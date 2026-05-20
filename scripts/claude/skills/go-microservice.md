# Go 微服务开发规范

## 目录分层

```
project/
├── cmd/            # 入口层，每个子目录一个 main.go
├── internal/       # 业务层，不对外暴露
│   ├── handler/    # HTTP/gRPC 处理层
│   ├── service/    # 业务逻辑层
│   ├── repository/ # 数据访问层
│   └── model/      # 领域模型
├── pkg/            # 公共工具层，可对外暴露
├── api/            # Protobuf/OpenAPI 定义
└── configs/        # 配置文件
```

## 命名规范

- 包名：小写单词，无下划线 (`userservice` 非 `user_service`)
- 函数：小驼峰 `getUserInfo`，导出函数大驼峰 `GetUserInfo`
- 结构体：大驼峰 `UserService`
- 接口：单方法接口 `-er` 后缀 (`Reader`, `Writer`)
- 常量：大驼峰或全大写蛇形

## 代码要求

- 依赖注入，便于测试
- 错误统一封装，使用 `fmt.Errorf("context: %w", err)` 传递上下文
- 日志标准化，使用 `slog` 或 `zerolog`
- 所有公开函数写单元测试
- Context 作为第一个参数传递

## 常用命令

```bash
go build ./...
go test ./...
go vet ./...
golangci-lint run
```
