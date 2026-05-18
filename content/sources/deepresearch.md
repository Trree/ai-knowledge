

● 竞品分析结果如下：

  核心结论：没有直接竞品

  没有任何现有产品或开源项目同时具备 GDA 的六个结构性特征（交付物层迭代、外部 oracle、强制切换、最差优先、一致性检查、显式停止规则）。

  最接近的几个

  1. Sakana AI 的 AI Scientist — 最接近的概念竞品
  - 有 generate → experiment → write → review 的循环
  - 但 review 步骤用的是 LLM 自评（GDA 明确定义这不是 oracle），不会基于 review 结果去重新搜证据

  2. Karpathy 的 autoresearch — 直接灵感来源
  - 单维度（val_bpb）、单领域（ML 训练），GDA 是多维度、多 oracle、跨领域的泛化

  3. CORAL（autoresearch 的多 agent 基础设施） — 互补关系
  - CORAL 管的是 agent 组织和工作空间，GDA 定义的是每个 agent 内部的改进纪律。可以组合使用

  市场空白
  
│     层级     │     现有产品做了               │ GDA 做的     │
├──────────────┼──────────┼──────────┤
│ 检索层迭代   │ OpenAI / Google / Perplexity / Anthropic 全都在做 │ 不是重点 │
├──────────────┼────────┼──────────┤
│ 交付物层迭代 │ 没人做                                            │ 核心位置     │
  

  所有 Deep Research 产品（OpenAI、Google、Perplexity、Anthropic）都在检索层迭代（多轮搜索、pivot、backtrack），但没有一个把最终交付物当成可版本化、可系统性改进的对象。

  STORM（斯坦福，28k star）、GPT Researcher（26k star）、DeerFlow（字节，63k star）都是单次管道或通用 agent 框架，没有 "写完之后围绕最弱问题持续补证据" 的协议。

  最大风险

  OpenAI / Google / Anthropic 任何一家在 Deep Research 后面加一个 "review and improve" 环节，就会成为直接竞争。但截至 2026 年 4
  月，没有一家这样做。协议层的复杂度（强制切换、证据仲裁、显式停止规则）不是随便加一层 polish 就能复制的。

  定位总结

  GDA 占据的是 "生成交付物" 和 "交付交付物" 之间的结构性空白。现有系统全部止步于生成（或检索层迭代）。这个位置目前没人站。