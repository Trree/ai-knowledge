# WIKI.md — Wiki 操作指南

> 基于 Karpathy LLM Wiki 的核心精神：知识应该复利增长。
> "This document is intentionally abstract. Everything is optional and modular — pick what's useful, ignore what isn't."

---

## 核心原则

1. **退后一层**：人定义什么知识重要，LLM 做执行
2. **极限压缩**：能用一页说清楚的不要拆成三页
3. **真实结果做裁判**：wiki 的价值不是"格式合规"，是"比原始笔记更能回答问题"

---

## 架构

```
vault/
├── sources/        # 原始材料（一等公民，可浏览，只读）
├── wiki/           # 综合洞察（每篇回答一个跨源的真问题）
│   └── index.md    # 目录
├── .raw/           # 原始备份（隐藏，不日常使用）
├── WIKI.md         # 本文件
└── CLAUDE.md
```

### 两层，不是八层

- **sources/** = 原始材料。放进来就不改。是知识的"地基"。
- **wiki/** = 你的洞察。每篇综合页跨多个 source 回答一个真问题。不是摘要，是新理解。

---

## 操作

### INGEST — 添加新材料

1. 把文件放进 `sources/`
2. 读完原文，问自己：**这改变了我对什么的认知？**
3. 如果它改变了某个已有 wiki 页面的结论 → 更新那个页面
4. 如果它揭示了一个新的跨源问题 → 写一篇新的 wiki 页面
5. 如果它只是补充细节 → 不需要新页面，加一个 wikilink 引用就够
6. 更新 `wiki/index.md`

**关键**：不是每个 source 都需要对应的 wiki 页面。只有当多个 source 交叉产生新洞察时才值得写。

### QUERY — 回答问题

1. 读 `wiki/index.md` 找相关页面
2. 读那些页面 + 它们引用的 sources
3. 综合回答，用 wikilink 引用
4. 如果答案揭示了新的跨源洞察 → 写成 wiki 页面

### LINT — 健康检查

- wiki 页面引用的 source 是否存在
- 有没有 wiki 页面变成了纯摘要（没有跨源洞察）
- index.md 是否和实际文件一致

---

## Wiki 页面标准

### 什么值得写

- 跨 3+ 个 source 回答一个真问题 ✓
- 发现了不同领域的共同模式 ✓
- 揭示了材料之间的矛盾或张力 ✓

### 什么不值得

- 单个 source 的摘要 ✗（直接读原文）
- Google 就能查到的实体信息 ✗
- 没有判断的"客观综述" ✗

### 格式

```markdown
---
title: 页面标题
created: YYYY-MM-DD
tags: [tag1, tag2]
---
# 页面标题

## 核心洞察
一段话说清楚这个页面回答什么问题，结论是什么。

## 证据/分析
引用多个 source，展示跨源的联系。
→ [[sources/文件名.md|显示名]]

## 与其他页面的关系
- [[另一个 wiki 页面]]：关系说明

## 未回答的问题
- 这个洞察的边界在哪？
```

---

## 规则

- `sources/` 只读，不改原始材料
- `wiki/` 自由创建、更新、删除
- 用 wikilink `[[Page Name]]` 而不是文件路径
- 每个 wiki 页面必须有 frontmatter（title, created, tags）
- 宁少勿多：6 篇有洞察的页面 > 60 篇机械摘要
