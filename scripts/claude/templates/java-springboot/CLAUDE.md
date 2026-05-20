# CLAUDE.md — Java SpringBoot 微服务项目

> **技术栈：** Spring Boot 3.5.11 + Spring Cloud + MyBatis Plus + MySQL + Redis + Nacos + Dubbo + XXL-Job + Kafka
> **构建工具：** Maven（多模块）

---

## 一、常用命令

```bash
# 编译
mvn clean compile -DskipTests

# 运行测试
mvn test
mvn test -pl module-name -Dtest=ClassName   # 单类测试

# 启动（开发环境，指定 Nacos 地址）
mvn spring-boot:run -pl module-name -Dspring-boot.run.profiles=dev

# 打包
mvn clean package -DskipTests

# 代码检查（如果配了 PMD/Checkstyle）
mvn pmd:check checkstyle:check

# Docker 构建（Jib 插件免 Dockerfile）
mvn compile jib:dockerBuild -pl module-name
```

## 二、项目结构约定

```
project-root/
├── common/                  # 公共模块：DTO、工具类、常量、异常定义
├── dao/                     # 数据访问层：Entity、Mapper、Mapper XML
├── service/                 # 业务逻辑层：Service、ServiceImpl
├── facade/                  # Dubbo 对外暴露的 RPC 接口
├── api/                     # 对外暴露的 HTTP 接口层：Controller
├── client/                  # 调用方模块：Feign Client、Dubbo Consumer
└── starter/                 # 启动模块：Application 主类、配置
```

## 三、架构分层与约定

### 3.1 分层职责
- **Controller** → 接收 HTTP 请求，参数校验，调用 Service，返回统一 `R<T>` 响应体
- **Service** → 业务逻辑，事务管理（`@Transactional`），调用 Mapper / 远程 RPC
- **Mapper** → 数据访问，单表 CRUD 用 BaseMapper，复杂查询走 XML
- **Facade** → Dubbo RPC 接口定义和实现，DTO 独立于内部模型

### 3.2 统一响应体
```java
// 所有 Controller 返回 R<T>
public class R<T> { int code; String msg; T data; }
// code=0 成功，非0 业务错误码
```

### 3.3 异常处理
- 业务异常：`BizException(code, msg)`，全局 `@RestControllerAdvice` 统一拦截
- 不要 catch 后只打日志不处理（吞异常），要么处理要么上抛

### 3.4 分层对象
| 对象 | 用途 | 位置 |
|------|------|------|
| Entity | 与数据库表一一映射 | dao 模块 |
| DTO | 服务间/模块间传输 | common 模块 |
| VO | 返回给前端 | common 模块 |
| Query | 接收查询参数 | common 模块 |
| Form | 接收表单提交 | common 模块 |

## 四、MyBatis Plus 规范

- 简单 CRUD 用 `BaseMapper<T>` 自带方法，复杂查询写 XML 中的 SQL
- 分页用 `IPage<T>` + 分页插件，Controller 接收 `pageNum/pageSize`
- 逻辑删除用 `@TableLogic` + `del_flag` 字段
- 创建/更新时间用 `@TableField(fill = ...)` + `MetaObjectHandler` 自动填充
- XML 中 SQL 不要用 `${}` 拼接用户输入，一律用 `#{}`

## 五、Redis 规范

- Key 命名：`项目:模块:业务:ID`，如 `gstack:user:session:123`
- 用 `StringRedisTemplate`，统一序列化
- 分布式锁用 Redisson，不要自己用 SETNX 实现
- 缓存过期时间加随机偏移防雪崩
- 每个 Key 必须设 TTL

## 六、Nacos + Dubbo 规范

- 配置文件命名：`${spring.application.name}-${profile}.yaml`
- 敏感配置走环境变量，不写死在配置文件
- `@DubboService` 注册，`@DubboReference(check = false)` 消费
- RPC 接口定义在 facade 模块，consumer 只依赖接口模块
- DTO 实现 `Serializable`，配超时、重试、熔断

## 七、XXL-Job 规范

- 用 `@XxlJob("taskName")` 注解，name 与调度中心一致
- 分片用 `XxlJobHelper.getShardIndex()/getShardTotal()`
- 日志用 `XxlJobHelper.log()` 输出到调度中心
- 任务必须幂等（可能重复执行）

## 八、Kafka 规范

- Topic：`项目.业务.事件类型`，如 `gstack.order.created`
- Consumer Group：`项目.模块.功能`
- 消息体 JSON，Consumer 保证幂等
- 生产端指定 key 保证分区有序

## 九、数据库规范（MySQL）

- 表名/列名：snake_case，复数形式
- 必须字段：`id`(BIGINT 自增)、`create_time`、`update_time`、`del_flag`
- 索引命名：`uk_字段`（唯一）、`idx_字段`（普通）
- 禁止外键约束（应用层保证一致性）
- 数据量大时禁止 `SELECT *`

## 十、安全要点

- Controller 参数校验 `@Valid` + JSR-303
- SQL 严禁拼接字符串（MyBatis `#{}` 已防注入，注意 XML 中 `${}` 危险）
- 敏感接口加限流（Sentinel）
- 日志不打印敏感信息（密码、手机号、身份证）

## 十一、测试

```bash
mvn test                          # 全量
mvn test -Dtest=UserServiceTest   # 单类
```

- Service 层 JUnit 5 + Mockito
- Mapper 层 `@MybatisPlusTest` 连真实数据库

## 十二、反模式

- ❌ Controller 里写业务逻辑 → 移到 Service
- ❌ Service 循环依赖 → 事件解耦
- ❌ 一个 Service 类超 500 行 → 拆
- ❌ 用 Lombok `@Data` → 用 `@Getter` `@Setter` 分别标注
- ❌ Controller 直接返回 Entity → 转 VO
- ❌ `catch Exception` 后 `e.printStackTrace()` → `log.error` + 上抛
- ❌ Redis Key 无 TTL → 必须设过期时间
