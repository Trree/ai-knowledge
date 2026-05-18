---
title: Claude Code Memory、Skills 与 Taste 圆桌讨论
created: 2026-04-27
type: conversation-source
tags: [claude-code, memory, skills, taste, agent, knowledge-management]
source: ChatGPT/Codex conversation
---

# Claude Code Memory、Skills 与 Taste 圆桌讨论

这是一份对话整理稿，用作原始材料归档。它记录了一次围绕 [[Claude Code]] 的 memory、skills、团队知识沉淀与 taste 的讨论。本文不是 wiki 洞察页，而是后续写作、提炼或复盘时可引用的 source。

## 讨论背景

最初的问题是：

> 先搜索关于 Claude Code 的 memory 和 skills 的相关定义和最新信息，然后讨论 memory 和 skills 的关系是什么？我们应该沉淀什么？团队里面如何沉淀 memory 和 skills？

讨论先从 Claude Code 官方语义出发：

- `CLAUDE.md` 是项目级、人写的持久上下文。
- auto memory 是 Claude Code 在使用中根据纠正、偏好和经验自动记录的记忆。
- skills 是带 `SKILL.md` 的能力包，可以被手动调用，也可以由模型根据任务自动触发。
- memory 更像默认上下文；skill 更像按需加载的能力包。

参考资料：

- Claude Code memory docs: <https://code.claude.com/docs/en/memory>
- Claude Code skills docs: <https://code.claude.com/docs/en/skills>
- Claude Code changelog: <https://code.claude.com/docs/en/changelog>
- Anthropic Agent Skills docs: <https://docs.claude.com/en/docs/agents-and-tools/agent-skills>

## 第一层结论：Memory 和 Skill 的基本关系

最初的核心结论是：

> Memory 存判断，skill 存流程。

或者更白话地说：

```text
memory = 这里的规矩和常识
skill  = 遇到某类任务时的做法
```

memory 回答的是：

```text
这里是什么？
什么是对的？
什么不能做？
哪些判断长期成立？
```

skill 回答的是：

```text
现在怎么做？
先做什么，再做什么？
做到什么算完成？
什么时候要停下来？
```

放到这个知识库里：

```text
memory:
- 这是知识库，不是软件工程仓库
- sources/ 只读
- wiki 页面是判断，不是摘要
- 宁少勿多
- 不是每个 source 都需要生成 wiki 页面
- 新增、删除、重命名 wiki 页面要更新 wiki/index.md

skills:
- ingest-new-source
- write-cross-source-insight
- lint-wiki-quality
- update-wiki-index
- sync-wiki-and-explain-result
```

一个简单判断标准：

```text
如果所有任务都默认要知道 -> memory
如果只有某类任务触发时才执行 -> skill
如果包含 3 步以上动作 -> skill
如果只是长期判断标准 -> memory
```

## 为什么现在大家更在乎 Skills

讨论中提出了一个更深的问题：

> 为什么现在人更在乎 skills，而 memory 没有人真正考虑研究？

得到的判断是：

**skill 是已经驯化过的 memory。**

skill 更容易被看见、使用、管理、审查和传播。

```text
memory = 原始经验 / 背景 / 偏好 / 纠错记录
skill  = 被整理成流程的经验
```

人们更关注 skills，有几个原因：

1. **skill 看得见，memory 看不见。**
   一个 skill 有名字、有触发条件、有文件、有步骤。memory 的价值常常是隐性的：它只是让 agent 少犯一次错。

2. **skill 容易验证，memory 难验证。**
   skill 可以检查是否按步骤完成。memory 要检查的是 agent 是否在正确时刻想起正确经验，这更难。

3. **skill 更适合团队协作。**
   skill 可以进 git、做 code review、版本化、回滚。auto memory 更像个人经验，碎片化且私密。

4. **memory 有治理成本。**
   团队必须回答：记什么？谁批准？什么时候忘？冲突怎么办？旧经验误导新任务怎么办？

5. **skill 更容易产品化。**
   它像插件、模板、app 或 npm 包，而 memory 更像组织内部的隐性经验。

因此，skills 热并不说明 memory 不重要。它说明 agent 工程化的第一阶段更容易从 skills 开始。

## 第二层结论：Memory、Skill 与组织学习

讨论进一步把二者放进组织学习流程里：

```text
一次纠错 / 一次经验
        |
        v
个人 memory
        |
        v
重复出现，团队确认
        |
        +--> 稳定判断：进入 CLAUDE.md / AGENTS.md
        |
        +--> 重复流程：做成 skill
        |
        +--> 局部规则：做 path rule
        |
        +--> 复杂案例：进入 wiki 或 review note
```

团队不应该直接把每次经验都写进公共 memory。更合理的是三层机制：

```text
个人捕获池 -> 团队候选池 -> 正式资产池
```

进入正式资产池之前要问：

```text
1. 这条经验是否反复出现？
2. 它是否跨成员、跨 agent 有效？
3. 它是否稳定，不依赖一次性上下文？
4. 它是否会改变下一次行动？
5. 漏掉它的代价是否足够高？
6. 是否有人负责维护和淘汰？
```

满足 `稳定 + 总是相关`，进 memory。

满足 `重复 + 可执行 + 有步骤`，做 skill。

满足 `局部 + 明确作用域`，做 path rule。

满足 `新鲜但未验证`，先留在个人 memory 或候选池。

满足 `高风险`，优先做成 skill 或 checklist。

## Team Memory 不该是什么

讨论中特别强调：team memory 不是“大家想到什么就往里塞”的公共便签。

不该进入 team memory 的内容：

```text
- 一次性 workaround
- 已经过期的工具命令
- 某个人的临时偏好
- 已经被 skill 固化的详细步骤
- 没有复用价值的事故细节
- 和新规则冲突的旧规则
```

该进入 team memory 的内容：

```text
- 项目身份和边界
- 不可违反的规则
- 稳定的团队判断
- 高频误解
- 术语和领域共识
```

对当前知识库来说，第一版 memory 可以非常短：

```markdown
# AI Knowledge Wiki

This repository is a knowledge wiki, not a software engineering repo.

Rules:
- Read WIKI.md before making structure or content decisions.
- sources/ is read-only unless the user explicitly asks otherwise.
- wiki pages are judgments, not summaries.
- Do not create one wiki page per source.
- Prefer updating an existing wiki page over creating a duplicate page.
- Create a new wiki page only when 3+ sources produce a real cross-source question or insight.
- Every wiki page needs frontmatter: title, created, tags.
- Use [[Page Name]] for wiki links.
- Cite sources as [[sources/file.md|Display Name]].
- When adding, deleting, or renaming wiki pages, update wiki/index.md.
```

如果加反例，只加少量防错例子：

```markdown
Examples:
- Bad: summarizing one source into a new wiki page.
- Good: using several sources to answer one real question with a clear core insight.
```

第一版 memory 的长度标准：

```text
10 条规则以内
2 个反例以内
不写步骤
不写长背景
不写临时偏好
不写工具命令细节
```

## Team Skill 应该长什么样

一个合格的 skill 不应该只是更长的 memory。它应该是一个可执行的行动单元。

统一骨架可以是：

```markdown
---
name: skill-name
description: Use when ...
owner: ...
scope: ...
last_reviewed: YYYY-MM-DD
---

# skill-name

## When to use
什么任务触发它。

## Do not use when
什么情况不要用它。

## Inputs
需要哪些输入。

## Steps
1. 做第一件事。
2. 做第二件事。
3. 在关键判断点停下来判断。
4. 产出结果。

## Quality bar
怎样才算做得好。

## Verification
如何检查结果。

## Escalation
什么时候必须问用户或交给 owner。

## Memory feedback
执行中如果发现稳定新规则，提交为候选 memory；
如果发现重复新流程，提交为候选 skill。
```

第一批 skill 可以是：

```text
1. ingest-new-source
触发：用户新增材料或要求整理 sources
核心判断：这份材料改变了哪个已有判断？
验收：要么更新旧 wiki，要么明确说明暂不写页

2. write-cross-source-insight
触发：需要从多个 source 写 wiki 页面
核心判断：这页回答的真实问题是什么？
验收：有 frontmatter、有核心洞察、有跨源证据、有未解问题

3. lint-wiki-quality
触发：用户要求检查 wiki 或写完页面后
核心判断：页面是在给判断，还是在复述资料？
验收：引用存在、index 一致、页面没有机械摘要化
```

一个 skill 是否合格，可以用五问验收：

```text
1. 什么时候触发清楚吗？
2. 什么情况下不该用清楚吗？
3. 步骤能实际执行吗？
4. 中间有没有关键判断点？
5. 最后怎么验证清楚吗？
```

## 第三层：真正有意思的是 Taste

讨论后来从 memory 和 skill 进入更深一层：

> AI agent 时代，团队真正要沉淀的不是 memory 或 skill，而是 taste。

三者关系可以写成：

```text
experience -> memory
craft      -> skill
judgment   -> taste
```

或者：

```text
memory: 记住我们踩过什么坑
skill: 复用我们会做什么事
taste: 继承我们认为什么是好
```

memory 和 skill 都是 taste 的下游：

```text
taste 决定你记什么
taste 决定你把什么流程化
taste 决定你删什么
taste 决定你不让 agent 做什么
```

对当前知识库来说，“wiki 是判断，不是摘要”不是普通规则，而是一种 taste。

它背后真正的判断是：

```text
不要堆资料。
不要伪装成知识管理。
不要用数量掩盖没有洞察。
一个页面必须回答一个真实问题。
```

这也是为什么这句话很重要：

```text
6 篇有判断的页面，优于 60 篇机械摘要。
```

这句话不是普通流程规则，而是一把刀。它告诉 agent：不要为了显得勤奋而生产垃圾。

## Taste 能不能被沉淀

讨论中形成的判断是：

**taste 不能直接打包，但可以通过例子、反例、拒绝理由和 review 问题被间接训练。**

taste 不适合只写成抽象原则。更有效的是：

```text
好例子：
这篇为什么值得留下？

坏例子：
这篇为什么只是摘要？

边界例子：
这篇差一点值得写，但为什么最后不写？

拒绝理由：
我们为什么没有创建这个页面？
我们为什么合并或删除了这个 skill？
```

训练 taste 的材料结构：

```text
principles  -> 定方向
examples    -> 校准边界
skills      -> 反复应用
review      -> 继续修正
```

一个实用比例是：

```text
10% 原则
20% 正例
20% 负例/边界例
40% skills/checklists
10% review notes/淘汰记录
```

这不是字数比例，而是注意力比例。

## 让 Agent 学会少做

讨论中一个重要转折是：

> skill 是把做法教给 agent。taste 是把不做什么教给 agent。

AI agent 的默认倾向是补全、解释、生成和结构化。没有 taste 的团队，会被 agent 的生产力淹没。

因此，团队必须训练 agent 学会：

```text
stop   -> 不创建
merge  -> 合并到旧页
delete -> 删除低价值内容
defer  -> 留作 source，不写 wiki
ask    -> 判断不足时问人
```

对当前知识库，训练 agent 少做的规则可以是：

```text
Do not create a wiki page if:
- it summarizes only one source
- it has no clear core insight
- it cannot name the real question it answers
- it duplicates an existing page
- it would still be obvious after a Google search
- deleting it would lose no judgment
```

写 skill 时也要反向设计：

```text
write-cross-source-insight:
- Start condition: 3+ sources create a real tension or new question
- Stop condition: no new judgment found
- Merge condition: existing page already answers it
- Ask condition: insight is plausible but boundary is unclear
- Output condition: page has one sharp core insight
```

## 要不要保存负资产

讨论进一步问：

> 如果团队真的开始沉淀 taste，要不要保存负资产？比如被删掉的页面、失败 prompt、错误 agent 行为。

结论是：

**负资产值得保存，但必须隔离、筛选、去个人化，并且服务于未来判断。**

负资产不是为了追责，而是为了训练判断。

应该保存的不是失败全文，而是这个四元组：

```text
尝试做什么？
看起来为什么合理？
为什么最后拒绝？
下次遇到同类情况怎么判断？
```

对这个知识库，可保存的负资产包括：

```text
1. 被拒绝的 wiki 页
只保留标题、核心问题、拒绝理由，不保留长全文。

2. 错误的 agent 行为
例如：把单篇 source 摘要成 wiki 页。

3. 失败 prompt
例如：诱导 agent 生成大量页面而不是判断是否值得写。

4. 边界案例
例如：有 2 个 source，但洞察不够强，所以不写页。

5. 被删除或合并的页面理由
例如：重复、无洞察、只是实体信息。
```

但这些负资产不应该进入正式 wiki 主线。更小的做法是放在相关 wiki 页的末尾：

```markdown
## 被拒绝的方向
- 没有单独写“X source 摘要页”：因为它只补充事实，没有产生新判断。
```

## Memory、Skill、Taste 的最终关系

整场讨论最后形成了一个三层结构：

```text
taste
  |
  v
memory
  |
  v
skill
```

更准确地说：

```text
taste 决定什么值得留下
memory 记住这种判断
skill 在任务中执行这种判断
review 用反馈继续校准 taste
```

memory 和 skill 不是对立关系。它们都是组织判断的不同形态：

```text
memory = 已经稳定下来的判断
skill  = 已经流程化的经验
taste  = 决定什么值得记住和流程化的选择力
```

团队真正要问的不是：

```text
我们有多少 memory？
我们有多少 skills？
```

而是：

```text
我们有没有能力告诉一个越来越强的执行者：什么不值得执行？
```

## 对当前知识库的落地建议

第一版不要搭大体系。更好的起点是：

```text
一个短 memory 文件
三个核心 skills
一个每周 triage 习惯
少量正例和负例
```

### 第一版 Memory

放入 `AGENTS.md` 或 `CLAUDE.md` 的应是短规则：

```text
- 这是 AI Knowledge Wiki，不是软件工程仓库。
- sources/ 只读，除非用户明确要求。
- wiki 页面是判断，不是摘要。
- 不是每个 source 都需要生成 wiki 页面。
- 优先更新旧页，不重复造页。
- 只有跨 3+ source 形成真实问题或新洞察，才值得写新 wiki 页。
- 新增、删除、重命名 wiki 页面时，同步更新 wiki/index.md。
```

### 第一批 Skills

优先做这三个：

```text
1. ingest-new-source
2. write-cross-source-insight
3. lint-wiki-quality
```

后续再做：

```text
4. update-wiki-index
5. sync-wiki-and-explain-result
```

### 第一批 Taste 材料

先保存少量正负例：

```text
Positive examples:
- 1-2 篇真正有判断的 wiki 页

Negative examples:
- 1-2 个看似完整但只是摘要的页面例子

Boundary examples:
- 1-2 个最后决定不写 wiki 页的 source 或主题
```

### 每周 Triage 问题

每周处理候选 memory / skill / taste 材料时，只问五个问题：

```text
1. 这条经验是否反复出现？
2. 它是判断、流程、局部规则，还是案例？
3. 它是否会改变下一次行动？
4. 它是否应该被默认加载？
5. 它什么时候应该被删除？
```

## 一句话总结

这场讨论最后压成一句话：

> Memory 让 agent 知道这里的规矩，skill 让 agent 学会这里的手艺，taste 让 agent 明白什么根本不值得做。

