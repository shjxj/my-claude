# Claude Code 完整功能与使用手册

> 更新日期：2026-05-19 | 涵盖 Claude Code 核心能力、所有 CLI 命令、内置斜杠命令、已安装插件（10个）与技能、MCP 服务（13个）的详细中文说明
>
> **相关文件**：`INSTALLED.md`（插件清单）、`develop.md`（开发方法论）、`scripts/install.sh`（一键安装 + 升级）

---

## 目录

1. [Claude Code 核心能力](#一claude-code-核心能力)
2. [CLI 命令行参数详解](#二cli-命令行参数详解)
3. [CLI 子命令详解](#三cli-子命令详解)
4. [内置斜杠命令大全](#四内置斜杠命令大全)
5. [已安装插件详解](#五已安装插件详解)
6. [已安装用户级 Skill 详解](#六已安装用户级-skill-详解)
7. [MCP 服务详解](#七mcp-服务详解)
8. [快捷键与交互技巧](#八快捷键与交互技巧)

---

## 一、Claude Code 核心能力

Claude Code 是 Anthropic 官方推出的命令行 AI 编程助手，可在终端中直接使用。

### 1.1 代码编辑能力

| 能力 | 说明 |
|------|------|
| **文件读取** | 读取任意文件内容，支持代码、图片（PNG/JPG）、PDF、Jupyter Notebook |
| **文件编辑** | 精确的字符串替换编辑，支持单次替换和全局替换 |
| **文件创建** | 创建新文件，自动检测路径合法性 |
| **代码搜索** | 基于 AST 的智能符号搜索、全文正则搜索、文件名模糊匹配 |
| **多文件重构** | 跨文件编辑，支持大规模代码变更 |

### 1.2 终端与系统能力

| 能力 | 说明 |
|------|------|
| **Bash 执行** | 运行任意 Shell 命令，支持后台执行、超时控制 |
| **Git 操作** | 完整的 Git 工作流：提交、分支管理、PR 创建、代码审查 |
| **进程管理** | 启动、监控、终止后台进程 |
| **文件系统** | 浏览目录、查找文件、批量操作 |

### 1.3 智能推理能力

| 能力 | 说明 |
|------|------|
| **计划模式** | 在修改代码前先制定实施计划，用户审批后再执行 |
| **思维链推理** | 复杂问题的结构化逐步推理（通过 sequential-thinking MCP） |
| **子代理系统** | 创建多个子代理并行执行独立任务 |
| **TDD 开发** | 测试驱动开发流程——先写测试，再写实现 |
| **系统化调试** | 结构化的 Bug 排查方法论 |

### 1.4 扩展与集成能力

| 能力 | 说明 |
|------|------|
| **插件系统** | 从市场安装插件，扩展功能 |
| **技能系统** | 通过 SKILL.md 定义可复用的领域知识和流程 |
| **MCP 协议** | 连接外部工具和服务（数据库、浏览器、API 等） |
| **Hook 系统** | 在工具调用前后执行自定义脚本 |
| **IDE 集成** | 与 VS Code、JetBrains IDE 联动 |
| **会话持久化** | 自动保存会话，支持恢复和分支 |

### 1.5 协作与部署能力

| 能力 | 说明 |
|------|------|
| **代码审查** | 多维度自动审查（安全、性能、可维护性） |
| **PR 管理** | 创建、审查、合并 GitHub Pull Request |
| **E2E 测试** | 通过 Playwright 进行浏览器自动化测试 |
| **远程控制** | 手机扫码远程监控和控制 |
| **定时任务** | Cron 表达式定时执行任务 |
| **工作树隔离** | Git Worktree 实现多任务并行无冲突 |

---

## 二、CLI 命令行参数详解

### 2.1 基本用法

```bash
claude [options] [command] [prompt]
```

默认启动交互式会话。使用 `-p/--print` 进入非交互模式。

### 2.2 会话控制参数

| 参数 | 说明 |
|------|------|
| `-p, --print` | 非交互模式，输出结果后退出（适用于管道） |
| `-c, --continue` | 恢复当前目录最近一次会话 |
| `-r, --resume [id]` | 按会话 ID 恢复会话，或打开交互式选择器 |
| `--session-id <uuid>` | 使用指定的 UUID 作为会话 ID |
| `--fork-session` | 恢复时创建新会话 ID（与 `--resume`/`--continue` 配合） |
| `--from-pr [value]` | 恢复关联到某个 PR 的会话 |
| `-n, --name <name>` | 为会话设置显示名称 |
| `--no-session-persistence` | 禁用会话持久化（仅 `--print` 模式） |

### 2.3 模型与推理参数

| 参数 | 说明 |
|------|------|
| `--model <model>` | 指定模型：`sonnet`、`opus`、`haiku` 或完整模型名 |
| `--effort <level>` | 推理努力程度：`low`、`medium`、`high`、`xhigh`、`max`（max 仅 Opus） |
| `--fallback-model <model>` | 主模型过载时自动切换的备用模型（仅 `--print`） |
| `--max-budget-usd <amount>` | API 调用最大花费上限（仅 `--print`） |
| `--betas <betas...>` | Beta 功能头（API Key 用户） |

### 2.4 权限与安全参数

| 参数 | 说明 |
|------|------|
| `--permission-mode <mode>` | 权限模式：`acceptEdits`、`auto`、`bypassPermissions`、`default`、`dontAsk`、`plan` |
| `--allowedTools, --allowed-tools <tools>` | 允许的工具列表（如 `"Bash(git *) Edit"`） |
| `--disallowedTools, --disallowed-tools <tools>` | 禁止的工具列表 |
| `--dangerously-skip-permissions` | 跳过所有权限检查（仅限无网络沙箱环境） |

### 2.5 输入输出参数

| 参数 | 说明 |
|------|------|
| `--input-format <format>` | 输入格式：`text`（默认）或 `stream-json`（实时流式输入） |
| `--output-format <format>` | 输出格式：`text`（默认）、`json`（单次结果）、`stream-json`（实时流） |
| `--json-schema <schema>` | JSON Schema 用于结构化输出验证 |
| `--include-partial-messages` | 包含部分消息块（仅 `--print` + `stream-json`） |
| `--include-hook-events` | 输出中包含 Hook 生命周期事件（仅 `stream-json`） |
| `--replay-user-messages` | 将 stdin 的用户消息回显到 stdout |
| `--verbose` | 覆盖配置文件中的 verbose 设置 |

### 2.6 配置与扩展参数

| 参数 | 说明 |
|------|------|
| `--settings <file-or-json>` | 加载额外的 settings JSON 文件或字符串 |
| `--setting-sources <sources>` | 指定加载的配置源（`user`、`project`、`local`，逗号分隔） |
| `--mcp-config <configs...>` | 从 JSON 文件或字符串加载 MCP 服务器 |
| `--strict-mcp-config` | 仅使用 `--mcp-config` 指定的 MCP，忽略其他配置 |
| `--plugin-dir <path>` | 从目录或 .zip 加载插件（可重复使用） |
| `--plugin-url <url>` | 从 URL 获取插件 .zip（可重复使用） |
| `--agents <json>` | JSON 定义自定义代理 |
| `--agent <agent>` | 指定当前会话使用的代理 |
| `--system-prompt <prompt>` | 自定义系统提示词 |
| `--append-system-prompt <prompt>` | 追加系统提示词 |
| `--exclude-dynamic-system-prompt-sections` | 排除动态系统提示词段以优化缓存 |
| `--add-dir <directories...>` | 添加额外的工具访问目录 |
| `--disable-slash-commands` | 禁用所有技能 |
| `--tools <tools...>` | 指定可用工具集（`""` 禁用全部，`"default"` 使用全部） |

### 2.7 集成与环境参数

| 参数 | 说明 |
|------|------|
| `--ide` | 自动连接到可用的 IDE |
| `--chrome` / `--no-chrome` | 启用/禁用 Chrome 集成 |
| `--bare` | 最小模式：跳过 hooks、LSP、插件同步、自动记忆等 |
| `--debug [filter]` / `-d` | 启用调试模式，可选分类过滤 |
| `--debug-file <path>` | 将调试日志写入指定文件 |
| `-w, --worktree [name]` | 为当前会话创建新的 Git Worktree |
| `--tmux` | 为 Worktree 创建 tmux 会话 |
| `--remote-control [name]` | 启用远程控制模式 |
| `--file <specs...>` | 启动时下载文件资源 |

### 2.8 其他参数

| 参数 | 说明 |
|------|------|
| `-h, --help` | 显示帮助信息 |
| `-v, --version` | 显示版本号 |
| `--brief` | 启用 SendUserMessage 工具用于代理与用户通信 |

---

## 三、CLI 子命令详解

| 命令 | 说明 | 用法示例 |
|------|------|----------|
| `claude` | 启动交互式会话 | `claude` |
| `claude "prompt"` | 带提示词的交互式会话 | `claude "帮我重构这个函数"` |
| `claude -p "prompt"` | 非交互式单次执行 | `claude -p "解释这个文件的功能"` |
| `claude update` | 检查并安装更新 | `claude update` |
| `claude install [target]` | 安装原生版本 | `claude install stable` |
| `claude auth` | 管理身份认证 | `claude auth` |
| `claude doctor` | 环境健康检查 | `claude doctor` |
| `claude mcp` | 配置和管理 MCP 服务器 | `claude mcp add` / `claude mcp list` |
| `claude plugin` | 管理插件（等同于 `plugins`） | `claude plugin list` |
| `claude agents` | 管理后台代理 | `claude agents` |
| `claude project` | 管理项目状态 | `claude project` |
| `claude setup-token` | 设置长期认证令牌（需订阅） | `claude setup-token` |
| `claude ultrareview [target]` | 云端多代理代码审查 | `claude ultrareview` |
| `claude auto-mode` | 检查自动模式分类器配置 | `claude auto-mode` |

---

## 四、内置斜杠命令大全

以下命令在 Claude Code 交互式会话中输入。输入 `/` 后按 Tab 可自动补全。

### 4.1 会话管理（7 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/help` | — | 显示所有可用命令、快捷键和文档（不消耗 Token） | `/help` 或 `/help 主题` |
| `/clear` | `/reset` `/new` | 清空当前对话历史（保留 CLAUDE.md 和项目记忆） | `/clear` |
| `/compact [重点]` | — | 压缩对话上下文以释放 Token 空间，可指定保留重点 | `/compact` 或 `/compact 保留数据库架构` |
| `/context` | — | 可视化上下文窗口使用情况（彩色网格显示各分类 Token 占用） | `/context` |
| `/status` | — | 显示会话信息：版本、模型、账户、上下文使用率 | `/status` |
| `/exit` | `/quit` | 退出 Claude Code REPL 会话 | `/exit` |
| `/rename [名称]` | — | 重命名当前会话 | `/rename 功能开发` |

### 4.2 会话历史与导航（4 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/resume [会话ID]` | `/continue` | 恢复之前的会话，或打开交互式选择器 | `/resume` 或 `/resume abc123` |
| `/rewind` | `/checkpoint` | 回滚对话和/或代码变更到之前的检查点 | `/rewind` |
| `/branch [名称]` | `/fork` | 从当前节点创建对话分支（用于对比不同方案） | `/branch 替代方案` |
| `/export [文件名]` | — | 导出当前对话为文本文件或剪贴板 | `/export` 或 `/export log.txt` |

### 4.3 成本与用量（4 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/cost` | — | 显示当前会话的 Token 用量和预估费用 | `/cost` |
| `/usage` | — | 显示账户级别的计划限额和消耗 | `/usage` |
| `/stats` | — | 可视化每日使用统计、会话历史、连续使用天数 | `/stats` |
| `/insights` | — | 从会话历史生成分析和优化报告 | `/insights` |

### 4.4 配置与设置（11 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/config` | `/settings` | 打开设置编辑器（主题、模型默认值、输出风格等） | `/config` |
| `/model [名称]` | — | 切换模型：`sonnet`、`opus`、`haiku` 或完整模型名 | `/model opus` |
| `/effort [级别]` | — | 设置推理努力度：`low`、`medium`、`high`、`xhigh`、`max` | `/effort high` |
| `/fast [on\|off]` | — | 切换快速模式（约 2.5 倍速度，约 6 倍费用） | `/fast on` |
| `/theme [名称]` | — | 切换终端颜色主题 | `/theme dark` |
| `/color [颜色\|default]` | — | 设置提示栏颜色 | `/color green` |
| `/statusline` | — | 自定义终端状态栏（位置、内容、可见性） | `/statusline` |
| `/vim` | — | 切换 Vim 键位绑定 | `/vim` |
| `/keybindings` | — | 打开键盘快捷键配置文件 | `/keybindings` |
| `/terminal-setup` | — | 配置 Shell 集成（bash/zsh/WezTerm） | `/terminal-setup` |
| `/privacy-settings` | — | 配置隐私偏好（Pro/Max 计划可用） | `/privacy-settings` |

### 4.5 项目与记忆（4 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/init` | — | 在项目根目录生成或更新 CLAUDE.md 项目记忆文件 | `/init` |
| `/memory` | — | 调整项目级和用户级持久化指令 | `/memory` |
| `/add-dir <路径>` | — | 添加额外工作目录到会话的允许上下文 | `/add-dir /path/to/other` |
| `/todos` | — | 查看当前任务分解列表 | `/todos` |

### 4.6 诊断与健康（3 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/doctor` | — | 运行完整环境健康检查（API Key、网络、配置、权限等） | `/doctor` |
| `/debug [描述]` | — | 启用调试日志，可选分析特定类别 | `/debug` 或 `/debug api` |
| `/release-notes` | — | 查看当前版本的更新日志 | `/release-notes` |

### 4.7 扩展与集成（10 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/mcp` | — | 管理 MCP 服务器连接（添加、移除、OAuth 流程） | `/mcp` |
| `/plugin [操作] [名称]` | — | 管理插件：install、enable、disable、list、uninstall | `/plugin install superpowers@claude-plugins-official` |
| `/reload-plugins` | — | 重新加载所有已安装插件 | `/reload-plugins` |
| `/skills` | — | 列出所有可用技能和斜杠命令 | `/skills` |
| `/ide` | — | 管理 IDE 集成（VS Code、JetBrains） | `/ide` |
| `/chrome` | — | 配置 Chrome 浏览器集成 | `/chrome` |
| `/hooks` | — | 查看和配置工具事件 Hook | `/hooks` |
| `/agents` | — | 管理子代理配置 | `/agents` |
| `/install-github-app` | — | 安装 GitHub Actions 应用集成 | `/install-github-app` |
| `/install-slack-app` | — | 安装 Slack 集成应用 | `/install-slack-app` |

### 4.8 代码审查与质量（6 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/review` | — | 审查当前未提交的变更或 GitHub PR | `/review` 或 `/review https://github.com/.../pull/123` |
| `/diff` | — | 交互式差异查看器（未提交的 git 变更和每轮 diff） | `/diff` |
| `/pr-comments [PR]` | — | 获取并显示 GitHub PR 的评论 | `/pr-comments` 或 `/pr-comments 123` |
| `/security-review` | — | 扫描已暂存的变更中的安全漏洞 | `/security-review` |
| `/simplify [重点]` | — | 并行启动 3 个审查代理检查代码复用/质量/效率，自动修复 | `/simplify` |
| `/batch <指令>` | — | 通过 5-30 个并行代理在隔离 git worktree 中执行大规模重构 | `/batch 将所有文件迁移到 src/` |

### 4.9 规划与执行（5 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/plan [描述]` | — | 进入只读计划模式——先分析产出计划，确认后才修改文件 | `/plan 添加用户认证` |
| `/tasks` | — | 查看和管理所有后台任务和子代理进程 | `/tasks` |
| `/schedule [描述]` | — | 创建云端定时任务（Cron 风格，电脑关闭也能运行） | `/schedule 每天健康检查` |
| `/loop [间隔] [提示]` | — | 按间隔重复运行提示或斜杠命令，默认 10 分钟 | `/loop 5m 检查部署状态` |
| `/autofix-pr [提示]` | — | 云端代理监控当前 PR，CI 失败时自动推送修复 | `/autofix-pr` |

### 4.10 实用工具（4 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/copy [N\|w]` | — | 交互式代码块选择器。复制最后回复或写入文件（`w`） | `/copy` 或 `/copy w` |
| `/btw <问题>` | — | 快速提问只读问题，不影响当前工作流（临时、单轮） | `/btw 重试逻辑怎么做？` |
| `/bashes` | — | 列出当前会话中所有运行中的后台 Bash 命令 | `/bashes` |
| `/teleport` | — | 从 Claude Web UI 导入 session.jsonl 继续本地对话 | `/teleport` |

### 4.11 账户与认证（4 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/login` | — | 认证 Anthropic 账户或切换账户 | `/login` |
| `/logout` | — | 断开当前会话的认证连接 | `/logout` |
| `/passes` | — | 与其他用户分享免费的 Claude Code 通行证 | `/passes` |
| `/extra-usage` | — | 配置额外的用量限制 | `/extra-usage` |

### 4.12 跨设备与远程（4 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/mobile` | `/ios` `/android` | 生成二维码在手机 App 上继续当前会话 | `/mobile` |
| `/desktop` | `/app` | 在桌面 App 中继续当前会话 | `/desktop` |
| `/remote-control` | `/rc` | 启用来自 claude.ai 的远程控制模式 | `/remote-control` |
| `/remote-env` | — | 配置默认远程执行环境 | `/remote-env` |

### 4.13 反馈与支持（2 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/feedback` | `/bug` | 直接向 Anthropic 发送反馈或报告 Bug | `/feedback` |
| `/upgrade` | `/update` | 检查 Claude Code 更新并安装 | `/upgrade` |

### 4.14 权限与安全（2 个）

| 命令 | 别名 | 说明 | 用法 |
|------|------|------|------|
| `/permissions` | `/allowed-tools` | 查看或更新工具执行权限 | `/permissions` |
| `/sandbox` | — | 切换沙箱模式以限制工具执行 | `/sandbox` |

---

## 五、已安装插件详解

### 5.1 superpowers@claude-plugins-official（v5.1.0）

**定位**：标准开发流水线，强制执行「头脑风暴 → 制定计划 → TDD → 代码审查」的完整流程。

#### 技能列表（13 个）

| 技能 | 功能说明 | 使用方式 |
|------|----------|----------|
| `brainstorming` | 头脑风暴，充分探索问题空间和解决方案 | `/brainstorming` |
| `writing-plans` | 将方案转化为结构化实施计划（文件清单、接口定义、实施步骤） | `/writing-plans` |
| `executing-plans` | 按批准的计划逐步实施代码变更，每步完成后验证 | `/executing-plans` |
| `test-driven-development` | TDD 红-绿-重构循环：先写测试 → 最小实现 → 重构 | `/test-driven-development` |
| `subagent-driven-development` | 将大型任务分解为子任务，分派给多个子代理并行执行 | `/subagent-driven-development` |
| `systematic-debugging` | 结构化 Bug 排查：复现 → 假设 → 验证 → 确认根因 → 修复 | `/systematic-debugging` |
| `verification-before-completion` | 完成前系统性验证（测试、lint、边界情况、风格一致） | `/verification-before-completion` |
| `requesting-code-review` | 规范化请求 AI 进行代码审查 | `/requesting-code-review` |
| `receiving-code-review` | 按标准流程处理审查反馈，确保每个问题都妥善处理 | `/receiving-code-review` |
| `using-superpowers` | Superpowers 系统的使用引导 | `/using-superpowers` |
| `using-git-worktrees` | Git Worktree 隔离工作流 | `/using-git-worktrees` |
| `finishing-a-development-branch` | 开发完成后的标准化收尾流程（测试、文档、PR） | `/finishing-a-development-branch` |
| `dispatching-parallel-agents` | 高效调度和管理多个并行代理 | `/dispatching-parallel-agents` |

---

### 5.2 frontend-design@claude-plugins-official（b5a156b）

**定位**：前端 UI 设计生成，支持多种设计风格。

#### 技能列表（1 个）

| 技能 | 功能说明 | 使用方式 |
|------|----------|----------|
| `frontend-design` | 生成高质量前端 UI 代码 | 对话中 `@frontend-design 用玻璃态设计登录表单` |

**支持的风格**：玻璃态（Glassmorphism）、工业风（Industrial）、极简主义（Minimalist）、暗黑模式（Dark Mode）、新拟态（Neumorphism）

---

### 5.3 claude-mem@thedotmack（v13.2.0）

**定位**：跨会话记忆系统，自动记录和加载历史上下文。

#### 技能列表（12 个）

| 技能 | 功能说明 | 使用方式 |
|------|----------|----------|
| `do` | 执行通用任务 | `/do 任务描述` |
| `knowledge-agent` | 从已构建的知识语料库中回答特定问题 | `/knowledge-agent 问题` |
| `timeline-report` | 生成项目开发活动时间线报告 | `/timeline-report` |
| `babysit` | 监控指定任务的执行状态并在异常时通知 | `/babysit 任务` |
| `mem-search` | 跨会话搜索历史记忆 | `/mem-search 数据库连接池问题` |
| `how-it-works` | 解释 claude-mem 工作原理 | `/how-it-works` |
| `pathfinder` | 在项目中智能导航和定位 | `/pathfinder 目标` |
| `version-bump` | 管理 claude-mem 版本升级 | `/version-bump` |
| `make-plan` | 基于记忆制定更准确的项目计划 | `/make-plan 目标` |
| `smart-explore` | 基于记忆的智能代码库探索 | `/smart-explore 目标` |
| `learn-codebase` | 一次性学习整个代码库（约 5 分钟处理典型仓库） | `/learn-codebase` |
| `wowerpoint` | 基于项目记忆生成演示文稿 | `/wowerpoint 主题` |

---

### 5.4 ecc@ecc（v2.0.0-rc.1）

**定位**：Everything Claude Code，综合工程系统，200+ 技能覆盖全开发周期。

#### 5.4.1 流程管理（8 个）

| 技能 | 功能说明 |
|------|----------|
| `plan` | 软件架构规划——系统设计、可扩展性决策 |
| `code-review` | 多维度代码审查（安全/逻辑/性能/可维护性） |
| `pr` | PR 创建与管理 |
| `ship` | 测试→审查→推送→创建 PR 一键流程 |
| `checkpoint` | 创建检查点，便于回滚 |
| `evolve` | 技能和配置的进化优化 |
| `feature-dev` | 端到端功能开发流程 |
| `aside` | 旁路任务，不中断主流程 |

#### 5.4.2 质量保障（9 个）

| 技能 | 功能说明 |
|------|----------|
| `quality-gate` | 质量门禁——合并前检查 |
| `security-scan` | 安全漏洞扫描 |
| `security-review` | OWASP Top 10 + 深度安全审计 |
| `test-coverage` | 测试覆盖率分析 |
| `silent-failure-hunter` | 静默失败检测（吞掉的错误、坏的回退） |
| `production-audit` | 生产环境审计 |
| `repo-scan` | 仓库全面健康检查 |
| `comment-analyzer` | 代码注释质量分析 |
| `type-design-analyzer` | 类型设计分析（封装性、不变量表达） |

#### 5.4.3 构建修复（11 个）

| 技能 | 适用 |
|------|------|
| `build-fix` | 通用（自动检测类型） |
| `go-build` | Go |
| `rust-build` | Rust/Cargo |
| `cpp-build` | C++/CMake |
| `java-build` | Java/Maven/Gradle |
| `kotlin-build` | Kotlin/Gradle |
| `swift-build` | Swift/Xcode/SPM |
| `dart-build` | Dart/Flutter |
| `django-build` | Django |
| `gradle-build` | Gradle 专项 |
| `pytorch-build-resolver` | PyTorch/CUDA |

#### 5.4.4 代码审查（17 个，按语言/框架）

| 技能 | 审查重点 |
|------|----------|
| `go-review` | Go 惯用法、并发模式、错误处理 |
| `rust-review` | 所有权/生命周期、unsafe、惯用模式 |
| `python-review` | PEP 8、类型提示、安全性 |
| `typescript-review` | 类型安全、异步正确性、Node/Web 安全 |
| `java-review` | Spring Boot/Quarkus、JPA、安全 |
| `kotlin-review` | 惯用法、协程安全、Compose |
| `cpp-review` | 内存安全、现代 C++、并发 |
| `csharp-review` | .NET 惯例、async 模式、可空引用 |
| `flutter-review` | Widget、状态管理、性能 |
| `swift-review` | 协议导向、值语义、Swift Concurrency |
| `django-review` | ORM、DRF 模式、安全配置 |
| `fastapi-review` | 异步正确性、依赖注入、Pydantic |
| `fsharp-review` | 函数式惯用法、类型安全 |
| `database-reviewer` | PostgreSQL 查询优化、Schema 设计 |
| `healthcare-reviewer` | 临床安全、PHI 合规 |
| `mle-reviewer` | 数据契约、特征管道、训练可复现性 |
| `pr-test-analyzer` | PR 测试覆盖质量 |

#### 5.4.5 测试（10 个）

| 技能 | 领域 |
|------|------|
| `go-test` | Go 测试 |
| `rust-test` | Rust 测试 |
| `cpp-test` | C++ 测试 |
| `kotlin-test` | Kotlin 测试 |
| `flutter-test` | Flutter 测试 |
| `python-testing` | Python 测试 |
| `e2e-runner` | E2E（Playwright + Vercel） |
| `tdd-workflow` | TDD 工作流 |
| `ai-regression-testing` | AI 回归测试 |
| `tdd-guide` | TDD 方法论 |

#### 5.4.6 多代理并行（10 个）

| 技能 | 功能 |
|------|------|
| `loop-start` | 启动自主代理循环 |
| `loop-status` | 查看循环状态 |
| `santa-loop` | Santa 方法循环 |
| `multi-plan` | 多代理并行规划 |
| `multi-execute` | 多代理并行执行 |
| `multi-frontend` | 多前端并行开发 |
| `multi-backend` | 多后端并行开发 |
| `multi-workflow` | 多工作流并行 |
| `autonomous-loops` | 自主循环配置 |
| `continuous-agent-loop` | 持续代理循环 |

#### 5.4.7 前端与设计（11 个）

| 技能 | 领域 |
|------|------|
| `frontend-design-direction` | 设计方向指导 |
| `design-system` | 设计系统构建 |
| `motion-patterns` | 动效模式 |
| `motion-foundations` | 动效基础 |
| `motion-advanced` | 高级动效 |
| `motion-ui` | UI 动效 |
| `ui-demo` | UI 演示生成 |
| `ui-to-vue` | UI 转 Vue 组件 |
| `liquid-glass-design` | 液态玻璃设计风格 |
| `frontend-slides` | 前端演示文稿 |
| `angular-developer` | Angular 专项 |

#### 5.4.8 项目/文档/运维（20+ 个）

| 类别 | 代表技能 |
|------|----------|
| 项目会话管理 | `projects` `project-init` `sessions` `save-session` `resume-session` |
| 文档知识 | `update-docs` `update-codemaps` `doc-updater` `code-tour` `learn` `deep-research` |
| 技能管理 | `skill-create` `skill-health` `skill-stocktake` `skill-scout` `rules-distill` |
| 运维部署 | `pm2` `deployment-patterns` `production-scheduling` `connections-optimizer` `canary-watch` |
| 成本管理 | `context-budget` `token-budget-advisor` `cost-report` `cost-tracking` |

#### 5.4.9 架构与模式（25+ 个）

| 技能 | 领域 |
|------|------|
| `hexagonal-architecture` | 六边形架构 |
| `architecture-decision-records` | 架构决策记录 |
| `backend-patterns` | 后端模式 |
| `frontend-patterns` | 前端模式 |
| `api-design` | API 设计 |
| `golang-patterns` | Go 模式 |
| `rust-patterns` | Rust 模式 |
| `python-patterns` | Python 模式 |
| `kotlin-patterns` | Kotlin 模式 |
| `django-patterns` | Django 模式 |
| `fastapi-patterns` | FastAPI 模式 |
| `springboot-patterns` | Spring Boot 模式 |
| `laravel-patterns` | Laravel 模式 |
| `postgres-patterns` | PostgreSQL 模式 |
| `redis-patterns` | Redis 模式 |
| `docker-patterns` | Docker 模式 |
| `mcp-server-patterns` | MCP Server 模式 |
| `prisma-patterns` | Prisma ORM |
| `mysql-patterns` | MySQL |
| `swiftui-patterns` | SwiftUI |
| `compose-multiplatform-patterns` | Compose Multiplatform |

#### 5.4.10 其他专项领域

| 类别 | 技能 |
|------|------|
| **安全** | `security-review` `security-bounty-hunter` `hipaa-compliance` `healthcare-phi-compliance` |
| **Hook** | `hookify` `hookify-list` `hookify-configure` `hookify-rules` `hookify-help` |
| **PR 流水线** | `prp-pr` `prp-plan` `prp-implement` `prp-prd` `prp-commit` `review-pr` |
| **性能** | `performance-optimizer` `harness-audit` `harness-optimizer` |
| **重构** | `refactor-clean` `code-simplifier` `prune` |
| **Git/项目管理** | `github-ops` `jira` `jira-integration` `git-workflow` |
| **评估** | `benchmark` `agent-eval` `eval-harness` `gan-design` `gan-build` |
| **内容** | `article-writing` `content-engine` `brand-voice` |
| **媒体** | `video-editing` `remotion-video-creation` `manim-video` `fal-ai-media` |
| **SEO/无障碍** | `seo` `accessibility` |
| **数据库** | `database-migrations` `postgres-patterns` `mysql-patterns` `clickhouse-io` |
| **网络** | `network-architect` `network-config-reviewer` `network-troubleshooter` `homelab-*` |
| **开源** | `opensource-forker` `opensource-sanitizer` `opensource-packager` |

---

### 5.5 java-core@java-plugins（v2.2.2）🆕

**定位**：Java 项目核心工具，提供架构审查、构建修复、代码规范等基础能力。支持 Java 8 ~ Java 21。

**来源**：`github:ducpm2303/claude-java-plugins`

#### 技能（14 个）

| 技能 | 领域 |
|------|------|
| 项目结构 | 标准 Java 项目结构设计 |
| 分层架构 | 分层架构模式 |
| 多模块 Maven | Maven 多模块项目管理 |
| 设计模式 | Java 设计模式应用 |
| 构建修复 | Maven/Gradle/javac 构建错误修复 |
| 代码规范 | Java 编码规范和风格 |
| 日志 | Java 日志最佳实践 |
| 异常处理 | 异常处理模式 |
| 集合 | Java 集合框架最佳实践 |
| 流式编程 | Stream API 使用 |
| 并发 | Java 并发编程 |
| 序列化 | JSON/XML 序列化 |
| 日期时间 | Java 时间 API |
| I/O | 文件 I/O 操作 |

#### 代理（2 个）

| 代理 | 职能 |
|------|------|
| `java-architect` | 项目结构、分层架构、设计模式 |
| `java-build-resolver` | Maven/Gradle/javac 构建修复 |

#### 命令（2 个）

| 命令 | 功能 |
|------|------|
| `/java-core:architect-review` | 架构审查 |
| `/java-core:build-fix` | 构建修复 |

---

### 5.6 java-spring@java-plugins（v2.2.2）🆕

**定位**：Spring Boot 专属工具，覆盖项目脚手架、JPA、安全、缓存、AI 集成等全领域。支持 Spring Boot 2.7 ~ 4.0。

**来源**：`github:ducpm2303/claude-java-plugins`

#### 技能（9 个）

| 技能 | 功能说明 |
|------|----------|
| `java-scaffold` | 脚手架新建 Spring Boot 项目（2.7.x ~ 4.0.x） |
| `java-jpa` | JPA 深度审查 — N+1 查询、抓取策略、投影、Specification |
| `java-logging` | 日志审查 — SLF4J、MDC、结构化日志、PII 安全 |
| `java-crud` | 在已有项目中生成完整 CRUD 功能 |
| `java-security` | Spring Security 审查/生成 — JWT、OAuth2、方法安全、CORS（Boot 2.x & 3.x） |
| `java-openapi` | OpenAPI/Swagger 文档生成与审查（springdoc v1/v2） |
| `java-spring-ai` | Spring AI 集成 — ChatClient、RAG、工具调用、记忆（Spring AI 1.x / LangChain4J） |
| `java-resilience` | Resilience4J 模式 — 断路器、重试、限流、舱壁、超时（Boot 2.x & 3.x） |
| `java-cache` | 缓存策略 — Caffeine（单实例）/ Redis（分布式），@Cacheable/@CacheEvict/@CachePut |

#### 代理（1 个）

| 代理 | 职能 |
|------|------|
| `java-spring-expert` | Spring Boot 最佳实践、JPA、Security、REST API |

#### 命令（2 个）

| 命令 | 功能 |
|------|------|
| `/java-spring:run` | 启动 Spring Boot 应用（含环境变量和数据库预检查） |
| `/java-spring:routes` | 扫描 @RestController 打印 REST 端点表 |

---

### 5.7 java-quality@java-plugins（v2.2.2）🆕

**定位**：Java 代码质量保障，安全审查 + 性能优化 + 测试工程三位一体。

**来源**：`github:ducpm2303/claude-java-plugins`

#### 技能（3 个）

| 技能 | 功能 |
|------|------|
| 安全审查 | OWASP Top 10、CWE、注入检测 |
| 性能优化 | JVM 调优、GC 分析、数据库查询优化 |
| 测试策略 | 单元测试、集成测试、测试覆盖率 |

#### 代理（3 个）

| 代理 | 职能 |
|------|------|
| `java-security-reviewer` | 安全漏洞检测与修复 |
| `java-performance-reviewer` | 性能瓶颈分析与优化建议 |
| `java-test-engineer` | 测试策略设计与实施 |

#### 命令（1 个）

| 命令 | 功能 |
|------|------|
| `/java-quality:quality-check` | 综合质量检查 |

---

### 5.8 spring-boot-dev@sivalabs-marketplace（v1.0.0）🆕

**定位**：Spring Boot 应用开发插件，自动生成符合最佳实践的包结构、JPA 实体、Repository、Service、REST Controller。由知名 Spring Boot 作者 K. Siva Prasad Reddy 创建。

**来源**：`github:sivaprasadreddy/sivalabs-marketplace`

#### 技能（5 个）

| 技能 | 功能说明 |
|------|----------|
| `spring-boot-package-structure-creator` | 创建推荐的项目包结构（controller/service/repository/model/dto/config） |
| `jpa-entity-creator` | 创建 JPA 实体类（含 @Entity、@Table、字段映射、关系注解） |
| `spring-data-jpa-repo-creator` | 创建 Spring Data JPA Repository 接口 |
| `spring-service-creator` | 创建 Service 层类（含 @Service、事务管理、DTO 转换） |
| `spring-rest-api-creator` | 创建 Spring MVC REST API Controller（含 @RestController、验证） |

**使用方式**：
```bash
# 在 Claude Code 对话中
请用 CRUD REST API 管理 Person（含 id、name、email、phone 字段）
# Claude 会自动调用 spring-boot-dev 技能生成完整代码
```

---

### 5.9 planning-with-files@planning-with-files（v2.38.1）🆕

**定位**：持久化 Markdown 规划系统，灵感来源于 Manus 风格的持续规划。创建三个 Markdown 文件在上下文窗口外部跟踪任务状态。

**来源**：`github:OthmanAdi/planning-with-files`

#### 命令（2 个）

| 命令 | 功能 |
|------|------|
| `/planning-with-files:plan` | 启动规划模式（自动补全为 `/plan`） |
| `/planning-with-files:start` | 启动完整工作流（自动补全为 `/planning`） |

#### 规划文件

| 文件 | 用途 |
|------|------|
| `task_plan.md` | 任务分解计划 |
| `findings.md` | 分析发现与洞察 |
| `progress.md` | 实施进度追踪 |

#### 机制

通过 Pre/Post/Stop Hooks 自动管理这三个文件，在上下文压缩时依然保留完整的任务状态。

---

### 5.10 ralph-loop@claude-plugins-official（v1.0.0）🆕

**定位**：自主代理迭代循环。灵感来源于 Geoffrey Huntley 首创的 "Ralph Wiggum" 技术——通过 Stop Hook 让 Claude 自我反馈循环，无需外部 bash 脚本驱动。

**来源**：`github:anthropics/claude-plugins-official`（官方维护）

#### 命令（2 个）

| 命令 | 功能 |
|------|------|
| `/ralph-loop` | 启动自主循环，参数：`--max-iterations <n>`（最大迭代次数）、`--completion-promise "<text>"`（完成承诺文本） |
| `/cancel-ralph` | 停止当前循环 |

#### 机制

Stop Hook 在 Claude 尝试退出时拦截，将相同的提示词重新注入当前会话，形成自我参照的反馈循环。Claude 会不断检查 `--completion-promise` 定义的完成条件，直到满足或达到 `--max-iterations` 上限。

**使用示例**：
```bash
/ralph-loop --max-iterations 20 --completion-promise "所有 TODO 项标记为完成"
# 请为 gstack 项目添加用户认证功能
```

---

## 六、已安装用户级 Skill 详解

### 6.1 gstack — 多角色 AI 工程团队（47 个子技能）

**路径**：`~/.claude/skills/gstack/`  
**安装方式**：`git clone https://github.com/garrytan/gstack.git`

#### 规划审查（7 个）

| 技能 | 角色视角 | 功能 |
|------|----------|------|
| `office-hours` | 产品导师 | 产品头脑风暴，梳理需求 |
| `plan-ceo-review` | CEO | 商业战略角度审查方案 |
| `plan-eng-review` | 工程主管 | 技术架构审查 |
| `plan-design-review` | 设计主管 | 用户体验和交互审查 |
| `plan-devex-review` | 开发体验 | DX 审查：API 易用性 |
| `plan-tune` | 优化顾问 | 方案微调和优化 |
| `autoplan` | 自动化 | 自动生成完整项目计划 |

#### 实现审查（7 个）

| 技能 | 功能 |
|------|------|
| `review` | PR 代码审查 |
| `codex` | 代码解释和文档 |
| `investigate` | Bug 调查和根因分析 |
| `design-review` | 设计稿审查 |
| `design-shotgun` | 快速多方案设计探索 |
| `design-html` | 设计稿转 HTML/CSS |
| `devex-review` | 开发者体验审查 |

#### QA 测试（5 个）

| 技能 | 功能 |
|------|------|
| `qa` | 完整 QA（含浏览器 E2E） |
| `qa-only` | 仅浏览器 E2E |
| `scrape` | 网页抓取 |
| `skillify` | 网页功能→技能 |
| `browse` | 浏览器交互 |

#### 浏览器工具（3 个）

| 技能 | 功能 |
|------|------|
| `open-gstack-browser` | 打开 GStack 浏览器 |
| `connect-chrome` | 连接 Chrome 实例 |
| `setup-browser-cookies` | 配置浏览器 Cookies |

#### 发布部署（5 个）

| 技能 | 功能 |
|------|------|
| `ship` | 测试→审查→推送→PR |
| `land-and-deploy` | 合并 PR 并部署 |
| `canary` | 金丝雀发布 |
| `landing-report` | 发布报告 |
| `setup-deploy` | 配置部署流水线 |

#### 文档（3 个）

| 技能 | 功能 |
|------|------|
| `document-release` | Release Notes |
| `document-generate` | 自动生成文档 |
| `make-pdf` | 生成 PDF |

#### 安全（5 个）

| 技能 | 功能 |
|------|------|
| `cso` | OWASP + STRIDE 审计 |
| `careful` | 高风险操作确认 |
| `freeze` | 冻结代码变更 |
| `guard` | 安全守护监控 |
| `unfreeze` | 解冻代码变更 |

#### 记忆协作（7 个）

| 技能 | 功能 |
|------|------|
| `context-save` | 保存会话上下文 |
| `context-restore` | 恢复会话上下文 |
| `learn` | 学习项目知识 |
| `retro` | 回顾总结 |
| `pair-agent` | 配对代理协作 |
| `setup-gbrain` | 配置知识库 |
| `sync-gbrain` | 同步知识库 |

#### 工具（4 个）

| 技能 | 功能 |
|------|------|
| `health` | 系统健康检查 |
| `benchmark` | 性能基准测试 |
| `benchmark-models` | 模型性能对比 |
| `gstack-upgrade` | 版本升级 |

**用法**：在对话中输入对应斜杠命令，如 `/office-hours`、`/review`、`/qa`、`/ship`、`/cso`。

---

### 6.2 find-skills — 技能发现

**路径**：`~/.claude/skills/find-skills/`  
**功能**：帮助用户搜索开源技能生态中可安装的技能。  
**触发**：用户询问如「有没有 X 技能」「帮我找 X 技能」时自动触发。  
**用法示例**：`有没有部署到 AWS 的技能？`

---

### 6.3 supabase — Supabase 平台操作

**路径**：`~/.claude/skills/supabase/`  
**安装**：`npx skills add supabase/agent-skills`  
**功能**：Supabase 平台安全操作最佳实践（数据库、Auth、Storage、Edge Functions、Realtime）。

---

### 6.4 supabase-postgres-best-practices — PG 最佳实践

**路径**：`~/.claude/skills/supabase-postgres-best-practices/`  
**功能**：PostgreSQL 最佳实践，覆盖 7 个领域：

| 参考文件 | 内容 |
|----------|------|
| `conn-pooling.md` | 连接池管理（PgBouncer 配置） |
| `conn-prepared-statements.md` | 预编译语句 |
| `security-rls-basics.md` | Row Level Security 基础 |
| `security-rls-performance.md` | RLS 性能优化 |
| `data-pagination.md` | 数据分页（Keyset vs Offset） |
| `lock-advisory.md` | 咨询锁 |
| `lock-short-transactions.md` | 短事务与锁优化 |

---

### 6.5 code-simplifier — 代码简化与质量检查 🆕

**路径**：`~/.claude/skills/code-simplifier/`
**安装**：`npm install -g @adonis0123/code-simplifier`
**功能**：代码简化、重复检测、可维护性改进。每次 Write/Edit 操作后自动提醒进行质量检查。
**用法**：在对话中输入 `/code-simplifier` 启动代码简化流程。

---

## 七、MCP 服务详解

当前 13 个 MCP 服务全部运行中。

### 7.1 claude-mem（来源：claude-mem 插件）

跨会话记忆管理和智能代码探索。

| 工具 | 功能 |
|------|------|
| `search` | 语义搜索记忆索引 |
| `timeline` | 获取记忆前后上下文 |
| `get_observations` | 获取记忆完整详情 |
| `smart_search` | AST 级别代码符号搜索 |
| `smart_outline` | 文件结构概览（折叠函数体） |
| `smart_unfold` | 展开符号查看完整源码 |
| `build_corpus` | 构建知识语料库 |
| `prime_corpus` | 激活知识库 |
| `query_corpus` | 向知识库提问 |
| `memory_add` | 手动添加记忆 |

### 7.2 context7（来源：ecc 插件）

实时库/框架文档查询。

| 工具 | 功能 |
|------|------|
| `resolve-library-id` | 解析库名称为 Context7 ID |
| `query-docs` | 查询文档获取代码示例 |

### 7.3 exa（来源：ecc 插件）

Web 搜索和内容提取。

| 工具 | 功能 |
|------|------|
| `web_search_exa` | 语义搜索网页内容 |
| `web_fetch_exa` | 读取网页完整内容（Markdown 格式） |

### 7.4 github（来源：ecc 插件）

GitHub 全功能操作（25+ 工具）。

| 类别 | 工具 |
|------|------|
| PR | `create_pr` `get_pr` `get_pr_files` `get_pr_reviews` `get_pr_comments` `get_pr_status` `create_pr_review` `merge_pr` `update_pr_branch` `list_prs` |
| Issue | `create_issue` `get_issue` `list_issues` `update_issue` `add_issue_comment` `search_issues` |
| 仓库 | `create_repository` `fork_repository` `search_repositories` `list_commits` |
| 代码 | `search_code` `get_file_contents` `create_or_update_file` `push_files` `create_branch` |
| 用户 | `search_users` |

### 7.5 playwright（来源：ecc 插件）

浏览器自动化（20+ 工具）。

| 类别 | 工具 |
|------|------|
| 导航 | `browser_navigate` `browser_navigate_back` |
| 交互 | `browser_click` `browser_type` `browser_fill_form` `browser_select_option` `browser_hover` `browser_drag` |
| 键盘 | `browser_press_key` |
| 截图 | `browser_snapshot` `browser_take_screenshot` |
| 脚本 | `browser_evaluate` `browser_run_code` |
| 文件 | `browser_file_upload` |
| 监控 | `browser_network_requests` `browser_console_messages` |
| 管理 | `browser_tabs` `browser_resize` `browser_wait_for` `browser_handle_dialog` `browser_close` |

### 7.6 memory（来源：ecc 插件）

知识图谱 CRUD。

| 工具 | 功能 |
|------|------|
| `create_entities` | 创建知识实体 |
| `open_nodes` | 打开节点查看 |
| `search_nodes` | 搜索图谱节点 |
| `read_graph` | 读取整个图谱 |
| `create_relations` | 创建实体关系 |
| `add_observations` | 为实体添加观察 |
| `delete_entities` | 删除实体 |
| `delete_observations` | 删除观察 |
| `delete_relations` | 删除关系 |

### 7.7 sequential-thinking（来源：ecc 插件）

结构化思维链推理。

| 工具 | 功能 |
|------|------|
| `sequentialthinking` | 支持分支、修正、反思的多步骤推理 |

### 7.8 context7 (SivaLabs)（来源：spring-boot-dev 插件）🆕

实时 Spring Boot 文档查询。

| 工具 | 功能 |
|------|------|
| `resolve-library-id` | 解析库名称为 Context7 ID |
| `query-docs` | 查询 Spring Boot / JPA / 相关库文档 |

### 7.9 db-analyzer（手动配置）🆕

**版本**：0.2.14 | **命令**：`npx -y mcp-db-analyzer`

数据库结构分析与优化。

| 能力 | 说明 |
|------|------|
| Schema 分析 | PostgreSQL / MySQL / SQLite 表结构分析 |
| 索引优化 | 索引建议、冗余索引检测 |
| 查询计划 | EXPLAIN 查询计划检查 |
| 表关系 | 外键关系图、缺失索引 |

### 7.10 jvm-diagnostics（手动配置）🆕

**版本**：0.1.14 | **命令**：`npx -y mcp-jvm-diagnostics`

JVM 诊断与调优。

| 能力 | 说明 |
|------|------|
| 线程分析 | Thread dump 解析、线程状态统计 |
| 死锁检测 | 自动检测循环等待 |
| GC 日志 | GC 日志解析、内存分配分析 |
| 调优建议 | 基于诊断结果的 JVM 参数优化 |

### 7.11 migration-advisor（手动配置）🆕

**版本**：0.2.14 | **命令**：`npx -y mcp-migration-advisor`

数据库迁移风险分析。

| 能力 | 说明 |
|------|------|
| Flyway 支持 | Flyway SQL/Java 迁移脚本分析 |
| Liquibase 支持 | XML/YAML/SQL changelog 分析 |
| 锁检测 | 检测潜在的表锁和迁移冲突 |
| 冲突分析 | 多分支迁移合并冲突检测 |

### 7.12 spring-boot-actuator（手动配置）🆕

**版本**：0.1.14 | **命令**：`npx -y mcp-spring-boot-actuator`

Spring Boot Actuator 端点分析。

| 能力 | 说明 |
|------|------|
| Health 分析 | 健康检查端点诊断 |
| Metrics 分析 | 指标数据解析与趋势 |
| Environment 分析 | 环境变量和配置审查 |
| Bean 诊断 | Spring Bean 依赖图和状态 |

### 7.13 redis-diagnostics（手动配置）🆕

**版本**：0.1.14 | **命令**：`npx -y mcp-redis-diagnostics` | **环境变量**：`REDIS_URL=redis://localhost:6379`

Redis 实例诊断。

| 能力 | 说明 |
|------|------|
| 内存分析 | 内存使用、碎片率、淘汰策略 |
| 慢日志 | 慢查询日志分析 |
| 客户端连接 | 连接数、空闲连接、超时 |
| Keyspace 健康 | 键分布、过期键、大键检测 |

---

## 八、快捷键与交互技巧

### 8.1 基本快捷键

| 快捷键 | 功能 |
|--------|------|
| `Enter` | 发送消息 |
| `Shift + Enter` | 换行 |
| `↑ / ↓` | 浏览历史命令 |
| `Tab` | 自动补全（输入 `/` 后按 Tab 查看所有命令） |
| `Ctrl + C` | 中断当前操作 |
| `Ctrl + D` | 退出会话 |
| `Ctrl + L` | 清屏 |
| `Ctrl + R` | 搜索历史命令 |

### 8.2 最佳实践

#### 通用开发

| 场景 | 推荐命令 |
|------|----------|
| 新功能设计 | `/brainstorming` → `/writing-plans` → `/executing-plans` |
| Bug 修复 | `/systematic-debugging` |
| 提交前 | `/security-review` → `/review` |
| 大型重构 | `/batch 指令` |
| 查看技能 | `/skills` 或按 Tab |
| 查看费用 | `/cost` |
| 查看上下文 | `/context` |

#### Java / Spring Boot 开发 🆕

| 场景 | 推荐命令/操作 |
|------|--------------|
| 新建 Spring Boot 项目 | `/java-spring:java-scaffold` 或 `spring-boot-dev:spring-boot-package-structure-creator` |
| 生成 CRUD 功能 | `/java-spring:java-crud` + `spring-boot-dev:jpa-entity-creator` |
| 代码架构审查 | `/java-core:architect-review` |
| 构建修复 | `/java-core:build-fix` |
| 安全审查 | `/java-quality:quality-check`（调用 java-security-reviewer） |
| JPA 性能优化 | `/java-spring:java-jpa` |
| Spring Security 配置 | `/java-spring:java-security` |
| 数据库迁移风险分析 | 对话中触发 `migration-advisor` MCP |
| JVM 故障诊断 | 对话中触发 `jvm-diagnostics` MCP |
| 缓存策略 | `/java-spring:java-cache` |
| 综合质量保障 | `/java-quality:quality-check` |

#### 持久化规划与自主循环 🆕

| 场景 | 推荐命令 |
|------|----------|
| 持久化任务规划 | `/planning-with-files:plan`（自动管理 task_plan.md / findings.md / progress.md） |
| 启动规划工作流 | `/planning-with-files:start` |
| 自主迭代执行 | `/ralph-loop --max-iterations 20 --completion-promise "所有测试通过"` |
| 停止自主循环 | `/cancel-ralph` |
