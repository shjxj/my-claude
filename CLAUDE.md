# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在此仓库中工作时提供指引。

## 工作区说明

当前工作区根目录为 `/opt/devs/projects/claude`，实际项目代码位于 `gstack/` 子目录。开发 gstack 项目时请先 `cd gstack`，并阅读 `gstack/CLAUDE.md` 了解完整的开发命令、架构和规范。

## 推荐安装的 Claude Code 增强工具

按优先级排列，覆盖编码规范、代码审查、长期记忆、浏览器自动化、多项目管理等场景。

### 一、前提条件

确保已安装 Claude Code 并可正常使用：
```bash
claude --version
```

### 二、核心开发技能（建议全部安装）

#### 1. Superpowers — 标准开发流水线
强制执行「头脑风暴 → 制定计划 → TDD → 代码审查」的完整开发流程。

```bash
# 在 Claude Code 对话中执行
/plugin install superpowers@claude-plugins-official
```

安装后可用的子命令：`/brainstorming`、`/writing-plans`、`/executing-plans`、`/test-driven-development`，代码审查在提交时自动触发。

#### 2. GStack — 多角色 AI 工程团队
模拟 CEO、架构师、工程师、设计师、QA、安全官等 23 种角色，用不同视角处理开发任务。

```bash
git clone https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

安装后在 Claude Code 对话中通过斜杠命令调用，例如：
- `/office-hours` — 产品头脑风暴
- `/plan-ceo-review` — CEO 视角战略审查
- `/plan-eng-review` — 架构方案审查
- `/review` — PR 代码审查
- `/qa` — 浏览器 E2E 测试
- `/ship` — 测试、审查、推送、创建 PR
- `/cso` — OWASP + STRIDE 安全审计

完整技能列表见安装后的 `/help` 输出。

#### 3. Code Review — 多维度自动化审查
从安全性、逻辑、性能、可维护性等维度审查代码。

Claude Code 已内置代码审查能力（提交时自动触发）。如需第三方增强审查规则：

```bash
mkdir -p ~/.claude/skills/code-review
# 将审查规则的 SKILL.md 放入该目录
```

使用方式：
```
请审查最近一次 git 提交的变更
```

#### 4. Security Guidance — 安全编码助手
实时检测 SQL 注入、XSS、命令注入等安全风险。该能力已内置于 Claude Code 默认行为中，可在项目 CLAUDE.md 中进一步强化：

```markdown
## 安全约束
- 所有 SQL 查询必须使用参数化查询
- 禁止将用户输入拼接到系统命令中
- 敏感信息（密钥、令牌）禁止写入代码或提交到仓库
```

### 三、长期记忆

#### 5. claude-mem — 跨会话记忆
让 Claude Code 记住之前的架构决策、修复过的 bug、项目偏好等，在新会话中自动加载。

```bash
npx claude-mem install
```

安装后自动工作，无需手动调用。查询历史时直接在对话中提问：
```
我们之前是怎么解决数据库连接池耗尽问题的？
```

### 四、领域专项技能

#### 6. frontend-design — 前端 UI 设计
生成更具美感和多样性的前端 UI 代码，支持玻璃态、工业风等多种设计风格。

通过 Skill 包或插件市场安装后，在对话中引用：
```
@frontend-design 请用玻璃态风格设计一个用户登录表单
```

#### 7. Agent Browser — 浏览器自动化
控制无头浏览器执行页面导航、点击、填表、截图等操作，用于 E2E 测试和现场验证。

```bash
# 在 Claude Code 对话中执行
/plugin install agent-browser
```

#### 8. Supabase + GitHub MCP
- **Supabase**：安全操作 Supabase 的最佳实践，包含 MCP 连接器
- **GitHub MCP**：让 Claude 管理 Issues、PR、搜索仓库

```bash
# GitHub MCP 安装（在 Claude Code 对话中执行）
/plugin install github-mcp
# 按提示完成 GitHub 账号授权
```

Supabase 技能安装：
```bash
npx skills add supabase/agent-skills
```
仓库: https://github.com/supabase/agent-skills，安装后根据 MCP 指引配置连接。

#### 9. Skill Creator — 自定义技能工厂
通过自然语言描述或示例，为团队创建私有工作流。

在对话中描述需求即可：
```
请帮我创建一个 skill，用于自动生成 React 组件的单元测试模板（含边界情况和错误态）
```

#### 10. Everything Claude Code — 181 技能合集
包含多代理、安全扫描、持续学习等能力的综合工程系统。Anthropic 黑客松冠军作品，150K+ stars。

仓库: https://github.com/affaan-m/everything-claude-code
安装: `/plugin marketplace add https://github.com/affaan-m/everything-claude-code && /plugin install ecc@ecc`

### 五、多实例管理与协作

#### 11. claude-projects — 项目集中管理
统一管理多个项目，用简单命令启动后台任务。

```bash
npm install -g claude-projects
```

```bash
ccode my-app "你的任务" --background
ccode list   # 查看后台任务状态
```

#### 12. ClaudeLink — 多实例实时通信
基于 MCP 的通信枢纽，让多个 Claude Code 实例之间收发消息，适用于前后端协同等场景。

```bash
npx claudelink init
# 重启 Claude Code 生效
```

#### 13. Agent Teams — 内置子代理系统
Claude Code 内置的 Subagents 功能，可创建子代理并行执行任务。

在对话中直接定义子代理：
```
创建一个子代理处理后端 API 文档生成，另一个子代理同步更新前端类型定义
```

#### 14. Git Worktree — 同仓库多分支隔离
为同一 Git 仓库创建独立工作树，避免多任务间的文件冲突。

```bash
claude --worktree
```

#### 15. ctx-link — 跨实例上下文共享
让多个项目的 Claude 实例（前后端等）共享项目语境。支持本地和云模式（Supabase）。

```bash
bun add -g ctx-link
claude mcp add --scope user ctx-link "$(which ctx-link)"
ctxl setup && ctxl init
```
npm: https://www.npmjs.com/package/ctx-link

#### 16. EZVibe — 可视化管理面板
本地 Web 界面，可视化管理和监控多个 Claude 实例。

```bash
npm install -g ezvibe
ezvibe start
```

#### 17. open-claude-remote — 远程监控
手机扫码配对，实时监控和控制 PC 终端的 Claude Code。支持 ANSI 色彩、多实例管理、钉钉通知。

```bash
npm install -g open-claude-remote
```
npm: https://www.npmjs.com/package/open-claude-remote

### 六、按场景推荐组合

| 场景 | 推荐组合 |
|------|---------|
| 新手入门 | Superpowers + claude-mem |
| 代码质量保障 | Code Review + Security Guidance + GStack |
| 前端开发 | frontend-design + Supabase + Agent Browser |
| 多项目管理 | claude-projects + Git Worktree + ctx-link |
| 团队协作 | ClaudeLink + Agent Teams + EZVibe |
| 全面武装 | 全部安装 + Everything Claude Code |

### 七、安装验证

在项目目录中启动 Claude Code，验证技能已生效：

```bash
cd 你的项目目录
claude
```

在对话中输入 `/help` 查看已安装的技能列表，或尝试调用一个斜杠命令确认生效。如果技能未出现，检查：
1. 技能目录是否存在且路径正确
2. SKILL.md 文件格式是否正确
3. 重启 Claude Code 使新技能生效
