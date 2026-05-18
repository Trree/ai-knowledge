

> 目标：把全局规范拆成“索引 + 细分领域文档”，默认上下文更轻；需要时再按需加载。

## 永久硬约束（始终生效）

- 默认中文输出（除非用户明确要求英文）。
    
- 本文件是当前会话内优先级最高的全局规范入口；当与 `~/.codex/prompts/**` 或其他参考文档冲突时，以本文件为准（系统/用户/项目内 AGENTS 明确覆盖除外）。
    
- 需求未对齐前：仅做必要的只读侦察（如 `ls`/`rg`/`cat`/`--version`），不改文件、不做破坏性操作。
    
- 一旦用户明确“批准/继续/按默认选项执行”：不中途再反问澄清，自主闭环推进；关键假设/取舍/技术债记录到项目根 `tasks.md`（不存在则创建）。
    
- 长耗时任务（>1 分钟）且不在 tmux：创建/复用会话 `codex-worker`，在其中运行后续命令，避免中断。
    
- 单文件修改必须使用 `apply_patch`；禁止用 shell 重定向直接写文件。
    
- 输出遵循 Less is More：只在对齐、报错、完成三个节点输出必要信息；文件改动优先用 diff/路径+要点描述。
    

## 上下文优先级

- 加载与覆盖顺序：`~/.codex/AGENTS.md` < 项目根 `AGENTS.md` < 子目录 `AGENTS.md`（就近覆盖）。
    
- 若项目已有规范（README/CONTRIBUTING/架构约束等），以项目规范为准；本文件只提供“全局底线 + 路由”。
    

## 按需加载索引（触发 → 需要阅读的细分规范）

> 规则：命中任一触发条件时，必须先读取对应文件内容（只读）再回答；无法读取则说明原因并继续按本索引的硬约束执行。

- 计划/方案/重构/架构变更/需求歧义较大 → `~/.codex/agents/process.md`﻿
    
- 工程化/降熵/可维护性/可观测性/复杂排障 → `~/.codex/agents/engineering.md`﻿
    
- 开发/设计/实现/编码/落地/执行/闭环/端到端验证 → `~/.codex/agents/agent-charter.md`﻿
    
- 开发/设计/实现/代码评审/重构/简化/复杂度/向后兼容 → `~/.codex/agents/dev-craft.md`﻿
    
- Java/Spring/分层/事务/异常治理/JPA → `~/.codex/agents/java-backend.md`﻿
    
- 安全/鉴权/权限/注入/SSRF/敏感信息 → `~/.codex/agents/security.md`﻿
    
- 缺陷/bug 修复/测试/覆盖率/回归/E2E 验证 → `~/.codex/agents/testing.md`﻿
    
- 提示词/Prompt/AGENTS/CLAUDE.md/全局规范/纳管 → `~/.codex/agents/prompt-management.md`﻿
    

## agents 文档规范（用于新增/维护）

- ﻿`agents/*.md` 单文件 ≤200 行，单一主题；避免把细节堆回本索引。
    
- 以“触发条件 + 可执行检查清单”为主；少讲背景，多给可落地命令/验收标准。
    
- 变更遵循降熵：删过时规则、合并重复点、显式标注临时方案（原因/影响/回滚或还债计划/验收）。
    

## 占用参考（可选）

- 行数：`wc -l ~/.codex/AGENTS.md ~/.codex/agents/*.md`﻿
    
- Token：如需精确 token 计数，优先使用你环境里的 tokenizer 工具；否则以“行数 + 字符数”近似评估即可。
    

testing.md

security.md

prompt-management.md

process.md

java-backend.md

engineering.md

dev-craft.md

agent-charter.md