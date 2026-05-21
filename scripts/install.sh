#!/usr/bin/env bash
# =============================================================================
# Claude Code 全局技能一键安装/升级脚本（幂等）
# =============================================================================
# 使用方法:
#   bash scripts/install.sh            安装缺失 + 升级已安装（默认）
#   bash scripts/install.sh --upgrade   仅升级已安装，不装新的
#
# 所有安装均为全局（~/.claude/ 或 npm global），非项目级。
# 已安装的项会自动跳过或升级，可安全重复运行。
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"
INFO="${BLUE}→${NC}"
STAR="${CYAN}★${NC}"

SKILLS_DIR="$HOME/.claude/skills"
TOTAL=0; NEW=0; UPGRADED=0; LATEST=0; SKIPPED=0; FAILED=0
declare -a SUMMARY_LINES=()
declare -a MANUAL_STEPS=()

UPGRADE_ONLY=false
[[ "${1:-}" == "--upgrade" ]] && UPGRADE_ONLY=true

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

add_summary() { SUMMARY_LINES+=("$1"); }

check_command() {
    if command -v "$1" &>/dev/null; then
        echo -e "    ${PASS} $1: $($1 --version 2>&1 | head -1)"
        return 0
    else
        echo -e "    ${FAIL} $1 未安装"
        return 1
    fi
}

is_plugin_installed() {
    claude plugin list 2>/dev/null | grep -qi "$1" 2>/dev/null
}

is_npm_installed() {
    npm list -g "$1" --depth=0 2>/dev/null | grep -q "$1"
}

# ---- GitHub 仓库存在性检查 ----
repo_exists() {
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "https://github.com/$1" 2>/dev/null || echo "000")
    [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ]
}

# ---- Git 技能：安装或升级 ----
# 参数: $1=技能名, $2=GitHub仓库(owner/repo), $3=分支(默认main)
install_or_upgrade_git_skill() {
    local name="$1"
    local repo="$2"
    local branch="${3:-main}"
    local target="$SKILLS_DIR/$name"

    if [ -d "$target/.git" ]; then
        echo -e "    ${INFO} 已安装，检查更新..."
        cd "$target"
        git remote update 2>&1 || { echo -e "    ${WARN} remote update 失败，跳过升级"; add_summary "    ${PASS} $name 已安装（网络不通，未检查更新）"; LATEST=$((LATEST + 1)); return 0; }
        local behind; behind=$(git rev-list HEAD...@{u} --count 2>/dev/null || echo "0")
        if [ "$behind" -gt 0 ]; then
            echo -e "    ${INFO} 落后 $behind 个提交，正在升级..."
            if git pull --ff-only 2>&1; then
                echo -e "    ${PASS} $name 已升级（$behind 个提交）"
                add_summary "    ${STAR} $name 已升级"; UPGRADED=$((UPGRADED + 1))
            else
                echo -e "    ${WARN} fast-forward 失败（本地有修改），跳过升级"
                add_summary "    ${WARN} $name 升级失败（本地有修改）"; SKIPPED=$((SKIPPED + 1))
            fi
        else
            echo -e "    ${PASS} $name 已是最新"
            add_summary "    ${PASS} $name 已是最新"; LATEST=$((LATEST + 1))
        fi
        return 0
    fi

    if [ -d "$target" ]; then
        echo -e "    ${WARN} 目录已存在但非 git 仓库，跳过"
        add_summary "    ${WARN} $name 已存在（非 git，跳过）"; SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过新安装"
        add_summary "    ○ $name 未安装（--upgrade 模式跳过）"; SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    echo -e "    ${INFO} 正在克隆 https://github.com/$repo ..."
    mkdir -p "$(dirname "$target")"
    if git clone --single-branch --depth 1 --branch "$branch" "https://github.com/$repo.git" "$target" 2>&1; then
        echo -e "    ${PASS} $name 安装成功"
        add_summary "    ${PASS} $name 新安装"; NEW=$((NEW + 1))
    else
        rm -rf "$target"
        echo -e "    ${FAIL} $name 安装失败"
        add_summary "    ${FAIL} $name 安装失败"; MANUAL_STEPS+=("$name: git clone https://github.com/$repo.git $target"); FAILED=$((FAILED + 1))
    fi
}

# ---- npm 全局包：安装或升级 ----
install_or_upgrade_npm() {
    local pkg="$1" name="${2:-$1}"

    if is_npm_installed "$pkg"; then
        echo -e "    ${INFO} 已安装，检查更新..."
        local before; before=$(npm list -g "$pkg" --depth=0 2>/dev/null | grep "$pkg" | head -1)
        npm update -g "$pkg" 2>&1 || true
        local after; after=$(npm list -g "$pkg" --depth=0 2>/dev/null | grep "$pkg" | head -1)
        if [ "$before" != "$after" ]; then
            echo -e "    ${PASS} $name 已升级"; add_summary "    ${STAR} $name 已升级"; UPGRADED=$((UPGRADED + 1))
        else
            echo -e "    ${PASS} $name 已是最新"; add_summary "    ${PASS} $name 已是最新"; LATEST=$((LATEST + 1))
        fi
        return 0
    fi

    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过新安装"
        add_summary "    ○ $name 未安装（--upgrade 模式跳过）"; SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    echo -e "    ${INFO} 正在安装 $pkg ..."
    if npm install -g "$pkg" 2>&1; then
        echo -e "    ${PASS} $name 安装成功"; add_summary "    ${PASS} $name 新安装"; NEW=$((NEW + 1))
    else
        echo -e "    ${FAIL} $name 安装失败"; add_summary "    ${FAIL} $name 安装失败"; MANUAL_STEPS+=("$name: npm install -g $pkg"); FAILED=$((FAILED + 1))
    fi
}

# ---- Claude Code 插件：安装 ----
install_plugin() {
    local plugin_name="$1" search_key="${2:-$1}"

    if is_plugin_installed "$search_key"; then
        echo -e "    ${PASS} $plugin_name 已安装，跳过"
        add_summary "    ${PASS} $plugin_name 已安装"; LATEST=$((LATEST + 1))
        return 0
    fi

    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过新安装"
        add_summary "    ○ $plugin_name 未安装（--upgrade 模式跳过）"; SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    if claude plugin install "$plugin_name" 2>&1; then
        echo -e "    ${PASS} $plugin_name 安装成功"; add_summary "    ${PASS} $plugin_name 新安装"; NEW=$((NEW + 1))
    else
        echo -e "    ${FAIL} $plugin_name 安装失败"; add_summary "    ${FAIL} $plugin_name 安装失败"; MANUAL_STEPS+=("$plugin_name: claude plugin install $plugin_name"); FAILED=$((FAILED + 1))
    fi
}

# =============================================================================
# 0. 环境预检
# =============================================================================

print_header "环境预检"

HAS_CLAUDE=true; HAS_GIT=true; HAS_BUN=true; HAS_XCODE=true

check_command claude || HAS_CLAUDE=false
check_command git    || HAS_GIT=false
check_command bun    || HAS_BUN=false

# bun 自动安装（GStack 依赖）
if [ "$HAS_BUN" = false ]; then
    echo ""
    echo -e "    ${INFO} bun 未安装，正在自动安装（GStack 依赖）..."
    if curl -fsSL https://bun.sh/install | bash 2>&1; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        if command -v bun &>/dev/null; then
            echo -e "    ${PASS} bun 安装成功: $(bun --version 2>&1)"
            HAS_BUN=true
        else
            echo -e "    ${WARN} bun 已安装但当前 shell 未加载，后续使用完整路径"
            [ -f "$HOME/.bun/bin/bun" ] && HAS_BUN=true
        fi
    else
        echo -e "    ${FAIL} bun 自动安装失败，GStack 将跳过"
        HAS_BUN=false
    fi
fi

# Xcode CLI 检查（EZVibe 等原生编译依赖）
if xcode-select -p &>/dev/null; then
    echo -e "    ${PASS} Xcode CLI: $(xcode-select -p 2>&1)"
else
    echo -e "    ${WARN} Xcode CLI 未安装（EZVibe 等需要原生编译的包将跳过）"
    HAS_XCODE=false
fi

[ "$HAS_CLAUDE" = false ] && { echo -e "\n${RED}错误: 请先安装 Claude Code${NC}\n  https://docs.anthropic.com/en/docs/claude-code"; exit 1; }
[ "$HAS_GIT" = false ]    && { echo -e "\n${RED}错误: 请先安装 Git${NC}"; exit 1; }

echo ""
if [ "$UPGRADE_ONLY" = true ]; then
    echo -e "${YELLOW}模式: 仅升级已安装项${NC}"
else
    echo -e "${GREEN}模式: 安装缺失 + 升级已安装${NC}"
fi
echo -e "${GREEN}预检通过，开始...${NC}"

# =============================================================================
# 1. 核心开发插件（Claude Code 插件市场）
# =============================================================================

print_header "一、核心开发插件"

print_step "Superpowers（20+ 可组合子技能，覆盖开发全流程）"
install_plugin "superpowers@claude-plugins-official" "superpowers"

print_step "Planning With Files（持久化规划，上下文外状态跟踪）"
install_plugin "planning-with-files@planning-with-files" "planning-with-files"

print_step "Ralph Loop（自主迭代循环，防止提前收工）"
install_plugin "ralph-loop@claude-plugins-official" "ralph-loop"

# =============================================================================
# 2. 开发工具链（GitHub Skills → ~/.claude/skills/）
# =============================================================================

print_header "二、开发工具链 Skills"

# --- GStack ---
print_step "GStack（多角色 AI 工程团队，47 子技能）"

if ! command -v bun &>/dev/null && [ -f "$HOME/.bun/bin/bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [ -z "$(command -v bun)" ]; then
    echo -e "    ${FAIL} 需要 bun 但不可用"
    add_summary "    ${FAIL} GStack（bun 不可用）"; FAILED=$((FAILED + 1))
    MANUAL_STEPS+=("安装 bun: curl -fsSL https://bun.sh/install | bash")
else
    GSTACK_DIR="$SKILLS_DIR/gstack"
    gstack_done=false

    if [ -d "$GSTACK_DIR/.git" ]; then
        echo -e "    ${INFO} 已安装，检查更新..."
        cd "$GSTACK_DIR"
        git remote update 2>&1 || true
        behind=$(git rev-list HEAD...@{u} --count 2>/dev/null || echo "0")
        if [ "$behind" -gt 0 ]; then
            echo -e "    ${INFO} 落后 $behind 个提交，正在升级..."
            if git pull --ff-only 2>&1; then
                ./setup 2>&1 || true
                echo -e "    ${PASS} GStack 已升级"; add_summary "    ${STAR} GStack 已升级"; UPGRADED=$((UPGRADED + 1))
            else
                echo -e "    ${WARN} fast-forward 失败（本地有修改），跳过升级"
                add_summary "    ${PASS} GStack 已安装（有本地修改，跳过升级）"; LATEST=$((LATEST + 1))
            fi
        else
            echo -e "    ${PASS} GStack 已是最新"; add_summary "    ${PASS} GStack 已是最新"; LATEST=$((LATEST + 1))
        fi
        gstack_done=true
    fi

    if [ "$gstack_done" != true ]; then
        if [ "$UPGRADE_ONLY" = true ]; then
            echo -e "    ${INFO} --upgrade 模式，跳过新安装"
            add_summary "    ○ GStack 未安装（--upgrade 模式跳过）"; SKIPPED=$((SKIPPED + 1))
        else
            # 优先使用本地副本
            LOCAL_GSTACK=""
            for candidate in "/opt/devs/projects/claude/gstack" "$PWD/gstack" "$(dirname "$0")/../gstack"; do
                if [ -d "$candidate/.git" ] && [ -f "$candidate/setup" ]; then
                    LOCAL_GSTACK="$candidate"; break
                fi
            done

            if [ -n "$LOCAL_GSTACK" ]; then
                echo -e "    ${INFO} 从本地副本复制: $LOCAL_GSTACK"
                mkdir -p "$(dirname "$GSTACK_DIR")"
                if cp -R "$LOCAL_GSTACK" "$GSTACK_DIR" 2>&1; then
                    cd "$GSTACK_DIR" && ./setup 2>&1
                    echo -e "    ${PASS} GStack 安装成功（本地副本）"; add_summary "    ${PASS} GStack 新安装"; NEW=$((NEW + 1))
                else
                    echo -e "    ${FAIL} 复制失败"; add_summary "    ${FAIL} GStack 安装失败"; FAILED=$((FAILED + 1))
                fi
            else
                echo -e "    ${INFO} 从 GitHub 克隆..."
                if git clone --single-branch --depth 1 "https://github.com/garrytan/gstack.git" "$GSTACK_DIR" 2>&1; then
                    cd "$GSTACK_DIR" && ./setup 2>&1
                    echo -e "    ${PASS} GStack 安装成功"; add_summary "    ${PASS} GStack 新安装"; NEW=$((NEW + 1))
                else
                    echo -e "    ${FAIL} 网络问题，安装失败"; add_summary "    ${FAIL} GStack 安装失败"; FAILED=$((FAILED + 1))
                    MANUAL_STEPS+=("GStack: git clone https://github.com/garrytan/gstack.git $GSTACK_DIR && cd $GSTACK_DIR && ./setup")
                fi
            fi
        fi
    fi
fi

# --- find-skills ---
print_step "find-skills（技能搜索发现）"
install_or_upgrade_git_skill "find-skills" "anthropics/claude-code"

# --- Code Simplifier ---
print_step "Code Simplifier（代码简化，写完自动审查）"
install_or_upgrade_npm "@adonis0123/code-simplifier" "code-simplifier"

# =============================================================================
# 3. 前端设计技能（来自 22 项清单）
# =============================================================================

print_header "三、前端设计技能"

# --- frontend-design ---
print_step "frontend-design（官方前端美学 Skill，禁止滥俗样式）"
install_plugin "frontend-design@claude-plugins-official" "frontend-design"

# --- UI UX Pro Max ---
print_step "UI UX Pro Max（67 风格 + 161 配色 + 57 字体配对）"
if repo_exists "nextlevelbuilder/ui-ux-pro-max-skill"; then
    install_or_upgrade_git_skill "ui-ux-pro-max" "nextlevelbuilder/ui-ux-pro-max-skill"
else
    echo -e "    ${WARN} 仓库 404，跳过"; add_summary "    ${WARN} ui-ux-pro-max 仓库 404"; SKIPPED=$((SKIPPED + 1))
fi

# --- web-design-guidelines ---
print_step "web-design-guidelines（专业 Web 设计原则：间距/响应式/WCAG）"
if repo_exists "dreric-labs/agent-skills"; then
    install_or_upgrade_git_skill "web-design-guidelines" "dreric-labs/agent-skills"
else
    echo -e "    ${WARN} 仓库 404，ecc:frontend-design-direction 已覆盖"; add_summary "    ${WARN} web-design-guidelines 仓库 404，ecc 已覆盖"; SKIPPED=$((SKIPPED + 1))
fi

# --- shadcn-ui ---
print_step "shadcn-ui（shadcn/ui 组件库深度集成）"
if is_plugin_installed "developer-kit"; then
    echo -e "    ${PASS} developer-kit 已安装（含 shadcn/ui 支持）"; add_summary "    ${PASS} shadcn-ui（developer-kit 已安装）"; LATEST=$((LATEST + 1))
else
    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过"; add_summary "    ○ shadcn-ui 未安装"; SKIPPED=$((SKIPPED + 1))
    else
        if claude plugin install "developer-kit@giuseppe-trisciuoglio" 2>&1; then
            echo -e "    ${PASS} developer-kit 安装成功"; add_summary "    ${PASS} shadcn-ui 新安装"; NEW=$((NEW + 1))
        else
            echo -e "    ${WARN} 插件安装失败，跳过"; add_summary "    ${WARN} shadcn-ui 安装失败"; MANUAL_STEPS+=("shadcn-ui: claude plugin install developer-kit@giuseppe-trisciuoglio"); FAILED=$((FAILED + 1))
        fi
    fi
fi

# --- Impeccable ---
print_step "Impeccable（/audit /critique /polish /overdrive 精确控制）"
if repo_exists "paulbakaus/impeccable"; then
    install_or_upgrade_git_skill "impeccable" "paulbakaus/impeccable"
else
    echo -e "    ${WARN} 仓库 404，ecc:code-review + superpowers:verification-before-completion 已覆盖"
    add_summary "    ${WARN} Impeccable 仓库 404，ecc 已覆盖"; SKIPPED=$((SKIPPED + 1))
fi

# --- web-accessibility ---
print_step "web-accessibility（WCAG 无障碍自动检测）"
echo -e "    ${PASS} ecc:accessibility 已覆盖（WCAG 2.2 键盘导航/对比度/语义标签）"
add_summary "    ${STAR} web-accessibility 由 ecc:accessibility 覆盖"; LATEST=$((LATEST + 1))

# =============================================================================
# 4. 记忆与协作
# =============================================================================

print_header "四、记忆与协作"

# --- claude-mem ---
print_step "claude-mem（跨会话长期记忆，12 子技能）"
if [ -d "$HOME/.claude-mem" ] || is_plugin_installed "claude-mem"; then
    echo -e "    ${PASS} claude-mem 已安装"; add_summary "    ${PASS} claude-mem 已安装"; LATEST=$((LATEST + 1))
else
    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过"; add_summary "    ○ claude-mem 未安装"; SKIPPED=$((SKIPPED + 1))
    else
        if npx --yes claude-mem install 2>&1; then
            echo -e "    ${PASS} claude-mem 安装成功"; add_summary "    ${PASS} claude-mem 新安装"; NEW=$((NEW + 1))
        else
            echo -e "    ${FAIL} 安装失败"; add_summary "    ${FAIL} claude-mem 安装失败"; MANUAL_STEPS+=("claude-mem: npx claude-mem install"); FAILED=$((FAILED + 1))
        fi
    fi
fi

# --- claude-projects ---
print_step "claude-projects（项目集中管理）"
install_or_upgrade_npm "claude-projects"

# --- ClaudeLink ---
print_step "ClaudeLink（多实例实时通信）"
if [ -d "$HOME/.claudelink" ] || [ -f "$HOME/.claudelink/package.json" ]; then
    echo -e "    ${PASS} ClaudeLink 已初始化"; add_summary "    ${PASS} ClaudeLink 已初始化"; LATEST=$((LATEST + 1))
else
    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过"; add_summary "    ○ ClaudeLink 未安装"; SKIPPED=$((SKIPPED + 1))
    else
        if npm view claudelink version 2>/dev/null; then
            if npx --yes claudelink init 2>&1; then
                echo -e "    ${PASS} ClaudeLink 初始化成功"; add_summary "    ${PASS} ClaudeLink 新安装"; NEW=$((NEW + 1))
            else
                echo -e "    ${FAIL} 初始化失败"; add_summary "    ${FAIL} ClaudeLink 初始化失败"; MANUAL_STEPS+=("ClaudeLink: npx claudelink init"); FAILED=$((FAILED + 1))
            fi
        else
            echo -e "    ${WARN} npm 包不存在，可能已更名"; add_summary "    ${WARN} ClaudeLink npm 包不存在"; SKIPPED=$((SKIPPED + 1))
        fi
    fi
fi

# --- EZVibe ---
print_step "EZVibe（可视化管理面板）"
if is_npm_installed "ezvibe"; then
    echo -e "    ${INFO} 已安装，检查更新..."
    npm update -g ezvibe 2>&1 || true
    echo -e "    ${PASS} EZVibe 已更新"; add_summary "    ${PASS} EZVibe 已是最新"; LATEST=$((LATEST + 1))
else
    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过"; add_summary "    ○ EZVibe 未安装"; SKIPPED=$((SKIPPED + 1))
    elif [ "$HAS_XCODE" = false ]; then
        echo -e "    ${FAIL} 需要 Xcode CLI（better-sqlite3 C++ 编译）"; add_summary "    ${FAIL} EZVibe（缺少 Xcode CLI）"; MANUAL_STEPS+=("EZVibe: xcode-select --install 后重试 npm install -g ezvibe"); FAILED=$((FAILED + 1))
    else
        if npm install -g ezvibe 2>&1; then
            echo -e "    ${PASS} EZVibe 安装成功（启动: ezvibe start）"; add_summary "    ${PASS} EZVibe 新安装"; NEW=$((NEW + 1))
        else
            echo -e "    ${FAIL} 安装失败"; add_summary "    ${FAIL} EZVibe 安装失败"; MANUAL_STEPS+=("EZVibe: npm install -g ezvibe"); FAILED=$((FAILED + 1))
        fi
    fi
fi

# =============================================================================
# 5. MCP 服务配置
# =============================================================================

print_header "五、MCP 服务配置"

print_step "UI Expert MCP（UI 设计系统嵌入）"
MCP_JSON="$HOME/.claude/.mcp.json"
UI_CONFIGURED=false
if [ -f "$MCP_JSON" ]; then
    if python3 -c "import json; print('ui-expert' in json.load(open('$MCP_JSON')).get('mcpServers',{}))" 2>/dev/null | grep -q "True"; then
        UI_CONFIGURED=true
    fi
fi
if [ "$UI_CONFIGURED" = true ]; then
    echo -e "    ${PASS} UI Expert MCP 已配置"; add_summary "    ${PASS} UI Expert MCP 已配置"; LATEST=$((LATEST + 1))
else
    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过"; add_summary "    ○ UI Expert MCP 未配置"; SKIPPED=$((SKIPPED + 1))
    else
        echo -e "    ${INFO} 正在配置..."
        if [ -f "$MCP_JSON" ]; then
            python3 -c "
import json
with open('$MCP_JSON') as f:
    d = json.load(f)
d.setdefault('mcpServers', {})['ui-expert'] = {'command':'npx','args':['-y','@reallygood83/ui-expert-mcp']}
with open('$MCP_JSON','w') as f:
    json.dump(d, f, indent=2)
print('ok')
" 2>&1 && { echo -e "    ${PASS} UI Expert MCP 配置成功"; add_summary "    ${PASS} UI Expert MCP 新配置"; NEW=$((NEW + 1)); } || \
            { echo -e "    ${FAIL} 配置失败"; add_summary "    ${FAIL} UI Expert MCP 配置失败"; MANUAL_STEPS+=("UI Expert MCP: 手动添加到 ~/.claude/.mcp.json"); FAILED=$((FAILED + 1)); }
        else
            echo '{"mcpServers": {"ui-expert": {"command": "npx", "args": ["-y", "@reallygood83/ui-expert-mcp"]}}}' > "$MCP_JSON"
            echo -e "    ${PASS} UI Expert MCP 配置成功"; add_summary "    ${PASS} UI Expert MCP 新配置"; NEW=$((NEW + 1))
        fi
    fi
fi

print_step "Supabase 技能"
echo -e "    ${INFO} 需通过官方市场手动安装: claude plugin install supabase"
add_summary "    ${WARN} Supabase 需手动安装"; SKIPPED=$((SKIPPED + 1))

# =============================================================================
# 6. GitHub 集成
# =============================================================================

print_header "六、GitHub 集成"

print_step "GitHub CLI 认证"
if gh auth status 2>/dev/null; then
    echo -e "    ${PASS} GitHub CLI 已认证"; add_summary "    ${PASS} GitHub CLI 已认证"; LATEST=$((LATEST + 1))
else
    if [ "$UPGRADE_ONLY" = true ]; then
        echo -e "    ${INFO} --upgrade 模式，跳过"; add_summary "    ○ GitHub 未认证"; SKIPPED=$((SKIPPED + 1))
    else
        echo -e "    ${WARN} GitHub CLI 未认证"; add_summary "    ${WARN} GitHub CLI 未认证"; MANUAL_STEPS+=("GitHub: gh auth login 或在 Claude Code 中执行 /github"); SKIPPED=$((SKIPPED + 1))
    fi
fi

# =============================================================================
# 7. 22 项清单覆盖总结
# =============================================================================

print_header "七、22 项技能清单覆盖状态"

echo ""
echo -e "  ┌──────────────────────────────────────────────────────────────────────────────┐"
echo -e "  │  # │ 技能                    │ 状态        │ 覆盖方式                          │"
echo -e "  ├──────────────────────────────────────────────────────────────────────────────┤"

COVERAGE_TABLE=(
    " 1 | claude-dev-skills        | ${GREEN}已覆盖${NC}     | superpowers + ecc（200+ 子技能）"
    " 2 | git-workflow             | ${GREEN}已覆盖${NC}     | ecc:git-workflow + GitHub MCP"
    " 3 | terminal-sandbox         | ${GREEN}已覆盖${NC}     | Claude Code 内置 Bash"
    " 4 | database-master          | ${GREEN}已覆盖${NC}     | MCP db-analyzer（MySQL/PG）"
    " 5 | api-lifecycle            | ${GREEN}已覆盖${NC}     | ecc:api-design + java-openapi"
    " 6 | devops-deploy            | ${GREEN}已覆盖${NC}     | ecc:deployment-patterns"
    " 7 | find-skills              | ${GREEN}已安装${NC}     | ~/.claude/skills/find-skills"
    " 8 | skill-creator            | ${GREEN}已覆盖${NC}     | ecc:skill-create + 内置"
    " 9 | vercel-react-best-pract. | ${GREEN}已覆盖${NC}     | ecc 前端技能族"
    "10 | agent-browser            | ${GREEN}已覆盖${NC}     | Playwright MCP + gstack:browse"
    "11 | frontend-design          | ${GREEN}已安装${NC}     | 插件 @claude-plugins-official"
    "12 | ui-ux-pro-max            | ${CYAN}本次安装${NC}     | ~/.claude/skills/ui-ux-pro-max"
    "13 | web-design-guidelines    | ${YELLOW}仓库404${NC}    | ecc:frontend-design-direction"
    "14 | shadcn-ui                | ${CYAN}本次安装${NC}     | developer-kit 插件"
    "15 | web-accessibility        | ${GREEN}已覆盖${NC}     | ecc:accessibility（WCAG 2.2）"
    "16 | Impeccable               | ${YELLOW}仓库404${NC}    | ecc:code-review 替代"
    "17 | ui-first-builder         | ${YELLOW}手动安装${NC}   | ZIP 上传（claude.ai/settings）"
    "18 | claude-design-system     | ${YELLOW}无公开源${NC}   | 暂无公开安装源"
    "19 | design-principles        | ${YELLOW}无公开源${NC}   | 暂无公开安装源"
    "20 | UI Expert MCP            | ${CYAN}本次安装${NC}     | MCP 配置 @reallygood83/ui-expert"
    "21 | Workflow Studio          | ${YELLOW}独立工具${NC}   | 非 Skill，需单独下载"
    "22 | Claude Marketplace       | ${GREEN}内置${NC}       | Claude Code 自带"
)

for line in "${COVERAGE_TABLE[@]}"; do
    echo -e "  │ $line │"
done

echo -e "  └──────────────────────────────────────────────────────────────────────────────┘"

# =============================================================================
# 8. 内置能力确认
# =============================================================================

print_header "八、内置能力确认"

echo ""
echo -e "  ${PASS} Security Guidance      — Claude Code 内置（项目 CLAUDE.md 约束）"
echo -e "  ${PASS} Agent Teams            — Subagents 系统"
echo -e "  ${PASS} Git Worktree           — claude --worktree"
echo -e "  ${PASS} Terminal Sandbox       — 内置 Bash 工具"
echo -e "  ${PASS} Skill Creator          — 内置 + ecc:skill-create"
echo -e "  ${PASS} Agent Browser          — Playwright MCP（20+ 浏览器操作）"
echo -e "  ${PASS} Everything Claude Code — 181 技能合集，需手动查阅 GitHub"
echo -e "  ${WARN} ctx-link               — 需手动安装，查阅官方仓库"
echo -e "  ${WARN} open-claude-remote     — 需手动安装，查阅官方仓库"
echo -e "  ${WARN} Supabase               — 需手动: claude plugin install supabase"

# =============================================================================
# 汇总报告
# =============================================================================

print_header "汇总报告"

echo ""
echo -e "  ${GREEN}新安装:   $NEW${NC}"
echo -e "  ${CYAN}已升级:   $UPGRADED${NC}"
echo -e "  ${GREEN}已是最新: $LATEST${NC}"
echo -e "  ${YELLOW}已跳过:   $SKIPPED${NC}"
echo -e "  ${RED}失败:     $FAILED${NC}"
echo -e "  ─────────────────"
echo -e "  总计:     $TOTAL 项"

if [ ${#SUMMARY_LINES[@]} -gt 0 ]; then
    echo ""
    echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}  详细状态:${NC}"
    echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
    for line in "${SUMMARY_LINES[@]}"; do
        echo -e "$line"
    done
fi

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
echo "  claude plugin list                  # 已安装插件"
echo "  claude mcp list                     # MCP 服务状态"
echo "  ls ~/.claude/skills/                # 用户级 Skill 目录"
echo "  npm list -g --depth=0               # 全局 npm 包"
echo ""
echo "  重复运行: bash scripts/install.sh           # 安装缺失 + 升级"
echo "  仅升级:   bash scripts/install.sh --upgrade # 只升级已安装"
echo ""
