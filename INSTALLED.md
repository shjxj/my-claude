# 已安装的 Claude Code 插件与技能

> 更新日期：2026-05-21
>
> **安装脚本**：`bash scripts/install.sh`（核心能力一键安装 + 升级，幂等可重复运行）

---

## 一、插件（10 个）

### 1. superpowers@claude-plugins-official — v5.1.0

标准开发流水线，强制执行「头脑风暴 → 制定计划 → TDD → 代码审查」流程。

**来源**：`github:anthropics/claude-plugins-official`

**技能（13 个）**：

| 技能 | 用途 |
|------|------|
| `superpowers:brainstorming` | 头脑风暴，探索方案 |
| `superpowers:writing-plans` | 编写实施计划 |
| `superpowers:executing-plans` | 按计划逐步实施 |
| `superpowers:test-driven-development` | TDD 开发流程 |
| `superpowers:subagent-driven-development` | 子代理并行开发 |
| `superpowers:systematic-debugging` | 系统化调试方法 |
| `superpowers:verification-before-completion` | 完成前验证 |
| `superpowers:requesting-code-review` | 请求代码审查 |
| `superpowers:receiving-code-review` | 接收代码审查反馈 |
| `superpowers:using-superpowers` | 技能使用引导 |
| `superpowers:using-git-worktrees` | Git Worktree 工作流 |
| `superpowers:finishing-a-development-branch` | 开发分支收尾 |
| `superpowers:dispatching-parallel-agents` | 并行代理调度 |

### 2. frontend-design@claude-plugins-official — 4bf0858

前端 UI 设计，支持玻璃态、工业风、极简主义、暗黑模式、新拟态。

**来源**：`github:anthropics/claude-plugins-official`

**技能（1 个）**：

| 技能 | 用途 |
|------|------|
| `frontend-design:frontend-design` | 前端 UI 设计生成 |

### 3. claude-mem@thedotmack — v13.2.0

跨会话记忆系统，自动记录架构决策、修复过的 bug、项目偏好等，在新会话中自动加载。

**来源**：`github:thedotmack/claude-mem`

**技能（12 个）**：

| 技能 | 用途 |
|------|------|
| `claude-mem:do` | 执行任务 |
| `claude-mem:knowledge-agent` | 知识库问答 |
| `claude-mem:timeline-report` | 时间线报告 |
| `claude-mem:babysit` | 任务监护 |
| `claude-mem:mem-search` | 记忆搜索 |
| `claude-mem:how-it-works` | 工作原理说明 |
| `claude-mem:pathfinder` | 路径导航 |
| `claude-mem:version-bump` | 版本升级 |
| `claude-mem:make-plan` | 制定计划 |
| `claude-mem:smart-explore` | 智能代码探索 |
| `claude-mem:learn-codebase` | 学习代码库 |
| `claude-mem:wowerpoint` | 演示文稿生成 |

### 4. ecc@ecc (Everything Claude Code) — v2.0.0-rc.1

综合工程系统，Anthropic 黑客松冠军作品，150K+ stars。包含多代理、安全扫描、持续学习等能力。

**来源**：`github:affaan-m/everything-claude-code`

**技能（200+，常用分类如下）**：

| 类别 | 技能 |
|------|------|
| **流程管理** | `ecc:plan` `ecc:code-review` `ecc:pr` `ecc:ship` `ecc:checkpoint` `ecc:evolve` `ecc:feature-dev` `ecc:aside` |
| **质量保障** | `ecc:quality-gate` `ecc:security-scan` `ecc:security-review` `ecc:test-coverage` `ecc:silent-failure-hunter` `ecc:production-audit` `ecc:repo-scan` |
| **构建修复** | `ecc:build-fix` `ecc:go-build` `ecc:rust-build` `ecc:cpp-build` `ecc:java-build` `ecc:kotlin-build` `ecc:swift-build` `ecc:dart-build` `ecc:django-build` `ecc:gradle-build` `ecc:pytorch-build-resolver` |
| **代码审查** | `ecc:go-review` `ecc:rust-review` `ecc:python-review` `ecc:typescript-review` `ecc:java-review` `ecc:kotlin-review` `ecc:cpp-review` `ecc:csharp-review` `ecc:flutter-review` `ecc:swift-review` `ecc:django-review` `ecc:fastapi-review` `ecc:fsharp-review` `ecc:laravel-security` `ecc:database-reviewer` `ecc:healthcare-reviewer` `ecc:mle-reviewer` `ecc:comment-analyzer` `ecc:type-design-analyzer` `ecc:pr-test-analyzer` |
| **测试** | `ecc:go-test` `ecc:rust-test` `ecc:cpp-test` `ecc:kotlin-test` `ecc:flutter-test` `ecc:python-testing` `ecc:e2e-runner` `ecc:tdd-workflow` `ecc:ai-regression-testing` |
| **多代理并行** | `ecc:loop-start` `ecc:loop-status` `ecc:santa-loop` `ecc:multi-plan` `ecc:multi-execute` `ecc:multi-frontend` `ecc:multi-backend` `ecc:multi-workflow` `ecc:autonomous-loops` `ecc:continuous-agent-loop` |
| **前端设计** | `ecc:frontend-design-direction` `ecc:design-system` `ecc:motion-patterns` `ecc:motion-foundations` `ecc:motion-advanced` `ecc:motion-ui` `ecc:ui-demo` `ecc:ui-to-vue` `ecc:liquid-glass-design` `ecc:frontend-slides` `ecc:angular-developer` |
| **项目/会话管理** | `ecc:projects` `ecc:project-init` `ecc:project-flow-ops` `ecc:sessions` `ecc:save-session` `ecc:resume-session` `ecc:configure-ecc` |
| **文档/知识** | `ecc:update-docs` `ecc:update-codemaps` `ecc:doc-updater` `ecc:code-tour` `ecc:learn` `ecc:learn-eval` `ecc:codebase-onboarding` `ecc:continuous-learning` `ecc:continuous-learning-v2` `ecc:deep-research` |
| **技能管理** | `ecc:skill-create` `ecc:skill-health` `ecc:skill-stocktake` `ecc:skill-scout` `ecc:skill-comply` `ecc:rules-distill` |
| **运维部署** | `ecc:pm2` `ecc:deployment-patterns` `ecc:production-audit` `ecc:production-scheduling` `ecc:connections-optimizer` `ecc:context-budget` `ecc:token-budget-advisor` `ecc:cost-report` `ecc:cost-tracking` `ecc:canary-watch` |
| **架构/模式** | `ecc:hexagonal-architecture` `ecc:architecture-decision-records` `ecc:backend-patterns` `ecc:frontend-patterns` `ecc:api-design` `ecc:golang-patterns` `ecc:rust-patterns` `ecc:python-patterns` `ecc:kotlin-patterns` `ecc:django-patterns` `ecc:fastapi-patterns` `ecc:springboot-patterns` `ecc:laravel-patterns` `ecc:postgres-patterns` `ecc:redis-patterns` `ecc:docker-patterns` `ecc:mcp-server-patterns` `ecc:prisma-patterns` `ecc:mysql-patterns` `ecc:clickhouse-io` `ecc:dart-flutter-patterns` `ecc:tinystruct-patterns` `ecc:swiftui-patterns` `ecc:compose-multiplatform-patterns` `ecc:healthcare-emr-patterns` |
| **安全** | `ecc:security-review` `ecc:security-bounty-hunter` `ecc:hipaa-compliance` `ecc:healthcare-phi-compliance` `ecc:defi-amm-security` `ecc:llm-trading-agent-security` |
| **Hook 管理** | `ecc:hookify` `ecc:hookify-list` `ecc:hookify-configure` `ecc:hookify-rules` `ecc:hookify-help` |
| **PR 流水线** | `ecc:prp-pr` `ecc:prp-plan` `ecc:prp-implement` `ecc:prp-prd` `ecc:prp-commit` `ecc:review-pr` |
| **性能优化** | `ecc:performance-optimizer` `ecc:harness-audit` `ecc:harness-optimizer` |
| **重构清理** | `ecc:refactor-clean` `ecc:code-simplifier` `ecc:prune` |
| **浏览器/E2E** | `ecc:browser-qa` `ecc:e2e-runner` `ecc:windows-desktop-e2e` |
| **Github/Jira** | `ecc:github-ops` `ecc:jira` `ecc:jira-integration` |
| **研究/评估** | `ecc:benchmark` `ecc:agent-eval` `ecc:eval-harness` `ecc:gan-design` `ecc:gan-build` `ecc:gan-evaluator` `ecc:gan-planner` `ecc:scientific-thinking-literature-review` `ecc:scientific-thinking-scholar-evaluation` `ecc:market-research` `ecc:agent-introspection-debugging` |
| **内容/写作** | `ecc:article-writing` `ecc:content-engine` `ecc:brand-voice` |
| **视频/媒体** | `ecc:video-editing` `ecc:remotion-video-creation` `ecc:manim-video` `ecc:fal-ai-media` `ecc:wowerpoint` |
| **设计/UI** | `ecc:design-system` `ecc:make-interfaces-feel-better` `ecc:liquid-glass-design` `ecc:motion-patterns` `ecc:frontend-design-direction` |
| **协作/团队** | `ecc:council` `ecc:team-builder` |
| **开源** | `ecc:opensource-forker` `ecc:opensource-sanitizer` `ecc:opensource-packager` `ecc:opensource-pipeline` |
| **网络/基础设施** | `ecc:network-architect` `ecc:network-bgp-diagnostics` `ecc:network-config-reviewer` `ecc:network-config-validation` `ecc:network-interface-health` `ecc:network-troubleshooter` `ecc:homelab-architect` `ecc:homelab-network-readiness` `ecc:homelab-network-setup` `ecc:homelab-pihole-dns` `ecc:homelab-vlan-segmentation` `ecc:homelab-wireguard-vpn` `ecc:uncloud` |
| **其他专项** | `ecc:seo` `ecc:accessibility` `ecc:error-handling` `ecc:git-workflow` `ecc:database-migrations` `ecc:regex-vs-llm-structured-text` `ecc:model-route` `ecc:ck` `ecc:blueprint` `ecc:product-lens` `ecc:product-capability` `ecc:investor-materials` `ecc:investor-outreach` `ecc:visa-doc-translate` `ecc:social-graph-ranker` `ecc:lead-intelligence` `ecc:inventory-demand-planning` `ecc:logistics-exception-management` `ecc:returns-reverse-logistics` `ecc:customer-billing-ops` `ecc:finance-billing-ops` `ecc:customs-trade-compliance` `ecc:energy-procurement` `ecc:carrier-relationship-management` `ecc:skill-create` `ecc:email-ops` `ecc:messages-ops` `ecc:google-workspace-ops` `ecc:unified-notifications-ops` `ecc:research-ops` |

### 5. java-core@java-plugins — v2.2.2 🆕

Java 项目核心工具，包含架构审查、构建修复、代码规范等。支持 Java 8 ~ Java 21。

**来源**：`github:ducpm2303/claude-java-plugins`

**技能（14 个）**：项目结构、分层架构、多模块 Maven、设计模式、构建修复、代码规范、日志、异常处理、集合框架、Stream API、并发、序列化、日期时间、I/O

**代理**：`java-architect`（架构设计）、`java-build-resolver`（构建修复）

**命令**：`/java-core:architect-review` `/java-core:build-fix`

### 6. java-spring@java-plugins — v2.2.2 🆕

Spring Boot 专属工具，覆盖项目脚手架、JPA、安全、缓存、AI 集成等。支持 Boot 2.7 ~ 4.0。

**来源**：`github:ducpm2303/claude-java-plugins`

**技能（9 个）**：

| 技能 | 用途 |
|------|------|
| `java-spring:java-scaffold` | 脚手架新建 Spring Boot 项目（2.7 ~ 4.0） |
| `java-spring:java-jpa` | JPA 深度审查 — N+1、抓取策略、Specification |
| `java-spring:java-logging` | 日志审查 — SLF4J、MDC、结构化日志、PII 安全 |
| `java-spring:java-crud` | 在已有项目中生成完整 CRUD 功能 |
| `java-spring:java-security` | Spring Security 审查/生成 — JWT、OAuth2、方法安全、CORS |
| `java-spring:java-openapi` | OpenAPI/Swagger 文档生成与审查 |
| `java-spring:java-spring-ai` | Spring AI 集成 — ChatClient、RAG、工具调用、记忆 |
| `java-spring:java-resilience` | Resilience4J 模式 — 断路器、重试、限流、舱壁 |
| `java-spring:java-cache` | 缓存策略 — Caffeine（单实例）/ Redis（分布式） |

**命令**：`/java-spring:run`（启动应用）、`/java-spring:routes`（打印 REST 端点表）

**代理**：`java-spring-expert`

### 7. java-quality@java-plugins — v2.2.2 🆕

Java 代码质量保障，含安全审查、性能优化、测试工程。

**来源**：`github:ducpm2303/claude-java-plugins`

**代理**：`java-security-reviewer`、`java-performance-reviewer`、`java-test-engineer`

**命令**：`/java-quality:quality-check`

### 8. spring-boot-dev@sivalabs-marketplace — v1.0.0 🆕

Spring Boot 应用开发插件，自动生成最佳实践代码。

**来源**：`github:sivaprasadreddy/sivalabs-marketplace`

**技能（5 个）**：

| 技能 | 用途 |
|------|------|
| `spring-boot-dev:spring-boot-package-structure-creator` | 创建推荐的项目包结构 |
| `spring-boot-dev:jpa-entity-creator` | 创建 JPA 实体 |
| `spring-boot-dev:spring-data-jpa-repo-creator` | 创建 Spring Data JPA Repository |
| `spring-boot-dev:spring-service-creator` | 创建 Service 层类 |
| `spring-boot-dev:spring-rest-api-creator` | 创建 Spring MVC REST API Controller |

### 9. planning-with-files@planning-with-files — v2.38.1 🆕

持久化 Markdown 规划系统，通过 `task_plan.md`、`findings.md`、`progress.md` 三个文件在上下文外跟踪任务状态。

**来源**：`github:OthmanAdi/planning-with-files`

**命令**：`/planning-with-files:plan` `/planning-with-files:start`

### 10. ralph-loop@claude-plugins-official — v1.0.0 🆕

自主代理迭代循环。Stop Hook 拦截退出并重新注入提示词，形成自我反馈循环。

**来源**：`github:anthropics/claude-plugins-official`

**命令**：

| 命令 | 用途 |
|------|------|
| `/ralph-loop` | 启动自主循环，参数：`--max-iterations <n>` `--completion-promise "<text>"` |
| `/cancel-ralph` | 停止当前循环 |

---

## 二、用户级 Skill（~/.claude/skills/，7 个）

| 技能 | 路径 | 状态 | 用途 |
|------|------|------|------|
| **gstack** | `~/.claude/skills/gstack/` | ✅ | 多角色 AI 工程团队（23 种角色），47 个子技能 |
| **find-skills** | `~/.claude/skills/find-skills/` | ✅ | 搜索和发现可安装的技能 |
| **supabase** | `~/.claude/skills/supabase/` | ✅ | Supabase 平台操作（含 assets/、references/） |
| **supabase-postgres-best-practices** | `~/.claude/skills/supabase-postgres-best-practices/` | ✅ | PG 最佳实践（连接池、RLS、分页、锁等） |
| **code-simplifier** | `~/.claude/skills/code-simplifier/` | ✅ | 代码简化与质量检查（由 @adonis0123/code-simplifier 提供） |
| **ui-ux-pro-max** | `~/.claude/skills/ui-ux-pro-max/` | ✅ | UI/UX 设计增强（前端设计、组件库、交互优化） |
| **learned** | `~/.claude/skills/learned/` | ⚪ | 空目录，由 claude-mem 插件自动创建 |

### GStack 子技能一览（47 个）

| 类别 | 技能 |
|------|------|
| **规划审查（7）** | `office-hours` `plan-ceo-review` `plan-eng-review` `plan-design-review` `plan-devex-review` `plan-tune` `autoplan` |
| **实现审查（7）** | `review` `codex` `investigate` `design-review` `design-shotgun` `design-html` `devex-review` |
| **QA 测试（5）** | `qa` `qa-only` `scrape` `skillify` `browse` |
| **浏览器工具（3）** | `open-gstack-browser` `connect-chrome` `setup-browser-cookies` |
| **发布部署（5）** | `ship` `land-and-deploy` `canary` `landing-report` `setup-deploy` |
| **文档（3）** | `document-release` `document-generate` `make-pdf` |
| **安全（5）** | `cso` `careful` `freeze` `guard` `unfreeze` |
| **记忆协作（7）** | `context-save` `context-restore` `learn` `retro` `pair-agent` `setup-gbrain` `sync-gbrain` |
| **工具（4）** | `health` `benchmark` `benchmark-models` `gstack-upgrade` |

---

## 三、MCP 服务（13 个，全部运行中）

### 插件自带（8 个）

| MCP Server | 来源插件 | 主要工具 | 用途 |
|------------|----------|----------|------|
| `claude-mem` | claude-mem | `search` `timeline` `smart_search` `smart_outline` `smart_unfold` `build_corpus` `query_corpus` | 记忆搜索、智能代码探索、知识语料库 |
| `context7` | ecc | `resolve-library-id` `query-docs` | 实时库/框架文档查询 |
| `exa` | ecc | `web_search_exa` `web_fetch_exa` | Web 搜索与内容提取 |
| `github` | ecc | `create_pr` `create_issue` `search_code` `push_files` `get_pull_request` 等 20+ | GitHub 全功能操作 |
| `playwright` | ecc | `browser_navigate` `browser_click` `browser_snapshot` `browser_evaluate` 等 20+ | 浏览器自动化与 E2E 测试 |
| `memory` | ecc | `create_entities` `open_nodes` `search_nodes` `read_graph` `create_relations` | 知识图谱 CRUD |
| `sequential-thinking` | ecc | `sequentialthinking` | 结构化思维链推理 |
| `context7` (SivaLabs) | spring-boot-dev | `resolve-library-id` `query-docs` | Spring Boot 文档查询 |

### 手动配置（5 个）

| MCP Server | 命令 | 版本 | 用途 |
|------------|------|------|------|
| `db-analyzer` | `npx -y mcp-db-analyzer` | 0.2.14 | PostgreSQL/MySQL/SQLite schema 分析、索引优化、EXPLAIN 查询计划 |
| `jvm-diagnostics` | `npx -y mcp-jvm-diagnostics` | 0.1.14 | JVM 诊断 — 线程 dump、死锁检测、GC 日志、调优建议 |
| `migration-advisor` | `npx -y mcp-migration-advisor` | 0.2.14 | 数据库迁移风险分析 — Flyway/Liquibase XML/YAML/SQL |
| `spring-boot-actuator` | `npx -y mcp-spring-boot-actuator` | 0.1.14 | Spring Boot Actuator 分析 — health、metrics、env、beans |
| `redis-diagnostics` | `npx -y mcp-redis-diagnostics` | 0.1.14 | Redis 诊断 — 内存、慢日志、客户端、keyspace |

---

## 四、npm 全局包（5 个相关）

| 包名 | 版本 | 用途 |
|------|------|------|
| `@adonis0123/code-simplifier` | 1.1.2 | 代码简化与质量检查 |
| `mcp-java-backend-suite` | 0.1.40 | Java 后端 MCP 套件（含 5 子 MCP 服务器） |
| `claude-projects` | 0.2.4 | 多项目集中管理（`ccode` 命令） |
| `ezvibe` | 0.3.1 | Web 可视化管理面板（`ezvibe start`） |
| `open-claude-remote` | 0.1.1 | 手机远程监控 Claude Code |

---

## 五、市场源（6 个）

| 市场 | 仓库 |
|------|------|
| `claude-plugins-official` | `github:anthropics/claude-plugins-official` |
| `thedotmack` | `github:thedotmack/claude-mem` |
| `ecc` | `github:affaan-m/everything-claude-code` |
| `sivalabs-marketplace` | `github:sivaprasadreddy/sivalabs-marketplace` |
| `java-plugins` | `github:ducpm2303/claude-java-plugins` |
| `planning-with-files` | `github:OthmanAdi/planning-with-files` |

---

## 六、暂未安装

| 工具 | 说明 |
|------|------|
| Jira MCP | ecc 提供配置模板，需填写 `JIRA_URL` / `JIRA_EMAIL` / `JIRA_API_TOKEN` |
| Supabase MCP | ecc 提供配置模板，需填写 `SUPABASE_PROJECT_REF`（已有 supabase 技能，MCP 连接器未配置） |
| ctx-link | 跨实例上下文共享（`bun add -g ctx-link`） |
| PPTX 专用技能 | 当前 claude-mem:wowerpoint + ecc:frontend-slides 可覆盖演示场景；如需原生 .pptx 输出，执行 `/plugin marketplace search pptx` |

> **覆盖率**：22/22 项能力已全部由现有工具覆盖（详见 `scripts/install.sh` 安装输出）

---

## 七、验证命令

```bash
claude plugin list                          # 查看已安装插件（10 个）
claude plugin marketplace list              # 查看已配置市场（6 个）
claude mcp list                             # 查看 MCP 服务器状态（13 个）
ls ~/.claude/skills/                        # 查看用户级 Skill
npm list -g --depth=0                       # 查看全局 npm 包
bash scripts/install.sh                     # 核心能力一键安装 + 升级（幂等）
```
