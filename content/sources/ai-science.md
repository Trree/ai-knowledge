
这个项目的核心思想，不是“让 LLM 写论文”，而是把一类研究工作压缩成一个可执行闭环：

  先把研究问题装进一个模板，再让 LLM 只在模板允许的空间里提想法、改代码、跑实验，最后由真实执行结果而不是模型自述来决定下一步。README.md:286 launch_scientist.py:343 ai_scientist/
  perform_experiments.py:116

  更本质一点，它做了三件事：

  - 把“科研”拆成标准接口：idea -> experiment -> metrics -> plots -> writeup -> review。ai_scientist/generate_ideas.py:76 ai_scientist/perform_writeup.py:401 ai_scientist/perform_review.py:126
  - 把领域知识放进模板里，而不是硬编码在主流程里。模板最核心的是 experiment.py、plot.py、prompt.json、seed_ideas.json、latex/template.tex。README.md:286
  - 把 LLM 从“裁判”降级为“提案人 + 实施者”。真正的裁判是运行结果和结构化指标，比如 final_info.json。ai_scientist/perform_experiments.py:62

  你如果想把这种思想用到别的项目，最有用的不是照搬代码，而是照搬这套抽象：

  1. 先定义可执行基座
  找出项目里那份“真正决定结果”的文件或模块。
  在这个仓库里是模板里的 experiment.py；在别的项目里可能是：

  - 一个训练脚本
  - 一个推理 pipeline
  - 一个仿真器
  - 一个 benchmark harness
  - 一个业务规则引擎

  没有这个基座，agent 只能空谈。

  2. 再定义动作边界
  明确 agent 能改什么，不能改什么。
  边界越清晰，系统越稳定。autoresearch 那种只改一个 train.py 是极简做法；AI Scientist 是“改模板目录里的少数核心文件”。

  3. 定义统一结果协议
  你必须有一个稳定的结构化输出，类似这里的 final_info.json。
  否则 agent 没法自动比较“这次更好还是更差”。

  最小协议通常需要：

  - status
  - metrics
  - artifacts
  - notes

  4. 定义评价函数
  研究系统能自动循环，靠的不是 prompt，而是 evaluator。
  你要明确：

  - 什么指标最重要
  - 是越大越好还是越小越好
  - 多指标怎么权衡
  - crash / timeout 怎么算

  5. 再加 idea 层
  只有当执行层稳定以后，才值得加“想法生成”。
  否则系统会产生很多 proposal，但没有可靠验证。

  6. 最后再加 writeup / review
  写作和审查应该是执行层的下游，不应该反过来主导系统。

  如果把它迁移到别的项目，我建议你按这个最小骨架来做：

  template/
    task.md              # 问题定义、约束、成功标准
    experiment.py        # 真正执行的主程序
    evaluator.py         # 把原始输出转成指标
    plot.py              # 可选，可视化
    seed_ideas.json      # 可选，初始提案
    result_schema.json   # 结果格式定义

  主循环就是：

  load template
  -> generate/change proposal
  -> modify executable code
  -> run
  -> parse metrics
  -> compare to baseline
  -> keep / discard
  -> repeat

  最适合用这套思想的项目有三类：

  - 能稳定自动运行的项目
  - 有明确指标的项目
  - 改动空间有限但非零的项目

  比如：

  - 模型训练与调参
  - 检索/排序系统优化
  - 编译器/推理引擎优化
  - 仿真与控制策略搜索
  - 数据处理 pipeline 优化

  最不适合的是：

  - evaluator 很主观
  - 结果周期太长
  - 无法把成功标准结构化
  - 改动边界完全不清楚

  一句话总结：

  这项目的核心思想，是把开放式研究问题收缩成“模板约束下的可执行搜索”。
  你要迁移它，不是复制“自动写论文”，而是先复制这三个东西：
  可改动的执行基座、稳定的结果协议、真实反馈驱动的闭环。

  如果你愿意，我可以下一步直接按你的某个具体项目，帮你反推一版适合它的 template 结构。
