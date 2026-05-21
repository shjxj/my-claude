# 开发工作方法论

> 基于当前安装的 10 插件 + 7 Skill + 13 MCP 服务制定的端到端开发流程
> 更新日期：2026-05-21
>
> **22 项能力全覆盖**：运行 \`bash scripts/install.sh\` 一键安装/升级全部能力

---

## 目录

- [项目配置模板](#项目配置模板)
- [五大核心能力](#五大核心能力)
- [分层架构概览](#分层架构概览)
- [大型项目开发实践](#大型项目开发实践)
- [总览](#总览)
- [阶段一：需求与头脑风暴](#阶段一需求与头脑风暴)
- [阶段二：方案设计与确认](#阶段二方案设计与确认)
- [阶段三：开发计划制定](#阶段三开发计划制定)
- [阶段四：TDD 实现](#阶段四tdd-实现)
- [阶段五：代码审查](#阶段五代码审查)
- [阶段六：测试验证](#阶段六测试验证)
- [阶段七：安全审查](#阶段七安全审查)
- [阶段八：性能审查](#阶段八性能审查)
- [阶段九：上线准备](#阶段九上线准备)
- [阶段十：上线](#阶段十上线)
- [阶段十一：上线后监控](#阶段十一上线后监控)
- [质量标准与完成定义](#质量标准与完成定义)
- [命令速查表](#命令速查表)

---

## 项目配置模板

> `scripts/claude/` 提供可直接复制使用的 Claude Code 项目配置模板包，
> 已纠正常见教程中的配置格式错误。

### 快速开始

```bash
# 复制完整配置包到你的项目
cp scripts/claude/claude.md <目标项目>/
cp scripts/claude/.mcp.json <目标项目>/
mkdir -p <目标项目>/.claude
cp scripts/claude/settings.local.json <目标项目>/.claude/

# 复制技术栈技能模板到全局
cp scripts/claude/skills/*.md ~/.claude/skills/
```

### Hook 正确配置

常见教程中使用 `onBeforeWriteFile`、`onCommandRun` 等驼峰事件名，并要求写成 JS module.exports 文件——**这些都是错误的**。

**正确的 Hook 配置**（在 `settings.json` 中）：

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "echo '代码已修改'"
      }]
    }],
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "node ~/.claude/hooks/validate-command.js"
      }]
    }]
  }
}
```

**真实事件名**：`PreToolUse`、`PostToolUse`、`UserPromptSubmit`、`SessionStart`、`SessionEnd`、`Stop`、`Notification`、`SubagentStart`、`PreCompact`、`PreMessageEnqueue` 等。

### Agent 正确使用

常见教程中的 `/agent explore/plan/coding` 命令格式不正确。Claude Code 的子代理通过 **`Agent` 工具** + `subagent_type` 参数调用，由对话自然触发：

```
"梳理整个项目分层架构"  → Agent(subagent_type='Explore')
"设计模块拆分方案"      → Agent(subagent_type='Plan')
"审查代码修改"          → Agent(subagent_type='ecc:code-reviewer')
```

### settings.json 常见错误

| ❌ 错误写法 | ✅ 正确写法 |
|------------|------------|
| `"enablePlugins": true` | `"enabledPlugins": { "name@market": true }` |
| `"enableHooks": true` | `"hooks": { "PostToolUse": [...] }` |
| `"allowWriteDirs": [...]` | `"permissions": { "allow": [...], "deny": [...] }` |
| `"hookDir": "~/.claude/hooks"` | 不存在此配置键 |
| `"agentDir": "~/.claude/agents"` | 不存在此配置键 |

> 完整纠正清单见 `scripts/claude/README.md`

---

## 会话日志系统 — 开发全流程自动记录

### 概述

通过 PostToolUse Hook 自动拦截 Skill/Agent 调用 + CLAUDE.md 指令驱动 AI 主动维护，实现「头脑风暴 → 计划 → TDD → 审查 → 验证」全流程的自动记录。

**两层分工：**

| 层 | 机制 | 职责 |
|----|------|------|
| Hook 层 | `PostToolUse` 自动拦截 | 捕获 Skill/Agent 执行结果，按路由表写入日志文件 |
| AI 层 | `CLAUDE.md` 指令驱动 | 更新 task_plan/findings/progress，写入 ADR，记录 bug |

### 文件结构

```
项目根目录/
├── docs/
│   ├── sessions/{日期}/            # Hook 自动创建
│   │   ├── _index.md               # 当日命令执行索引
│   │   ├── 01-brainstorming.md     # 头脑风暴/需求
│   │   ├── 02-strategy.md          # CEO/战略审查
│   │   ├── 03-architecture.md      # 架构设计
│   │   ├── 04-plan.md              # 实施计划
│   │   ├── 05-tdd.md               # TDD 实现
│   │   ├── 06-review.md            # 代码审查
│   │   ├── 07-verification.md      # 验证
│   │   ├── 08-security.md          # 安全审计
│   │   ├── 09-loop.md              # 自主循环
│   │   ├── 10-session-log.md       # 未分类记录（兜底）
│   │   └── _summary.md             # 会话摘要（Stop hook）
│   ├── adr/                         # 架构决策记录
│   └── bugs/active.md              # Bug 追踪
├── task_plan.md / findings.md / progress.md  # planning-with-files 管理
├── .claude/
│   ├── settings.local.json          # Hook 配置
│   └── hooks/session-logger.sh      # 路由脚本
```

### 路由规则

| 命令 | 目标文件 |
|------|---------|
| `/brainstorming` `/office-hours` | `01-brainstorming.md` |
| `/plan-ceo-review` | `02-strategy.md` |
| `/plan-eng-review` `/plan-design-review` | `03-architecture.md` |
| `/writing-plans` `/planning-with-files:plan` | `04-plan.md` |
| `/test-driven-development` `/executing-plans` | `05-tdd.md` |
| `/code-review` `/requesting-code-review` `/receiving-code-review` | `06-review.md` |
| `/verification-before-completion` | `07-verification.md` |
| `/security-review` `/security-scan` | `08-security.md` |
| `/ralph-loop` | `09-loop.md` |
| 其他未匹配的 Skill/Agent | `10-session-log.md` |
| 会话结束（Stop hook） | `_summary.md` |

### AI 阶段衔接规则

在目标项目 CLAUDE.md 中写入以下规则，AI 在阶段衔接时自动执行：

1. **规划完成后**：确保 `task_plan.md` 每个任务可独立追踪
2. **TDD 每完成一个任务**：标记 `task_plan.md` 为 `[x]`，在 `progress.md` 末尾追加进度
3. **代码审查完成后**：问题写入 `findings.md`
4. **验证完成后**：更新 `progress.md` 最终状态
5. **产生重大技术决策时**：写入 `docs/adr/{编号}-{标题}.md`
6. **发现 bug 时**：写入 `docs/bugs/active.md`
7. **会话开始时**：读取最近日期的 `_summary.md` + `task_plan.md` + `progress.md`

### 快速部署

```bash
# 模板位置：scripts/claude/templates/session-logging/
cp templates/session-logging/settings.local.json <目标项目>/.claude/
cp -r templates/session-logging/hooks/ <目标项目>/.claude/
chmod +x <目标项目>/.claude/hooks/session-logger.sh
cat templates/session-logging/CLAUDE.md.snippet >> <目标项目>/CLAUDE.md
cp templates/session-logging/adr/_template.md <目标项目>/docs/adr/
cp templates/session-logging/bugs/active.md <目标项目>/docs/bugs/
mkdir -p <目标项目>/docs/{sessions,adr,bugs,releases}
```

> 完整使用说明见 `scripts/claude/templates/session-logging/README.md`

---

## 五大核心能力

Claude Code 通过五种扩展机制接入外部生态，形成完整的开发工具链。

### 能力总览

| 能力 | 作用 | 配置位置 | 典型场景 |
|------|------|----------|----------|
| **MCP** | 连接外部服务和 API | `settings.json` → `mcpServers` | 数据库诊断、浏览器自动化、GitHub 操作 |
| **Hooks** | 生命周期拦截和自动化 | `settings.json` → `hooks` | 代码修改后自动提示审查、高危命令拦截 |
| **Skills** | 领域技术栈预设规范 | `~/.claude/skills/*.md` | Go 微服务规范、React 组件规范 |
| **Plugins** | 第三方功能扩展包 | `settings.json` → `enabledPlugins` | superpowers、ecc、java-core 等 |
| **Agents** | 子代理并行分工 | 对话中自然触发 `Agent` 工具 | Explore 梳理架构、Plan 设计模块、Review 审查代码 |

### MCP — 打通外部系统

```
对外连接数据库、API、浏览器、文件系统等外部资源
配置：settings.json → mcpServers → { command + args + env }
项目级覆盖：.mcp.json（优先级高于全局 settings.json）
```

当前已接入 13 个 MCP 服务：`db-analyzer`（数据库诊断）、`jvm-diagnostics`（JVM 调优）、`migration-advisor`（迁移审查）、`spring-boot-actuator`（运行健康）、`redis-diagnostics`（Redis 诊断）、`github`（PR/Issue）、`playwright`（浏览器 E2E）、`context7`（实时文档查询）、`claude-mem`（长期记忆）、`memory`（知识图谱）、`sequential-thinking`（多步推理）、`exa`（语义搜索）。

### Hooks — 生命周期自动化

Hooks 监听 Claude Code 运行时的关键事件，自动执行 Shell 命令。**注意**：Hook 是 `settings.json` 中的 Shell 命令，不是 JS 文件 `module.exports`。

**真实事件**：`PreToolUse`、`PostToolUse`、`UserPromptSubmit`、`SessionStart`、`SessionEnd`、`Stop`、`Notification`、`SubagentStart`、`SubagentStop`、`PreCompact`、`PreMessageEnqueue`。

**常用场景**：
- `PostToolUse` + `matcher: "Edit|Write"` → 代码修改后自动提示质量检查
- `PreToolUse` + `matcher: "Bash"` → 高危命令执行前拦截
- `SessionStart` → 会话启动时注入项目上下文

### Skills — 技术栈模板

Skills 是放在 `~/.claude/skills/` 下的 Markdown 文件，通过 `Skill` 工具或斜杠命令调用，为 Claude Code 加载对应技术栈的开发规范。项目级 Skill 同样支持。

### Plugins — 功能扩展

Plugins 从市场源安装，提供成组的 Skills 和 Agents。当前 10 个插件提供 300+ 技能和 50+ 代理。

### Agents — 并行分工

子代理通过 `Agent` 工具调用，由对话自然触发。常见类型：
- **Explore**：只读检索，梳理架构、分析依赖
- **Plan**：方案设计、模块拆分
- **General-purpose**：通用编码实现
- **各插件 Agent**：code-reviewer、security-reviewer、test-engineer 等

> 完整 Agent 类型列表见 `scripts/claude/agents/README.md`

---

## 分层架构概览

Claude Code 内部可理解为 7 层架构（概念模型，非官方文档）：

| 层 | 职责 | 关键组件 |
|----|------|----------|
| **交互层** | 接收输入、流式输出、会话管理 | CLI（Ink 终端引擎）、IDE 集成、Web/桌面 UI |
| **扩展层** | 标准化扩展接入 | MCP、Hooks、Skills、Plugins |
| **委托层** | 任务拆分与并行分发 | SubAgent 系统（最多 10 个并行） |
| **核心引擎层** | 对话循环、Prompt 编排、决策 | QueryEngine（12 步状态机）、System Prompt 管理器 |
| **安全与工具层** | 工具执行、权限控制、沙箱 | 42+ 内置工具、7 种权限模式、ML 安全分类器 |
| **状态/上下文层** | 上下文组装、压缩、持久化 | 5 级压缩流水线、会话存储、全局代码索引 |
| **基础设施层** | 底层支撑 | 网络通信、缓存、日志、认证代理 |

**与大型项目实践的对应关系**：

| 最佳实践 | 对应架构层 |
|----------|-----------|
| 限定项目作用域 | 安全与工具层（权限控制） |
| 统一编码规范 | 核心引擎层（Prompt 编排） |
| 模块化开发 | 委托层（多 Agent 分工） |
| 全局代码检索 | 状态层（代码索引）+ 工具层（搜索） |
| 分批迭代提交 | 核心引擎层 + 状态层 |

---

## 大型项目开发实践

### 十条核心原则

**1. 限定项目作用域**
对话开始时明确只关注业务相关目录，排除 `node_modules`、`dist`、`logs`、`cache` 等。通过 `CLAUDE.md` 或对话指令设定边界，利用 `settings.local.json` 的 `permissions.deny` 强制限制。

**2. 统一项目编码规范**
将所有编码规范写入 `CLAUDE.md`（项目级最高优先级）：
- 命名风格、注释规则、目录分层
- 异常处理模式、日志规范
- 接口定义标准、测试要求

**3. 结构化指令编写**
复杂需求结构化描述：
```
任务：<做什么>
业务目标：<为什么>
上下文：<涉及的模块/文件/依赖>
约束：<技术限制、兼容要求、性能指标>
边界条件：<异常场景、兜底逻辑>
输出要求：<代码 + 测试 + 文档>
```

**4. 优先模块化开发**
大型项目按模块/服务/功能拆分，每次只处理一个模块。多个独立模块可使用并行 Agent 同时开发。

**5. 善用全局代码检索**
修改前先让 Explore Agent 通读相关代码，复用已有工具类、公共方法、通用接口，避免重复造轮子。

**6. 改动前先做影响分析**
修改存量代码前，先梳理调用关系、依赖链路，评估修改影响范围。

**7. 强制边界与异常处理**
要求输出代码自带：
- 参数校验（入参非空、类型、范围）
- 异常捕获与传播（不吞异常）
- 兜底逻辑（超时、降级、重试）

**8. 同步生成配套内容**
完成功能开发后同步输出：
- 单元测试（覆盖率 ≥ 80%）
- 接口文档（请求/响应示例）
- 修改说明（变更文件清单 + 原因）

**9. 分批迭代提交**
- 小功能分批编写、自测、提交，不一次性大批量改动
- 每完成一个逻辑单元就提交一次
- 降低合并冲突与回滚风险

**10. 老项目重构策略**
1. Explore Agent 梳理全量旧业务逻辑和调用链路
2. 保留原有业务行为不变，只优化结构和性能
3. 按模块逐步重构，每个模块重构后全量回归测试
4. 通过后再进入下一模块

### 项目级配置最小模板

```bash
# 必须的 3 个文件
项目根目录/
├── CLAUDE.md           # 编码规范 + 项目信息
├── .mcp.json           # MCP 外部服务（如需要）
└── .claude/
    └── settings.local.json  # 权限白名单
```

> 完整模板见 `scripts/claude/`

---

## 总览

```
需求 → 方案 → 计划 → 实现 → 审查 → 测试 → 安全 → 性能 → 上线准备 → 上线 → 监控
  ↓      ↓      ↓      ↓      ↓      ↓      ↓      ↓       ↓       ↓      ↓
 头脑   架构   持久化  TDD    多维   覆盖    OWASP  JVM+    分支     金丝   实时
 风暴   设计   规划   循环   审查   率+E2E  STRIDE  DB     收尾     雀    告警
```

**核心原则**：
- 每个阶段有明确的入口标准和出口标准
- 所有变更走 TDD：先写测试 → 最小实现 → 重构
- 合并前必须通过代码审查 + 安全审查 + 性能审查三道门禁
- 持久化规划文件确保上下文压缩后不丢失状态
- 使用自主循环执行大型多步骤任务

---

## 阶段一：需求与头脑风暴

### 目标
将模糊想法转化为清晰的、可执行的需求描述。

### 操作步骤

#### 步骤 1.1 — 头脑风暴

**命令**：`/brainstorming`

**输入要求**：提供功能描述（可以是模糊的）

**示例对话**：
```
用户：/brainstorming
我想为项目添加一个订单导出功能，用户可以把订单导出为 Excel 或 PDF

Claude 会执行：
1. 探索问题空间（为什么要导出？谁用？在哪个页面触发？）
2. 列出 3+ 个备选方案：
   方案 A — 后端生成文件，异步下载（适合大数据量）
   方案 B — 前端生成，即时下载（适合小数据量）
   方案 C — 混合方案，小数据前端/大数据后端
3. 对比各方案的优缺点、技术复杂度、可扩展性
4. 推荐方案并说明理由
```

**预期产出**：
- 3+ 个方案及其优缺点对比
- 推荐方案及理由
- 关键边界条件和风险点

#### 步骤 1.2 — 产品审查（可选，重要功能）

**命令**：`/office-hours`

**输入要求**：带上一步的输出结果

**示例对话**：
```
用户：/office-hours
我们计划实现订单导出功能，方案是用后端异步生成 Excel/PDF，
用户点击导出后创建任务，完成时推送通知。
请帮我梳理用户故事。

Claude 会以产品导师视角：
1. 梳理用户故事：
   As a 运营人员
   I want 导出最近 30 天的订单为 Excel
   So that 我可以进行离线数据分析
2. 明确验收条件：
   Given 用户选择了日期范围
   When 点击「导出」按钮
   Then 系统创建导出任务并显示「处理中」
   When 任务完成
   Then 用户收到通知并可下载文件
3. 指出 MVP 范围和后续迭代方向
```

**预期产出**：
- 用户故事（As a / I want / So that 格式）
- 验收条件（Given / When / Then 格式）
- MVP 范围定义

#### 步骤 1.3 — 战略审查（关键功能）

**命令**：`/plan-ceo-review`

**示例对话**：
```
用户：/plan-ceo-review
功能：订单导出（Excel/PDF）。目标用户：运营团队 50 人。
预估耗时：3 天。会对当前 Sprint 其他任务有影响。
请审查优先级和技术方案。

Claude 会从商业/战略角度分析：
1. 是否与当前业务目标一致
2. 投入产出比评估
3. 与竞品的差异化分析
4. 是否应该现在做
```

### 入口标准
- 用户提出功能需求或 Bug 描述

### 出口标准
- [ ] 至少 3 个备选方案被评估
- [ ] 用户故事已编写
- [ ] 验收条件已明确
- [ ] 关键风险已识别
- [ ] 方案与已有架构无冲突

---

## 阶段二：方案设计与确认

### 目标
将需求转化为技术方案，产生架构决策记录。

### 操作步骤

#### 步骤 2.1 — 编写技术方案

**命令**：`/writing-plans` 或 `ecc:plan`

**前置条件**：用户故事和验收条件已确认

**示例对话**：
```
用户：/writing-plans
我们要实现订单导出功能。用户故事和验收条件如下：
- As a 运营人员, I want 导出订单为 Excel/PDF
- 验收条件：支持日期范围筛选、异步生成、完成通知

请输出技术方案，包括：
1. 文件清单（新建和修改的文件）
2. API 接口定义（路径、请求/响应）
3. 数据库变更（如有）
4. 技术选型（Excel 库、PDF 库、消息队列）
```

**预期产出**：
```markdown
## 技术方案：订单导出功能

### 文件清单
- 新建：ExportController.java、ExportService.java、ExportTask.java
- 新建：ExportTaskRepository.java、ExportScheduler.java
- 修改：SecurityConfig.java（添加权限）
- 新建：export_task.sql（数据库迁移）

### API 设计
POST   /api/exports          创建导出任务
GET    /api/exports/{id}      查询任务状态
GET    /api/exports/{id}/download  下载文件

### 技术选型
- Excel：Apache POI（大数据量）或 EasyExcel
- PDF：iText 或 OpenPDF
- 异步：Spring @Async + Scheduler
```

#### 步骤 2.2 — 架构审查

**命令**：`/plan-eng-review`

**要求**：在技术方案产出后执行

**示例对话**：
```
用户：/plan-eng-review
技术方案：[粘贴步骤 2.1 的方案]
请审查：
1. 与现有架构是否一致
2. 是否有更好的技术选型
3. 可扩展性是否充分
4. 安全性是否存在问题
```

**预期产出**：
- 架构评审意见（通过 / 有条件通过 / 重新设计）
- 具体修改建议

#### 步骤 2.3 — UX 审查（涉及前端时）

**命令**：`/plan-design-review`

**示例对话**：
```
用户：/plan-design-review
导出功能交互流程：
1. 用户在列表页勾选订单 → 点击「导出」
2. 弹出面板选择格式（Excel/PDF）和日期范围
3. 点击确认 → 显示「导出任务已创建」
4. 通知栏显示进度 → 完成后可下载

请审查交互设计
```

#### 步骤 2.4 — 架构决策记录（如有重大选型）

**命令**：触发 `ecc:architecture-decision-records`

**示例对话**：
```
用户：请为此功能的两个关键选型创建 ADR：
1. 为什么选 EasyExcel 而不是 Apache POI
2. 为什么用 @Async 而不是 RabbitMQ
```

**预期产出**：
- ADR-001: 导出库选型（EasyExcel vs Apache POI）
- ADR-002: 异步方案选型（@Async vs 消息队列）

### 入口标准
- [ ] 阶段一出口标准全部满足

### 出口标准
- [ ] 技术方案文档已编写（含文件清单、接口定义、数据流）
- [ ] 架构审查通过
- [ ] ADR 已记录（如有重大技术选型）
- [ ] 用户已确认方案

---

## 阶段三：开发计划制定

### 目标
将技术方案分解为可执行的任务列表，启动持久化规划。

### 操作步骤

#### 步骤 3.1 — 启动持久化规划

**命令**：`/planning-with-files:plan`

**要求**：带上阶段二的技术方案

**示例对话**：
```
用户：/planning-with-files:plan
基于以下技术方案制定实施计划：
[粘贴阶段二的方案]

请创建 task_plan.md、findings.md、progress.md
任务粒度控制在 2-4 小时，标注依赖关系和验收标准
```

**预期产出（task_plan.md 示例）**：
```markdown
# task_plan.md — 订单导出功能

## Task 1: 数据库迁移
- 文件：export_task.sql
- 预估：1h
- 依赖：无
- 验收：表结构创建成功，索引正确

## Task 2: 实体和 Repository
- 新建：ExportTask.java, ExportTaskRepository.java
- 预估：1.5h
- 依赖：Task 1
- 验收：JPA 映射正确，Repository CRUD 测试通过

## Task 3: ExportService（核心逻辑）
- 新建：ExportService.java
- 预估：3h
- 依赖：Task 2
- 验收：Excel 生成测试通过、PDF 生成测试通过、异常处理测试通过

## Task 4: ExportController（API 层）
- 新建：ExportController.java
- 预估：2h
- 依赖：Task 3
- 验收：POST /api/exports 201，GET /api/exports/{id} 200，下载 200

## Task 5: 异步调度
- 新建：ExportScheduler.java
- 预估：2h
- 依赖：Task 3
- 验收：异步执行正常，失败重试正常

## Task 6: 通知集成
- 修改：NotificationService.java
- 预估：1.5h
- 依赖：Task 5
- 验收：任务完成时通知正确发送

## Task 7: Security 权限
- 修改：SecurityConfig.java
- 预估：1h
- 依赖：Task 4
- 验收：无权限用户拒绝访问

## Task 8: 集成测试 + E2E
- 预估：2h
- 依赖：Task 1-7
- 验收：覆盖率 ≥ 80%，E2E 通过
```

#### 步骤 3.2 — 确认计划

**检查项**：
- 每个任务粒度 ≤ 4 小时
- 依赖关系正确（无循环依赖）
- 验收标准可测试（不是「代码写好」而是「测试通过」）
- 关键风险在 findings.md 中已标注

**示例对话**：
```
用户：请检查 task_plan.md，确认：
1. 任务粒度是否合理
2. 依赖是否正确
3. 是否有遗漏

Claude 审查后输出：
- Task 3 粒度偏大（3h），建议拆分为 Excel 生成 + PDF 生成
- 缺少「文件清理」任务（过期导出文件需定期删除）
- 确认无其他问题，可以开始实施
```

### 入口标准
- [ ] 阶段二出口标准全部满足

### 出口标准
- [ ] `task_plan.md` 已创建，任务粒度 2-4 小时
- [ ] 每个任务有明确验收标准
- [ ] 依赖关系已标注
- [ ] `findings.md` 已记录约束和风险
- [ ] `progress.md` 初始化完成
- [ ] 用户已确认计划

---

## 阶段四：TDD 实现

### 目标
按计划逐步实现，每个任务走完整 TDD 循环。

### 操作步骤

#### 步骤 4.1 — 启动 TDD 模式

**命令**：`/test-driven-development`

**示例对话**：
```
用户：/test-driven-development
开始执行 Task 2：创建 ExportTask 实体和 ExportTaskRepository。

需求：
- ExportTask 字段：id, userId, status(PENDING/PROCESSING/COMPLETED/FAILED),
  format(EXCEL/PDF), dateFrom, dateTo, filePath, createdAt, completedAt
- Repository 需要：findByUserId, findByStatus, findPendingTasks

请按 TDD 流程实现：
1. RED — 先写测试
2. GREEN — 最小实现
3. REFACTOR — 重构优化
```

#### TDD 详细流程

**RED 阶段（写测试）**：

```java
// 测试示例：ExportTaskRepositoryTest.java
@DataJpaTest
class ExportTaskRepositoryTest {

    @Autowired
    private ExportTaskRepository repository;

    @Test
    void shouldSaveAndFindExportTask() {
        // Given
        var task = ExportTask.builder()
            .userId(1L)
            .status(ExportStatus.PENDING)
            .format(ExportFormat.EXCEL)
            .dateFrom(LocalDate.now().minusDays(30))
            .dateTo(LocalDate.now())
            .build();

        // When
        var saved = repository.save(task);
        var found = repository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getStatus()).isEqualTo(ExportStatus.PENDING);
    }

    @Test
    void shouldFindPendingTasks() {
        // Given
        repository.save(createTask(ExportStatus.PENDING));
        repository.save(createTask(ExportStatus.PROCESSING));
        repository.save(createTask(ExportStatus.COMPLETED));

        // When
        var pending = repository.findByStatus(ExportStatus.PENDING);

        // Then
        assertThat(pending).hasSize(1);
    }

    @Test
    void shouldRejectNullUserId() {
        // Given
        var task = ExportTask.builder().userId(null).build();

        // When & Then
        assertThatThrownBy(() -> repository.save(task))
            .isInstanceOf(DataIntegrityViolationException.class);
    }
}
```

**GREEN 阶段（最小实现）**：

```java
@Entity
@Table(name = "export_tasks")
class ExportTask {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ExportStatus status = ExportStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ExportFormat format;

    private LocalDate dateFrom;
    private LocalDate dateTo;
    private String filePath;
    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime completedAt;
}

interface ExportTaskRepository extends JpaRepository<ExportTask, Long> {
    List<ExportTask> findByUserId(Long userId);
    List<ExportTask> findByStatus(ExportStatus status);
}
```

**REFACTOR 阶段**：
- 添加 `@Builder` 注解
- 提取常量到 ExportConstants
- 添加索引注解 `@Table(indexes = {...})`

#### 步骤 4.2 — 按计划逐步执行

**命令**：`/executing-plans`

**示例对话**：
```
用户：/executing-plans
当前 task_plan.md：
- [x] Task 1: 数据库迁移 ✓
- [   ] Task 2: 实体和 Repository ← 当前
- [   ] Task 3: ExportService
- ...

开始执行 Task 2，完成后更新 progress.md
```

**每完成一个任务后必须做的事**：
1. 运行 `code-simplifier` 质量检查（会自动提示）
2. 更新 `progress.md` 标记完成
3. 运行全部测试确保无回归

#### 步骤 4.3 — Java 快捷生成

**新建 Spring Boot 项目时**：

```bash
# 命令
/java-spring:java-scaffold

# 对话示例
用户：请创建一个 Spring Boot 3.2 + Java 21 项目。
包名：com.example.order，依赖：Spring Web, Spring Data JPA,
PostgreSQL, Spring Security, Lombok, Validation
```

```bash
# 创建包结构
用户：请按标准分层创建项目包结构
# Claude 自动调用 spring-boot-dev:spring-boot-package-structure-creator
```

**生成 CRUD 时**：

```bash
# 命令
/java-spring:java-crud

# 对话示例
用户：请为 ExportTask 生成完整的 CRUD REST API
# Claude 自动调用 java-spring:java-crud + 4 个 spring-boot-dev 生成器
```

#### 步骤 4.4 — 自主循环模式（大型任务）

**适用场景**：
- 跨多个文件的大规模实现（10+ 文件）
- 需要多轮迭代的任务序列
- 可自动验证的任务（有明确的完成条件）

**命令**：`/ralph-loop`

**示例**：
```bash
/ralph-loop --max-iterations 20 --completion-promise "task_plan.md 中所有 8 个任务标记为 [x] 完成，且 mvn test 全部通过"
```

**要求**：
- `--max-iterations`：建议 10-50，大任务 50+
- `--completion-promise`：必须是可自动验证的条件
  - ✅ 好："所有测试通过且覆盖率 ≥ 80%"
  - ✅ 好："task_plan.md 中所有任务标记完成"
  - ❌ 差："用户满意" （无法自动验证）

**停止循环**：
```bash
/cancel-ralph
```

#### 步骤 4.5 — 构建修复（遇到编译错误时）

```bash
# 命令
/java-core:java-fix

# 对话示例
用户：mvn compile 报错：cannot find symbol: class ExportTaskRepository
请修复构建错误
```

### 入口标准
- [ ] 阶段三出口标准全部满足
- [ ] 每个任务有明确验收标准
- [ ] 依赖任务已完成

### 出口标准
- [ ] 所有任务按 `task_plan.md` 顺序完成
- [ ] 所有测试通过
- [ ] 测试覆盖率 ≥ 80%（业务逻辑 ≥ 90%）
- [ ] `code-simplifier` 质量检查通过
- [ ] `progress.md` 已更新
- [ ] 无编译错误或警告

---

## 阶段五：代码审查

### 目标
多维度审查代码质量，确保安全、可维护、可扩展。

### 操作步骤

#### 步骤 5.1 — 提交代码审查

**前置条件**：所有测试通过、代码已提交

**命令**：`/requesting-code-review`

**示例对话**：
```
用户：/requesting-code-review
请审查分支 feature/order-export 上的变更：
- 8 个文件变更
- 新建 ExportController、ExportService、ExportTask 等
- 621 行新增代码

审查重点：
1. 安全：文件下载是否有路径遍历风险
2. 性能：是否有 N+1 查询
3. 错误处理：导出失败的异常是否被正确传播
```

#### 步骤 5.2 — 多维度审查

**命令**：`ecc:code-review`

**覆盖维度**：

| 维度 | 检查项 | 严重程度 |
|------|--------|----------|
| 安全性 | SQL 注入、XSS、命令注入、敏感信息泄漏 | 🔴 严重/高危 |
| 正确性 | 逻辑错误、边界条件、空值处理 | 🔴 严重 |
| 性能 | N+1 查询、不必要的循环、锁竞争 | 🟡 重要 |
| 可维护性 | 命名、函数长度、重复代码、耦合度 | 🟢 建议 |
| 可测试性 | 依赖注入、纯函数、无全局状态 | 🟢 建议 |
| 风格一致性 | 格式、命名规范、项目惯例 | 🟢 建议 |

#### 步骤 5.3 — 语言专项审查

**Java 审查**：`java-core:java-review`
```bash
# 触发方式
用户：请对 ExportService.java 进行 Java 代码审查
# Claude 自动调用 java-core:java-review 代理
```

**审查重点**：
- Java 惯用法是否正确
- 并发安全（是否正确使用 synchronized / volatile / Atomic）
- 资源管理（try-with-resources、连接关闭）
- 异常处理（受检异常 vs 非受检异常的选择）
- Optional 使用是否正确

#### 步骤 5.4 — 专项深度审查

**静默失败检测**：
```bash
# 触发方式
用户：请检查这些代码有没有静默失败的风险
# Claude 调用 ecc:silent-failure-hunter

# 典型问题：
# - catch 块中仅用 log.error() 未重新抛出
# - 返回值 null 而不抛出异常
# - Optional.orElse(null) 链路断裂
```

**注释质量分析**：
```bash
# 触发方式
用户：请分析注释质量
# Claude 调用 ecc:comment-analyzer

# 检查项：
# - 注释与代码是否一致（过时注释）
# - TODO/FIXME 是否有跟踪
# - 关键逻辑是否有非显而易见的注释
```

#### 步骤 5.5 — 处理审查反馈

**命令**：`/receiving-code-review`

**示例对话**：
```
用户：/receiving-code-review
审查反馈：
1. [严重] ExportService.download() 存在路径遍历风险，需验证 filePath
2. [重要] ExportTaskRepository.findPendingTasks() 应加 @Query 限制结果数量
3. [建议] 方法过长，建议拆分

请逐条处理
```

**处理流程**：
1. 逐条阅读反馈
2. 修复代码
3. 运行测试确认无回归
4. 标记评论为 resolved
5. 提交修复

### 入口标准
- [ ] 阶段四出口标准全部满足
- [ ] 代码已提交到本地分支

### 出口标准
- [ ] 安全相关无严重/高危问题
- [ ] 无静默失败风险（异常被吞噬、错误无传播）
- [ ] 注释准确（无过时、无误导）
- [ ] 所有审查评论已 resolved
- [ ] Approve

---

## 阶段六：测试验证

### 目标
全面验证功能正确性，覆盖所有测试层级。

### 操作步骤

#### 步骤 6.1 — 完成前验证

**命令**：`/verification-before-completion`

**示例对话**：
```
用户：/verification-before-completion
订单导出功能开发完成，请进行系统性验证：
- 检查所有测试是否通过
- 检查覆盖率是否达标
- 检查是否有遗漏的边界情况
- 检查代码风格是否一致
```

#### 步骤 6.2 — 覆盖率分析

**命令**：`ecc:test-coverage`

**示例对话**：
```
用户：请分析订单导出功能的测试覆盖率
重点检查 ExportService 和 ExportController 的覆盖率
```

**覆盖率标准**：
| 层级 | 最低要求 |
|------|----------|
| 业务逻辑（Service 层） | ≥ 90% |
| API 层（Controller） | ≥ 80% |
| 实体/工具类 | ≥ 80% |
| 全局 | ≥ 80% |

#### 步骤 6.3 — Java 测试工程

**命令**：`/java-quality:java-test`

**示例对话**：
```
用户：请为 ExportService 生成完整的测试套件，包括：
- 正常路径（Excel 生成、PDF 生成）
- 边界条件（空数据、超大日期范围）
- 错误态（文件系统满、数据源异常）
- 并发（两个导出任务同时触发）
```

#### 步骤 6.4 — E2E 测试

**命令**：`ecc:e2e-runner`

**示例对话**：
```
用户：请为订单导出功能创建 E2E 测试：
1. 用户登录 → 进入订单列表 → 选择日期范围 → 点击导出
2. 验证导出任务创建成功
3. 等待任务完成
4. 验证下载链接可用
```

**E2E 测试用例模板**：

```markdown
## E2E: 订单导出 Excel

### 前置条件
- 测试用户已创建
- 数据库中有 50 条测试订单
- 浏览器：Chrome 最新版

### 测试步骤
1. 用 test_user / test_pass 登录
2. 导航到 /orders
3. 选择日期范围：最近 7 天
4. 点击「导出」按钮
5. 在弹出面板选择 Excel 格式
6. 点击确认
7. 等待「导出任务已创建」提示
8. 等待通知显示「导出完成」
9. 点击通知中的下载链接

### 预期结果
- 导出任务状态变为 COMPLETED
- 下载文件为 .xlsx 格式
- 文件包含 50 条订单数据
- 响应时间 < 30s（50 条数据）
```

### 入口标准
- [ ] 阶段五出口标准全部满足

### 出口标准
- [ ] 单元测试覆盖率 ≥ 80%（业务逻辑 ≥ 90%）
- [ ] 集成测试覆盖所有 API 端点
- [ ] E2E 覆盖核心路径
- [ ] 所有测试绿色
- [ ] `verification-before-completion` 通过

---

## 阶段七：安全审查

### 目标
确保代码符合安全标准，消除已知漏洞。

### 操作步骤

#### 步骤 7.1 — 安全扫描

**命令**：`ecc:security-scan` 或 `/security-review`

**示例对话**：
```
用户：请对 feature/order-export 分支进行完整的安全扫描
重点：文件下载路径遍历、用户数据泄漏、权限绕过
```

#### 步骤 7.2 — STRIDE 审计

**命令**：`/cso`

**示例对话**：
```
用户：/cso
对订单导出功能执行 OWASP + STRIDE 完整审计
数据流：用户请求 → Controller → Service → 文件生成 → 存储 → 下载
信任边界：用户 ↔ API 之间、API ↔ 文件系统之间
```

**STRIDE 检查项**：

| 威胁类型 | 检查问题 | 示例 |
|----------|----------|------|
| **S**poofing（仿冒） | 谁可以创建导出任务？ | 验证 JWT Token、检查 userId |
| **T**ampering（篡改） | 能否修改其他用户的导出？ | 下载时验证文件归属 |
| **R**epudiation（抵赖） | 能否否认执行了导出？ | 审计日志记录所有导出操作 |
| **I**nformation（信息泄漏） | 能否看到其他用户的导出？ | /api/exports?userId=xxx → 403 |
| **D**enial of Service | 能否创建大量导出任务？ | 限制用户并发导出数 |
| **E**levation（提权） | 普通用户能否导出全部数据？ | 角色权限检查 ADMIN vs USER |

#### 步骤 7.3 — Java 专项安全

**命令**：`/java-quality:java-security-check`

**示例对话**：
```
用户：请对以下代码进行 Java 安全审查：
- ExportController.java（文件下载端点）
- ExportService.java（文件路径处理）

检查：
1. 路径遍历（Path Traversal）
2. 任意文件读取
3. XXE（XML External Entity）
4. 文件上传安全
```

**常见安全问题及修复示例**：

```java
// ❌ 不安全：路径遍历风险
@GetMapping("/download/{filename}")
public ResponseEntity<Resource> download(@PathVariable String filename) {
    Path file = Paths.get("/exports/" + filename);  // 危险！
    // 攻击者输入：../../etc/passwd
}

// ✅ 安全：路径验证 + 规范化
@GetMapping("/download/{filename}")
public ResponseEntity<Resource> download(@PathVariable String filename) {
    Path basePath = Paths.get("/exports/").toAbsolutePath().normalize();
    Path filePath = basePath.resolve(filename).normalize();

    // 确保解析后的路径在 basePath 内
    if (!filePath.startsWith(basePath)) {
        throw new SecurityException("Invalid file path");
    }

    // 验证文件归属
    ExportTask task = exportService.findByFilePath(filePath.toString());
    if (!task.getUserId().equals(getCurrentUserId())) {
        throw new AccessDeniedException("Not your file");
    }
}
```

### 入口标准
- [ ] 阶段六出口标准全部满足

### 出口标准
- [ ] 0 高危 / 0 严重安全漏洞
- [ ] STRIDE 审查无未处理风险
- [ ] 密钥/令牌不存于代码或配置文件
- [ ] 第三方依赖无已知严重 CVE
- [ ] 安全头配置正确
- [ ] PII/PHI 处理合规（如适用）

---

## 阶段八：性能审查

### 目标
识别并修复性能瓶颈。

### 操作步骤

#### 步骤 8.1 — 综合性能分析

**命令**：`ecc:performance-optimizer`

**示例对话**：
```
用户：请分析 ExportService 的性能问题
场景：运营人员导出最近 90 天订单（约 10 万条），出现了 30 秒超时
```

#### 步骤 8.2 — Java 专项性能

**命令**：`/java-quality:java-perf-check`

**示例对话**：
```
用户：请对 ExportService.exportExcel() 进行性能审查
关注：N+1 查询、内存使用、大对象创建
```

**常见性能问题与修复**：

```java
// ❌ 性能问题：N+1 查询
List<Order> orders = orderRepository.findAll();
for (Order order : orders) {
    List<OrderItem> items = orderItemRepository.findByOrderId(order.getId()); // N+1!
}

// ✅ 修复：JOIN FETCH
@Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.items WHERE o.createdAt BETWEEN :from AND :to")
List<Order> findOrdersWithItems(@Param("from") LocalDate from, @Param("to") LocalDate to);

// ❌ 性能问题：一次性加载全部数据到内存
List<Order> allOrders = orderRepository.findAll(); // 可能 OOM

// ✅ 修复：分页流式处理
try (Stream<Order> stream = orderRepository.findByCreatedAtBetween(from, to)) {
    stream.forEach(this::writeToExcel);
}
```

#### 步骤 8.3 — 数据库诊断

**MCP 触发**：对话中描述需求即可

**示例对话**：
```
用户：请检查 order 表的索引情况，重点分析订单导出查询是否使用了正确的索引

Claude 自动调用 db-analyzer MCP：
- analyze_indexes(schema="public", mode="all")
- explain_query(sql="SELECT ... FROM orders WHERE created_at BETWEEN ...")

预期输出：
- 缺失索引：orders.created_at 无索引 → 建议 CREATE INDEX
- 冗余索引：idx_orders_userid_status 与 idx_orders_userid 重叠
- 查询计划：Seq Scan on orders（全表扫描）→ 加索引后变为 Index Scan
```

#### 步骤 8.4 — JVM 诊断

**示例对话**：
```
用户：应用在处理大量导出任务时频繁 Full GC，请分析原因

Claude 调用 jvm-diagnostics MCP：
- analyze_gc_log（GC 频率、暂停时间）
- analyze_heap_histo（大对象分布）
- analyze_thread_dump（是否有阻塞）

预期输出：
- GC 问题：Young GC 频繁（每分钟 15 次），Full GC 每次暂停 3s
- 堆分析：byte[] 占堆 60%，疑为 POI 工作簿未关闭
- 建议：增加 -Xmx、使用 SXSSFWorkbook（流式 Excel）、确保 try-with-resources
```

#### 步骤 8.5 — Redis 诊断（如使用缓存）

**示例对话**：
```
用户：请检查 Redis 的缓存命中率和内存使用情况

Claude 调用 redis-diagnostics MCP：
- analyze_memory()、analyze_keyspace()

预期输出：
- 缓存命中率 45%（偏低）→ 建议调整过期策略
- 大 Key：exports:cache 占用 250MB → 建议拆分
```

### 入口标准
- [ ] 阶段七出口标准全部满足

### 出口标准
- [ ] 0 个 N+1 查询或全表扫描
- [ ] 数据库有合适索引
- [ ] GC 暂停 < 200ms
- [ ] API P95 < 500ms
- [ ] 无内存泄漏信号
- [ ] 缓存命中率 > 80%（如使用）

---

## 阶段九：上线准备

### 目标
确保代码、文档、配置准备好发布。

### 操作步骤

#### 步骤 9.1 — 分支收尾

**命令**：`/finishing-a-development-branch`

**示例对话**：
```
用户：/finishing-a-development-branch
分支：feature/order-export
目标分支：main

请执行收尾检查：
1. 所有测试是否通过
2. 是否有关联的 Issue 需要链接
3. 文档是否已更新
4. 提交信息是否规范
```

#### 步骤 9.2 — 数据库迁移审查

**示例对话**：
```
用户：请审查数据库迁移脚本 export_task.sql 的风险
[粘贴 SQL 内容]

Claude 调用 migration-advisor MCP：
- analyze_migration(filename="V2__add_export_task.sql", sql=...)

预期输出：
- 锁风险：CREATE TABLE export_tasks — ACCESS EXCLUSIVE lock（可接受，新表）
- 数据丢失风险：无
- 整体风险评分：15/100（低风险）
- 建议：可安全执行
```

**另一种情况（高风险）**：
```
预期输出：
- 锁风险：ALTER TABLE orders ADD COLUMN export_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
  → ACCESS EXCLUSIVE lock on orders（500 万行）
  → 预计锁持有时间：可能 30 秒+
- 建议：
  1. 先 ADD COLUMN 不加 NOT NULL
  2. 批量 UPDATE 填充默认值
  3. 再 ADD NOT NULL 约束
  4. 或使用在线 DDL 工具（pt-online-schema-change）
- 整体风险评分：75/100（高风险）⚠️
```

#### 步骤 9.3 — 创建检查点

**命令**：`/checkpoint`

**示例对话**：
```
用户：/checkpoint
即将上线订单导出 v2.1.0，创建检查点以备回滚

预期产出：
- 检查点 2026-05-19-export-v2.1.0 已创建
- 包含：代码状态 + 对话上下文
- 回滚命令：/rewind
```

#### 步骤 9.4 — 生成 Release Notes

**命令**：`/document-release`

**示例对话**：
```
用户：/document-release
版本：v2.1.0
功能：订单导出（Excel/PDF）
分支：feature/order-export
关联 Issue：#234

请生成 Release Notes
```

**预期产出**：
```markdown
# v2.1.0 — 订单导出功能

## 新增功能
- 支持导出订单为 Excel (.xlsx) 格式
- 支持导出订单为 PDF 格式
- 异步导出，大数据量不阻塞页面
- 导出完成后站内通知 + 邮件通知

## 技术变更
- 新增 export_tasks 表
- 集成 EasyExcel 3.3.x（替代 Apache POI）
- 新增 @Async 导出任务调度

## 升级注意事项
- 需执行数据库迁移 V2__add_export_task.sql
- 需添加文件存储目录权限
- 新增环境变量：EXPORT_FILE_DIR=/data/exports
```

### 入口标准
- [ ] 阶段八出口标准全部满足
- [ ] 所有 PR 已合并

### 出口标准
- [ ] 数据库迁移无高风险（或已确认可接受）
- [ ] Release Notes 已生成
- [ ] 监控告警已配置
- [ ] 回滚方案已就绪
- [ ] 检查点已创建

---

## 阶段十：上线

### 目标
安全地将变更部署到生产环境。

### 操作步骤

#### 步骤 10.1 — 一键发布

**命令**：`/ship`

**示例对话**：
```
用户：/ship
分支：feature/order-export
目标：main

请执行完整发布流程：
1. 运行最终测试
2. 最终代码审查
3. 推送到远程
4. 创建 PR（如未创建）
```

#### 步骤 10.2 — 金丝雀发布

**命令**：`/canary`

**示例对话**：
```
用户：/canary
版本：v2.1.0
策略：10% → 50% → 100%，每阶段 5 分钟观察

观察指标：
- HTTP 5xx 错误率 < 0.1%
- P95 响应时间 < 500ms
- 导出任务成功率 > 99%
```

**金丝雀观察模板**：

| 阶段 | 流量比例 | 观察时间 | 通过条件 |
|------|----------|----------|----------|
| Phase 1 | 10% | 5 min | 无 5xx 错误，导出成功率 ≥ 99% |
| Phase 2 | 50% | 5 min | P95 < 500ms，CPU < 70% |
| Phase 3 | 100% | 持续 | 所有指标正常，无异常告警 |

#### 步骤 10.3 — 合并部署

**命令**：`/land-and-deploy`

**示例对话**：
```
用户：/land-and-deploy
PR #245 已通过金丝雀验证，合并并全量部署
```

### 入口标准
- [ ] 阶段九出口标准全部满足
- [ ] 非高峰期/已协调上线窗口

### 出口标准
- [ ] 数据库迁移成功（无错误、无锁超时）
- [ ] 金丝雀各阶段指标正常
- [ ] 烟雾测试通过
- [ ] 无新错误日志
- [ ] 用户可正常访问

---

## 阶段十一：上线后监控

### 目标
确认上线稳定，持续监控。

### 操作步骤

#### 步骤 11.1 — 实时健康检查

**示例对话**：
```
用户：上线 5 分钟了，请检查系统健康状态

Claude 调用 spring-boot-actuator MCP：
- analyze_health(json=...) → 所有组件 UP
- analyze_metrics(json=...) → 导出端点 P95 = 320ms ✅
```

#### 步骤 11.2 — 安全守护

**命令**：`/guard`

**示例对话**：
```
用户：/guard
启动安全守护，监控范围：订单导出 API
异常阈值：5 分钟内错误率 > 1% 则告警
```

### 监控时间线

| 时间 | 动作 | 命令/工具 |
|------|------|-----------|
| 上线 + 5 min | 错误日志、核心 API 响应 | `spring-boot-actuator` |
| 上线 + 30 min | 业务指标（导出成功率）、用户反馈 | 业务 Dashboard |
| 上线 + 2 h | 性能基线对比（上线前 vs 上线后） | `jvm-diagnostics` + `db-analyzer` |
| 上线 + 24 h | 全面健康检查、关闭金丝雀监控 | `/guard` 检查 |

### 告警阈值速查

| 指标 | 工具 | 正常范围 | 告警阈值 |
|------|------|----------|----------|
| 错误率 | Actuator /health | < 0.1% | > 1% |
| 响应时间 P95 | Actuator /metrics | < 300ms | > 500ms |
| JVM 堆使用率 | `jvm-diagnostics` | 50-70% | > 85% |
| GC 暂停时间 | `jvm-diagnostics` | < 50ms | > 1s |
| 数据库连接池 | `db-analyzer` | 30-50% | > 80% |
| Redis 内存 | `redis-diagnostics` | < 60% | > 80% |

### 入口标准
- [ ] 阶段十出口标准全部满足

### 出口标准
- [ ] 24 小时内无异常告警
- [ ] 性能指标与基线一致
- [ ] 用户无负面反馈

---

## 质量标准与完成定义

### 代码质量门禁

| 指标 | 标准 | 检查工具 |
|------|------|----------|
| 测试覆盖率 | 整体 ≥ 80%，业务逻辑 ≥ 90% | `ecc:test-coverage` |
| 安全漏洞 | 0 高危 / 0 严重 | `ecc:security-scan` |
| 代码重复 | < 3% | `code-simplifier` |
| N+1 查询 | 0 | `db-analyzer` + `java-spring:java-jpa` |
| 静默失败 | 0 | `ecc:silent-failure-hunter` |
| API 响应 | P95 < 500ms | Actuator metrics |
| GC 暂停 | < 200ms | `jvm-diagnostics` |

### 完成定义 (Definition of Done)

一个功能被认为**完成**，必须满足：

- [ ] 代码已实现并通过所有测试
- [ ] 测试覆盖率达标（≥ 80%）
- [ ] 代码审查通过（Approved）
- [ ] 安全审查无高危/严重
- [ ] 性能审查无阻塞性问题
- [ ] 数据库迁移已分析且安全
- [ ] 文档已更新（API 文档、Release Notes、ADR 如有）
- [ ] `progress.md` 标记为完成
- [ ] 无遗留 TODO/FIXME（或已有跟踪 Issue）
- [ ] 上线后 24 小时无异常

---

## 命令速查表

### 一、流程命令（按阶段排列）

#### 阶段一：需求

| 命令 | 用途 | 示例 |
|------|------|------|
| `/brainstorming` | 头脑风暴，探索 3+ 方案 | `/brainstorming` 我想给系统加个导出功能 |
| `/office-hours` | 产品视角梳理需求 | `/office-hours` 这个导出功能要给运营团队用 |
| `/plan-ceo-review` | 战略优先级审查 | `/plan-ceo-review` 导出功能是否该现在做 |

#### 阶段二：设计

| 命令 | 用途 | 示例 |
|------|------|------|
| `/writing-plans` | 编写技术方案 | `/writing-plans` 基于以下需求编写技术方案：[需求] |
| `ecc:plan` | 软件架构规划 | 同上 |
| `/plan-eng-review` | 工程架构审查 | `/plan-eng-review` 审查以下技术方案：[方案] |
| `/plan-design-review` | UX/交互审查 | `/plan-design-review` 审查导出功能交互流程 |
| `ecc:architecture-decision-records` | 记录 ADR | 请为 EasyExcel vs POI 选型创建 ADR |

#### 阶段三：计划

| 命令 | 用途 | 示例 |
|------|------|------|
| `/planning-with-files:plan` | 创建持久化规划 | `/planning-with-files:plan` 基于方案分解任务 |
| `/planning-with-files:start` | 启动规划工作流 | 同上 |
| `/executing-plans` | 按计划逐步执行 | 后续各阶段使用 |

#### 阶段四：实现

| 命令 | 用途 | 示例 |
|------|------|------|
| `/test-driven-development` | TDD 红-绿-重构 | `/test-driven-development` 开始实现 Task 2 |
| `/ralph-loop` | 自主迭代执行 | `/ralph-loop --max-iterations 20 --completion-promise "所有测试通过"` |
| `/cancel-ralph` | 停止循环 | `/cancel-ralph` |
| `/code-simplifier` | 代码简化（自动触发） | 每次 Edit/Write 后自动提示 |
| `/java-spring:java-scaffold` | 新建 Spring Boot 项目 | `/java-spring:java-scaffold` 创建项目 |
| `/java-spring:java-crud` | 生成 CRUD | `/java-spring:java-crud` 为 Order 实体生成 CRUD |
| `/java-spring:java-jpa` | JPA 审查 | `/java-spring:java-jpa` 审查 OrderRepository |
| `/java-spring:java-security` | Security 配置 | `/java-spring:java-security` 配置 JWT 认证 |
| `/java-spring:java-openapi` | API 文档 | `/java-spring:java-openapi` 生成 Swagger 文档 |
| `/java-spring:java-cache` | 缓存策略 | `/java-spring:java-cache` 配置 Redis 缓存 |
| `/java-spring:java-resilience` | 弹性模式 | `/java-spring:java-resilience` 添加断路器 |
| `/java-spring:java-spring-ai` | AI 集成 | `/java-spring:java-spring-ai` 添加 RAG |
| `/java-spring:java-logging` | 日志审查 | `/java-spring:java-logging` 审查日志配置 |
| `/java-core:java-review` | 架构审查 | `/java-core:java-review` 审查项目架构 |
| `/java-core:java-fix` | 构建修复 | `/java-core:java-fix` 修复编译错误 |
| `/java-core:java-refactor` | 代码重构 | `/java-core:java-refactor` 重构 OrderService |
| `/java-core:java-explain` | 代码解释 | `/java-core:java-explain` 解释这段代码 |
| `/java-core:java-docs` | 文档生成 | `/java-core:java-docs` 生成 JavaDoc |
| `/java-core:java-clean-arch` | 清洁架构建议 | `/java-core:java-clean-arch` 重构为清洁架构 |
| `/java-core:java-concurrency-review` | 并发审查 | `/java-core:java-concurrency-review` 审查并发代码 |
| `/java-core:java-design-pattern` | 设计模式 | `/java-core:java-design-pattern` 这里用什么模式 |
| `/java-core:java-adr` | 架构决策 | `/java-core:java-adr` 记录技术选型 |
| `/java-core:java-migrate` | 迁移辅助 | `/java-core:java-migrate` 升级 Spring Boot 3 |
| `/java-core:java-commit` | 规范提交 | `/java-core:java-commit` 生成规范的 commit message |
| `/java-core:java-solid` | SOLID 原则审查 | `/java-core:java-solid` 审查 SOLID 合规性 |
| `/java-core:java-health` | 项目健康检查 | `/java-core:java-health` 全面健康检查 |
| `/java-core:java-api-review` | API 审查 | `/java-core:java-api-review` 审查 REST API 设计 |

#### 阶段五：审查

| 命令 | 用途 | 示例 |
|------|------|------|
| `/requesting-code-review` | 提交审查 | `/requesting-code-review` 请审查分支 feature/xxx |
| `ecc:code-review` | 多维度审查 | 同上 |
| `/receiving-code-review` | 处理反馈 | `/receiving-code-review` 逐条处理审查意见 |
| `ecc:comment-analyzer` | 注释质量 | 请分析代码注释质量 |
| `ecc:silent-failure-hunter` | 静默失败检测 | 请检查有没有静默失败风险 |
| `ecc:type-design-analyzer` | 类型设计 | 请分析类型设计合理性 |
| `/review` (gstack) | 团队视角审查 | `/review` 审查 PR #245 |
| `/simplify` | 并行简化审查 | `/simplify` 检查代码复用/质量/效率 |

#### 阶段六：测试

| 命令 | 用途 | 示例 |
|------|------|------|
| `/verification-before-completion` | 完成前验证 | `/verification-before-completion` 进行全面验证 |
| `ecc:test-coverage` | 覆盖率分析 | 请分析测试覆盖率 |
| `ecc:e2e-runner` | E2E 测试 | 请为导出功能创建 E2E 测试 |
| `/java-quality:java-test` | Java 测试工程 | `/java-quality:java-test` 生成测试套件 |
| `ecc:tdd-workflow` | TDD 工作流验证 | 检查 TDD 流程是否规范 |

#### 阶段七：安全

| 命令 | 用途 | 示例 |
|------|------|------|
| `ecc:security-scan` | OWASP 扫描 | 请进行全面安全扫描 |
| `/security-review` | 安全审查 | `/security-review` 审查已暂存的变更 |
| `/cso` | OWASP + STRIDE | `/cso` 对导出功能执行 STRIDE 审计 |
| `/java-quality:java-security-check` | Java 安全 | `/java-quality:java-security-check` |

#### 阶段八：性能

| 命令 | 用途 | 示例 |
|------|------|------|
| `ecc:performance-optimizer` | 综合性能分析 | 请分析导出功能的性能瓶颈 |
| `/java-quality:java-perf-check` | Java 性能 | `/java-quality:java-perf-check` |
| `ecc:harness-optimizer` | 代理优化 | 优化代理执行效率 |

#### 阶段九：上线准备

| 命令 | 用途 | 示例 |
|------|------|------|
| `/finishing-a-development-branch` | 分支收尾 | `/finishing-a-development-branch` |
| `/document-release` | Release Notes | `/document-release` 版本 v2.1.0 |
| `/checkpoint` | 创建检查点 | `/checkpoint` 上线前检查点 |

#### 阶段十：上线

| 命令 | 用途 | 示例 |
|------|------|------|
| `/ship` | 一键发布流程 | `/ship` |
| `/canary` | 金丝雀发布 | `/canary` 10% → 50% → 100% |
| `/land-and-deploy` | 合并并部署 | `/land-and-deploy` |
| `ecc:deployment-patterns` | 部署模式指导 | 这个服务适合蓝绿还是金丝雀？ |

#### 阶段十一：监控

| 命令 | 用途 | 示例 |
|------|------|------|
| `/guard` | 安全守护 | `/guard` 启动导出 API 安全监控 |
| `ecc:canary-watch` | 金丝雀观察 | 查看金丝雀指标 |

---

### 二、Spring Boot 代码生成命令

| 命令 | 生成内容 | 示例 |
|------|----------|------|
| `spring-boot-dev:spring-boot-package-structure-creator` | 标准包结构 | 请为 com.example.order 创建包结构 |
| `spring-boot-dev:jpa-entity-creator` | JPA 实体 | 请创建 Order JPA 实体 |
| `spring-boot-dev:spring-data-jpa-repo-creator` | Repository | 请创建 OrderRepository |
| `spring-boot-dev:spring-service-creator` | Service 层 | 请创建 OrderService |
| `spring-boot-dev:spring-rest-api-creator` | REST Controller | 请创建 OrderController |

---

### 三、MCP 诊断命令（对话中自然触发）

| 诊断需求 | 对话示例 | 调用 MCP |
|----------|----------|----------|
| **数据库 Schema** | "请分析 public schema 的表结构和行数" | `db-analyzer: inspect_schema` |
| **索引建议** | "orders 表查询很慢，请分析索引" | `db-analyzer: analyze_indexes` |
| **查询计划** | "这个 SQL 为什么慢？SELECT * FROM orders WHERE..." | `db-analyzer: explain_query` |
| **表膨胀** | "orders 表越来越大，检查膨胀情况" | `db-analyzer: analyze_table_bloat` |
| **表关系** | "画出所有表的外键关系图" | `db-analyzer: analyze_table_relationships` |
| **活跃连接** | "检查是否有 idle-in-transaction 连接" | `db-analyzer: analyze_connections` |
| **线程 Dump** | "帮我分析这段 jstack 输出" | `jvm-diagnostics: analyze_thread_dump` |
| **GC 日志** | "分析这段 GC 日志" | `jvm-diagnostics: analyze_gc_log` |
| **堆分析** | "分析 jmap -histo 输出，找内存泄漏" | `jvm-diagnostics: analyze_heap_histo` |
| **堆对比** | "对比两次 jmap 快照，看哪些对象在增长" | `jvm-diagnostics: compare_heap_histos` |
| **JFR 分析** | "分析 jfr summary 输出" | `jvm-diagnostics: analyze_jfr` |
| **综合诊断** | "同期 thread dump + GC log 一起分析" | `jvm-diagnostics: diagnose_jvm` |
| **迁移 SQL 分析** | "分析 V2__add_export_task.sql 的锁风险" | `migration-advisor: analyze_migration` |
| **Liquibase XML** | "分析 changelog.xml 的风险" | `migration-advisor: analyze_liquibase` |
| **迁移冲突** | "这两个迁移脚本有没有冲突？" | `migration-advisor: detect_conflicts` |
| **生成回滚** | "生成 V2 迁移的 rollback SQL" | `migration-advisor: generate_rollback` |
| **风险评分** | "给这个迁移打个分" | `migration-advisor: score_risk` |
| **Actuator 健康** | "检查 /actuator/health 状态" | `spring-boot-actuator: analyze_health` |
| **Actuator 指标** | "分析 /actuator/metrics 的关键指标" | `spring-boot-actuator: analyze_metrics` |
| **环境变量检查** | "检查 /actuator/env 有没有暴露密钥" | `spring-boot-actuator: analyze_env` |
| **Bean 依赖图** | "检查 Spring Bean 有没有循环依赖" | `spring-boot-actuator: analyze_beans` |
| **Redis 内存** | "检查 Redis 内存使用和碎片率" | `redis-diagnostics: analyze_memory` |
| **Redis 慢日志** | "查看 Redis 慢查询" | `redis-diagnostics: analyze_slowlog` |
| **Redis 客户端** | "检查 Redis 连接池是否饱和" | `redis-diagnostics: analyze_clients` |
| **Redis 综合** | "Redis 全面健康检查" | `redis-diagnostics: analyze_performance` |
| **Redis 配置** | "检查 Redis 安全配置" | `redis-diagnostics: analyze_config` |
| **Redis 复制** | "检查 Redis 主从复制延迟" | `redis-diagnostics: analyze_replication` |

---

### 四、会话管理命令

| 命令 | 用途 | 示例 |
|------|------|------|
| `/cost` | 查看会话费用 | `/cost` |
| `/usage` | 查看账户用量 | `/usage` |
| `/context` | 可视化上下文窗口 | `/context` |
| `/stats` | 使用统计 | `/stats` |
| `/clear` | 清空上下文 | `/clear` |
| `/compact` | 压缩上下文 | `/compact 保留架构设计部分` |
| `/resume` | 恢复会话 | `/resume` |
| `/rewind` | 回滚到检查点 | `/rewind` |
| `/rename` | 重命名会话 | `/rename 订单导出功能开发` |
| `/checkpoint` | 创建检查点 | `/checkpoint` |
| `/export` | 导出对话 | `/export session-log.md` |
| `/mem-search` | 搜索历史记忆 | `/mem-search 数据库连接池配置` |
| `/learn-codebase` | 学习代码库 | `/learn-codebase` |
| `/skills` | 列出所有技能 | `/skills` 或输入 `/` 后按 Tab |
| `/status` | 会话状态 | `/status` |
| `/doctor` | 环境健康检查 | `/doctor` |
| `/tasks` | 后台任务管理 | `/tasks` |
| `scripts/install.sh` | 核心能力一键安装 + 升级 | `bash scripts/install.sh` |
| `/bashes` | 后台命令列表 | `/bashes` |

---

### 五、其他专项命令

#### GStack 命令

| 命令 | 用途 | 示例 |
|------|------|------|
| `/qa` | 完整 QA（含 E2E） | `/qa` 测试订单导出功能 |
| `/qa-only` | 仅浏览器 E2E | `/qa-only` |
| `/investigate` | Bug 调查 | `/investigate` 导出任务一直 PENDING |
| `/browse` | 浏览器交互 | `/browse` 打开测试页面 |
| `/document-generate` | 文档生成 | `/document-generate` 生成 API 文档 |
| `/careful` | 高风险操作确认 | `/careful` 删除生产数据库 |
| `/freeze` | 冻结变更 | `/freeze` 上线窗口前冻结 |
| `/unfreeze` | 解冻变更 | `/unfreeze` 上线完成解冻 |
| `/retro` | 回顾总结 | `/retro` 回顾本次 Sprint |
| `/health` | GStack 健康检查 | `/health` |

#### ECC 专项

| 命令 | 用途 | 示例 |
|------|------|------|
| `ecc:quality-gate` | 质量门禁 | 合并前运行所有检查 |
| `ecc:production-audit` | 生产审计 | 审计生产环境配置 |
| `ecc:repo-scan` | 仓库扫描 | 全面健康检查 |
| `ecc:refactor-clean` | 重构清理 | 清理死代码和重复 |
| `ecc:database-migrations` | 迁移管理 | 管理数据库迁移脚本 |
| `ecc:error-handling` | 错误处理审查 | 检查错误处理模式 |
| `ecc:git-workflow` | Git 工作流 | 选择合适的分支策略 |
| `ecc:seo` | SEO 审计 | 前端 SEO 优化 |
| `ecc:accessibility` | 无障碍审查 | WCAG 2.2 合规检查 |
| `ecc:api-design` | API 设计审查 | 审查 REST API 设计 |
| `ecc:docker-patterns` | Docker 模式 | Dockerfile 和 Compose 最佳实践 |
| `ecc:postgres-patterns` | PG 模式 | PostgreSQL 最佳实践 |
| `ecc:redis-patterns` | Redis 模式 | Redis 使用模式 |
| `ecc:springboot-patterns` | Spring Boot 模式 | Spring Boot 最佳实践 |
| `ecc:batch` | 大规模重构 | `/batch 将所有 API 从 v1 迁移到 v2` |
| `ecc:checkpoint` | 检查点 | 创建/恢复检查点 |
| `ecc:multi-execute` | 多代理并行 | 多代理同时工作 |

---

## 角色分工

| 角色 | 技能 | 何时使用 | 职责 |
|------|------|----------|------|
| **CEO** | `plan-ceo-review` | 新功能立项前 | 战略优先级、投资回报率 |
| **产品经理** | `office-hours` | 需求不清晰时 | 用户故事、验收条件、MVP 范围 |
| **架构师** | `plan-eng-review` `java-core:java-architect` `ecc:architecture-decision-records` | 方案设计阶段 | 技术方案、系统架构、技术选型 ADR |
| **工程师** | TDD + `executing-plans` + 全系列 Java 命令 | 实现阶段 | 写代码、写测试、重构、构建修复 |
| **设计师** | `plan-design-review` `design-review` | 涉及 UI 时 | 交互设计、可用性、视觉一致性 |
| **QA** | `qa` `qa-only` `e2e-runner` `test-coverage` | 测试阶段 | E2E 测试、回归测试、覆盖率验证 |
| **安全官** | `cso` `security-review` `java-security-reviewer` | 安全审查阶段 | OWASP Top 10、STRIDE、注入检测 |
| **性能工程师** | `performance-optimizer` `java-perf-check` | 性能审查阶段 | N+1 检测、JVM 调优、索引优化 |
| **运维/DevOps** | `ship` `canary` `land-and-deploy` `guard` | 上线阶段 | 部署策略、金丝雀、回滚 |
| **开发体验** | `plan-devex-review` `devex-review` | 持续 | API 易用性、开发效率、工具链 |
