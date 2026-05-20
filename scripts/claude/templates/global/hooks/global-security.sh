#!/bin/bash
# ============================================
# Claude Code 全局安全 Hook
# 放置: ~/.claude/hooks/global-security.sh
# 触发: 每次 Bash 工具调用前 (PreToolUse)
# 返回: 0=允许, 1=阻止
# chmod +x ~/.claude/hooks/global-security.sh
# ============================================

input="$CLAUDE_TOOL_ARGUMENT"

# ---------- 高危命令（直接阻止）----------
declare -a fatal_patterns=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf ."
  "> /dev/sda"
  "dd if=.*of=/dev/"
  "mkfs\."
  "curl.*\|.*sh"
  "wget.*\|.*bash"
  "chmod 777 /"
  "chmod -R 777 /"
  "shutdown -h now"
  "reboot"
  ":\(\) { :\|:& };:"
)

for pattern in "${fatal_patterns[@]}"; do
  if echo "$input" | grep -qiE "$pattern"; then
    echo "⛔ [安全] 高危操作被阻止: 匹配 '$pattern'"
    exit 1
  fi
done

# ---------- 数据库危险操作（警告不阻止）----------
declare -a db_danger=(
  "DROP DATABASE"
  "DROP TABLE"
  "TRUNCATE TABLE"
  "DELETE FROM"
)

phrases=""
for pattern in "${db_danger[@]}"; do
  if echo "$input" | grep -qi "$pattern"; then
    phrases="$phrases  $pattern"
  fi
done

if [ -n "$phrases" ]; then
  echo "⚠️  [安全] DDL/DML 危险操作:$phrases"
  if ! echo "$input" | grep -qi "WHERE"; then
    echo "⚠️  [安全] DELETE 无 WHERE — 会清空全表"
  fi
fi

# ---------- Git 危险操作 ----------
if echo "$input" | grep -qiE "git (push|reset) .*--force"; then
  echo "⚠️  [安全] git force — 可能覆盖远端历史"
fi

if echo "$input" | grep -qiE "git (reset|checkout) .*--hard"; then
  echo "⚠️  [安全] git hard reset — 未提交改动永久丢失"
fi

# ---------- 敏感信息泄露检查 ----------
if echo "$input" | grep -qiE "(API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE_KEY)="; then
  if ! echo "$input" | grep -qiE '\$'; then
    echo "🔐 [安全] 疑似硬编码敏感信息，建议用环境变量"
  fi
fi

exit 0
