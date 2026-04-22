# AI Knowledge Wiki

Purpose: 追踪 AI agents、知识管理、内容平台、思维方法的跨领域洞察
Owner: wufeilong
Created: 2026-04-22

## 结构

```
vault/
├── sources/       # 原始材料（只读）
├── wiki/          # 综合洞察页
│   └── index.md   # 目录（所有 wiki 页面的入口）
├── .raw/          # 原始备份（隐藏）
├── WIKI.md        # wiki 操作指南
└── CLAUDE.md      # 本文件
```

## 操作规范

详见 WIKI.md。核心三条：

1. **不是每个 source 都需要 wiki 页面**。只有跨 3+ 个 source 的新洞察才值得写。
2. **wiki 页面是判断，不是摘要**。每页必须有"核心洞察"段，一段话说清结论。
3. **宁少勿多**。

## 约定

- `sources/` 只读，不改原始材料
- 用 `[[Page Name]]` wikilink，不用文件路径
- wiki 页面必须有 frontmatter（title, created, tags）
- 引用 source 格式：`[[sources/文件名.md|显示名]]`
- wiki 目录在 `wiki/index.md`，新增/删除页面时更新
