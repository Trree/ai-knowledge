

> 本文档汇集了 Claude Code 创始人 Boris Cherny (@bcherny) 在 X 平台分享的所有使用技巧，由粉丝站点 howborisusesclaudecode.com 整理，共计 87 个技巧。
>
> *网站由 [@CarolinaCherry](https://github.com/carolinacherry) 构建，非 Anthropic 官方网站。所有内容来源于 Boris Cherny 的公开帖子。*

---

## 第一章：13个核心技巧（2026年1月2日）

### 1. 并行运行5个Claude实例

- 使用5个独立的 git checkout，每个标签页运行一个实例
- 配置 iTerm2 通知，随时知晓哪个 Claude 需要输入

### 2. Web+移动端并行

- 在 claude.ai/code 额外运行5-10个会话
- 使用 `&` 或 `--teleport` 在本地与Web间切换
- 早晨用 iPhone 启动任务，回到电脑后接续

### 3. Opus 4.5 + 思维模式

- 对所有任务使用 Opus 4.5 with thinking
- "更少引导 + 更好工具使用 = 整体更快"

### 4. 共享 CLAUDE.md

- 全团队共用一个 CLAUDE.md，提交到 git
- 每次发现错误即更新："每次看到 Claude 做错了就添加进去"

### 5. 代码审查中使用 @.claude

- PR 评论中标记 @.claude 自动更新 CLAUDE.md
- 称之为"复利工程"（Compounding Engineering）

### 6. 从 Plan Mode 开始

- Shift+Tab 两次进入计划模式
- 流程：计划 → 细化 → 自动接受编辑 → 一次完成

### 7. 斜杠命令处理内循环

- 频繁操作封装为命令，存于 `.claude/commands/`
- 可内嵌 Bash 预计算信息

### 8. 子代理自动化常见工作流

```
.claude/agents/
  build-validator.md
  code-architect.md
  code-simplifier.md
  verify-app.md
```

### 9. PostToolUse Hook 自动格式化

```json
"PostToolUse": [{
  "matcher": "Write|Edit",
  "hooks": [{"type": "command", "command": "bun run format || true"}]
}]
```

### 10. 预授权安全权限

- 使用 `/permissions` 预授权常见命令
- 支持通配符：`Bash(bun run *)`, `Edit(/docs/**)`

### 11. 工具集成

- Slack MCP、BigQuery CLI、Sentry 错误日志

### 12. 处理长时间任务

- 方案：后台代理验证 / Stop Hook / `--permission-mode=dontAsk`

### 13. ⭐ 最重要：验证机制

> "Give Claude a way to verify its work... it will **2-3x the quality**"

使用 Chrome 扩展让 Claude 自测 UI 变更，形成反馈闭环。

---

## 第二章：10个进阶技巧（2026年1月31日）

### 1. 更多并行（Git Worktrees）

```bash
git worktree add .claude/worktrees/my-worktree origin/main
cd .claude/worktrees/my-worktree && claude
```

设置 shell 别名（za/zb/zc）快速切换

### 2. 复杂任务先规划

- 一个 Claude 写计划，另一个作为高级工程师来审查
- 验证步骤也使用 plan mode，不只用于构建

### 3. 深度投入 CLAUDE.md

- 每次纠正后说："更新你的 CLAUDE.md 避免重蹈覆辙"
- 维护每个任务/项目的笔记目录

### 4. 创建自定义技能

- 每天做超过一次的操作 → 封装为技能
- `/techdebt` 命令发现重复代码
- 同步 Slack/GDrive/Asana/GitHub 的上下文聚合命令

### 5. Claude 自主修复 Bug

- 粘贴 Slack bug 讨论链接直接说"fix"
- "直接说'修复失败的 CI 测试'"
- 指向 docker 日志排查分布式系统问题

### 6. 提示词技巧升级

- "审问我这些变更，在我通过你的测试之前不要提 PR"
- "告诉我这行不通，用最优雅的方案重新实现"
- 提前写详细规格说明

### 7. 终端环境配置

- 推荐 **Ghostty**（同步渲染、24位色、Unicode支持）
- `/statusline` 自定义状态栏
- 语音听写（macOS: fn×2），说话速度是打字的3倍

### 8. 使用子代理

- 追加"use subagents"让 Claude 投入更多算力
- 子代理保持主代理上下文窗口清洁

### 9. 数据与分析

- 使用 `bq` CLI 即时拉取分析指标
- "我个人已经6个月以上没写过 SQL 了"

### 10. 用 Claude 学习

- `/config` 启用 Explanatory/Learning 输出模式
- 让 Claude 生成可视化 HTML 演示
- ASCII 图表解释新协议和代码库
- 间隔重复学习技能

---

## 第三章：12个自定义技巧（2026年2月11日）

### 1. 终端配置

- `/config` 设置深色/浅色模式
- `/terminal-setup` 启用 Shift+Enter 换行
- `/vim` 启用 Vim 模式

### 2. 调整努力级别

- `/model` 选择努力级别：Low / Medium / High
- Boris 个人全部使用 High

### 3. 安装插件、MCP和技能

- `/plugin` 浏览安装官方或公司内部插件市场
- LSP 支持所有主流语言

### 4. 创建自定义代理

- `.claude/agents/` 下放 `.md` 文件
- 可配置：名称、颜色、工具集、权限模式、模型
- `settings.json` 中 `"agent"` 字段设置默认代理

### 5. 预审批常见权限

- 通配符语法：`Bash(bun run *)` 或 `Edit(/docs/**)`
- 提交到团队 `settings.json`

### 6. 启用沙箱

- `/sandbox` 启用开源沙箱运行时
- 支持文件和网络隔离
- 三种模式：自动允许 / 普通权限 / 无沙箱

### 7. 添加状态行

- `/statusline` 自定义显示模型、目录、上下文用量、费用
- 团队每人配置都不同

### 8. 自定义快捷键

- `/keybindings` 重新映射任意按键
- 配置存于 `~/.claude/keybindings.json`，实时生效

### 9. 设置 Hooks

- 权限请求路由到 Slack 或 Opus
- Stop Hook 决定是否继续运行
- 工具调用前后处理

### 10. 自定义 Spinner 动词

- 在 `settings.json` 中添加/替换默认动词列表
- 提交到源码控制与团队共享

### 11. 输出样式

- `/config` 设置输出风格：Explanatory / Learning / Custom
- 调整 Claude 的语气和格式

### 12. 全面自定义

- 支持 **37个设置** 和 **84个环境变量**
- 支持代码库级、子文件夹级、个人级、企业策略级配置

---

## 第四章：内置 Worktree 支持（2026年2月20日）

### 1. `claude --worktree` 隔离运行

```bash
claude --worktree my_worktree
claude --worktree my_worktree --tmux
```

### 2. Desktop App Worktree

- Code 标签页 → 勾选 "worktree" 复选框

### 3. 子代理支持 Worktree

```
> Migrate all sync io to async. Launch 10 parallel agents with worktree isolation.
```

### 4. 自定义代理始终使用 Worktree

```yaml
# .claude/agents/worktree-worker.md
---
name: worktree-worker
model: haiku
isolation: worktree
---
```

### 5. 非 Git 版本控制支持

- 通过 `WorktreeCreate` / `WorktreeRemove` Hooks 支持 Mercurial、Perforce、SVN

---

## 第五章：生产发布技能（2026年2月27日）

### /simplify — 提升代码质量

- 并行代理审查：重用机会、质量问题、效率改进
- 附加到任何提示末尾使用

### /batch — 并行代码迁移

```bash
> /batch migrate src/ from Solid to React
```

- 交互式规划，然后扇出到数十个并行代理
- 每个代理有独立 worktree，自测后提 PR

---

## 第六章：三个功能（2026年3月）

### /loop — 定期任务调度

```bash
/loop babysit all my PRs
/loop every morning use the Slack MCP to give me a summary
```

最长运行3天，无人值守

### 代码审查 — 代理团队猎寻 Bug

- PR 开启时自动派遣专业审查代理
- Anthropic 内部使用后：每位工程师代码产出提升 **200%**

### /btw — 工作中的旁链询问

```bash
> /btw what does the retry logic do?
```

- 单轮回答，无工具调用，但有完整对话上下文

---

## 第七章：一周功能发布（2026年3月13日）

### /effort max — 最大推理模式

```
四级：low → medium → high → max
```

### 远程控制 — 从手机启动新会话

```bash
claude remote-control
```

### 语音模式 — 100%用户开放

- Desktop 和 Cowork 中可用

### 设置脚本 — 自动化云环境

- 新会话启动前运行，可安装依赖、配置环境

### `claude --name` — 命名会话

```bash
claude --name "auth-refactor"
```

### Plan Mode 后自动命名

- 根据计划内容自动推断描述性名称

### /color — 自定义提示符颜色

- 多会话并行时快速视觉区分

### PostCompact Hook — 响应上下文压缩

```json
"PostCompact": [{"hooks": [{"command": "echo 'Context was compacted'"}]}]
```

---

## 第八章：新超能力（2026年3月23-25日）

### 自动模式 — 更安全地跳过权限

- 内置分类器评估每个动作
- Shift+Tab 循环：plan mode → auto mode → normal mode
- Boris 评价："no 👏 more 👏 permission prompts 👏"

### /schedule — 云端定时任务

```bash
/schedule a daily job that looks at all PRs shipped since yesterday and update our docs
```

- 不同于 `/loop`（本地运行3天），这个在云端运行，关闭电脑也能跑

### iMessage 插件 — 短信控制 Claude

```bash
/plugin install imessage@claude-plugins-official
```

### 自动记忆 & 自动梦境

```bash
/memory  # 配置记忆
/dream   # 触发记忆整理
```

- Auto-dream 类似 REM 睡眠：整理、清理、合并记忆

---

## 第九章：隐藏与未充分利用的功能（2026年3月29日）

### 1. 移动应用

- iOS/Android Claude 应用 → Code 标签页

### 2. 会话在设备间迁移

```bash
claude --teleport   # 本地会话转到云端
/remote-control     # 远程控制本地会话
```

Boris："我在 /config 中设置了'为所有会话启用远程控制'"

### 3. /loop 和 /schedule

Boris 实际运行的循环：

```bash
/loop 5m /babysit         # 自动处理代码审查、rebase
/loop 30m /slack-feedback # 每30分钟基于Slack反馈提PR
/loop /post-merge-sweeper # 处理遗漏的代码审查评论
/loop 1h /pr-pruner       # 关闭过期PR
```

### 4. Hooks

- **SessionStart**: 动态加载上下文
- **PreToolUse**: 记录每条Bash命令
- **PermissionRequest**: 路由到 WhatsApp 审批
- **Stop**: 自动继续运行

### 5. Cowork Dispatch

- Claude Desktop 的安全远程控制
- 可使用 MCP、浏览器、电脑

### 6. Chrome 扩展（前端工作必备）

- "给Claude一种验证输出的方式"是最重要的技巧
- 比其他类似 MCP 更可靠

### 7. Desktop App

- 自动启动和测试 Web 服务器

### 8. Fork 会话

```bash
/branch                                      # 会话内分叉
claude --resume <session-id> --fork-session  # CLI分叉
```

### 9. /btw

```
> /btw how do i spell daushund?
dachshund — German for "badger dog"
```

### 10. Git Worktrees

```bash
claude -w  # 在新worktree中启动
```

### 11. /batch

- 面试式规划，然后扇出到数十/数百/数千个代理

### 12. --bare（SDK启动加速10倍）

```bash
claude -p "summarize this codebase" --output-format=stream-json --bare
```

- 跳过本地 CLAUDE.md、settings、MCP 的搜索

### 13. --add-dir（访问更多目录）

```bash
claude --add-dir /path/to/other-repo
/add-dir /path/to/other-repo
```

### 14. --agent（自定义代理）

```bash
# .claude/agents/ReadOnly.md
---
name: ReadOnly
tools: Read
---
claude --agent=ReadOnly
```

### 15. /voice（语音输入）

- CLI: `/voice` 然后按住空格
- Desktop: 语音按钮
- iOS: 启用听写功能
- Boris "大部分编码都是说话完成的，而不是打字"

---

## 第十章：新功能发布（2026年4月14-16日）

### Routines — 定时和事件驱动的 Claude Code

触发器：

- **Schedule**: cron 表达式
- **GitHub event**: PR 开启/合并、Issue 开启
- **API**: POST 到 webhook URL

连接器：GitHub、Linear，可扩展

### /rewind — 回退而非纠正

```bash
/rewind  # 或双击 Esc
```

> **纠正路径**：上下文 = 文件读取 + 失败尝试 + 纠正 + 修复
> **回退路径**：上下文 = 文件读取 + 一次知情提示 + 修复

### /compact vs /clear

- **/compact**: 有损LLM摘要，保持动力，细节可能模糊

  ```bash
  /compact focus on the auth refactor, drop the test debugging
  ```

- **/clear**: 手写摘要，从零开始，上下文精确可控

- **规则**: 新任务用 `/clear`，相关任务用带提示的 `/compact`

### 自动压缩阈值

```bash
CLAUDE_CODE_AUTO_COMPACT_WINDOW=400000 claude
```

- 上下文衰退在 300-400k tokens 时出现
- 400k 是 Thariq 推荐的折中值

### 委托而非指导（Cat Wu on Opus 4.7）

- **旧模式**：描述步骤 → 观察输出 → 纠正 → 下一步
- **新模式**：写简洁简报 → 启动 → 等待完成

### 全任务上下文（首轮提供完整信息）

三要素：

1. **目标**: 成功标准
2. **约束**: 不做什么、不动什么
3. **验收标准**: 如何验证完成

### xhigh — Opus 4.7 新默认努力级别

```
low → medium → high → xhigh → max
```

- xhigh 是 Opus 4.7 的新默认值
- 自适应思考（而非固定思考预算）
- **max 只对当前会话有效**，其他级别持久化

---

## 第十一章：精通 Opus 4.7（2026年4月16日）

### 1. 自动模式 + 并行 Claude

- 权限路由到模型分类器
- 安全操作自动审批，危险操作仍标记
- 可以同时运行更多 Claude

### 2. /fewer-permission-prompts

```bash
/fewer-permission-prompts
```

扫描会话历史，推荐添加到许可列表的命令

### 3. Recaps — 了解离开期间发生了什么

```
✻ recap: Fixing the post-submit transcript shift bug...
Next: I need a screen recording of the remaining horizontal rewrap...
```

在 `/config` 中可禁用

### 4. /focus — 只看最终结果

```bash
/focus  # 隐藏中间过程，只显示最终变更
```

与 auto mode 完美配合：一个消除权限提示，一个消除视觉噪音

### 5. 努力级别精通

- xhigh 用于大多数任务，max 用于最难任务
- max 只对当前会话有效
- 可以用自然语言控制："Think carefully step-by-step"

### 6. /go — 验证+简化+提PR

Boris 的工作流程："许多提示看起来像 'Claude do blah blah /go'"

`/go` 会：
1. 端到端测试（bash/browser/computer use）
2. 运行 `/simplify`
3. 提 PR

### 7. 从4.6升级到4.7的三个变化

1. **校准的响应长度**: 简单问题更短，开放分析更长
2. **减少自动工具使用**: 更多推理，需明确指导何时用工具
3. **更谨慎的子代理派遣**: 40个文件的重构需明确要求并行

### 8. 任务完成通知

- 声音提醒、Stop Hook、iTerm2 通知、Recaps
- 组合使用：auto mode + focus mode + /go + 通知 = 完全自主

---

## 附录：技能安装与创作指南

### 技能类型（Thariq 总结的9种）

1. **库和API参考**: 内部库、CLI、SDK
2. **产品验证**: 驱动运行中的产品进行验证
3. **数据分析**: ID、字段名、查询模式
4. **业务自动化**: 多工具工作流 → 单命令
5. **脚手架和模板**: 框架正确的样板代码
6. **代码质量和审查**: 对抗性审查、风格、测试
7. **CI/CD和部署**: 提交、推送、安全部署
8. **事故手册**: 症状→调查→报告
9. **基础设施运维**: 安全限制的清理和维护

### 9个技能创作技巧

1. **跳过显而易见的内容** — 聚焦于偏离默认路径的内容
2. **构建 Gotchas 章节** — 高价值内容，每次踩坑就记录
3. **渐进式披露** — SKILL.md 作为中枢，子文件做具体工作
4. **不要强制规定** — 提供信息而非逐步脚本
5. **描述=触发器** — 为模型而写，包含触发短语
6. **考虑初始化** — 在 `config.json` 存储配置
7. **持久化数据** — 使用 `${CLAUDE_PLUGIN_DATA}` 存储日志/JSON
8. **提供代码** — 包含辅助脚本供 Claude 组合使用
9. **按需 Hooks** — 会话级别的守卫（/careful 阻止 rm -rf）

### 一键安装 Boris 技能

```bash
mkdir -p ~/.claude/skills/boris && curl -L -o ~/.claude/skills/boris/SKILL.md https://howborisusesclaudecode.com/api/install
```

安装后使用：

```
> /boris
> How should I set up parallel Claude sessions?
```

包含 **87个技巧**，涵盖所有上述主题。
