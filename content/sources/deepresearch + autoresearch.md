
● 两个概念，一个闭环：

  Deep Research

  各大厂商都有的产品能力（OpenAI Deep Research、Google Gemini Deep Research、Perplexity Deep Research）：

  - 输入一个研究问题
  - Agent 自主浏览几十到上百个网页，跟链接、评估来源
  - 输出一份有引用的综合研究报告
  - 耗时 5-30 分钟

  本质：从已有知识中提取和综合信息。只读不写。

  [[autoresearch]]

  就是你本目录里 Karpathy 的这个项目：

  - Agent 改代码 → 跑 5 分钟训练 → 看 val_bpb → keep/discard → 循环
  - 一夜跑 ~100 个实验
  - 人类睡觉，醒来看结果

  本质：通过实验生成新知识。只写不读（不查外部资料）。

  Deep Research + autoresearch = 完整的科研循环

           Deep Research              autoresearch
           (读 literature)            (跑 experiment)
                │                          │
                ▼                          ▼
    ┌─────────────────────┐    ┌─────────────────────┐
    │ 读论文、博客、文档    │    │ 写代码、跑实验、看指标 │
    │ 了解 state of art   │    │ 验证假设、发现新结果   │
    │ 发现 gap 和假设      │    │ keep or discard      │
    └──────────┬──────────┘    └──────────┬──────────┘
               │                          │
               └──────────┬───────────────┘
                          │
                          ▼
                ┌─────────────────┐
                │ 结果驱动新问题    │
                │ 新问题驱动新检索  │
                │ 新检索驱动新实验  │
                │       ...       │
                └─────────────────┘

  单独的 Deep Research 只能综合已知知识——不产生新知识。

  单独的 autoresearch 只能盲目试——可能重复发现已知结论，浪费实验预算。

  组合起来 就是人类科研者做的事：读文献 → 提假设 → 跑实验 → 看结果 → 读更多文献理解结果 → 新假设 → 新实验...
