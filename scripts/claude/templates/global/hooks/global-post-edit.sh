#!/bin/bash
# ============================================
# Claude Code 全局 Post-Edit Hook
# 放置: ~/.claude/hooks/global-post-edit.sh
# 触发: 每次 Edit/Write 工具调用后
# chmod +x ~/.claude/hooks/global-post-edit.sh
# ============================================

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

changed=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

if [ "$changed" -gt 0 ] || [ "$staged" -gt 0 ]; then
  echo ""
  echo "  Git: ${staged} staged, ${changed} unstaged"
  echo ""
fi

exit 0
