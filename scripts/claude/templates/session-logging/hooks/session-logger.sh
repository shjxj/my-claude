#!/bin/bash
# =============================================================================
# session-logger.sh — Claude Code 会话自动记录脚本
#
# 由 PostToolUse/Stop hook 触发，将 Skill/Agent 执行结果路由写入日志文件。
# 用法: session-logger.sh skill|agent|summary
# stdin 接收 Hook 传入的 JSON
# =============================================================================

set -euo pipefail

MODE="${1:-skill}"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
LOG_DIR="$PROJECT_ROOT/docs/sessions/$DATE"
INDEX_FILE="$LOG_DIR/_index.md"

mkdir -p "$LOG_DIR"

# ── 读取 stdin ──
INPUT=$(cat)

# ── JSON 解析：优先 jq，其次 python3 ──
json_value() {
    local key="$1"
    local default="${2:-}"
    if command -v jq &>/dev/null; then
        echo "$INPUT" | jq -r ".$key // \"$default\"" 2>/dev/null || echo "$default"
    elif command -v python3 &>/dev/null; then
        echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    keys = '$key'.split('.')
    val = d
    for k in keys:
        val = val.get(k, None)
        if val is None: break
    if val is None:
        print('$default')
    elif isinstance(val, str):
        print(val)
    else:
        print(json.dumps(val, ensure_ascii=False))
except:
    print('$default')
"
    else
        echo "$default"
    fi
}

# ── 提取 Skill 名称 ──
extract_skill_name() {
    local tool_name
    tool_name=$(json_value "tool_name" "unknown")

    if [ "$tool_name" = "Skill" ]; then
        json_value "tool_input.skill" "unknown-skill"
    elif [ "$tool_name" = "Agent" ]; then
        local agent_type
        agent_type=$(json_value "tool_input.subagent_type" "unknown-agent")
        echo "agent:$agent_type"
    else
        echo "$tool_name"
    fi
}

# ── 写入索引文件 ──
append_index() {
    local skill="$1"
    if [ ! -f "$INDEX_FILE" ]; then
        {
            echo "# 会话索引 — $DATE"
            echo ""
            echo "| 时间 | 命令 | 文件 |"
            echo "|------|------|------|"
        } > "$INDEX_FILE"
    fi
    local target_file
    target_file=$(route_target "$skill")
    local basename_file
    basename_file=$(basename "$target_file")
    echo "| $TIME | \`$skill\` | [$basename_file]($basename_file) |" >> "$INDEX_FILE"
}

# ── 路由：skill → 目标文件路径 ──
route_target() {
    local skill="$1"

    case "$skill" in
        *brainstorming*|*office-hours*)
            echo "$LOG_DIR/01-brainstorming.md" ;;
        *plan-ceo-review*)
            echo "$LOG_DIR/02-strategy.md" ;;
        *plan-eng-review*|*plan-design-review*|*design-review*|*architect*)
            echo "$LOG_DIR/03-architecture.md" ;;
        *writing-plans*|*planning-with-files:plan*|*make-plan*|*writing-plan*)
            echo "$LOG_DIR/04-plan.md" ;;
        *test-driven-development*|*tdd-workflow*|*tdd*)
            echo "$LOG_DIR/05-tdd.md" ;;
        *code-review*|*code-reviewer*|*requesting-code-review*|*receiving-code-review*|*review-pr*)
            echo "$LOG_DIR/06-review.md" ;;
        *verification-before-completion*|*verification*|*verify*)
            echo "$LOG_DIR/07-verification.md" ;;
        *security-review*|*security-scan*|*security-bounty*|*security*)
            echo "$LOG_DIR/08-security.md" ;;
        *ralph-loop*|*loop-start*|*autonomous-loop*)
            echo "$LOG_DIR/09-loop.md" ;;
        *)
            echo "$LOG_DIR/10-session-log.md" ;;
    esac
}

# ── 追加 Skill 输出到目标文件 ──
append_output() {
    local target="$1"
    local tool_name
    tool_name=$(json_value "tool_name" "unknown")

    if [ ! -f "$target" ]; then
        local heading
        heading=$(basename "$target" .md)
        {
            echo "# $heading"
            echo ""
            echo "> 日期：$DATE"
            echo ""
            echo "---"
            echo ""
        } > "$target"
    fi

    {
        echo "## $tool_name — $TIME"
        echo ""
        echo "\`\`\`json"
        json_value "tool_output" "(无输出)" | head -c 8000
        echo ""
        echo "\`\`\`"
        echo ""
        echo "---"
        echo ""
    } >> "$target"
}

# ── 生成会话摘要 ──
generate_summary() {
    local reason
    reason=$(json_value "tool_input.reason" "用户退出")

    {
        echo "# 会话摘要 — $DATE $TIME"
        echo ""
        echo "> 结束原因：$reason"
        echo ""
        echo "## 本日文件"
        echo ""
        if [ -d "$LOG_DIR" ]; then
            ls -1 "$LOG_DIR" 2>/dev/null | while read -r f; do
                echo "- [$f]($f)"
            done
        fi
        echo ""
        echo "## 待办提醒"
        echo ""
        echo "下次会话开始时 AI 会读取此文件和索引。"
        echo ""
    } >> "$LOG_DIR/_summary.md"
}

# =============================================================================
# 主逻辑
# =============================================================================

case "$MODE" in
    skill|agent)
        SKILL=$(extract_skill_name)
        TARGET=$(route_target "$SKILL")
        append_index "$SKILL"
        append_output "$TARGET"
        ;;
    summary)
        generate_summary
        ;;
    *)
        echo "用法: session-logger.sh skill|agent|summary"
        exit 1
        ;;
esac
