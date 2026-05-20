# CLAUDE.md — 用户级全局配置

> **放置位置：** `~/.claude/CLAUDE.md`
> **作用域：** 对所有项目生效（项目级 CLAUDE.md 可覆盖）
> **更新频率：** 个人偏好稳定后很少改动

---

## 一、助手行为准则（必配）

### 1.1 语言与沟通
- 始终使用**中文**回复，代码/术语/命令行除外
- 回复简洁直接，不要啰嗦，不要用 emoji
- 每完成一个步骤给出一句话更新，不要沉默
- 遇到不确定时先问，不要猜测后直接动手

### 1.2 代码操作原则
- 优先编辑已有文件，不要随意创建新文件
- 不要添加我用不到的错误处理、fallback、验证逻辑
- 不要写注释说明代码做了什么 — 好的命名就够了；只有 WHY 不明显的才加一行注释
- 不要做"顺手重构"、"顺手清理" — 只做我要求的
- 三个相似的代码块 > 一个过早的抽象

### 1.3 安全底线
- 绝对不允许出现：SQL 注入、XSS、命令注入、路径遍历
- 敏感信息（密钥/密码/Token）必须走环境变量，绝不硬编码
- 用户输入必须校验和消毒
- 不要跳过 git hooks（--no-verify、--no-gpg-sign）
- 不要修改 git config
- 不要对 main/master 执行 force push

### 1.4 Git 规范
- 只有我明确要求时才 commit，不要主动提交
- 只有我明确要求时才 push
- Commit message 用中文，简洁描述"做了什么、为什么"
- 不要 git add -A / git add . — 始终指定具体文件
- 不要在 commit 中包含 .env / credentials / 大二进制文件

### 1.5 测试规范
- 写新功能或改 bug 时写测试，但我没要求时可以跳过
- 测试覆盖核心逻辑即可，不追求覆盖率数字
- 不要 mock 数据库（集成测试应该连真实 DB）

### 1.6 不确定时的行为
- 有多种方案时，简短列出选项和 trade-off 让我选，不要自行决定
- 需要执行破坏性操作时（删除文件/表/数据），先确认
- 运行不熟悉的 CLI 命令前，解释它做什么

---

## 二、编程风格偏好

### 2.1 通用
- 命名：Java/TypeScript/Dart 用 camelCase，Python 用 snake_case，常量用 UPPER_SNAKE
- 函数/方法尽量短小，单一职责
- 不用魔法数字，提取为命名常量
- 文件/类遵守单一职责

### 2.2 各语言偏好
| 语言 | 偏好 |
|------|------|
| Java | Lombok（禁止用 @Data，用 @Getter/@Builder 组合）、Stream API、Optional 避免 null |
| TypeScript | strict 模式、type 优先于 interface、避免 any、使用 optional chaining |
| Dart | Freezed 做不可变模型、Provider 做状态管理、dart fix 做格式化 |
| SQL | 关键字大写、表名/列名 snake_case、索引有明确命名 |
