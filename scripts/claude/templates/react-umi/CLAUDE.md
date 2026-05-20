# CLAUDE.md — React + Umi Max PC 端项目

> **技术栈：** TypeScript 6.0.3 + React 19 + @umijs/max + Antd 5 + @ant-design/pro-components
> **包管理：** pnpm

---

## 一、常用命令

```bash
pnpm install               # 安装依赖
pnpm dev                   # 开发启动（默认 :8000）
pnpm dev --port=8001       # 指定端口
pnpm build                 # 生产构建
pnpm lint                  # ESLint
pnpm tsc --noEmit          # TypeScript 类型检查
pnpm test                  # 测试
pnpm test -- --coverage    # 覆盖率
```

## 二、项目结构

```
src/
├── app.tsx              # 运行时配置：初始状态、布局、request 拦截器
├── access.ts            # 权限函数
├── global.less          # 全局样式
├── components/          # 全局组件（每组件一个目录）
│   └── Foo/
│       ├── index.tsx
│       └── index.less
├── pages/               # 页面 — 自动路由
│   └── user/
│       └── list/
│           ├── index.tsx
│           └── index.less
├── services/            # API 请求函数（按模块分文件）
├── models/              # 全局状态（@umijs/max 内置）
├── utils/               # 工具函数
├── constants/           # 常量、枚举
└── types/               # TS 类型定义
config/
├── config.ts            # Umi 配置
└── routes.ts            # 路由定义
```

## 三、路由

```typescript
// config/routes.ts
export default [
  {
    path: '/user',
    layout: false,              // 无布局（登录页）
    routes: [
      { path: '/user/login', component: './user/login' },
    ],
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    icon: 'DashboardOutlined',
    access: 'canViewDashboard',  // 权限控制
    component: './dashboard',
  },
];
```

## 四、页面开发

### 4.1 ProTable（列表）
```tsx
<ProTable<API.UserItem>
  columns={columns}
  request={async (params) => {
    const res = await fetchUsers(params);
    return { data: res.data, success: true, total: res.total };
  }}
  rowKey="id"
  search={{ labelWidth: 100 }}
  pagination={{ defaultPageSize: 20 }}
/>
```

### 4.2 ProForm（表单）
```tsx
<ProForm onFinish={async (values) => { await submitForm(values); }}>
  <ProFormText name="name" label="名称" rules={[{ required: true }]} />
</ProForm>
```

## 五、状态管理

- `src/models/` — 全局状态（`useModel('namespace')` 访问）
- 页面内状态 → `useState` / `useReducer`
- 表单状态 → 直接用 ProForm，不额外存 store
- 服务端数据 → `useRequest`（ahooks / Umi 内置），不要手动 `useState` + `useEffect` + `fetch`

## 六、API 请求

```typescript
// src/services/user.ts
import { request } from '@umijs/max';

export async function fetchUsers(params: API.UserQuery) {
  return request<API.PageResult<API.UserItem>>('/api/users', { params });
}
```

- 统一用 `request`（内置拦截器 + 错误处理）
- `app.tsx` 中配置 `errorHandler` 和 `requestInterceptors`
- API 返回类型统一定义在 `src/types/api.d.ts`

## 七、权限

```typescript
// src/access.ts
export default function access(initialState) {
  return {
    canAdmin: initialState?.currentUser?.role === 'admin',
  };
}

// 组件中
import { useAccess, Access } from '@umijs/max';
<Access accessible={useAccess().canAdmin} fallback={<div>无权限</div>}>
  <Button>删除</Button>
</Access>
```

## 八、TypeScript

- strict 模式，禁止 `any`（`catch(e)` 除外），用 `unknown` + 类型守卫
- `type` 优先于 `interface`（除非需要 extends/implements）
- API 类型在 `src/types/api.d.ts` 的 `declare namespace API` 下

## 九、Antd / ProComponents

- 列表页 → `ProTable`，小表格 → `Table`
- 表单页 → `ProForm`，弹窗表单 → `ModalForm`
- 全局布局 → `ProLayout`（app.tsx 配置）
- 日期 → `dayjs`（Antd 内置）
- 主题 → `config/config.ts` 的 `theme` 字段

## 十、样式

- Less + CSS Module（`.module.less`）
- 优先用 `Space` / `Flex` / `Row` / `Col` 布局，少写 CSS
- 覆盖 Antd 样式优先用 `ConfigProvider` 的 `theme.token`，而不是全局 CSS

## 十一、反模式

- ❌ `useEffect` 直接调 API 不处理竞态 → 用 `useRequest`
- ❌ 一个组件文件 1000 行 → 拆成子组件
- ❌ API 返回后手动 `setState` → 用 `useRequest` 的 `data`
- ❌ `any` 满天飞 → 定义类型
- ❌ 硬编码 API 地址 → 在 `config/config.ts` 配置 proxy
