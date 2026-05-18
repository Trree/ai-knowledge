# AI Knowledge Wiki

Purpose: 追踪 AI agents、知识管理、内容平台、思维方法的跨领域洞察
Owner: wufeilong

本仓库是知识库 / wiki 仓库，不是软件工程仓库。结构和 wiki 操作细则见 `WIKI.md`。

## 启动约定

- 先读 [[WIKI]].md，再做结构或内容判断。
- 默认启用直接模式；用户说“导师模式”时，按 `mentor-mode.md` 临时开启。
- 默认做小而边界清晰的任务；大改结构前先给短计划。
- 优先产出直接有价值的结果：更新 `wiki/`、维护 `wiki/index.md`、整理 `sources/`。
- `sources/` 只读；新增材料统一放入 `sources/`，除非用户明确要求改原始材料。

## Wiki 判断

- wiki 页面是判断，不是摘要；每页回答一个真实问题。
- 只有跨 3+ 个 source 产生新问题或新洞察时，才值得写新页面。
- 如果现有页面能吸收新材料，优先更新旧页，不重复造页。
- 不创建只总结单个 source 的 wiki 页面；宁少勿多。
- wiki 页面必须有 frontmatter：`title`、`created`、`tags`。
- 使用 `[[Page Name]]` wikilink；引用 source 用 `[[sources/文件名.md|显示名]]`。
- 新增、删除、重命名 wiki 页面时，同步更新 `wiki/index.md`。
- 不臆造 manifest、数据库、自动 ingest 流程或复杂目录层级。

## 知识资产边界

- Memory 存长期判断；Skill 存可触发流程；path rule 存局部规则。
- 默认所有任务都该知道的规则，才写入 `AGENTS.md` / `CLAUDE.md`。
- 有明确触发场景和 3 步以上动作的重复流程，优先沉淀为 Skill。
- taste 是判断什么值得留下、什么应该拒绝；用正例、反例、拒绝理由沉淀。
- 一次性纠错或临时偏好不进入团队 memory。

## 经验捕获触发器

任务结束前，如果出现以下情况，检查是否需要写入 `memory-candidates.md`：

- 用户纠正了 agent 的判断、流程或边界。
- agent 发现自己违反了仓库规则。
- 同类问题重复出现。
- 做出了“不创建 / 不更新 / 合并 / 删除”的知识判断。
- 用户表达了长期偏好，例如“以后都……”“不要再……”。

只有当这条经验会改变下一次行动时，才写入候选池。
不确定时，先问用户，不要自动写。
