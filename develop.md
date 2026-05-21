# 开发工作方法论 v2.0

> 基于当前安装的 10 插件 + 7 Skill + 13 MCP 服务制定的端到端开发流程
> 更新日期：2026-05-21
>
> **v2.0 更新**：按 10 种项目类型/技术栈给出差异化实践，新增 NFR 收集、CI/CD、事故响应等环节

---

## 项目类型速查

> 快速定位你的技术栈，跳转到对应专属内容。每种类型在各阶段均有差异化指导。

| # | 模板目录 | 适用场景 | 技术栈关键词 | 核心差异点 |
|---|----------|---------|-------------|-----------|
| 1 | `java-springboot` | Java 后端微服务 | Spring Boot 3.5 + MyBatis Plus + Dubbo + Kafka | **重点** JVM 诊断、数据库迁移审查、Nacos 配置 |
| 2 | `react-umi` | React PC 管理端 | TypeScript + Umi Max + Antd 5 + ProComponents | **重点** ProTable/ProForm、路由权限、Umi 构建配置 |
| 3 | `typescript-vite-react` | React SPA 前端 | TypeScript + Vite + React Router + Zustand | **重点** Vite 代理、纯前端部署、浏览器兼容 |
| 4 | `typescript-nextjs-react` | React 全栈项目 | TypeScript + Next.js 15 + App Router + Prisma | **重点** SSR/SSG 策略、Server Action、Vercel 部署 |
| 5 | `monorepo` | 大型多技术栈仓库 | 多语言混合（Java + TS + Dart + 小程序） | **重点** 跨项目协调、共享类型、分批提交 |
| 6 | `flutter-pos` | Flutter 移动端 | Flutter 3 + Provider + Freezed + Dio + sqflite | **重点** 离线优先、硬件集成、平台通道 |
| 7 | `wechat-miniprogram` | 微信小程序 | TypeScript + 原生小程序 + TDesign | **重点** 包体积限制、审核流程、wx API 封装 |
| 8 | `session-logging` | 会话日志系统 | Hook 脚本 + Markdown + Shell | **重点** Hook 配置正确性、日志路由规则 |
| 9 | `docs-config` | 文档/配置项目 | Markdown + Shell + JSON | **重点** 模板完备度、文档规范、幂等脚本 |
| 10 | `global` | 通用/未分类项目 | 任意技术栈 | **重点** 按实际技术栈补充规范 |

---

## 目录

- [第一部分：通用开发流程（13 阶段）](#第一部分通用开发流程13-阶段)
  - [阶段 0：项目初始化与 NFR 收集](#阶段-0项目初始化与-nfr-收集)
  - [阶段一：需求与头脑风暴](#阶段一需求与头脑风暴)
  - [阶段二：方案设计与确认](#阶段二方案设计与确认)
  - [阶段三：开发计划制定](#阶段三开发计划制定)
  - [阶段四：TDD 实现](#阶段四tdd-实现)
  - [阶段五：代码审查](#阶段五代码审查)
  - [阶段六：测试验证](#阶段六测试验证)
  - [阶段七：安全审查](#阶段七安全审查)
  - [阶段八：性能审查](#阶段八性能审查)
  - [阶段九：CI/CD 与持续交付](#阶段九cicd-与持续交付)
  - [阶段十：上线准备](#阶段十上线准备)
  - [阶段十一：上线](#阶段十一上线)
  - [阶段十二：上线后监控与事故响应](#阶段十二上线后监控与事故响应)
- [第二部分：技术栈专项补充](#第二部分技术栈专项补充)
- [第三部分：质量标准与完成定义](#第三部分质量标准与完成定义)
- [第四部分：命令速查表](#第四部分命令速查表)

---

## 第一部分：通用开发流程（13 阶段）

```
项目初始化 → 需求 → 方案 → 计划 → TDD → 审查 → 测试 → 安全 → 性能 → CI/CD → 上线准备 → 上线 → 监控与事故响应
    ↓          ↓      ↓      ↓      ↓      ↓      ↓      ↓      ↓       ↓        ↓       ↓          ↓
  NFR收集    头脑    架构   持久化  红绿    多维    覆盖    OWASP   JVM+    流水线    分支     金丝      实时
  技术选型    风暴    设计   规划    重构    审查    率+E2E  STRIDE  DB      自动化    收尾     雀       告警
```

### 各阶段技术栈重要性矩阵

> 🔴 = 该类型项目此阶段极其重要 | 🟡 = 有一定差异 | ⚪ = 通用流程即可

| 阶段 | java-springboot | react-umi | vite-react | nextjs | monorepo | flutter | miniprogram | session-logging | docs-config |
|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 阶段0 NFR收集 | 🔴 | 🟡 | 🟡 | 🔴 | 🔴 | 🔴 | 🔴 | ⚪ | ⚪ |
| 阶段一 需求 | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | ⚪ | ⚪ |
| 阶段二 方案设计 | 🔴 | 🟡 | 🟡 | 🔴 | 🔴 | 🟡 | 🟡 | ⚪ | ⚪ |
| 阶段三 计划 | 🟡 | 🟡 | 🟡 | 🟡 | 🔴 | 🟡 | 🟡 | 🟡 | ⚪ |
| 阶段四 TDD | 🔴 | 🟡 | 🟡 | 🔴 | 🔴 | 🔴 | 🟡 | ⚪ | ⚪ |
| 阶段五 审查 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🟡 | 🟡 |
| 阶段六 测试 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | ⚪ | ⚪ |
| 阶段七 安全 | 🔴 | 🟡 | 🟡 | 🔴 | 🔴 | 🟡 | 🔴 | ⚪ | ⚪ |
| 阶段八 性能 | 🔴 | 🟡 | 🟡 | 🔴 | 🔴 | 🔴 | 🔴 | ⚪ | ⚪ |
| 阶段九 CI/CD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | ⚪ | ⚪ |
| 阶段十 上线准备 | 🔴 | 🟡 | 🟡 | 🔴 | 🔴 | 🔴 | 🔴 | ⚪ | ⚪ |
| 阶段十一 上线 | 🔴 | 🟡 | 🟡 | 🔴 | 🔴 | 🔴 | 🔴 | ⚪ | ⚪ |
| 阶段十二 监控 | 🔴 | ⚪ | ⚪ | 🔴 | 🔴 | 🔴 | 🟡 | ⚪ | ⚪ |

---

### 阶段 0：项目初始化与 NFR 收集

> **定位**：在需求分析之前，明确项目的非功能性约束和技术基线。**这是最容易跳过的环节，也是后期返工的主要原因。**

#### 目标
在写第一行代码前，锁定技术选型、非功能性需求(NFR)、项目边界。

#### 步骤 0.1 — 技术选型确认

**命令**：`ecc:plan` 或 `java-core:java-adr`

**辅助工具**：Context7 MCP（查询最新框架文档、版本兼容性、API 变更）

**输入要求**：项目类型、目标用户量、团队技能

**产出**：技术选型决策记录（ADR-000: 项目技术基线）

> **重点** 对于已有项目（非新建），先执行 `/learn-codebase` 让 Memory 系统学习整个代码库。后续会话会自动注入相关架构上下文，大幅减少反复解释项目结构的时间。执行后在 `http://localhost:37701` 确认记忆已播种。

| 项目类型 | 必选技术栈 | 可选替代 | **重点** 决策依据 |
|----------|-----------|---------|-------------------|
| **java-springboot** | Spring Boot 3.5 + MyBatis Plus + MySQL | Spring Data JPA（复杂查询少时）、PostgreSQL（需高级 SQL 特性） | **重点** 团队 Spring 经验、Dubbo 还是 REST、Nacos 还是 Consul |
| **react-umi** | Umi Max + Antd 5 + ProComponents | Antd 4（存量）、Arco Design（轻量） | **重点** 后台管理标准度高，ProComponents 可省 60% CRUD 代码 |
| **vite-react** | Vite 6 + React Router 7 + Zustand | React Router 6、Redux Toolkit（大项目） | **重点** Vite 代理配置解决跨域，路由懒加载做代码分割 |
| **nextjs** | Next.js 15 App Router + Prisma/Drizzle + Auth.js | Pages Router（存量）、NextAuth v4 | **重点** App Router 是未来，Server Component 减少客户端 JS |
| **monorepo** | pnpm workspace + 各子项目独立技术栈 | Turborepo、Nx（大型团队） | **重点** 共享方式：shared 包 vs 各自维护 vs 类型拷贝 |
| **flutter-pos** | Flutter 3 + Provider + Freezed + Dio | Riverpod、BLoC（大型项目） | **重点** 离线优先架构是 POS 刚需，sqflite 做本地队列 |
| **miniprogram** | TypeScript + TDesign + 原生框架 | uni-app（跨端）、WMPF（IoT） | **重点** 包体积 20MB 硬限制，npm 包需构建后才能用 |
| **session-logging** | Shell + jq + Markdown | Python（复杂解析） | **重点** Shell 脚本兼容性（macOS/Linux），jq 版本差异 |
| **docs-config** | Markdown + Shell | AsciiDoc（复杂文档） | **重点** 模板完备度三级体系（基础/标准/完整） |

#### 步骤 0.2 — NFR 收集清单

**🔑 每个项目类型必须明确的 NFR：**

```markdown
## 通用 NFR（所有项目类型必须收集）

### 性能
- [ ] API 响应时间目标：P50 < ___ms, P95 < ___ms, P99 < ___ms
- [ ] 并发用户数：峰值 ___ 用户同时在线
- [ ] 数据量级：单表最大 ___ 行，日增 ___ 行
- [ ] 页面加载时间：FCP < ___s, LCP < ___s, TTI < ___s（前端项目）

### 可用性
- [ ] SLA 目标：___%（如 99.9% = 月宕机 43 分钟）
- [ ] 维护窗口：每周 ___ 时段
- [ ] 降级策略：核心链路 ≥ ___% 可用，非核心可降级

### 安全
- [ ] 认证方式：JWT / OAuth2.0 / Session / 微信登录
- [ ] 数据分级：公开 / 内部 / 敏感 / 机密
- [ ] 合规要求：GDPR / 等保 / PCI-DSS / HIPAA / 无
- [ ] 审计日志：是否需要、保留多久

### 可扩展性
- [ ] 水平扩展：是否支持、是否需要无状态设计
- [ ] 数据分片：是否需要、分片键是什么
- [ ] 未来 ___ 个月的用户/数据增长预估

### 运维
- [ ] 部署方式：Docker / K8s / 物理机 / Vercel / 微信审核
- [ ] 日志方案：ELK / 阿里云 SLS / 腾讯云 CLS / 无
- [ ] 监控方案：Prometheus + Grafana / Spring Boot Actuator / 无
- [ ] 告警通道：钉钉 / 飞书 / 企微 / PagerDuty
```

| 项目类型 | 额外必填 NFR | **重点** 原因 |
|----------|-------------|-------------|
| **java-springboot** | 数据库连接池大小、JVM 堆配置(-Xmx)、Dubbo 超时/重试策略 | 后端是性能瓶颈集中点 |
| **react-umi** | 浏览器兼容范围（Chrome 90+）、首屏加载目标、菜单权限粒度 | 管理端用户浏览器环境多样 |
| **vite-react** | CDN 部署策略、浏览器兼容（含移动端?）、SEO 需求（SPA 先天弱） | SPA 部署需要 nginx try_files |
| **nextjs** | SSR/SSG/ISR 策略、Edge/Node 运行时选择、图片优化方案 | 渲染策略选错影响全站性能 |
| **monorepo** | 子项目间 API 契约版本化策略、共享代码的变更广播机制 | 跨项目破坏性变更的传播控制 |
| **flutter-pos** | 离线数据同步策略、硬件兼容清单（打印机型号/扫码枪）、电量/内存约束 | POS 硬件碎片化严重 |
| **miniprogram** | 微信版本最低要求、分包策略、云开发用量预估 | 审核周期 1-7 天影响发布节奏 |
| **session-logging** | Hook 事件覆盖清单、日志文件大小上限 | 无运行时，关注文件系统 |
| **docs-config** | 模板支持的技术栈范围、同步更新机制 | 文档过时比没有更危险 |

#### 步骤 0.3 — 项目脚手架初始化

| 项目类型 | 初始化命令/工具 | **重点** 注意事项 |
|----------|----------------|-------------------|
| **java-springboot** | `/java-spring:java-scaffold` | 确认 Spring Boot 版本、Java 版本、Maven 多模块结构 |
| **react-umi** | `pnpm create umi` | 选择 Max 模板（内置 ProComponents、权限、布局） |
| **vite-react** | `pnpm create vite` → react-ts | 安装 React Router、Zustand、TanStack Query |
| **nextjs** | `pnpm create next-app@latest` | 选择 App Router、TypeScript、Tailwind CSS、src/ 目录 |
| **monorepo** | 手动创建根 pnpm-workspace.yaml | 先建根目录配置，再逐一脚手架初始化子项目 |
| **flutter-pos** | `flutter create --org com.example pos_app` | 配置 build_runner、freezed、json_serializable |
| **miniprogram** | 微信开发者工具新建项目 | 选 TypeScript 模板，配置 TDesign |
| **session-logging** | `cp templates/session-logging/* <目标项目>/` | Hook 脚本必须 chmod +x |
| **docs-config** | `mkdir -p scripts/claude/templates/<name>` | 至少 CLAUDE.md，推荐 settings.local.json |

#### 步骤 0.4 — 项目配置文件生成

> **重点** 按模板完备度三级生成配置：
> - 基础级（小项目/单人）：仅 CLAUDE.md
> - 标准级（常规项目/2-5人团队）：CLAUDE.md + settings.local.json
> - 完整级（大项目/5+人团队）：CLAUDE.md + settings.local.json + .mcp.json + hooks

| 项目类型 | 推荐完备度 | MCP 服务 | **重点** settings 配置 |
|----------|-----------|---------|----------------------|
| **java-springboot** | 完整级 | db-analyzer + jvm-diagnostics + migration-advisor + spring-boot-actuator + redis-diagnostics | permissions.allow 放开 mvn/git/docker |
| **react-umi** | 标准级 | playwright（E2E） | permissions.allow 放开 pnpm |
| **vite-react** | 标准级 | playwright（E2E） | permissions.allow 放开 pnpm/vite |
| **nextjs** | 完整级 | playwright + db-analyzer（如有 DB） | permissions.allow 放开 pnpm/vercel |
| **monorepo** | 完整级 | 按子项目需要配置 | 每个子项目有独立 settings.local.json |
| **flutter-pos** | 标准级 | 无特殊 | permissions.allow 放开 flutter/dart |
| **miniprogram** | 标准级 | 无特殊 | permissions.allow 放开 pnpm |
| **session-logging** | 完整级 | 无特殊 | hooks 配置是核心 |
| **docs-config** | 基础级 | 无特殊 | 按需 |

#### 入口标准
- 项目需求已提出（可以是模糊的）

#### 出口标准
- [ ] 技术选型已记录（ADR-000）
- [ ] NFR 清单按项目类型填写完成
- [ ] 项目脚手架已初始化并验证可运行
- [ ] 项目配置文件已就位（CLAUDE.md + settings.local.json 最低）
- [ ] 团队对 NFR 已确认（性能和可用性目标是关键）

---

### 阶段一：需求与头脑风暴

#### 目标
将模糊想法转化为清晰的、可执行的需求描述。不同项目类型需求分析侧重点不同。

#### 步骤 1.1 — 头脑风暴

**命令**：`/brainstorming`

**辅助工具**：Context7 MCP — 查询竞品方案中涉及框架的最新 API，避免基于过时文档做决策。Exa MCP — 搜索同类项目的技术方案和最佳实践。

**通用产出**：
- 3+ 个方案及其优缺点对比
- 推荐方案及理由
- 关键边界条件和风险点

| 项目类型 | 头脑风暴侧重点 | **重点** 必须覆盖 |
|----------|--------------|-------------------|
| **java-springboot** | API 契约、数据模型、异步任务 | **重点** 数据库表结构草图、接口路径与请求/响应格式、消息队列 Topic 设计 |
| **react-umi** | 页面结构、权限模型、表单复杂度 | **重点** 菜单层级、权限粒度（路由级/按钮级/数据级）、ProTable 列定义 |
| **vite-react** | 路由设计、组件树、数据流 | **重点** 浏览器兼容范围、是否需要 SSR、SEO 影响评估 |
| **nextjs** | Server/Client 边界、渲染策略、数据获取 | **重点** 哪些页面 SSR、哪些 SSG、哪些 CSR，Server Action 范围 |
| **monorepo** | 影响哪些子项目、API 改动范围 | **重点** 先改后端还是前后端并行、共享类型如何处理 |
| **flutter-pos** | 离线场景、硬件交互、UI 交互流 | **重点** 断网时哪些操作可用、哪些需排队、硬件异常如何提示 |
| **miniprogram** | 微信生态集成、分包规划、审核风险 | **重点** 是否需要微信支付/订阅消息/获取手机号、审核可能被拒的点 |
| **session-logging** | Hook 事件覆盖、路由规则、文件结构 | **重点** 新规则是否与已有规则冲突、日志文件大小控制 |
| **docs-config** | 受众、更新频率、模板覆盖范围 | **重点** 写给 AI 看还是人看、需要多少代码示例 |

#### 步骤 1.2 — 产品审查

**命令**：`/office-hours`

**通用产出**：用户故事（As a / I want / So that）+ 验收条件（Given / When / Then）+ MVP 范围

**各类型差异**：

| 项目类型 | 用户故事示例 | **重点** 验收条件 |
|----------|-------------|-------------------|
| **java-springboot** | As a 运营人员, I want 导出最近30天订单 | Given 选择日期范围 When 点击导出 Then 创建异步任务 |
| **react-umi** | As a 管理员, I want 在列表中批量操作 | Given 勾选3条记录 When 点击批量删除 Then 弹出确认框 |
| **vite-react** | As a 用户, I want 离线也能浏览已加载内容 | Given 断网 When 点击已访问页面 Then 展示缓存内容 |
| **nextjs** | As a 访客, I want 页面3秒内可见 | Given 慢网速 When 打开商品详情 Then 骨架屏先展示 |
| **flutter-pos** | As a 收银员, I want 扫码即加购物车 | Given 扫描商品条码 When 识别成功 Then 购物车+1 + 提示音 |
| **miniprogram** | As a 用户, I want 微信一键登录 | Given 点击微信登录 When 授权 Then 无需手机号直接进入 |

#### 步骤 1.3 — 战略审查（关键功能）

**命令**：`/plan-ceo-review`

各类型项目的战略审查侧重点：

| 项目类型 | **重点** 战略考量 |
|----------|-------------------|
| **java-springboot** | 接口改动是否影响下游消费者（前端/小程序/第三方） |
| **react-umi / vite-react** | 是否可用组件库快速搭建（降低开发成本） |
| **nextjs** | 是否可用 Server Component 减少客户端复杂度 |
| **monorepo** | 跨项目改动的协调成本，是否值得现在做 |
| **flutter-pos** | 硬件兼容性测试成本，是否覆盖主流设备 |
| **miniprogram** | 审核周期对发布节奏的影响，是否需要灰度 |

#### 入口标准
- 用户提出功能需求或 Bug 描述

#### 出口标准
- [ ] 至少 3 个备选方案被评估
- [ ] 用户故事已编写（含技术栈特定验收条件）
- [ ] 关键风险已识别（含项目类型特有风险）
- [ ] 方案与已有架构无冲突

---

### 阶段二：方案设计与确认

#### 目标
将需求转化为技术方案，产生架构决策记录。**不同技术栈的方案设计输出物差异很大。**

#### 步骤 2.1 — 编写技术方案

**命令**：`/writing-plans` 或 `ecc:plan`

**辅助工具**：Context7 MCP — 确认所选框架/库的最新 API 签名、配置项、版本兼容性，避免方案设计时用了过时或废弃的 API。

**通用产出**：文件清单 + API 接口定义 + 数据流 + 技术选型

**🔑 按项目类型的方案设计模板：**

##### java-springboot 后端方案模板

```markdown
## 技术方案：<功能名>

### 数据库变更
- 新建表：xxx（字段、索引、分表策略）
- 修改表：xxx（ALTER 风险分析、数据迁移方案）

### API 设计
POST   /api/v1/xxx          创建
GET    /api/v1/xxx/{id}      查询
PUT    /api/v1/xxx/{id}      更新
DELETE /api/v1/xxx/{id}      删除

### 分层设计
- Controller：参数校验、R<T> 响应
- Service：核心逻辑、事务边界、异步处理
- Mapper：SQL 语句、分页查询
- 消息队列：Topic 名称、消息体、消费者

### 技术选型
| 能力 | 选择 | **重点** 理由 |
|------|------|-------------|
| 异步 | @Async vs Kafka | 数据量 < 1000 条用 @Async，超过用 Kafka |
| Excel | EasyExcel vs POI | 大数据量用 EasyExcel（流式，省内存） |
| 分布式锁 | Redisson | 不要自己用 SETNX 实现 |
```

##### React 前端方案模板（react-umi / vite-react 通用）

```markdown
## 技术方案：<功能名>

### 页面结构
- 路由：/xxx/list（列表）、/xxx/detail/:id（详情）、/xxx/create（新建）
- 组件树：PageLayout → SearchForm + DataTable + ActionBar

### 状态设计
| 状态 | 存放位置 | **重点** 理由 |
|------|---------|-------------|
| 列表数据 | TanStack Query / useRequest | 服务端数据，自动缓存 |
| 筛选条件 | URL SearchParams | 可分享、可回退 |
| UI 状态 | useState | 弹窗、加载态、选中行 |

### API 对接
- 请求封装：apiClient.get<PageResult<User>>('/api/v1/users', params)
- 错误处理：统一拦截器，code !== 0 展示 msg
- 加载态：Skeleton / Spin
- 空态：Empty 组件 + 引导文案

### 权限设计（如有）
- 路由级：access = 'canViewDashboard'
- 按钮级：<Access accessible={canDelete}>删除</Access>
```

##### Next.js 全栈方案模板

```markdown
## 技术方案：<功能名>

### 渲染策略
| 页面 | 策略 | **重点** 理由 |
|------|------|-------------|
| /products | SSG + ISR 60s | 商品数据变化不频繁 |
| /cart | CSR | 用户相关，需实时 |
| /admin/dashboard | SSR | 需要最新数据 + SEO 不重要 |

### Server / Client 边界
- Server Component：数据获取、数据库查询、无交互的 UI
- Client Component：表单交互、状态管理、useEffect 副作用

### Server Action 设计
- 表单提交走 Server Action（无需额外 API Route）
- 复杂查询走 API Route（GET 请求）

### 数据库操作
- Prisma / Drizzle 查询，不在 Client Component 中直接调
- revalidatePath / revalidateTag 做缓存失效
```

##### Flutter 移动端方案模板

```markdown
## 技术方案：<功能名>

### 页面结构
- routes：/checkout → CheckoutPage → CartWidget + PaymentSheet
- Provider 树：CartProvider → OrderProvider → PaymentProvider

### 离线策略（**重点** POS 必填）
- 断网检测：connectivity_plus
- 本地队列：sqflite 暂存未同步订单
- 同步时机：网络恢复 + 每 30s 轮询
- 冲突处理：服务端时间戳为准，客户端覆盖提示

### 硬件交互
- 扫码枪：RawKeyboardListener / Platform Channel
- 打印机：esc_pos_utils + bluetooth_print
- 钱箱：Platform Channel 调原生
```

##### 微信小程序方案模板

```markdown
## 技术方案：<功能名>

### 分包规划（**重点** 必填）
- 主包：首页、通用组件、工具函数（< 2MB）
- 分包A：用户模块
- 分包B：订单模块
- 每个分包 < 2MB，总包 < 20MB

### 页面注册
- app.json 注册所有页面路径
- tabBar 页面不能超过 5 个

### 微信能力集成
- 登录：wx.login → 服务端 code2Session → openId
- 支付：wx.requestPayment（需商户号）
- 订阅消息：wx.requestSubscribeMessage（需模板 ID）
```

#### 步骤 2.2 — 架构审查

**命令**：`/plan-eng-review`

| 项目类型 | **重点** 审查项 |
|----------|----------------|
| **java-springboot** | 数据库表设计是否合理（索引、分表）、API 版本化策略、事务边界是否正确 |
| **react-umi / vite-react** | 路由设计是否清晰、状态管理是否过度、SEO 是否考虑 |
| **nextjs** | Server/Client 边界是否合理、会不会过度客户端渲染、缓存策略是否正确 |
| **monorepo** | 子项目间耦合度、共享代码的维护策略、CI 流水线是否并行 |
| **flutter-pos** | 离线策略是否完整、状态管理是否过度嵌套、内存管理（图片缓存） |
| **miniprogram** | 分包是否合理、审核风险点、微信 API 调用频率限制 |

#### 步骤 2.3 — UX 审查（涉及前端/移动端/小程序时）

**命令**：`/plan-design-review`

**仅适用于以下项目类型**：react-umi、vite-react、nextjs、flutter-pos、miniprogram

#### 步骤 2.4 — 架构决策记录

**命令**：触发 `ecc:architecture-decision-records`

**🔑 各项目类型最常见的 ADR 主题：**

| 项目类型 | 典型 ADR 主题 |
|----------|-------------|
| **java-springboot** | EasyExcel vs Apache POI、@Async vs Kafka、MySQL 分表策略、Redis 缓存策略 |
| **react-umi** | ProComponents vs 自研、useRequest vs TanStack Query、Less vs CSS-in-JS |
| **vite-react** | Zustand vs Redux Toolkit、CSS Modules vs Tailwind、axios vs fetch |
| **nextjs** | SSR vs SSG vs ISR、Server Action vs API Route、Prisma vs Drizzle |
| **monorepo** | pnpm workspace vs Turborepo、shared/ 包 vs 各自维护 |
| **flutter-pos** | Provider vs Riverpod/BLoC、sqflite vs Drift、Platform Channel vs Pigeon |
| **miniprogram** | 原生 vs uni-app/Taro、TDesign vs WeUI、云开发 vs 自建后端 |

#### 入口标准
- [ ] 阶段一出口标准全部满足

#### 出口标准
- [ ] 技术方案文档已按项目类型模板编写
- [ ] 架构审查通过
- [ ] ADR 已记录（如有重大技术选型）
- [ ] 用户已确认方案

---

### 阶段三：开发计划制定

#### 目标
将技术方案分解为可执行的任务列表，启动持久化规划。

#### 步骤 3.1 — 启动持久化规划

**命令**：`/planning-with-files:plan`

**通用要求**：任务粒度 2-4 小时，标注依赖关系和验收标准

**🔑 不同项目类型的任务拆解建议：**

| 项目类型 | 典型任务顺序 | **重点** 注意事项 |
|----------|-------------|-------------------|
| **java-springboot** | 1.DB迁移 → 2.Entity/Repository → 3.Service → 4.Controller → 5.异步/消息 → 6.集成测试 | **重点** DB 迁移放第一个（后续任务依赖表结构）；事务边界在 Service 层定义 |
| **react-umi** | 1.路由配置 → 2.API Service → 3.页面组件 → 4.权限接入 → 5.E2E | **重点** 路由和权限必须在页面开发前确认；ProTable 的 request 函数可独立测试 |
| **vite-react** | 1.路由配置 → 2.API Client 封装 → 3.Store 定义 → 4.页面组件 → 5.路由守卫 → 6.E2E | **重点** API Client 封装放前面，统一拦截器、错误处理 |
| **nextjs** | 1.数据库 Schema → 2.API Route/Server Action → 3.页面 Layout → 4.页面组件 → 5.Middleware → 6.E2E | **重点** 先定数据层再写 UI；Server/Client 边界在每个组件开发时确认 |
| **monorepo** | 1.后端：DB → API → 测试 → 2.前端：API Client → 页面 → E2E | **重点** 严格先后端再前端（或并行但 API Mock 先行）；跨项目任务独立 commit |
| **flutter-pos** | 1.Model(Freezed) → 2.Repository → 3.Provider → 4.Page/Widget → 5.离线同步 → 6.硬件集成 → 7.集成测试 | **重点** build_runner 在 Model 变更后必须重新运行 |
| **miniprogram** | 1.app.json 注册 → 2.API 封装 → 3.页面四件套 → 4.TDesign 集成 → 5.分包配置 → 6.真机测试 | **重点** 新页面必须先在 app.json 注册；npm 包需在开发者工具中构建 |
| **session-logging** | 1.Hook 规则设计 → 2.路由脚本 → 3.CLAUDE.md 指令 → 4.端到端测试 | **重点** Hook 规则和路由脚本是最容易出错的部分 |
| **docs-config** | 1.模板结构 → 2.CLAUDE.md → 3.settings.local.json → 4..mcp.json → 5.验证 | **重点** 模板完备度按需选择 |

#### 步骤 3.2 — 确认计划

**检查项**（按项目类型差异化）：

| 检查项 | java-springboot | 前端类 | 移动端/小程序 | 配置类 |
|--------|:---:|:---:|:---:|:---:|
| 任务粒度 ≤ 4h | ✅ | ✅ | ✅ | ✅ |
| 无循环依赖 | ✅ | ✅ | ✅ | ✅ |
| 验收标准可测试 | ✅ | ✅ | ✅ | ✅ |
| DB 迁移任务在最先 | ✅ | - | - | - |
| 路由/权限任务在页面开发前 | - | ✅ | ✅ | - |
| 跨项目任务已标注依赖 | ✅(monorepo) | ✅(monorepo) | - | - |
| 离线场景任务已覆盖 | - | - | ✅(flutter/miniprogram) | - |
| Hook 脚本有验证步骤 | - | - | - | ✅(session-logging) |

#### 入口标准
- [ ] 阶段二出口标准全部满足

#### 出口标准
- [ ] `task_plan.md` 已按项目类型模板创建
- [ ] 每个任务有明确验收标准
- [ ] 依赖关系已标注
- [ ] `findings.md` 已记录约束和风险
- [ ] `progress.md` 初始化完成
- [ ] 重大技术决策已写入 Memory（claude-mem 自动记录）

> **重点** planning-with-files 的三文件（task_plan.md / findings.md / progress.md）在 `/compact` 压缩时可能丢失上下文。关键信息应同步写入 Memory 系统确保跨会话持久化。下次会话启动时，claude-mem 会自动注入相关记忆到上下文中。

---

### 阶段四：TDD 实现

#### 目标
按计划逐步实现，每个任务走完整 TDD 循环。**不同技术栈的测试工具和 TDD 节奏不同。**

#### 步骤 4.1 — 启动 TDD 模式

**命令**：`/test-driven-development`

**辅助工具**：Context7 MCP — 写测试和实现时查最新的 API 签名，避免凭"记忆"写错方法名或参数顺序。

**🔑 各技术栈 TDD 工具链：**

| 项目类型 | 测试框架 | Mock 工具 | **重点** 测试数据库策略 |
|----------|---------|----------|----------------------|
| **java-springboot** | JUnit 5 + Mockito | `@MockBean` / `@InjectMocks` | **重点** Mapper 测试连真实 DB（`@MybatisPlusTest`），不要 mock 数据库 |
| **react-umi** | Vitest + React Testing Library | MSW（Mock Service Worker） | **重点** 不要 mock fetch，用 MSW 模拟 API |
| **vite-react** | Vitest + React Testing Library | MSW | 同上 |
| **nextjs** | Vitest + React Testing Library | MSW + `next/headers` mock | **重点** Server Component 测试用 `NODE_ENV=test` 连测试 DB |
| **monorepo** | 各子项目用各自框架 | 同上 | **重点** 跨项目接口变更先更新后端测试，再更新前端 Mock |
| **flutter-pos** | `flutter test` + `mocktail` | `when().thenReturn()` | **重点** Provider 做单元测试，Widget 做 WidgetTest |
| **miniprogram** | 微信开发者工具自带 | 无成熟方案 | **重点** 核心逻辑抽到 utils 做纯函数测试，UI 靠真机测试 |
| **session-logging** | Shell `set -e` + 断言 | - | **重点** Hook 脚本用 `bash -n` 验证语法，用 echo 模拟事件 |
| **docs-config** | 模板完整性手动验证 | - | **重点** 新模板在目标项目类型中实际使用验证 |

#### TDD 详细流程（按技术栈）

##### Java Spring Boot TDD 示例

**RED 阶段**：
```java
@DataJpaTest
class ExportTaskRepositoryTest {
    @Autowired private ExportTaskRepository repository;

    @Test
    void shouldFindPendingTasks() {
        repository.save(createTask(ExportStatus.PENDING));
        repository.save(createTask(ExportStatus.COMPLETED));
        var pending = repository.findByStatus(ExportStatus.PENDING);
        assertThat(pending).hasSize(1);
    }
}
```

**GREEN 阶段**：
```java
@Entity @Table(name = "export_tasks")
class ExportTask {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Enumerated(EnumType.STRING) @Column(nullable = false)
    private ExportStatus status = ExportStatus.PENDING;
}
```

**REFACTOR 阶段**：添加 `@Builder`、提取常量、添加索引注解。

##### React 前端 TDD 示例

```typescript
// RED
describe('UserList', () => {
  it('shows loading state initially', () => {
    server.use(http.get('/api/users', () => HttpResponse.json([])));
    render(<UserList />);
    expect(screen.getByText('加载中...')).toBeInTheDocument();
  });

  it('renders user list after loading', async () => {
    const users = [{ id: 1, name: 'Alice' }];
    server.use(http.get('/api/users', () => HttpResponse.json(users)));
    render(<UserList />);
    expect(await screen.findByText('Alice')).toBeInTheDocument();
  });
});

// GREEN
function UserList() {
  const { data, isLoading } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
  if (isLoading) return <Spin />;
  return <Table dataSource={data} />;
}
```

##### Flutter Provider TDD 示例

```dart
// RED
void main() {
  test('CartProvider adds item correctly', () {
    final cart = CartProvider();
    final product = Product(id: '1', name: '可乐', price: 3.0);

    cart.addItem(product, qty: 2);

    expect(cart.items.length, 1);
    expect(cart.items.first.quantity, 2);
    expect(cart.total, 6.0);
  });

  test('CartProvider removes item', () {
    final cart = CartProvider();
    cart.addItem(Product(id: '1', name: '可乐', price: 3.0));
    cart.removeItem('1');
    expect(cart.items.length, 0);
  });
}
```

#### 步骤 4.2 — 按计划逐步执行

**命令**：`/executing-plans`

每完成一个任务后：
1. 运行 `code-simplifier` 质量检查
2. 更新 `progress.md`
3. 运行全部测试确保无回归

#### 步骤 4.3 — 自主循环（大型多步骤任务）

**命令**：`/ralph-loop`

**🔑 各项目类型的自主循环建议参数：**

| 项目类型 | max-iterations | 典型 completion-promise |
|----------|:---:|-----------|
| **java-springboot** | 10-20 | `mvn test 全部通过 且 task_plan.md 所有任务 [x]` |
| **react-umi / vite-react** | 10-15 | `pnpm test 全部通过 且 pnpm tsc --noEmit 无错误` |
| **nextjs** | 10-20 | `pnpm test && pnpm tsc --noEmit && pnpm build 全部通过` |
| **monorepo** | 20-50 | `所有子项目测试通过 且 task_plan.md 所有任务 [x]` |
| **flutter-pos** | 10-20 | `flutter test && flutter analyze 全部通过` |
| **miniprogram** | 5-10 | `pnpm tsc --noEmit 无错误 且 task_plan.md 所有任务 [x]` |

#### 步骤 4.4 — 构建修复

| 项目类型 | 命令 | **重点** 常见错误 |
|----------|------|-----------------|
| **java-springboot** | `/java-core:java-fix` | cannot find symbol（漏了 Mapper 注解）、循环依赖 |
| **react-umi / vite-react** | `pnpm tsc --noEmit` 看错误 | 类型不匹配、import 路径错误 |
| **nextjs** | `pnpm tsc --noEmit` + `pnpm build` | Server Component 中用客户端 API |
| **flutter-pos** | `flutter analyze` | Freezed 生成文件过期（需重新 build_runner） |
| **miniprogram** | `pnpm tsc --noEmit` | 类型定义缺失 |

#### 入口标准
- [ ] 阶段三出口标准全部满足

#### 出口标准
- [ ] 所有任务按 task_plan.md 顺序完成
- [ ] 所有测试通过（按各技术栈命令）
- [ ] 测试覆盖率 ≥ 80%（业务逻辑 ≥ 90%）
- [ ] `code-simplifier` 质量检查通过
- [ ] `progress.md` 已更新
- [ ] 无编译错误或警告

---

### 阶段五：代码审查

#### 目标
多维度审查代码质量，确保安全、可维护、可扩展。

#### 步骤 5.1 — 提交代码审查

**命令**：`/requesting-code-review`

#### 步骤 5.2 — 多维度审查矩阵

**命令**：`ecc:code-review`

**🔑 按项目类型的审查重点矩阵：**

| 审查维度 | java-springboot | react-umi/vite-react | nextjs | flutter-pos | miniprogram |
|----------|----------------|---------------------|--------|-------------|-------------|
| **安全** | 🔴 SQL 注入、SSRF、路径遍历 | 🟡 XSS、CSRF、Token 泄漏 | 🔴 Server Action 注入、API 鉴权 | 🟡 本地存储敏感数据 | 🔴 openId 泄露、XSS |
| **正确性** | 🔴 事务边界、并发安全、空值 | 🟡 竞态条件、状态不一致 | 🔴 Server/Client 边界错误 | 🔴 离线同步冲突 | 🟡 setData 数据一致性 |
| **性能** | 🔴 N+1 查询、全表扫描 | 🟡 不必要的 re-render、Bundle 大小 | 🔴 缓存策略、Server Component 滥用 | 🔴 列表 build 次数、图片内存 | 🔴 setData 频率、包体积 |
| **可维护性** | 🟡 方法长度、循环依赖 | 🔴 组件大小、props 传递深度 | 🔴 Server/Client 职责混乱 | 🟡 Provider 嵌套深度 | 🔴 WXML 复杂逻辑 |
| **可测试性** | 🟡 依赖注入、纯函数 | 🟡 组件可测试性 | 🟡 Server Action 可测试性 | 🟡 Provider 可单元测试 | 🟡 逻辑是否抽到 utils |
| **风格一致** | 🟢 Lombok 使用、命名 | 🟢 import 顺序、hooks 命名 | 🟢 'use client' 位置、文件约定 | 🟢 Freezed 使用、命名 | 🟢 四件套命名一致性 |

#### 步骤 5.3 — 技术栈专项审查

| 项目类型 | 审查命令 | **重点** 审查项 |
|----------|---------|----------------|
| **java-springboot** | `java-core:java-review` | 并发安全（synchronized/volatile）、资源管理（try-with-resources）、Optional 使用、`@Transactional` 边界 |
| **java-springboot** | `/java-spring:java-jpa` | N+1 查询、JOIN FETCH、分页正确性、`@Query` 性能 |
| **java-springboot** | `/java-spring:java-security` | 接口鉴权、CSRF、CORS、JWT 配置 |
| **react-umi** | `ecc:typescript-reviewer` | `any` 使用、类型守卫、optional chaining |
| **vite-react** | `ecc:typescript-reviewer` | 同上 + Vite 配置 |
| **nextjs** | `ecc:typescript-reviewer` | Server/Client Component 正确性、`revalidatePath` 位置 |
| **flutter-pos** | `ecc:flutter-review` | Widget 重构、Provider dispose、内存泄漏 |
| **miniprogram** | 无专项 Agent | 人工审查 setData 合理性、WXML 复杂度 |

#### 步骤 5.4 — 静默失败检测

**命令**：`ecc:silent-failure-hunter`

**🔑 各项目类型的静默失败重灾区：**

| 项目类型 | **重点** 检测点 |
|----------|---------------|
| **java-springboot** | `catch(Exception e) { log.error(e); }` 后未重新抛出；`return null` 代替抛异常；`@Async` 方法异常被吞 |
| **react-umi / vite-react** | `useEffect` 中 fetch 不处理 error；`try/catch` 后 setState 空数组；Promise catch 只 console.log |
| **nextjs** | Server Action 返回 `{ error: "..." }` 但调用方未检查；`revalidatePath` 在 try 外导致失败不报错 |
| **flutter-pos** | Dio 错误拦截器吞异常；Provider 方法异常不通知 UI；离线同步静默跳过失败记录 |
| **miniprogram** | `wx.request` fail 回调只 console.log；`setData` 失败不处理；Storage 满静默丢弃 |

#### 步骤 5.5 — 处理审查反馈

**命令**：`/receiving-code-review`

#### 入口标准
- [ ] 阶段四出口标准全部满足

#### 出口标准
- [ ] 安全相关无严重/高危问题
- [ ] 无静默失败风险
- [ ] 注释准确
- [ ] 所有审查评论已 resolved
- [ ] Approve

---

### 阶段六：测试验证

#### 目标
全面验证功能正确性，覆盖所有测试层级。

#### 步骤 6.1 — 完成前验证

**命令**：`/verification-before-completion`

#### 步骤 6.2 — 覆盖率分析

**命令**：`ecc:test-coverage`

**🔑 各项目类型覆盖率标准：**

| 项目类型 | 覆盖率工具 | 整体最低 | 业务逻辑最低 | **重点** 豁免项 |
|----------|-----------|:---:|:---:|-----------|
| **java-springboot** | JaCoCo | 80% | 90% (Service) | Entity/Config/常量类 |
| **react-umi** | Vitest coverage | 80% | 90% (services/utils) | 纯展示组件、类型定义 |
| **vite-react** | Vitest coverage | 80% | 90% (hooks/services) | 同上 |
| **nextjs** | Vitest coverage | 80% | 90% (lib/services) | Server Component 渲染（难以单元测试） |
| **flutter-pos** | `flutter test --coverage` | 75% | 85% (Provider/Service) | Widget build 方法（WidgetTest 覆盖） |
| **miniprogram** | 无成熟工具 | - | utils 纯函数 100% | 页面逻辑难以自动化测试 |

#### 步骤 6.3 — 测试层级要求

| 项目类型 | 单元测试 | 集成测试 | E2E 测试 | **重点** 说明 |
|----------|:---:|:---:|:---:|-----------|
| **java-springboot** | ✅ JUnit 5 + Mockito | ✅ `@SpringBootTest` + 真实 DB | ✅ Playwright | **重点** Mapper 测试连真实 DB，不要 mock |
| **react-umi** | ✅ Vitest + RTL | ✅ MSW 模拟 API | ✅ Playwright | **重点** 用 MSW 不要 mock fetch |
| **vite-react** | ✅ Vitest + RTL | ✅ MSW 模拟 API | ✅ Playwright | 同上 |
| **nextjs** | ✅ Vitest + RTL | ✅ 测试 DB + MSW | ✅ Playwright | **重点** Server Action 用测试 DB |
| **monorepo** | ✅ 各子项目 | ✅ 跨项目 API 契约测试 | ✅ 全链路 E2E | **重点** 跨项目接口变更的回归 |
| **flutter-pos** | ✅ Provider/Service | ✅ WidgetTest | ✅ 真机测试 | **重点** 硬件相关需要真机验证 |
| **miniprogram** | ✅ utils 纯函数 | ❌ 难以自动化 | ✅ 真机测试 | **重点** 微信 API 只能在真机验证 |
| **session-logging** | - | - | ✅ 手动端到端 | **重点** Hook 触发验证 |
| **docs-config** | - | - | ✅ 模板使用验证 | **重点** 在目标项目中实际测试模板 |

#### 步骤 6.4 — Java 测试工程

**命令**：`/java-quality:java-test`

#### 步骤 6.5 — E2E 测试

**命令**：`ecc:e2e-runner`

**🔑 E2E 测试平台选择：**

| 项目类型 | E2E 工具 | **重点** 必须覆盖的路径 |
|----------|---------|---------------------|
| **java-springboot** | Playwright (通过前端) 或 REST Assured (纯 API) | 核心 API CRUD + 权限拒绝 + 异常场景 |
| **react-umi / vite-react** | Playwright | 登录 → 核心页面 → 表单提交 → 列表搜索 → 权限控制 |
| **nextjs** | Playwright | SSR 渲染正确 → 客户端交互 → API Route → 错误页面 |
| **flutter-pos** | `integration_test` + 真机 | 扫码 → 加购物车 → 结账 → 离线模式 → 同步 |
| **miniprogram** | 微信开发者工具 + 真机 | 登录 → 核心页面 → 支付流程 → 分包加载 |
| **monorepo** | Playwright 全链路 | 后端 API → 前端页面 → 数据一致性 |

#### 入口标准
- [ ] 阶段五出口标准全部满足

#### 出口标准
- [ ] 各层级测试覆盖率达标（按项目类型标准）
- [ ] 集成测试覆盖所有 API 端点（后端）/ 核心页面（前端）
- [ ] E2E 覆盖核心路径
- [ ] 所有测试绿色
- [ ] `verification-before-completion` 通过

---

### 阶段七：安全审查

#### 目标
确保代码符合安全标准，消除已知漏洞。

#### 步骤 7.1 — 安全扫描

**命令**：`ecc:security-scan` 或 `/security-review`

#### 步骤 7.2 — STRIDE 审计

**命令**：`/cso`

**🔑 各项目类型 STRIDE 威胁面：**

| 威胁 | java-springboot | 前端类 | nextjs | flutter-pos | miniprogram |
|------|----------------|--------|--------|-------------|-------------|
| **S**poofing | JWT 伪造、Session 劫持 | Token 窃取 | Session 劫持、OAuth 回调劫持 | Token 本地存储安全 | openId 伪造 |
| **T**ampering | API 参数篡改、数据库注入 | XSS、表单篡改 | Server Action 参数篡改 | 本地数据篡改 | 请求重放 |
| **R**epudiation | 缺少审计日志 | - | 缺少操作日志 | 离线操作无服务端记录 | - |
| **I**nformation | 接口过度暴露、SQL 注入报错 | 前端泄漏 API 结构 | Server Component 泄漏 DB 查询 | 本地数据库可被提取 | openId/unionId 泄漏 |
| **D**enial | 接口无频率限制、慢查询 | - | SSR 被滥用 | - | - |
| **E**levation | RBAC 绕过、接口未鉴权 | 前端路由守卫可绕过 | Middleware 绕过 | - | - |

#### 步骤 7.3 — 技术栈专项安全

| 项目类型 | 审查命令 | **重点** 检查项 |
|----------|---------|----------------|
| **java-springboot** | `/java-quality:java-security-check` | SQL 注入（MyBatis `${}`）、路径遍历（文件下载）、SSRF、JWT 密钥强度、敏感信息日志打印 |
| **nextjs** | `ecc:security-review` | Server Action 注入、API Route 鉴权、`NEXT_PUBLIC_*` 变量泄漏、CSP 头配置 |
| **react-umi / vite-react** | `ecc:security-review` | XSS（dangerouslySetInnerHTML）、Token 存储（localStorage vs httpOnly cookie）、CORS 配置 |
| **flutter-pos** | 无专项 Agent | SharedPreferences 存储敏感信息、Dio 拦截器日志泄漏 Token |
| **miniprogram** | 无专项 Agent | **重点** openId/unionId 只在服务端处理、wx.setStorageSync 不存敏感信息、WXML 防 XSS |

#### 步骤 7.4 — 依赖安全扫描

> **新增环节**：第三方依赖 CVE 检查

| 项目类型 | 扫描工具 | **重点** 说明 |
|----------|---------|-------------|
| **java-springboot** | `mvn dependency-check:check` 或 Snyk | **重点** Spring 生态 CVE 频率高，必须定期扫描 |
| **前端类** | `pnpm audit` 或 Snyk | **重点** 关注构建工具链漏洞 |
| **flutter-pos** | `dart pub outdated` | **重点** 关注平台通道相关包 |
| **miniprogram** | `pnpm audit` | **重点** npm 包在构建后内联到小程序 |

#### 入口标准
- [ ] 阶段六出口标准全部满足

#### 出口标准
- [ ] 0 高危 / 0 严重安全漏洞
- [ ] STRIDE 审查无未处理风险
- [ ] 密钥/令牌不存于代码或配置文件
- [ ] 第三方依赖无已知严重 CVE
- [ ] PII/PHI 处理合规（如适用）

---

### 阶段八：性能审查

#### 目标
识别并修复性能瓶颈。**不同技术栈的性能瓶颈完全不同。**

#### 步骤 8.1 — 综合性能分析

**命令**：`ecc:performance-optimizer`

#### 步骤 8.2 — 技术栈专项性能

**🔑 各项目类型性能检查清单：**

##### java-springboot 性能检查

| 检查项 | 工具 | 正常范围 | **重点** 说明 |
|--------|------|----------|-------------|
| N+1 查询 | `db-analyzer: explain_query` | 0 个 | **重点** `@OneToMany` 默认懒加载是 N+1 重灾区 |
| 全表扫描 | `db-analyzer: analyze_indexes` | 0 个 | **重点** 每个 WHERE/ORDER BY/JOIN 列都要有索引 |
| GC 暂停 | `jvm-diagnostics: analyze_gc_log` | < 200ms | **重点** Young GC 频繁是正常，Full GC 频繁是问题 |
| 堆使用率 | `jvm-diagnostics: analyze_heap_histo` | 50-70% | **重点** 关注 byte[] 占比（大对象泄漏信号） |
| 连接池 | `db-analyzer: analyze_connections` | 30-50% | **重点** 连接池耗尽 = 请求排队 = P99 飙升 |
| 缓存命中率 | `redis-diagnostics: analyze_keyspace` | > 80% | **重点** 命中率低说明缓存策略有问题 |
| 线程阻塞 | `jvm-diagnostics: analyze_thread_dump` | 0 死锁 | **重点** 关注 BLOCKED 状态的线程 |
| API 响应 | `spring-boot-actuator: analyze_metrics` | P95 < 500ms | **重点** 区分正常慢（大数据量导出）和异常慢（缺失索引） |

##### React 前端性能检查（react-umi / vite-react）

| 检查项 | 工具 | 正常范围 | **重点** 说明 |
|--------|------|----------|-------------|
| 首屏加载 | Lighthouse | FCP < 1.8s, LCP < 2.5s | **重点** 代码分割 + 路由懒加载 |
| Bundle 大小 | `pnpm build` 分析产物 | 单 chunk < 200KB | **重点** Antd/ProComponents 按需引入，不要全量 |
| Re-render | React DevTools Profiler | 不必要的 re-render = 0 | **重点** `useMemo`/`useCallback` 只在高频更新处使用 |
| 图片优化 | Lighthouse | 图片大小 < 200KB | **重点** WebP 格式、懒加载、CDN |
| API 请求数 | Network 面板 | 首页 < 10 个 | **重点** 合并请求、GraphQL 或 BFF 聚合 |

##### Next.js 性能检查

| 检查项 | 工具 | 正常范围 | **重点** 说明 |
|--------|------|----------|-------------|
| SSR 耗时 | `next build` 输出 | < 200ms | **重点** Server Component 中 DB 查询耗时是关键 |
| 客户端 JS | `next build` 输出 | 首屏 JS < 150KB | **重点** `'use client'` 边界下移减少客户端代码 |
| 图片优化 | `next/image` Lighthouse | LCP 图片用 priority | **重点** 忘记 `priority`/`sizes` 属性是常见问题 |
| 缓存命中 | `next/cache` 行为 | Data Cache 命中率 > 80% | **重点** `revalidatePath`/`revalidateTag` 粒度控制 |

##### Flutter POS 性能检查

| 检查项 | 工具 | 正常范围 | **重点** 说明 |
|--------|------|----------|-------------|
| UI 帧率 | Flutter DevTools | > 58fps | **重点** build 方法中避免做重计算 |
| 内存 | DevTools Memory | < 200MB | **重点** 图片缓存是内存大户 |
| 列表性能 | DevTools | 滑动不卡顿 | **重点** 长列表用 `ListView.builder`，不用 `ListView(children: [])` |
| 离线同步 | 自定义埋点 | 同步成功率 > 99% | **重点** 同步失败重试 + 冲突解决 |

##### 微信小程序性能检查

| 检查项 | 工具 | 正常范围 | **重点** 说明 |
|--------|------|----------|-------------|
| 包体积 | 微信开发者工具 | 单分包 < 2MB，总包 < 20MB | **重点** 图片进 CDN 不进包，npm 按需引入 |
| setData 频率 | 性能面板 | < 20次/秒 | **重点** 只传变更字段、合并连续调用 |
| 首屏加载 | 真机测试 | < 2s | **重点** 首页放主包，非关键页放分包 |
| 内存 | 性能面板 | < 50MB | **重点** 页面 onUnload 清理定时器和监听 |

#### 步骤 8.3 — 数据库诊断（java-springboot / nextjs 全栈）

**MCP 触发**：对话中描述需求即可

- `db-analyzer: analyze_indexes` — 索引使用分析
- `db-analyzer: explain_query` — 慢查询执行计划
- `db-analyzer: analyze_table_bloat` — 表膨胀检查
- `db-analyzer: analyze_connections` — 连接池分析

#### 步骤 8.4 — JVM 诊断（java-springboot 专属）

- `jvm-diagnostics: analyze_gc_log` — GC 日志分析
- `jvm-diagnostics: analyze_heap_histo` — 堆对象分布
- `jvm-diagnostics: analyze_thread_dump` — 线程状态分析
- `jvm-diagnostics: diagnose_jvm` — 综合诊断

#### 步骤 8.5 — Redis 诊断（使用缓存的项目）

- `redis-diagnostics: analyze_memory` — 内存使用
- `redis-diagnostics: analyze_slowlog` — 慢查询
- `redis-diagnostics: analyze_clients` — 客户端连接

#### 入口标准
- [ ] 阶段七出口标准全部满足

#### 出口标准

**通用：**
- [ ] 0 个 N+1 查询或全表扫描
- [ ] 无内存泄漏信号
- [ ] 缓存命中率 > 80%（如使用）

**按项目类型：**

| 项目类型 | 额外出口标准 |
|----------|-------------|
| **java-springboot** | API P95 < 500ms、GC 暂停 < 200ms、数据库有合适索引 |
| **react-umi / vite-react** | FCP < 1.8s、LCP < 2.5s、单 chunk < 200KB |
| **nextjs** | SSR < 200ms、首屏 JS < 150KB |
| **flutter-pos** | UI > 58fps、内存 < 200MB |
| **miniprogram** | 包体积合规、setData < 20次/秒、首屏 < 2s |

---

### 阶段九：CI/CD 与持续交付

> **新增环节**：覆盖从本地开发到生产部署的自动化流水线。

#### 目标
建立自动化构建、测试、部署流水线，确保每次变更可追踪、可回滚。

#### 步骤 9.1 — CI 流水线设计

**🔑 各项目类型 CI 流水线模板：**

##### java-springboot CI（GitHub Actions 示例）

```yaml
name: Java CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: test
          MYSQL_DATABASE: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { java-version: '21', distribution: 'temurin' }
      - run: mvn test                    # **重点** 单元+集成测试
      - run: mvn pmd:check checkstyle:check  # 代码风格
      - run: mvn dependency-check:check  # CVE 扫描
```

##### 前端 CI（react-umi / vite-react / nextjs 通用）

```yaml
name: Frontend CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with: { version: 9 }
      - run: pnpm install --frozen-lockfile
      - run: pnpm tsc --noEmit           # **重点** 类型检查
      - run: pnpm lint                    # ESLint
      - run: pnpm test                    # 单元测试
      - run: pnpm build                   # **重点** 构建验证（nextjs 尤其重要）
```

##### Flutter CI

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x' }
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter analyze            # **重点** 静态分析
      - run: flutter test               # 单元测试
```

##### 微信小程序 CI

```yaml
# **重点** 小程序无法在 CI 中完整构建（依赖微信开发者工具）
# CI 可做的：类型检查 + 代码规范 + 单元测试
name: MiniProgram CI
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install
      - run: pnpm tsc --noEmit
      - run: pnpm lint
      - run: pnpm test
      # **重点** 真机测试需要手动触发或通过微信 CI 工具(miniprogram-ci)
```

##### Monorepo CI

```yaml
name: Monorepo CI
on: [push, pull_request]
jobs:
  # **重点** 检测变更的子项目，只跑受影响的部分
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.filter.outputs.backend }}
      admin-web: ${{ steps.filter.outputs.admin-web }}
    steps:
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            backend: ['backend/**']
            admin-web: ['admin-web/**']

  backend-test:
    needs: detect-changes
    if: needs.detect-changes.outputs.backend == 'true'
    # ... Java CI steps

  admin-web-test:
    needs: detect-changes
    if: needs.detect-changes.outputs.admin-web == 'true'
    # ... Frontend CI steps
```

#### 步骤 9.2 — CD 部署策略

| 项目类型 | 部署方式 | 环境管理 | **重点** 注意事项 |
|----------|---------|---------|-----------------|
| **java-springboot** | Docker + K8s / Docker Compose | dev → staging → prod | **重点** 数据库迁移在部署前执行，有回滚方案 |
| **react-umi / vite-react** | Nginx 静态 + CDN / OSS | 同上 | **重点** SPA 路由需 nginx `try_files $uri /index.html` |
| **nextjs** | Vercel（推荐）/ Docker + Node.js | Preview Deploy → Production | **重点** Vercel 自动为每个 PR 生成预览环境 |
| **monorepo** | 各子项目独立部署 | 各子项目独立环境 | **重点** 部署顺序：基础设施 → 后端 → 前端 |
| **flutter-pos** | App Store / Google Play / 企业分发 | TestFlight → 灰度 → 全量 | **重点** App Store 审核 1-3 天，Google Play 几小时 |
| **miniprogram** | 微信后台提交审核 | 开发版 → 体验版 → 审核 → 发布 | **重点** 审核 1-7 天，可配置灰度比例 |
| **session-logging** | `cp` 到目标项目 | 无 | **重点** 模板变更需手动同步到使用方 |
| **docs-config** | 无部署 | 无 | **重点** 变更通过 git push 分发 |

#### 步骤 9.3 — Feature Flag 策略（推荐）

> **重点** Feature Flag 实现灰度发布、紧急关闭、A/B 实验，不依赖部署回滚。

| 项目类型 | Feature Flag 方案 | **重点** 使用场景 |
|----------|------------------|-----------------|
| **java-springboot** | 自研（DB 配置表 + 缓存）/ LaunchDarkly / 配置中心 | **重点** 新功能灰度、接口限流动态调整 |
| **nextjs** | Vercel Edge Config / LaunchDarkly | **重点** 配合 ISR 做页面级灰度 |
| **react-umi / vite-react** | 自研（请求头 + Cookie）/ LaunchDarkly | **重点** 前端功能开关，不依赖后端发布 |
| **miniprogram** | 微信自带的灰度发布 | **重点** 审核通过后按百分比灰度 |

#### 步骤 9.4 — API 版本化策略

> **重点** API 版本化应该在阶段二方案设计中确定，在阶段九 CI/CD 中落实到流水线检查。

| 版本化方式 | 适用场景 | 示例 | 废弃策略 |
|-----------|---------|------|---------|
| URL Path | REST API（最常用） | `/api/v1/users`、`/api/v2/users` | 老版本保留 6 个月，标记 `@Deprecated` |
| Header | 网关层路由 | `Accept: application/vnd.api.v2+json` | 网关层控制 |
| Query Param | 临时版本切换 | `/api/users?version=2` | 不建议长期使用 |

**🔑 版本化原则：**
- 新增字段：向后兼容，不需要新版本
- 删除/重命名字段：需要新版本
- 修改字段类型/含义：需要新版本
- 响应结构变更：需要新版本

#### 入口标准
- [ ] 阶段八出口标准全部满足

#### 出口标准
- [ ] CI 流水线已配置（至少覆盖：类型检查 + 测试 + 构建验证）
- [ ] CD 策略已确定（按项目类型选择部署方式）
- [ ] Feature Flag 方案已确定（推荐）
- [ ] API 版本化策略已确定（后端/全栈项目）
- [ ] 环境变量在各环境已配置
- [ ] 回滚方案已就绪

---

### 阶段十：上线准备

#### 目标
确保代码、文档、配置准备好发布。

#### 步骤 10.1 — 分支收尾

**命令**：`/finishing-a-development-branch`

#### 步骤 10.2 — 数据库迁移审查（java-springboot / nextjs 全栈）

**触发**：对话中描述需求

- `migration-advisor: analyze_migration` — 锁风险分析
- `migration-advisor: detect_conflicts` — 迁移冲突检测
- `migration-advisor: generate_rollback` — 生成回滚 SQL
- `migration-advisor: score_risk` — 风险评分

**🔑 数据库回滚方案（新增）：**

```sql
-- 前滚（V2__add_export_task.sql）
CREATE TABLE export_tasks (...);

-- 回滚（V2__add_export_task_rollback.sql）
-- **重点** 每个迁移必须有对应回滚脚本
DROP TABLE IF EXISTS export_tasks;
```

| 迁移类型 | 回滚方案 | **重点** 风险 |
|----------|---------|-------------|
| CREATE TABLE | DROP TABLE | 数据丢失（确认无依赖） |
| ADD COLUMN | DROP COLUMN | 数据丢失 |
| ADD COLUMN NOT NULL | DROP COLUMN | 数据丢失 |
| DROP COLUMN | 从备份恢复 | **重点** 高风险，先标记废弃，下个版本再删 |
| RENAME COLUMN | 反向 RENAME | 确认无代码引用旧列名 |
| ALTER TYPE | 反向 ALTER | **重点** 高风险，需兼容转换 |

#### 步骤 10.3 — 检查点

**命令**：`/checkpoint`

#### 步骤 10.4 — Release Notes

**命令**：`/document-release`

#### 步骤 10.5 — 上线前最终检查清单

**🔑 各项目类型上线前检查清单：**

##### java-springboot 上线前检查

```markdown
- [ ] 数据库迁移已审查（风险评分 < 50）
- [ ] 迁移回滚脚本已就绪
- [ ] JVM 参数已确认（-Xmx、GC 策略）
- [ ] 连接池配置已确认（HikariCP）
- [ ] Redis 缓存策略已确认（TTL 设置）
- [ ] Dubbo/Nacos 配置已确认
- [ ] 外部依赖健康检查（DB、Redis、Kafka、Nacos）
- [ ] CI 流水线绿色
- [ ] API 文档已更新（如有 Swagger）
```

##### 前端上线前检查（react-umi / vite-react）

```markdown
- [ ] `pnpm build` 成功，无警告
- [ ] 环境变量确认（`VITE_*` / `UMI_*` / `NEXT_PUBLIC_*`）
- [ ] Nginx 配置已确认（SPA try_files）
- [ ] CDN 配置已确认（如有）
- [ ] 浏览器兼容已验证
- [ ] 监控埋点已确认（如有）
```

##### nextjs 上线前检查

```markdown
- [ ] `pnpm build` 成功，无错误
- [ ] 构建日志中 SSR/SSG/ISR 页面数量正确
- [ ] 环境变量确认（`NEXT_PUBLIC_*` vs `process.env.*`）
- [ ] Middleware 逻辑已确认（不影响静态资源）
- [ ] 图片域名在 `next.config.ts` 的 `images.remotePatterns` 中
- [ ] Vercel/Docker 部署配置已确认
```

##### Flutter POS 上线前检查

```markdown
- [ ] `flutter build apk --release` / `flutter build ios --release` 成功
- [ ] 版本号已更新（pubspec.yaml version）
- [ ] build_runner 生成文件已更新
- [ ] 真机测试通过（Android + iOS）
- [ ] 硬件设备兼容性验证（打印机、扫码枪）
- [ ] 离线模式完整流程验证
- [ ] App Store / Google Play 元数据已准备
```

##### 微信小程序上线前检查

```markdown
- [ ] 包体积合规（主包 < 2MB，分包 < 2MB，总 < 20MB）
- [ ] 所有页面在 app.json 注册
- [ ] 体验版测试通过
- [ ] 涉及微信支付/订阅消息的模板已审核通过
- [ ] 服务器域名在后台已配置（request 合法域名）
- [ ] 隐私协议已更新（如涉及用户信息）
- [ ] 审核材料已准备（功能截图 + 说明）
```

#### 入口标准
- [ ] 阶段九出口标准全部满足

#### 出口标准
- [ ] 上线前检查清单全部通过
- [ ] 数据库迁移无高风险（或已确认可接受）
- [ ] 回滚方案已就绪
- [ ] Release Notes 已生成
- [ ] 检查点已创建

---

### 阶段十一：上线

#### 目标
安全地将变更部署到生产环境。

#### 步骤 11.1 — 一键发布

**命令**：`/ship`

#### 步骤 11.2 — 金丝雀发布

**命令**：`/canary`

**🔑 各项目类型的金丝雀策略：**

| 项目类型 | 金丝雀粒度 | 观察指标 | **重点** 回滚条件 |
|----------|-----------|---------|-----------------|
| **java-springboot** | 10% → 50% → 100% 实例 | 5xx 错误率、P95 响应时间、GC 暂停 | **重点** 5xx > 1% 立即回滚 |
| **react-umi / vite-react** | CDN 切换版本 | JS 错误率、页面加载时间 | **重点** JS 错误率 > 0.5% 回滚 CDN |
| **nextjs** | Vercel 逐步切换流量 | 同上 + SSR 失败率 | **重点** Vercel 支持一键回滚到上次部署 |
| **flutter-pos** | App Store 分阶段发布(1%→10%→50%→100%) | Crash rate、ANR 率 | **重点** Crash rate > 0.5% 暂停发布 |
| **miniprogram** | 微信后台灰度(5%→15%→30%→100%) | 页面错误率、接口失败率 | **重点** 审核通过后灰度，有问题的立即回退 |

#### 步骤 11.3 — 合并部署

**命令**：`/land-and-deploy`

#### 入口标准
- [ ] 阶段十出口标准全部满足

#### 出口标准
- [ ] 数据库迁移成功
- [ ] 金丝雀各阶段指标正常
- [ ] 烟雾测试通过
- [ ] 无新错误日志
- [ ] 用户可正常访问

---

### 阶段十二：上线后监控与事故响应

> **扩展环节**：新增事故分级、回滚决策、事后复盘。

#### 目标
确认上线稳定，持续监控，事故时快速响应。

#### 步骤 12.1 — 监控时间线

| 时间 | 动作 | java-springboot | 前端类 | nextjs | flutter-pos | miniprogram |
|------|------|:---:|:---:|:---:|:---:|:---:|
| 上线 + 5min | 实时健康检查 | Actuator /health | JS 错误率 | Vercel Analytics | Crashlytics | 小程序后台错误 |
| 上线 + 30min | 业务指标 | 导出成功率 | 页面 PV/UV | SSR 成功率 | 收银成功率 | 支付成功率 |
| 上线 + 2h | 性能基线对比 | JVM + DB 对比 | Lighthouse 对比 | 构建产物对比 | 帧率对比 | 首屏对比 |
| 上线 + 24h | 全面健康检查 | 全指标确认 | 用户反馈 | 用户反馈 | App Store 评分 | 用户反馈 |

#### 步骤 12.2 — SLO / Error Budget 体系

> **新增**：服务等级目标替代绝对阈值告警，基于错误预算消耗率做告警。

**🔑 各项目类型 SLO 设定建议：**

| 项目类型 | 核心 SLI | SLO 目标 | Error Budget | **重点** Burn Rate 告警 |
|----------|---------|---------|-------------|------------------------|
| **java-springboot** | API 成功率 | 99.9% (月) | 43 min/月 | 5% 消耗 → Warning，20% → Critical |
| **java-springboot** | API P95 | < 500ms | - | P95 > 1s 持续 5min → Alert |
| **react-umi / vite-react** | JS 错误率 | < 0.5% | - | > 1% 持续 5min → Alert |
| **nextjs** | 页面加载成功 | 99.9% | 43 min/月 | SSR 失败率 > 1% → Alert |
| **flutter-pos** | 收银成功率 | 99.99% | 4 min/月 | **重点** POS 对可用性要求极高 |
| **miniprogram** | 页面打开成功率 | 99.5% | 3.6 h/月 | > 2% 错误率 → 微信后台告警 |

#### 步骤 12.3 — 事故分级与响应

> **新增**：明确的事故分级、响应时间、处理流程。

| 级别 | 定义 | 示例 | 响应时间 | **重点** 处理动作 |
|:---:|------|------|:---:|-----------|
| **P0 紧急** | 核心功能完全不可用 | 支付接口全部 500、登录 100% 失败 | 5 min | **重点** 立即回滚，不要再排查根因 |
| **P1 严重** | 核心功能部分不可用/降级 | 导出功能 50% 失败、首页加载 > 10s | 30 min | **重点** 先在监控确认范围，再决定回滚还是热修复 |
| **P2 一般** | 非核心功能异常 | 某运营报表加载失败、头像上传偶发失败 | 4 h | 排入修复队列，下一个迭代处理 |
| **P3 轻微** | UI 显示问题、偶发小错误 | 按钮样式错位、非关键文案错误 | 下个迭代 | 低优先级修复 |

**🔑 回滚决策流程：**

```
发现异常 → 确认影响范围(P0/P1/P2) → P0? → 是 → 立即回滚(5min内)
                                    → 否 → P1? → 是 → 30min内决策：根因明确且修复 < 30min? → 热修复
                                                                                → 否 → 回滚
                                    → 否 → P2 → 排入修复队列
```

#### 步骤 12.4 — 事后复盘(Postmortem)

> **新增**：P0/P1 事故必须在恢复后 24h 内完成复盘。

**Postmortem 模板：**

```markdown
# Postmortem: <事故简述>

## 时间线（全部使用北京时间）
- 14:30  上线 v2.1.0
- 14:35  监控告警：支付接口 5xx 错误率 30%
- 14:38  确认影响范围：全部用户支付失败（P0）
- 14:40  执行回滚到 v2.0.9
- 14:42  服务恢复，支付成功率回到 99.9%
- 15:00  开始根因排查

## 影响
- 持续时间：7 分钟（14:35-14:42）
- 影响用户：约 200 笔支付失败
- 消耗 Error Budget：约 15%（7分钟 / 43分钟月预算）

## 根因
<5 Whys 分析>

## 修复
- [ ] 短期：（已完成）回滚到 v2.0.9
- [ ] 中期：（本次）修复代码 + 加测试 + 灰度再上线
- [ ] 长期：（下个迭代）加强支付接口的集成测试覆盖

## 经验教训
- 什么做得对：5 分钟内完成了回滚决策和执行
- 什么可以改进：支付接口的变更应该有更严格的测试要求
- 幸运因素：发生在低峰期，影响用户较少
```

#### 步骤 12.5 — 安全守护

**命令**：`/guard`

#### 告警阈值速查（按项目类型）

| 指标 | java-springboot | 前端类 | nextjs | flutter-pos | miniprogram |
|------|:---:|:---:|:---:|:---:|:---:|
| 错误率 | > 1% | > 1% JS Error | > 1% | > 0.5% Crash | > 2% |
| 响应时间 | P95 > 1s | LCP > 4s | SSR > 1s | - | 首屏 > 3s |
| JVM 堆 | > 85% | - | - | - | - |
| GC 暂停 | > 1s | - | - | - | - |
| DB 连接池 | > 80% | - | > 80% | - | - |
| Redis 内存 | > 80% | - | > 80% | - | - |
| 内存 | - | - | - | > 200MB | > 50MB |

#### 入口标准
- [ ] 阶段十一出口标准全部满足

#### 出口标准
- [ ] 24 小时内 P95 指标正常
- [ ] 72 小时内无 P0/P1 事故
- [ ] P0/P1 事故复盘已完成
- [ ] 用户无负面反馈

---

## 第二部分：技术栈专项补充

> 以下为各技术栈在通用流程之外的特有实践，按模板目录名组织。

### java-springboot 专项

#### 多模块 Maven 项目结构

```
project-root/
├── common/        # DTO、工具、异常、常量 → 被所有模块依赖
├── dao/           # Entity + Mapper + XML → 依赖 common
├── service/       # Service + Impl → 依赖 dao
├── facade/        # Dubbo RPC 接口定义 → 依赖 common
├── api/           # Controller（HTTP 入口）→ 依赖 service
├── client/        # Feign / Dubbo Consumer → 依赖 facade
└── starter/       # Application 主类 + 配置 → 依赖所有
```

**🔑 模块依赖原则：**
- 单向依赖：common ← dao ← service ← api/facade
- 禁止反向依赖（api 不能依赖 dao）
- 禁止跨层依赖（Controller 不能直接调 Mapper）

#### JVM 参数速查

```bash
# **重点** 生产环境 JVM 参数
-Xms2g -Xmx2g                           # 堆初始=最大，避免扩容开销
-XX:+UseG1GC                            # G1 收集器（推荐）
-XX:MaxGCPauseMillis=200                # GC 暂停目标 200ms
-XX:+HeapDumpOnOutOfMemoryError         # OOM 时 dump
-XX:HeapDumpPath=/data/logs/heapdump    # dump 路径
-XX:+PrintGCDetails -Xloggc:/data/logs/gc.log  # GC 日志
```

#### Redis Key 设计规范

```
格式：项目:模块:业务:ID
示例：mallx:order:export:12345
      mallx:user:session:abc123
      mallx:product:stock:67890

**重点**
- 每个 Key 必须设 TTL
- 过期时间加随机偏移（防缓存雪崩）：TTL + random(0, TTL * 0.1)
- 分布式锁用 Redisson，不要自己用 SETNX
```

#### DB 迁移风险等级

| 操作 | 风险评分 | 锁类型 | **重点** 影响 |
|------|:---:|--------|-----------|
| CREATE TABLE | 15 | ACCESS EXCLUSIVE（瞬间） | 低风险，新表无并发冲突 |
| ADD COLUMN (nullable) | 10 | ACCESS EXCLUSIVE（瞬间） | 低风险，仅修改元数据 |
| ADD COLUMN NOT NULL DEFAULT | 65 | ACCESS EXCLUSIVE（需全表扫描） | **重点** 大表可能锁很久 |
| CREATE INDEX | 30 | SHARE（可并发读不可写） | **重点** 用 CONCURRENTLY 避免锁表 |
| DROP COLUMN | 85 | ACCESS EXCLUSIVE | **重点** 先标记废弃，确认无引用再删 |
| RENAME COLUMN | 60 | ACCESS EXCLUSIVE | **重点** 同步更新所有引用代码 |
| ALTER TYPE | 90 | ACCESS EXCLUSIVE + 全表扫描 | **重点** 高风险，需要兼容转换 |

---

### react-umi 专项

#### Umi Max 内置能力速查

| 能力 | 使用方式 | **重点** 说明 |
|------|---------|-------------|
| 路由 | `config/routes.ts` | 支持嵌套、权限、菜单自动生成 |
| 请求 | `import { request } from '@umijs/max'` | 内置拦截器、错误处理 |
| 状态 | `src/models/` + `useModel()` | 全局状态管理 |
| 权限 | `src/access.ts` + `<Access>` 组件 | 路由级 + 组件级 |
| 数据获取 | `useRequest`（ahooks 集成） | 自动 loading、error、竞态处理 |
| 国际化 | `@umijs/max` 内置 | 配置式 |

#### ProTable 最佳实践

```typescript
// **重点** ProTable 的 request 返回格式必须包含 data/success/total
const columns: ProColumns<API.UserItem>[] = [
  { title: 'ID', dataIndex: 'id', hideInSearch: true },
  { title: '用户名', dataIndex: 'username' },
  { title: '状态', dataIndex: 'status', valueEnum: STATUS_MAP },
  {
    title: '操作',
    valueType: 'option',
    render: (_, record) => [
      <a key="edit" onClick={() => handleEdit(record)}>编辑</a>,
      <a key="delete" onClick={() => handleDelete(record)}>删除</a>,
    ],
  },
];

<ProTable<API.UserItem>
  columns={columns}
  request={async (params) => {
    const res = await fetchUsers(params);
    return { data: res.data, success: true, total: res.total };
  }}
  rowKey="id"
  search={{ labelWidth: 100 }}
  pagination={{ defaultPageSize: 20 }}
/>
```

#### 反模式（react-umi 专属）

- ❌ ProTable + 手动 fetch → 用 ProTable 内置 `request`
- ❌ `useEffect` + `setState` + `fetch` → 用 `useRequest`
- ❌ 权限只在前端路由做 → 后端接口也要鉴权（前端路由守卫只是 UI 优化）
- ❌ `any` 满天飞 → API 类型在 `src/types/api.d.ts` 统一定义
- ❌ ProForm 外再包一层 Form → ProForm 自带校验和提交

---

### typescript-vite-react 专项

#### Vite 配置要点

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [react()],
  resolve: { alias: { '@': path.resolve(__dirname, 'src') } },
  server: {
    port: 3000,
    proxy: {
      '/api': { target: 'http://localhost:8080', changeOrigin: true },
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {        // **重点** 手动分包优化
          vendor: ['react', 'react-dom', 'react-router-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
});
```

#### Zustand 使用规范

```typescript
// **重点** Store 按领域拆分，不要一个 store 管所有
// ✅ 按领域拆分
// stores/auth.ts   → 用户信息、token
// stores/cart.ts   → 购物车
// stores/ui.ts     → 侧栏状态、主题

// ❌ 一个 stores/app.ts 管所有
```

#### SPA 部署要点

```nginx
# **重点** SPA 必须配置 try_files，否则刷新 404
location / {
  try_files $uri $uri/ /index.html;
}

# API 代理（可选，也可以前端直连）
location /api {
  proxy_pass http://backend:8080;
}
```

---

### typescript-nextjs-react 专项

#### Server Component 数据流

```
数据库/API
    ↓
Server Component（async，直接 await）
    ↓ props
Client Component（'use client'，不能 async）
    ↓
用户交互
```

**🔑 关键规则：**
- Server Component 可以 `async function`，直接 await DB 查询
- Client Component 不能 async，数据通过 props 传入或用 TanStack Query
- `'use client'` 边界尽量下移：只把需要交互的叶子组件标记为客户端
- 不要为了用 hooks 把整页变 Client Component

#### 渲染策略选择

| 场景 | 策略 | 配置 | **重点** 适用 |
|------|------|------|-------------|
| 博客文章、产品页 | SSG | `generateStaticParams` | 内容不频繁变化 |
| 动态内容 + SEO 重要 | SSR | 默认（async Server Component） | 每次请求最新数据 |
| 定期更新 + 高性能 | ISR | `revalidate = 60` | 可接受 60 秒延迟 |
| 用户仪表盘、购物车 | CSR | `'use client'` + TanStack Query | 不需要 SEO |

#### Server Action 安全

```typescript
// ✅ 正确：输入校验 + 权限检查
'use server';
import { z } from 'zod';
import { auth } from '@/lib/auth';

const schema = z.object({ name: z.string().min(1).max(100) });

export async function updateUser(formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  const { name } = schema.parse(Object.fromEntries(formData));
  await db.user.update({ where: { id: session.user.id }, data: { name } });
  revalidatePath('/profile');  // **重点** revalidate 在操作成功后
}
```

---

### monorepo 专项

#### 子项目操作流程

```
1. 识别目标子项目（用户说"后端"/"前端"/"小程序"）
2. 读取子项目的 CLAUDE.md → 加载该技术栈规范
3. 在子项目目录内操作 → 不跨目录修改
4. 涉及 API 变更：先改后端 → 再改前端/小程序/Flutter
5. 不同子项目分 commit 提交
```

#### 跨项目 API 变更流程

```
1. 后端：定义/修改 API → 更新接口文档 → 提交 + 测试
2. 前端/小程序/Flutter：更新 API Client → 调整调用代码 → 提交 + 测试
3. 如涉及共享类型(shared/types/)：先更新类型 → 各消费方同步调整
```

**🔑 禁止操作：**
- ❌ 跨子项目在一个 commit 里混改
- ❌ 前端/小程序/Flutter 直连数据库
- ❌ 在子项目间直接 import 源码
- ❌ 改公共配置（docker-compose / CI）不告知

---

### flutter-pos 专项

#### 离线优先架构

```
用户操作 → Provider(立即更新本地状态)
              ↓
        sqflite 本地存储(队列)
              ↓
        网络恢复? → 是 → Dio 同步到服务端
                  → 否 → 等待
              ↓
        同步成功 → 更新队列状态
        同步失败 → 重试(最多3次) → 仍失败 → 标记失败 + 通知用户
```

#### Provider 模式

```dart
// **重点** ChangeNotifier dispose 时释放资源
class OrderProvider extends ChangeNotifier {
  final OrderService _service;
  List<Order> _orders = [];
  bool _syncing = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get syncing => _syncing;

  Future<void> syncPendingOrders() async {
    _syncing = true; notifyListeners();
    try {
      final pending = await _service.getLocalPending();
      for (final order in pending) {
        await _service.syncToServer(order);
      }
    } finally {
      _syncing = false; notifyListeners();
    }
  }

  @override
  void dispose() {
    // **重点** 清理资源
    super.dispose();
  }
}
```

#### 金额处理

```dart
// **重点** 金额统一用 double，**绝对不要**用 double 做相等比较
// ✅ 格式化展示
String formatMoney(double amount) => '¥${amount.toStringAsFixed(2)}';

// ✅ 比较用 tolerance
bool almostEqual(double a, double b) => (a - b).abs() < 0.001;
```

---

### wechat-miniprogram 专项

#### 分包策略

```json
// app.json
{
  "pages": [          // 主包（首页 + 通用页）
    "pages/index/index",
    "pages/common/error"
  ],
  "subpackages": [    // 分包
    {
      "root": "subpkg-user",
      "pages": ["pages/profile/index", "pages/settings/index"]
    },
    {
      "root": "subpkg-order",
      "pages": ["pages/list/index", "pages/detail/index"]
    }
  ],
  "preloadRule": {    // 预加载
    "pages/index/index": {
      "network": "all",
      "packages": ["subpkg-user"]
    }
  }
}
```

**🔑 分包原则：**
- 首页相关放主包
- 非首屏页放分包
- 独立功能放独立分包（不依赖主包）
- 预加载高频分包

#### setData 优化

```typescript
// ❌ 错误：全量 setData
this.setData({ user: this.data.user });

// ✅ 正确：只传变更字段
this.setData({ 'user.avatar': newAvatar });

// ✅ 正确：合并连续的 setData
const updates: Record<string, any> = {};
updates['user.avatar'] = newAvatar;
updates['user.nickname'] = newNickname;
this.setData(updates);  // 一次调用
```

#### 审核注意事项

| 审核风险 | **重点** 规避方法 |
|----------|-----------------|
| 功能不完整 | 提交审核前完整走一遍体验版 |
| 含测试数据 | 提审前清理所有测试数据 |
| 缺少隐私协议 | 涉及用户信息时必须更新隐私协议 |
| 类目不符 | 确认小程序类目与实际功能匹配 |
| 服务器域名未配置 | 提前在微信后台配置 request 合法域名 |

---

### session-logging 专项

#### Hook 正确配置

**仅适用于 session-logging 类项目。**

```json
// .claude/settings.local.json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Skill|Agent",
      "hooks": [{
        "type": "command",
        "command": "bash .claude/hooks/session-logger.sh Skill ${CLAUDE_TOOL_NAME}"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "bash .claude/hooks/session-logger.sh Stop"
      }]
    }]
  }
}
```

**🔑 Hook 配置常见错误：**

| ❌ 错误 | ✅ 正确 | **重点** 说明 |
|---------|---------|-------------|
| `"enableHooks": true` | `"hooks": { "PostToolUse": [...] }` | 不存在 enableHooks 配置键 |
| `"onBeforeWriteFile"` | `"PostToolUse"` | 不存在驼峰事件名 |
| JS 文件 `module.exports` | Shell 命令 `"type": "command"` | Hook 不是 JS 模块 |
| `"hookDir": "..."` | 直接在 hooks 字段中配置 | 不存在 hookDir 配置键 |

#### 路由规则验证

```bash
# **重点** 新路由规则上线前验证
# 1. 模拟 Skill 调用
bash .claude/hooks/session-logger.sh Skill writing-plans

# 2. 检查日志文件是否正确生成
ls docs/sessions/$(date +%Y-%m-%d)/

# 3. 验证路由规则不冲突
grep -r "writing-plans" .claude/hooks/
```

---

### docs-config 专项

#### 模板完备度决策

| 场景 | 完备度 | 文件 | **重点** 理由 |
|------|:---:|------|-------------|
| 个人小项目、Demo | 基础 | CLAUDE.md | 轻量够用 |
| 团队项目(2-5人) | 标准 | + settings.local.json | 权限控制必要 |
| 大型团队、微服务 | 完整 | + .mcp.json + hooks | MCP 诊断 + 流程自动化 |

#### 新建模板检查清单

```markdown
- [ ] CLAUDE.md 包含：常用命令、项目结构、架构分层、安全要点、反模式
- [ ] CLAUDE.md 不包含：已安装能力清单（占 token 无 AI 价值）
- [ ] settings.local.json 格式正确（不是 enablePlugins/enableHooks 等错误写法）
- [ ] 模板在目标项目中实际验证过
- [ ] README.md 同步更新（如有）
```

---

### global 专项

**适用于未匹配到特定技术栈的项目。**

#### 最小 CLAUDE.md 模板

```markdown
# CLAUDE.md — <项目名>

> 技术栈：<填写>
> 构建工具：<填写>

## 常用命令
```bash
# 编译/构建
# 测试
# 启动
```

## 项目结构
```
src/
├── ...
```

## 编码规范
- 命名风格：<camelCase/snake_case>
- 文件组织：<约定>

## 安全要点
- 敏感信息走环境变量
- 用户输入校验消毒

## 反模式
- ❌ ...
```

#### 按实际技术栈添加

如果项目后续明确了技术栈，应从 global 迁移到对应模板（java-springboot / typescript-vite-react 等），补充该技术栈的专项规范、MCP 配置、审查重点。

---

## 第三部分：质量标准与完成定义

### 代码质量门禁（按项目类型）

| 指标 | java-springboot | 前端类 | nextjs | flutter-pos | miniprogram |
|------|:---:|:---:|:---:|:---:|:---:|
| 测试覆盖率 | ≥ 80% (JaCoCo) | ≥ 80% (Vitest) | ≥ 80% (Vitest) | ≥ 75% | utils 100% |
| 安全漏洞 | 0 高危/严重 | 0 高危/严重 | 0 高危/严重 | 无 | 无 |
| N+1 查询 | 0 | - | 0 (如有 DB) | - | - |
| 编译错误 | 0 | 0 | 0 | 0 | 0 |
| 静默失败 | 0 | 0 | 0 | 0 | 0 |
| Bundle/包体积 | - | chunk < 200KB | 首屏 JS < 150KB | - | 分包 < 2MB |
| API 响应 | P95 < 500ms | - | SSR < 200ms | - | - |
| 前端性能 | - | FCP < 1.8s | LCP < 2.5s | UI > 58fps | 首屏 < 2s |

### 完成定义 (Definition of Done)

一个功能被认为**完成**，必须满足：

**通用（所有项目类型）：**
- [ ] 代码已实现并通过所有测试
- [ ] 测试覆盖率达标（按项目类型标准）
- [ ] 代码审查通过（Approved）
- [ ] 安全审查无高危/严重
- [ ] 性能审查无阻塞性问题（按项目类型标准）
- [ ] `progress.md` 标记为完成
- [ ] 无遗留 TODO/FIXME（或已有跟踪 Issue）

**java-springboot 额外：**
- [ ] 数据库迁移已分析且风险可控（< 50 分）
- [ ] JVM 参数已确认
- [ ] API 文档已更新
- [ ] 上线后 24h 无异常

**前端类额外（react-umi / vite-react / nextjs）：**
- [ ] `pnpm build` 成功无警告
- [ ] 环境变量确认
- [ ] 浏览器兼容已验证

**nextjs 额外：**
- [ ] SSR/SSG/ISR 策略正确
- [ ] Server/Client 边界合理

**flutter-pos 额外：**
- [ ] 真机测试通过（Android + iOS）
- [ ] build_runner 生成文件已更新
- [ ] 离线模式流程验证通过
- [ ] 硬件兼容性验证通过

**miniprogram 额外：**
- [ ] 包体积合规
- [ ] 体验版测试通过
- [ ] 审核材料已准备

**session-logging 额外：**
- [ ] Hook 脚本语法验证通过 (`bash -n`)
- [ ] 路由规则不冲突
- [ ] 端到端验证通过

**docs-config 额外：**
- [ ] 模板在目标项目中实际验证
- [ ] README.md 同步更新（如有）

---

## 第四部分：命令速查表

### 流程命令（按阶段排列）

#### 阶段 0：项目初始化

| 命令 | 用途 |
|------|------|
| `ecc:plan` | 技术选型与架构规划 |
| `java-core:java-adr` | Java 项目架构决策记录 |
| `/java-spring:java-scaffold` | 新建 Spring Boot 项目 |
| `spring-boot-dev:spring-boot-package-structure-creator` | 生成标准包结构 |

#### 阶段一：需求

| 命令 | 用途 |
|------|------|
| `/brainstorming` | 头脑风暴，探索 3+ 方案 |
| `/office-hours` | 产品视角梳理需求 |
| `/plan-ceo-review` | 战略优先级审查 |

#### 阶段二：设计

| 命令 | 用途 |
|------|------|
| `/writing-plans` | 编写技术方案 |
| `/plan-eng-review` | 工程架构审查 |
| `/plan-design-review` | UX/交互审查 |
| `ecc:architecture-decision-records` | 记录 ADR |

#### 阶段三：计划

| 命令 | 用途 |
|------|------|
| `/planning-with-files:plan` | 创建持久化规划 |
| `/executing-plans` | 按计划逐步执行 |

#### 阶段四：实现

| 命令 | 用途 | 适用项目类型 |
|------|------|-------------|
| `/test-driven-development` | TDD 红-绿-重构 | 全部 |
| `/ralph-loop` | 自主迭代执行 | 全部 |
| `/java-spring:java-crud` | 生成 CRUD | java-springboot |
| `/java-spring:java-jpa` | JPA 审查 | java-springboot |
| `/java-spring:java-security` | Security 配置 | java-springboot |
| `/java-core:java-fix` | 构建修复 | java-springboot |
| `spring-boot-dev:jpa-entity-creator` | 生成 JPA 实体 | java-springboot |
| `spring-boot-dev:spring-rest-api-creator` | 生成 REST Controller | java-springboot |
| `spring-boot-dev:spring-service-creator` | 生成 Service | java-springboot |

#### 阶段五：审查

| 命令 | 用途 | 适用项目类型 |
|------|------|-------------|
| `/requesting-code-review` | 提交审查 | 全部 |
| `ecc:code-review` | 多维度审查 | 全部 |
| `/receiving-code-review` | 处理反馈 | 全部 |
| `ecc:silent-failure-hunter` | 静默失败检测 | 全部 |
| `ecc:comment-analyzer` | 注释质量 | 全部 |
| `java-core:java-review` | Java 架构审查 | java-springboot |
| `ecc:flutter-review` | Flutter 审查 | flutter-pos |
| `ecc:typescript-reviewer` | TypeScript 审查 | 前端类 |

#### 阶段六：测试

| 命令 | 用途 | 适用项目类型 |
|------|------|-------------|
| `/verification-before-completion` | 完成前验证 | 全部 |
| `ecc:test-coverage` | 覆盖率分析 | 全部 |
| `ecc:e2e-runner` | E2E 测试 | 有 UI 的项目 |
| `/java-quality:java-test` | Java 测试工程 | java-springboot |

#### 阶段七：安全

| 命令 | 用途 | 适用项目类型 |
|------|------|-------------|
| `ecc:security-scan` | OWASP 扫描 | 全部 |
| `/security-review` | 安全审查 | 全部 |
| `/cso` | OWASP + STRIDE | 有 API 的项目 |
| `/java-quality:java-security-check` | Java 安全 | java-springboot |

#### 阶段八：性能

| 命令 | 用途 | 适用项目类型 |
|------|------|-------------|
| `ecc:performance-optimizer` | 综合性能分析 | 全部 |
| `/java-quality:java-perf-check` | Java 性能 | java-springboot |

#### 阶段九～十二

| 命令 | 用途 | 阶段 |
|------|------|:---:|
| `/finishing-a-development-branch` | 分支收尾 | 阶段十 |
| `/document-release` | Release Notes | 阶段十 |
| `/checkpoint` | 检查点 | 阶段十 |
| `/ship` | 一键发布 | 阶段十一 |
| `/canary` | 金丝雀发布 | 阶段十一 |
| `/land-and-deploy` | 合并并部署 | 阶段十一 |
| `/guard` | 安全守护 | 阶段十二 |

### MCP 诊断速查（按使用场景）

| 场景 | 项目类型 | MCP 工具 |
|------|---------|---------|
| 慢查询分析 | java-springboot / nextjs | `db-analyzer: explain_query` |
| 索引建议 | java-springboot / nextjs | `db-analyzer: analyze_indexes` |
| 表膨胀检查 | java-springboot | `db-analyzer: analyze_table_bloat` |
| 活跃连接分析 | java-springboot | `db-analyzer: analyze_connections` |
| GC 日志分析 | java-springboot | `jvm-diagnostics: analyze_gc_log` |
| 堆内存分析 | java-springboot | `jvm-diagnostics: analyze_heap_histo` |
| 线程 Dump | java-springboot | `jvm-diagnostics: analyze_thread_dump` |
| 迁移风险评估 | java-springboot | `migration-advisor: analyze_migration` |
| 迁移冲突检测 | java-springboot | `migration-advisor: detect_conflicts` |
| 健康检查 | java-springboot | `spring-boot-actuator: analyze_health` |
| Redis 内存 | java-springboot / nextjs | `redis-diagnostics: analyze_memory` |
| Redis 慢查询 | java-springboot / nextjs | `redis-diagnostics: analyze_slowlog` |
| E2E 测试 | 前端 / 小程序 / Flutter | Playwright (通过 `ecc:e2e-runner`) |

---

## 角色分工

| 角色 | 命令 | 阶段 | **重点** 职责 |
|------|------|:---:|-------------|
| **CEO** | `plan-ceo-review` | 阶段一 | 战略优先级、投资回报率 |
| **产品经理** | `office-hours` | 阶段一 | 用户故事、验收条件、MVP 范围 |
| **架构师** | `plan-eng-review` `ecc:plan` | 阶段二 | 技术方案、系统架构、技术选型 ADR |
| **工程师** | TDD + `executing-plans` | 阶段四 | 写代码、写测试、重构 |
| **QA** | `e2e-runner` `test-coverage` | 阶段六 | E2E 测试、回归测试、覆盖率验证 |
| **安全官** | `cso` `security-review` | 阶段七 | OWASP Top 10、STRIDE、注入检测 |
| **性能工程师** | `performance-optimizer` | 阶段八 | N+1 检测、JVM 调优、索引优化 |
| **DevOps** | `ship` `canary` `guard` | 阶段九～十二 | CI/CD 流水线、金丝雀、回滚、监控 |
| **SRE** | 告警响应、事故复盘 | 阶段十二 | SLO/SLI、Error Budget、Postmortem |

---

> **文档版本**: v2.0 | **更新日期**: 2026-05-21
> **v2.0 变更**: 按 10 种项目类型全面重构，新增阶段 0（NFR 收集）、阶段九（CI/CD）、事故分级与 Postmortem、技术栈专项补充
