## 一句话结论

**业界已收敛到一个出人意料的简单答案：强推理模型 + 简单工具调用循环（Simple Tool-Calling Loop）。**

这不是某个学术模式"胜出"，而是复杂架构被证明不必要。[[Claude Code]]

## 当前最佳模式：Augmented LLM Loop
Anthropic 在 2024 年 12 月发表的 **"Building Effective Agents"** 给出了最清晰的表述：

```python
# 整个"agent架构"就是一个 while 循环
while not done:
    response = model.generate(messages, tools=available_tools)
    if response.has_tool_calls:
        for tool_call in response.tool_calls:
            result = execute_tool(tool_call)
            messages.append(tool_result(result))
    else:
        done = True
```

## 为什么简单循环胜出？——性能决定因素排序

业界已达成共识的优先级排序：

```
影响力排序（从大到小）：

1. 模型能力          ████████████████████  ← 远远最重要
2. 工具设计          ████████████         ← 第二重要
3. System Prompt     ████████             ← 第三
4. Context 管理      ██████               ← 第四
5. 架构复杂度        ██                   ← 最不重要
```

**Devin 是最好的反面教材**：它架构最复杂（规划+执行+反思+记忆），2024 年初曾短暂领先 SWE-bench，但很快被用更强模型的简单循环超越。这验证了 Richard Sutton 的 **"Bitter Lesson"**（苦涩教训）：利用计算的通用方法（更强的模型）总是打败精巧的特定方法（复杂架构）。

## 结论：不是选"最佳模式"，而是接受"模式不重要"

业界的真正共识不是"X 模式最好"，而是：

> **Agent 的性能瓶颈不在架构，在模型。把精力花在工具设计和 Prompt 工程上，用最简单的循环，配最强的模型。**

如果你正在构建 Coding Agent，最佳实践是：

1. 用最强的可用模型 + extended thinking
2. 设计好工具（清晰的描述、好的错误信息、合适的粒度）
3. 写好 system prompt
4. 实现 context 管理（长会话压缩、相关代码检索）
5. 用最简单的 while 循环
6. **只有当简单方案被证明不够时**，才考虑加规划、反思、多代理