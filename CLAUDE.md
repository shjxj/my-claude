# CLAUDE.md — 文档/配置管理项目

> **项目定位：** Claude Code 配置管理中心
> **内容类型：** Shell 脚本 / Markdown 文档 / JSON 配置模板 / Hook 脚本

---

## 项目定位

Claude Code 配置与文档管理中心。不是可运行应用 — 无构建、无测试、无 lint。内容为 Shell 脚本、Markdown 文档、JSON 配置模板、Hook 脚本。

## 常用命令

```bash
# 运行安装脚本（幂等，可重复执行）
bash scripts/install.sh        # 核心能力一键安装 + 升级

# 验证安装状态
claude plugin list              # 已安装插件列表
claude plugin marketplace list  # 已配置市场源
claude mcp list                 # MCP 服务器状态
ls ~/.claude/skills/            # 用户级 Skill 目录

# 复制模板到目标项目
cp scripts/claude/claude.md <目标项目>/
cp scripts/claude/settings.local.json <目标项目>/.claude/
cp scripts/claude/.mcp.json <目标项目>/
```

## 目录结构

```
/opt/devs/projects/claude/
├── CLAUDE.md                  # 项目指令（本文件）
├── README.md                  # 对外能力总览
├── CLAUDE-INFO.md             # 当前环境信息快照
├── INSTALLED.md / INSTALLED-INFO.md  # 已安装能力清单 + 使用手册
├── develop.md                 # 开发方法论
├── scripts/
│   ├── install.sh             # 一键安装 + 升级（幂等）
│   └── claude/                # 可复用配置模板包
│       ├── claude.md          # 通用项目行为规范模板
│       ├── settings.local.json  # 权限白名单模板（真实格式）
│       ├── .mcp.json          # MCP 配置模板
│       ├── skills/            # 技术栈技能模板（Go/Java/React/Vue3/Python）
│       ├── templates/         # 分场景配置包（global/java-springboot/react-umi/etc.）
│       ├── hooks/README.md    # Hook 正确配置指南
│       ├── agents/README.md   # Agent 正确使用指南
│       └── memory/memory.md   # 长期记忆模板
```

## 模板体系

### 模板完备度三级
| 级别 | 文件 | 适用场景 |
|------|------|---------|
| 基础 | CLAUDE.md | 轻量项目 |
| 标准 | + settings.local.json | 常规项目 |
| 完整 | + .mcp.json + hooks | 大型项目 |

### 新增场景模板
在 `scripts/claude/templates/<场景名>/` 下创建，至少包含 `CLAUDE.md`，推荐加 `settings.local.json`。

### CLAUDE.md 模板内容约定
- 开头注明技术栈和版本
- 必备块：常用命令、项目结构、架构分层、安全要点
- 推荐块：代码模式示例、数据库规范、反模式
- 不写：已安装能力清单（占 token 且对 AI 无指导价值）

## 文档规范

- Markdown + 中文为主，术语用英文
- 代码块标注语言，表格对齐
- 文件名用反引号，目录结构用树形
- 关键纠正用 ❌ → ✅

## Shell 脚本规范

- `#!/bin/bash`（非 `#!/usr/bin/env bash`），函数 snake_case，变量 `${}` 包裹
- 路径加双引号
- 脚本必须幂等（可安全重复运行）
- 不硬编码密码/Token

## Git 规范

- 提交信息格式：`<类型>: <简述>`，类型为 docs/feat/fix/refactor/chore
- 不提交 `.DS_Store`、`.idea/` 用户配置
- 改模板后同步更新 README.md

## 关键纠正（模板包已修正）

常见教程中的以下写法不正确：
- ❌ `enablePlugins: true` → ✅ `enabledPlugins: { "name@market": true }`
- ❌ Hook 事件 `onBeforeWriteFile` → ✅ `PreToolUse`、`PostToolUse`、`SessionStart` 等
- ❌ Hook 是 JS module.exports → ✅ settings.json 中的 Shell 命令 `type: "command"`
- ❌ `/agent explore 需求` → ✅ 使用 `Agent` 工具 + `subagent_type` 参数
- ❌ 目录 `~/.claude/agents/`、`~/.claude/plugins-config/` → ✅ 实际不存在
