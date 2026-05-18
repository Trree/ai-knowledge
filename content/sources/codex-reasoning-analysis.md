# OpenAI Codex CLI 推理过程源码分析报告

> 基于 https://github.com/openai/codex 源码（codex-rs Rust 版本）

---

## 一、整体架构

Codex CLI 分为两个实现：

- **codex-cli**：早期 TypeScript 版本（`codex-cli/`），现仅保留启动入口
- **codex-rs**：Rust 重写版本（`codex-rs/`），是当前主力实现

核心代码集中在 `codex-rs/core/src/` 下，关键文件：

| 文件 | 职责 |
|------|------|
| `codex.rs` | 主入口，Session 管理，Agent 循环（`run_turn`） |
| `compact.rs` | 本地 Compaction（记忆压缩） |
| `compact_remote.rs` | 远程 Compaction（服务端压缩） |
| `stream_events_utils.rs` | 流式事件处理，tool call 分发 |
| `client.rs` | 模型 API 客户端（SSE/WebSocket） |
| `tools/` | 工具定义与路由 |

---

## 二、Codex 是 ReAct 模式吗？

**是的，Codex 本质上使用了 ReAct（Reasoning + Acting）模式**，但有其特殊性：

### 经典 ReAct 的三步循环：
```
Thought → Action → Observation → Thought → Action → ...
```

### Codex 的实际实现：

Codex **不需要显式实现 ReAct 的 "Thought" 步骤**，因为它依赖的底层模型（o3/codex-mini）**内置了 reasoning 能力**。推理过程发生在模型内部（通过 `reasoning_effort` 参数控制），Codex Agent 框架只需要实现 **Action → Observation 的循环**，模型自身完成 Reasoning。

具体来说：

```
[模型内部 Reasoning] → tool_call（Action）→ tool_output（Observation）
         ↑                                           |
         └───────────────────────────────────────────┘
                        循环直到模型不再发出 tool_call
```

这在代码中体现为 `run_turn()` 中的 **双层循环** 结构。

---

## 三、Agent 循环核心流程

### 3.1 外层循环：`run_turn()`（`codex.rs:5659`）

```
用户输入 → [pre-sampling compact] → [构建 context] → 内层循环 → [auto compact] → 返回
```

```rust
// codex.rs:5881
loop {
    // 1. 处理 pending input（用户中途插入的消息）
    // 2. 构建 sampling_request_input（完整历史）
    // 3. 调用 run_sampling_request()（内层循环）
    match run_sampling_request(...).await {
        Ok(result) => {
            // 如果 token 超限 + 还需要 follow-up → 触发 auto compact
            if token_limit_reached && needs_follow_up {
                run_auto_compact(...).await;
                continue;  // compact 后继续循环
            }
            // 如果不需要 follow-up → turn 结束
            if !needs_follow_up {
                // 运行 stop hooks / after_agent hooks
                break;
            }
            continue;  // 需要 follow-up，继续循环
        }
        Err(e) => { /* 错误处理 */ break; }
    }
}
```

### 3.2 内层循环：`try_run_sampling_request()`（`codex.rs:7261`）

这是 **单次 API 请求** 的流式处理循环：

```rust
// 1. 发送请求到模型 API（SSE/WebSocket 流）
let mut stream = client_session.stream(prompt, ...).await?;

// 2. 逐个处理流式事件
loop {
    let event = stream.next().await;
    match event {
        // 模型输出了一个完整的 item（可能是文本/tool_call/reasoning）
        ResponseEvent::OutputItemDone(item) => {
            let result = handle_output_item_done(&mut ctx, item, ...).await?;
            if let Some(tool_future) = result.tool_future {
                in_flight.push_back(tool_future);  // 异步执行 tool
            }
            needs_follow_up |= result.needs_follow_up;
        }
        // 流式文本/reasoning delta
        ResponseEvent::OutputItemAdded(item) => { /* 流式输出 */ }
        // Reasoning 内容
        ResponseEvent::ServerReasoningIncluded(included) => { /* 记录 */ }
        // 请求完成
        ResponseEvent::Completed { token_usage, .. } => {
            // 等待所有 in-flight tool calls 完成
            while let Some(tool_result) = in_flight.next().await { ... }
            break Ok(SamplingRequestResult { needs_follow_up, ... });
        }
    }
}
```

### 3.3 Tool Call 处理（`stream_events_utils.rs:197`）

```rust
pub async fn handle_output_item_done(ctx, item, ...) -> Result<OutputItemResult> {
    match ToolRouter::build_tool_call(item) {
        // 模型发出了 tool call → 异步执行
        Ok(Some(call)) => {
            let tool_future = ctx.tool_runtime.handle_tool_call(call, ...);
            output.needs_follow_up = true;   // ← 关键：有 tool call 就需要再次请求模型
            output.tool_future = Some(tool_future);
        }
        // 不是 tool call → 普通文本/reasoning 输出
        Ok(None) => { /* 记录消息 */ }
        // tool call 错误 → 将错误作为 tool output 返回给模型
        Err(FunctionCallError::RespondToModel(message)) => {
            output.needs_follow_up = true;   // ← 错误也需要 follow-up
        }
    }
}
```

### 3.4 完整流程图

```
用户输入 "修复 login.ts 的 bug"
        │
        ▼
┌─── run_turn() 外层循环 ──────────────────────────────────┐
│                                                           │
│  [1] pre-sampling compact（如果 token 接近上限）          │
│  [2] 注入 context（instructions + history + user message）│
│  [3] 构建 Prompt { input, tools, instructions }           │
│        │                                                  │
│        ▼                                                  │
│  ┌── run_sampling_request() ─────────────────────────┐    │
│  │                                                   │    │
│  │  → API Request (stream)                           │    │
│  │    ← [Reasoning] 模型内部思考（不可见/部分可见）  │    │
│  │    ← OutputItemDone: local_shell("cat login.ts")  │    │
│  │         → 异步执行 tool → 返回文件内容            │    │
│  │    ← needs_follow_up = true                       │    │
│  │                                                   │    │
│  └───────────────────────────────────────────────────┘    │
│        │                                                  │
│        ▼ (needs_follow_up = true → 继续循环)              │
│                                                           │
│  [4] 将 tool output 加入 history                          │
│  [5] 重新构建 input（包含 tool output）                   │
│        │                                                  │
│        ▼                                                  │
│  ┌── run_sampling_request() ─────────────────────────┐    │
│  │                                                   │    │
│  │  → API Request (stream)                           │    │
│  │    ← [Reasoning] 分析文件内容，找到 bug           │    │
│  │    ← OutputItemDone: apply_patch(...)              │    │
│  │         → 应用代码补丁                            │    │
│  │    ← needs_follow_up = true                       │    │
│  │                                                   │    │
│  └───────────────────────────────────────────────────┘    │
│        │                                                  │
│        ▼ (继续循环)                                       │
│                                                           │
│  ┌── run_sampling_request() ─────────────────────────┐    │
│  │                                                   │    │
│  │  → API Request                                    │    │
│  │    ← OutputItemDone: "已修复 login.ts 的 bug..."  │    │
│  │    ← needs_follow_up = false                      │    │
│  │                                                   │    │
│  └───────────────────────────────────────────────────┘    │
│        │                                                  │
│        ▼ (needs_follow_up = false → break)                │
│  [6] 运行 stop hooks / after_agent hooks                  │
│                                                           │
└───────────────────────────────────────────────────────────┘
        │
        ▼
    返回 last_agent_message
```

---

## 四、推理（Reasoning）处理

### 4.1 Reasoning 由模型内置，不是 Agent 框架实现

Codex 的 reasoning 完全依赖底层模型（o3/codex-mini 系列），框架只负责：

1. **传递 `reasoning_effort` 参数**（low/medium/high）控制推理深度
2. **传递 `reasoning_summary` 参数**控制推理摘要可见性
3. **接收和转发 `ResponseEvent::ServerReasoningIncluded`** 事件
4. **处理 `ResponseItem::Reasoning`** 类型，将其转为 `TurnItem` 展示给用户

```rust
// codex.rs:7443 - 处理 reasoning 事件
ResponseEvent::ServerReasoningIncluded(included) => {
    sess.set_server_reasoning_included(included).await;
}

// stream_events_utils.rs:330 - Reasoning item 作为普通非 tool 项处理
ResponseItem::Reasoning { .. } => {
    let turn_item = parse_turn_item(item)?;
    // 作为 AgentReasoning turn item 发送给 UI
}
```

### 4.2 Reasoning Effort 配置

```
ReasoningEffort: low | medium | high
```

这个参数直接传给 OpenAI Responses API，控制模型内部 "思考" 的计算预算。

### 4.3 与 Claude 的对比

| 特性 | Codex (o3/codex-mini) | Claude (extended thinking) |
|------|----------------------|---------------------------|
| Reasoning 实现位置 | 模型内部（RL 训练的搜索式推理） | 模型内部（thinking tokens） |
| Agent 框架参与 | 仅传参数、转发事件 | 仅传参数、转发 thinking block |
| 可见性 | `reasoning_summary` 控制 | thinking block 可选输出 |
| 控制粒度 | `reasoning_effort`: low/medium/high | `budget_tokens` 精细控制 |

---

## 五、Compaction — 记忆压缩机制

**Codex 确实有完善的 Compaction（上下文压缩）机制**，而且比 Claude Code 更复杂，支持本地和远程两种模式。

### 5.1 触发条件

```rust
// codex.rs:5967-5994
let total_usage_tokens = sess.get_total_token_usage().await;
let token_limit_reached = total_usage_tokens >= auto_compact_limit;

// 两种触发时机：
// 1. Pre-sampling compact：turn 开始前，token 已超限
// 2. Mid-turn compact：turn 中间，tool call 后 token 超限
if token_limit_reached && needs_follow_up {
    run_auto_compact(&sess, &turn_context,
        InitialContextInjection::BeforeLastUserMessage).await;
    continue;
}
```

### 5.2 本地 Compaction（`compact.rs`）

适用于非 OpenAI 提供商（如本地模型）。

**Compaction Prompt**（`templates/compact/prompt.md`）：
```
You are performing a CONTEXT CHECKPOINT COMPACTION. Create a handoff
summary for another LLM that will resume the task.

Include:
- Current progress and key decisions made
- Important context, constraints, or user preferences
- What remains to be done (clear next steps)
- Any critical data, examples, or references needed to continue
```

**Summary Prefix**（`templates/compact/summary_prefix.md`）：
```
Another language model started to solve this problem and produced a
summary of its thinking process. You also have access to the state
of the tools that were used by that language model. Use this to build
on the work that has already been done and avoid duplicating work.
```

**处理流程**：

```
1. 收集完整历史 history
2. 发送 compact prompt 给模型，要求生成摘要
3. 模型返回摘要文本 summary_text
4. 构建新历史：
   - 保留最近的 user messages（最多 20K tokens）
   - 添加 summary_text 作为压缩后的上下文
   - 保留 ghost snapshots（用于 /undo 功能）
5. 替换 session 的 history 为压缩后版本
6. 重新计算 token 用量
```

```rust
// compact.rs:324
fn build_compacted_history(initial_context, user_messages, summary_text) {
    // 从最近的 user messages 开始，倒序选取，直到 20K tokens 上限
    for message in user_messages.iter().rev() {
        if tokens <= remaining { selected.push(message); }
    }
    // 最后追加 summary_text 作为压缩上下文
    history.push(summary_text);
}
```

### 5.3 远程 Compaction（`compact_remote.rs`）

适用于 OpenAI 提供商，由服务端执行压缩。

```rust
// compact_remote.rs:50
fn should_use_remote_compact_task(provider) -> bool {
    provider.is_openai()  // 仅 OpenAI 使用远程压缩
}
```

**流程差异**：
- 远程压缩将完整的 prompt（包含 tools 定义）发给 `compact_conversation_history` API
- 服务端返回压缩后的历史，客户端进行后处理
- 后处理包括：移除 developer 消息、保留真实 user 消息和 hook prompts

### 5.4 Initial Context 注入策略

```rust
enum InitialContextInjection {
    BeforeLastUserMessage,  // Mid-turn compact: 在最后一条用户消息前注入
    DoNotInject,            // Pre-turn compact: 不注入（下次 turn 会自动注入）
}
```

这个设计确保了 compact 后模型仍然能看到正确的系统指令和上下文。

### 5.5 模型切换时的 Compact

```rust
// codex.rs:6174-6210
// 当从大 context window 模型切换到小 context window 模型时
// 会使用前一个模型先执行 compact，再切换
async fn maybe_run_previous_model_inline_compact(...) {
    if total_usage_tokens > new_auto_compact_limit
        && old_model != new_model
        && old_context_window > new_context_window {
        // 用旧模型执行 compact
        run_auto_compact(&sess, &previous_model_turn_context, ...).await;
    }
}
```

---

## 六、工具系统

### 6.1 内置工具

| 工具 | 文件 | 用途 |
|------|------|------|
| `local_shell` | `local_tool.rs` | 执行 shell 命令（沙箱内） |
| `apply_patch` | `apply_patch_tool.rs` | 应用代码补丁 |
| `plan` / `update_plan` | `plan_tool.rs` | 计划管理 |
| `request_user_input` | `request_user_input_tool.rs` | 向用户提问 |
| `agent_job` | `agent_job_tool.rs` | 子 Agent 任务 |
| `view_image` | `view_image.rs` | 查看图片 |
| `js_repl` | `js_repl_tool.rs` | JS REPL |
| MCP tools | `mcp_tool.rs` | MCP 协议工具 |
| Dynamic tools | `dynamic_tool.rs` | 动态工具 |

### 6.2 Tool Router

```rust
// tools/src/lib.rs
// ToolRouter 负责：
// 1. 解析模型输出中的 tool_call
// 2. 路由到正确的 tool 实现
// 3. 执行 tool 并返回结果
// 4. 权限检查和沙箱策略
```

### 6.3 并行 Tool Call

```rust
// codex.rs:7283
let mut in_flight: FuturesOrdered<BoxFuture<'_, ...>> = FuturesOrdered::new();

// tool call 被添加到 in_flight 队列
if let Some(tool_future) = output_result.tool_future {
    in_flight.push_back(tool_future);
}

// Completed 时等待所有 in-flight 完成
while let Some(tool_result) = in_flight.next().await { ... }
```

---

## 七、协作模式（Collaboration Modes）

Codex 支持多种协作模式，通过不同的 system prompt 模板实现：

| 模式 | 模板 | 特点 |
|------|------|------|
| Default | `collaboration_mode/default.md` | 默认交互模式 |
| Plan | `collaboration_mode/plan.md` | 3 阶段规划模式（探索→意图→实现） |
| Execute | `collaboration_mode/execute.md` | 独立执行模式，不问问题 |
| Pair Programming | `collaboration_mode/pair_programming.md` | 结对编程模式 |

### Plan 模式的 3 阶段：

1. **PHASE 1 — Ground in the environment**: 先探索代码库，不问用户
2. **PHASE 2 — Intent chat**: 明确用户意图，多问问题
3. **PHASE 3 — Implementation chat**: 确定实现细节
4. **Finalization**: 输出 `<proposed_plan>` 块

---

## 八、System Prompt 结构

主系统指令位于 `templates/model_instructions/gpt-5.2-codex_instructions_template.md`：

```
You are Codex, a coding agent based on GPT-5.

{{ personality }}

# Working with the user
  - 格式化规则（Markdown, 不用 emoji, 文件引用格式...）
  - 呈现规则

# General
  - 优先使用 rg 搜索

# Editing constraints
  - 默认 ASCII
  - apply_patch 优先
  - 不随意 revert 用户更改
  - 不使用 git 交互模式
  - 不使用 destructive git 命令

# Plan tool 使用规则
# Special user requests（时间查询、代码审查...）
# Frontend tasks 设计规则
```

---

## 九、与 Claude Code 的架构对比

| 维度 | Codex CLI | Claude Code |
|------|-----------|-------------|
| 实现语言 | Rust（主）+ TypeScript | TypeScript |
| Agent 循环 | `run_turn` 外层 + `try_run_sampling_request` 内层 | 类似的 turn-based 循环 |
| Reasoning | 模型内置（o3 reasoning），框架仅转发 | Extended thinking，框架仅转发 |
| Compaction | 本地 + 远程双模式 | 本地压缩（conversation compaction） |
| Tool 系统 | `ToolRouter` + 并行执行 | 类似的工具路由 + 并行 |
| 沙箱 | Linux sandbox + Windows sandbox + 网络代理 | 文件系统 + 命令权限 |
| 协作模式 | Default/Plan/Execute/PairProgramming | 类似的 plan mode |
| API 协议 | OpenAI Responses API (SSE/WebSocket) | Anthropic Messages API |
| 权限 | 分层：Never/UnlessTrusted/OnFailure/OnRequest/Granular | Auto-accept/审批模式 |

---

## 十、总结

1. **Codex 使用的是 ReAct 模式的变体**：Reasoning 由模型内置，Agent 框架实现 Action-Observation 循环
2. **不是显式 CoT（Chain of Thought）**：没有 "Let me think step by step" 的显式提示，reasoning 是模型原生能力
3. **双层循环架构**：外层管理 turn 生命周期和 compaction，内层管理单次 API 请求的流式处理和 tool call
4. **完善的 Compaction 机制**：支持本地/远程两种模式，pre-turn 和 mid-turn 两种时机，以及模型切换时的智能压缩
5. **工具并行执行**：使用 `FuturesOrdered` 管理多个并发的 tool call
6. **`needs_follow_up` 是核心控制信号**：有 tool call 返回 → 需要 follow-up → 继续循环；无 tool call → turn 结束
