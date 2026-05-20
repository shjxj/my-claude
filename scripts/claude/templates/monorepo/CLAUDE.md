# CLAUDE.md — Monorepo 父项目

> **项目类型：** 多子项目 Monorepo，包含 Java 后端、React 前端、小程序、Flutter 等多技术栈
> **包管理：** pnpm（前端/小程序）+ Maven（Java）+ Pub（Flutter）

---

## 一、子项目清单

| 子项目 | 路径 | 技术栈 | 端口 |
|--------|------|--------|------|
| backend | `backend/` | Spring Boot 3.5 + MyBatis Plus + Dubbo | 8080 |
| admin-web | `admin-web/` | React 19 + Umi Max + Antd 5 | 8000 |
| miniprogram | `miniprogram/` | 微信原生 + TDesign | - |
| pos-app | `pos-app/` | Flutter 3 + Provider | - |

> 子项目详细规范见各自目录下的 `CLAUDE.md`，处理子项目内任务时必须先读取对应的 CLAUDE.md。

## 二、工作原则

### 2.1 子项目识别
- 我说「后端」或「Java」→ 在 `backend/` 下操作
- 我说「后台」「管理端」「Admin」→ 在 `admin-web/` 下操作
- 我说「小程序」「微信」→ 在 `miniprogram/` 下操作
- 我说「POS」「Flutter」「App」→ 在 `pos-app/` 下操作
- 不明确时，先问我在哪个子项目

### 2.2 跨项目任务
- 涉及多个子项目时，逐一处理，一个子项目完成后再下一个
- 先改 API 提供方（后端），再改消费方（前端/小程序/Flutter）
- 跨项目共享的类型定义放在 `shared/types/`（如果存在）
- 改接口后，同步更新所有消费方的调用

### 2.3 操作范围
- 只在我指定的子项目目录内操作
- 不要跨子项目修改（改后端时不动前端代码，反之亦然）
- 根目录的公共配置（如 `pnpm-workspace.yaml`、`docker-compose.yml`）谨慎修改，先确认

## 三、项目目录结构

```
project-root/
├── CLAUDE.md                    # 本文件 — Monorepo 总纲
├── backend/                     # Java SpringBoot 后端
│   ├── CLAUDE.md                # 后端专项规范
│   ├── settings.local.json
│   ├── .mcp.json
│   └── pom.xml
├── admin-web/                   # React Umi 管理端
│   ├── CLAUDE.md
│   ├── settings.local.json
│   └── package.json
├── miniprogram/                 # 微信小程序
│   ├── CLAUDE.md
│   ├── settings.local.json
│   └── package.json
├── pos-app/                     # Flutter POS
│   ├── CLAUDE.md
│   ├── settings.local.json
│   └── pubspec.yaml
├── shared/                      # 跨项目共享（可选）
│   └── types/                   # 共享类型定义（DTO / 枚举）
├── docs/                        # 项目文档
├── scripts/                     # 构建/部署脚本
├── docker-compose.yml           # 本地基础设施（MySQL、Redis 等）
└── .gitignore
```

## 四、环境准备

```bash
# 1. 启动本地基础设施
docker-compose up -d

# 2. 按需初始化各子项目
# 后端
cd backend && mvn clean compile -DskipTests

# 管理端
cd admin-web && pnpm install && pnpm dev

# 小程序（在微信开发者工具中打开 miniprogram/ 目录）

# Flutter
cd pos-app && flutter pub get && flutter pub run build_runner build
```

## 五、跨项目约定

### 5.1 API 路径
- 后端统一前缀 `/api/v1/`
- 管理端代理 `/api` → `http://localhost:8080`
- 小程序通过 Nginx/网关访问，不直连后端

### 5.2 上下文传递
- HTTP Header `X-Request-Id` 全链路追踪
- 用户身份统一用 JWT token，Header `Authorization: Bearer <token>`

### 5.3 枚举/常量
- 跨项目共享的枚举（如订单状态、支付方式）在后端定义，前端/小程序/Flutter 各自维护一份映射
- 禁止跨项目 import 源码

### 5.4 错误码
- 后端统一 `code` 范围：0=成功，1xxx=参数错误，2xxx=业务错误，3xxx=认证/权限，9xxx=系统错误
- 前端统一拦截 `code !== 0`，展示 `msg`

## 六、Git 规范

```bash
# 分支命名
feature/子项目-功能简述    # feature/admin-user-list
fix/子项目-bug简述         # fix/backend-order-duplicate

# 提交信息
<子项目>: <类型> - <简述>
# 例：backend: feat - 新增用户导出接口
# 例：admin-web: fix - 修复分页重置问题
```

- 不同子项目的改动分 commit 提交，不混在一起
- PR 尽量单子项目，跨项目 PR 标题标注 `[backend] [admin-web]` 等

## 七、反模式

- ❌ 不读子项目 CLAUDE.md 就开始改代码
- ❌ 跨子项目在一个 commit 里混改
- ❌ 前端/小程序直连数据库（必须走后端 API）
- ❌ 在子项目间直接 import 共享代码（应该各自维护或走 shared/ 包）
- ❌ 改公共配置文件（docker-compose / CI）不告知
