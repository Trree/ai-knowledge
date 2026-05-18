
是的，**Codex 经常“卡住”不一定是它在执行很大的任务**。更准确地说，可能分成 6 类原因：

## 1. 它真的在做大任务

典型场景：

- 一次让它改很多文件
    
- 让它理解整个仓库
    
- 让它跑测试、构建、类型检查
    
- 让它自己探索代码结构
    
- 让它生成 PRD、拆 issue、写代码、跑验证一条龙
    

这种情况下它不是卡死，而是进入了长链路：

> 读代码 → 建模 → 规划 → 修改 → 跑命令 → 读报错 → 再修改 → 再跑

尤其是大型仓库、前端项目、monorepo、node_modules 很大的项目，会明显变慢。

但这类“慢”通常有一个特征：**它偶尔会输出命令、文件修改、测试结果**。如果一直只有 `Working...`，就不太像单纯任务大。

---

## 2. 命令卡住：最常见

很多 Codex 卡住其实不是模型卡住，而是它调用的命令卡住。

常见命令：

```bash
npm install
npm run dev
npm test
pnpm install
bunx ...
playwright ...
pytest
mvn test
gradle build
```

问题是这些命令有些会：

- 等待用户输入
    
- 启动一个长期运行服务
    
- 卡在网络下载
    
- 测试用例死循环
    
- 子进程没有退出
    
- stdout/stderr 管道没关闭
    

GitHub 上也有相关 issue：有人报告 Codex CLI 在命令超时后只杀掉 shell wrapper，没有杀掉子进程，导致子进程继续占用 stdout/stderr，最终让 Codex 看起来无限挂起。([GitHub](https://github.com/openai/codex/issues/4337?utm_source=chatgpt.com "Commands hang indefinitely when timeout occurs on shell- ..."))

所以你看到“Codex 卡住”，实际可能是：

> Codex 正在等一个永远不会结束的命令返回。

---

## 3. Sandbox / 权限导致卡住

Codex 默认会受 sandbox 和 approval policy 限制。OpenAI 文档说明，本地 Codex 会使用操作系统级 sandbox，通常限制它只能访问当前 workspace；默认网络访问也是关闭的，并且某些操作需要停下来请求批准。([OpenAI Developers](https://developers.openai.com/codex/agent-approvals-security?utm_source=chatgpt.com "Agent approvals & security – Codex"))

这会导致几个现象：

- 需要联网的命令失败或等待
    
- 需要写 workspace 外文件时被拦截
    
- 某些工具需要 approval，但 UI 没处理好
    
- Playwright、浏览器、Docker、数据库、后台服务类命令容易出问题
    

有用户报告 sandbox 环境会限制长时间或多进程测试，导致测试正确但仍超时。([GitHub](https://github.com/openai/codex/issues/3557?utm_source=chatgpt.com "Codex CLI timeout because of sandboxed environment"))

你的场景里如果经常跑：

```bash
playwright-cli open ...
npm install -g ...
npx skills add ...
claude/ducc/codex 调工具
```

那非常容易触发网络、权限、长期进程、交互命令这几类问题。

---

## 4. Approval 卡住

还有一种很像“假死”的情况：Codex 其实在等你批准某个操作，但界面状态没有明显暴露，或者 approval 被某个工具调用卡住。

OpenAI 社区里有人反馈：Codex 在处理多个文件后会卡在某个文件上，一直要求 approval，整个 session 暂停，只能重启扩展。([OpenAI Developer Community](https://community.openai.com/t/codex-get-stuck-while-executing-command/1373572?utm_source=chatgpt.com "Codex get stuck while executing command"))

GitHub issue 里也有类似描述：MCP server 的命令 approval 被阻塞时，整个 turn 会卡住，直到手动取消。([GitHub](https://github.com/openai/codex/issues/11816?utm_source=chatgpt.com "Codex mcp-server can hang indefinitely when command ..."))

这种情况的判断标准：

- 它没有继续输出
    
- 你看不到明确报错
    
- 但它也没有结束
    
- 重启后同样任务可能又能继续
    

---

## 5. Codex 自身 bug / agent loop 卡住

这不是你使用姿势的问题。Codex CLI 近期确实有不少关于“Working hangs forever”“hangs during command execution”“prompt runs indefinitely”的公开 issue。比如有人报告 Codex CLI 一直显示 Working、不完成；也有人报告在终端命令执行期间挂住。([GitHub](https://github.com/openai/codex/issues/16166?utm_source=chatgpt.com "\"Working\" hangs forever · Issue #16166 · openai/codex"))

还有用户报告在 Windows/WSL 环境下所有 prompt 都卡住，没有 response。([GitHub](https://github.com/openai/codex/issues/14048?utm_source=chatgpt.com "models — Codex CLI hangs indefinitely on all prompts, no ..."))

所以结论是：

> Codex 卡住不是罕见现象。它可能是任务复杂，也可能是 CLI / extension / sandbox / tool-call 层的问题。

---

## 6. 上下文太乱，导致它“思考过度”

如果一个 session 里堆了太多东西：

- 多轮修改
    
- 多个方向切换
    
- 大量日志
    
- 大量失败命令
    
- 多个任务混在一起
    
- 让它同时做 PRD、issue、代码、测试、文档
    

Codex 会越来越难判断下一步。表现就是：

- 迟迟不动手
    
- 反复读文件
    
- 重复运行命令
    
- 进入无效探索
    
- 不知道什么时候该停止
    

这类不是系统卡死，而是 agent planning 失控。

---

# 我建议你这样排查

## 第一优先级：看它卡在哪一层

你可以直接问 Codex：

```text
你现在卡在哪一步？不要继续执行命令，只总结当前状态、上一个命令、等待的原因。
```

如果它能回答，说明不是完全卡死，是任务规划或命令等待。

如果它不能回答，直接 `Esc` / interrupt。

---

## 第二优先级：禁止它跑长期命令

给 Codex 加这种约束：

```text
不要运行长期驻留命令，例如 npm run dev、playwright open、watch、serve。
所有命令必须加超时或只做一次性检查。
如果需要启动服务，先告诉我命令，由我手动运行。
```

尤其避免让它自己执行：

```bash
npm run dev
vite --host
next dev
playwright open
tail -f
watch
```

这些天然不会退出。

---

## 第三优先级：把任务切小

不要这样说：

```text
帮我完成这个功能，从需求到实现到测试全部做完。
```

改成：

```text
第一步：只阅读相关代码，找出需要改的文件，不要修改。
第二步：给出最小实现方案。
第三步：只修改核心逻辑。
第四步：只跑最小验证命令。
```

Codex 更适合：

> 小步规划 → 小步修改 → 小步验证

不适合一次性吞一个大 workflow。

---

## 第四优先级：明确停止条件

你可以在 prompt 里写：

```text
如果连续 2 次命令失败，停止，不要继续尝试。
如果一个命令超过 60 秒没有输出，停止并告诉我。
不要自动安装大型依赖。
不要递归扫描整个仓库。
```

这能显著减少“越跑越深”的情况。

---

# 一个更稳的 Codex 使用模板

你可以直接复制：

```text
请按小步执行，不要一次性完成全部任务。

规则：
1. 先只分析，不要改文件。
2. 列出你需要查看的文件和原因。
3. 不要运行长期驻留命令，例如 npm run dev、watch、serve、playwright open。
4. 所有命令都必须是短命令，预期 60 秒内结束。
5. 如果命令卡住、需要联网、需要权限、需要人工输入，立刻停止并说明。
6. 不要递归扫描整个仓库，只看与任务直接相关的文件。
7. 每完成一个阶段，先总结当前状态，再等我确认下一步。
```

如果是改代码：

```text
目标：实现 XXX。

执行方式：
第一阶段：只定位代码，不修改。
第二阶段：给出最小修改方案。
第三阶段：只改必要文件。
第四阶段：只跑最小验证命令。

限制：
- 不要运行 npm run dev / watch / serve。
- 不要全量测试，优先跑单测或类型检查。
- 如果需要安装依赖，先询问。
- 如果连续两次验证失败，停止并总结原因。
```

---

# 我的判断

你遇到的“经常卡住”，大概率不是单一原因，而是这几个叠加：

1. **Codex 经常调用不会自然退出的命令**
    
2. **sandbox / approval / 网络权限导致命令半失败半等待**
    
3. **任务粒度太大，agent loop 进入长时间探索**
    
4. **Codex CLI/extension 自身确实存在 hang 类 bug**
    

对于你这种用法——PRD、issue、skills、Playwright、Claude/Codex/OpenClaw 混合 workflow——最关键的不是换模型，而是给 Codex 加“执行边界”。

一句话：

> Codex 不是怕大任务，而是怕“没有边界的大任务 + 可能不退出的命令 + 需要权限的工具链”。

你应该把它当成一个**可控执行器**，不是完全自治的后台工程师。