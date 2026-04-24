# 下一代 Deep Research 系统应该长什么样？

截至 2026 年 4 月 21 日，我核对了 OpenAI、Google、Perplexity、Anthropic 的官方资料，以及几篇直接讨论研究代理结构和评测的原始论文。先说结论，今天的前沿产品已经不是纯单次搜索了。OpenAI 官方写的是多步研究，并且会根据拿到的信息 pivot 和 backtrack。Google 官方写的是先出研究计划，再多轮搜索和精炼。Perplexity 官方写的是 iteratively search、read、reason。Anthropic 官方写的是 multiple searches that build on each other。

所以，下一代 Deep Research 系统要解决的，已经不是「把单次搜索变成迭代搜索」。真正的问题是，怎么把「会搜」升级成「会围绕一个研究交付物持续补证据、处理矛盾、显式暴露缺口，并且在合适的时候停下来」。

## Current Products

### OpenAI Deep Research

OpenAI 在 2025 年 2 月 2 日发布 Deep Research，并在 2026 年 2 月 10 日更新说明。官方描述里最关键的不是「会搜很多网页」，而是它会做多步研究，并在过程中根据实时信息进行 pivot 和 backtrack。后续更新又加了 MCP / app connectors、trusted sites、运行中可打断追加指令、GitHub / SharePoint 等内部源支持。这说明 OpenAI 已经把研究系统往「多源信息代理」方向推，而不只是网页摘要器。

### Gemini Deep Research

Google 的官方描述是，用户提出问题后，Gemini 先生成一个多步研究计划，用户可以修改或批准，然后 Gemini 会多次执行搜索、阅读、分析和精炼。Google 后续的官方帮助文档又把 source scope 做得更明确了，用户可以决定是否启用 Google Search，也可以把 Gmail、Drive、NotebookLM、已上传文件纳入研究源，部分研究还会自动生成图表和可视化。

### Perplexity Research

Perplexity 的官方帮助文档写得很直接，Research 模式会执行 dozens of searches、阅读 hundreds of sources，然后 iteratively search、read documents、reason about next steps，最后生成可导出、可分享的报告。它的特点是速度快、外部网页覆盖广，但官方描述里重点仍然是搜索与综合，而不是交付物级别的质量闭环。

### Claude Research

Anthropic 在 2025 年 4 月 15 日介绍 Claude 的 Research 功能时，强调的是 conducting multiple searches that build on each other，并且可以把 Web、Google Workspace、Enterprise 内容库一起纳入。Claude 这一路线非常清楚，研究不再只是公网检索，而是公网与私有语料的联合作业。

小结一下，当前一线产品已经出现了三个共识，第一，研究流程已经 agent 化。第二，私有源和企业源会越来越重要。第三，最终交付物仍然主要是一份报告，而不是一个可持续改进的研究状态机。

## Recurring Patterns

把这些产品放在一起看，重复出现的模式非常明显。

第一层，是任务级流程已经基本收敛了，都是「问题输入 → 生成或隐含计划 → 多轮搜索 / 阅读 → 综合成报告」。差异主要在 source scope、交互方式和速度，不在主流程骨架。

第二层，是它们大多已经具备「检索层迭代」，但还没有真正做成「交付物层迭代」。也就是说，它们会反复搜、反复读、反复整理材料，但很少把最终报告拆成一组明确的缺口，然后逐个补齐。

第三层，是 citation 已经变成标配，但 citation 不等于结论站得住。DeepResearch Bench 这类评测之所以引入 effective citation count、citation accuracy 这些指标，本身就在说明，研究系统真正难的不是贴上链接，而是让 claim 和 evidence 逐条对应。

第四层，是产品层面越来越强调 source access，却还比较少强调 source conflict。Google、OpenAI、Claude 都在增强可接入的数据源范围，但官方描述里很少把「互相冲突的证据怎么处理」作为第一等结构来讲。

第五层，是这些系统的结束条件通常隐含在产品体验里，而不是显式暴露给用户。用户看到的是「报告生成完成」，而不是「哪些缺口已被补齐、哪些缺口无权威证据、为什么系统决定现在停止」。

这里有一个很关键的判断，这不是说今天的 Deep Research 不够聪明，而是说它们大多把智能用在「找到更多材料」，而不是「把研究交付物变成一个可验证、可收敛的对象」。

## Next-Gen Architecture

如果要做下一代 Deep Research，我觉得架构应该从「搜索代理」升级成「研究交付物编译器」。它至少要有下面七层。

### 1. Task Contract

先把任务合同写清楚，研究问题、目标读者、必须回答的子问题、可接受的证据类型、预算、停止条件，都要显式化。今天很多产品有计划，但缺的是 success condition。

### 2. Persistent Research State

核心不是 prompt，也不是 scratchpad，而是一份持久化研究状态。里面至少要有 claim ledger、evidence map、open questions、data gaps、conflicts、current target、revision log。没有这个状态，系统就很难真正「回头改」，因为它根本不知道上一轮没打动的是什么。

### 3. Baseline Pass

先生成一个可读的 baseline 版本，不追求完美，只追求让后续改进有落点。Deep Researcher 这篇论文之所以强调 cross-validation、self-reflection 和 honesty，也是因为研究任务里第一稿通常只能解决覆盖率，解决不了质量。

### 4. Deliverable-Level Improve Loop

这一步才是分水岭。不是继续泛泛地搜，而是先扫描当前交付物在 evidence、counterevidence、boundary、consistency、coverage 五个维度上的最弱点，然后只围绕当前最弱问题发起一次 focused oracle call。拿到新信息就并入，拿不到就切换目标。

### 5. Oracle Layer

Oracle 不该只是一种。下一代系统至少要把 web、papers、private docs、datasets、codebase、execution results 分开建模。不同 oracle 的信号强度不一样，调用成本不一样，可信度也不一样。Karpathy 的 autoresearch 给了一个很重要的启发，能交给外部世界打分的，就不要让 agent 自己打分。

### 6. Verifier / Critic Layer

这一层要和 generator 分开。它至少要检查五件事，claim-evidence 对齐、citation 准确性、全文一致性、边界条件、置信度校准。OpenAI 自己在官方限制里都承认，hallucinations、区分权威信息与传言、confidence calibration 仍然是难点，这说明 verifier 不能只是生成器的附属功能。

### 7. Stop Rule + Versioned Artifact

系统停下来的理由必须显式化。正确的停法不是「时间到了」或「字数够了」，而是「当前没有剩余的可行动缺口」或者「预算耗尽」。最终交付物也不该只是一篇静态报告，而应该带 unresolved gaps、evidence hierarchy、confidence notes、revision history。

如果把这七层压成一句话，下一代 Deep Research 不该只是一个更会搜索的代理，而应该是一个有任务合同、有外部裁判、有研究状态、有版本管理的研究操作系统。

## Missing Structural Pieces

基于上面的产品观察和论文，我认为现在最缺的结构件有六个。

### 1. Claim Graph

今天大部分产品输出的是一篇带引用的文章，不是一张 claim graph。没有 claim graph，你就很难在系统内部回答这些问题，这句话到底由哪几条证据支撑，哪条证据同时支撑了相反观点，哪条结论还没有一级来源。

### 2. Gap Registry

研究过程中最重要的，不只是找到什么，更是知道还没找到什么。现在多数产品会把缺口吞掉，或者把缺口隐藏在语言模糊性里。下一代系统需要一个显式的 gap registry，把「缺竞品数据」「无官方协议」「只有二手总结」这类问题单独挂出来，而且允许它们在后续轮次重新变成 target。

### 3. Conflict Resolver

现在的产品重 source expansion，轻 source arbitration。可是一旦研究变复杂，冲突不是例外，而是常态。下一代系统必须把 conflict resolver 做成第一等公民，至少要能做 source ranking、claim contradiction detection、evidence tiebreaking，而不是把矛盾留给读者自己消化。

### 4. Externalized Quality Gates

DeepResearch Bench II 的结果很刺眼，即便是最强模型，在他们的细粒度 rubrics 上满足的标准也不到一半。这件事说明，研究系统如果没有外部化的质量门，模型会很自然地停在「看起来像一份好报告」的阶段。quality gate 不能只靠主观观感，必须尽量落到 citation quality、coverage、consistency、evidence strength 这些外部维度上。

### 5. Honest Uncertainty Layer

真正的研究系统不应该假装自己什么都知道。它应该明确区分四种状态，已证实、部分支持、存在冲突、证据缺失。DeepResearcher 在论文里把 honesty 单独拎出来，不是修辞问题，而是结构问题。因为一旦系统不能诚实地表达不确定性，它就会用流畅文本掩盖信息缺口。

### 6. Re-openable Improvement Loop

这是我觉得最关键，也最容易被忽略的结构件。很多系统即使会多轮搜索，也还是默认第一次 miss 之后这个问题就结束了。真正好的研究系统应该允许 miss 之后先切到别的问题，等上下文和证据条件变了，再回来重新攻击原问题。也就是说，迭代不是为了多转几圈，而是为了让「暂时不可解」和「永久无解」被结构性地区分开。

如果只用一句话概括，今天 Deep Research 缺的不是更多搜索，而是一个面向交付物质量的外部反馈闭环。

## Conclusion

截至 2026 年 4 月 21 日，官方资料已经足够说明一件事，前沿 Deep Research 产品已经在「会不会多步搜索」这个问题上迈过去了。下一代系统的分水岭，不在搜索层，而在研究交付物层。

真正的下一代 Deep Research，应该长成这样，先有清晰任务合同，再有持久研究状态，先出 baseline，再围绕最弱缺口做 focused oracle calls，用独立 verifier 检查 claim-evidence 对齐、冲突、边界和置信度，最后带着 unresolved gaps 和 revision history 停在一个可解释的点上。

换句话说，下一代 Deep Research 不是更强的浏览器，而是更像一个研究操作系统。它要能搜，但更重要的是，它要知道自己还缺什么、哪里互相打架、什么时候该停、为什么停。

## Sources

- [OpenAI, Introducing deep research, published February 2, 2025 and updated February 10, 2026](https://openai.com/index/introducing-deep-research/)
- [Google, Gemini can make your life easier in more ways, including Deep Research](https://blog.google/products/gemini/google-gemini-deep-research/)
- [Google Help, Start a deep research report in Gemini Apps](https://support.google.com/gemini/answer/15719111)
- [Perplexity Help Center, What is Perplexity Research?](https://www.perplexity.ai/help-center/en/articles/10738684-what-is-deep-research)
- [Anthropic, Introducing Research for Claude](https://www.anthropic.com/news/research?hsLang=en)
- [DeepResearcher: Scaling Deep Research via Reinforcement Learning in Real-world Environments](https://arxiv.org/abs/2504.03160)
- [DeepResearch Bench: A Comprehensive Benchmark for Deep Research Agents](https://arxiv.org/abs/2506.11763)
- [DeepResearch Bench II: Tracing Language Model Performance to the Frontier of Knowledge Work](https://arxiv.org/abs/2601.08536)
- [Karpathy, autoresearch](https://github.com/karpathy/autoresearch)
