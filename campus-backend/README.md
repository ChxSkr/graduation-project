# 校园智慧生活 APP 后端服务

基于 **Spring Boot 3.2.5 + MyBatis-Plus + MySQL + JWT** 的校园智慧生活 APP 后端，为 HarmonyOS NEXT 前端提供 RESTful API。

## 一、技术栈

| 类别 | 选型 | 版本 |
|------|------|------|
| 框架 | Spring Boot | 3.2.5 |
| 语言 | Java | 17 |
| ORM | MyBatis-Plus | 3.5.5 |
| 数据库 | MySQL | 8.0+ |
| 数据源 | Druid | 1.2.22 |
| 认证 | JWT (jjwt) | 0.12.5 |
| 密码加密 | BCrypt（spring-security-crypto） | — |
| 工具 | Hutool / Lombok | 5.8.27 / — |
| 构建 | Maven | — |

## 二、项目结构

```
campus-backend/
├── pom.xml
└── src/main/
    ├── java/com/campus/life/
    │   ├── CampusLifeApplication.java        # 启动类
    │   ├── common/                           # 通用基础设施
    │   │   ├── Result.java                   # 统一响应包装
    │   │   ├── ResultCode.java               # 状态码枚举
    │   │   ├── PageResult.java               # 分页响应
    │   │   ├── BusinessException.java        # 业务异常
    │   │   └── GlobalExceptionHandler.java   # 全局异常处理
    │   ├── config/                           # 配置
    │   │   ├── WebMvcConfig.java             # 拦截器 + CORS
    │   │   ├── MybatisPlusConfig.java        # 分页插件 + 自动填充
    │   │   └── PasswordEncoderConfig.java    # BCrypt
    │   ├── interceptor/
    │   │   └── JwtInterceptor.java           # JWT 拦截器
    │   ├── utils/
    │   │   ├── JwtUtils.java                 # JWT 生成/解析
    │   │   └── UserContext.java              # ThreadLocal 用户上下文
    │   ├── entity/                           # 实体（7 张表）
    │   ├── mapper/                           # MyBatis-Plus Mapper
    │   ├── dto/                              # 请求/响应 DTO
    │   ├── service/                          # 业务接口 + 实现
    │   └── controller/                       # 6 个 Controller
    └── resources/
        ├── application.yml                   # 主配置
        ├── application-dev.yml               # 开发环境数据源
        └── db/init.sql                       # 数据库初始化脚本
```

## 三、模块与接口

| 模块 | Controller | 公开访问 | 主要接口 |
|------|-----------|---------|---------|
| 认证 | AuthController | ✅ | `/auth/login`、`/auth/register` |
| 用户 | UserController | ❌ | `/user/info` (GET/PUT)、`/user/password` (PUT) |
| 课程 | CourseController | ❌ | `/course/list`、`/course/listByDay`、`/course/listByWeek`、`/course/{id}` (GET/PUT/DELETE)、`/course` (POST) |
| 校园卡 | CampusCardController | ❌ | `/card/info`、`/card/recharge`、`/card/consume`、`/card/toggleLost`、`/card/records`、`/card/monthlySummary` |
| 资讯 | NewsController | ✅ | `/news/page`、`/news/categories`、`/news/{id}`、`/news/latest` |
| 失物招领 | LostFoundController | 列表/详情公开 | `/lostFound/list`、`/lostFound/detail/{id}`、`/lostFound/publish`、`/lostFound/complete/{id}`、`/lostFound/{id}` (DELETE) |

**统一响应格式**：

```json
{
  "code": 200,
  "message": "success",
  "data": { ... },
  "timestamp": 1720900000000
}
```

**分页响应格式**（`PageResult<T>`）：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [...],
    "total": 100,
    "current": 1,
    "size": 10,
    "pages": 10
  }
}
```

## 四、快速启动

### 1. 环境准备

- JDK 17+
- Maven 3.8+
- MySQL 8.0+

### 2. 初始化数据库

```bash
mysql -u root -p < src/main/resources/db/init.sql
```

脚本会自动创建 `campus_life` 数据库、7 张表，并插入测试数据：
- 2 个测试用户（学号 `2021001001` / `2021001002`，密码均为 `123456`）
- 4 个资讯分类、7 门课程、2 张校园卡、7 条消费记录、5 条资讯、4 条失物招领

### 3. 修改数据源配置（如需要）

编辑 [src/main/resources/application-dev.yml](src/main/resources/application-dev.yml) 中的 `url` / `username` / `password`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/campus_life?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: root
    password: root
```

### 4. 启动服务

```bash
# 方式一：Maven 命令行
mvn spring-boot:run

# 方式二：打包后运行
mvn clean package -DskipTests
java -jar target/campus-life.jar
```

或在 IDE 中直接运行 [CampusLifeApplication.java](src/main/java/com/campus/life/CampusLifeApplication.java)。

### 5. 验证服务

服务启动后默认监听 `http://localhost:8080/api`。

```bash
# 健康检查（公开接口）
curl http://localhost:8080/api/news/categories

# 登录获取 token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"studentId":"2021001001","password":"123456"}'

# 携带 token 访问受保护接口
curl http://localhost:8080/api/user/info \
  -H "Authorization: Bearer <your_token>"
```

## 五、认证机制

- **登录**：`POST /auth/login` 返回 `{ token, tokenPrefix, expiresIn, userInfo }`
- **请求鉴权**：所有非公开接口需在请求头携带 `Authorization: Bearer <token>`
- **Token 失效**：后端返回 401，前端应清除本地 token 并跳转登录页
- **有效期**：默认 7 天（`jwt.expiration` 配置项，单位毫秒）

## 六、前端对接说明

前端 API 配置位于 `Test_project/entry/src/main/ets/network/ApiConfig.ets`：

```typescript
static readonly BASE_URL: string = 'http://localhost:8080/api';
```

**真机/模拟器访问注意事项**：
- DevEco Studio 模拟器：`localhost` 通常可直达宿主机后端
- 真机调试：需将 `BASE_URL` 改为后端主机的局域网 IP，如 `http://192.168.1.100:8080/api`
- 设备需在 `module.json5` 中已声明网络权限（`ohos.permission.INTERNET`）

## 七、关键设计

### 1. 统一异常处理
通过 `@RestControllerAdvice` + `GlobalExceptionHandler` 捕获 `BusinessException` 与未知异常，统一转为 `Result<?>` 响应。

### 2. 自动填充字段
`MybatisPlusConfig` 中的 `MetaObjectHandler` 在插入/更新时自动写入 `createTime` / `updateTime`。

### 3. 逻辑删除
实体继承 `BaseEntity`，`deleted` 字段通过 `@TableLogic` 实现逻辑删除（0-未删 1-已删）。

### 4. 跨域
`WebMvcConfig.addCorsMappings` 允许所有来源、所有方法、携带凭证，预检请求缓存 1 小时。

### 5. 用户上下文
`JwtInterceptor` 在 `preHandle` 中解析 token 并将 `userId` / `studentId` / `name` 存入 `UserContext`（ThreadLocal），业务层通过 `UserContext.getCurrentUserId()` 获取当前用户，`afterCompletion` 中清理。

## 八、测试账号

| 学号 | 密码 | 姓名 |
|------|------|------|
| 2021001001 | 123456 | 张三 |
| 2021001002 | 123456 | 李四 |
