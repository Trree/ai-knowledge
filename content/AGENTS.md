# AI Knowledge Wiki

Purpose: 追踪 AI agents、知识管理、内容平台、思维方法的跨领域洞察
Owner: wufeilong
Created: 2026-04-24

## 结构

```text
vault/
├── sources/       # 原始材料（只读）
├── wiki/          # 综合洞察页
│   └── index.md   # 目录（所有 wiki 页面的入口）
├── WIKI.md        # wiki 操作指南
├── CLAUDE.md      # Claude 启动说明
└── AGENTS.md      # Codex / 通用 agent 启动说明
```

## 给 Codex 的工作约定

1. 先读 `WIKI.md`，再做结构或内容判断。
2. 把这个仓库当作知识库 / wiki 仓库，而不是软件工程仓库。
3. 默认做小而边界清晰的任务；如果要大改结构，先给一个短计划。
4. 优先产出对仓库有直接价值的结果：新增/更新 `wiki/` 页面、维护 `wiki/index.md`、整理 `sources/`。

## 核心规则

- `sources/` 只读，不改原始材料，除非用户明确要求。
- 新增材料统一放入 `sources/`。
- 不是每个 source 都需要对应 wiki 页面；只有跨 3+ 个 source 产生新问题或新洞察时才值得写。
- wiki 页面是判断，不是摘要；每页都应有明确的“核心洞察”。
- wiki 页面必须有 frontmatter：`title`、`created`、`tags`。
- 使用 `[[Page Name]]` wikilink，不用文件路径互链。
- 引用 source 时使用 `[[sources/文件名.md|显示名]]`。
- 新增、删除、重命名 wiki 页面时，同步更新 `wiki/index.md`。
- 增量检测入口：`.\sync-wiki.cmd` 或 `powershell -ExecutionPolicy Bypass -File scripts/sync-wiki.ps1`。

## 质量标准

- 宁少勿多。6 篇有判断的页面，优于 60 篇机械摘要。
- 一篇 wiki 页面回答一个真实问题，而不是堆事实。
- 如果现有页面已经能吸收新材料，优先更新旧页面，不要重复造页。
- 不要臆造仓库里不存在的 manifest、数据库、自动 ingest 流程或复杂目录层级，除非用户明确要求。
