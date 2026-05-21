# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在此仓库中工作时提供指引。

## 工作区说明

当前工作区根目录为 `/opt/devs/projects/claude`，实际项目代码位于 `gstack/` 子目录。开发 gstack 项目时请先 `cd gstack`，并阅读 `gstack/CLAUDE.md` 了解完整的开发命令、架构和规范。

## 当前已安装能力概览

| 类别 | 数量 | 详情 |
|------|------|------|
| 插件 | 10 个 | superpowers / frontend-design / claude-mem / ecc / java-core / java-spring / java-quality / spring-boot-dev / planning-with-files / ralph-loop |
| 用户级 Skill | 7 个 | gstack (47 子技能) / find-skills / supabase / supabase-postgres-best-practices / code-simplifier / ui-ux-pro-max / learned |
| MCP 服务 | 13 个 | claude-mem / context7×2 / exa / github / playwright / memory / sequential-thinking / db-analyzer / jvm-diagnostics / migration-advisor / spring-boot-actuator / redis-diagnostics |
| npm 全局包 | 5 个 | code-simplifier / mcp-java-backend-suite / claude-projects / ezvibe / open-claude-remote |
| 市场源 | 6 个 | claude-plugins-official / thedotmack / ecc / sivalabs-marketplace / java-plugins / planning-with-files |

完整清单见 `INSTALLED.md`，详细使用手册见 `INSTALLED-INFO.md`，开发方法论见 `develop.md`。

## 安装脚本

```bash
# 一键安装全部核心能力（幂等，可重复运行，含安装 + 升级）
bash scripts/install.sh

# 仅检查/升级已安装组件
bash scripts/install.sh --upgrade
```

## 核心开发技能

### 1. Superpowers — 标准开发流水线
强制执行「头脑风暴 → 制定计划 → TDD → 代码审查」的完整开发流程。**已安装 v5.1.0。**

可用子命令：`/brainstorming`、`/writing-plans`、`/executing-plans`、`/test-driven-development`、`/systematic-debugging`、`/verification-before-completion`、`/requesting-code-review`、`/receiving-code-review`、`/using-git-worktrees`、`/finishing-a-development-branch`、`/dispatching-parallel-agents`、`/subagent-driven-development`

### 2. GStack — 多角色 AI 工程团队
模拟 CEO、架构师、工程师、设计师、QA、安全官等 23 种角色，用不同视角处理开发任务。**已安装，47 个子技能。**

常用命令：
- `/office-hours` — 产品头脑风暴
- `/plan-ceo-review` — CEO 视角战略审查
- `/plan-eng-review` — 架构方案审查
- `/review` — PR 代码审查
- `/qa` — 浏览器 E2E 测试
- `/ship` — 测试、审查、推送、创建 PR
- `/cso` — OWASP + STRIDE 安全审计

完整技能列表见安装后的 `/help` 输出。

### 3. Everything Claude Code (ecc) — 200+ 技能合集
综合工程系统，Anthropic 黑客松冠军作品。**已安装 v2.0.0-rc.1。**

覆盖：18 种语言代码审查、13 种语言构建修复、10 种测试框架、多代理并行、25+ 架构模式、安全审计、PR 流水线、前端设计系统、E2E 测试、Hook 管理、性能优化、网络诊断、开源工具链等。

### 4. Code Review — 多维度自动化审查
Claude Code 内置 + `ecc:code-review` + `superpowers:requesting-code-review` + `superpowers:receiving-code-review`。从安全性、逻辑、性能、可维护性等维度审查代码。

附加审查能力：`ecc:security-review`、`ecc:silent-failure-hunter`、`ecc:comment-analyzer`、`ecc:type-design-analyzer`

### 5. Security Guidance — 安全编码助手
实时检测 SQL 注入、XSS、命令注入等安全风险。已内置于 Claude Code + `ecc:security-scan` + `ecc:security-bounty-hunter` + `gstack:cso`（OWASP + STRIDE）。

## 长期记忆

### 6. claude-mem — 跨会话记忆
让 Claude Code 记住之前的架构决策、修复过的 bug、项目偏好等，在新会话中自动加载。**已安装 v13.2.0。**

查询历史：`我们之前是怎么解决数据库连接池耗尽问题的？`

## 领域专项技能

### 7. frontend-design — 前端 UI 设计
支持玻璃态、工业风、极简主义、暗黑模式、新拟态。**已安装。** + `ecc:frontend-design-direction`、`ecc:design-system`、`ecc:liquid-glass-design`、`ecc:motion-*` 族。

### 8. Agent Browser — 浏览器自动化
控制无头浏览器执行页面导航、点击、填表、截图等操作。**已通过 Playwright MCP（20+ 工具）覆盖。** + `ecc:browser-qa` + `ecc:e2e-runner` + `gstack:browse` + `gstack:qa`

### 9. GitHub 集成
**已通过 GitHub MCP（25+ 工具）覆盖。** 管理 Issues、PR、搜索仓库、推送文件。

### 10. Supabase
**已安装** supabase 和 supabase-postgres-best-practices 两个技能。

## Java / Spring Boot 专属

### 11. java-core — Java 核心工具
**已安装 v2.2.2。** 14 个技能：项目结构、分层架构、多模块 Maven、设计模式、构建修复、代码规范、日志、异常处理、集合框架、Stream API、并发、序列化、日期时间、I/O。

代理：`java-architect`（架构设计）、`java-build-resolver`（构建修复）

### 12. java-spring — Spring Boot 专属
**已安装 v2.2.2。** 9 个技能：`java-scaffold`、`java-jpa`、`java-logging`、`java-crud`、`java-security`、`java-openapi`、`java-spring-ai`、`java-resilience`、`java-cache`。

代理：`java-spring-expert`

### 13. java-quality — Java 质量保障
**已安装 v2.2.2。** 3 个代理：`java-security-reviewer`、`java-performance-reviewer`、`java-test-engineer`

### 14. spring-boot-dev — Spring Boot 代码生成
**已安装 v1.0.0。** 5 个技能：包结构创建 → JPA 实体 → Repository → Service → REST Controller

## 流程增强

### 15. planning-with-files — 持久化规划
**已安装 v2.38.1。** 通过 `task_plan.md`、`findings.md`、`progress.md` 三个文件在上下文外跟踪任务状态。

命令：`/planning-with-files:plan`、`/planning-with-files:start`

### 16. ralph-loop — 自主迭代循环
**已安装 v1.0.0。** Stop Hook 拦截退出并重新注入提示词，形成自我反馈循环。

命令：`/ralph-loop --max-iterations <n> --completion-promise "<text>"`、`/cancel-ralph`

## MCP 诊断服务

| MCP Server | 用途 |
|------------|------|
| `db-analyzer` | PostgreSQL/MySQL/SQLite schema 分析、索引优化、EXPLAIN 查询计划 |
| `jvm-diagnostics` | JVM 线程 dump、死锁检测、GC 日志分析、调优建议 |
| `migration-advisor` | Flyway/Liquibase 迁移风险分析、锁冲突检测、回滚生成 |
| `spring-boot-actuator` | Health/Metrics/Env/Beans/Caches/Startup 端点诊断 |
| `redis-diagnostics` | Redis 内存分析、慢日志、客户端连接、Keyspace 健康 |

## 多实例管理与协作

| 工具 | 用途 |
|------|------|
| **claude-projects** | 多项目集中管理（`ccode my-app "任务" --background`）|
| **EZVibe** | Web 可视化管理面板（`ezvibe start`）|
| **open-claude-remote** | 手机扫码远程监控 Claude Code |
| **Claude Code 内置** | Subagents 子代理系统、Git Worktree（`claude --worktree`）|

## 按场景推荐组合

| 场景 | 推荐组合 |
|------|---------|
| 新手入门 | Superpowers + claude-mem + planning-with-files |
| 代码质量保障 | Superpowers + ecc:code-review + ecc:security-scan + GStack |
| Java/Spring Boot | java-core + java-spring + java-quality + spring-boot-dev + db-analyzer + jvm-diagnostics |
| 前端开发 | frontend-design + ecc:frontend-design-direction + Playwright MCP |
| 多项目管理 | claude-projects + Git Worktree + planning-with-files |
| 团队协作 | GitHub MCP + ecc:pr + GStack + claude-mem |
| 全面武装 | 全部 10 插件 + 7 Skill + 13 MCP |

## 安装验证

```bash
claude plugin list                          # 查看已安装插件（10 个）
claude plugin marketplace list              # 查看已配置市场（6 个）
claude mcp list                             # 查看 MCP 服务器状态（13 个）
ls ~/.claude/skills/                        # 查看用户级 Skill
npm list -g --depth=0                       # 查看全局 npm 包
bash scripts/install.sh                     # 一键安装（含安装 + 升级）
```

在对话中输入 `/help` 查看已安装的技能列表。如果技能未出现，检查：
1. 技能目录是否存在且路径正确
2. SKILL.md 文件格式是否正确
3. 重启 Claude Code 使新技能生效

## 配置模板包

`scripts/claude/` 目录提供可复用的 Claude Code 项目配置模板，可直接复制到目标项目使用：

| 模板文件 | 用途 | 说明 |
|----------|------|------|
| `claude.md` | 项目行为规范模板 | 含编码规范、操作约束、输出格式 |
| `.mcp.json` | 项目级 MCP 配置 | 数据库、文件系统等外部服务连接 |
| `settings.local.json` | 权限白名单模板 | 使用真实 `permissions.allow/deny` 格式 |
| `skills/*.md` | 技术栈技能模板 | Go 微服务、Java Spring Boot、React/Vue3 TS、Python FastAPI |
| `hooks/README.md` | Hook 正确配置指南 | 纠正真实事件名（PreToolUse 非 onBeforeWriteFile）和 Shell 命令配置方式 |
| `agents/README.md` | Agent 正确使用指南 | 纠正调用方式（Agent 工具 非 /agent 命令） |
| `memory/memory.md` | 项目长期记忆模板 | 含 frontmatter 格式的项目信息/编码约定/迭代规则 |

### 关键纠正

常见教程中的以下写法**不正确**：
- ❌ `enablePlugins: true` → ✅ `enabledPlugins: { "name@market": true }`（对象格式）
- ❌ Hook 事件 `onBeforeWriteFile` → ✅ `PreToolUse`, `PostToolUse`, `SessionStart` 等
- ❌ Hook 是 JS module.exports → ✅ 是 settings.json 中的 Shell 命令 `type: "command"`
- ❌ `/agent explore 需求` → ✅ 使用 `Agent` 工具 + `subagent_type` 参数
- ❌ 目录 `~/.claude/agents/`、`~/.claude/plugins-config/` → ✅ 实际不存在
