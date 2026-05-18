---
title: "There's a New PM Skill. It's Called Taste at Speed"
source: "https://www.news.aakashg.com/p/taste-at-speed"
author:
  - "[[Aakash Gupta]]"
published: 2026-03-14
created: 2026-05-08
description: "How the Claude Code team evaluates hundreds of prototypes before shipping. The 5 Lenses framework, a real-world teardown, and 4 downloadable templates."
tags:
  - "clippings"
---
### Inside Boris Cherny's prototype-first workflow, the 5 Lenses evaluation framework, and 4 downloadable tools.包含 Boris Cherny 的首创型工作流程、5 个透镜评估框架和 4 个可下载工具。

Boris Cherny’s first pull request at Anthropic got rejected.  
Boris Cherny 在 Anthropic 的第一个 pull request 被拒绝了。

Not because the code was bad. Because *he wrote it by hand.*  
不是因为他代码写得不好。而是因为他手写的。

His ramp buddy told him to use Clyde, the janky internal predecessor to [Claude Code](https://www.news.aakashg.com/p/claude-code-v21-is-insane-ai-update). Boris spent half a day figuring out the tool. Then it one-shotted a working PR.  
他的导师告诉他要用 Clyde，一个蹩脚的内部前身程序，来代替 Claude Code。Boris 花了半天时间弄懂这个工具。然后他一次性提交了一个工作的 PR。

That was September 2024.那是 2024 年 9 月。

By December, Opus 4.5 wrote 100% of his code. He didn’t edit a single line manually. He uninstalled his IDE.  
到 12 月，Opus 4.5 写完了 100%的代码。他没有手动编辑一行代码。他卸载了他的 IDE。

Today Boris ships 20-30 PRs a day running 5 parallel Claude instances. His team built [Cowork](https://www.news.aakashg.com/p/guide-claude-cowork), a full product for non-engineers, in about 10 days. They [prototyped](https://www.news.aakashg.com/p/ai-prototyping-tutorial) agent teams for months, trying *hundreds* of versions before shipping.  
今天 Boris 每天提交 20-30 个 PR，运行 5 个并行的 Claude 实例。他的团队在 10 天内为非工程师构建了 Cowork，一个完整的产品。他们为代理团队原型设计了好几个月，尝试了数百个版本后才发布。

No [PRDs](https://www.news.aakashg.com/p/ai-prd). No [Figma](https://www.news.aakashg.com/p/how-figma-grows).没有 PRDs。没有 Figma。

Meanwhile, most PM teams are still spending 2 weeks getting a [spec](https://www.news.aakashg.com/p/product-requirements-documents-prds) through review for a feature that could be prototyped, tested, and killed in an afternoon.  
与此同时，大多数 PM 团队仍然花费两周时间让一个规范通过审查，而这个功能可以在一个下午内原型设计、测试和淘汰。

The gap between these two realities is compounding every week.  
这两者之间的差距每周都在加剧。

And the skill that separates PMs on either side of that gap is what I’m calling **taste at speed**: the ability to evaluate working software fast, kill most of it, and ship the survivors.  
而将两边区分开来的技能，就是我所说的快速品味：快速评估工作软件，淘汰大部分，并发布剩余部分。

I’ve been thinking about this since my [LinkedIn post](https://www.linkedin.com/feed/update/urn:li:activity:7435373356281131010/) on Boris went viral (215K+ impressions):  
自从我在领英上发布关于 Boris 的文章后（浏览量超过 215K），我就一直在思考这件事：

![](https://substackcdn.com/image/fetch/$s_!d2JQ!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fbc7ce72d-9904-4f70-b9d1-60ae9aad8b95_1280x1600.png)

The response told me something. This topic hit a nerve.  
回复告诉我了一些事情。这个话题触动了一些人的神经。

PMs know the ground is shifting. They just don’t know what to do about it.  
PM 们知道情况正在变化。他们只是不知道该如何应对。

*Today, I’m going deep.今天，我要深入探讨。*

---

## Today’s Post 今天的文章

*I’ve written **the web’s first guide to Taste at Speed**:  
我写了互联网上第一份《快速品味指南》。*

![](https://substackcdn.com/image/fetch/$s_!Im5L!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb1a47952-23fd-4def-8a30-d6c9ca8d80a9_1200x800.png)

1. Why Taste at Speed Is the Defining PM Skill  
	为什么快速品味是定义产品经理的核心技能
2. How the Best Teams Actually Ship Now  
	如何顶尖团队现在真正交付成果
3. The Taste at Speed Framework  
	速度品味框架
4. How to Build This Skill  
	如何构建这项技能
5. Where the PRD Fits Now  
	PRD 现在放在哪里
6. Real-World Teardown 实际拆解

*Plus **4 downloadable tools**: a Prototype Evaluation Scorecard, a Skill-Building Roadmap, a Prototype-First PRD Template, and a Divergent Prototyping Prompt Template.  
此外，还有 4 个可下载的工具：原型评估评分卡、技能建设路线图、以原型为先的产品需求文档模板以及发散式原型设计提示模板。*

---

## 1\. Why Taste at Speed Is the Defining PM Skill1. 为什么快速品味是定义产品经理的核心技能

Boris [shared an analogy](https://www.youtube.com/watch?v=PQU9o_5rHC4&t=1s) recently that I haven’t been able to stop thinking about.  
博里斯最近分享了一个类比，让我一直思考不断。

In the 1400s, less than 1% of Europe’s population was literate. There was a class of scribes who spent years in training. They were employed by kings and lords who were themselves often illiterate.  
在 1400 年代，欧洲人口中识字率不到 1%。有一个抄写员阶层，他们花费数年进行培训。他们受雇于国王和领主，而这些国王和领主自己往往也是文盲。

Then the printing press came along. The cost of printed material dropped 100x over the next 30-50 years. The quantity went up 10,000x over the next century.  
然后印刷机出现了。在接下来的 30-50 年里，印刷材料的价格下降了 100 倍。在接下来的一个世纪里，数量增加了 10000 倍。

> *“If you think about what happened to the scribes, they ceased to become scribes, but now there’s a category of writers and authors. These people now exist. And the reason they exist is because the market for literature just expanded a ton.”  
> “如果你想想抄写员发生了什么，他们不再当抄写员了，但现在有了一个作家和作者的类别。这些人现在存在。他们存在的原因是文学市场刚刚扩张了很多。”*

Now think about this through the lens of product teams.  
现在从产品团队的角度来思考。

Software engineers are today’s scribes. PMs are the kings who “employed” them, often unable to write the code themselves.  
软件工程师是今天的抄写员。产品经理是“雇佣”他们的人王，往往自己写不了代码。

The disconnect between “what I want built” and “who can build it” is *the* fundamental coordination problem that [PRDs](https://www.news.aakashg.com/p/product-requirements-documents-prds), design reviews, sprint planning, and every alignment meeting existed to solve.

**When building costs near zero, that coordination layer compresses.** The bottleneck moves from “can we build it” to “should we ship it.”

[PRDs existed because](https://www.news.aakashg.com/p/product-requirements-documents-prds) building was expensive and you needed sign-off before committing resources. When a [prototype](https://www.news.aakashg.com/p/ai-prototyping-tutorial) takes 45 minutes instead of 6 weeks, nobody needs a document to authorize exploration.

They need someone who can look at working software and say “this one, not that one” in real time.

If anything, the spec now comes *after* the prototype.

This is taste at speed.

And it’s a **filtering function**, not an acceleration function. The [80% kill rate](https://www.youtube.com/watch?v=We7BZVKbCVw&t=2463s) is the whole point.

> *“Half my ideas are bad and you just have to try stuff. You try a thing, you give it to users, you talk to users, you learn, and then eventually you might end up at a good idea. Sometimes you don’t.”*

Without taste, speed just means you build the wrong thing faster. That’s a feature factory on steroids.

I think the best articulation of why judgment becomes the long-term moat is [Shreyas Doshi’s recent piece on product sense](https://shreyasdoshi.substack.com/p/why-product-sense-is-the-only-product). His logic: AI tools will commoditize. When everyone has roughly equivalent AI capabilities, the only differentiator is the human judgment applied on top of AI outputs. He breaks that into five skills: **empathy, simulation, strategic thinking, taste, and creative execution.**

Taste at speed activates all five simultaneously. You’re staring at working software and running empathy (does this solve the real problem?), simulation (what breaks at scale?), strategy (does this fit where we’re going?), taste (is this the best of the options?), and creative execution (can I see a version 2x better?) all at once.

![](https://substackcdn.com/image/fetch/$s_!LSut!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F289c6dee-3437-48fe-8c59-df9b56211dfc_3600x4500.png)

### Why Speed Compounds

The speed component matters because it creates a flywheel.

A PM who evaluates 15 prototypes a week builds judgment faster than a PM who reviews one spec a month. After 6 months, that volume of pattern-matching reps creates a taste gap that keeps widening.

The experience gap becomes a taste gap.

The taste gap becomes a career gap.

And it compounds every single week.

---

## 2\. How the Best Teams Actually Ship Now

Let me walk through exactly how the Claude Code team operates.

### The Old Model vs. The New Model

The traditional flow was linear:

**Idea → PRD → Design → Eng builds → QA → Ship** (8-12 weeks)

The AI-era flow is cyclical:

**Idea → 5 prototypes → Evaluate → Kill 4 → Spec the survivor → Ship** (1-2 weeks)

![](https://substackcdn.com/image/fetch/$s_!IBNr!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F39dac18d-abf2-4d8b-9694-6333e9e2cb4b_3600x4500.png)

The spec didn’t disappear. It moved from step 2 to step 6.

It comes *after* you know what you’re building instead of before.

### How Boris Actually Works

Five terminal tabs. Each one has a parallel checkout of the repository. He starts Claude Code in **plan mode** in each one. Round-robins between them.

Goes back and forth on the plan until it’s right. Then with Opus 4.6, the implementation one-shots almost every time.

He also starts agents from his phone every morning *before he’s at his desk.* A third of his code might come from the iOS app.

He was [candid about plan mode’s shelf life](https://www.youtube.com/watch?v=PQU9o_5rHC4&t=1s):

> “Plan mode probably has a limited lifespan. Maybe in a month, no more need for plan mode.”

That’s wild to hear from the guy who built it. But it tracks with his core philosophy: **don’t build for the model of today. Build for the model [6 months from now](https://www.youtube.com/watch?v=PQU9o_5rHC4&t=1s).**

> “All of Claude Code has just been written and rewritten and rewritten over and over and over. There is no part of Claude Code that was around 6 months ago.”

**The numbers are real:**

- Claude Code writes **~80% of code** at Anthropic on average
- Boris writes **100%** of his with Claude Code
- He ships **10-30 PRs daily**, every day
- Opus introduced maybe **2 bugs** in an entire month of coding. He estimates he would have introduced **~20** writing by hand.
- Productivity per engineer has increased **200%** since Claude Code launched, even as Anthropic has **tripled** in headcount

To put that in context, Boris ran code quality at Meta. A 2% productivity gain there was “a year of work by hundreds of people.”

### The Team Culture

Everyone at Anthropic has the same title: **Member of Technical Staff.** PMs code. Data scientists code. Designers code. The finance guy codes.

This happened organically. Boris walked into the office one day and saw a data scientist with Claude Code up on his monitor. Using it to run SQL queries with ASCII visualizations in the terminal.

Boris asked if he was dogfooding.

“No, I’m using it to run queries.”

The next week, the entire row of data scientists had Claude Code running. Then half the sales team. Then the finance team. Boris calls this **[latent demand](https://www.youtube.com/watch?v=AmdLVWMdjOk&t=1444s)**, and he thinks it’s the single most important principle in product.

> “You can never get people to do something they do not yet do. The thing you can do is find the intent that they have and then steer it to let them better capitalize on that intent.”

No PRDs on the Claude Code team. Cat Woo, who runs product, is extremely technical. The culture is “better send a PR.”

And the prototyping volume is staggering:

- **Agent teams**: “probably hundreds of versions” before shipping
- **Condensed file view**: ~30 prototypes, then a month of internal dogfooding
- **Terminal spinner**: “probably 50 maybe 100 iterations, and 80% of those didn’t ship”
- **Plugins**: built by Daisy running swarms over a weekend. She told the swarm to build plugins, come up with a spec, make an Asana board, split into tasks. It spawned a couple hundred agents. They made 100 tasks. Then they implemented it. *“That’s pretty much the version of plugins that we shipped.”*

### Code Review Isn’t Dead

This isn’t a free-for-all.

Every PR at Anthropic is **code-reviewed by Claude Code first**, catching about 80% of bugs. Then a human engineer does the second pass. There are type checkers, linters, and the build runs. Claude Code even tests itself by launching itself in a subprocess.

Boris still automates lint rules in real time. Early in his career at Meta, he kept a spreadsheet: every time he left a code review comment about a recurring pattern, he tallied it. When a row hit 3-4 instances, he wrote a lint rule. Now he does the same thing but faster: he tags Claude directly on a coworker’s PR and [asks it to write the lint rule](https://www.youtube.com/watch?v=julbw1JuAz0&t=17s).

> “The more general model will always outperform the more specific model. We have a framed copy of the bitter lesson on the wall where the Claude Code team sits.”

**There’s always an engineer approving the change before anything goes [to production](https://www.news.aakashg.com/p/ai-prototype-to-production).**

### The Honest Caveat

I want to be straight about why this works at Anthropic specifically:

- **Small, senior team** where everyone shares deep context
- **The product IS the AI tool** they’re building with
- **Boris built his taste over 15+ years** shipping at Meta scale. He was one of the most prolific code authors *and* code reviewers at Instagram.
- **Extraordinary hiring density.** Dario’s own words: “You want a relatively small set of people where almost everyone you hire is really, really good.”

The prototype-first evaluation loop, the discipline of trying dozens or hundreds of versions, the culture of showing instead of writing, the code review automation layer. All of that translates to other companies.

But most teams aren’t 100% senior generalists at an AI company building their own AI tool. The no-PRD approach requires a team small enough to align through conversation and prototypes. So the full Anthropic playbook won’t work everywhere yet.

**But here’s my take:** this is where most fast-moving teams will be within 18 months. The tools are getting accessible enough. Cowork is Anthropic’s bet on bringing this to non-engineers. v0, Cursor, Replit, and Lovable are all pushing in the same direction.

The question isn’t *if* this workflow becomes standard. It’s *when.*

And Boris [thinks](https://www.youtube.com/watch?v=We7BZVKbCVw&t=2463s) coding is already largely solved.

> “I think by the end of the year, everyone’s going to be a product manager and everyone codes. The title software engineer is going to start to go away. It’s just going to be replaced by builder.”

The PMs who start building these reps now will have a massive head start.

---

🔒 **The rest of this post is for paid subscribers.** I’m going deep on the Taste at Speed Framework (5 Lenses), how to build this skill regardless of your starting point, where the PRD fits now, and a full real-world teardown showing good vs. bad prototype evaluation side by side. Plus 4 downloadable templates.

Hi **wufeilongsky@gmail.com**

## Keep reading with a 7-day free trial

Subscribe to Product Growth to keep reading this post and get 7 days of free access to the full post archives.

[Already a paid subscriber? **Switch accounts**](https://substack.com/sign-in?redirect=%2Fp%2Ftaste-at-speed&for_pub=aakashgupta&change_user=true)