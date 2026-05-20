# Python FastAPI 开发规范

## 目录分层

```
project/
├── app/
│   ├── api/         # 路由层（按资源拆分）
│   ├── services/    # 业务逻辑层
│   ├── models/      # SQLAlchemy 模型
│   ├── schemas/     # Pydantic 请求/响应 Schema
│   ├── repositories/# 数据访问层
│   └── core/        # 配置、依赖注入、中间件
├── tests/
├── alembic/         # 数据库迁移
└── main.py          # 入口
```

## 命名规范

- 文件名：snake_case `user_service.py`
- 类名：PascalCase `UserService`
- 函数/变量：snake_case `get_user_by_id`
- 常量：UPPER_SNAKE_CASE `MAX_PAGE_SIZE`
- 测试文件：`test_<module>.py`

## 技术栈推荐

- Python 3.11+
- FastAPI + Pydantic v2
- SQLAlchemy 2.0 (async)
- Alembic 迁移
- pytest + pytest-asyncio 测试
- httpx 异步 HTTP 测试
- Poetry / uv 依赖管理

## 代码要求

- 使用 async/await 异步端点
- Pydantic Schema 严格定义请求/响应类型
- 依赖注入使用 FastAPI `Depends`
- 全局异常处理 `@app.exception_handler`
- 数据库会话管理使用 contextmanager
- 所有端点写测试（正常/边界/错误态）
