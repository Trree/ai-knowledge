

> 一个融合 autoresearch 迭代循环与 Deep Research 信息获取能力的通用 Agent 执行协议。
> 用 7 个概念驱动任何有外部反馈的任务持续改进到收敛。

---

## 1. 问题：AI Agent 为什么会转圈

当前主流 AI Agent 工作流存在一个结构性缺陷：**自评估循环**。

```
agent 修改 → agent 自评 → agent 说「更好了」→ 继续修改 → ...
```

这个循环没有外部信号注入。Agent 既是执行者又是裁判，每一轮的「改进」本质上是对自身输出的重新措辞，不会产生新的事实、数据或验证结果。表现为：

- 代码修改后不跑测试，凭直觉判断「应该没问题了」
- 研究报告修改三轮，信息量不变，只是调了措辞和结构
- Agent 声称 improved readability，但没有任何可量化的指标支撑

根本原因：**缺少外部 oracle**。Agent 的改进判断没有经过独立于自身的外部验证。

---

## 2. 两个前置项目：autoresearch 与 Deep Research

### 2.1 Karpathy 的 autoresearch：迭代循环的原型

[autoresearch](https://github.com/karpathy/autoresearch) 是 Karpathy 实现的自主 ML 实验系统。核心流程：

```
修改代码 → 跑训练 → 读 validation loss → keep or revert → 重复
```

**5 个设计原语**：

| 原语 | 作用 | 为什么有效 |
|------|------|-----------|
| 标量指标 (val_bpb) | 唯一的好坏判据 | 客观、可比较、不可被 agent 操纵 |
| Keep/Revert | 棘轮机制 | 质量单调递增，不会退化 |
| 无限循环 | 人不在时持续运行 | 去掉人类在环的瓶颈 |
| 状态外化 | 写磁盘，可中断恢复 | 不依赖 context window |
| 固定预算 | 每轮资源可预测 | 可比较，可审计 |

**autoresearch 的核心思想**：改进是否真实发生，不由 agent 决定，由外部物理量决定。val_bpb 下降了就是下降了，agent 说什么都不算。

**局限**：只能处理有标量指标的执行任务（ML 训练）。无法处理信息获取类任务（研究、调研）。Oracle 类型单一（只有 execution oracle）。

### 2.2 Deep Research 产品：信息获取的管道

2024-2025 年 OpenAI / Google / Perplexity 推出的 Deep Research 产品。架构统一为单向管道：

```
规划 → 搜索 → 阅读 → 综合 → 输出报告
```

**6 个结构性不足**：

| 不足 | 说明 | 后果 |
|------|------|------|
| 只读不写 | 不能通过实验验证结论 | 无法产生一手知识 |
| 无闭环 | 不能自主迭代加深 | 一次性输出，质量上限低 |
| 无状态持久化 | 依赖 context window | 跨 session 遗忘 |
| 无验证机制 | 不自检矛盾 | 幻觉传播，来源可能互相矛盾 |
| 规划不可修正 | 计划锁死后只能执行 | 无法根据中间发现调整方向 |
| 单一输出模态 | 只产出文本 | 不产出代码、数据、实验 |

**核心问题**：Deep Research 做的是文献综述（literature review），不是研究（research）。真正的研究需要迭代——搜索、验证、实验、评估、保留或回滚——循环到收敛。

### 2.3 对比：两者各有一半

| 维度 | autoresearch | Deep Research | GDA |
|------|-------------|---------------|-----|
| 迭代循环 | ✅ | ❌ | ✅ |
| 外部反馈 | ✅ (execution) | ❌ | ✅ (execution + information) |
| 信息获取 | ❌ | ✅ | ✅ |
| Keep/Revert | ✅ | ❌ | ✅ (+ forced switch) |
| 收敛检测 | ❌ (人类手停) | ❌ (一次性) | ✅ (rescan stop) |
| 矛盾检测 | N/A | ❌ | ✅ (consistency check) |
| 通用性 | 仅 ML 训练 | 仅文献综述 | 任何有 oracle 的任务 |

**GDA 的定位**：autoresearch 的迭代循环骨架 + Deep Research 的信息获取能力 + 一层统一协议。

---

## 3. 系统架构

### 3.1 两阶段模型

```
Phase 1: EXECUTE                    Phase 2: IMPROVE
┌─────────────────────┐             ┌──────────────────────────────────┐
│ CLARIFY             │             │ Round 1: 全面扫描，排序          │
│   ↓                 │             │   ↓                              │
│ DECOMPOSE           │             │ ┌→ Rescan: 选最弱问题            │
│   ↓                 │  oracle?    │ │   ↓                            │
│ EXECUTE ←→ REPLAN   │ ────────→   │ │ Focused oracle call            │
│   ↓                 │   Yes       │ │   ↓                            │
│ BASELINE            │             │ │ Judge: new info?               │
└─────────────────────┘             │ │   ├─ Yes → keep, commit ──→ ┐  │
        │                           │ │   └─ No  → miss, rescan     │  │
      No oracle                     │ │        ├─ other target? ──→ ┘  │
        ↓                           │ │        └─ no target → STOP     │
      STOP                          │ └──────────────────────────────┘  │
                                    │ Budget hit → STOP                 │
                                    │ User interrupt → STOP             │
                                    └──────────────────────────────────┘
```

### 3.2 Oracle 分类

```
Oracle
├── Family A: Execution Oracle
│   ├── test suite (npm test, pytest, go test)
│   ├── coverage tool (istanbul, coverage.py)
│   ├── linter (eslint, ruff, clippy)
│   ├── compiler (tsc, rustc, gcc)
│   └── benchmark (hyperfine, criterion)
│
└── Family B: Information Oracle
    ├── web search
    ├── paper search (arxiv, semantic scholar)
    ├── codebase reading (grep, ast analysis)
    └── dataset inspection
```

区分标准：oracle 的输出是否独立于 agent 的判断。`npm test` 的结果不受 agent 影响——这是 execution oracle。web search 的结果不受 agent 影响——这是 information oracle。agent 自己读一遍文档然后说「我觉得写得不错」——这不是 oracle。

### 3.3 状态文件：goal-state.md

所有运行状态持久化到一个 markdown 文件，借鉴 autoresearch 的状态外化设计：

```yaml
phase: IMPROVE
round: 3
branch: gda/<tag>
best_commit: d4e5f6g
oracle_type: execution
budget: 10
```

Phase 1 目标表：

```
| id | goal | verify_cmd | expect | type | status |
|----|------|------------|--------|------|--------|
| G1 | fix empty email crash | npm test | all pass | hard | done |
```

Improve log（固定 6 字段）：

```yaml
- round: 1
  target: "coverage 45% in auth module"
  oracle_call: "add 3 edge-case tests → npm test --coverage"
  new_info: "coverage 45% → 82%, 3 edge cases pass"
  action: keep [commit abc1234]
  next_constraint: none

- round: 2
  target: "lint 2 warnings"
  oracle_call: "fix warnings → eslint"
  new_info: "none"
  action: miss
  next_constraint: must not target "lint 2 warnings" next round
```

6 个字段的设计目的：任意一轮的完整上下文可以从这 6 个字段完全恢复。Agent 中断后读 log 即可无缝继续。

### 3.4 核心概念（7 个，最小完备集）

| 概念 | 定义 | 为什么不能砍 |
|------|------|-------------|
| phase | execute / improve | 两阶段模型的骨架 |
| goal | Phase 1 子目标 | 驱动拆分和验证 |
| verify | 验证命令 | 外部判据，不可省 |
| oracle | 外部信息源 | 核心原则的载体 |
| round | 改进轮次 | 状态追踪和 budget 计数 |
| current_target | 本轮攻击的问题 | forced switch 需要追踪 |
| budget | 总轮次上限 | 硬停止条件，防止无限循环 |

v5 有 14 个概念（scout, problem map, saturated, targeting, scan, rank 等），v6 砍到 7 个。砍掉的概念要么是冗余的（scout = round 1），要么引入了不必要的不可逆性（saturated），要么是假全局（problem map）。

---

## 4. 关键机制详解

### 4.1 Forced Switch（替代 saturated）

**v5 设计（saturated）**：问题被标记 saturated 后永久关闭。

**问题**：不可逆 = 脆弱。解决问题 B 时获得的新信息可能让问题 A 重新可攻，但 saturated 锁死了回路。

**v6 设计（forced switch）**：

```
IF last round targeted X AND got no new info
THEN this round MUST NOT target X
```

一条规则。不是永久封杀，只是强制换一轮。`next_constraint` 字段显式记录约束。过几轮后 X 自动重新变为合法 target。

**实际效果**：在 benchmark 报告的 case 中，Round 1 搜竞品数据 miss。Round 2-3 打了别的问题。Round 4 回到竞品数据，换了搜索策略，找到了可用信息。如果用 saturated，这个发现不会发生。

### 4.2 Rescan Stop（替代全量遍历停止）

**v5 设计**：所有 problem map 中的问题都变成 done 或 saturated 时停止。

**问题**：有时需要空转多轮才能确认所有问题都已关闭。

**v6 设计**：miss 之后立即做 fresh rescan。

```
After a miss, rescan the full deliverable.
IF no actionable target exists OTHER THAN last_miss_target → stop.
ELSE continue with next best target.
```

判定在 miss 时刻立即发生，不需要再跑一整轮去发现没有 target。

### 4.3 Consistency Check（信息类任务安全网）

仅对 information oracle 生效。每 3 轮触发：

```
Re-read the full deliverable.
Check for contradictory claims.
IF found → resolving the contradiction becomes the next target.
```

为什么是 3 轮？前 1-2 轮加入的信息量通常不足以产生可检测的矛盾。3 是经验平衡点。

### 4.4 Evidence Tiebreaker（证据分级）

仅在 consistency check 发现矛盾时使用：

```
primary    — peer-reviewed paper, official docs, raw data
benchmark  — reproducible experiment, public benchmark
vendor     — white paper, product announcement, corporate blog
anecdotal  — forum post, blog opinion, social media
```

这不是准入门槛（所有证据都进入），是矛盾解决时的优先级。分级依据是可复现性和利益无关性。

### 4.5 两种 Agent 判断

```
Type 1: CAN outsource to oracle → MUST outsource
  代码质量 → 跑测试
  覆盖率   → coverage tool
  报告长度 → wc -l

Type 2: CANNOT outsource → allowed, with safety net
  信息相关性判断
  探索方向选择
  Safety net: consistency check + evidence tiebreaker
```

这是整个协议的核心原则。Type 1 消除了 agent 自评估的问题。Type 2 承认某些判断无法外包，但加了周期性自检和证据仲裁作为兜底。

---

## 5. 评估方法

### 5.1 协议自身的评估维度

| 维度 | 指标 | 如何测量 |
|------|------|---------|
| 概念经济性 | 核心概念数 | 数 SKILL.md 中不可消除的概念 |
| 收敛速度 | 平均轮次数 | 跑多个任务，统计到 CONVERGED 的轮次 |
| 误停率 | 本可继续但停了的比例 | 人工审查 CONVERGED 时是否还有可改进的点 |
| 空转率 | 没有新信息的轮次占比 | 统计 improve log 中 miss 的比例 |
| 恢复能力 | 中断后能否继续 | 杀掉 agent，重启，检查是否无缝续接 |

### 5.2 产出物的评估

GDA 不定义产出物的评估标准——这是 oracle 的职责。

- Execution oracle 任务：测试通过率、覆盖率、lint 错误数、benchmark 数值
- Information oracle 任务：信息覆盖度（人工审查）、来源数量和质量、矛盾数量

### 5.3 与无协议 baseline 的对比

最直接的评估方式：同一任务，用 GDA 和不用 GDA 各跑一次，比较：

- 最终产出物质量（由 oracle 判定）
- agent 转圈次数（无新信息的轮次）
- 完成时间和 token 消耗
- improve log 的审计清晰度

---

## 6. 优化策略

### 6.1 Oracle 选择优化

原则：选择信噪比最高的 oracle。

```
✅ npm test --coverage    → 精确的数值反馈
✅ eslint --format json   → 结构化的问题列表
❌ npm test（已全绿）      → 不会产生新信息
❌ 通用 web search        → 噪声太高
```

Focused oracle call 比 broad oracle call 有效。Round 1 用 broad 扫全面，后续轮次用 focused 打单点。

### 6.2 Budget 调优

默认 10 轮。调优依据：

- 代码 bug fix：3-5 轮通常够（问题空间小）
- 代码质量改进：5-8 轮（覆盖率/lint/类型安全多个维度）
- 研究报告：8-12 轮（信息获取和一致性检查需要更多轮次）
- 大型调研：15-20 轮（需要用户显式指定）

### 6.3 target 排序优化

默认按严重程度排序。可以根据场景调整：

```
severity-first  — 默认，适合大多数场景
tractability-first — 当最严重的问题明显不可解时
leverage-first — 当一个问题的解决会连锁解锁其他问题时
```

### 6.4 状态文件优化

goal-state.md 过大时会影响 agent 的 context window 利用效率。优化手段：

- improve log 超过 10 轮时，将早期轮次折叠为摘要
- Phase 1 目标表在 Phase 2 期间可压缩为单行总结
- 保持 improve log 最近 5 轮的完整记录

---

## 7. 最佳实践

### 7.1 任务适配

**适合 GDA 的任务**：

- 有明确外部验证手段的代码任务（测试、lint、benchmark）
- 需要多轮信息获取的研究/调研任务
- 需要在多个质量维度上持续改进的交付物

**不适合 GDA 的任务**：

- 纯创意任务（没有 oracle 可以判断创意好坏）
- 一次性简单修改（Phase 1 就够了，不需要 Phase 2）
- 实时交互任务（GDA 是批处理协议，不是对话协议）

### 7.2 Phase 1 最佳实践

- verify_cmd 必须是可执行的 shell 命令，不能是「人工检查」
- 研究任务的 verify_cmd 只检查存在性（`wc -l > N`、`grep heading`），不检查质量
- 每个 goal 的粒度应该是「一次 commit 能完成的量」
- REPLAN 最多两次重试 + 两种策略，超出就 BLOCKED，不要死磕

### 7.3 Phase 2 最佳实践

- **Round 1 必须全面扫描**，不要跳过。这是 v6 替代 Scout 阶段的机制
- **每轮只打一个 target**。不要试图一轮改多个问题，这样无法归因新信息来自哪个改动
- **严格判断新信息**。如果犹豫「这算不算新信息」，大概率不算。新信息应该是明确的、可指认的
- **miss 之后立刻 rescan**，不要凭记忆判断有没有其他 target
- **improve log 6 字段必须完整填写**，不能偷懒省略 next_constraint

### 7.4 研究任务最佳实践

- Phase 1 交付物用 markdown，章节结构清晰，方便 Phase 2 rescan
- Information oracle 优先搜 primary 和 benchmark 级别的来源
- 每 3 轮 consistency check 不要跳过，矛盾积累到后期修复成本更高
- 搜索策略 miss 后，下一次换关键词、换搜索引擎、换语言，不要用相同策略重试

### 7.5 调试与审计

- improve log 是最重要的调试工具。如果 agent 行为异常，先看 log
- `next_constraint` 字段可以追踪 forced switch 是否正确执行
- 如果 agent 在 Phase 2 转圈，检查它是否把「不是新信息」的东西当成了新信息
- CONVERGED 报告应该让人类能在 30 秒内理解「做了什么、停在哪、还有什么没做」

---

## 8. 版本演进

| 版本 | 核心变更 | 概念数 |
|------|---------|--------|
| v1-v3 | 基础的 goal decomposition + execution loop | ~8 |
| v4 | 加入 IMPROVE loop，要求外部 oracle | ~10 |
| v5 | 加入 Scout、Problem Map、Saturated | 14 |
| v6 | 合并 Scout 进 Round 1，砍掉 Problem Map 和 Saturated，加入 forced switch、consistency check、evidence tiebreaker | **7** |

v5 → v6 的核心教训：

1. **Scout 是假阶段**——和 Round 1 行为相同，拆成两步只增加状态管理负担
2. **Problem Map 是假全局**——3 次采样画的 map 给 agent「已看全」的错觉
3. **Saturated 不可逆 = 脆弱**——新信息可能让旧问题重新可攻
4. **概念过多**——14 个概念 vs autoresearch 的 5 个，正交维度爆炸

---

## 9. 部署

GDA 以 Claude Code SKILL.md 格式发布。安装后通过触发词激活：

```
触发词："目标驱动"、"GDA"、"帮我拆解"、"按目标执行"
```

协议文件：`SKILL.md`（< 300 行）+ `references/examples.md`（5 个 worked examples）

运行时产物：`goal-state.md`（状态文件，git tracked）

全部代码和协议开源，MIT 协议。
