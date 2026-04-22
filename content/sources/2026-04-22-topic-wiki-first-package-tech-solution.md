# 窄场景 Topic Wiki 首包技术方案

状态：Draft v0.1  
对应需求：[2026-04-22-topic-wiki-first-package-prd.md](E:/ai-knowledge/content/2026-04-22-topic-wiki-first-package-prd.md)  
定位：商业化 MVP 技术方案  

## 1. 方案结论

这不是一个应该一开始就做成 SaaS 的产品。

最合适的技术路线是：

- 对外卖的是 `固定边界首包服务`
- 对内建设的是 `半自动编译流水线`
- 交付形态是 `Obsidian/Codex 可用的 Topic Wiki 包`
- 系统目标不是“用户自助搭建”，而是“运营同学或交付同学可以稳定、低成本、可追溯地交付首包”

一句话概括：

`先做一套服务交付中台，而不是先做一个通用知识库前台。`

## 2. 技术目标

技术方案必须同时满足 4 个商业目标：

1. 能在 `<= 30` 份 source、`1` 个主题的边界内稳定交付。
2. 能明确展示 `source trace`，降低用户对黑盒总结和 drift 的不信任。
3. 能产出 6 个可见交付件：`raw/`、`wiki/`、`schema/`、`index/`、`query-demo/`、`lint-report/`。
4. 能把首包过程沉淀成模板、规则和脚本，为后续 `Starter Kit` 做准备。

## 3. 总体架构

推荐采用 `前台极简 + 后台工作流引擎 + 每单独立工作区` 的架构。

### 3.1 架构分层

#### A. 商业前台

负责获客和下单，不承载核心编译逻辑。

- 官网落地页
- 试卖页
- 资料提交页
- 订单状态页

#### B. 运营后台

负责订单流转、资料审核、人工介入和最终交付。

- 订单管理
- 资料范围确认
- 任务状态流转
- 质量检查
- 交付导出

#### C. 编译引擎

负责把 source 编译成 Topic Wiki。

- source 规范化
- metadata 提取
- schema 生成
- wiki 页面生成
- trace 绑定
- query demo 生成
- lint 生成
- zip/vault 导出

#### D. 数据与存储层

- 订单数据
- 原始文件对象存储
- 每单工作目录
- 中间产物
- 最终交付包

## 4. 推荐技术选型

### 4.1 前端

推荐：`Next.js`

原因：

- 官网、试卖页、订单页可以共用一套前端
- 后续如果从服务演进到半自助产品，不需要重做前台
- 对 markdown 预览、文件上传、静态页面都够用

### 4.2 后端

推荐：`FastAPI`

原因：

- 文档处理、markdown 处理、LLM 调用、文件编译流水线都更适合 Python
- 后续接 worker、队列、批处理简单
- 更适合把“脚本能力”逐步收敛成 API 能力

### 4.3 数据库

推荐：`PostgreSQL`

存储：

- 订单
- 用户
- source 元数据
- 任务状态
- 交付记录
- lint issue 元数据

### 4.4 队列

推荐：`Redis + Celery`

原因：

- ingest、编译、lint、导出都属于异步任务
- 商业上要避免一次请求卡住整条流水线

### 4.5 对象存储

推荐：`S3 兼容对象存储`

可选：

- Cloudflare R2
- MinIO
- AWS S3

存储内容：

- 用户上传的原始资料
- 规范化后的文件
- 导出的 zip 包
- 公开 demo 静态资产

### 4.6 工作区

推荐：`每个订单一个独立文件工作区`

形式：

- 本地目录
- 或容器内挂载目录

原因：

- 这种产品天然以文件为中心
- 最终交付物本来就是文件夹和 markdown vault
- 每单隔离最简单，也最便于删除和追责

### 4.7 LLM 层

推荐：`双模型策略`

- 强模型：用于 schema 设计、wiki 编译、交叉矛盾分析、最终 query demo
- 轻模型：用于 metadata 提取、格式转换、标题清洗、初步 lint

要求：

- 不把模型能力硬编码到业务逻辑里
- 通过统一的 `LLM Provider Adapter` 调用

原因：

- 便于切换供应商
- 便于控制成本
- 便于后期把不同步骤分配给不同模型

## 5. 最小系统拓扑

MVP 建议只部署 5 个服务：

1. `web`
   Next.js，负责官网、试卖页、上传页、订单页
2. `api`
   FastAPI，负责订单、source、任务编排 API
3. `worker`
   Celery worker，负责 ingest、compile、lint、export
4. `db`
   PostgreSQL，负责结构化元数据
5. `object-storage`
   R2/MinIO/S3，负责原始文件和交付文件

`工程化补充`

P0 阶段甚至可以不拆独立 `web`，直接用一个极简后台页面配合静态试卖页先跑通首单。

## 6. 订单状态机

商业化服务必须有明确状态机，不然交付会失控。

建议状态：

1. `lead`
2. `scoping`
3. `quoted`
4. `paid`
5. `normalizing`
6. `schema_drafting`
7. `wiki_compiling`
8. `linting`
9. `human_review`
10. `packaging`
11. `delivered`
12. `archived`

状态流转规则：

- `scoping` 前不能进入生产
- `paid` 前不能占用正式编译资源
- `human_review` 不通过不能交付

## 7. 数据模型

### 7.1 核心实体

#### `Order`

- `id`
- `topic_name`
- `user_id`
- `status`
- `price`
- `scope_limit`
- `delivery_due_at`
- `created_at`

#### `Source`

- `id`
- `order_id`
- `title`
- `source_type`
- `origin_url`
- `file_key`
- `normalized_file_key`
- `status`
- `word_count`
- `language`

#### `SchemaVersion`

- `id`
- `order_id`
- `version`
- `schema_md`
- `naming_rules_md`
- `page_type_rules_md`

#### `WikiPage`

- `id`
- `order_id`
- `path`
- `title`
- `page_type`
- `summary`
- `status`

#### `TraceLink`

- `id`
- `order_id`
- `wiki_page_id`
- `source_id`
- `evidence_span`
- `claim_type`

#### `LintIssue`

- `id`
- `order_id`
- `page_path`
- `issue_type`
- `severity`
- `description`
- `suggested_fix`

#### `DeliveryBundle`

- `id`
- `order_id`
- `bundle_key`
- `bundle_version`
- `delivered_at`

## 8. 交付包目录规范

建议统一输出如下结构：

```text
topic-wiki-package/
  README.md
  raw/
    manifest.yaml
    src-001.pdf
    src-002.md
  schema/
    schema.md
    page-types.md
    naming-rules.md
    AGENTS.md
  wiki/
    index.md
    log.md
    overview.md
    concepts/
    entities/
    comparisons/
    timeline/
  index/
    source-index.md
    page-index.md
    trace-index.csv
  query-demo/
    what-we-know.md
    contradictions.md
    what-to-add-next.md
  lint-report/
    summary.md
    issues.csv
    risk-notes.md
```

说明：

- `index.md` 和 `log.md` 保留原始 `LLM Wiki` 思路里的核心导航角色
- `trace-index.csv` 用于让 source trace 可机器检查
- `AGENTS.md` 用于约束后续继续 ingest / query / lint 的规则

## 9. 核心编译流水线

### 9.1 Step 1: Intake 与边界检查

输入：

- 用户主题
- 用户目标问题
- source 列表

处理：

- 检查是否单主题
- 检查是否超过 `30` 份 source
- 给出缩边界建议

输出：

- `scope-review.md`
- 最终批准的 source manifest

### 9.2 Step 2: Source 规范化

支持输入类型：

- PDF
- 网页
- Markdown
- DOCX
- 会议纪要文本
- 视频字幕文本

处理：

- 转成 utf-8 文本或 markdown
- 生成统一 metadata
- 标记 source id

输出：

- `raw/manifest.yaml`
- 标准化后的 source 文件

### 9.3 Step 3: Source 索引

处理：

- 为每份 source 提取标题、作者、日期、类型、摘要
- 生成 source catalog
- 为后续 page trace 预留稳定 source id

输出：

- `index/source-index.md`

### 9.4 Step 4: Schema 草拟

输入：

- 主题描述
- source sample
- 可选行业模板

处理：

- 生成该主题的页面类型
- 生成目录结构建议
- 生成命名规范
- 生成页面间链接规则

输出：

- `schema/schema.md`
- `schema/page-types.md`
- `schema/naming-rules.md`

### 9.5 Step 5: Wiki 编译

处理：

- 先生成 overview、timeline、concept、entity、comparison 这些核心页面
- 再补双向链接
- 再补每页的 source 引用

要求：

- 不是把 source 摘抄成卡片
- 而是编译成围绕主题组织的知识页面

输出：

- `wiki/` 下各类主题页面

### 9.6 Step 6: Trace 绑定

处理：

- 为每个关键结论绑定 source id
- 生成 page 到 source 的映射
- 生成 source 到 page 的反向映射

推荐做法：

- 页面 frontmatter 内写 `source_ids`
- 正文内关键结论用脚注或引用块标记来源
- 另外输出 `trace-index.csv`

### 9.7 Step 7: Query Demo 生成

固定回答 3 个问题：

1. `我们知道什么？`
2. `哪些地方互相矛盾？`
3. `接下来该补什么资料？`

输出：

- `query-demo/what-we-know.md`
- `query-demo/contradictions.md`
- `query-demo/what-to-add-next.md`

### 9.8 Step 8: Lint 与风险检查

lint 不只是格式检查，必须覆盖商业上真正影响信任的风险。

至少检查：

- 孤立页面
- 未引用 source 的页面
- 同一概念的命名漂移
- 互相冲突但未标记的结论
- 明显缺失的关键维度

输出：

- `lint-report/summary.md`
- `lint-report/issues.csv`
- `lint-report/risk-notes.md`

### 9.9 Step 9: 人工复核

这一步不能完全自动化。

人工必须复核：

- 主题边界是否跑偏
- 页面命名是否像人写的，不像模型乱起名
- 关键结论是否真的可回溯
- query demo 是否有实际价值

### 9.10 Step 10: 导出与交付

输出：

- zip 包
- 可选私有 git 仓库
- 可选静态 html 预览

## 10. API 设计

MVP 不需要复杂开放平台，但内部系统最好一开始就有明确 API。

### 10.1 订单 API

- `POST /api/orders`
- `GET /api/orders/{id}`
- `POST /api/orders/{id}/quote`
- `POST /api/orders/{id}/mark-paid`

### 10.2 Source API

- `POST /api/orders/{id}/sources/presign`
- `POST /api/orders/{id}/sources/confirm`
- `GET /api/orders/{id}/sources`
- `POST /api/orders/{id}/scope-review`

### 10.3 编译 API

- `POST /api/orders/{id}/normalize`
- `POST /api/orders/{id}/draft-schema`
- `POST /api/orders/{id}/compile-wiki`
- `POST /api/orders/{id}/generate-query-demo`
- `POST /api/orders/{id}/run-lint`
- `POST /api/orders/{id}/package`

### 10.4 交付 API

- `GET /api/orders/{id}/deliveries`
- `POST /api/orders/{id}/deliver`
- `GET /api/orders/{id}/download`

## 11. Prompt 与规则系统

这个产品的核心资产，不是模型调用次数，而是规则系统。

必须把以下内容做成可版本化模板：

- 不同行业的 schema 模板
- 页面命名规则
- 页面类型定义
- source trace 规则
- lint 规则
- query demo 生成规则
- handoff 说明模板

推荐做法：

- 所有 prompt 都以 markdown 文件存储
- 每次交付记录所用 prompt 版本
- 重要模板进入 git 管理

## 12. 人工与自动化边界

### 12.1 必须自动化的部分

- source 上传与存储
- source 规范化
- source manifest 生成
- 基础 metadata 提取
- query demo 初稿生成
- lint 初稿生成
- bundle 导出

### 12.2 必须保留人工的部分

- 主题缩边界
- schema 最终确认
- 关键页面改写
- 冲突结论判定
- 最终交付质量把关

结论：

`这是一个“人机协作交付系统”，不是全自动知识工厂。`

## 13. 安全与隐私

商业化必须考虑资料敏感性。

最低要求：

- 每个订单独立工作区
- 用户上传文件加访问控制
- 默认不把客户资料用于训练
- 交付后支持按订单删除
- 下载链接有时效

`工程化补充`

建议策略：

- 原始文件保留 `30` 天
- 交付包保留 `90` 天
- 支持客户手动触发提前删除

## 14. 成本控制

首包要成立，单位经济必须成立。

### 14.1 成本来源

- LLM token 成本
- 文件解析成本
- 人工审核成本
- 存储成本

### 14.2 控制手段

- 强制 `<= 30` 份 source
- 先做 source 规范化和抽样，不直接整库灌入强模型
- 轻模型负责抽取，强模型只负责高价值步骤
- 只在最终交付前做一次人工精修

### 14.3 工程目标

建议把单单交付控制在：

- 机器流水线 `20-40` 分钟
- 人工审核 `30-60` 分钟

这样 `999 RMB` 的内测价才有机会跑通验证。

## 15. 分阶段实施

### P0：服务交付脚本化

目标：

- 先支撑 `10-20` 单以内的人工交付

实现：

- 静态试卖页
- 简单上传入口
- Python 脚本 + FastAPI 后台
- 每单本地工作目录
- 手动触发流水线

不做：

- 用户自助编辑
- 多租户权限体系
- 在线 wiki 编辑器

### P1：内部交付中台

目标：

- 让 1 个运营或交付同学可以稳定并行处理多个订单

新增：

- 订单后台
- 任务状态页
- 失败重跑
- prompt 版本管理
- 行业模板管理

### P2：半产品化

目标：

- 从交付中沉淀出可复制模板，准备卖 `Starter Kit`

新增：

- 模板市场雏形
- 自助 intake
- 自助重新编译部分页面
- 简单静态预览

### P3：产品化扩展

仅在以下条件成立后再考虑：

- 首包付费需求被验证
- 用户愿意复购
- 用户明确要求更多自助能力

再考虑：

- 持续 ingest
- 在线协作
- 多主题管理
- 检索增强
- 插件化 lint

## 16. 风险与应对

### 风险 1：技术上能做，商业上不成立

应对：

- 先做服务型后台，不做重平台
- 先验证付费和资料提交率

### 风险 2：trace 做不透，用户不信

应对：

- 强制 page-source 双向索引
- 关键结论必须可回源

### 风险 3：模型输出看起来像 AI 垃圾

应对：

- 保留人工改写
- 用 schema 限制页面形式
- 不追求大而全，先追求边界清楚

### 风险 4：后续维护体验差

应对：

- 在 `README.md` 和 `AGENTS.md` 中明确继续 ingest / query / lint 的方法
- 把 handoff 做成交付的一部分，而不是额外服务

## 17. 验收标准

技术方案落地后，首包系统至少要满足：

1. 能接收一个订单和最多 `30` 份 source。
2. 能把 source 规范化并生成 manifest。
3. 能生成 `schema/`、`wiki/`、`index/`、`query-demo/`、`lint-report/`。
4. 能导出一个可下载的交付包。
5. 关键页面能追溯到 source。
6. 交付过程有明确状态机，且支持失败重试。
7. 运营人员不需要直接进代码仓库，也能完成交付。

## 18. 最小落地建议

如果现在就开做，我建议按下面顺序：

1. 先实现 `订单 + 上传 + 工作区 + 导出 zip`
2. 再实现 `source 规范化 + manifest + source-index`
3. 再实现 `schema 生成 + wiki 编译`
4. 再实现 `query demo + lint`
5. 最后补 `后台状态页 + 模板管理`

原因很简单：

先把“能交付”做出来，再把“更自动”做出来。
