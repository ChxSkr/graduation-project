# 校园智慧生活 APP 后端 API 文档

## 概述

基于 **Spring Boot 3.2.5 + MyBatis-Plus + MySQL + JWT** 的 RESTful API，为 HarmonyOS NEXT 前端提供后端服务。

- **Base URL**: http://localhost:8080/api
- **Content-Type**: pplication/json; charset=utf-8
- **日期格式**: yyyy-MM-dd HH:mm:ss (Asia/Shanghai)
- **序列化**: Jackson (null 值不返回)

---

## 认证机制

| 项目 | 说明 |
|------|------|
| 认证方式 | JWT (HMAC-SHA) |
| Token 前缀 | Bearer  |
| 请求头 | Authorization: Bearer <token> |
| 默认有效期 | 7 天 (604800000 ms) |
| 公开接口 | /auth/**, /public/**, /news/**, /lostFound/list, /lostFound/detail/** |

---

## 通用响应格式

### 成功响应

`json
{
  "code": 200,
  "message": "操作成功",
  "data": { ... },
  "timestamp": 1720900000000
}
`

### 分页响应 (data 为 PageResult)

`json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [ ... ],
    "total": 100,
    "current": 1,
    "size": 10,
    "pages": 10
  },
  "timestamp": 1720900000000
}
`

### 错误响应

`json
{
  "code": 400,
  "message": "请求参数错误",
  "data": null,
  "timestamp": 1720900000000
}
`

---

## 错误码

| 错误码 | HTTP状态 | 说明 |
|--------|----------|------|
| 200 | 200 | 操作成功 |
| 201 | 201 | 创建成功 |
| 204 | 204 | 无内容 |
| 400 | 400 | 请求参数错误 |
| 401 | 401 | 未登录或登录已过期 |
| 403 | 403 | 无权限访问 |
| 404 | 404 | 资源不存在 |
| 405 | 405 | 请求方法不允许 |
| 500 | 500 | 业务处理失败 / 服务器内部错误 |
| 1001 | 401 | 用户不存在 |
| 1002 | 401 | 密码错误 |
| 1003 | 403 | 账号已被禁用 |
| 1004 | 400 | 学号已存在 |
| 1005 | 404 | 校园卡不存在 |
| 1006 | 400 | 校园卡已挂失 |
| 1007 | 400 | 校园卡已冻结 |
| 1008 | 400 | 余额不足 |
| 1009 | 404 | 课程不存在 |
| 1010 | 404 | 资讯不存在 |
| 1011 | 404 | 失物招领信息不存在 |

---

## API 接口

---

### 一、认证模块 — /auth

所有接口无需登录。

#### 1.1 登录

`
POST /auth/login
`

**请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| studentId | String | 是 | 学号 |
| password | String | 是 | 密码 (6-32位) |

**响应 data** — LoginResponse:

| 字段 | 类型 | 说明 |
|------|------|------|
| token | String | JWT token |
| tokenPrefix | String | token 前缀 ("Bearer ") |
| expiresIn | Long | 有效期 (毫秒) |
| userInfo | UserInfoVO | 用户信息 |

**UserInfoVO**:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 用户ID |
| studentId | String | 学号 |
| name | String | 姓名 |
| college | String | 学院 |
| major | String | 专业 |
| grade | String | 年级 |
| avatar | String | 头像URL |
| phone | String | 手机号 |
| email | String | 邮箱 |

**示例**:

`ash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"studentId":"2021001001","password":"123456"}'
`

---

#### 1.2 注册

`
POST /auth/register
`

**请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| studentId | String | 是 | 学号 |
| password | String | 是 | 密码 (6-32位) |
| name | String | 是 | 姓名 |
| college | String | 否 | 学院 |
| major | String | 否 | 专业 |
| grade | String | 否 | 年级 |
| phone | String | 否 | 手机号 |
| email | String | 否 | 邮箱 |

**响应 data**: UserInfoVO

---

### 二、用户模块 — /user

所有接口需要登录。

#### 2.1 获取当前用户信息

`
GET /user/info
`

**请求头**: Authorization: Bearer <token>

**响应 data**: UserInfoVO

---

#### 2.2 修改用户信息

`
PUT /user/info
`

**请求头**: Authorization: Bearer <token>

**请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 否 | 姓名 |
| college | String | 否 | 学院 |
| major | String | 否 | 专业 |
| grade | String | 否 | 年级 |
| avatar | String | 否 | 头像URL |
| phone | String | 否 | 手机号 |
| email | String | 否 | 邮箱 |

**响应 data**: UserInfoVO

---

#### 2.3 修改密码

`
PUT /user/password
`

**请求体**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| oldPassword | String | 是 | 原密码 |
| newPassword | String | 是 | 新密码 (6-32位) |

---

### 三、课程模块 — /course

所有接口需要登录，课程数据按 userId 隔离。

#### 3.1 获取所有课程

`
GET /course/list
`

**响应 data**: List<Course>

**Course 实体**:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 主键 |
| userId | Long | 用户ID |
| name | String | 课程名称 |
| teacher | String | 授课教师 |
| classroom | String | 教室 |
| dayOfWeek | Integer | 星期几 (1-7) |
| startSection | Integer | 开始节次 (1-12) |
| endSection | Integer | 结束节次 (1-12) |
| weekStart | Integer | 起始周 (1-30) |
| weekEnd | Integer | 结束周 (1-30) |
| color | String | 课程卡片颜色 (如 "#1890FF") |
| credit | BigDecimal | 学分 |
| remark | String | 备注 |
| createTime | DateTime | 创建时间 |
| updateTime | DateTime | 更新时间 |

---

#### 3.2 按天查询课程

`
GET /course/listByDay?dayOfWeek=1&week=5
`

**请求参数**:

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| dayOfWeek | Integer | 是 | — | 星期几 (1-7) |
| week | Integer | 否 | 1 | 第几周 (1-30) |

**响应 data**: List<Course>

---

#### 3.3 按周查询课程

`
GET /course/listByWeek?week=5
`

**请求参数**:

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| week | Integer | 否 | 1 | 第几周 (1-30) |

**响应 data**: List<Course>

---

#### 3.4 获取课程详情

`
GET /course/{id}
`

**路径参数**: id — 课程ID

**响应 data**: Course

---

#### 3.5 新增课程

`
POST /course
`

**请求体**:

| 字段 | 类型 | 必填 | 约束 | 说明 |
|------|------|------|------|------|
| name | String | 是 | max 100 | 课程名称 |
| teacher | String | 否 | max 50 | 授课教师 |
| classroom | String | 否 | max 100 | 教室 |
| dayOfWeek | Integer | 是 | 1-7 | 星期几 |
| startSection | Integer | 是 | 1-12 | 开始节次 |
| endSection | Integer | 是 | 1-12 | 结束节次 |
| weekStart | Integer | 是 | 1-30 | 起始周 |
| weekEnd | Integer | 是 | 1-30 | 结束周 |
| color | String | 否 | — | 颜色 (默认 "#1890FF") |
| credit | BigDecimal | 否 | — | 学分 (默认 0) |
| remark | String | 否 | — | 备注 |

**响应 data**: Course

---

#### 3.6 修改课程

`
PUT /course/{id}
`

**路径参数**: id — 课程ID

**请求体**: 同 3.5 新增课程

**响应 data**: Course

---

#### 3.7 删除课程

`
DELETE /course/{id}
`

**路径参数**: id — 课程ID

---

### 四、校园卡模块 — /card

所有接口需要登录，数据按当前用户隔离。

#### 4.1 获取校园卡信息

`
GET /card/info
`

**响应 data** — CampusCard:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 主键 |
| userId | Long | 用户ID |
| cardNo | String | 卡号 |
| balance | BigDecimal | 余额 |
| userName | String | 持卡人姓名 |
| status | String | 状态: normal / frozen / lost |
| createTime | DateTime | 创建时间 |
| updateTime | DateTime | 更新时间 |

---

#### 4.2 充值

`
POST /card/recharge
`

**请求体**:

| 字段 | 类型 | 必填 | 约束 | 说明 |
|------|------|------|------|------|
| amount | BigDecimal | 是 | 0.01 ~ 10000 | 充值金额 |
| channel | String | 否 | — | 充值方式 (默认 "微信") |
| description | String | 否 | — | 描述 |

**响应 data**: CampusCard (更新后)

---

#### 4.3 消费

`
POST /card/consume
`

**请求体**:

| 字段 | 类型 | 必填 | 约束 | 说明 |
|------|------|------|------|------|
| amount | BigDecimal | 是 | >= 0.01 | 消费金额 |
| location | String | 是 | — | 消费地点 |
| description | String | 否 | — | 描述 |

**响应 data**: CampusCard (更新后)

---

#### 4.4 挂失 / 解挂

`
PUT /card/toggleLost
`

切换校园卡挂失状态 (normal ↔ lost)。

**响应 data**: CampusCard

---

#### 4.5 消费记录

`
GET /card/records?type=all
`

**请求参数**:

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| type | String | 否 | all | all / recharge / consume |

**响应 data** — List<CardRecord>:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 主键 |
| cardId | Long | 校园卡ID |
| userId | Long | 用户ID |
| amount | BigDecimal | 金额 (正=充值, 负=消费) |
| type | String | recharge / consume |
| location | String | 地点 |
| description | String | 描述 |
| recordTime | DateTime | 记录时间 |
| createTime | DateTime | 创建时间 |

---

#### 4.6 月度统计

`
GET /card/monthlySummary
`

**响应 data** — List<MonthlySummaryVO>:

| 字段 | 类型 | 说明 |
|------|------|------|
| month | String | 月份 |
| totalRecharge | BigDecimal | 当月充值总额 |
| totalConsume | BigDecimal | 当月消费总额 |

---

### 五、资讯模块 — /news

所有接口公开访问 (无需登录)。

#### 5.1 分页查询资讯

`
GET /news/page?current=1&size=10&categoryCode=all&keyword=
`

**请求参数**:

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数 |
| categoryCode | String | 否 | all | 分类编码 (all=全部) |
| keyword | String | 否 | — | 搜索关键词 |

**响应 data**: PageResult<News>

**News 实体**:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 主键 |
| title | String | 标题 |
| summary | String | 摘要 |
| content | String | 正文 |
| categoryCode | String | 分类编码 |
| coverImage | String | 封面图URL |
| author | String | 作者 |
| views | Integer | 阅读量 |
| status | Integer | 0=下架 / 1=上架 |
| publishTime | DateTime | 发布时间 |
| createTime | DateTime | 创建时间 |
| updateTime | DateTime | 更新时间 |

---

#### 5.2 获取所有分类

`
GET /news/categories
`

**响应 data** — List<NewsCategory>:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 主键 |
| code | String | 分类编码 |
| name | String | 分类名称 |
| sort | Integer | 排序 |
| createTime | DateTime | 创建时间 |

---

#### 5.3 获取资讯详情

`
GET /news/{id}
`

**路径参数**: id — 资讯ID

**响应 data**: News

---

#### 5.4 获取最新资讯

`
GET /news/latest?categoryCode=campus&limit=5
`

**请求参数**:

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| categoryCode | String | 否 | — | 分类编码 (不传=全部) |
| limit | Integer | 否 | 5 | 返回条数 |

**响应 data**: List<News>

---

### 六、失物招领模块 — /lostFound

- /lostFound/list 和 /lostFound/detail/{id} 公开访问
- 其余接口需要登录

#### 6.1 分页查询列表 (公开)

`
GET /lostFound/list?type=lost&category=all&keyword=&current=1&size=10
`

**请求参数**:

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数 |
| type | String | 否 | all | lost (丢失) / found (拾到) / all |
| category | String | 否 | all | 分类 (证件/电子产品/其他...) |
| keyword | String | 否 | — | 搜索关键词 |

**响应 data**: PageResult<LostFound>

**LostFound 实体**:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 主键 |
| userId | Long | 发布人ID |
| type | String | lost / found |
| title | String | 标题 |
| description | String | 描述 |
| location | String | 地点 |
| contact | String | 联系方式 |
| category | String | 分类 |
| images | String | 图片URL (逗号分隔) |
| status | String | active / completed |
| eventTime | DateTime | 事件发生时间 |
| publishTime | DateTime | 发布时间 |
| createTime | DateTime | 创建时间 |
| updateTime | DateTime | 更新时间 |

---

#### 6.2 我的发布列表 (需登录)

`
GET /lostFound/my?type=all&current=1&size=10
`

**请求参数**:

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数 |
| type | String | 否 | all | lost / found / all |

**响应 data**: PageResult<LostFound>

---

#### 6.3 获取详情 (公开)

`
GET /lostFound/detail/{id}
`

**路径参数**: id — 信息ID

**响应 data**: LostFound

---

#### 6.4 发布信息 (需登录)

`
POST /lostFound/publish
`

**请求体**:

| 字段 | 类型 | 必填 | 约束 | 说明 |
|------|------|------|------|------|
| type | String | 是 | — | lost / found |
| title | String | 是 | max 100 | 标题 |
| description | String | 是 | — | 描述 |
| location | String | 是 | — | 地点 |
| contact | String | 是 | — | 联系方式 |
| category | String | 否 | — | 分类 |
| images | List\<String\> | 否 | — | 图片URL数组 |
| eventTime | DateTime | 否 | — | 事件发生时间 (ISO字符串) |

**响应 data**: LostFound

---

#### 6.5 标记为已完成 (需登录)

`
PUT /lostFound/complete/{id}
`

**路径参数**: id — 信息ID

**响应 data**: LostFound (status = completed)

---

#### 6.6 删除 (需登录)

`
DELETE /lostFound/{id}
`

**路径参数**: id — 信息ID

---

## 测试账号

| 学号 | 密码 | 姓名 |
|------|------|------|
| 2021001001 | 123456 | 张三 |
| 2021001002 | 123456 | 李四 |

---

## 项目结构

`
campus-backend/
├── pom.xml
└── src/main/
    ├── java/com/campus/life/
    │   ├── CampusLifeApplication.java    # 启动类
    │   ├── common/                       # 通用基础设施
    │   │   ├── Result.java               # 统一响应包装
    │   │   ├── ResultCode.java           # 状态码枚举
    │   │   ├── PageResult.java           # 分页响应
    │   │   ├── BusinessException.java    # 业务异常
    │   │   └── GlobalExceptionHandler.java # 全局异常处理
    │   ├── config/                       # 配置
    │   │   ├── WebMvcConfig.java         # 拦截器 + CORS
    │   │   ├── MybatisPlusConfig.java    # 分页插件 + 自动填充
    │   │   └── PasswordEncoderConfig.java # BCrypt
    │   ├── interceptor/
    │   │   └── JwtInterceptor.java       # JWT 认证拦截器
    │   ├── utils/
    │   │   ├── JwtUtils.java             # JWT 生成/解析
    │   │   └── UserContext.java          # ThreadLocal 用户上下文
    │   ├── entity/                       # 数据实体 (7张表)
    │   ├── mapper/                       # MyBatis-Plus Mapper
    │   ├── dto/                          # 请求/响应 DTO
    │   ├── service/                      # 业务接口 + 实现
    │   └── controller/                   # 6 个 Controller
    └── resources/
        ├── application.yml               # 主配置
        ├── application-dev.yml           # 开发环境数据源
        └── db/init.sql                   # 数据库初始化脚本
`

## 数据库表

| 表名 | 说明 |
|------|------|
| sys_user | 用户表 |
| course | 课程表 |
| campus_card | 校园卡表 |
| card_record | 校园卡消费记录表 |
| news | 资讯表 |
| news_category | 资讯分类表 |
| lost_found | 失物招领表 |

## 技术栈

| 类别 | 选型 | 版本 |
|------|------|------|
| 框架 | Spring Boot | 3.2.5 |
| 语言 | Java | 17 |
| ORM | MyBatis-Plus | 3.5.5 |
| 数据库 | MySQL | 8.0+ |
| 数据源 | Druid | 1.2.22 |
| 认证 | JWT (jjwt) | 0.12.5 |
| 密码加密 | BCrypt | — |
| 工具 | Hutool / Lombok | 5.8.27 |
| 构建 | Maven | 3.8+ |
