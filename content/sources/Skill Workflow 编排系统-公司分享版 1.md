# WeaveSpec：把 Superpowers 从开发规范升级为可运行工作流
# WeaveSpec：把 Superpowers 从开发规范升级为可运行工作流

报告日期：xxxx  
报告类型：内部使用经验总结  
分享者：xxx  

## 一句话结论

Superpowers 解决的是“AI 开发应该遵循什么最佳规范”：先头脑风暴、再确认 spec、再写实现计划、再 TDD 执行、再 review。

WeaveSpec 解决的是下一层问题：**当这些规范和内部 skills 已经存在，怎么把它们快速组合成可运行、可恢复、可对比、可复用的团队 SOP。**

所以这个项目不是简单复用 Superpowers，而是在 Superpowers 之上补了一层 workflow 编排能力：把“开发方法论”变成“可执行流程系统”。

## 为什么这件事值得分享

现在 AI 开发已经不缺单点能力。我们有很多好用的 skills，也有 Superpowers 这类成熟开发规范。但真实团队落地时，问题往往出在组合层：

- 每次开发都知道应该先 spec、再 plan、再执行、再验证，但每次都要临时组织。
- 一个流程里可能要组合开源 skill、内部 skill、专项审查 skill，但前后顺序靠人记。
- 任务中断后，状态和中间产物散在聊天上下文里，恢复成本高。
- 想替换一个 review skill 或测试 skill 做对比时，很难保证输入一致。
- SOP 写在文档里，但不能直接运行、不能恢复、不能 A/B 对比。

WeaveSpec 的价值就在这里：**它不是再造一个 Superpowers，而是把 Superpowers、内部 skills 和团队规则编排成可运行 workflow。**

## Superpowers 与 WeaveSpec 的关系

| 维度 | Superpowers | WeaveSpec |
|---|---|---|
| 核心定位 | 开发最佳规范和 skills 集合 | 多 skill 工作流编排系统 |
| 解决问题 | 单次开发应该怎么做才规范 | 多个规范和 skills 怎么组合、运行和复用 |
| 典型能力 | brainstorming、writing-plans、TDD、review、执行计划 | YAML workflow、DAG 依赖、状态持久化、断点恢复、gate、A/B compare |
| 使用方式 | 人或 agent 按 skill 流程逐步调用 | `/workflow:*` 命令直接运行定义好的流程 |
| 产物形态 | spec、plan、测试、review 等单步产物 | workflow 定义、运行记录、步骤输出、对比报告 |
| 团队复用 | 需要团队约定如何组合 | 流程模板可复制、可审查、可演进 |

一句话概括：

**Superpowers 提供“正确做事的方法”；WeaveSpec 提供“让这套方法可运行、可复用、可优化的编排层”。**

## WeaveSpec 改进了什么

### 1. 从“方法论”变成“可运行流程”

Superpowers 告诉我们开发应该分阶段：先理解问题，再设计方案，再写计划，再执行，再验证。

WeaveSpec 把这些阶段写进 workflow YAML，通过 `/workflow:run` 直接执行。流程不再只是一段说明，而是有步骤、有依赖、有输入输出、有状态的运行单元。

### 2. 从“顺序靠人记”变成“DAG 编排”

复杂开发流程不是简单的一条直线。比如 API 开发里，设计确认后，后端和前端可以并行；实现后再做集成测试、代码审查、文档生成和发布确认。

WeaveSpec 通过 `depends_on` 表达步骤依赖，支持 DAG 编排和并行组，让流程结构显式化。

### 3. 从“聊天上下文”变成“状态持久化”

普通 AI 开发流程一旦中断，很容易丢上下文。WeaveSpec 每次运行会生成 `.workflow/runs/` 记录，保存 `state.yaml` 和每一步输出。

这带来两个直接价值：

- 失败后可以 `--resume` 从中断点继续。
- 复盘时能看到每一步到底输出了什么，而不是凭印象回忆。

### 4. 从“手感判断”变成“同输入 A/B 对比”

当一个步骤效果不好时，传统做法是凭感觉换 prompt 或换 skill。

WeaveSpec 提供 `/workflow:compare`：在同一个 workflow、同一个 step、同一个输入下，对比两个 skill 或两个变体，并保存对比输出和报告。

这解决的是一个很实际的问题：**优化单步质量时，先保证输入一致，再比较结果。**

### 5. 从“文档 SOP”变成“可执行 SOP”

很多团队 SOP 写得很完整，但执行时仍然要靠人记。WeaveSpec 把 SOP 写成 workflow 定义：

- 哪些步骤先后执行。
- 哪些步骤需要人工确认。
- 哪些步骤可以并行。
- 哪些输出需要保存。
- 哪些步骤可以替换对比。

这样 SOP 不只是“提醒人怎么做”，而是“系统按这个流程跑”。

### 6. 从“个人配置”变成“插件分发”

WeaveSpec 不是只在一个项目里手工复制 `.claude/` 和 `.workflow/`。它被打包成 Claude Code plugin，包含：

- `commands/workflow/`：`init`、`list`、`create`、`run`、`compare`
- `agents/workflow/`：`workflow-validator`、`diff-reporter`
- `templates/definitions/`：内置 workflow 模板

这让团队可以通过插件方式安装和升级，而不是每个项目各自复制一份流程。

## 背景

### 1. 相关工作背景情况

项目名称：WeaveSpec / Skill Workflow 编排系统

核心功能：将多个 AI skill 和开发规范组合成可复用 workflow，支持 DAG 依赖编排、状态持久化、断点恢复、步骤替换、A/B 对比和人工 gate 控制。

它可以组合的能力包括：

1. Superpowers：头脑风暴、spec 确认、实现计划、执行计划、TDD、review 等开发最佳规范。
2. Karpathy skills：编码前思考、简洁优先、精准修改、目标驱动执行。
3. 百度内部 skill：内部代码资产复用。
4. 团队内部 skill：金额流转代码审查等专项审查。

### 2. 传统方式痛点

| 痛点           | 具体表现                                                       |
| ------------ | ---------------------------------------------------------- |
| 规范存在，但组合靠人   | 知道要用 brainstorming、writing-plans、TDD、review，但每次顺序和衔接都靠临时组织 |
| SOP 存在，但不能运行 | 文档写了流程，但系统不会按文档自动执行、恢复、记录                                  |
| 中断后难恢复       | 聊天上下文断了之后，很难知道当前执行到哪一步                                     |
| 单步质量难优化      | 想换一个 skill 做对比，但输入不一致时结论不可靠                                |
| 团队复制成本高      | 一套好流程不容易在其他项目中快速安装和复用                                      |

### 3. AI 介入后的预期和实际效果

预期效果：把“先锁规则、再出 spec、再计划、再执行、再验证”的开发规范，编排成可运行、可恢复、可对比的团队 workflow。

实际效果：WeaveSpec 已经通过 Claude Code plugin 方式提供 `/workflow:init`、`/workflow:list`、`/workflow:create`、`/workflow:run`、`/workflow:compare`，并用 YAML workflow 定义承载团队 SOP。

## AI 使用前后对比

| 环节 | 之前：使用单点 skills / Superpowers | 现在：使用 WeaveSpec 后 | 效率提升 | 质量提升 |
|---|---|---|---|---|
| 流程启动 | 人手工决定先用哪个 skill、后用哪个 skill | `/workflow:run <name>` 直接运行既定流程 | 减少临时组织成本 | 执行路径一致 |
| 流程定义 | 流程写在文档或脑子里 | YAML 定义 steps、depends_on、gate、inputs、outputs | SOP 可复制 | 流程可审查 |
| 任务中断 | 上下文断了就要人工找回状态 | `.workflow/runs/` 保存 state 和 step 输出，支持 `--resume` | 降低恢复成本 | 过程可追溯 |
| 单步优化 | 凭感觉替换 prompt 或 skill | `/workflow:compare` 同输入比较两个 skill 或变体 | 缩短试错路径 | 对比更可信 |
| 人工介入 | 每一步都可能被打断确认 | gate 只放在方向分叉和不可逆动作前 | 减少上下文切换 | 人的判断放在关键点 |
| 团队分发 | 手工复制配置和流程 | Claude Code plugin + workflow templates | 降低推广成本 | 版本更容易同步 |

## 工具组合

| AI 工具/组件 | 用途 | 在 WeaveSpec 中的角色 |
|---|---|---|
| WeaveSpec Workflow Plugin | 提供 workflow 命令、模板、validator、diff reporter | 编排层和分发层 |
| Superpowers | 提供开发最佳规范，如 brainstorming、writing-plans、TDD、review | 被编排的核心开发规范 |
| Karpathy skills | 编码前思考、简洁优先、精准修改、目标驱动执行 | 补充工程判断规则 |
| 内部代码资产复用 skill | 扫描和复用内部代码资产 | 接入公司内部知识 |
| 金额流转代码审查 skill | 对金额流转相关代码做专项检查 | 接入团队风险控制 |
| workflow-validator agent | 校验 YAML、skill 引用、DAG 无环、gate 配置 | 保证 workflow 可执行 |
| diff-reporter agent | 汇总 A/B 对比输出并生成报告 | 支撑单步骤优化 |

## 使用案例：把 spec mode 变成可运行 workflow

### 案例目标

把“需求 → doc.md → 确认 → tasks.md → 确认 → 执行 → summary.md”的 spec mode 流程，变成一条可执行、可恢复、可复盘的 workflow。

这个流程的重点不是让 AI 直接开始编码，而是先把需求、设计、任务和执行边界明确下来，再进入实现阶段。

### 完整工作流程

| 阶段 | 做什么 | 价值 |
|---|---|---|
| 1. 生成 `doc.md` | 分析需求和上下文，输出技术规范文档 | 先统一理解，减少后续方向漂移 |
| 2. 确认 `doc.md` | 展示文档，等待用户审查和确认 | 把设计阶段歧义提前消化 |
| 3. 生成 `tasks.md` | 基于 spec 拆出可执行任务列表 | 把规范转成执行计划 |
| 4. 确认 `tasks.md` | 用户确认任务顺序和粒度 | 锁定执行路径 |
| 5. 执行任务 | 逐个执行任务并更新状态 | 保持执行透明，避免上下文混乱 |
| 6. 生成 `summary.md` | 记录完成过程、关键决策和最终产出 | 形成可复盘资产 |

### 对应 WeaveSpec 能力

| 需求 | WeaveSpec 支持 |
|---|---|
| 多阶段流程 | YAML `steps` + `depends_on` |
| 中途确认 | `gate: user_confirm` |
| 中断恢复 | `/workflow:run <name> --resume` |
| 每步输出留痕 | `.workflow/runs/<run>/step-*.output.md` |
| 运行状态追踪 | `.workflow/runs/<run>/state.yaml` |
| 单步优化 | `/workflow:compare` |

## 另一个案例：API 标准开发流程

项目内置的 `api-development` workflow 更能体现 WeaveSpec 与 Superpowers 的差异。

它不是简单调用一个 skill，而是把 API 开发拆成：

1. API 设计
2. 后端实现
3. 前端集成
4. 集成测试
5. 代码审查
6. 文档生成
7. 发布部署

其中设计阶段和发布阶段保留人工 gate，后端和前端可以并行开发，测试、review、文档和发布按依赖继续推进。

这说明 WeaveSpec 的重点是：**把开发规范编排成团队级流程，而不是把 Superpowers 当成一个单独 skill 调用。**

## 适用场景

| 场景 | 为什么适合 WeaveSpec | 注意点 |
|---|---|---|
| Spec mode 开发 | 链路长、规则多、需要先确认再执行 | 必须明确 doc/tasks/summary 的产物标准 |
| 标准 API 开发 | 设计、前后端、测试、文档、发布有清晰依赖 | 发布前必须保留人工 gate |
| 后端功能开发 | 可组合 brainstorming、writing-plans、TDD、质量审查 | 示例 skill 需要替换为真实可用 skill |
| 专项代码审查 | 可把安全、金额流转、质量检查并入统一流程 | 审查标准必须清楚 |
| 内容发布流程 | 翻译、格式化、发布天然是多步骤 SOP | 对外发布前必须确认 |
| 单步 skill 优化 | 同输入 A/B 对比能减少主观判断 | 样本要稳定，不能换输入比较 |

## 心得与经验

### 做这些事

1. **先判断是否需要 workflow**  
   高频、标准化、多步骤、有复盘价值的任务适合 WeaveSpec；一次性探索任务不一定适合。

2. **把 Superpowers 当作规范来源，不是终点**  
   Superpowers 提供好的开发动作，WeaveSpec 要做的是把这些动作编排成团队可复用流程。

3. **每个 step 尽量只做一件事**  
   一个 step 对应一个职责清楚的 skill。步骤越清楚，后续替换和对比越容易。

4. **gate 只放在关键点**  
   方向分叉和不可逆动作前需要人工确认；普通中间步骤不要频繁打断。

5. **保留运行记录**  
   每次运行都保存状态和中间产物。失败后先看记录，再决定改哪个 step。

6. **用 compare 优化单步骤**  
   在相同输入下替换 skill，再比较结果。不要用不同输入做 A/B 对比。

7. **改 workflow，不要只改单次输出**  
   单次手修只能救这一轮，调整 workflow 才能让后续所有运行受益。

### 避免这些事

1. **不要把 WeaveSpec 写成“复用 Superpowers”**  
   这个项目的核心是编排层、状态层、对比层和分发层。

2. **不要把 workflow 当成超长 Prompt**  
   Workflow 是步骤、依赖、状态、gate 和输出的组合，不是把提示词叠长。

3. **不要每一步都加人工确认**  
   过多 gate 会把人拖回流水线质检员位置。

4. **不要忽略 validator**  
   YAML、skill 引用、DAG 和 gate 配置需要校验，否则流程会变成不可运行文档。

## 可复用方法

其他团队如果要复用这套思路，可以按这个顺序走：

1. 找一个高频、重复、边界清楚的工作流。
2. 列出已有可用规范和 skills，包括 Superpowers、内部 skill、专项审查 skill。
3. 把流程拆成 steps，明确每一步输入、输出和完成标准。
4. 用 `depends_on` 表达步骤依赖，而不是只写自然语言顺序。
5. 只在方向分叉和不可逆动作前设置 `user_confirm`。
6. 保存 workflow YAML，并用 validator 检查。
7. 运行后保留 state 和 step 输出。
8. 对效果不稳定的单步，用 `/workflow:compare` 做同输入对比。
9. 把改进写回 workflow 定义，而不是只修单次产物。

## 结论

WeaveSpec 的核心价值，不是提供另一个开发 skill，也不是简单复用 Superpowers。

它真正补上的，是 Superpowers 之外的四层能力：

- **编排层**：把多个 skills 和规范组织成 DAG workflow。
- **状态层**：保存运行记录，支持断点恢复和复盘。
- **优化层**：通过 Skill Swap 和 A/B compare 优化单步骤。
- **分发层**：通过 Claude Code plugin 和模板把流程交给团队复用。

从这个角度看，Superpowers 更像“开发规范库”，WeaveSpec 更像“团队 AI 工作流运行时”。

## 下一步建议

- 选一个高频开发流程，例如 API 开发或后端功能开发，替换模板里的占位 skill，跑通真实案例。
- 为团队内部高风险环节补充专项 skill，例如金额流转、安全、权限、发布检查。
- 把每次运行记录作为复盘材料，持续优化 workflow 定义。

## 代码地址

[weavespec](https://git.yy.com/wufeilong/weavespec)
