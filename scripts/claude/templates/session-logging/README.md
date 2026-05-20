# 会话日志模板包 — Session Logging Template

开发全流程自动记录系统。安装到目标项目后，每次执行 `/brainstorming`、`/tdd`、`/code-review` 等命令时，自动将结果写入 `docs/sessions/{日期}/` 对应文件。

## 快速安装

```bash
# 1. 复制配置文件到目标项目
cp templates/session-logging/settings.local.json <目标项目>/.claude/
cat templates/session-logging/CLAUDE.md.snippet >> <目标项目>/CLAUDE.md

# 2. 复制 Hook 脚本并赋予执行权限
cp -r templates/session-logging/hooks/ <目标项目>/.claude/
chmod +x <目标项目>/.claude/hooks/session-logger.sh

# 3. 复制 ADR 模板和 Bug 追踪模板
cp templates/session-logging/adr/_template.md <目标项目>/docs/adr/
cp templates/session-logging/bugs/active.md <目标项目>/docs/bugs/

# 4. 创建目录结构
mkdir -p <目标项目>/docs/sessions
mkdir -p <目标项目>/docs/adr
mkdir -p <目标项目>/docs/bugs
mkdir -p <目标项目>/docs/releases
```

## 工作原理

```
用户执行 /brainstorming
       │
       ▼
Claude Code 调用 Skill 工具
       │
       ▼
PostToolUse Hook 触发 ──→ session-logger.sh skill
       │                        │
       │                  提取 skill 名称
       │                  按路由表匹配
       │                        │
       ▼                        ▼
AI 继续下一步         docs/sessions/2026-05-20/01-brainstorming.md
```

### 两层分工

| 层 | 机制 | 职责 |
|----|------|------|
| Hook 层 | `PostToolUse` 自动拦截 | 捕获 Skill/Agent 执行结果，写入日志文件 |
| AI 层 | `CLAUDE.md` 指令驱动 | 更新 task_plan/findings/progress，写入 ADR，记录 bug |

## 文件结构

```
项目根目录/
├── docs/
│   ├── sessions/                   # Hook 自动捕获
│   │   └── 2026-05-20/            # 按日期分目录
│   │       ├── _index.md           # 当日命令执行索引
│   │       ├── 01-brainstorming.md # 头脑风暴/需求讨论
│   │       ├── 02-strategy.md      # CEO/战略审查
│   │       ├── 03-architecture.md  # 架构设计/工程审查
│   │       ├── 04-plan.md          # 实施计划
│   │       ├── 05-tdd.md           # TDD 实现
│   │       ├── 06-review.md        # 代码审查
│   │       ├── 07-verification.md  # 验证
│   │       ├── 08-security.md      # 安全审计
│   │       ├── 09-loop.md          # 自主循环
│   │       ├── 10-session-log.md   # 未匹配的 Skill/Agent（兜底）
│   │       └── _summary.md         # 会话摘要（Stop hook 自动生成）
│   ├── adr/                        # 架构决策记录（AI 主动写入）
│   │   ├── _template.md
│   │   └── 001-选择Room作为数据库层.md
│   ├── bugs/                       # Bug 追踪（AI 主动写入）
│   │   └── active.md
│   └── releases/                   # 发布记录
├── task_plan.md                    # planning-with-files 管理
├── findings.md
├── progress.md
├── .claude/
│   ├── settings.local.json         # Hook 配置
│   └── hooks/
│       └── session-logger.sh       # 路由脚本
└── CLAUDE.md
```

## 路由规则

| 命令 | 目标文件 |
|------|---------|
| `/brainstorming` `/office-hours` `:brainstorming` | `01-brainstorming.md` |
| `/plan-ceo-review` `:plan-ceo-review` | `02-strategy.md` |
| `/plan-eng-review` `/plan-design-review` `:plan-eng-review` `:plan-design-review` | `03-architecture.md` |
| `/writing-plans` `/planning-with-files:plan` `:make-plan` `:writing-plans` | `04-plan.md` |
| `/test-driven-development` `:test-driven-development` `:tdd-workflow` | `05-tdd.md` |
| `/code-review` `/requesting-code-review` `/receiving-code-review` `:code-review` | `06-review.md` |
| `/verification-before-completion` `:verification-before-completion` | `07-verification.md` |
| `/security-review` `/security-scan` `:security-scan` `:security-review` | `08-security.md` |
| `/ralph-loop` `:ralph-loop` `:loop-start` | `09-loop.md` |
| 其他未匹配的 Skill/Agent | `10-session-log.md` |
| 会话结束（Stop hook） | `_summary.md` |

## 阶段衔接规则（AI 主动行为）

CLAUDE.md 中约定的规则，AI 在每个阶段完成后自动执行：

1. **规划完成后**：确保 `task_plan.md` 任务可追踪
2. **TDD 每完成一个任务**：在 `task_plan.md` 中标记 `[x]`，在 `progress.md` 追加进度
3. **代码审查完成后**：问题写入 `findings.md`
4. **验证完成后**：更新 `progress.md` 最终状态
5. **产生重大技术决策时**：写入 `docs/adr/`，编号递增
6. **发现 bug 时**：写入 `docs/bugs/active.md`
7. **安全扫描发现漏洞时**：写入 `findings.md`，严重问题标 `**严重**`

## 自定义

### 修改输出目录

编辑 `.claude/hooks/session-logger.sh`，修改 `LOG_DIR`：

```bash
LOG_DIR="$PROJECT_ROOT/history/ai-sessions/$DATE"  # 自定义路径
```

### 添加新的路由

编辑 `session-logger.sh` 中的 `route_target()` 函数，添加新的 case。

### 添加新的 Hook 事件

编辑 `.claude/settings.local.json`，在 `hooks` 中添加新的事件类型。可用事件：

| 事件 | 时机 |
|------|------|
| `PreToolUse` | 工具调用前（可拦截） |
| `PostToolUse` | 工具调用后 |
| `SessionStart` | 会话启动 |
| `Stop` | Agent 停止响应 |
| `PreCompact` | 上下文压缩前 |
| `UserPromptSubmit` | 用户提交提示词 |

## 依赖

- Bash 4.0+
- `jq`（可选，JSON 解析；无 `jq` 时自动回退到 `python3`）
- Git（用于定位项目根目录）
