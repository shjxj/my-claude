# Hooks 正确配置指南

## 原文档问题

原文档描述的 `onBeforeWriteFile`、`onCommandRun` 等事件名 **不是真实的 Claude Code Hook 事件**。
Hook 也不是通过 JS 文件 `module.exports` 实现的，而是 **在 settings.json 中配置 Shell 命令**。

## 真实的 Hook 事件

Claude Code 支持以下生命周期事件（版本 v1.0+）：

| 事件 | 触发时机 |
|------|---------|
| `PreToolUse` | 工具调用前 |
| `PostToolUse` | 工具调用后 |
| `UserPromptSubmit` | 用户提交提示词时 |
| `SessionStart` | 会话启动时 |
| `SessionEnd` | 会话结束时 |
| `Stop` | Agent 停止响应时 |
| `Notification` | 系统通知时 |
| `SubagentStart` | 子代理启动时 |
| `SubagentStop` | 子代理结束时 |
| `PreCompact` | 上下文压缩前 |
| `PreMessageEnqueue` | 消息入队前 |

## 正确配置方式

在 `~/.claude/settings.json` 或项目 `.claude/settings.local.json` 中配置：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo '代码已修改，建议进行代码审查'"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/hooks/validate-command.js"
          }
        ]
      }
    ]
  }
}
```

## Hook 脚本示例

Hook 脚本通过环境变量获取上下文信息：

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

## 关键差异总结

| | 原文档（错误） | 实际 |
|---|---|---|
| 配置方式 | 独立 JS 文件 `module.exports` | settings.json 内 `hooks` 字段 |
| 事件名 | `onBeforeWriteFile` 等驼峰命名 | `PreToolUse` 等 PascalCase |
| Hook 类型 | JS 函数 | Shell 命令 (`type: "command"`) |
| 存储位置 | `~/.claude/hooks/*.js` | 在 settings.json 中内联 |
