# Claude Code 使用指南

> 涵盖配置规范、实战技巧、疑难解答 — 所有内容均已核验，可当前版本直接使用。

---

## 一、CLAUDE.md 配置规范

### 1.1 核心原则

- **CLAUDE.md 是全局行为准则**，不是项目百科、不是文档仓库、不是代码模板库
- **控制在 150 行以内**，超过 200 行后尾部指令在实际使用中容易权重下降。这不是官方硬性限制，而是社区反复验证的经验阈值
- **每次对话自动加载**，优先级最高

### 1.2 必须保留的内容

- 项目技术栈、框架、包管理器、构建工具
- 全局分层架构、核心目录职责
- 统一命名规范（组件/函数/常量）
- 项目启动/打包/测试的通用命令
- 全局安全红线和禁止行为

### 1.3 必须移出的内容

- 大段代码示例和业务模板
- 细分模块专属规则（下沉到子目录 CLAUDE.md）
- 冗长的接口清单、数据表结构
- 格式类规则（交给 ESLint/Prettier 等工具）
- 历史迭代记录和备注

### 1.4 五大分流策略

**策略 1：目录分级 CLAUDE.md**

全局只留极简主规则，细分规则下沉到子目录，进入对应目录时自动生效：

```
项目根目录
├── CLAUDE.md               （全局极简核心规则，<150 行）
├── src/
│   ├── CLAUDE.md           （源码通用规则）
│   ├── components/CLAUDE.md
│   ├── pages/CLAUDE.md
│   └── service/CLAUDE.md
└── tests/CLAUDE.md
```

**策略 2：长文本规则 → 做成 Skills**

将低频、篇幅长的规范放入 `.claude/skills/` 或 `~/.claude/skills/`，用时通过 `/skill-name` 调用，不占全局上下文。

**策略 3：跨项目技术栈规范 → 全局 Skills**

通用技术规范存入 `~/.claude/skills/`，多项目共享，不写入项目 CLAUDE.md。

**策略 4：强制规则 → Hooks 钩子**

需要强制执行的规则（拦截高危命令、写文件后触发格式化等）用 Hooks 实现。Hooks 在 `settings.json` 中以 Shell 命令方式配置，监听工具调用事件。比纯文字规则执行力更强。

**策略 5：业务约定 → Memory 长期记忆**

项目专属业务逻辑、流程、约束写入 Memory 系统，不占 CLAUDE.md 空间。

### 1.5 标准模板

```markdown
# 项目全局开发规范

## 技术栈
- 开发框架：
- 编程语言：
- 包管理工具：
- 构建工具：

## 项目分层
1. 入口层：启动入口
2. 业务层：核心逻辑
3. 工具层：公共方法
4. 测试层：测试代码

## 命名规范
- 组件/结构体：大驼峰
- 函数/变量：小驼峰
- 常量：全大写下划线

## 常用命令
- 本地启动：
- 项目打包：
- 运行测试：

## 全局约束
1. 业务代码必须加异常捕获和入参校验
2. 禁止修改依赖目录、构建产物、日志缓存
3. 禁止执行高危删除、提权类系统命令
4. 修改代码前分析依赖关系，避免全局报错
```

---

## 二、项目配置规范

### 2.1 配置文件层级

| 文件 | 位置 | 优先级 | 用途 |
|------|------|--------|------|
| `CLAUDE.md` | 项目根目录 | 最高 | 项目行为规范 |
| `settings.json` | `~/.claude/` | 全局 | 插件、Hook、MCP、权限 |
| `settings.local.json` | 项目 `.claude/` | 覆盖全局 | 项目级权限白名单 |
| `.mcp.json` | 项目根目录 | 覆盖全局 MCP | 项目级 MCP 配置 |
| `.claudeignore` | 项目根目录 | — | 忽略无需解析的文件 |

### 2.2 settings.json 关键配置

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "ecc@ecc": true
  },
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(npm:*)",
      "Bash(mvn:*)"
    ],
    "deny": [
      "Bash(rm:*)",
      "Bash(sudo:*)",
      "Write(/etc/*)",
      "Write(/usr/*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo '代码已修改'"
          }
        ]
      }
    ]
  }
}
```

**常见错误对照**：

| 错误写法 | 正确写法 |
|----------|----------|
| `"enablePlugins": true` | `"enabledPlugins": { "name@market": true }` |
| `"allowWriteDirs": [...]` | `"permissions": { "allow": [...], "deny": [...] }` |
| Hook 是 JS 文件 `module.exports` | Hook 是 `settings.json` 中的 `"type": "command"` |

### 2.3 .claudeignore

在项目根目录创建 `.claudeignore`，减少文件检索数量：

```
node_modules/
dist/
build/
.git/
logs/
cache/
venv/
.venv/
*.log
```

### 2.4 Hooks 配置详解

Hooks 监听 Claude Code 运行时事件，在事件前后执行 Shell 命令。**Hook 是事件驱动的被动响应，不能主动发起操作，只能绑定到具体事件。**

**完整事件列表**：

| 事件 | 触发时机 | 常用场景 |
|------|---------|---------|
| `PreToolUse` | 工具调用前 | 拦截高危命令、校验文件路径 |
| `PostToolUse` | 工具调用后 | 代码修改后触发格式化、提示审查 |
| `UserPromptSubmit` | 用户提交提示词 | 注入项目上下文 |
| `SessionStart` | 会话启动 | 环境检查、加载配置 |
| `SessionEnd` | 会话结束 | 清理临时文件 |
| `Stop` | Agent 停止响应 | 记录日志 |
| `Notification` | 系统通知 | 自定义通知行为 |
| `SubagentStart` | 子代理启动 | 子代理环境准备 |
| `SubagentStop` | 子代理结束 | 子代理结果处理 |
| `PreCompact` | 上下文压缩前 | 保存关键信息 |
| `PreMessageEnqueue` | 消息入队前 | 消息预处理 |

**Hook 脚本通过环境变量获取上下文**：

```javascript
// ~/.claude/hooks/validate-command.js
const command = process.env.CLAUDE_CODE_TOOL_INPUT || '';
const dangerPatterns = ['rm -rf', 'sudo', 'chmod 777', 'curl | sh'];

for (const pattern of dangerPatterns) {
  if (command.includes(pattern)) {
    console.error(`高危命令被拦截: ${pattern}`);
    process.exit(1);
  }
}
```

### 2.5 Skills 目录结构

```
~/.claude/skills/                    # 全局 Skills（跨项目共享）
├── go-microservice.md
├── java-springboot.md
├── react-ts.md
└── python-fastapi.md

项目/.claude/skills/                 # 项目级 Skills
├── api-docs.md
└── deploy-guide.md
```

Skills 是 Markdown 文件，通过 `Skill` 工具或 `/skill-name` 斜杠命令调用。

### 2.6 Agent 正确用法

子代理通过 **Agent 工具**（tool use）调用，而非 `/agent xxx` 斜杠命令。子代理拥有独立上下文，不污染主会话。

**常用 Agent 类型**：

| 类型 | `subagent_type` | 用途 |
|------|----------------|------|
| 通用 | `general-purpose` | 通用编码和查询 |
| 探索 | `Explore` | 只读检索、架构梳理、依赖分析 |
| 规划 | `Plan` | 方案设计、模块拆分 |
| 代码审查 | `ecc:code-reviewer` | 多维度代码审查 |
| 安全审查 | `ecc:security-reviewer` | OWASP 安全扫描 |
| 性能审查 | `java-quality:java-performance-reviewer` | N+1、内存、线程 |
| 测试工程 | `java-quality:java-test-engineer` | JUnit、Mockito、Testcontainers |
| 构建修复 | `ecc:build-error-resolver` | 编译错误诊断修复 |

**调用方式**：在对话中描述需求，Claude Code 自动选择合适的 Agent 类型。可显式要求并行 Agent。

### 2.7 MCP 配置

MCP（Model Context Protocol）连接外部服务。项目级配置在 `.mcp.json`，全局配置在 `settings.json` → `mcpServers`。

推荐按需安装的 MCP：

| MCP | 用途 |
|-----|------|
| Playwright | 浏览器自动化、UI 测试、截图 |
| GitHub | Issue/PR 管理、代码搜索 |
| db-analyzer | PostgreSQL/MySQL schema 分析、索引优化 |
| jvm-diagnostics | 线程 dump、GC 分析、死锁检测 |
| migration-advisor | Flyway/Liquibase 迁移风险分析 |
| spring-boot-actuator | 运行时健康检查、指标分析 |
| redis-diagnostics | Redis 内存、慢日志、连接分析 |

### 2.8 配置模板包

项目 `scripts/claude/` 提供可复用的配置模板，可直接复制到目标项目使用：

| 模板 | 用途 |
|------|------|
| `scripts/claude/claude.md` | 项目行为规范模板（通用） |
| `scripts/claude/settings.local.json` | 权限白名单模板（真实格式） |
| `scripts/claude/.mcp.json` | 项目级 MCP 配置模板 |
| `scripts/claude/skills/*.md` | 5 套技术栈规范（Go/Java/React/Vue3/Python） |
| `scripts/claude/hooks/README.md` | Hook 正确配置指南 |
| `scripts/claude/agents/README.md` | Agent 正确使用指南 |
| `scripts/claude/memory/memory.md` | 长期记忆模板 |

**分场景模板**（`scripts/claude/templates/`）：

| 模板目录 | 适用场景 |
|----------|---------|
| `global` | 通用项目基础配置 |
| `java-springboot` | Java Spring Boot 项目 |
| `react-umi` | React + Umi 项目 |
| `monorepo` | 大型 monorepo 项目 |
| `session-logging` | 会话日志系统（含 Hook 路由脚本） |
| `docs-config` | 文档型配置项目 |
| `flutter-pos` | Flutter 项目 |
| `wechat-miniprogram` | 微信小程序项目 |

```bash
# 快速部署到目标项目
cp scripts/claude/claude.md <目标项目>/
cp scripts/claude/settings.local.json <目标项目>/.claude/
cp scripts/claude/.mcp.json <目标项目>/

# 按场景使用模板
cp scripts/claude/templates/java-springboot/CLAUDE.md <目标项目>/
```

---

## 三、实战技巧

### 3.1 启动优化

**`--bare` 静默启动**：

```bash
claude --bare
```

跳过 hooks、LSP、插件同步、自动记忆、后台预加载、CLAUDE.md 自动发现。大型老旧项目启动显著加速。

**`-p` 单次问答**（非交互模式）：

```bash
claude -p "解释 src/main.go 的架构"
```

**`--worktree` 隔离工作树**：

```bash
claude --worktree feature-branch
```

创建 git worktree 隔离开发环境，主项目不受影响。

### 3.2 会话管理

| 命令 | 作用 | 使用时机 |
|------|------|---------|
| `/context` | 查看上下文占用比例 | 超 70% 时需压缩 |
| `/compact` | 压缩上下文释放 Token | 长会话每 30-45 分钟用一次 |
| `/clear` | 清空全部会话记忆 | 切换全新任务前 |
| `/cost` | 查看会话费用 | 随时 |
| `/stats` | 使用统计 | 随时 |
| `/resume` | 恢复历史会话 | 继续之前的工作 |
| `/checkpoint` | 创建检查点 | 重大改动前 |
| `/rewind` | 回滚到检查点 | 出错时 |
| `/rename` | 重命名会话 | 方便查找 |

### 3.3 规划模式

当任务较复杂时，Claude Code 会自动进入规划模式（内部使用 EnterPlanMode 工具）：先分析仓库、输出架构方案，人工确认后再编写代码。也可以主动告诉它"先出方案再写代码"。

### 3.4 批量操作

没有内置的 `/batch` 命令。批量重构的正确方式：在对话中用自然语言描述需求，Claude Code 使用 Edit 工具的 `replace_all` 或通过 Bash 批量处理。

> 示例：把 src/ 下所有 fetch 调用统一改成 axios

### 3.5 安全试错

- **Git Worktree**：`claude --worktree [name]` 创建隔离工作树，测试通过后合并，不通过直接丢弃
- **Fork Session**：`claude --fork-session --resume [id]` 分叉会话，变动不影响原会话

### 3.6 临时提问

没有 `/btw` 临时会话命令。推荐做法：
- 另开终端窗口运行 `claude` 做临时提问
- 使用 `claude -p "问题"` 单次问答

### 3.7 用对话修正而非手动改代码

AI 生成的代码有问题时，用自然语言描述修改需求让 AI 自主迭代，而非手动改代码。AI 能记住优化逻辑，后续生成更贴合预期。

### 3.8 版本更新

```bash
# 内置更新（推荐）
claude update

# npm 更新（如通过 npm 安装）
npm update -g @anthropic-ai/claude-code
```

### 3.9 需求标准化

编写需求时明确入参、出参、功能效果、校验规则。结构化描述模板：

```
任务：<做什么>
业务目标：<为什么>
上下文：<涉及的模块/文件/依赖>
约束：<技术限制、兼容要求、性能指标>
边界条件：<异常场景、兜底逻辑>
输出要求：<代码 + 测试 + 文档>
```

### 3.10 补充技巧

- **代码修改后自动提示审查**：配置 PostToolUse Hook，每次 Edit/Write 后自动触发
- **多任务并行**：使用 Agent 工具同时启动多个子代理处理独立任务
- **大项目优先探索**：改代码前先用 Explore Agent 梳理架构和依赖关系
- **分批迭代提交**：小功能分批编写、自测、提交，降低合并冲突风险
- **老项目重构**：Explore Agent 梳理全量旧逻辑 → 保留原有行为 → 按模块逐步重构 → 每模块全量回归测试

---

## 四、疑难解答

### 4.1 CLAUDE.md 规则不生效

**症状**：写的规范 AI 不遵守、部分指令被忽略

| 原因 | 解决 |
|------|------|
| 文件超过 200 行，尾部规则权重下降 | 按第一部分方案分流，精简到 150 行以内 |
| 规则互相矛盾 | 检查冲突指令，统一定义 |
| 规则太模糊（如"代码写好点"） | 改为具体指令，如"所有 public 方法加参数非空校验" |
| 格式类规则被忽略 | 格式规则用 ESLint/Prettier 管控，不写在 CLAUDE.md |
| 对话过长，早期规则被压缩 | `/compact` 压缩或 `/clear` 重开 |

### 4.2 启动慢/卡顿

**症状**：`claude` 启动后长时间无响应

1. 使用 `claude --bare` 跳过预扫描和插件同步
2. 创建 `.claudeignore` 排除 `node_modules`、`dist`、`build`、`.git` 等
3. 检查 `.mcp.json` 中是否有启动失败的 MCP 服务拖慢初始化
4. `claude doctor` 检查环境健康

### 4.3 上下文爆满

**症状**：`/context` 显示 80%+ 占用，AI 开始"失忆"

1. `/compact` 压缩上下文（保留关键信息，释放 Token）
2. `/clear` 清空重开（切换任务时用）
3. 复杂任务拆分为子 Agent，每个拥有独立上下文
4. 长期项目用 Memory 系统保存关键信息，不被压缩丢失

### 4.4 Hook 不工作

**症状**：配置了 Hook 但没有触发

**排查步骤**：

1. **检查事件名**：使用 `PreToolUse`/`PostToolUse` 等 PascalCase，不是 `onBeforeWriteFile` 等驼峰
2. **检查配置位置**：Hook 必须配置在 `settings.json` 或 `settings.local.json` 的 `hooks` 字段中
3. **检查 `type` 字段**：必须为 `"command"`
4. **检查 `matcher` 正则**：`"Edit|Write"` 匹配编辑工具，`"Bash"` 匹配终端。正则错误会导致不触发
5. **手动验证命令**：先在终端执行 Hook 的命令，确认无错误
6. **检查脚本权限**：Hook 脚本需要 `chmod +x` 可执行权限

### 4.5 权限弹窗太多

**症状**：每次操作都弹出确认窗口

在 `.claude/settings.local.json` 配置白名单：

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(npm:*)",
      "Bash(mvn:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Write(/etc/*)"
    ]
  }
}
```

权限模式：
- `default`：标准确认
- `acceptEdits`：自动接受编辑，其他确认
- `dontAsk`：不再弹窗询问（谨慎使用）
- `plan`：只读规划模式

启动时指定：`claude --permission-mode acceptEdits`

### 4.6 MCP 连接失败

**症状**：MCP 工具不可用或报错

1. `claude mcp list` 查看状态
2. 检查 `.mcp.json` 中 `command` 和 `args` 是否正确
3. 确认 MCP 服务进程是否正常启动
4. 检查超时设置（默认 30 秒，远程服务可能需要更长）
5. `claude --debug` 启动查看 MCP 连接日志

### 4.7 模型响应质量下降

**症状**：对话越长 AI 越"笨"，输出质量明显下降

| 原因 | 解决 |
|------|------|
| 上下文杂乱 | `/compact` 压缩，去掉无关历史 |
| CLAUDE.md 臃肿 | 精简 CLAUDE.md，分流到 Skills/Memory |
| 多任务混杂 | `/clear` 重开，一个会话专注一个任务 |
| Token 接近上限 | `/context` 检查，超 70% 立即压缩 |

### 4.8 Skill 找不到

**症状**：`/skill-name` 提示命令不存在

1. `ls ~/.claude/skills/` 检查文件是否存在
2. 检查文件名格式（小写加连字符，如 `go-microservice.md`）
3. 检查 frontmatter 格式是否正确
4. 重启 Claude Code 加载新 Skill
5. 输入 `/` 后按 Tab 查看已安装列表

### 4.9 常用速查

| 问题 | 命令 |
|------|------|
| 查看已安装插件 | `claude plugin list` |
| 查看 MCP 状态 | `claude mcp list` |
| 环境健康 | `claude doctor` 或 `/doctor` |
| Skill 列表 | 输入 `/` 按 Tab |
| 后台任务 | `/tasks` |
| 上下文占比 | `/context` |
| API 费用 | `/cost` |
| 调试模式 | `claude --debug` |
| 指定模型 | `claude --model sonnet` |
