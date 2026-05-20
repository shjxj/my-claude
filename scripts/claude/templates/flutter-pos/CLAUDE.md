# CLAUDE.md — Flutter POS 项目

> **技术栈：** Flutter 3 + Provider + Freezed + Dio + SharedPreferences + sqflite + json_serializable + build_runner
> **目标平台：** Android + iOS 手机/Pad 收银 POS

---

## 一、常用命令

```bash
flutter pub get                        # 安装依赖
flutter pub run build_runner build     # 生成 freezed + json_serializable 代码
flutter pub run build_runner watch     # 持续监听自动生成
flutter analyze                        # 静态分析
dart fix --apply                       # 自动修复
flutter test                           # 测试
flutter run                            # 启动
```

## 二、项目结构

```
lib/
├── main.dart                  # 入口：Provider 注入、路由
├── app.dart                   # MaterialApp 配置
├── models/                    # Freezed 数据模型 + .freezed.dart/.g.dart
│   └── order.dart
├── providers/                 # Provider 状态管理（一个文件一个 Provider）
│   ├── cart_provider.dart
│   └── order_provider.dart
├── services/                  # 业务逻辑 + 外部依赖封装
│   ├── api_client.dart        # Dio 封装
│   ├── order_service.dart
│   ├── database.dart          # sqflite
│   └── printer_service.dart   # POS 硬件
├── repositories/              # 数据仓库层：组合 api + local db
├── pages/
│   └── checkout/
│       ├── checkout_page.dart
│       └── widgets/           # 页面级子组件
├── widgets/                   # 全局复用组件
├── utils/                     # 常量、扩展方法
├── router/
└── theme/
```

## 三、数据模型（Freezed + json_serializable）

```dart
// lib/models/product.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    String? barcode,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
```

- `build_runner` 生成 `.freezed.dart` / `.g.dart`，**不要手改生成文件**
- 模型变更后必须重新 run `build_runner`

## 四、状态管理（Provider）

```dart
// lib/providers/cart_provider.dart
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  double get total => _items.fold(0, (s, i) => s + i.subtotal);

  void addItem(Product p, {int qty = 1}) {
    final idx = _items.indexWhere((i) => i.product.id == p.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + qty);
    } else {
      _items.add(CartItem(product: p, quantity: qty));
    }
    notifyListeners();
  }

  void removeItem(String id) { _items.removeWhere((i) => i.product.id == id); notifyListeners(); }
  void clear() { _items.clear(); notifyListeners(); }
}
```

- `notifyListeners()` 只在状态真正变化时调用
- 跨 Provider 依赖用 `ProxyProvider`
- 避免 `Provider.of<T>()` → 用 `context.watch<T>()` / `context.read<T>()`

## 五、依赖注入

```dart
// main.dart
void main() => runApp(
  MultiProvider(
    providers: [
      Provider(create: (_) => ApiClient()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
    ],
    child: const App(),
  ),
);
```

- 所有 Provider 在 `main.dart` 统一注册

## 六、网络请求（Dio）

```dart
// lib/services/api_client.dart（单例，通过 Provider 注入）
class ApiClient {
  late final Dio _dio;
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.addAll([
      LogInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer ${Storage.token}';
          handler.next(options);
        },
        onError: (e, handler) { /* 401→登录, 其他→上抛 */ handler.next(e); },
      ),
    ]);
  }
}
```

- 拦截器统一处理 token、日志、401
- 超时必须设

## 七、本地存储

### SharedPreferences（轻量配置：token、设置）
### sqflite（离线数据：订单暂存）

```dart
// 离线优先：网络断开 → 存 sqflite → 网络恢复自动同步
```

## 八、POS 专项注意

- **离线优先：** 订单断网时入 sqflite 队列，联网后自动同步
- **硬件集成：** 打印机、扫码枪、钱箱 → Platform Channel 调原生
- **事务性：** 扣库存+建订单+收款 必须原子化
- **按钮防抖：** 收银按钮 debounce，防重复扣款
- **金额：** 统一 `double`，展示格式化 2 位小数

## 九、测试

```bash
flutter test
flutter test test/cart_provider_test.dart
```

- Provider 写单元测试（不涉及 UI）

## 十、反模式

- ❌ `setState()` 到处散落 → 用 Provider
- ❌ 模型类手写 `fromJson/toJson` → 用 json_serializable + build_runner
- ❌ Dio 拦截器里直接 `Navigator.push` → 回调/事件
- ❌ Widget 里写业务逻辑 → 移到 Provider / Service
- ❌ 不处理 `dispose` → 记得释放资源
