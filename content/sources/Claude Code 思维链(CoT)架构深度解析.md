---
title: Claw Code 思维链(CoT)架构深度解析
date: 2026-04-02
tags: [architecture, rust, agent, chain-of-thought, claw-code]
---

# Claw Code 思维链(CoT)架构深度解析

> 基于 Claw Code 项目（Claude Code 的 clean-room Rust 重写）的源码分析，拆解其 Agent 系统中"思维链"的完整实现机制。

## 概述

在 Claw Code 项目中，**思维链不是一个单独的模块**，而是由 **六个层次的协同机制** 共同构成。可以把它理解为一条从"用户输入"到"最终回答"之间的多轮推理链路。

```
第一层: System Prompt     → 思维规则注入（"宪法"）
第二层: Agentic Loop      → 思维链驱动引擎（核心循环）
第三层: Session 消息结构   → 思维链记忆体（结构化存储）
第四层: Permission 权限    → 思维链安全阀（行动约束）
第五层: Hook 中间件       → 思维链外部干预点
第六层: Compaction 压缩   → 思维链记忆压缩
```

---

## 第一层：System Prompt 注入 — 推理的"思维规则"

**核心文件**: `rust/crates/runtime/src/prompt.rs`

System Prompt 是思维链的"宪法"。它告诉模型该如何思考。`SystemPromptBuilder::build()` 输出一个分段结构：

```
┌─────────────────────────────────────────┐
│ 1. Intro Section                        │  ← "你是一个交互式 Agent"
│ 2. Output Style (可选)                  │  ← 控制推理输出风格
│ 3. System Section                       │  ← 工具权限、标签系统
│ 4. Doing Tasks Section                  │  ← 推理行为准则
│ 5. Actions Section                      │  ← 安全行动约束
│ ---- DYNAMIC_BOUNDARY ----              │  ← 静态/动态分界线
│ 6. Environment Context                  │  ← 当前目录、日期、平台
│ 7. Project Context                      │  ← git status/diff 快照
│ 8. Instruction Files (CLAW.md)          │  ← 用户自定义推理指令
│ 9. Runtime Config                       │  ← 运行时配置
│ 10. LSP Context (可选)                  │  ← 代码诊断/定义/引用
│ 11. Append Sections                     │  ← 额外上下文
└─────────────────────────────────────────┘
```

### 关键约束注入

`get_simple_doing_tasks_section()` 中定义了指导模型推理方式的核心规则：

```rust
"Read relevant code before changing it"          // 先读后改
"Do not add speculative abstractions"            // 不臆测
"If an approach fails, diagnose the failure"     // 失败先诊断
"Report outcomes faithfully"                     // 如实报告
```

### 动态边界（SYSTEM_PROMPT_DYNAMIC_BOUNDARY）

`prompt.rs` 第 38 行定义了一个特殊分隔符，将 prompt 分为：

- **静态规则区**（模型应遵循的思维规范）— 每次对话不变
- **动态上下文区**（每次对话变化的环境信息）— 每次可能变

这让 API 层可以对静态部分做缓存（Anthropic prompt caching），减少重复 token 消耗。从价格上看，cache_read 价格是 $1.5/M vs 普通 input $15/M — **10 倍的成本差异**。

---

## 第二层：Agentic Loop — 思维链的"驱动引擎"

**核心文件**: `rust/crates/runtime/src/conversation.rs`（第 153-263 行）

这是整个思维链最核心的运行机制。`run_turn()` 实现了一个开放式迭代循环：

### 执行流程

```
用户说: "帮我修复 bug"
    │
    ▼
┌──────────────────────────────────────────────────┐
│ Iteration 1: 模型"思考"                           │
│   TextDelta: "Let me read the file first."       │  ← 思维链第1步
│   ToolUse: read_file("src/lib.rs")               │  ← 决定行动
│                                                   │
│ → 执行工具 → 获得文件内容                          │
│                                                   │
│ Iteration 2: 模型接收工具结果继续"思考"             │
│   TextDelta: "I see the bug on line 42..."        │  ← 思维链第2步
│   ToolUse: edit_file(...)                         │  ← 修复行动
│                                                   │
│ → 执行工具 → 获得编辑结果                          │
│                                                   │
│ Iteration 3: 模型确认完成                          │
│   TextDelta: "The bug has been fixed."            │  ← 思维链终止
│   (无 ToolUse → 退出循环)                         │
└──────────────────────────────────────────────────┘
```

### 核心代码逻辑

```rust
loop {
    // 1. 将完整对话历史发给 LLM
    let events = self.api_client.stream(request)?;

    // 2. 解析 LLM 的流式响应
    let (assistant_message, usage) = build_assistant_message(events)?;

    // 3. 提取工具调用
    let pending_tool_uses = /* 从 blocks 中提取 ToolUse */;

    // 4. 如果没有工具调用 → 思维链结束
    if pending_tool_uses.is_empty() {
        break;
    }

    // 5. 逐一执行工具（带权限检查和 Hook）
    for (tool_use_id, tool_name, input) in pending_tool_uses {
        // 权限检查 → PreHook → 执行 → PostHook
        // 将结果推入会话
    }
    // 6. 回到循环顶部，携带工具结果重新调用 LLM
}
```

### 关键设计

- **泛型策略模式**: `ConversationRuntime<C: ApiClient, T: ToolExecutor>` — API 客户端和工具执行器均可插拔
- **同步 trait 接口**: `ApiClient::stream()` 返回 `Result<Vec<AssistantEvent>>` — 有意设计为同步，简化测试
- **Hook 中间件**: PreToolUse/PostToolUse 构成中间件管道，可拦截/修改工具执行
- **迭代上限**: 主对话 `usize::MAX`（无限），子 Agent 限制为 32 轮

### 思维链的终止条件

模型回复中 **不包含任何 ToolUse block** 时，循环退出。这意味着模型"思考完毕"，不再需要外部信息或行动。

---

## 第三层：Session 消息结构 — 思维链的"记忆体"

**核心文件**: `rust/crates/runtime/src/session.rs`

思维链的每一步都以结构化消息存储在 `Session` 中。

### 数据结构

```rust
pub enum ContentBlock {
    Text { text },                                      // 模型的推理文本（"思考"过程）
    ToolUse { id, name, input },                        // 模型决定使用的工具
    ToolResult { tool_use_id, tool_name, output, is_error },  // 工具执行结果
}

pub struct ConversationMessage {
    pub role: MessageRole,          // System | User | Assistant | Tool
    pub blocks: Vec<ContentBlock>,  // 一条消息可包含多个 block
    pub usage: Option<TokenUsage>,  // token 用量追踪
}

pub struct Session {
    pub version: u32,
    pub messages: Vec<ConversationMessage>,
}
```

### 一个典型思维链在 Session 中的记录

```
messages[0]: User     → [Text("帮我修复 src/lib.rs 的 bug")]
messages[1]: Assistant → [Text("让我先看一下文件"), ToolUse(read_file)]
messages[2]: Tool     → [ToolResult(read_file, "文件内容...")]
messages[3]: Assistant → [Text("第42行有空指针"), ToolUse(edit_file)]
messages[4]: Tool     → [ToolResult(edit_file, "编辑成功")]
messages[5]: Assistant → [Text("Bug 已修复")]  ← 无 ToolUse，循环结束
```

### 流式响应重组

`build_assistant_message()` 将 SSE 流事件重组为结构化消息：

```rust
fn build_assistant_message(events: Vec<AssistantEvent>) -> ... {
    for event in events {
        match event {
            TextDelta(delta) => text.push_str(&delta),     // 累积思考文本
            ToolUse { .. } => {
                flush_text_block(&mut text, &mut blocks);  // 思考文本截断为 block
                blocks.push(ContentBlock::ToolUse { .. }); // 接行动决策
            }
            MessageStop => finished = true,
        }
    }
    flush_text_block(&mut text, &mut blocks); // 最后的思考文本
}
```

**性能细节**: `flush_text_block` 使用 `std::mem::take` 零拷贝地将累积的思考文本转为 `ContentBlock::Text`，避免 String clone。

---

## 第四层：权限门控 — 思维链的"安全阀"

**核心文件**: `rust/crates/runtime/src/permissions.rs`

思维链中每一步工具调用都要经过权限检查。

### 权限层级

```rust
pub enum PermissionMode {
    ReadOnly,           // 最低 — 只读操作
    WorkspaceWrite,     // 中等 — 可写文件
    DangerFullAccess,   // 高危 — 可执行任意命令
    Prompt,             // 交互 — 每次询问用户
    Allow,              // 最高 — 完全放行
}
```

通过 `#[derive(PartialOrd, Ord)]`，权限判断只需一个 `>=` 比较：

```rust
if current_mode == PermissionMode::Allow || current_mode >= required_mode {
    return PermissionOutcome::Allow;
}
```

### 对思维链的影响

```
模型想调用 bash("rm -rf /")
    │
    ▼
PermissionPolicy::authorize()
    │
    ├─ ReadOnly + 需要 DangerFullAccess → 直接拒绝
    ├─ WorkspaceWrite + 需要 DangerFullAccess → 弹出 Prompter 让用户决定
    ├─ DangerFullAccess 或 Allow → 放行
    │
    ▼
拒绝 → ToolResult(is_error: true, "requires danger-full-access permission")
       → 这个拒绝信息回到 LLM，模型会"重新思考"换一个安全的方案
```

当工具被拒绝时，拒绝原因作为 `ToolResult(is_error: true)` 返回给模型。模型看到错误后会**调整推理策略** — 比如不用 bash 直接删文件，而是改用 edit_file 修改。这就是思维链的**自适应能力**。

---

## 第五层：Hook 中间件 — 思维链的"外部干预点"

**核心文件**: `rust/crates/runtime/src/hooks.rs`

Hook 允许在思维链的每一步工具调用前后注入外部逻辑。

### 执行流程

```
模型决定调用工具
    │
    ▼
┌─ PreToolUse Hook ──────────────────────┐
│  执行用户配置的 shell 命令               │
│  JSON payload 通过 stdin 传入           │
│  环境变量: HOOK_TOOL_NAME, HOOK_EVENT   │
│                                         │
│  exit 0 → 放行 (stdout 作为反馈)       │
│  exit 2 → 拒绝 (阻断思维链当前步骤)    │
│  其他   → 警告 (继续但附加警告信息)     │
└─────────────────────────────────────────┘
    │
    ▼ (如果放行)
  执行工具
    │
    ▼
┌─ PostToolUse Hook ─────────────────────┐
│  同样的机制，但可以看到工具输出          │
│  可以拒绝（标记结果为 error）           │
│  或附加反馈信息到工具结果               │
└─────────────────────────────────────────┘
    │
    ▼
  结果 = merge_hook_feedback(pre_feedback + tool_output + post_feedback)
  → 回到 LLM 继续思维链
```

### Hook 反馈合并

```rust
fn merge_hook_feedback(messages: &[String], output: String, denied: bool) -> String {
    // 将 hook 的 stdout 信息追加到工具输出后面
    // 用 "Hook feedback:" 或 "Hook feedback (denied):" 标签区分
    // 模型在下一轮思考时能看到这些额外反馈
}
```

### 设计优势

- **语言无关** — 任何可执行文件/脚本都能当 hook
- **故障隔离** — hook 崩溃（非 0 非 2 退出码）不影响主进程，只产生警告
- **双通道上下文** — 通过 stdin（完整 JSON）和环境变量同时传递上下文

---

## 第六层：Compaction — 思维链的"记忆压缩"

**核心文件**: `rust/crates/runtime/src/compact.rs`

当思维链过长（超出上下文窗口）时，压缩机制启动。

### 压缩触发条件

```rust
fn should_compact(session, config) -> bool {
    compactable.len() > config.preserve_recent_messages   // 消息数超限
    && estimated_tokens >= config.max_estimated_tokens     // token 数超限
}
```

### 压缩前后对比

```
压缩前:
  [msg1(user)] [msg2(assistant)] [msg3(tool)] ... [msg20(assistant)]
                                                        ↑ 太长了

压缩后:
  [System: 压缩摘要] [msg19(user)] [msg20(assistant)]
                      ↑ 保留最近 N 条
```

### 五维度摘要提取

`summarize_messages()` 从被压缩的消息中提取五种关键信息：

1. **Scope** — 压缩了多少条消息（user/assistant/tool 分类计数）
2. **Tools mentioned** — 思维链中用过哪些工具
3. **Recent user requests** — 最近 3 条用户请求
4. **Pending work** — 含 "todo"/"next"/"remaining" 关键词的未完成事项
5. **Key files** — 提到过的代码文件（通过路径+扩展名启发式提取）
6. **Key timeline** — 每条被压缩消息的单行摘要

### Token 估算

```rust
fn estimate_message_tokens(message: &ConversationMessage) -> usize {
    text.len() / 4 + 1   // 英文平均 4 字符 ≈ 1 token
}
```

不引入 tiktoken 或任何分词器依赖，用 `len()/4` 近似。够用（误差 < 20%），零依赖，零延迟。

### 递归压缩

当再次压缩已经有压缩摘要的 session 时，`merge_compact_summaries()` 会：

```
Previously compacted context:   ← 旧摘要的要点
  - Scope: 5 earlier messages
Newly compacted context:        ← 新压缩的要点
  - Recent user requests: ...
Key timeline:                   ← 保留最近的时间线
```

保证信息不会随着多次压缩指数衰减。

### 续接指令

压缩摘要末尾附加明确指令：

```
"Continue the conversation from where it left off without asking
 the user any further questions. Resume directly — do not acknowledge
 the summary, do not recap what was happening..."
```

防止模型浪费 token 说"让我继续之前的工作" — 直接干活。

---

## 完整数据流

```
                    ┌──────────────────────┐
                    │   System Prompt      │ ← 第一层：思维规则注入
                    │   (prompt.rs)        │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
              ┌────►│   Agentic Loop       │ ← 第二层：驱动引擎
              │     │   (conversation.rs)  │
              │     └──────────┬───────────┘
              │                │
              │     ┌──────────▼───────────┐
              │     │  LLM API 调用        │
              │     │  (api/ crate)        │
              │     └──────────┬───────────┘
              │                │
              │     ┌──────────▼───────────┐
              │     │  解析响应:            │
              │     │  Text + ToolUse      │ ← 第三层：结构化记忆
              │     │  (session.rs)        │
              │     └──────────┬───────────┘
              │                │
              │         有 ToolUse?
              │        /          \
              │      Yes           No → 返回结果，思维链结束
              │       │
              │  ┌────▼──────────────┐
              │  │ 权限检查           │ ← 第四层：安全阀
              │  │ (permissions.rs)  │
              │  └────┬──────────────┘
              │       │
              │  ┌────▼──────────────┐
              │  │ PreToolUse Hook   │ ← 第五层：外部干预
              │  │ (hooks.rs)        │
              │  └────┬──────────────┘
              │       │
              │  ┌────▼──────────────┐
              │  │ 执行工具           │
              │  │ (tools/ crate)    │
              │  └────┬──────────────┘
              │       │
              │  ┌────▼──────────────┐
              │  │ PostToolUse Hook  │
              │  └────┬──────────────┘
              │       │
              │  ┌────▼──────────────┐
              │  │ 结果推入 Session   │
              │  └────┬──────────────┘
              │       │
              │  ┌────▼──────────────┐
              │  │ 是否需要压缩?      │ ← 第六层：记忆压缩
              │  │ (compact.rs)      │
              │  └────┬──────────────┘
              │       │
              └───────┘  (回到循环顶部)
```

---


## 总结

Claw Code 的思维链 = **System Prompt 规定思维规则** + **Agentic Loop 驱动多轮推理** + **Session 结构化存储每步推理** + **权限/Hook 约束每步行动** + **Compaction 在上下文溢出时压缩记忆**。

六层协同，构成了从"模型思考"到"工具行动"再到"结果反馈"的完整闭环推理链。其高效不是来自某个单一技巧，而是在每个层次都做了"刚好够用"的最简决策 — 不多做、不少做，避免过度工程。
