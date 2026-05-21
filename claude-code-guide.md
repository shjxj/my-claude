# Claude Code 使用指南 v2.0

> 基于当前安装的 10 插件 + 200+ Skill + 13 MCP 服务制定的全场景使用手册
> 更新日期：2026-05-21
>
> **v2.0 更新**：按 10 种项目类型全面重构，新增核心工作流、高级能力（自主循环/并行Agent/记忆系统/Context7）、扩充疑难解答

---

## 项目类型速查

> 快速定位你的技术栈，跳转到专属配置。每种类型在以下各章节均有差异化指导。

| # | 模板目录 | 适用场景 | 技术栈关键词 | 核心关注点 |
|---|----------|---------|-------------|-----------|
| 1 | `java-springboot` | Java 后端微服务 | Spring Boot 3.5 + MyBatis Plus + Dubbo | **重点** Maven/Gradle 权限、JVM MCP、DB 迁移 MCP |
| 2 | `react-umi` | React PC 管理端 | TypeScript + Umi Max + Antd 5 | **重点** ProComponents 使用规范、路由权限配置 |
| 3 | `typescript-vite-react` | React SPA 前端 | TypeScript + Vite + React Router + Zustand | **重点** Vite 代理、SPA 部署 try_files |
| 4 | `typescript-nextjs-react` | React 全栈项目 | TypeScript + Next.js 15 + App Router + Prisma | **重点** Server/Client 边界、渲染策略、Vercel 部署 |
| 5 | `monorepo` | 大型多技术栈仓库 | 多语言混合（Java + TS + Dart + 小程序） | **重点** 子项目隔离、跨项目协调、CI 变更检测 |
| 6 | `flutter-pos` | Flutter 移动端 | Flutter 3 + Provider + Freezed + Dio | **重点** 离线优先、硬件集成、平台通道 |
| 7 | `wechat-miniprogram` | 微信小程序 | TypeScript + 原生框架 + TDesign | **重点** 分包策略、审核流程、包体积限制 |
| 8 | `session-logging` | 会话日志系统 | Hook 脚本 + Shell + Markdown | **重点** Hook 正确配置、路由规则不冲突 |
| 9 | `docs-config` | 文档/配置项目 | Markdown + Shell + JSON | **重点** 模板完备度三级、幂等脚本 |
| 10 | `global` | 通用/未分类项目 | 任意技术栈 | **重点** 按实际技术栈补充专项规范 |

---

## 目录

- [一、CLAUDE.md 配置规范（按项目类型）](#一claudemd-配置规范按项目类型)
- [二、项目配置规范（按技术栈差异化）](#二项目配置规范按技术栈差异化)
- [三、Agent 与子代理体系](#三agent-与子代理体系)
- [四、Skill 与工作流体系](#四skill-与工作流体系)
- [五、MCP 服务体系](#五mcp-服务体系)
- [六、核心工作流](#六核心工作流)
- [七、高级能力](#七高级能力)
- [八、实战技巧](#八实战技巧)
- [九、疑难解答](#九疑难解答)
- [十、命令速查](#十命令速查)

---

## 一、CLAUDE.md 配置规范（按项目类型）

### 1.1 核心原则

- **CLAUDE.md 是全局行为准则**，不是项目百科、不是文档仓库、不是代码模板库
- **控制在 150 行以内**，超过 200 行后尾部指令在实际使用中权重下降。这是社区反复验证的经验阈值
- **每次对话自动加载**，优先级最高

### 1.2 五大分流策略

**策略 1：目录分级 CLAUDE.md**

全局只留极简主规则，细分规则下沉到子目录，进入对应目录时自动生效。

**策略 2：长文本规则 → Skills**

低频、篇幅长的规范放入 `.claude/skills/` 或 `~/.claude/skills/`，通过 `/skill-name` 调用，不占全局上下文。

**策略 3：跨项目技术栈规范 → 全局 Skills**

通用技术规范存入 `~/.claude/skills/`，多项目共享，不写入项目 CLAUDE.md。

**策略 4：强制规则 → Hooks 钩子**

需强制执行的规则用 Hooks 实现。Hooks 在 `settings.json` 中以 Shell 命令方式配置，监听工具调用事件。比纯文字规则执行力更强。

**策略 5：业务约定 → Memory 长期记忆**

项目专属业务逻辑、流程、约束写入 Memory 系统（claude-mem 插件），不占 CLAUDE.md 空间。每次新会话自动注入相关记忆。

### 1.3 模板完备度三级

| 级别 | 文件 | 适用场景 | **重点** 说明 |
|------|------|---------|-------------|
| **基础** | CLAUDE.md | 个人小项目、Demo | 150 行以内的核心规则 |
| **标准** | + settings.local.json | 团队项目（2-5人） | 权限白名单 + Hook 配置 |
| **完整** | + .mcp.json + hooks | 大型团队、微服务 | MCP 诊断 + 全流程自动化 |

### 1.4 按项目类型的 CLAUDE.md 模板

#### java-springboot

```markdown
# CLAUDE.md — Java Spring Boot 微服务

> **技术栈：** Java 21 + Spring Boot 3.5 + MyBatis Plus + MySQL + Redis + Dubbo + Nacos

## 常用命令
mvn clean test              # 单元+集成测试
mvn spring-boot:run         # 本地启动
mvn clean package -DskipTests  # 打包

## 项目分层
controller → service(impl) → mapper → entity
     ↓            ↓
  R<T> 响应   @Transactional 事务边界

## 命名规范
- Entity/Mapper/Service/Controller 按领域划分
- 方法名：getXxxByYyy、listXxxByCondition、saveXxx、updateXxx、removeXxx
- 常量：全大写下划线

## 全局约束
1. Controller 只做参数校验和 R<T> 响应，不写业务逻辑
2. Service 用 @Transactional 控制事务，禁止 Controller 直调 Mapper
3. SQL 用 #{} 参数化，禁止 ${} 拼接
4. 敏感信息走环境变量/Nacos，不硬编码
5. 修改代码前分析调用链路

## 安全红线
- 禁止 SQL 注入（MyBatis `${}` 拼接）
- 禁止路径遍历（文件下载必须校验路径）
- 禁止 SSRF（外部 URL 请求必须白名单）
```

#### react-umi

```markdown
# CLAUDE.md — React + Umi Max 管理端

> **技术栈：** TypeScript + Umi Max + Antd 5 + ProComponents

## 常用命令
pnpm dev                    # 开发启动
pnpm build                  # 生产构建
pnpm tsc --noEmit           # 类型检查
pnpm test                   # Vitest

## 项目结构
src/
├── pages/                  # 页面（Umi 文件路由）
├── components/             # 全局组件
├── services/               # API 请求
├── models/                 # 全局状态（useModel）
├── access.ts               # 权限定义
├── app.tsx                 # 运行时配置
└── config/routes.ts        # 路由 + 菜单

## 核心规则
1. 列表页优先用 ProTable，不要手动写 Table + fetch
2. 数据获取用 useRequest，不要 useEffect + useState + fetch
3. 权限在 access.ts 定义，路由 + 组件双重控制
4. API 类型定义在 src/types/api.d.ts

## 反模式
- ❌ ProTable + 手动 fetch
- ❌ useEffect + setState + fetch
- ❌ 权限只在前端路由做
- ❌ any 满天飞
```

#### typescript-vite-react

```markdown
# CLAUDE.md — TypeScript + Vite + React SPA

> **技术栈：** TypeScript + React 19 + Vite 6 + React Router 7 + Zustand + TanStack Query

## 常用命令
pnpm dev                    # Vite 开发服务器
pnpm build                  # 生产构建
pnpm preview                # 预览构建产物
pnpm tsc --noEmit           # 类型检查
pnpm test                   # Vitest

## 核心规则
1. 服务端数据用 TanStack Query，不用 useEffect + fetch
2. 全局状态用 Zustand，页面内状态用 useState
3. API 调用统一走 apiClient（axios 实例 + 拦截器）
4. SPA 部署必须 nginx try_files $uri /index.html

## 反模式
- ❌ useEffect 调 API 不处理竞态条件
- ❌ 所有状态扔进 Zustand
- ❌ 硬编码 API 地址
```

#### typescript-nextjs-react

```markdown
# CLAUDE.md — TypeScript + Next.js + React 全栈

> **技术栈：** TypeScript + React 19 + Next.js 15 (App Router) + Prisma/Drizzle + Auth.js

## 常用命令
pnpm dev                    # 开发启动
pnpm build                  # 生产构建
pnpm tsc --noEmit           # 类型检查
pnpm test                   # Vitest

## 核心规则
1. 默认 Server Component，只把交互部分拆成 Client Component
2. 'use client' 边界尽量下移
3. Server Component 直接 async await 数据库，不用 useEffect
4. Server Action 必须加输入校验（zod）+ 权限检查（auth()）
5. revalidatePath 只在操作成功后调用

## 反模式
- ❌ Server Component 中用 useState/useEffect
- ❌ 整页标记 'use client'
- ❌ Server Action 不校验输入
- ❌ 忘记 next/image 的 priority/sizes 属性
```

#### monorepo

```markdown
# CLAUDE.md — 多技术栈 Monorepo

> **项目结构：** pnpm workspace + 多子项目

## 子项目操作规则
1. 操作前先明确目标子项目目录
2. 读取子项目的 CLAUDE.md 加载技术栈规范
3. 在子项目目录内操作，不跨目录修改
4. API 变更顺序：后端 → 前端/小程序/Flutter
5. 不同子项目分 commit 提交

## 禁止操作
- ❌ 跨子项目在一个 commit 里混改
- ❌ 前端/小程序/Flutter 直连数据库
- ❌ 在子项目间直接 import 源码
- ❌ 改公共配置文件不告知
```

#### flutter-pos

```markdown
# CLAUDE.md — Flutter POS 移动端

> **技术栈：** Flutter 3 + Dart + Provider + Freezed + Dio + sqflite

## 常用命令
flutter pub get                        # 获取依赖
flutter pub run build_runner build     # 生成 Freezed/JSON 代码（model 变更后必须执行）
flutter analyze                        # 静态分析
flutter test                           # 单元测试
flutter build apk --release            # Android 构建

## 核心规则
1. 离线优先：所有操作先写本地 sqflite，网络恢复后同步
2. Model 用 @freezed 生成不可变类
3. 状态管理用 Provider（ChangeNotifier），dispose 中释放资源
4. 金额统一用 double + tolerance 比较，绝对不用 == 比较
5. 硬件交互走 Platform Channel 封装

## 反模式
- ❌ 在线只读（不考虑断网场景）
- ❌ 本地数据库存明文密码
- ❌ Provider 嵌套超过 5 层
- ❌ build 方法中做网络请求
```

#### wechat-miniprogram

```markdown
# CLAUDE.md — 微信小程序

> **技术栈：** TypeScript + 原生小程序 + TDesign

## 核心约束
1. 主包 < 2MB，单分包 < 2MB，总包 < 20MB
2. 新页面必须在 app.json 注册
3. npm 包需在微信开发者工具中构建后才能用
4. 所有微信 API 调用需处理 fail 回调
5. openId/unionId 只在服务端处理，不传到前端
6. 审核周期 1-7 天，提审前完整体验版测试

## 反模式
- ❌ setData 全量更新（只传变更字段）
- ❌ 频繁 setData（合并连续调用，< 20 次/秒）
- ❌ Storage 存敏感信息
- ❌ 首页依赖分包加载
- ❌ wx.request fail 不处理
```

#### session-logging

```markdown
# CLAUDE.md — 会话日志系统

> **技术栈：** Hook 脚本 + Shell + Markdown

## 核心规则
1. Hook 配置在 settings.json 的 hooks 字段中，type 为 "command"
2. Hook 事件名为 PascalCase：PreToolUse、PostToolUse、SessionStart 等
3. 路由脚本负责识别 Skill/Agent 名称，写入对应阶段日志
4. 新路由规则不能与已有规则冲突

## 验证流程
bash -n .claude/hooks/session-logger.sh     # 语法检查
bash .claude/hooks/session-logger.sh Skill writing-plans  # 模拟调用

## 常见错误
| ❌ 错误 | ✅ 正确 |
|---------|---------|
| "enableHooks": true | "hooks": { "PostToolUse": [...] } |
| "onBeforeWriteFile" | "PostToolUse" |
| JS 文件 module.exports | Shell 命令 "type": "command" |
| "hookDir": "..." | 直接在 hooks 字段配置 |
```

#### docs-config

```markdown
# CLAUDE.md — 文档/配置管理项目

> **项目定位：** Claude Code 配置管理中心

## 模板完备度决策
| 场景 | 完备度 | 文件 |
|------|:---:|------|
| 个人小项目/Demo | 基础 | CLAUDE.md |
| 2-5人团队 | 标准 | + settings.local.json |
| 大型团队/微服务 | 完整 | + .mcp.json + hooks |

## 新增场景模板检查清单
- [ ] CLAUDE.md 含：常用命令、项目结构、架构分层、安全要点、反模式
- [ ] CLAUDE.md 不含：已安装能力清单（占 token 无指导价值）
- [ ] settings.local.json 格式正确
- [ ] 模板在目标项目中实际验证过
```

---

## 二、项目配置规范（按技术栈差异化）

### 2.1 配置文件层级

| 文件 | 位置 | 优先级 | 用途 |
|------|------|--------|------|
| `CLAUDE.md` | 项目根目录 | 最高 | 项目行为规范 |
| `settings.json` | `~/.claude/` | 全局 | 插件、Hook、MCP、权限 |
| `settings.local.json` | 项目 `.claude/` | 覆盖全局 | 项目级权限白名单 |
| `.mcp.json` | 项目根目录 | 覆盖全局 MCP | 项目级 MCP 配置 |
| `.claudeignore` | 项目根目录 | — | 忽略无需解析的文件 |

### 2.2 settings.local.json 配置（按项目类型）

**通用骨架：**

```json
{
  "permissions": {
    "allow": [],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Write(/etc/*)",
      "Write(/usr/*)"
    ]
  }
}
```

**各项目类型 allow 白名单差异：**

| 项目类型 | allow 关键项 | **重点** 说明 |
|----------|-------------|-------------|
| **java-springboot** | `Bash(mvn:*)` `Bash(java:*)` `Bash(git:*)` `Bash(docker:*)` | Maven、Docker 必备 |
| **react-umi** | `Bash(pnpm:*)` `Bash(git:*)` | pnpm + git 即可 |
| **vite-react** | `Bash(pnpm:*)` `Bash(git:*)` | 同上 |
| **nextjs** | `Bash(pnpm:*)` `Bash(git:*)` `Bash(vercel:*)` | 加 vercel CLI |
| **monorepo** | `Bash(pnpm:*)` `Bash(mvn:*)` `Bash(git:*)` | 各子项目命令都要放行 |
| **flutter-pos** | `Bash(flutter:*)` `Bash(dart:*)` `Bash(git:*)` | flutter + dart |
| **miniprogram** | `Bash(pnpm:*)` `Bash(git:*)` | pnpm 即可 |
| **session-logging** | `Bash(git:*)` `Bash(mkdir:*)` | Hook 脚本需要写文件权限 |
| **docs-config** | `Bash(git:*)` `Bash(mkdir:*)` `Bash(cp:*)` | 模板复制需要 cp |

**常见配置错误对照：**

| 错误写法 | 正确写法 |
|----------|----------|
| `"enablePlugins": true` | `"enabledPlugins": { "name@market": true }` |
| `"allowWriteDirs": [...]` | `"permissions": { "allow": [...], "deny": [...] }` |
| `"enableHooks": true` | `"hooks": { "PostToolUse": [...] }` |
| Hook 是 JS 文件 `module.exports` | `settings.json` 中的 `"type": "command"` + Shell 命令 |
| `"hookDir": "..."` | 直接在 hooks 字段配置 |

### 2.3 .claudeignore（按项目类型差异）

```bash
# 通用（所有项目类型）
node_modules/
dist/
build/
.git/
*.log
logs/
cache/

# java-springboot
target/
*.class
*.jar

# Flutter
.dart_tool/
.packages

# Next.js
.next/
.turbo/

# 微信小程序
miniprogram_npm/
```

### 2.4 Hooks 配置详解

**Hook 是事件驱动的被动响应**，不能主动发起操作，只能绑定到具体事件。配置在 `settings.json` 的 `hooks` 字段中，type 必须为 `"command"`。

**完整事件列表：**

| 事件 | 触发时机 | **重点** 常用场景 |
|------|---------|-----------------|
| `PreToolUse` | 工具调用前 | 拦截高危命令、校验文件路径 |
| `PostToolUse` | 工具调用后 | 代码修改后触发格式化、日志记录 |
| `UserPromptSubmit` | 用户提交提示词 | 注入项目上下文 |
| `SessionStart` | 会话启动 | 环境检查、加载配置 |
| `SessionEnd` | 会话结束 | 清理临时文件 |
| `Stop` | Agent 停止响应 | 记录日志、自动循环触发 |
| `Notification` | 系统通知 | 自定义通知行为 |
| `SubagentStart` | 子代理启动 | 子代理环境准备 |
| `SubagentStop` | 子代理结束 | 子代理结果处理 |
| `PreCompact` | 上下文压缩前 | 保存关键信息到 Memory |
| `PreMessageEnqueue` | 消息入队前 | 消息预处理 |

**按项目类型的 Hook 配置示例：**

通用 — 代码修改后触发提示：

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "echo '[Hook] 代码已修改，建议运行代码审查'"
      }]
    }]
  }
}
```

java-springboot — Maven 构建前置检查：

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "if echo \"$CLAUDE_CODE_TOOL_INPUT\" | grep -q 'mvn.*test'; then echo '[Hook] 即将运行 Maven 测试...'; fi"
      }]
    }]
  }
}
```

session-logging — Skill/Agent 执行日志：

```json
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

**Hook 调试：**

```bash
bash -n .claude/hooks/session-logger.sh                        # 语法检查
CLAUDE_CODE_TOOL_INPUT="mvn clean test" bash .claude/hooks/pre-check.sh  # 模拟调用
claude --debug 2>&1 | grep -i hook                             # 查看 Hook 日志
```

### 2.5 Skills 目录结构

```
~/.claude/skills/                    # 全局 Skills（跨项目共享）
├── gstack/                          # 多角色 AI 工程团队（23 角色）
├── find-skills/                     # 搜索和发现技能
├── supabase/                        # Supabase 平台操作
├── ui-ux-pro-max/                   # UI/UX 设计增强
└── code-simplifier/                 # 代码质量检查

项目/.claude/skills/                 # 项目级 Skills
├── api-docs.md
└── deploy-guide.md
```

插件自带的 Skills（如 superpowers、ecc、java-core）无需额外配置，安装插件后自动可用。

### 2.6 配置模板部署

```bash
# 快速部署到目标项目
cp scripts/claude/templates/<类型>/CLAUDE.md <目标项目>/
cp scripts/claude/settings.local.json <目标项目>/.claude/

# 完整级项目额外部署
cp scripts/claude/.mcp.json <目标项目>/

# 验证配置
ls <目标项目>/CLAUDE.md <目标项目>/.claude/settings.local.json
```

---

## 三、Agent 与子代理体系

### 3.1 核心概念

子代理通过 **Agent 工具**（tool use）调用，拥有独立上下文，不污染主会话。在对话中描述需求，Claude Code 自动选择合适的 Agent 类型。可显式要求并行启动多个 Agent。

### 3.2 Agent 类型速查

#### 通用 Agent

| Agent | subagent_type | 用途 |
|-------|--------------|------|
| 通用编码 | `general-purpose` | 通用编码和查询 |
| 探索检索 | `Explore` | 只读检索、架构梳理、依赖分析 |
| 规划设计 | `Plan` | 方案设计、模块拆分、架构规划 |

#### Java 专项

| Agent | subagent_type | 用途 | 来源 |
|-------|--------------|------|------|
| 架构审查 | `java-core:java-architect` | 项目结构、分层架构 | java-core |
| 构建修复 | `java-core:java-build-resolver` | Maven/Gradle 编译错误 | java-core |
| Spring 专家 | `java-spring:java-spring-expert` | Spring Boot 深度问题 | java-spring |
| 安全审查 | `java-quality:java-security-reviewer` | OWASP、注入、配置安全 | java-quality |
| 性能审查 | `java-quality:java-performance-reviewer` | N+1、内存、线程安全 | java-quality |
| 测试工程 | `java-quality:java-test-engineer` | JUnit 5、Mockito、Testcontainers | java-quality |

#### 多语言审查 Agent

| Agent | 适用语言 |
|-------|---------|
| `ecc:go-reviewer` | Go |
| `ecc:rust-reviewer` | Rust |
| `ecc:python-reviewer` | Python |
| `ecc:typescript-reviewer` | TypeScript/JavaScript |
| `ecc:java-reviewer` | Java |
| `ecc:kotlin-reviewer` | Kotlin |
| `ecc:cpp-reviewer` | C++ |
| `ecc:csharp-reviewer` | C# |
| `ecc:flutter-reviewer` | Dart/Flutter |
| `ecc:swift-reviewer` | Swift |
| `ecc:django-reviewer` | Django |
| `ecc:fastapi-reviewer` | FastAPI |
| `ecc:database-reviewer` | SQL/数据库 |

#### 构建修复 Agent

| Agent | 适用场景 |
|-------|---------|
| `ecc:build-error-resolver` | TypeScript/通用 |
| `java-core:java-build-resolver` | Maven/Gradle |
| `ecc:go-build-resolver` | Go |
| `ecc:rust-build-resolver` | Rust cargo |
| `ecc:cpp-build-resolver` | C++ CMake |
| `ecc:kotlin-build-resolver` | Kotlin Gradle |
| `ecc:swift-build-resolver` | Swift/Xcode |
| `ecc:dart-build-resolver` | Dart/Flutter |
| `ecc:django-build-resolver` | Django 配置/迁移 |
| `ecc:pytorch-build-resolver` | PyTorch 运行时 |

#### 专项 Agent

| Agent | 用途 |
|-------|------|
| `ecc:code-reviewer` | 多维度代码审查 |
| `ecc:security-reviewer` | OWASP 安全扫描 |
| `ecc:silent-failure-hunter` | 静默失败检测 |
| `ecc:performance-optimizer` | 性能分析优化 |
| `ecc:e2e-runner` | E2E 测试（Playwright） |
| `ecc:doc-updater` | 文档和 codemap 更新 |
| `ecc:refactor-cleaner` | 死代码清理 |
| `ecc:comment-analyzer` | 注释质量分析 |
| `ecc:type-design-analyzer` | 类型设计分析 |
| `ecc:pr-test-analyzer` | PR 测试覆盖分析 |

### 3.3 按项目类型的 Agent 推荐

| 项目类型 | 首选 Agent 组合 | 使用时机 |
|----------|---------------|---------|
| **java-springboot** | `java-spring-expert` + `java-performance-reviewer` + `java-security-reviewer` | 审查阶段 |
| **react-umi / vite-react** | `typescript-reviewer` + `code-reviewer` | 审查阶段 |
| **nextjs** | `typescript-reviewer` + `code-reviewer` + `security-reviewer` | 审查阶段 |
| **monorepo** | 各子项目独立使用对应 Agent | 各子项目审查时 |
| **flutter-pos** | `flutter-reviewer` + `dart-build-resolver` | 审查 + 构建修复 |
| **miniprogram** | `typescript-reviewer`（utils 层） | 逻辑层审查 |

### 3.4 并行 Agent 调度

**命令**：`/dispatching-parallel-agents`

**典型并行模式：**

```
# 全栈项目：后端 + 前端 + E2E 可并行
Agent 1: java-quality:java-test-engineer → 后端测试
Agent 2: ecc:typescript-reviewer → 前端审查
Agent 3: ecc:e2e-runner → E2E 测试

# Monorepo 多子项目：各自独立
Agent 1: 处理 backend/ 中的 Java 变更
Agent 2: 处理 admin-web/ 中的 React 变更
Agent 3: 处理 miniprogram/ 中的小程序变更
```

**注意事项：**
- 有依赖关系的任务不能并行
- 并行 Agent 个数不宜超过 4-5 个
- 每个 Agent 有独立上下文，不共享对话记忆

---

## 四、Skill 与工作流体系

### 4.1 已安装 Skill 总览

10 插件共提供 280+ Skill，按用途分四大类：

#### 流程管理（Superpowers 必用）

| Skill | 用途 |
|-------|------|
| `/brainstorming` | 头脑风暴，探索 3+ 方案 |
| `/writing-plans` | 编写技术方案 |
| `/executing-plans` | 按计划逐步执行 |
| `/test-driven-development` | TDD 红-绿-重构 |
| `/requesting-code-review` | 提交代码审查 |
| `/receiving-code-review` | 处理审查反馈 |
| `/verification-before-completion` | 完成前验证 |
| `/finishing-a-development-branch` | 分支收尾 |
| `/dispatching-parallel-agents` | 并行代理调度 |
| `/subagent-driven-development` | 子代理驱动开发 |
| `/using-git-worktrees` | Git Worktree 工作流 |

#### GStack 角色（23 种）

| 类别 | 角色命令 |
|------|---------|
| **规划审查** | `/office-hours` `/plan-ceo-review` `/plan-eng-review` `/plan-design-review` |
| **实现审查** | `/review` `/codex` `/investigate` |
| **QA 测试** | `/qa` `/qa-only` |
| **发布部署** | `/ship` `/canary` `/land-and-deploy` |
| **安全** | `/cso` `/guard` `/careful` `/freeze` `/unfreeze` |
| **文档** | `/document-release` `/document-generate` |
| **记忆协作** | `/context-save` `/context-restore` `/learn` `/retro` |

#### Java 专项

| Skill | 用途 |
|-------|------|
| `/java-core:java-adr` `/java-core:java-review` `/java-core:java-clean-arch` | 架构决策/审查/整洁架构 |
| `/java-spring:java-scaffold` `/java-spring:java-jpa` `/java-spring:java-security` `/java-spring:java-crud` | 脚手架/JPA/安全/CRUD |
| `/java-quality:java-test` `/java-quality:java-security-check` `/java-quality:java-perf-check` | 测试/安全/性能 |

#### ecc 高频

| Skill | 用途 |
|-------|------|
| `ecc:code-review` | 多维度审查 |
| `ecc:security-scan` | OWASP 扫描 |
| `ecc:test-coverage` | 覆盖率分析 |
| `ecc:e2e-runner` | E2E 测试 |
| `ecc:performance-optimizer` | 性能优化 |
| `ecc:silent-failure-hunter` | 静默失败检测 |

### 4.2 按项目类型的 Skill 使用路径

| 项目类型 | 核心 Skill 路径 |
|----------|---------------|
| **java-springboot** | brainstorming → writing-plans → tdd → java-review + java-jpa → java-test → java-security-check → java-perf-check → ship |
| **react-umi** | brainstorming → writing-plans → plan-design-review → tdd → typescript-review → test-coverage → e2e-runner |
| **nextjs** | brainstorming → writing-plans → tdd → typescript-review + security-review → test-coverage → e2e-runner |
| **flutter-pos** | brainstorming → writing-plans → tdd → flutter-review → flutter-test → 真机测试 |
| **miniprogram** | brainstorming → writing-plans → tdd → 体验版测试 → 提交审核 |

---

## 五、MCP 服务体系

### 5.1 已安装 MCP（13 个）

| MCP Server | 核心工具 | 用途 |
|------------|---------|------|
| **Playwright** | browser_navigate/click/snapshot/screenshot 等 20+ | 浏览器自动化、E2E 测试 |
| **GitHub** | create_pr/issue/search_code/push_files 等 20+ | GitHub 全功能操作 |
| **db-analyzer** | explain_query/analyze_indexes/connections/table_bloat | PostgreSQL/MySQL 分析 |
| **jvm-diagnostics** | analyze_gc_log/heap_histo/thread_dump/diagnose_jvm | JVM 诊断 |
| **migration-advisor** | analyze_migration/detect_conflicts/generate_rollback/score_risk | DB 迁移风险分析 |
| **spring-boot-actuator** | analyze_health/metrics/env/beans | Spring Boot 运行时 |
| **redis-diagnostics** | analyze_memory/slowlog/clients/keyspace | Redis 诊断 |
| **claude-mem** | search/timeline/smart_search/outline/unfold | 记忆搜索、代码探索 |
| **Context7** (x2) | resolve-library-id/query-docs | 实时库/框架文档 |
| **exa** | web_search_exa/web_fetch_exa | Web 搜索 |
| **memory** | create_entities/open_nodes/search_nodes/read_graph | 知识图谱 |
| **sequential-thinking** | sequentialthinking | 结构化思维链 |

### 5.2 MCP 按项目类型推荐

| 项目类型 | 必备 MCP | 可选 MCP |
|----------|---------|---------|
| **java-springboot** | db-analyzer + jvm-diagnostics + migration-advisor + spring-boot-actuator | redis-diagnostics |
| **react-umi** | Playwright | - |
| **vite-react** | Playwright | - |
| **nextjs** | Playwright | db-analyzer + redis-diagnostics |
| **monorepo** | 按子项目需要 | - |
| **flutter-pos** | - | Playwright（Web 管理端） |
| **miniprogram** | - | - |

### 5.3 Context7 使用指南

> **重点** Context7 提供最新版本文档，比 AI 训练数据更准确。涉及库/框架 API 时主动使用。

在对话中自然描述即可触发：

```
"查一下 Next.js 15 的 Server Action 最新写法"
"查 Drizzle ORM 的 migrations 命令"
"查 Spring Boot 3.5 的 @Async 配置"
```

### 5.4 Playwright 使用场景（按项目类型）

| 项目类型 | Playwright 场景 |
|----------|---------------|
| **java-springboot** | 通过前端 E2E 间接验证后端 API |
| **react-umi / vite-react** | 列表搜索 → 表单提交 → 权限控制 → 响应式截图 |
| **nextjs** | SSR 渲染验证 → 客户端交互 → API Route → 错误边界 |
| **monorepo** | 全链路：后端 API → 前端页面 → 数据一致性 |

---

## 六、核心工作流

### 6.1 Superpowers 标准流水线

```
头脑风暴 → 制定计划 → TDD 实现 → 代码审查 → 验证完成 → 分支收尾
   ↓          ↓         ↓         ↓         ↓         ↓
 brainstorming  plan    tdd      review  verify   finishing
```

**按项目类型的关键差异：**

| 阶段 | java-springboot | 前端类 | nextjs | flutter-pos | miniprogram |
|------|:---:|:---:|:---:|:---:|:---:|
| 头脑风暴 | **重点** API 契约 + 数据模型 | **重点** 页面结构 + 权限 | **重点** Server/Client 边界 | **重点** 离线场景 | **重点** 分包 + 审核 |
| 计划 | DB 迁移 → Service → Controller | 路由 → API → 页面 | Schema → Server Action → 页面 | Model → Provider → Page | 注册页面 → 分包配置 |
| TDD | JUnit 5 + 真实 DB | Vitest + MSW | Vitest + 测试 DB | flutter test + mocktail | utils 纯函数 + 真机 |
| 审查 | java-review + jpa + security | typescript-reviewer | typescript-reviewer + security | flutter-review | 人工审查 |

### 6.2 planning-with-files 持久化规划

**命令**：`/planning-with-files:plan`

**三个核心文件：**

| 文件 | 用途 | 更新时机 |
|------|------|---------|
| `task_plan.md` | 任务清单，含依赖和验收标准 | 每个任务完成时 `[x]` |
| `findings.md` | 发现的问题、约束、风险 | 审查/安全/性能扫描后 |
| `progress.md` | 进度记录 | 每个任务完成时 + 验证通过时 |

### 6.3 TDD 工作流

**命令**：`/test-driven-development`

| 项目类型 | RED 写法 | GREEN 写法 | REFACTOR 重点 |
|----------|---------|-----------|-------------|
| **java-springboot** | JUnit 5 + `@DataJpaTest` | Entity + Mapper + Service | 提取常量、加 @Builder、补索引 |
| **react-umi** | RTL + MSW | 组件 + useRequest | 拆子组件、抽 hooks |
| **nextjs** | Vitest + MSW | Server Component + Action | Server/Client 边界优化 |
| **flutter-pos** | flutter test + mocktail | Provider + Widget | dispose 资源、容错 |

### 6.4 发布工作流

**命令序列：**
1. `/finishing-a-development-branch` — 分支收尾
2. `/document-release` — Release Notes
3. `/checkpoint` — 检查点
4. `/ship` — 一键发布
5. `/canary` — 金丝雀发布
6. `/guard` — 安全守护

---

## 七、高级能力

### 7.1 自主循环（ralph-loop）

**命令**：`/ralph-loop --max-iterations <n> --completion-promise "<目标>"`

大型多步骤任务自动迭代，每次循环后自动运行测试，失败自动修复。

**按项目类型的典型参数：**

| 项目类型 | max-iterations | completion-promise 示例 |
|----------|:---:|-----------|
| **java-springboot** | 10-20 | `mvn test 全部通过 && task_plan.md 所有任务 [x]` |
| **前端类** | 10-15 | `pnpm test && pnpm tsc --noEmit && pnpm build 全部通过` |
| **nextjs** | 10-20 | `pnpm test && pnpm build 全部通过` |
| **monorepo** | 20-50 | `所有子项目测试通过 && task_plan.md 所有任务 [x]` |
| **flutter-pos** | 10-20 | `flutter test && flutter analyze 全部通过` |

停止循环：`/cancel-ralph`

### 7.2 记忆系统（claude-mem）

- 跨会话自动记录：架构决策、修复过的 bug、项目偏好
- 新会话自动注入相关历史上下文
- 智能代码探索：`smart_search`（AST 级）、`smart_outline`（文件结构）、`smart_unfold`（展开符号）

**常用命令：**

| 命令 | 用途 | 使用时机 |
|------|------|---------|
| `/learn-codebase` | 学习整个代码库到记忆 | 接手新项目时 |
| `/mem-search <关键词>` | 搜索历史记忆 | 回顾历史决策 |
| `/smart-explore <符号>` | AST 级代码搜索 | 定位函数/类/接口 |
| `/how-it-works` | 记忆系统原理 | 了解系统 |
| `/timeline-report` | 时间线报告 | 回顾项目进展 |

### 7.3 Git Worktree 隔离开发

**命令**：`/using-git-worktrees`

```bash
claude --worktree feature-branch     # 命令行
# 对话中也可直接要求: "帮我在 worktree 里实现 X 功能"
```

适用场景：实验性改动、大规模重构、同时处理多个独立 feature。测试通过后合并，不通过直接丢弃。

### 7.4 会话管理高级技巧

| 能力 | 命令 | 说明 |
|------|------|------|
| 分叉会话 | `claude --fork-session --resume [id]` | 变不影响原会话 |
| 恢复历史 | `/resume` | 继续历史会话 |
| 检查点 | `/checkpoint` | 创建可回滚点 |
| 回滚 | `/rewind` | 回滚到检查点 |
| 压缩 | `/compact` | 释放 Token |
| 清空 | `/clear` | 切换任务重置 |
| 重命名 | `/rename` | 命名有意义 |
| 费用 | `/cost` | 查看会话费用 |

---

## 八、实战技巧

### 8.1 启动方式

| 方式 | 命令 | 适用场景 |
|------|------|---------|
| 正常启动 | `claude` | 日常 |
| 静默启动 | `claude --bare` | 大/老项目 |
| 单次问答 | `claude -p "问题"` | 快速查询 |
| 指定模型 | `claude --model sonnet` | 省钱 |
| 指定权限 | `claude --permission-mode acceptEdits` | 减少弹窗 |

### 8.2 成本控制

| 策略 | 说明 |
|------|------|
| `/compact` 压缩 | 长会话每 30-45 分钟一次 |
| `/clear` 重置 | 切换任务时用 |
| 子 Agent 分流 | Agent 用完销毁，不占主上下文 |
| `claude --model sonnet` | 简单任务用 Sonnet 省钱 |
| `claude -p "问题"` | 单次比交互省 Token |
| `/context` 监控 | 超 70% = 压缩信号 |

### 8.3 需求描述结构

```
任务：<做什么>
业务目标：<为什么>
上下文：<涉及的模块/文件/依赖>
约束：<技术限制、兼容要求、性能指标>
边界条件：<异常场景、兜底逻辑>
输出要求：<代码 + 测试 + 文档>
```

### 8.4 大项目上下文管理

1. 创建 `.claudeignore` 排除大目录
2. CLAUDE.md 精简到 150 行，详细规则分流
3. 用 Explore Agent 做代码探索（独立上下文）
4. 子任务用 Agent 分发
5. 定期 `/compact` + Memory 保存关键信息

### 8.5 按项目类型的补充技巧

| 项目类型 | **重点** 技巧 |
|----------|-------------|
| **java-springboot** | 改 Mapper XML 后 `mvn test -pl dao` 只跑该模块 |
| **react-umi / vite-react** | 新组件用 Playwright `browser_snapshot` 验证渲染 |
| **nextjs** | `pnpm build` 检查输出中的页面类型（○Static / λDynamic） |
| **monorepo** | 改共享类型后 `pnpm --filter <subproject> test` 只跑受影响项目 |
| **flutter-pos** | Model 变更后必须 `build_runner build` |
| **miniprogram** | npm 包更新后在微信开发者工具"构建 npm" |
| **session-logging** | 新 Hook 规则用 `bash -n` 语法检查后再部署 |

---

## 九、疑难解答

### 9.1 CLAUDE.md 规则不生效

| 原因 | 解决 |
|------|------|
| 超 200 行权重下降 | 精简到 150 行，分流到 Skills/Memory |
| 规则互相矛盾 | 检查冲突，统一定义 |
| 规则太模糊 | 改为具体指令 |
| 格式规则被忽略 | 用 ESLint/Prettier/checkstyle |
| 对话过长被压缩 | `/compact` 或 `/clear` |

### 9.2 启动慢/卡顿

1. `claude --bare` 跳过预扫描
2. 创建 `.claudeignore` 排除大目录
3. 检查 MCP 服务是否全部正常
4. `claude doctor` 检查

### 9.3 上下文爆满

1. `/compact` 压缩
2. `/clear` 重开
3. 复杂任务拆子 Agent
4. 长期项目用 Memory 保存关键信息

### 9.4 Hook 不触发

1. 事件名检查：`PreToolUse`（PascalCase），不是驼峰
2. 配置位置检查：`settings.json` 的 `hooks` 字段
3. `type` 必须为 `"command"`
4. `matcher` 正则检查：`"Edit|Write"`、`"Bash"`、`"Skill|Agent"`
5. 手动执行 Hook 命令确认无错误
6. 脚本需 `chmod +x`

### 9.5 权限弹窗太多

在 `.claude/settings.local.json` 按项目类型配置白名单：

```json
// java-springboot
{ "permissions": { "allow": ["Bash(mvn:*)", "Bash(git:*)", "Bash(docker:*)"] } }

// 前端类
{ "permissions": { "allow": ["Bash(pnpm:*)", "Bash(git:*)"] } }

// flutter-pos
{ "permissions": { "allow": ["Bash(flutter:*)", "Bash(dart:*)", "Bash(git:*)"] } }
```

权限模式：`default` / `acceptEdits` / `dontAsk`（慎用）/ `plan`（只读）。

### 9.6 MCP 连接失败

1. `claude mcp list` 查看状态
2. 检查 `.mcp.json` 中 `command` 和 `args`
3. 手动运行 MCP 命令测试
4. `claude --debug` 查看日志

### 9.7 Skill 找不到

1. `claude plugin list` 确认插件已安装
2. 输入 `/` 按 Tab 查看列表
3. 用户级 Skill 检查 `~/.claude/skills/` 文件
4. 重启 Claude Code

### 9.8 模型响应质量下降

| 原因 | 解决 |
|------|------|
| 上下文杂乱 | `/compact` |
| CLAUDE.md 臃肿 | 精简分流 |
| 多任务混杂 | `/clear` 重开 |
| Token 超限 | `/context` 检查 |

### 9.9 插件冲突

1. `claude plugin list` 确认已安装
2. 检查 hooks 是否冲突
3. 暂时禁用怀疑插件：`claude plugin disable <name>`

### 9.10 Memory 不记录

1. 检查 claude-mem 插件状态
2. 确认 memory MCP 服务正常
3. 查看面板：`http://localhost:37701`

### 9.11 自主循环不停止

1. `/cancel-ralph` 强制停止
2. 检查 `--max-iterations` 是否太小
3. 检查 `--completion-promise` 条件是否可达

### 9.12 Playwright 操作失败

1. 确认 MCP 正常
2. `npx playwright install chromium` 安装浏览器
3. 用 `browser_snapshot` 而非截图分析页面
4. 操作前 `browser_wait_for` 等待元素出现

### 9.13 常用速查

| 问题 | 命令 |
|------|------|
| 插件列表 | `claude plugin list` |
| MCP 状态 | `claude mcp list` |
| 环境健康 | `claude doctor` |
| Skill 列表 | `/` 按 Tab |
| 后台任务 | `/tasks` |
| 上下文占比 | `/context` |
| 费用 | `/cost` |
| 调试模式 | `claude --debug` |
| 指定模型 | `claude --model sonnet` |
| 记忆面板 | `http://localhost:37701` |

---

## 十、命令速查

### 10.1 启动命令

```bash
claude                              # 标准启动
claude --bare                       # 静默启动
claude -p "问题"                    # 单次问答
claude --model sonnet               # 指定模型
claude --permission-mode acceptEdits # 减少弹窗
claude --worktree [name]            # 隔离工作树
claude --debug                      # 调试模式
```

### 10.2 会话管理

```
/context /compact /clear /cost /resume /checkpoint /rewind /rename /tasks
```

### 10.3 开发流程（Superpowers 标准流水线）

```
/brainstorming → /writing-plans → /executing-plans → /test-driven-development
→ /requesting-code-review → /verification-before-completion → /finishing-a-development-branch
```

### 10.4 GStack 角色

```
/office-hours /plan-ceo-review /plan-eng-review /plan-design-review
/review /qa /ship /canary /cso /guard /document-release
```

### 10.5 Java 专项

```
/java-core:java-adr /java-core:java-review /java-core:java-fix
/java-spring:java-scaffold /java-spring:java-jpa /java-spring:java-security /java-spring:java-crud
/java-quality:java-test /java-quality:java-security-check /java-quality:java-perf-check
```

### 10.6 高级能力

```
/ralph-loop /learn-codebase /mem-search /smart-explore /dispatching-parallel-agents /using-git-worktrees
```

### 10.7 MCP 诊断触发

在对话中自然描述即可：

| 需求 | 对话示例 |
|------|---------|
| 慢查询 | "分析一下最近的慢查询" |
| 索引建议 | "检查缺失的索引" |
| 线程分析 | "分析这个线程 dump" |
| GC 分析 | "看看 GC 日志" |
| 迁移审查 | "审查这个 SQL 迁移的风险" |
| 健康检查 | "检查 Spring Boot 健康状态" |
| Redis 诊断 | "看看 Redis 内存使用" |
| 浏览器测试 | "打开 http://localhost:3000 截图" |

---

> **文档版本**: v2.0 | **更新日期**: 2026-05-21
> **v2.0 变更**: 按 10 种项目类型全面重构，新增核心工作流、Agent 完整体系、MCP 按类型推荐、高级能力（自主循环/记忆系统/Context7/并行Agent）、扩充疑难解答至 13 个问题、命令速查
