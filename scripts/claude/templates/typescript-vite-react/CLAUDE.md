# CLAUDE.md — TypeScript + Vite + React SPA 项目

> **技术栈：** TypeScript 5.x + React 19 + Vite 6.x + React Router 7.x
> **包管理：** pnpm

---

## 一、常用命令

```bash
pnpm install               # 安装依赖
pnpm dev                   # 开发启动（默认 :5173）
pnpm build                 # 生产构建
pnpm preview               # 预览构建产物
pnpm lint                  # ESLint
pnpm tsc --noEmit          # TypeScript 类型检查
pnpm test                  # Vitest 测试
pnpm test -- --coverage    # 覆盖率
```

## 二、项目结构

```
src/
├── main.tsx              # 入口：ReactDOM.createRoot
├── App.tsx               # 根组件：路由 + 全局 Provider
├── vite-env.d.ts         # Vite 类型声明
├── components/           # 全局可复用组件
│   └── ui/               # 基础 UI 组件（Button、Input、Modal 等）
├── pages/                # 页面组件（按路由分组）
│   └── home/
│       ├── index.tsx
│       └── index.module.css
├── hooks/                # 自定义 Hooks
├── stores/               # Zustand stores
├── services/             # API 请求函数（按模块分文件）
├── utils/                # 工具函数
├── constants/            # 常量、枚举
├── types/                # TS 类型定义
└── styles/               # 全局样式 + CSS 变量
```

## 三、路由

```tsx
// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

<BrowserRouter>
  <Routes>
    <Route path="/" element={<Layout />}>
      <Route index element={<Home />} />
      <Route path="user/:id" element={<UserDetail />} />
      <Route path="*" element={<NotFound />} />
    </Route>
  </Routes>
</BrowserRouter>
```

- 路由守卫用 `ProtectedRoute` 包裹组件，检查 store 中 auth 状态
- `useNavigate()` 做跳转，不用 `window.location`

## 四、状态管理（Zustand）

```typescript
// src/stores/user.ts
import { create } from 'zustand';

interface UserState {
  user: User | null;
  setUser: (user: User) => void;
  logout: () => void;
}

export const useUserStore = create<UserState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
}));
```

- 全局共享状态 → Zustand
- 页面内状态 → `useState` / `useReducer`
- 服务端数据 → TanStack Query（`@tanstack/react-query`），不要手动 `useState` + `useEffect` + `fetch`

## 五、API 请求

```typescript
// src/services/user.ts
import { apiClient } from '@/utils/request';

export async function fetchUsers(params: UserQuery) {
  return apiClient.get<PageResult<User>>('/api/users', { params });
}
```

- 统一用 `apiClient`（axios 实例，统一 baseURL、拦截器、错误处理）
- `@/utils/request.ts` 中配置请求/响应拦截器 + token 注入
- API 返回类型定义在 `src/types/api.ts`

## 六、TypeScript

- strict 模式，禁止 `any`（`catch(e)` 除外），用 `unknown` + 类型守卫
- `type` 优先于 `interface`（除非需要 extends/implements）
- 使用 `optional chaining` (`?.`) 和 `nullish coalescing` (`??`)

## 七、样式

- CSS Modules（`*.module.css`）— 首选方案
- 若团队用 Tailwind CSS：Utility-First，复杂样式抽 `@apply`
- 优先用 Flexbox / Grid 布局，少写固定宽高
- CSS 变量定义主题色，不用硬编码颜色值

## 八、Vite 配置

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { '@': path.resolve(__dirname, 'src') },
  },
  server: {
    port: 3000,
    proxy: { '/api': { target: 'http://localhost:8080', changeOrigin: true } },
  },
});
```

## 九、测试（Vitest）

```bash
pnpm test                          # 跑全部
pnpm test -- --run --reporter=verbose  # 单次详细输出
```

- 用 Vitest + React Testing Library
- 组件测试覆盖交互路径，不用测实现细节
- 不要 mock `fetch` — 用 MSW（`msw`）模拟 API

## 十、构建与部署

- `pnpm build` 产物在 `dist/`，nginx 直出或部署到 CDN
- SPA 路由需要 nginx `try_files $uri /index.html`
- 环境变量用 `VITE_` 前缀：`import.meta.env.VITE_API_BASE`

## 十一、反模式

- ❌ `useEffect` 直接调 API 不处理竞态 → 用 TanStack Query
- ❌ 一个组件文件 500 行 → 拆成子组件 + 抽 hooks
- ❌ `any` 满天飞 → 定义类型
- ❌ 硬编码 API 地址 → 用 Vite proxy + 环境变量
- ❌ 把所有状态都扔进 Zustand → 先判断是全局还是局部
- ❌ 直接操作 DOM → 用 ref + React 方式
