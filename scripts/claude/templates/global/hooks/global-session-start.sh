#!/bin/bash
# ============================================
# Claude Code 会话结束 Hook
# 放置: ~/.claude/hooks/global-session-start.sh
# 触发: 每次会话结束时 (SessionEnd)
# chmod +x ~/.claude/hooks/global-session-start.sh
# ============================================

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

echo ""
echo "---"

# Git 仓库状态
if git rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null)
  ahead=$(git rev-list --count origin/"$branch"..HEAD 2>/dev/null || echo "?")
  behind=$(git rev-list --count HEAD..origin/"$branch" 2>/dev/null || echo "?")

  echo "  分支: $branch | ahead: $ahead | behind: $behind"

  changed=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  if [ "$changed" -gt 0 ] || [ "$staged" -gt 0 ] || [ "$untracked" -gt 0 ]; then
    echo "  unstaged: $changed | staged: $staged | untracked: $untracked"
  fi
fi

echo "---"
echo ""

exit 0
