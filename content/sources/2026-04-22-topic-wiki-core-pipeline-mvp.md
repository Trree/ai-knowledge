# 窄场景 Topic Wiki 核心编译流水线 MVP

状态：Draft v0.1  
目标：只定义最简可跑通的编译流水线，不包含前台、后台、支付、权限、队列  

## 1. MVP 结论

最简 MVP 只做一件事：

`把一组 source 编译成一个可交付的 Topic Wiki 包。`

最小输入：

- 1 个主题
- 1 个 source 目录
- 最多 30 份资料

最小输出：

- `raw/`
- `schema/`
- `wiki/`
- `index/`
- `query-demo/`
- `lint-report/`

最小运行方式：

- 一个本地 CLI 命令
- 一个工作目录
- 一套 prompt / 模板
- 一次人工复核

## 2. 最小目录结构

```text
topic-wiki-mvp/
  inputs/
    sources/
    topic.txt
    user-goal.txt
  templates/
    schema.prompt.md
    wiki.prompt.md
    query-demo.prompt.md
    lint.prompt.md
  workspace/
  outputs/
```

每次运行时，在 `workspace/` 下创建一个独立任务目录：

```text
workspace/run-20260422-001/
  raw/
  schema/
  wiki/
  index/
  query-demo/
  lint-report/
  logs/
```

## 3. MVP 只保留 6 个步骤

### Step 1: source 规范化

目标：

- 把各种输入资料统一成 utf-8 文本或 markdown
- 给每份资料分配稳定 `source_id`

输入：

- `inputs/sources/`

输出：

- `raw/src-001.md`
- `raw/src-002.md`
- `raw/manifest.yaml`

`manifest.yaml` 最少包含：

```yaml
topic: ai-coding-agents
sources:
  - source_id: src-001
    title: Example Source 1
    source_type: pdf
    origin_name: example.pdf
    normalized_path: raw/src-001.md
  - source_id: src-002
    title: Example Source 2
    source_type: markdown
    origin_name: notes.md
    normalized_path: raw/src-002.md
```

实现原则：

- PDF 先转文本
- 网页先转 markdown
- markdown 保持原样
- 其他格式先转纯文本

这一步不追求完美解析，只追求“后面步骤能稳定吃进去”。

### Step 2: source 索引

目标：

- 给 source 建立一个最小索引，便于后面生成 schema 和 trace

输入：

- `raw/*.md`
- `raw/manifest.yaml`

输出：

- `index/source-index.md`
- `index/source-index.csv`

每份 source 至少提取：

- `source_id`
- `title`
- `source_type`
- `一句话摘要`
- `可能相关的主题标签`

这一步建议用轻模型完成。

### Step 3: schema 草拟

目标：

- 先生成“这个主题的 wiki 应该长什么样”

输入：

- `topic.txt`
- `user-goal.txt`
- `index/source-index.md`
- 抽样 source 内容

输出：

- `schema/schema.md`
- `schema/page-types.md`
- `schema/site-map.md`

最小要求：

- 定义 3 到 6 类页面类型
- 定义 wiki 根目录结构
- 定义每类页面的字段

建议 page type 先固定为这几类：

- `overview`
- `concept`
- `entity`
- `comparison`
- `timeline`
- `open-question`

MVP 不需要追求完全自适应 schema，先用“固定 page type + 主题化命名”就够。

### Step 4: wiki 编译

目标：

- 把 source 编译成可浏览的 wiki 页面，而不是摘要堆

输入：

- `raw/`
- `schema/`
- `topic.txt`

输出：

- `wiki/index.md`
- `wiki/overview.md`
- `wiki/concepts/*.md`
- `wiki/entities/*.md`
- `wiki/comparisons/*.md`
- `wiki/timeline.md`
- `wiki/open-questions.md`

最小生成策略：

1. 先生成 `overview.md`
2. 再生成 `timeline.md`
3. 再生成 `concept` 页面
4. 再生成 `entity/comparison` 页面
5. 最后回写 `wiki/index.md`

每个页面最少包含：

- 页面标题
- 页面摘要
- 正文
- `source_ids`

推荐 frontmatter：

```yaml
---
title: Multi-Agent Coding
page_type: concept
source_ids:
  - src-001
  - src-003
---
```

### Step 5: query demo 生成

目标：

- 用固定问题证明这个 wiki 真的能用

输入：

- `wiki/`
- `raw/manifest.yaml`

输出：

- `query-demo/what-we-know.md`
- `query-demo/contradictions.md`
- `query-demo/what-to-add-next.md`

固定只回答 3 个问题：

1. `我们知道什么？`
2. `哪些地方互相矛盾？`
3. `接下来该补什么资料？`

这一步本质上是“面向销售和交付验收的演示层”。

### Step 6: lint 生成

目标：

- 检查这个 wiki 是否足够可信、足够完整、足够可交付

输入：

- `wiki/`
- `schema/`
- `raw/manifest.yaml`

输出：

- `lint-report/summary.md`
- `lint-report/issues.csv`

MVP 只检查 4 类问题：

1. 页面没有 `source_ids`
2. 页面命名不符合 schema
3. source 被导入了，但没有进入任何 wiki 页面
4. query demo 提到的矛盾或缺口，没有对应 source 支撑

这一步不做复杂 graph lint。

## 4. 最小流水线顺序

完整顺序如下：

```text
normalize_sources
  -> build_source_index
  -> draft_schema
  -> compile_wiki
  -> generate_query_demo
  -> run_lint
  -> human_review
  -> export_bundle
```

其中：

- `human_review` 必须保留
- `export_bundle` 只是打包，不算核心智能步骤

## 5. 最小代码结构

如果现在开始写代码，我建议只保留一个 Python CLI 项目：

```text
src/
  main.py
  pipeline.py
  steps/
    normalize.py
    source_index.py
    schema.py
    compile_wiki.py
    query_demo.py
    lint.py
  llm/
    provider.py
    prompts.py
  utils/
    files.py
    markdown.py
    frontmatter.py
```

### 5.1 入口命令

```bash
python -m src.main run \
  --topic-file inputs/topic.txt \
  --goal-file inputs/user-goal.txt \
  --sources-dir inputs/sources \
  --output-dir workspace/run-20260422-001
```

### 5.2 主流程伪代码

```python
def run_pipeline(topic_file, goal_file, sources_dir, output_dir):
    manifest = normalize_sources(sources_dir, output_dir)
    source_index = build_source_index(manifest, output_dir)
    schema = draft_schema(topic_file, goal_file, source_index, output_dir)
    wiki = compile_wiki(manifest, schema, topic_file, output_dir)
    query_demo = generate_query_demo(wiki, manifest, output_dir)
    lint = run_lint(wiki, schema, manifest, query_demo, output_dir)
    export_bundle(output_dir)
```

## 6. 每一步的模型策略

最简 MVP 建议只用两档模型：

- 轻模型：
  用于 source metadata 提取、初步摘要、命名清洗
- 强模型：
  用于 schema 生成、wiki 页面编译、矛盾分析、query demo

最小原则：

- 不要每一步都用强模型
- 不要先做 embedding / vector database
- 不要先做 graph database

这三个东西都不是最简 MVP 必需品。

## 7. 先不要做的东西

为了保持 MVP 最小化，以下内容全部延后：

- 在线编辑器
- 多用户协作
- 队列系统
- 数据库
- SaaS 后台
- 自动支付
- 复杂权限
- 长期增量 ingest
- 图检索
- 向量检索
- 自动纠错闭环

原因：

这些都不会决定“首包能不能交付”，只会推迟你拿到第一单可用结果。

## 8. 人工复核清单

MVP 必须有人审一次，重点审 5 件事：

1. `overview.md` 是否真的回答了主题
2. 页面命名是否清楚，不像模型乱写
3. 每个核心页面是否都有 `source_ids`
4. `contradictions.md` 里的冲突是否站得住
5. `what-to-add-next.md` 是否给出真实可执行的补料建议

## 9. 最小验收标准

只要满足下面 7 条，就算 MVP 跑通：

1. 能从一个 source 目录生成完整输出目录。
2. 输出目录中包含 `raw/`、`schema/`、`wiki/`、`index/`、`query-demo/`、`lint-report/`。
3. `wiki/index.md` 能导航到主要页面。
4. 主要页面有 `source_ids`。
5. `query-demo/` 下 3 个文件都成功生成。
6. `lint-report/summary.md` 能指出至少一种结构问题或内容缺口。
7. 人工看完之后，认为这包东西“能交付给首单用户”。

## 10. 最小落地建议

如果你现在就要开做，我建议开发顺序固定成这样：

1. 先做 `normalize_sources`
2. 再做 `draft_schema`
3. 再做 `compile_wiki`
4. 再做 `generate_query_demo`
5. 最后做 `run_lint`

原因：

- `source 索引` 很轻，可以穿插着做
- 真正决定这个产品有没有价值的是 `schema -> wiki -> query demo`
- `lint` 是增强信任感，不是第一性价值

一句话版本：

`最简 MVP 不是一个平台，而是一条能把 source 编译成 Topic Wiki 交付包的命令行流水线。`
