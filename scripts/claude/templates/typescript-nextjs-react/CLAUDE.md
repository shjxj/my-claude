# CLAUDE.md — TypeScript + Next.js + React 全栈项目

> **技术栈：** TypeScript 5.x + React 19 + Next.js 15.x (App Router)
> **包管理：** pnpm
> **样式：** Tailwind CSS + shadcn/ui

---

## 一、常用命令

```bash
pnpm install               # 安装依赖
pnpm dev                   # 开发启动（默认 :3000）
pnpm dev -- -p 3001        # 指定端口
pnpm build                 # 生产构建
pnpm start                 # 生产启动
pnpm lint                  # ESLint
pnpm tsc --noEmit          # TypeScript 类型检查
pnpm test                  # Vitest 测试
pnpm test -- --coverage    # 覆盖率
```

## 二、项目结构（App Router）

```
src/
├── app/                   # App Router 页面与 API 路由
│   ├── layout.tsx         # 根布局
│   ├── page.tsx           # 首页
│   ├── loading.tsx        # 全局加载态
│   ├── error.tsx          # 全局错误边界
│   ├── not-found.tsx      # 自定义 404
│   ├── (marketing)/       # Route Group（不影响 URL）
│   │   └── about/page.tsx
│   ├── dashboard/
│   │   ├── layout.tsx     # 嵌套布局
│   │   ├── page.tsx
│   │   └── loading.tsx    # 局部加载态
│   └── api/               # API Route Handlers
│       └── users/route.ts
├── components/            # 全局组件
│   └── ui/                # shadcn/ui 组件
├── hooks/                 # 自定义 Hooks（Client 端）
├── lib/                   # 工具、数据库、API 客户端
│   ├── db.ts              # 数据库连接（Prisma / Drizzle）
│   ├── auth.ts            # Auth.js / 鉴权逻辑
│   └── utils.ts           # 通用工具函数
├── services/              # 服务端数据操作（Server Actions 或用 lib/ 替代）
├── stores/                # Zustand（仅 Client 端全局状态）
├── types/                 # TS 类型定义
└── styles/                # 全局样式（Tailwind 配置即可）
```

## 三、Server Component vs Client Component

```tsx
// 默认 Server Component — 可以直接 async、读 DB、无 JS 下发
export default async function UsersPage() {
  const users = await db.user.findMany();
  return <UserList data={users} />;
}

// Client Component — 'use client' 在文件顶部
'use client';
import { useState } from 'react';

export function LoginForm() {
  const [email, setEmail] = useState('');
  return <form>...</form>;
}
```

**规则：**
- 组件树中尽量让 Server Component 做数据获取，Client Component 只做交互
- `'use client'` 边界下移：把需要交互的部分拆成独立 Client Component
- 不要为了用 hooks 把整页变 Client Component

## 四、路由与文件约定

| 文件 | 作用 |
|------|------|
| `page.tsx` | 页面 |
| `layout.tsx` | 布局（嵌套，状态保持） |
| `loading.tsx` | Suspense fallback（自动包裹 page） |
| `error.tsx` | Error Boundary（需 `'use client'`） |
| `not-found.tsx` | 自定义 404 |
| `route.ts` | API Route Handler（GET/POST/PUT/DELETE） |
| `middleware.ts` | 中间件（根目录 src/ 下） |

- 动态路由：`[id]` 目录，用 `params.id` 取值
- Catch-all：`[...slug]`
- Route Group：`(groupName)` 不影响 URL

## 五、数据获取

```tsx
// Server Component 直接获取
export default async function Page() {
  const data = await fetch('https://api.example.com/data'); // 自动缓存
  // 或直接调 Prisma/Drizzle
  const users = await db.user.findMany({ take: 10 });
  return <DataView data={users} />;
}
```

- Server Component 中 `fetch` 自动去重 + 缓存（Next.js 内置）
- Client Component 中用 TanStack Query + API Route 或 Server Action
- `next.config.ts` 配置 `images.remotePatterns` 放行外部图片
- 使用 `next/headers`、`next/navigation` 等 Next.js 内置，不用 browser API

## 六、Server Actions

```typescript
// src/app/actions/user.ts
'use server';
import { revalidatePath } from 'next/cache';

export async function updateUser(id: string, data: FormData) {
  // 服务端逻辑，直接操作 DB
  await db.user.update({ where: { id }, data: { name: data.get('name') } });
  revalidatePath('/users');
}
```

- Server Action 用于表单提交、数据变更
- `revalidatePath` / `revalidateTag` 做缓存失效
- 输入校验用 `zod`（服务端和客户端共用 schema）

## 七、鉴权（Auth.js / NextAuth v5）

- 中间件 `src/middleware.ts` 做路由保护
- `auth.ts` 中配置 providers、callbacks
- Server Component 用 `auth()` 取 session
- Client Component 用 `useSession()` hook
- API Route 用 `auth()` 或 middleware check

## 八、TypeScript

- strict 模式，禁止 `any`（`catch(e)` 除外），用 `unknown` + 类型守卫
- `type` 优先于 `interface`（除非需要 extends/implements）
- `useSearchParams()` 返回值用 `nullish coalescing` 兜底

## 九、样式

- Tailwind CSS — Utility-First
- shadcn/ui 的组件不要直接改源码，用 `className` 覆盖
- 响应式设计用 Tailwind 断点：`sm/md/lg/xl/2xl`
- 暗黑模式：`next-themes` + Tailwind `dark:` 前缀

## 十、测试

```bash
pnpm test                    # Vitest 跑全部
pnpm test -- --run           # 单次
```

- 组件测试用 Vitest + React Testing Library
- Server Actions / API 用 `NODE_ENV=test` + 真实或测试 DB
- 不要 mock `fetch` — 用 MSW

## 十一、部署

- 推荐 Vercel（零配置）或 Docker 自部署
- `pnpm build` → `pnpm start`（Node.js 服务器）
- 环境变量遵守 Next.js 命名：`NEXT_PUBLIC_` 前缀暴露给客户端
- 中间件只用 Edge 兼容 API（`NextResponse`、`NextRequest`）

## 十二、反模式

- ❌ Server Component 中用 `useState`/`useEffect` → 不会报错但无效
- ❌ 整页标记 `'use client'` → 把交互部分拆成小 Client Component
- ❌ `useEffect` 做数据获取 → 用 Server Component 或 TanStack Query
- ❌ 忘记 `priorty`/`sizes` 属性的 `<Image>` → 用 `next/image` 必须设置
- ❌ `auth()` 在 Client Component 中调用 → 用 `useSession()`
- ❌ `revalidatePath` 放在 try-catch 外面 → revalidate 只应在操作成功后执行
- ❌ 硬编码 API 地址 → 用环境变量 `NEXT_PUBLIC_*` + `process.env.*`
