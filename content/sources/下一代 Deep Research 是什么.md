> 研究时间：2026-04-20 | 所属领域：AI 产品 / Agentic Research | 研究对象类型：概念

## 一句话定义

下一代 Deep Research 不该只是一个“会自己搜网页并吐出长报告”的按钮，而应该是一套**可验证、可中断、可延续、可执行**的研究工作台：它把问题定义、证据收集、冲突消解、结论形成和后续行动串成一个可追溯流程。

## 纵向分析：从搜索框到研究工作台

### 这条线不是从 2025 年才开始的

如果把 Deep Research 只看成 2025 年几个产品同时上线的新功能，会低估它。它其实是三条技术线在 2024 年底到 2026 年初突然汇流的结果。

第一条线是**搜索**。传统搜索解决的是“把相关页面找出来”，真正的研究工作还得靠人手动开几十个标签页、做笔记、比口径、写结论。信息获取和判断仍然是两段式劳动。

第二条线是**带引用的浏览式问答**。OpenAI 在 2021 年的 WebGPT 已经把一个关键模式讲清楚了：模型不是凭空回答，而是边浏览网页边抽取证据，再把答案和来源绑在一起。这一步把“能答”推进到“能给出处”，但仍然停留在问答而不是完整研究流程。[OpenAI, WebGPT](https://openai.com/index/webgpt/)

第三条线是**推理与行动交替**。ReAct 论文在 2022 年把 reasoning 和 acting 写成同一条链条：先想，再做，再根据环境反馈继续想。这个抽象对 Deep Research 很关键，因为研究不是一次检索，而是一个不断修正假设的过程。[ReAct, 2022](https://arxiv.org/abs/2210.03629)

到 2025 年，OpenAI 又用 BrowseComp 这类浏览基准把另一个事实摆出来了：网页浏览并不是已经被“做完”的问题。能打开网页，不等于能在噪音、高相似页面、冲突信息和长链依赖里完成研究级任务。[OpenAI, BrowseComp](https://openai.com/index/browsecomp/)

所以 Deep Research 这个品类的真正前史，不是“聊天机器人加搜索”，而是这三件事逐步接上了：**能找、能做、能带证据地讲出来**。

### 2024 年 12 月到 2025 年上半年：产品化元年

真正把这个能力包装成大众可感知产品的，第一个关键节点是 Google。Google 在 **2024 年 12 月 11 日**发布 Gemini Deep Research，把“先给出研究计划，再自动搜集资料，最后形成报告”这个交互范式公开化。[Google, 2024-12-11](https://blog.google/products/gemini/google-gemini-deep-research/)

OpenAI 在 **2025 年 2 月 2 日**发布 ChatGPT deep research。它的重要性不只在于跟进竞品，而在于把这个能力和更强的推理模型、引用、长时任务绑定在一起。更关键的是，OpenAI 在首发时就非常明确地写出了限制：它可能产生幻觉，可能错判信息权威性，可能在不确定时给出错误自信。这说明产品方很清楚，这个品类的难点已经从“能不能搜”转向“怎么判断搜到的东西是否可靠”。[OpenAI, 2025-02-02](https://openai.com/index/introducing-deep-research/)

Perplexity 在 **2025 年 2 月 14 日**推出 Deep Research，把这个能力进一步平民化。它强调的是速度和可及性，公开说大多数任务能在 2 到 4 分钟内完成，并且把结果导出成 PDF 或文档。[Perplexity, 2025-02-14](https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research)

xAI 则在 **2025 年 2 月**随 Grok 3 一起推出 DeepSearch。它的风格很鲜明：强调超大上下文、实时联网、以及把 X 平台和网页搜索并到同一个推理过程里。[xAI, Grok 3](https://x.ai/news/grok-3)

Anthropic 的路径不太一样。它没有一上来把“Deep Research”当作一个强消费功能打，而是先把 Claude 变成一个更像研究同事的东西。Anthropic 在 **2025 年 3 月 20 日**发布 Research，并接入 Google Workspace；在 **2025 年 5 月 1 日**又发布 Integrations，让 Claude 能通过远程 MCP 接到更多内部与外部系统。Research 一次可以跑 5 到 45 分钟，这已经不是“快速问答”，而是明确进入长时认知劳动范畴了。[Anthropic, Research](https://www.anthropic.com/news/research) [Anthropic, Integrations](https://www.anthropic.com/news/integrations)

如果把这几家放在同一时间线上看，会发现 2025 年上半年大家其实同时承认了一件事：**用户不再满足于一个答案，他们要一个研究过程。**

### 2025 年下半年到 2026 年：从“会写报告”转向“连接工作上下文”

这条线在 2025 年下半年到 2026 年初发生了质变。

OpenAI 的方向最清楚。它一方面在 **2025 年 7 月 17 日**推出 ChatGPT agent，把 operator 式动作能力和 deep research 式信息能力合流；另一方面又在 **2026 年 2 月 10 日**的 deep research FAQ 中把几个关键能力写得更明确：连接 GitHub、SharePoint、Dropbox、Box、Outlook、Gmail、Google Drive、HubSpot、Linear 等应用；支持任意 MCP 连接器；允许限定可信站点；支持实时进度、通知和中断；并且能导出为 PDF、Markdown 或 Word。这个信号很强：Deep Research 正在从“一个功能”变成“一个通用研究运行时”。[OpenAI, ChatGPT agent](https://openai.com/index/chatgpt-agent/) [OpenAI, Deep Research FAQ](https://help.openai.com/en/articles/10500283-deep-research-faq)

Google 的更新也很有代表性。Gemini Deep Research 从一开始的公开网页研究，逐步长出对 Gmail、Drive、用户文件、既有研究报告乃至 NotebookLM notebook 的利用能力。它的帮助文档还强调了一个很重要的交互：先生成研究计划，用户可以修改计划、指定偏好来源，再启动执行。这意味着 Google 的理解不是“替用户研究”，而是“让用户签一个研究合同，再替他跑”。这个模式很可能会长期存在，因为研究任务最大的失败点常常不是搜不到，而是一开始就研究错了问题。[Google, 2024-12-11](https://blog.google/products/gemini/google-gemini-deep-research/)

Perplexity 的升级则说明另一条路线：它在帮助中心把 Deep Research 和 Enhanced Deep Research 区分开来，加入澄清问题、研究中追问、进度可视化、可编辑的 stream 文件、文件上传、代码执行与应用生成。这背后的逻辑不是把报告做得更长，而是把研究过程拆成更多可控步骤。[Perplexity Help, Deep Research](https://www.perplexity.ai/help-center/en/articles/11165331-deep-research) [Perplexity Help, Enhanced Deep Research](https://www.perplexity.ai/help-center/en/articles/11575592-enhanced-deep-research)

Anthropic 则把重点放在“组织知识边界”上。Research 加 Integrations，本质上是在告诉企业用户：真正值钱的研究，不只是访问公开互联网，而是把公共信息和组织内部上下文、安全权限、工作系统接起来。[Anthropic, Integrations](https://www.anthropic.com/news/integrations)

如果说 2025 年上半年，行业的共识是“要把搜集和写作自动化”；那到 2026 年，新的共识已经变成：**只会搜网页并写报告的 Deep Research 还不够，它必须接入上下文、暴露过程、接受约束。**

### 这段历史真正暴露出的主矛盾

我的判断是，Deep Research 的核心瓶颈已经不是检索能力，而是**研究过程控制**。

第一，现有产品都在补“前置定义”。Google 强调计划可编辑，Perplexity 强调澄清问题，OpenAI 强调可信站点和连接器。这些都不是检索技术，而是研究合同。

第二，现有产品都在补“证据边界”。带引用已经成了标配，但带引用不等于真的可验证。OpenAI 自己在首发里承认会幻觉、会错判权威性，这说明“引用”还只是表面层，真正缺的是 claim-level 的证据绑定和冲突仲裁。

第三，现有产品都在补“工作流后半段”。导出为文档、生成表格、连接应用、回写工作系统，这些动作说明行业已经意识到：研究不是报告结束，而是决策、沟通、执行的起点。

所以历史给出的答案其实很尖锐：**Deep Research 的下一代，不会赢在更会搜，而会赢在更会管研究这件事。**

## 横向分析：竞争图谱

### 当前主要玩家在比什么

截至 **2026 年 4 月 20 日**，这个赛道至少有五个代表性方向：OpenAI、Google Gemini、Perplexity、Anthropic Claude、xAI Grok。它们都在做“长时研究”，但其实活成了五种不同的产品。

| 产品 | 当前最强能力 | 当前最明显短板 | 更像什么 |
|------|--------------|----------------|----------|
| ChatGPT deep research | 研究能力与通用 agent 合流，连接器、MCP、可信站点、可中断流程比较完整 | 仍然受幻觉、权威性判断和成本限制约束 | 通用研究运行时 |
| Gemini Deep Research | Google 搜索与 Google 生态耦合最深，计划式交互清晰 | 更依赖 Google 体系，研究过程透明度和可审计度仍有限 | 搜索原生研究助手 |
| Perplexity Deep Research | 快、便宜、普及度高，研究过程逐步产品化 | 深度判断稳定性不如头部推理系统，容易滑向“高效汇编” | 高速研究引擎 |
| Claude Research | 组织内知识接入、权限边界、长时协作感强 | 面向大众市场的“公开互联网研究心智”较弱 | 企业研究同事 |
| Grok DeepSearch | 实时性强，X 与网页结合紧，适合跟踪动态话题 | 研究流程控制、证据结构化和正式交付能力偏弱 | 实时情报搜索器 |

### OpenAI：最像“下一代”雏形，但还没到位

OpenAI 的优势不是单点功能，而是方向最完整。它已经把 deep research 和更广义的 agent 融到一起：能研究，能浏览，能连应用，能导出，能在运行过程中接受中断，还能限制可信站点。这一套能力组合出来的不是“更长的回答”，而是一个比较像研究操作系统的东西。[OpenAI, ChatGPT agent](https://openai.com/index/chatgpt-agent/) [OpenAI, Deep Research FAQ](https://help.openai.com/en/articles/10500283-deep-research-faq)

但 OpenAI 的短板也最有代表性，因为它碰到了品类最深的天花板。OpenAI 自己承认 deep research 仍会产生幻觉、会混淆权威信息和传言、会在不确定时过度自信。这说明即便在当前最强的通用推理栈上，研究任务也还没有被真正“解决”。问题不在模型不会写，而在模型还不够会判案。[OpenAI, 2025-02-02](https://openai.com/index/introducing-deep-research/)

### Gemini：最强的不是模型，而是入口和语境

Google 的壁垒不只是 Gemini 模型，而是它天然站在搜索入口、个人知识和办公上下文之间。Deep Research 一旦能同时读取 Google 搜索结果、Drive 文件、Gmail、历史研究、NotebookLM notebook，它就不再只是“搜公开网”，而是在调度一个用户已经积累多年的信息世界。

Gemini 的产品哲学也很清楚：先让用户看计划，再运行。这个动作看起来小，实际上很重要，因为研究任务的失败往往始于定义错误。Gemini 把“先签研究计划”做成默认交互，说明 Google 更看重把歧义消灭在执行前。[Google, 2024-12-11](https://blog.google/products/gemini/google-gemini-deep-research/)

它的短板是，Google 目前给人的感觉仍然更像“搜索增强的研究助手”，而不是一个完整的研究工作台。它很强，但强在 Google 的既有生态和分发能力上，还没有把研究过程本身抽象成一个足够通用、足够可审计的系统。

### Perplexity：把研究服务拉到大众可用区间

Perplexity 的价值，在于它证明了 Deep Research 不一定非得是高价、低频、庄严的大任务。它可以更快、更便宜、更轻量，而且仍然足够好用。大多数任务 2 到 4 分钟返回结果，这种速度让它更接近“每天都能开一次”的研究工具，而不是“只有关键问题才舍得用”的仪式型工具。[Perplexity, 2025-02-14](https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research)

更值得注意的是，它最近新增的 Enhanced Deep Research 并不是单纯堆模型，而是往过程控制上补：澄清问题、研究中追问、进度展示、可编辑 stream 文件、文件上传、代码执行、生成应用。这说明 Perplexity 也已经看见同一个方向：研究的价值不只在结果，而在过程可操控。[Perplexity Help, Enhanced Deep Research](https://www.perplexity.ai/help-center/en/articles/11575592-enhanced-deep-research)

它的问题在于，Perplexity 的品牌气质天然偏“高速答案机”。这让它在“快速扫面”和“真正裁决复杂问题”之间容易出现张力。它擅长很快给你一份像样的研究稿，但未必最擅长把一个争议问题做成证据级别很硬的判断。

### Claude：最懂企业为什么需要 deep research

Anthropic 的路线很值得重视，因为它并没有把 Deep Research 当成一个孤立功能，而是把它放在“安全地接触组织知识”这个更大命题里。Research 可以长时间运行，Integrations 让 Claude 能带着权限模型进入企业工作流。这个思路比“自动搜网页写报告”更接近真实组织对研究的需求。[Anthropic, Research](https://www.anthropic.com/news/research) [Anthropic, Integrations](https://www.anthropic.com/news/integrations)

Claude 的优势是可信、克制、像同事。短板是，它在消费级心智上没有像 OpenAI 或 Perplexity 那样把“Deep Research”塑造成一个强标签。所以从生态位看，Claude 更像企业研究协作者，而不是面向所有人的研究入口。

### Grok：把研究做成实时情报

xAI 的 Grok DeepSearch 代表的是另一种理解：研究不只是深，而是要快、要跟着实时流动的信息跑，尤其是 X 这种实时公共话语场。对动态事件、舆情、实时行业信号，它有天然优势。[xAI, Grok 3](https://x.ai/news/grok-3)

但这条路线也最容易滑向“强搜索、弱研究”。如果没有更强的证据结构化、计划控制和正式交付能力，DeepSearch 很容易成为一个很强的情报扫描器，却不一定能成为严肃研究工作台。

### 横向交汇后的判断

把五家放在一起看，会看到一个很清楚的竞争图谱。

OpenAI 在往“通用研究运行时”走。

Google 在把“搜索入口 + 个人知识”变成研究的护城河。

Perplexity 在把研究做成高频服务。

Anthropic 在把研究嵌进企业权限和工作系统。

xAI 在把研究推向实时情报。

这五条路线都成立，但它们共同暴露出同一个缺口：**还没有谁把“研究过程本身”做成真正第一公民。** 现在的大多数产品，仍然把“最终报告”当主产品，把计划、证据图、冲突分析、结论置信度、后续任务拆解当作附属品。

而我觉得，下一代的分水岭恰恰会出现在这些“附属品”上。

## 横纵交汇洞察

### 下一代 Deep Research 不该是什么

它不该只是更长的文章生成器。

也不该只是更会搜网页的 agent。

更不该只是给每句话后面挂一个引用链接，然后假装问题已经解决。

如果今天的 Deep Research 主要解决的是“把研究这件事自动跑起来”，那下一代应该解决的是“让研究过程本身值得信任，并且能接上真实工作”。

### 下一代 Deep Research 应该具备的七个特征

#### 1. 研究对象从“一次性报告”升级为“持续存在的研究对象”

现在的大多数产品完成一次任务后，结果就结束了。下一代不该这样。它应该把一次研究沉淀成一个可继续更新、可分叉、可回看的对象：有问题定义，有证据池，有争议点，有结论版本，有更新时间线。用户不是每次都从零开始，而是在一个活的研究对象上追加问题。

#### 2. 基本单位从“段落”升级为“证据图”

今天的产品主要输出 prose。下一代应该首先构建 evidence graph：每个关键判断背后有哪些证据、这些证据来自哪里、相互是否冲突、各自权重如何、哪些是直接证据、哪些只是推断。最后的报告只是这个证据图的一种视图，而不是全部。

#### 3. 输入从“一个 prompt”升级为“研究合同”

研究任务最怕的是目标含糊。下一代系统应该在执行前强制明确这些东西：研究问题、目标受众、决策标准、排除范围、可信来源偏好、交付格式、时间预算、成本预算。也就是说，不是“帮我研究一下”，而是先把“研究什么算完成”写成合同。

#### 4. 语料边界从“公开网页”升级为“可授权的多语料编排”

真正有价值的研究，往往同时依赖公开互联网、企业内部文档、用户自己的文件、结构化数据库、订阅信息源和历史研究对象。下一代 Deep Research 的核心能力不是单一检索，而是**在权限和审计约束下编排多语料**。MCP、Integrations、Google Workspace、可信站点都只是这个方向的早期形态。

#### 5. 过程必须可见、可中断、可重定向

现在很多系统仍然像黑箱：你提交任务，等几分钟，拿到一份成稿。下一代不应该这样。它应该把当前计划、已搜过的方向、被排除的分支、待验证的断点、成本消耗和剩余不确定性暴露出来，让用户能中途改目标、缩范围、加限制、批准进一步搜索。

#### 6. 验证要从“引用装饰”升级为“主动求反例”

下一代系统应该默认做几件今天很少被认真做的事：为关键结论主动找反证；对数字和表格做自动复算；对来源做权威性与新鲜度排序；对冲突证据做并列呈现而不是强行糊成一个结论；对不确定判断明确置信度和未解问题。研究不是把支持自己的材料堆起来，而是让反例也进场。

#### 7. 输出要能直接接到执行层

一份研究如果最后只能导出成 PDF，它的价值其实被砍掉一半。下一代系统应该能把结论变成下游工件：决策 memo、演示文稿、财务表格、竞品数据库、待办清单、监控 watchlist、甚至进一步交给执行型 agent 去落地。研究不再是终点，而是生产系统的上游。

### 我对产品形态的判断

我的判断是，下一代 Deep Research 最终不会以一个孤立按钮存在，而会变成大模型工作台里的一个基础运行模式。

它上接聊天、文件、知识库、搜索、数据库和应用。

它中间维护计划、证据图、验证器和权限边界。

它下接文档、表格、幻灯片、任务系统和执行 agent。

也就是说，未来真正强的不是“deep research feature”，而是“research-native agent platform”。

### 三个剧本

#### 最可能的剧本

Deep Research 会和通用 agent 合流，成为大模型工作台里的标准模式。公开网页研究、私有数据接入、应用连接、导出交付、轻量执行连成一条链。产品之间的差异主要体现在证据控制、权限边界和工作流集成上，而不是单次报告长度。

#### 最危险的剧本

行业把注意力过度放在 benchmark、报告篇幅和表面引用上，结果 Deep Research 变成一种“看上去很认真”的自动写作。它能生成越来越像样的研究文风，却没有真正解决证据冲突、幻觉校准、结论审计和反例搜索。这样做出来的系统很容易变成高层包装、低层脆弱的研究幻觉机。

#### 最乐观的剧本

Deep Research 成为知识工作的通用基础设施。每个组织都有一层研究对象库，外部信息和内部知识在权限控制下持续汇流，重要问题的证据图可以版本化、复查和复用。那时用户买的就不是“会不会写报告”，而是“能不能稳定地产生可追责的判断”。

## 信息来源

- OpenAI. “Introducing deep research.” https://openai.com/index/introducing-deep-research/ （访问时间：2026-04-20）
- OpenAI Help Center. “Deep Research FAQ.” https://help.openai.com/en/articles/10500283-deep-research-faq （访问时间：2026-04-20）
- OpenAI. “ChatGPT agent.” https://openai.com/index/chatgpt-agent/ （访问时间：2026-04-20）
- OpenAI. “WebGPT.” https://openai.com/index/webgpt/ （访问时间：2026-04-20）
- OpenAI. “BrowseComp: A Simple Yet Challenging Benchmark for Browsing Agents.” https://openai.com/index/browsecomp/ （访问时间：2026-04-20）
- Yao, Shunyu et al. “ReAct: Synergizing Reasoning and Acting in Language Models.” https://arxiv.org/abs/2210.03629 （访问时间：2026-04-20）
- Google. “Gemini Deep Research.” https://blog.google/products/gemini/google-gemini-deep-research/ （访问时间：2026-04-20）
- Perplexity. “Introducing Perplexity Deep Research.” https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research （访问时间：2026-04-20）
- Perplexity Help Center. “Deep Research.” https://www.perplexity.ai/help-center/en/articles/11165331-deep-research （访问时间：2026-04-20）
- Perplexity Help Center. “Enhanced Deep Research.” https://www.perplexity.ai/help-center/en/articles/11575592-enhanced-deep-research （访问时间：2026-04-20）
- Anthropic. “Research.” https://www.anthropic.com/news/research （访问时间：2026-04-20）
- Anthropic. “Integrations.” https://www.anthropic.com/news/integrations （访问时间：2026-04-20）
- xAI. “Grok 3.” https://x.ai/news/grok-3 （访问时间：2026-04-20）
- DeepResearcher. “Scaling Deep Research via Reinforcement Learning in Real-world Environments.” https://arxiv.org/abs/2504.03160 （访问时间：2026-04-20）
- WebThinker. “Empowering Large Reasoning Models with Deep Research Capability.” https://arxiv.org/abs/2504.21776 （访问时间：2026-04-20）

## 方法论说明

本文采用横纵分析法：纵向追踪 Deep Research 作为一个产品概念从方法萌芽到品类成形的演化，横向比较当前主要实现路线，再在两条轴线交叉处给出对下一代产品形态的判断。
