#!/usr/bin/env bash
# =============================================================================
# Claude Code 增强工具一键安装脚本（幂等 — 可安全重复运行）
# 基于 CLAUDE.md 中推荐的插件和技能列表
# 使用方法: bash scripts/install.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"
INFO="${BLUE}→${NC}"

TOTAL=0; SUCCESS=0; SKIPPED=0; FAILED=0
MANUAL_STEPS=()

# =============================================================================
# 工具函数
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
}

print_step() {
    TOTAL=$((TOTAL + 1))
    echo ""
    echo -e "${INFO} [$TOTAL] $1..."
}

mark_success() { SUCCESS=$((SUCCESS + 1)); echo -e "    ${PASS} $1"; }
mark_skip()    { SKIPPED=$((SKIPPED + 1)); echo -e "    ${WARN} $1"; }
mark_fail()    { FAILED=$((FAILED + 1));   echo -e "    ${FAIL} $1"; MANUAL_STEPS+=("$1"); }

check_command() {
    if command -v "$1" &>/dev/null; then
        echo -e "    ${PASS} $1: $($1 --version 2>&1 | head -1)"
        return 0
    else
        echo -e "    ${FAIL} $1 未安装"
        return 1
    fi
}

# 检查 Claude Code 插件是否已安装
is_plugin_installed() {
    claude plugin list 2>/dev/null | grep -qi "$1" 2>/dev/null
}

# 检查 npm 全局包是否已安装
is_npm_installed() {
    npm list -g "$1" --depth=0 2>/dev/null | grep -q "$1"
}

# 安装 Claude Code 插件（带幂等检查）
install_plugin() {
    local plugin_name="$1"
    local search_key="${2:-$1}"  # 用于检查是否已安装的搜索关键词

    if is_plugin_installed "$search_key"; then
        mark_success "$plugin_name 已安装，跳过"
        return 0
    fi

    if claude plugin install "$plugin_name" 2>&1; then
        mark_success "$plugin_name 安装成功"
        return 0
    fi

    return 1
}

# git clone 带重试和幂等检查
clone_with_retry() {
    local repo_url="$1"
    local target_dir="$2"
    local max_retries="${3:-3}"

    if [ -d "$target_dir" ]; then
        echo -e "    ${INFO} 目录已存在: $target_dir"
        cd "$target_dir"
        if git pull --ff-only 2>&1; then
            return 0
        fi
        echo -e "    ${WARN} 更新失败，重新克隆..."
        cd "$(dirname "$target_dir")"
        rm -rf "$(basename "$target_dir")"
    fi

    for i in $(seq 1 "$max_retries"); do
        echo -e "    ${INFO} 尝试 $i/$max_retries..."
        if git clone --single-branch --depth 1 "$repo_url" "$target_dir" 2>&1; then
            return 0
        fi
        if [ "$i" -lt "$max_retries" ]; then
            echo -e "    ${WARN} 克隆失败，等待 ${i}0 秒后重试..."
            sleep "${i}0"
        fi
    done

    return 1
}

# =============================================================================
# 预检
# =============================================================================

print_header "环境预检"

HAS_CLAUDE=true; HAS_GIT=true; HAS_BUN=true; HAS_XCODE=true

check_command claude || HAS_CLAUDE=false
check_command git    || HAS_GIT=false
check_command bun    || HAS_BUN=false

# bun 未安装时自动安装（GStack 的 setup 脚本依赖 bun）
if [ "$HAS_BUN" = false ]; then
    echo ""
    echo -e "    ${INFO} bun 未安装，正在自动安装（GStack 依赖）..."
    if curl -fsSL https://bun.sh/install | bash 2>&1; then
        # 安装脚本会将 bun 加到 ~/.bashrc / ~/.zshrc，在当前 shell 中手动加载
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        if command -v bun &>/dev/null; then
            echo -e "    ${PASS} bun 安装成功: $(bun --version 2>&1)"
            HAS_BUN=true
        else
            echo -e "    ${WARN} bun 已安装但当前 shell 未加载，后续步骤将使用完整路径"
            [ -f "$HOME/.bun/bin/bun" ] && HAS_BUN=true
        fi
    else
        echo -e "    ${FAIL} bun 自动安装失败，GStack 将跳过"
        HAS_BUN=false
    fi
fi

# Xcode CLI 工具检查（EZVibe 等需要原生编译的包依赖）
if xcode-select -p &>/dev/null; then
    echo -e "    ${PASS} Xcode CLI: $(xcode-select -p 2>&1)"
else
    echo -e "    ${WARN} Xcode CLI 未安装（EZVibe 等需要原生编译的包将跳过）"
    HAS_XCODE=false
fi

[ "$HAS_CLAUDE" = false ] && { echo -e "\n${RED}错误: 请先安装 Claude Code${NC}\n  https://docs.anthropic.com/en/docs/claude-code"; exit 1; }
[ "$HAS_GIT" = false ]    && { echo -e "\n${RED}错误: 请先安装 Git${NC}"; exit 1; }

echo ""
echo -e "${GREEN}预检通过，开始安装...${NC}"

# =============================================================================
# 1. Superpowers
# =============================================================================

print_header "核心开发技能"

print_step "Superpowers（标准开发流水线）"
install_plugin "superpowers@claude-plugins-official" "superpowers" || \
    mark_fail "Superpowers 安装失败（请在 Claude Code 中执行: /plugin install superpowers@claude-plugins-official）"

# =============================================================================
# 2. GStack
# =============================================================================

print_step "GStack（多角色 AI 工程团队）"
GSTACK_DIR="$HOME/.claude/skills/gstack"

# 确保 bun 在 PATH 中（bun 可能刚安装或安装在非标准路径）
if ! command -v bun &>/dev/null && [ -f "$HOME/.bun/bin/bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [ -z "$(command -v bun)" ]; then
    mark_fail "GStack 安装失败 — bun 未安装（GStack 依赖 bun）"
    MANUAL_STEPS+=("安装 bun: curl -fsSL https://bun.sh/install | bash")
else

# 优先使用本地已有副本（避免大仓库网络 clone 失败）
LOCAL_GSTACK=""
for candidate in "/opt/devs/projects/claude/gstack" "$PWD/gstack" "$(dirname "$0")/../gstack"; do
    if [ -d "$candidate/.git" ] && [ -f "$candidate/setup" ]; then
        LOCAL_GSTACK="$candidate"
        break
    fi
done

if [ -d "$GSTACK_DIR/.git" ]; then
    # 已安装，尝试更新
    echo -e "    ${INFO} 已安装，尝试更新..."
    cd "$GSTACK_DIR"
    if git pull --ff-only 2>&1; then
        ./setup 2>&1 || true
        mark_success "GStack 更新成功"
    else
        mark_success "GStack 已安装（更新失败，网络可能不稳定，不影响使用）"
    fi
elif [ -n "$LOCAL_GSTACK" ]; then
    # 从本地副本复制，避免网络问题
    echo -e "    ${INFO} 从本地副本复制: $LOCAL_GSTACK"
    mkdir -p "$(dirname "$GSTACK_DIR")"
    if cp -R "$LOCAL_GSTACK" "$GSTACK_DIR" 2>&1; then
        cd "$GSTACK_DIR"
        ./setup 2>&1
        mark_success "GStack 安装成功（从本地副本）"
    else
        mark_fail "GStack 复制失败"
    fi
else
    # 无本地副本，从 GitHub 克隆（带重试）
    echo -e "    ${INFO} 从 GitHub 克隆（最多重试 3 次）..."
    if clone_with_retry "https://github.com/garrytan/gstack.git" "$GSTACK_DIR" 3; then
        cd "$GSTACK_DIR" && ./setup 2>&1
        mark_success "GStack 安装成功"
    else
        mark_fail "GStack 安装失败（网络问题，可稍后重试）"
    fi
fi  # inner: GSTACK_DIR 状态检查
fi  # outer: bun 是否可用

# =============================================================================
# 3. Code Review
# =============================================================================

print_step "Code Review（多维度代码审查）"
CODEREVIEW_DIR="$HOME/.claude/skills/code-review"
if [ -d "$CODEREVIEW_DIR" ] && [ -f "$CODEREVIEW_DIR/SKILL.md" ]; then
    mark_success "Code Review skill 已安装，跳过"
else
    if [ -d "$CODEREVIEW_DIR" ]; then
        echo -e "    ${INFO} 目录存在但无 SKILL.md，尝试重新克隆..."
        rm -rf "$CODEREVIEW_DIR"
    fi
    if git clone --depth 1 https://github.com/codihaus/claude-skills.git "$CODEREVIEW_DIR" 2>&1; then
        mark_success "Code Review 安装成功"
    else
        mark_fail "Code Review 安装失败（Claude Code 已内置代码审查能力，不影响使用。如需增强: 将 SKILL.md 放入 ~/.claude/skills/code-review/）"
    fi
fi

# =============================================================================
# 4. Security Guidance
# =============================================================================

print_step "Security Guidance（安全编码助手）"
echo -e "    ${INFO} Claude Code 内置能力，安全约束已写入项目 CLAUDE.md"
mark_success "Security Guidance（内置）"

# =============================================================================
# 5. claude-mem
# =============================================================================

print_header "长期记忆"

print_step "claude-mem（跨会话长期记忆）"
if [ -d "$HOME/.claude-mem" ] || is_plugin_installed "claude-mem"; then
    mark_success "claude-mem 已安装，跳过"
else
    if npx --yes claude-mem install 2>&1; then
        mark_success "claude-mem 安装成功"
    else
        mark_fail "claude-mem 安装失败（可手动执行: npx claude-mem install）"
    fi
fi

# =============================================================================
# 6. frontend-design
# =============================================================================

print_header "领域专项技能"

print_step "frontend-design（前端 UI 设计）"
install_plugin "frontend-design@claude-plugins-official" "frontend-design" || \
    mark_fail "frontend-design 安装失败（请在 Claude Code 中执行: /plugin install frontend-design）"

# =============================================================================
# 7. Agent Browser — 注意: 此名称不存在于 Claude Code 插件市场
# =============================================================================

print_step "Agent Browser（浏览器自动化）"
# GStack 已内置 /browse 技能（headless Chromium），与 Agent Browser 功能完全重叠
# Claude Code 插件市场中没有 "agent-browser" 这个独立插件
if [ -d "$GSTACK_DIR" ] && [ -f "$GSTACK_DIR/browse/SKILL.md" ]; then
    mark_success "已有 GStack /browse（功能等同于 Agent Browser），跳过"
else
    echo -e "    ${INFO} Claude Code 插件市场中无 'agent-browser' 插件"
    echo -e "    ${INFO} GStack 内置的 /browse 技能提供等效的浏览器自动化能力"
    mark_skip "Agent Browser（用 GStack /browse 替代）"
fi

# =============================================================================
# 8. GitHub 集成 — 使用 Claude Code 内置方式
# =============================================================================

print_step "GitHub 集成（仓库管理）"
# Claude Code 的 GitHub 集成是内置的，通过 OAuth 或 gh CLI 配置
# "github-mcp" 不是 Claude Code 插件市场中的独立插件
if gh auth status 2>/dev/null; then
    mark_success "GitHub CLI (gh) 已认证，Claude Code 会自动使用"
elif claude mcp list 2>/dev/null | grep -qi "github"; then
    mark_success "GitHub MCP 已配置，跳过"
else
    mark_fail "GitHub 集成需手动配置（在 Claude Code 中执行 /github 进行 OAuth 授权，或在终端执行: gh auth login）"
fi

# =============================================================================
# 9. Supabase
# =============================================================================

print_step "Supabase 技能"
echo -e "    ${INFO} 需通过官方市场安装后按 MCP 指引配置连接"
mark_skip "Supabase（需手动安装: 在 Claude Code 中执行 /plugin install supabase）"

# =============================================================================
# 10. Skill Creator（内置）
# =============================================================================

print_step "Skill Creator（自定义技能创建）"
echo -e "    ${INFO} Claude Code 内置能力，在对话中描述需求即可"
mark_success "Skill Creator（内置）"

# =============================================================================
# 11. Everything Claude Code
# =============================================================================

print_step "Everything Claude Code（181 技能合集）"
mark_skip "Everything Claude Code（需手动安装，查阅 https://github.com/Everything-Claude-Code）"

# =============================================================================
# 12. claude-projects
# =============================================================================

print_header "多实例管理与协作"

print_step "claude-projects（项目集中管理）"
if is_npm_installed "claude-projects"; then
    mark_success "claude-projects 已安装，跳过"
else
    if npm install -g claude-projects 2>&1; then
        mark_success "claude-projects 安装成功"
    else
        mark_fail "claude-projects 安装失败（可手动执行: npm install -g claude-projects）"
    fi
fi

# =============================================================================
# 13. ClaudeLink — 验证包是否存在
# =============================================================================

print_step "ClaudeLink（多实例实时通信）"
# npx claudelink init 在上次运行中失败，可能是包名不对
if [ -d "$HOME/.claudelink" ] || [ -f "$HOME/.claudelink/package.json" ]; then
    mark_success "ClaudeLink 已初始化，跳过"
else
    # 先检查包是否存在于 npm registry
    if npm view claudelink version 2>/dev/null; then
        if npx --yes claudelink init 2>&1; then
            mark_success "ClaudeLink 初始化成功（重启 Claude Code 后生效）"
        else
            mark_fail "ClaudeLink 初始化失败（可手动执行: npx claudelink init）"
        fi
    else
        mark_fail "claudelink 包在 npm registry 中不存在，此工具可能已更名或下架。请查阅官方仓库获取最新安装方式"
    fi
fi

# =============================================================================
# 14. Agent Teams（内置）
# =============================================================================

print_step "Agent Teams（内置子代理系统）"
echo -e "    ${INFO} Claude Code 内置能力，在对话中直接定义子代理即可"
mark_success "Agent Teams（内置）"

# =============================================================================
# 15. Git Worktree（内置）
# =============================================================================

print_step "Git Worktree（多分支工作树隔离）"
echo -e "    ${INFO} Claude Code 内置能力: claude --worktree"
mark_success "Git Worktree（内置）"

# =============================================================================
# 16. ctx-link
# =============================================================================

print_step "ctx-link（跨实例上下文共享）"
mark_skip "ctx-link（需手动安装，请查阅官方仓库）"

# =============================================================================
# 17. EZVibe
# =============================================================================

print_step "EZVibe（可视化管理面板）"
if is_npm_installed "ezvibe"; then
    mark_success "EZVibe 已安装，跳过"
else
    if [ "$HAS_XCODE" = false ]; then
        mark_fail "EZVibe 安装失败 — 缺少 Xcode CLI 工具（better-sqlite3 需要 C++ 编译器）。请执行: xcode-select --install 后重试"
    else
        if npm install -g ezvibe 2>&1; then
            mark_success "EZVibe 安装成功（启动: ezvibe start）"
        else
            mark_fail "EZVibe 安装失败（可手动执行: npm install -g ezvibe）"
        fi
    fi
fi

# =============================================================================
# 18. open-claude-remote
# =============================================================================

print_step "open-claude-remote（远程监控）"
mark_skip "open-claude-remote（需手动安装，请查阅官方仓库）"

# =============================================================================
# 汇总报告
# =============================================================================

print_header "安装完成 — 汇总报告"

echo ""
echo -e "  总计: $TOTAL 项"
echo -e "  ${GREEN}成功/已跳过: $SUCCESS${NC}"
echo -e "  ${YELLOW}手动安装:   $SKIPPED${NC}"
echo -e "  ${RED}失败:       $FAILED${NC}"

if [ ${#MANUAL_STEPS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}──────────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}  需手动处理:${NC}"
    echo -e "${YELLOW}──────────────────────────────────────────────────────────────${NC}"
    for step in "${MANUAL_STEPS[@]}"; do
        echo -e "  ${WARN} $step"
    done
fi

echo ""
echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
echo -e "${BLUE}  验证${NC}"
echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
echo ""
echo "  1. 重启 Claude Code（退出后重新运行 claude）"
echo "  2. 输入 /help 查看已安装的技能列表"
echo "  3. 插件列表: claude plugin list"
echo "  4. Skills 目录: ls ~/.claude/skills/"
echo ""
echo "  此脚本可安全重复运行 — 已安装的项会自动跳过。"
echo ""
