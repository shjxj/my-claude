# Java Spring Boot 开发规范

## 目录分层

```
src/main/java/com/example/
├── controller/     # REST Controller 层
├── service/        # 业务逻辑层
│   └── impl/       # 实现类
├── repository/     # 数据访问层 (JPA Repository)
├── model/
│   ├── entity/     # JPA 实体
│   ├── dto/        # 数据传输对象
│   └── vo/         # 视图对象
├── config/         # Spring 配置类
├── exception/      # 全局异常处理
└── util/           # 工具类
```

## 命名规范

- 类名：大驼峰 `UserController`
- 方法名：小驼峰 `findUserById`
- 变量名：小驼峰 `userService`
- 常量：全大写蛇形 `MAX_RETRY_COUNT`
- 包名：全小写

## 代码要求

- Controller 只做参数校验和路由，不写业务逻辑
- Service 层写业务逻辑，注入 Repository
- 使用 `@Valid` / `@Validated` 做参数校验
- 全局异常处理 `@RestControllerAdvice`
- 使用 Lombok 减少样板代码
- 单元测试覆盖 Service 层核心逻辑
- 使用 `@Transactional` 管理事务

## 常用注解

| 注解 | 用途 |
|------|------|
| `@RestController` | REST 控制器 |
| `@Service` | 业务层 |
| `@Repository` | 数据层 |
| `@Entity` | JPA 实体 |
| `@Transactional` | 事务管理 |
