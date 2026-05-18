#+title: 圆桌：个人如何自动化管理 Claude Code 膨胀的 Skills，使用 Hook 框架
#+date: [2026-04-08]
#+filetags: :roundtable:claude-code:hooks:skill-management:

* 议题与参会者

** 核心议题
个人如何自动化管理 Claude Code 膨胀的 Skills，使用 Hook 框架

** 参会者
- Kelsey Hightower (INTJ) — 前 Google 首席布道师，极简主义，声明式管理
- Rich Hickey (INTP) — Clojure 创造者，简单性工程，组合式设计
- Marie Kondo (ISFJ) — 整理咨询师，断舍离，仪式化决策
- Brendan Gregg (ISTJ) — 性能工程大师，数据驱动，可观测性
- Dan Abramov (INFP) — React 核心贡献者，开发者体验，渐进式架构

* 各轮讨论记录

** 第一轮：如何定义 Skill 膨胀？核心伤害是什么？

*** 发言记录

- 【Kelsey Hightower】【陈述】：膨胀不是数量问题，是治理缺位问题。未被管理的增长导致认知不可寻址性。
- 【Rich Hickey】【质疑】：治理是症状处理，根因是 skill 系统缺乏组合性设计。偶然复杂性 (incidental complexity) 无人设计。
- 【Marie Kondo】【补充】：膨胀首先是心理事件——囤积心理。核心伤害是持续的认知压迫感，而非报错。三个月未用可作边界。
- 【Brendan Gregg】【反驳】：三个月规则太主观，需数据驱动。定义膨胀的三个维度：使用频次、功能重叠度、调用延迟。
- 【Dan Abramov】【综合】：最终伤害是启动摩擦 + LLM 上下文污染。人和模型都是受害者。

*** 核心争议
Skill 膨胀的本质是治理问题、设计问题、心理问题还是度量问题？

*** ASCII 框架图
#+begin_example
              Skill 膨胀的多维诊断框架
  ┌──────────────────────────────────────────────┐
  │              受害者维度                        │
  │     ┌──────────┐      ┌──────────┐           │
  │     │  人 (DX)  │◄────►│ 模型 (CTX)│           │
  │     └─────┬────┘      └────┬─────┘           │
  │           ▼                ▼                  │
  │  ┌─────────────────────────────────┐         │
  │  │         表层症状：找不到/选不对     │         │
  │  └──────────────┬──────────────────┘         │
  │    ┌────────────┼────────────┐               │
  │    ▼            ▼            ▼               │
  │ 治理缺位    设计缺陷     心理囤积             │
  │ (Kelsey)   (Rich)      (Kondo)              │
  │    └────────────┼────────────┘               │
  │                 ▼                             │
  │        ┌────────────────┐                    │
  │        │  度量层 (Gregg)  │                    │
  │        └────────────────┘                    │
  └──────────────────────────────────────────────┘
#+end_example

** 第二轮：Hook 框架的能力边界在哪里？

*** 发言记录

- 【Brendan Gregg】【陈述】：Hook 能做四层——采集 (PostToolUse)、聚合 (脚本)、告警 (阈值)、执行 (危险)。盲区：无法做语义重叠检测。
- 【Rich Hickey】【质疑】：Hook 是事后观测不是事前拦截。用 runtime data 解决 design-time problem。PreToolUse 才能从源头控制，但不支持 skill install 事件。
- 【Kelsey Hightower】【反驳】：不需要拦截安装——声明式 manifest + reconciliation loop 持续收敛到期望状态，GitOps 思路。
- 【Marie Kondo】【补充】：manifest 需要人维护，决策环节不可自动化。Hook 的最大价值是把决策时刻仪式化地推到人面前。
- 【Dan Abramov】【综合】：完整管道四层——入口 (manifest)→运行 (PostToolUse)→决策 (仪式交互)→执行 (reconciliation)。还应加 LLM 上下文动态加载层。

*** 核心争议
Hook 在 skill 生命周期中的覆盖范围，以及自动化与人工决策的边界。

*** ASCII 框架图
#+begin_example
  安装时          运行时            审查时          清理时
  ────┬─────────────┬────────────────┬──────────────┬────
 Hook │  ❌ 不支持   │  ✅ PostToolUse│  ⚠️ 需人参与  │  ⚠️ 危险
 替代 │  Manifest    │  SQLite/JSON   │  仪式化提示   │  Reconcile
      │  声明约束    │  日志           │  交互         │  Loop
  自动化: 中(间接)      高(全自动)     低(人为核心)    中(半自动)

  盲区: ① 语义重叠检测 ② 质量评估 ③ 动态上下文加载
#+end_example

** 第三轮：Hook payload 真实结构与工程约束

*** 发言记录

- 【Brendan Gregg】【陈述】：逐字段审计——skill 字段名是 .tool_input.skill (非 skill_name)、tool_output 可能 >100KB 必须截断、无 timestamp 需自行补充。
- 【Rich Hickey】【质疑】：结构性局限——PostToolUse 是 fire-and-forget，无法控制。必须 Pre+Post 双 Hook 架构。PreToolUse 能返回 block + reason 反馈给 LLM。
- 【Kelsey Hightower】【反驳】：PreToolUse 拦截是 Week 4+ 的事。没有数据就写规则等于盲射，写错会锁死工作流。分阶段升级。
- 【Dan Abramov】【补充】：10 秒超时硬约束——采集脚本只做 IO 零计算，一切分析离线。更新了生产级脚本。
- 【Marie Kondo】【综合】：约束不是缺陷，约束是秩序的来源。Hook 的限制逼出简洁架构。

*** 核心争议
Payload 局限如何影响架构设计，以及约束与秩序的关系。

*** ASCII 框架图
#+begin_example
   PreToolUse (Week 4+):  可控制 (block/approve)
   PostToolUse (Day 1):   仅观测 (fire-and-forget)

   三个坑: ① .tool_input.skill ② output 巨大 ③ 无 timestamp
   硬约束: 10s 超时 → 采集/分析必须分离
#+end_example

** 第四轮：可运行代码交付

*** 发言记录

- 【Brendan Gregg】【陈述】：settings.json Hook 配置——一条入口指向采集脚本。Windows 环境注意路径展开和 jq 依赖。
- 【Kelsey Hightower】【补充】：20 行生产级 skill-tracker.sh——防御性取值、参数截断 200 字符、月度轮转、原子追加。
- 【Rich Hickey】【补充】：70 行 skill-audit.sh——频次排行、零调用检测、使用模式分析、膨胀率计算。故意不加自动删除。
- 【Marie Kondo】【补充】：20 行 skill-remind.sh——超过 14 天未审查输出整理提醒，仪式化触发。
- 【Dan Abramov】【综合】：4 文件交付清单 + 3 步落地指南 (Day 1/7/30) + 3 个已知缺口 (PreToolUse/名称匹配/语义重叠)。

*** 交付物清单
#+begin_src
~/.claude/
├── settings.json          ← 追加 PostToolUse hook 配置
├── hooks/
│   ├── skill-tracker.sh   ← Day 1: 采集 (20行)
│   ├── skill-audit.sh     ← Day 7: 审查 (70行)
│   └── skill-remind.sh    ← Day 30: 提醒 (20行)
└── skill-logs/            ← 自动创建
    ├── usage-YYYYMM.jsonl
    └── .last-audit
#+end_src

*** 落地时间线
- Day 1 (30分钟): 配置 Hook + 采集脚本 + 手动盘点
- Day 7: 运行审查脚本 + 首次清理
- Day 30: 启用提醒脚本 + 可选 manifest
- Day 90+: PreToolUse 拦截 + 语义分析 (可选)

* 知识网络（全局）

#+begin_example
  ┌─────────── 问题空间 ───────────────────────┐
  │  Skill 膨胀                                │
  │   ├── 治理缺位 ◄─── 无 GitOps 思维         │
  │   ├── 设计缺陷 ◄─── 累加式非组合式          │
  │   ├── 心理囤积 ◄─── 害怕失去的本能          │
  │   ├── 度量真空 ◄─── 不知道在用什么          │
  │   └── 上下文污染 ◄── System Prompt 过长     │
  ├─────────── 方案空间 ───────────────────────┤
  │  Hook 框架能力                              │
  │   ├── PostToolUse → 采集+聚合 (✅)          │
  │   ├── PreToolUse  → 拦截+引导 (✅)          │
  │   ├── 语义分析    → 重叠检测   (❌)         │
  │   └── 动态加载    → 上下文优化  (❌)         │
  │  约束 → 架构                                │
  │   ├── 10s 超时   → 采集/分析分离            │
  │   ├── Post 无控制 → Pre+Post 双层           │
  │   ├── 无时间戳    → 脚本自补                 │
  │   └── Output 巨大 → 只记 length             │
  ├─────────── 核心洞察 ───────────────────────┤
  │  ① 约束不是缺陷，约束是秩序的来源           │
  │  ② 自动化的最高境界是把决策推到人面前        │
  │  ③ 管理工具复杂性不能超过问题本身            │
  │  ④ 先有数据再有策略，先观测再拦截            │
  └────────────────────────────────────────────┘
#+end_example

* 开放问题

1. Skill 名称规范化：tool_input.skill 与 ~/.claude/skills/ 目录名的映射关系不明确
2. 语义重叠检测：如何用 LLM 批量比对 skill 描述以识别功能重复
3. 动态 Skill 加载：能否根据历史数据裁剪 system prompt 中的 skill 描述
4. 团队场景扩展：数据聚合、权限控制、统一策略的演进路径
5. Skill 生态治理：是否需要类似 npm deprecate 的废弃标记机制
