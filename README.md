# Claude Code 完整能力总览

> 更新日期：2026-05-19

---

## 一、基础设施

| 项目 | 版本/值 |
|------|----------|
| Claude Code | 2.1.143 |
| 模型后端 | DeepSeek (deepseek-v4-pro / deepseek-v4-flash) |
| Node.js | v24.14.1 |
| Java | GraalVM 21.0.2 |

---

## 二、插件（10 个）

### 1. superpowers — v5.1.0

标准开发流水线，强制执行「头脑风暴 → 制定计划 → TDD → 代码审查」流程。

**13 个技能**：`brainstorming` `writing-plans` `executing-plans` `test-driven-development` `subagent-driven-development` `systematic-debugging` `verification-before-completion` `requesting-code-review` `receiving-code-review` `using-superpowers` `using-git-worktrees` `finishing-a-development-branch` `dispatching-parallel-agents`

### 2. frontend-design — 4bf0858

前端 UI 设计生成，支持玻璃态、工业风、极简、暗黑模式、新拟态。1 个技能：`frontend-design`

### 3. claude-mem — v13.2.0

跨会话长期记忆系统，自动记录和加载历史上下文。12 个技能：`do` `knowledge-agent` `timeline-report` `babysit` `mem-search` `how-it-works` `pathfinder` `version-bump` `make-plan` `smart-explore` `learn-codebase` `wowerpoint`

### 4. ecc — v2.0.0-rc.1

Everything Claude Code，200+ 技能覆盖全开发周期。流程管理、质量保障、18 种语言代码审查、13 种语言构建修复、10 种测试框架、多代理并行、前端设计系统、25+ 架构模式、安全审计、PR 流水线、E2E 测试、SEO/无障碍、性能优化、Hook 管理、网络诊断、开源工具链等。

### 5. java-core — v2.2.2

Java 项目核心工具（Java 8 ~ 21）。14 个技能：项目结构、分层架构、多模块 Maven、设计模式、构建修复、代码规范、日志、异常处理、集合框架、Stream API、并发、序列化、日期时间、I/O。2 个代理：`java-architect` `java-build-resolver`

### 6. java-spring — v2.2.2

Spring Boot 专属（Boot 2.7 ~ 4.0）。9 个技能：`java-scaffold` `java-jpa` `java-logging` `java-crud` `java-security` `java-openapi` `java-spring-ai` `java-resilience` `java-cache`。代理：`java-spring-expert`

### 7. java-quality — v2.2.2

代码质量三位一体。3 个代理：`java-security-reviewer` `java-performance-reviewer` `java-test-engineer`

### 8. spring-boot-dev — v1.0.0

Spring Boot 代码自动生成。5 个技能：包结构创建 → JPA 实体 → Repository → Service → REST Controller

### 9. planning-with-files — v2.38.1

持久化 Markdown 规划系统。创建 `task_plan.md` `findings.md` `progress.md` 三文件跟踪任务状态。命令：`/planning-with-files:plan` `/planning-with-files:start`

### 10. ralph-loop — v1.0.0

自主代理迭代循环。Stop Hook 拦截退出并重新注入提示词，形成自我反馈循环。命令：`/ralph-loop` `/cancel-ralph`。参数：`--max-iterations` `--completion-promise`

---

## 三、用户级 Skill（5 个 + 1 空目录）

| Skill | 能力 |
|-------|------|
| **gstack** | 多角色 AI 工程团队（23 角色），47 子技能 |
| **find-skills** | 搜索和发现开源生态中可安装的技能 |
| **supabase** | Supabase 平台操作（DB/Auth/Storage/Edge Functions/Realtime） |
| **supabase-postgres-best-practices** | PG 最佳实践：连接池、RLS、分页、锁 |
| **code-simplifier** | 代码简化与质量检查 |
| learned | 空目录，插件自动创建，不提供技能 |

### GStack 子技能（47 个）

| 类别 | 技能 |
|------|------|
| 规划审查（7） | `office-hours` `plan-ceo-review` `plan-eng-review` `plan-design-review` `plan-devex-review` `plan-tune` `autoplan` |
| 实现审查（7） | `review` `codex` `investigate` `design-review` `design-shotgun` `design-html` `devex-review` |
| QA 测试（5） | `qa` `qa-only` `scrape` `skillify` `browse` |
| 浏览器工具（3） | `open-gstack-browser` `connect-chrome` `setup-browser-cookies` |
| 发布部署（5） | `ship` `land-and-deploy` `canary` `landing-report` `setup-deploy` |
| 文档（3） | `document-release` `document-generate` `make-pdf` |
| 安全（5） | `cso` `careful` `freeze` `guard` `unfreeze` |
| 记忆协作（7） | `context-save` `context-restore` `learn` `retro` `pair-agent` `setup-gbrain` `sync-gbrain` |
| 工具（4） | `health` `benchmark` `benchmark-models` `gstack-upgrade` |

---

## 四、MCP 服务（13 个，全部运行中）

### 开发工具

| MCP Server | 来源 | 能力 |
|------------|------|------|
| **github** | ecc | PR/Issue 管理、代码搜索、文件推送、仓库操作（25+ 工具） |
| **context7** (ecc) | ecc | 实时库/框架文档查询 |
| **context7** (SivaLabs) | spring-boot-dev | Spring Boot 文档查询 |
| **playwright** | ecc | 浏览器自动化：导航、点击、填表、截图、E2E 测试（20+ 工具） |

### 代码探索与记忆

| MCP Server | 来源 | 能力 |
|------------|------|------|
| **claude-mem** | claude-mem | AST 级符号搜索、语义记忆搜索、知识语料库构建与查询 |
| **memory** | ecc | 知识图谱 CRUD：实体、关系、观察 |
| **sequential-thinking** | ecc | 结构化多步思维链推理（分支、修正、反思） |

### 搜索

| MCP Server | 来源 | 能力 |
|------------|------|------|
| **exa** | ecc | 语义 Web 搜索、网页内容提取（Markdown） |

### Java 诊断（手动配置）

| MCP Server | 版本 | 能力 |
|------------|------|------|
| **db-analyzer** | 0.2.14 | PostgreSQL/MySQL/SQLite：Schema 分析、索引优化、EXPLAIN 查询计划 |
| **jvm-diagnostics** | 0.1.14 | 线程 dump 分析、死锁检测、GC 日志诊断、调优建议 |
| **migration-advisor** | 0.2.14 | Flyway/Liquibase 迁移风险分析、锁冲突检测 |
| **spring-boot-actuator** | 0.1.14 | Health/Metrics/Env/Beans/Caches/Startup 端点诊断 |
| **redis-diagnostics** | 0.1.14 | Redis：内存分析、慢日志、客户端连接、Keyspace 健康 |

---

## 五、npm 全局包（5 个相关）

| 包 | 版本 | 用途 |
|----|------|------|
| `@adonis0123/code-simplifier` | 1.1.2 | 代码简化与质量检查 |
| `mcp-java-backend-suite` | 0.1.40 | Java 后端 MCP 套件（含 5 子服务器） |
| `claude-projects` | 0.2.4 | 多项目集中管理（`ccode` 命令） |
| `ezvibe` | 0.3.1 | Web 可视化管理面板 |
| `open-claude-remote` | 0.1.1 | 手机扫码远程监控 Claude Code |

---

## 六、市场源（6 个）

| 市场 | 仓库 |
|------|------|
| `claude-plugins-official` | github:anthropics/claude-plugins-official |
| `thedotmack` | github:thedotmack/claude-mem |
| `ecc` | github:affaan-m/everything-claude-code |
| `sivalabs-marketplace` | github:sivaprasadreddy/sivalabs-marketplace |
| `java-plugins` | github:ducpm2303/claude-java-plugins |
| `planning-with-files` | github:OthmanAdi/planning-with-files |

---

## 七、按场景的能力速查

| 场景 | 可用能力 |
|------|----------|
| **Java/Spring Boot** | 项目脚手架、CRUD 生成、JPA 审查、Security 配置、API 文档、缓存策略、Resilience4J、Spring AI 集成、构建修复 |
| **代码审查** | 18 种语言专项审查、OWASP Top 10 安全扫描、静默失败检测、注释质量分析 |
| **测试** | TDD 工作流、单元/集成/E2E 测试、浏览器自动化（Playwright）、覆盖率分析 |
| **数据库** | Schema 分析、索引优化、迁移风险审查、Redis 诊断、表膨胀检测 |
| **JVM 诊断** | 线程 dump/死锁分析、GC 日志解析、JFR 飞行记录、JVM 调优 |
| **前端开发** | 多风格 UI 设计、设计系统构建、E2E 测试 |
| **DevOps** | PR 全流程管理、一键发布、金丝雀部署、PM2、Docker 模式 |
| **架构设计** | 六边形架构、ADR、25+ 语言/框架设计模式、API 设计 |
| **安全** | OWASP Top 10、STRIDE、HIPAA/PHI 合规、密钥泄漏扫描 |
| **知识管理** | 跨会话记忆、知识图谱、知识语料库、多实例通信 |
| **其他** | SEO、无障碍、视频编辑、学术研究、网络诊断、开源工具链 |

---

## 八、安装脚本

| 脚本 | 用途 | 运行方式 |
|------|------|----------|
| `scripts/install.sh` | 核心能力一键安装（幂等，18 项） | `bash scripts/install.sh` |
| `scripts/install-1.sh` | 55 项技能覆盖分析 + 缺失组件安装 | `bash scripts/install-1.sh` |

> **覆盖率结论**：55/55 项能力由 10 插件 + 5 Skill + 13 MCP 全部覆盖。

---

## 九、配置模板包

`scripts/claude/` 提供可直接复制到目标项目的 Claude Code 配置模板包，已纠正常见教程中的错误。

| 模板 | 用途 |
|------|------|
| `scripts/claude/claude.md` | 项目行为规范模板 |
| `scripts/claude/.mcp.json` | 项目级 MCP 配置模板 |
| `scripts/claude/settings.local.json` | 权限白名单（真实格式） |
| `scripts/claude/skills/` | 5 套技术栈规范（Go/Java/React/Vue3/Python） |
| `scripts/claude/hooks/README.md` | Hook 正确配置指南 |
| `scripts/claude/agents/README.md` | Agent 正确使用指南 |
| `scripts/claude/memory/memory.md` | 长期记忆模板 |

> 常见教程中的错误已在此模板包中纠正，详见 `scripts/claude/README.md`

## 十、最佳实践工作流

| 场景 | 推荐流程 |
|------|----------|
| **新功能设计** | `/brainstorming` → `/writing-plans` → `/executing-plans` |
| **持久化规划** | `/planning-with-files:plan`（自动管理 task_plan.md / findings.md / progress.md） |
| **自主迭代执行** | `/ralph-loop --max-iterations 20 --completion-promise "完成条件"` |
| **Bug 修复** | `/systematic-debugging` |
| **提交前** | `/security-review` → `/review` |
| **大型重构** | `/batch 指令` |
| **新建 Spring Boot 项目** | `/java-spring:java-scaffold` + `spring-boot-dev:*` |
| **生成 CRUD** | `/java-spring:java-crud` + JPA/Repo/Service/Controller 技能 |
| **代码质量检查** | `/java-quality:quality-check` |
| **JPA 性能优化** | `/java-spring:java-jpa` |
| **数据库迁移审查** | 触发 `migration-advisor` MCP |
| **JVM 故障诊断** | 触发 `jvm-diagnostics` MCP |
| **安装/验证** | `bash scripts/install.sh`（一键安装）、`bash scripts/install-1.sh`（55 项技能覆盖分析）|
| **查看技能列表** | `/skills` 或输入 `/` 后按 Tab |
| **查看费用/用量** | `/cost` `/context` |
