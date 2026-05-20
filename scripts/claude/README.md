# Claude Code 项目配置模板包

本目录包含可直接复制到项目根目录 `.claude/` 或用户全局 `~/.claude/` 的配置模板。

## 目录说明

| 文件 | 用途 | 放置位置 |
|------|------|---------|
| `claude.md` | 项目行为规范（最高优先级） | 项目根目录 |
| `settings.local.json` | 权限白名单（覆盖全局） | 项目 `.claude/` |
| `skills/*.md` | 技术栈技能模板 | `~/.claude/skills/` |
| `hooks/README.md` | Hook 正确配置指南 | 参考文档 |
| `agents/README.md` | Agent 正确使用指南 | 参考文档 |
| `memory/memory.md` | 项目长期记忆模板 | `~/.claude/projects/<hash>/memory/` |

## 与原文档的修正差异

本配置包基于真实 Claude Code 配置格式编写，与原分享文档的主要差异：

1. **settings.json 键名** — 使用 `enabledPlugins`（对象）而非 `enablePlugins`（布尔）
2. **权限配置** — 使用 `permissions.allow/deny` 数组，而非自定义键名
3. **Hooks** — 是 Shell 命令在 settings.json 配置，非 JS 文件 module.exports
4. **Skill 调用** — 使用 `Skill` 工具或 `/skill-name`，非 `/skill use`
5. **Agent 调用** — 使用 `Agent` 工具 + `subagent_type`，非 `/agent xxx`
6. **无虚构目录** — 移除 `agents/`、`plugins-config/` 等实际不存在的标准目录

## 使用方式

```bash
# 复制项目级配置到目标项目
cp scripts/claude/claude.md <目标项目>/
cp scripts/claude/.mcp.json <目标项目>/
cp scripts/claude/settings.local.json <目标项目>/.claude/

# 复制技能模板到全局
cp scripts/claude/skills/*.md ~/.claude/skills/
```
