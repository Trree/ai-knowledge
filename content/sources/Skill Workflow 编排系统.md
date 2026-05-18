
## ⏱️ 背景

### ① 相关工作背景情况

本案例围绕 **Skill Workflow 编排系统** 展开。它的目标是把多个 AI skill 组合成可复用的 workflow，让开发、评审、复盘、规则优化等重复任务从“每次临时拼接”变成“可运行、可追溯、可持续优化”的流程。

当前涉及的 skill 来源包括：

1. [karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)：编码前思考、简洁优先、精准修改、目标驱动执行。
2. [superpowers](https://github.com/obra/superpowers)：头脑风暴、实现计划、执行计划、并行、测试驱动开发。
3. 百度内部 skill：[内部代码资产复用](https://console.cloud.baidu-int.com/onetool/skills/2909)。
4. 团队内部 skill：金额流转代码审查。

### ② 传统方式痛点

- **流程依赖个人记忆**：同一个内部 skill 既要在开发流程中使用，又要在 review 环节中重复使用，容易到处复制、到处漏改。
- **开源 skill 难以局部改造**：开源 skill 好用，但部分规则不完全符合团队习惯；如果重写整个 skill，成本太高。
- **优化停留在单次输出**：执行完之后通常只改这一次的结果，没有把经验写回流程，下次还会重复遇到同类问题。
- **A/B 对比不稳定**：如果每次输入不同，很难判断结果差异来自 skill 本身，还是来自输入变化。

### ③ AI 介入后的预期和实际效果

预期效果是：把高频、稳定、重复的 AI 使用流程显式化，让 AI 不只是生成单次结果，而是参与到 **workflow 的创建、运行、对比和迭代** 中。

实际效果是：Skill Workflow 编排系统已经能支持 DAG 依赖编排、状态持久化、断点恢复、步骤替换、A/B 对比和人工 gate 控制。它最适合解决的不是单个问题的回答质量，而是整类重复性复杂任务的执行稳定性。

### AI 使用前后对比

> 说明：下表保留了可复盘的提效维度。具体分钟数需要在真实业务流中补充运行记录后再填写，避免凭印象编造数据。

| 环节            | 之前（原工作流）                                                    | 现在（使用 AI 后）                                                               | 效率提升        | 质量/效果提升                |
| ------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------- | ----------- | ---------------------- |
| 开发流程启动        | 每次手工选择 karpathy、superpowers、内部 skill，并重新组织提示词；时间投入：___ 分钟/次 | 通过 `/workflow:create` 创建流程，通过 `/workflow:run` 运行固定 workflow；时间投入：___ 分钟/次 | 减少重复组装流程的时间 | 流程边界更稳定，不依赖临时记忆        |
| 内部 skill 复用   | 同一个 skill 在开发、review 等多个环节重复粘贴或重复描述                         | 把 skill 作为 workflow 中的可复用节点，在多套流程中复用                                      | 减少重复维护成本    | 同一规则在不同环节表现一致          |
| 开源 skill 局部改造 | 不满意开源 skill 的部分规则时，要么忍受，要么重写                                | 将开源 skill 作为流程节点，只改它的下游规则或输出约束                                            | 降低二次改造成本    | 保留开源 skill 优点，同时贴合团队习惯 |
| 单步骤优化         | 每次凭主观感受判断哪个 skill 更好                                        | 在同一输入下使用 `/workflow:compare` 替换单个 step 做 A/B 对比                           | 缩短试错路径      | 对比更可复验，减少主观偏差          |
| 失败复盘          | 出问题后凭感觉修改本次输出                                               | 保留状态和中间产物，失败后复盘运行记录，再改 workflow                                           | 减少重复排查      | 问题定位更清楚，经验能沉淀到下一轮      |
| 其他            | 高频任务容易散落在个人经验里                                              | 高频任务沉淀为团队 SOP                                                             | 降低交接和协作成本   | 流程可审查、可演进              |

## 🛠️ 工具组合

| AI 工具/组件            | 用途                                      | 选择理由                           |
| ------------------- | --------------------------------------- | ------------------------------ |
| Skill Workflow 编排系统 | 将多个 skill 编排成可复用 workflow，支持运行、恢复、对比和迭代 | 适合把重复的 AI 使用流程工程化，而不是每次临时组织提示词 |
| karpathy-skills     | 编码前思考、简洁优先、精准修改、目标驱动执行                  | 适合作为开发前和实现过程中的基础工程纪律           |
| superpowers         | 头脑风暴、计划、执行、并行、TDD 等开发流程                 | 流程完整，适合快速组合成标准开发 workflow      |
| 百度内部 skill          | 内部代码资产复用                                | 能把内部知识和团队资产接入标准流程              |
| 团队内部金额流转代码审查 skill  | 对涉及金额流转的代码进行专项 review                   | 属于高风险、高复用、适合固化的审查环节            |
| Claude / ducc       | 执行 workflow 命令和 AI 协作任务                 | 已经是当前开发协作入口，适合承载 workflow 运行   |

## 🎯 适用场景

| 场景 | 优势 | 注意点 |
|---|---|---|
| 快速编排开源和内部 SKILLS | 快速将开源优秀 skill 和内部 skill 固化为统一流程 | 示例 workflow 需要替换为真实开发 skill |
| 单步骤 A/B 实验 | 可以在同一输入下替换 skill 做对比，快速找到更优方案 | 需要积累足够稳定的对比样本 |
| 复用同一个 skill | 多套流程中复用同一个 skill，不用重复编写 | 要保证 skill 边界足够清楚 |
| 团队 SOP 沉淀 | 流程定义可复用、可审查、可演进 | 前期抽象流程需要一定成本 |
| 高度开放式探索任务 | 能提供基础框架 | 不适合一开始就强约束，过早编排会限制探索空间 |

## 📌 使用案例：快速编排开源 SKILLS

### 案例目标

把开源和内部 skill 编排成一个可复用的开发 workflow，让开发流程中的思考、计划、执行、评审、专项审查和规则迭代变成一套可运行流程。

### ① 案例最终成果效果

| 环节 | AI 产出成果 |
|---|---|
| 工具整体介绍 | ![](https://rte.weiyun.baidu.com/wiki/attach/image/api/imageDownloadAddress?attachId=b52c9c3d1f0545deac295ef1cdeffae2&docGuid=4dqCIGJpJ7P_Uh) |
| Workflow 案例总览 | ![](https://rte.weiyun.baidu.com/wiki/attach/image/api/imageDownloadAddress?attachId=8e64ae86d00a47fc9f4cf72b5106977e&docGuid=4dqCIGJpJ7P_Uh) |
| 创建 workflow | ![](https://rte.weiyun.baidu.com/wiki/attach/image/api/imageDownloadAddress?attachId=cecb32fbe5f54150a24f9413d35deedc&docGuid=4dqCIGJpJ7P_Uh) |
| 创建流程文件 | ![](https://rte.weiyun.baidu.com/wiki/attach/image/api/imageDownloadAddress?attachId=3f49a4ec5629496c96bb5a5126ba908f&docGuid=4dqCIGJpJ7P_Uh) |
| 运行 workflow | ![](https://rte.weiyun.baidu.com/wiki/attach/image/api/imageDownloadAddress?attachId=e8c16c960e3b4a66b5535521349520e6&docGuid=4dqCIGJpJ7P_Uh) |
| 改进规则 | ![](https://rte.weiyun.baidu.com/wiki/attach/image/api/imageDownloadAddress?attachId=1d745aa177304a538c1cfb34f6444c78&docGuid=4dqCIGJpJ7P_Uh) |

### ② 使用案例完整工作流程

| 流程 | 输入/输出详情 |
|---|---|
| 1. 明确 workflow 名称和描述 | 输入：要固化的任务名称、使用场景、需要组合的 skills。输出：workflow 的基本定义。命令：`/workflow:create` |
| 2. 选择组合的 skills | 输入：karpathy-skills、superpowers、内部代码资产复用、金额流转代码审查等 skill。输出：按任务阶段排列的 workflow 节点。 |
| 3. 创建流程文件 | 输入：workflow 名称、步骤依赖、每步输入输出约束。输出：可运行的 workflow 文件。 |
| 4. 运行 workflow | 输入：具体开发任务或功能需求。输出：按 workflow 执行后的阶段性产物。命令：`/workflow:run fullstack-feature-dev` |
| 5. 查看详情 | 输入：workflow 名称。输出：workflow 总览或指定 workflow 详情。命令：`/workflow:list backend-dev` |
| 6. 替换和对比单步骤 | 输入：指定 workflow、指定 step、替代 skill。输出：同一输入下的结果对比。命令：`/workflow:compare backend-dev --step review --with alt-review` |
| 7. A/B 对比 | 输入：variant-a 和 variant-b。输出：两个方案在同一上下文中的对比结果。命令：`/workflow:compare fullstack-feature-dev --step review --variant-a review --variant-b alt-review` |
| 8. 改进规则 | 输入：运行结果、失败记录、人工反馈。输出：更新后的 workflow 或 step 规则。重点是让 AI 改进规则，而不是每次只改输出。 |

### 快速开始

```bash
git clone https://git.yy.com/wufeilong/weavespec

cd weavespec

claude
# 或者
ducc

/workflow:list
/workflow:create
/workflow:run backend-dev 功能
/workflow:list backend-dev
/workflow:compare backend-dev --step review --with alt-review
/workflow:compare fullstack-feature-dev --step review --variant-a review --variant-b alt-review
```

## 🔁 案例可迁移场景

| 场景 | 优势 | 注意点 |
|---|---|---|
| 代码开发流程 | 能把需求理解、方案设计、实现、测试、review 串成稳定流程 | 不要把所有任务都塞进一个巨大 workflow |
| 代码审查流程 | 能复用专项审查 skill，例如金额流转、权限、异常处理等 | 审查标准必须清楚，不能只写“帮我看看” |
| 文档生成流程 | 能把素材整理、结构化、审核、发布前检查串起来 | 对外发布前必须保留人工 gate |
| 研究分析流程 | 能把检索、证据整理、报告生成、反思迭代变成流程 | 开放式探索初期不要过早固定流程 |
| 团队 SOP 固化 | 能把个人经验沉淀为可复用、可交接的工作流 | 只适合高频稳定任务，低频任务先人工摸清楚 |

## ✅ 心得与经验

### 有效做法

1. **先把高频任务抽象成固定步骤**  
   先找重复任务，不要一上来编排所有事；明确每一步输入、输出和完成标准。

2. **让 skill 尽量原子化**  
   一个 skill 只解决一类问题，不要把多个不相关动作硬塞进一个 skill。

3. **保留运行记录**  
   每次运行都保存状态和中间产物；失败时优先复盘记录，而不是凭感觉改。

4. **把人工 gate 放在关键点**  
   方向分叉前确认；对外发布、提交、推送这类不可逆动作前确认。

5. **用 A/B compare 优化单步骤**  
   在同一输入下替换一个 skill 做对比；优化应该基于结果，而不是主观偏好。

6. **改 workflow，不要只改单次输出**  
   单次手修只能救这一轮，调整 workflow 才能让后续所有运行受益。

### 注意事项

1. **不要在每个步骤都插人工检查点**  
   这会严重打断上下文，也会让人从设计者退化成点按钮的审核员。

2. **不要把 workflow 当成单个 prompt 的放大版**  
   如果步骤边界不清晰，流程会很快失控。编排不是把 prompt 叠起来，而是设计协作关系。

3. **不要每次问题都直接手工改结果**  
   看起来快，长期最慢；相同问题下次还会重复出现。

4. **不要用不同输入做 A/B 对比**  
   输入不同会让对比结论失真，无法判断差异来自 skill 还是输入。

5. **不要在任务还不稳定时过度工程化**  
   低频任务先人工摸清楚流程，高频稳定后再沉淀为 workflow。

### 可复用流程

1. 找到高频、重复、边界相对清楚的任务。
2. 拆成多个原子步骤，明确每一步输入、输出和完成标准。
3. 为每一步匹配已有 skill，缺失的再补内部 skill。
4. 创建 workflow，并保留状态和中间产物。
5. 在关键分叉或不可逆动作前设置人工 gate。
6. 用真实运行记录复盘失败原因。
7. 通过 A/B compare 优化单步骤。
8. 把改进写回 workflow，而不是只修单次结果。

## 结论

Skill Workflow 编排系统的核心价值，不是让某一次 AI 输出更好，而是把重复性复杂任务变成 **可运行、可追溯、可验证、可持续优化的工程流程**。

从团队角度看，它不是单纯的 AI 工具集成，而是在尝试把人和 AI 的协作关系沉淀成一套可复用系统。继续推进时，最值得优先落地的方向有两个：

- 选一个高频、标准化程度高的业务流先跑通。
- 围绕真实运行记录建立优化闭环，而不是停留在定义层。

## 代码地址

[weavespec](https://git.yy.com/wufeilong/weavespec)
