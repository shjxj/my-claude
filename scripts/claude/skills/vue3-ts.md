# Vue 3 + TypeScript 开发规范

## 目录分层

```
src/
├── components/     # 复用组件 (PascalCase)
├── pages/          # 页面组件
├── composables/    # 组合式函数 (useXxx.ts)
├── services/       # API 调用层
├── stores/         # Pinia 状态管理
├── types/          # TypeScript 类型定义
├── utils/          # 工具函数
└── styles/         # 全局样式
```

## 命名规范

- 组件文件：PascalCase `UserCard.vue`
- Composable：`useXxx.ts`
- 工具函数：camelCase `formatDate.ts`
- 组件名：PascalCase `<UserCard />`
- 函数/变量：camelCase `getUserInfo`
- 常量：UPPER_SNAKE_CASE `API_BASE_URL`

## 技术栈推荐

- Vue 3.4+ + TypeScript
- Vite 构建
- Composition API + `<script setup>`
- Pinia 状态管理
- Vue Router 4 路由
- UnoCSS / TailwindCSS 样式
- TanStack Query (Vue Query) 服务端状态
- Vitest + Vue Test Utils 测试

## 代码要求

- 使用 `<script setup lang="ts">` 语法
- Props/Emits 使用 `defineProps` + `defineEmits` 并提供类型
- 每个组件单一职责，超过 300 行考虑拆分
- 严格模式 TypeScript，禁止 `any`
- API 调用集中在 `services/` 层
- 优先使用 Composables 封装可复用逻辑
