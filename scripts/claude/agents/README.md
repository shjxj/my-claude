# Agents 正确使用指南

## 原文档问题

原文档描述的 `/agent explore/plan/coding/review/test` 命令格式不准确。
Claude Code 的子代理通过 **`Agent` 工具** 调用，而非 `/agent` 斜杠命令。

## 真实的 Agent 类型

当前已安装的代理示例（取决于项目加载的插件）：

| Agent 类型 | 用途 | subagent_type |
|-----------|------|---------------|
| Explore | 只读代码检索、依赖分析 | `Explore` |
| Plan | 方案设计、模块拆分 | `Plan` |
| General | 通用编码、业务逻辑 | `general-purpose` |
| code-reviewer | 代码审查 (ecc) | `ecc:code-reviewer` |
| security-reviewer | 安全审查 (ecc) | `ecc:security-reviewer` |
| test-engineer | Java 测试 (java-quality) | `java-quality:java-test-engineer` |
| java-spring-expert | Spring Boot 专家 | `java-spring:java-spring-expert` |
| build-error-resolver | 构建错误修复 | `ecc:build-error-resolver` |

## 正确调用方式

在对话中描述需求，Claude Code 自动调用 `Agent` 工具：

```
"梳理整个项目分层架构"
→ Claude Code 调用 Agent(subagent_type='Explore')

"审查最近的代码修改"
→ Claude Code 调用 Agent(subagent_type='ecc:code-reviewer')
```

可显式要求并行 Agent：
> 并行启动 3 个 Agent：一个梳理架构、一个分析依赖、一个审查安全

## 自定义 Agent

目前 Claude Code 不通过 markdown 文件自定义 Agent。Agent 的能力由其定义插件决定。
可通过安装插件扩展 Agent 类型。

## 关键差异总结

| | 原文档（不准确） | 实际 |
|---|---|---|
| 调用方式 | `/agent explore 需求` | `Agent` 工具 + `subagent_type` 参数 |
| 自定义 Agent | `~/.claude/agents/*.md` | 由插件定义，非文件自定义 |
| Agent 类型 | 固定 5 种 | 取决于安装的插件（可达 50+） |
