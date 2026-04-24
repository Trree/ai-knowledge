# 我用 110 行脚本治好了 Claude Code 的「Skill 囤积症」

上周我打开 Claude Code，输入一个简单的问题，等了 3 秒才出结果。

不是网络慢，是 system prompt 里塞了 **47 个 skill 的描述**。每一次对话，模型都要先"看"一遍这 47 段文字，然后才开始想我的问题。

我突然意识到：我把 Claude Code 养成了一个塞满杂物的抽屉。

## 问题出在哪？不是 skill 太多，是你不知道在用哪些

打开 `~/.claude/skills/` 目录，47 个文件夹整整齐齐。我试着回忆每个 skill 的用途——大概到第 15 个就放弃了。

有些是半年前看到别人推荐随手装的，有些是为了某个项目临时装的，还有几个功能高度重叠的（比如我有两个图片生成 skill，至今分不清该用哪个）。

这种感觉很熟悉。就像你打开手机，200 个 App，真正每周打开的不超过 20 个。但你不会删，因为——"万一以后用到呢？"

**这就是 skill 膨胀的本质：不是数量问题，是治理缺位。**

你不知道哪些在用，不知道哪些重叠，不知道哪些已经废弃。更隐蔽的代价是，模型的注意力被稀释了——它要在 47 个 skill 描述里做"心智路由"，这 30 秒的思考时间，有一部分浪费在了你根本不会用的 skill 上。

## 一个念头：能不能让 Claude Code 自己追踪 skill 用量？

Claude Code 有一个被严重低估的能力——**Hook 框架**。

简单说，它允许你在特定事件发生时自动执行一段脚本。比如：

- 每当一个 skill 被调用（`PostToolUse` 事件），触发你的脚本
- 你的脚本记录下 skill 名称、时间、参数
- 积累一段时间后，你就有了一份"skill 使用报告"

听起来不复杂？实际写下来，确实不复杂。但有几个坑，我替你踩过了。

## 踩坑实录：Hook payload 的三个意外

在动手写脚本之前，我先搞清楚了一个关键问题：**Hook 到底会传什么数据给我的脚本？**

当一个 skill 执行完毕，Claude Code 会通过 stdin 传一个 JSON 给你的 Hook 脚本：

```json
{
  "session_id": "abc123",
  "tool_name": "Skill",
  "tool_input": { "skill": "ljg-card", "args": "-l" },
  "tool_output": "...(执行结果)...",
  "cwd": "/path/to/project",
  "project_root": "/path/to/project"
}
```

看起来信息很全？但有三个坑：

**坑 1：字段名不是你以为的那样。** skill 名称在 `.tool_input.skill`，不是 `.tool_input.skill_name`。写错了不会报错，只会静默拿到空值——你以为在记录，其实什么都没记到。

**坑 2：`tool_output` 可能非常大。** 有些 skill 的输出是几十 KB 的文本。如果你天真地把整个 payload 存下来，日志文件几天就能涨到几百 MB。正确做法：只记录 output 的长度，不记内容。

**坑 3：没有时间戳。** 是的，payload 里不含时间。你必须在脚本里自己用 `date` 命令生成。

还有一个硬约束：**Hook 脚本必须在 10 秒内执行完**，超时会被强制终止。所以采集脚本里不能做任何计算，只能"收到数据→提取字段→写文件→退出"。

这些坑看起来是限制，但它们实际上逼出了一个很干净的架构：**采集和分析必须分离**。采集脚本只管记录，分析脚本离线运行。

## 完整方案：4 个文件，30 分钟搞定

想通了架构，代码就很简单。整个方案只有 4 个文件：

```
~/.claude/
├── settings.json          ← 追加一段 Hook 配置
├── hooks/
│   ├── skill-tracker.sh   ← 采集脚本（20行）
│   ├── skill-audit.sh     ← 审查脚本（70行）
│   └── skill-remind.sh    ← 提醒脚本（20行）
└── skill-logs/            ← 自动生成的日志目录
```

### 第一步：注册 Hook（1 分钟）

在 `~/.claude/settings.json` 中追加：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Skill",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/skill-tracker.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

意思是：每当任何 skill 执行完毕，自动调用 `skill-tracker.sh`。

### 第二步：采集脚本（5 分钟）

```bash
#!/bin/bash
# ~/.claude/hooks/skill-tracker.sh
set -euo pipefail

INPUT=$(cat -)
SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // "unknown"')
ARGS=$(echo "$INPUT" | jq -r '.tool_input.args // ""' | head -c 200)
SESSION=$(echo "$INPUT" | jq -r '.session_id // ""')
PROJECT=$(echo "$INPUT" | jq -r '.project_root // ""')
TS=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
OUT_LEN=$(echo "$INPUT" | jq '.tool_output | length')

LOGDIR="$HOME/.claude/skill-logs"
mkdir -p "$LOGDIR"
printf '{"ts":"%s","skill":"%s","args":"%s","session":"%s","project":"%s","output_len":%s}\n' \
  "$TS" "$SKILL" "$ARGS" "$SESSION" "$PROJECT" "$OUT_LEN" \
  >> "$LOGDIR/usage-$(date +%Y%m).jsonl"
```

几个设计细节：

- 参数截断到 200 字符，防止异常长参数撑爆日志
- 按月分文件（`usage-202604.jsonl`），天然自带日志轮转
- 用 `printf` 而不是 `echo`，避免特殊字符问题
- `set -euo pipefail` 确保任何一步出错就停止，不写入脏数据

到这里，系统就"活"了。每用一次 skill，就自动多一行记录。你什么都不用改变，照常使用就行。

### 第三步：审查脚本（10 分钟）

攒了一两周数据后，运行这个脚本看看真相：

```bash
#!/bin/bash
# ~/.claude/hooks/skill-audit.sh
set -euo pipefail

DAYS=${1:-30}
LOGDIR="$HOME/.claude/skill-logs"

echo "======================================"
echo " Skill 使用审查报告（最近 ${DAYS} 天）"
echo "======================================"

CUTOFF=$(date -d "-${DAYS} days" -Iseconds 2>/dev/null || \
         date -v-${DAYS}d -Iseconds 2>/dev/null || echo "1970-01-01")

echo ""
echo "▶ 使用频次排行:"
cat "$LOGDIR"/usage-*.jsonl 2>/dev/null | \
  jq -r --arg c "$CUTOFF" 'select(.ts >= $c) | .skill' | \
  sort | uniq -c | sort -rn | head -20

INSTALLED=$(ls -1 "$HOME/.claude/skills/" 2>/dev/null || echo "")
USED=$(cat "$LOGDIR"/usage-*.jsonl 2>/dev/null | \
  jq -r --arg c "$CUTOFF" 'select(.ts >= $c) | .skill' | sort -u)

echo ""
echo "▶ 零调用 skill:"
ZERO=0
for s in $INSTALLED; do
  if ! echo "$USED" | grep -q "^${s}$"; then
    echo "   ✗ $s"
    ZERO=$((ZERO + 1))
  fi
done
[ "$ZERO" -eq 0 ] && echo "   (无)"

echo ""
echo "▶ 使用模式 Top 10 (skill + 参数):"
cat "$LOGDIR"/usage-*.jsonl 2>/dev/null | \
  jq -r --arg c "$CUTOFF" 'select(.ts >= $c) | "\(.skill) \(.args)"' | \
  sort | uniq -c | sort -rn | head -10

TOTAL=$(echo "$INSTALLED" | wc -w)
ACTIVE=$(echo "$USED" | wc -w)
echo ""
echo "======================================"
echo " 已安装 ${TOTAL} | 活跃 ${ACTIVE} | 零调用 ${ZERO}"
RATE=$(( ZERO * 100 / (TOTAL > 0 ? TOTAL : 1) ))
echo " 膨胀率: ${RATE}%"
echo "======================================"
```

我第一次运行的时候，结果挺扎心的：47 个 skill，过去 30 天只用了 11 个。膨胀率 **76%**。

更有趣的是"使用模式"那一栏。我发现自己用 `ljg-card` 时几乎只用 `-l` 参数，从来没用过 `-v` 和 `-c`。这让我意识到：我以为自己需要的功能，和实际使用的功能之间有巨大鸿沟。

### 第四步（可选）：定期提醒

这是给"知道该整理但总是忘记"的人准备的：

```bash
#!/bin/bash
# ~/.claude/hooks/skill-remind.sh
LOGDIR="$HOME/.claude/skill-logs"
STATE_FILE="$LOGDIR/.last-audit"

if [ -f "$STATE_FILE" ]; then
  LAST=$(cat "$STATE_FILE")
  NOW=$(date +%s)
  LAST_TS=$(date -d "$LAST" +%s 2>/dev/null || echo 0)
  DIFF=$(( (NOW - LAST_TS) / 86400 ))
else
  DIFF=999
fi

if [ "$DIFF" -ge 14 ]; then
  TOTAL=$(ls -1 "$HOME/.claude/skills/" 2>/dev/null | wc -w)
  echo ""
  echo "  ┌─────────────────────────────────────┐"
  echo "  │  距上次 Skill 审查已过 ${DIFF} 天        │"
  echo "  │  已安装: ${TOTAL} 个                     │"
  echo "  │  运行: bash ~/.claude/hooks/skill-audit.sh │"
  echo "  └─────────────────────────────────────┘"
fi
# 审查完毕后执行：date -Iseconds > ~/.claude/skill-logs/.last-audit
```

它不会自动删除任何东西，只是在你超过两周没做审查时，温柔地推你一把。

## 我从中学到的四件事

写完这套东西，真正的收获不是代码本身，而是过程中想明白了几个道理：

**1. 先有数据，再有策略。**

在看到审查报告之前，我以为自己"大部分 skill 都在用"。数据告诉我只有 24% 是活跃的。没有度量，所有的管理决策都是凭感觉。

**2. 自动化的最高境界不是替你做事，是在正确的时刻推你一把。**

我一开始想做"自动检测不用的 skill 并删除"。后来意识到这很危险——万一那个 skill 只是最近没用，下个月的项目就需要呢？正确的做法是让数据摆在你面前，由你来判断。提醒脚本做的就是这件事：不替你决策，但绝不让你逃避决策。

**3. 工具的约束反而是好事。**

Hook 的 10 秒超时、PostToolUse 无法控制执行流、payload 里没有时间戳——这些限制看起来是缺陷，但它们逼着我把采集和分析分离，写出了更简洁、更不容易出错的架构。如果 Hook 什么都能做，我可能会写一个 500 行的全能脚本，然后在某天凌晨它把我重要的 skill 给删了。

**4. 管理工具的复杂性不能超过它所解决的问题。**

110 行脚本、4 个文件、30 分钟部署。如果为了管理 skill 膨胀，我搭了一个带数据库、带 Web 界面、带自动清理的平台——那"管理工具"本身就变成了新的膨胀。

## 这套方案还缺什么？

坦诚说，有三个问题我还没解决：

**语义重叠检测。** 我有两个图片生成 skill，数据显示两个都在用，但其实它们功能几乎一样。纯粹靠调用频次无法发现这种重叠。也许可以用 LLM 去比对 skill 的描述文本——但这是 Day 90 的课题了。

**主动拦截。** 目前只是"事后观测"。如果想在调用一个已废弃的 skill 时弹出警告，需要用 `PreToolUse` Hook 返回 `{"decision": "block", "reason": "建议用 X 替代"}`。但这需要先积累数据确认"哪些该拦"，不能一上来就写规则。

**上下文优化。** 最理想的方案是根据使用数据动态裁剪 system prompt 里的 skill 描述——低频 skill 不加载，按需注入。这需要 Claude Code 平台级的支持，Hook 做不到。

不过，80% 的收益来自最简单的那 20% 的投入。**光是"知道自己在用什么"这一步，就已经比 99% 的人强了。**

---

如果你也被 skill 列表的长度压得喘不过气，不妨从最简单的一步开始——装上采集脚本，跑两周，然后看看那份审查报告。

你可能会像我一样，对着 76% 的膨胀率沉默很久，然后默默开始删东西。
