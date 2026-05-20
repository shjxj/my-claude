# CLAUDE.md — 微信小程序项目

> **技术栈：** TypeScript 6.0.3 + 微信小程序原生 + TDesign Miniprogram
> **工具：** 微信开发者工具 + pnpm

---

## 一、常用命令

```bash
pnpm install                      # 安装依赖
pnpm lint                         # ESLint
pnpm tsc --noEmit                 # TypeScript 类型检查

# 安装 TDesign 等 npm 包后，必须在微信开发者工具中：
# 工具 → 构建 npm
```

## 二、项目结构

```
miniprogram/
├── app.ts             # 入口：注册 App、全局数据
├── app.json           # 全局配置：pages 路由、window、tabBar
├── app.less           # 全局样式
├── components/        # 全局组件（ts + wxml + less + json 四件套）
│   └── navbar/
│       ├── index.ts
│       ├── index.wxml
│       ├── index.less
│       └── index.json
├── pages/             # 页面目录
│   └── index/
│       ├── index.ts
│       ├── index.wxml
│       ├── index.less
│       └── index.json
├── utils/
│   ├── request.ts     # wx.request 封装
│   └── storage.ts     # 本地存储封装
├── constants/
├── types/
└── styles/
    └── variables.less
```

## 三、页面开发

### 3.1 页面注册
```json
// app.json — 所有页面必须在此注册，否则 404
{ "pages": ["pages/index/index", "pages/user/detail/index"] }
```

### 3.2 页面 ts
```typescript
Page({
  data: { user: null as API.User | null, loading: false },
  onLoad(options: { id: string }) {
    this.fetchUser(options.id);
  },
  async fetchUser(id: string) {
    const user = await api.getUser(id);
    this.setData({ user });    // 只传变更字段，不要全量
  },
});
```

### 3.3 页面 wxml
```xml
<view class="container">
  <t-avatar image="{{user.avatar}}" />
  <t-cell title="用户名" note="{{user.username}}" />
  <t-button theme="primary" bind:tap="onSubmit">提交</t-button>
</view>
```

## 四、TDesign 组件使用

在页面/组件的 `.json` 中声明：
```json
{
  "usingComponents": {
    "t-button": "tdesign-miniprogram/button/button",
    "t-cell": "tdesign-miniprogram/cell/cell",
    "t-avatar": "tdesign-miniprogram/avatar/avatar"
  }
}
```
- 全局复用的组件在 `app.json` 的 `usingComponents` 声明
- 优先用 TDesign，不要自己造轮子

## 五、网络请求

统一封装 `wx.request`：
```typescript
// utils/request.ts
function request<T>(options: RequestOption): Promise<T> {
  return new Promise((resolve, reject) => {
    wx.request({
      ...options,
      url: `${BASE_URL}${options.url}`,
      header: {
        'Authorization': wx.getStorageSync('token') || '',
      },
      success(res) { res.statusCode === 200 ? resolve(res.data as T) : reject(res); },
      fail: reject,
    });
  });
}
```
- token 自动注入，baseUrl 集中管理，不要在每个页面里直接 `wx.request`

## 六、本地存储

封装 `wx.getStorageSync/setStorageSync`，对象自动 `JSON.parse/stringify`

## 七、TypeScript

- strict 模式
- `type` 优先于 `interface`
- 页面 data 建议声明类型：`Page<PageData, OnLoadParams>({...})`

## 八、样式

- Less + rpx（750rpx=屏宽）
- 全局变量放 `styles/variables.less`
- TDesign CSS 变量做主题定制

## 九、性能

- `setData` 只传变更字段，不传整个 data
- 长列表用虚拟列表
- 图片懒加载、压缩
- 包体积：单分包 ≤ 2MB，总包 ≤ 20MB

## 十、安全

- 用户输入做校验和消毒（防 XSS）
- 密码不要明文传，先哈希
- openId / unionId 只在服务端处理
- 不要在 setStorageSync 存敏感信息（token 除外）

## 十一、反模式

- ❌ 页面 ts 文件超 500 行 → 提取到 utils/service
- ❌ `setData({ obj: {...this.data.obj} })` → 只传变更字段
- ❌ `wx.request` 到处散落 → 统一封装
- ❌ WXML 中 `{{}}` 做复杂计算 → 用 WXS 或 ts 预处理
- ❌ `wx.navigateTo` 超 10 层 → 超了用 `wx.redirectTo`

## 十二、工具配置

- `project.config.json`：`"es6": true`, `"enhance": true`
- `tsconfig.json`：`"target": "ES2020"`, `"lib": ["ES2020"]`
- 每个页面必须在 `app.json` 注册
