# React + TypeScript 开发规范

## 目录分层

```
src/
├── components/     # 复用组件 (PascalCase 文件名)
├── pages/          # 页面组件
├── hooks/          # 自定义 Hooks (use-xxx.ts)
├── services/       # API 调用层
├── stores/         # 状态管理 (Zustand/Jotai)
├── types/          # TypeScript 类型定义
├── utils/          # 工具函数
└── styles/         # 全局样式
```

## 命名规范

- 组件文件：PascalCase `UserCard.tsx`
- Hook 文件：camelCase `useUserData.ts`
- 工具函数：camelCase `formatDate.ts`
- 类型文件：camelCase `user.ts`
- 组件名：PascalCase `<UserCard />`
- 函数/变量：camelCase `getUserInfo`
- 常量：UPPER_SNAKE_CASE `API_BASE_URL`

## 技术栈推荐

- React 18+ + TypeScript
- Vite 构建
- TailwindCSS / CSS Modules 样式
- TanStack Query (React Query) 服务端状态
- Zustand 客户端状态
- React Router 路由
- Vitest + React Testing Library 测试

## 代码要求

- 每个组件单一职责，超过 200 行考虑拆分
- 使用 TypeScript 严格模式，禁止 `any`
- API 调用集中在 `services/` 层
- 组件 Props 定义接口并导出
- 优先使用函数组件 + Hooks
