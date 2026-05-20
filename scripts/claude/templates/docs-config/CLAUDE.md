# CLAUDE.md — 文档/配置管理项目

> **项目定位：** Claude Code 配置管理中心
> **内容类型：** Shell 脚本 / Markdown 文档 / JSON 配置模板 / Hook 脚本

---

## 一、项目结构

```
/opt/devs/projects/claude/
├── CLAUDE.md                    # 项目级指令
├── README.md                    # 对外说明
├── INSTALLED.md                 # 能力清单
├── INSTALLED-INFO.md            # 使用手册
├── develop.md                   # 方法论
├── claude-code-guide.md         # 指南
├── scripts/
│   ├── install.sh               # 一键安装
│   ├── install-1.sh             # 覆盖分析+补装
│   └── claude/                  # 可复用模板包
│       ├── claude.md            # 通用模板
│       ├── .mcp.json            # MCP 模板
│       ├── settings.local.json  # 权限模板
│       ├── skills/              # 技术栈技能模板
│       ├── agents/              # Agent 说明
│       ├── hooks/               # Hook 指南
│       ├── memory/              # 长期记忆模板
│       └── templates/           # 分场景配置包
│           ├── global/
│           ├── java-springboot/
│           ├── react-umi/
│           ├── wechat-miniprogram/
│           ├── flutter-pos/
│           └── docs-config/
└── .claude/
    └── settings.local.json
```

## 二、常用操作

```bash
# 运行安装脚本（幂等）
bash scripts/install.sh
bash scripts/install-1.sh

# 验证安装
claude plugin list
claude mcp list
ls ~/.claude/skills/

# 新增场景模板
mkdir -p scripts/claude/templates/<name>
# 至少创建 CLAUDE.md，推荐 settings.local.json，按需 .mcp.json
```

## 三、模板文件规范

### 3.1 每个 `templates/<场景>/` 目录文件清单
| 文件 | 必选 | 用途 |
|------|------|------|
| `CLAUDE.md` | 是 | 该技术栈的规范/命令/架构 |
| `settings.local.json` | 推荐 | 项目级权限白名单 |
| `.mcp.json` | 按需 | 数据库/中间件诊断连接 |

### 3.2 CLAUDE.md 内容约定
- 开头注明技术栈和版本
- 必备块：常用命令、项目结构、架构分层、安全要点
- 推荐块：代码模式示例、数据库规范、反模式列表
- 不写：已安装能力清单（占 token 且对 AI 无指导价值）

### 3.3 模板完备度
| 级别 | 文件 | 场景 |
|------|------|------|
| 基础 | CLAUDE.md | 轻量项目 |
| 标准 | +settings.local.json | 常规项目 |
| 完整 | +.mcp.json + hooks | 大型项目 |

## 四、文档规范

- Markdown + 中文为主，术语英文
- 代码块标注语言，表格对齐
- 文件名用反引号，目录结构用树形
- 关键纠正用 ❌ → ✅

## 五、Shell 脚本规范

- `#!/bin/bash`，函数 snake_case，变量 `${}` 包裹
- 路径加双引号
- 脚本必须幂等
- 不硬编码密码/Token

## 六、Git 规范

```bash
# 提交信息：<类型>: <简述>
# 类型：docs / feat / fix / refactor / chore
```
- 不提交 `.DS_Store`、`.idea/` 用户配置
- 改模板后同步更新 README.md

## 七、反模式

- ❌ CLAUDE.md 罗列大量已安装能力（占 token，无 AI 指导价值）
- ❌ 模板硬编码密码/API Key
- ❌ CLAUDE.md 写成「给用户看的手册」→ 写给 AI 看
- ❌ 一个模板超 500 行 → 拆成命令/结构/规范
