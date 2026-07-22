-- ============================================================
-- 校园智慧生活 APP 数据库初始化脚本
-- 数据库：campus_life
-- 字符集：utf8mb4
-- ============================================================

DROP DATABASE IF EXISTS campus_life;
CREATE DATABASE campus_life DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE campus_life;

-- ------------------------------------------------------------
-- 1. 用户表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `student_id`  VARCHAR(20)  NOT NULL                COMMENT '学号',
    `password`    VARCHAR(100) NOT NULL                COMMENT '密码（BCrypt 加密）',
    `name`        VARCHAR(50)  NOT NULL                COMMENT '姓名',
    `college`     VARCHAR(100) DEFAULT NULL            COMMENT '学院',
    `major`       VARCHAR(100) DEFAULT NULL            COMMENT '专业',
    `grade`       VARCHAR(20)  DEFAULT NULL            COMMENT '年级',
    `avatar`      VARCHAR(255) DEFAULT NULL            COMMENT '头像URL',
    `phone`       VARCHAR(20)  DEFAULT NULL            COMMENT '手机号',
    `email`       VARCHAR(100) DEFAULT NULL            COMMENT '邮箱',
    `status`      TINYINT      NOT NULL DEFAULT 1      COMMENT '账号状态：0-禁用 1-正常',
    `deleted`     TINYINT      NOT NULL DEFAULT 0      COMMENT '逻辑删除：0-未删 1-已删',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_student_id` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ------------------------------------------------------------
-- 2. 课程表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
    `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id`       BIGINT       NOT NULL                COMMENT '用户ID',
    `name`          VARCHAR(100) NOT NULL                COMMENT '课程名称',
    `teacher`       VARCHAR(50)  DEFAULT NULL            COMMENT '授课教师',
    `classroom`     VARCHAR(100) DEFAULT NULL            COMMENT '教室',
    `day_of_week`   INT          NOT NULL                COMMENT '星期几：1-7',
    `start_section` INT          NOT NULL                COMMENT '开始节次：1-12',
    `end_section`   INT          NOT NULL                COMMENT '结束节次：1-12',
    `week_start`    INT          NOT NULL                COMMENT '起始周',
    `week_end`      INT          NOT NULL                COMMENT '结束周',
    `color`         VARCHAR(20)  DEFAULT '#1890FF'      COMMENT '课程卡片颜色',
    `credit`        DECIMAL(3,1) DEFAULT 0               COMMENT '学分',
    `remark`        VARCHAR(255) DEFAULT NULL            COMMENT '备注',
    `deleted`       TINYINT      NOT NULL DEFAULT 0      COMMENT '逻辑删除',
    `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- ------------------------------------------------------------
-- 3. 校园卡表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `campus_card`;
CREATE TABLE `campus_card` (
    `id`          BIGINT         NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT         NOT NULL                COMMENT '用户ID',
    `card_no`     VARCHAR(30)    NOT NULL                COMMENT '卡号',
    `balance`     DECIMAL(10,2)  NOT NULL DEFAULT 0      COMMENT '余额',
    `user_name`   VARCHAR(50)    NOT NULL                COMMENT '持卡人姓名',
    `status`      VARCHAR(10)    NOT NULL DEFAULT 'normal' COMMENT '状态：normal/frozen/lost',
    `deleted`     TINYINT        NOT NULL DEFAULT 0,
    `create_time` DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_id` (`user_id`),
    UNIQUE KEY `uk_card_no` (`card_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园卡';

-- ------------------------------------------------------------
-- 4. 校园卡消费记录表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `card_record`;
CREATE TABLE `card_record` (
    `id`          BIGINT         NOT NULL AUTO_INCREMENT,
    `card_id`     BIGINT         NOT NULL                COMMENT '校园卡ID',
    `user_id`     BIGINT         NOT NULL                COMMENT '用户ID',
    `amount`      DECIMAL(10,2)  NOT NULL                COMMENT '金额（正为充值，负为消费）',
    `type`        VARCHAR(10)    NOT NULL                COMMENT '类型：recharge/consume',
    `location`    VARCHAR(100)   DEFAULT NULL            COMMENT '地点',
    `description` VARCHAR(255)   DEFAULT NULL            COMMENT '描述',
    `record_time` DATETIME       NOT NULL                COMMENT '记录时间',
    `deleted`     TINYINT        NOT NULL DEFAULT 0,
    `create_time` DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_card_id` (`card_id`),
    KEY `idx_record_time` (`record_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园卡消费记录';

-- ------------------------------------------------------------
-- 5. 资讯分类表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `news_category`;
CREATE TABLE `news_category` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `code`        VARCHAR(30)  NOT NULL                COMMENT '分类编码：campus/notice/academic/job',
    `name`        VARCHAR(50)  NOT NULL                COMMENT '分类名称',
    `sort`        INT          NOT NULL DEFAULT 0      COMMENT '排序',
    `deleted`     TINYINT      NOT NULL DEFAULT 0,
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资讯分类';

-- ------------------------------------------------------------
-- 6. 资讯表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `news`;
CREATE TABLE `news` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT,
    `title`        VARCHAR(200) NOT NULL                COMMENT '标题',
    `summary`      VARCHAR(500) DEFAULT NULL            COMMENT '摘要',
    `content`      TEXT                                 COMMENT '正文',
    `category_code` VARCHAR(30) NOT NULL                COMMENT '分类编码',
    `cover_image`  VARCHAR(255) DEFAULT NULL            COMMENT '封面图URL',
    `author`       VARCHAR(50)  DEFAULT NULL            COMMENT '作者',
    `views`        INT          NOT NULL DEFAULT 0      COMMENT '阅读量',
    `status`       TINYINT      NOT NULL DEFAULT 1      COMMENT '状态：0-下架 1-上架',
    `publish_time` DATETIME     NOT NULL                COMMENT '发布时间',
    `deleted`      TINYINT      NOT NULL DEFAULT 0,
    `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category_code`),
    KEY `idx_publish_time` (`publish_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资讯';

-- ------------------------------------------------------------
-- 7. 失物招领表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `lost_found`;
CREATE TABLE `lost_found` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`      BIGINT       NOT NULL                COMMENT '发布人ID',
    `type`         VARCHAR(10)  NOT NULL                COMMENT '类型：lost/found',
    `title`        VARCHAR(100) NOT NULL                COMMENT '标题',
    `description`  TEXT                                 COMMENT '描述',
    `location`     VARCHAR(200) DEFAULT NULL            COMMENT '地点',
    `contact`      VARCHAR(50)  DEFAULT NULL            COMMENT '联系方式',
    `category`     VARCHAR(30)  DEFAULT NULL            COMMENT '分类：证件/电子产品/钥匙/书籍/其他',
    `images`       TEXT                                 COMMENT '图片URL，逗号分隔',
    `status`       VARCHAR(10)  NOT NULL DEFAULT 'active' COMMENT '状态：active/completed',
    `event_time`   DATETIME     DEFAULT NULL            COMMENT '事件发生时间',
    `publish_time` DATETIME     NOT NULL                COMMENT '发布时间',
    `deleted`      TINYINT      NOT NULL DEFAULT 0,
    `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_type_status` (`type`, `status`),
    KEY `idx_publish_time` (`publish_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='失物招领';

-- ============================================================
-- 初始化数据
-- ============================================================

-- 用户数据（密码均为 123456 的 BCrypt 加密）
INSERT INTO `sys_user` (`student_id`, `password`, `name`, `college`, `major`, `grade`, `phone`, `email`) VALUES
('2021001001', '$2a$10$bFodZPzPTxOvrx45ntUx6OrfweQNF.ha7WefyLmnoXKEe80vn8yka', '张三', '计算机科学与技术学院', '软件工程', '2021级', '13800138000', 'zhangsan@campus.edu.cn'),
('2021001002', '$2a$10$bFodZPzPTxOvrx45ntUx6OrfweQNF.ha7WefyLmnoXKEe80vn8yka', '李四', '计算机科学与技术学院', '计算机科学与技术', '2021级', '13800138001', 'lisi@campus.edu.cn');

-- 资讯分类
INSERT INTO `news_category` (`code`, `name`, `sort`) VALUES
('campus',  '校园新闻', 1),
('notice',  '通知公告', 2),
('academic','学术活动', 3),
('job',     '就业信息', 4);

-- 课程数据（用户1）
INSERT INTO `course` (`user_id`, `name`, `teacher`, `classroom`, `day_of_week`, `start_section`, `end_section`, `week_start`, `week_end`, `color`, `credit`, `remark`) VALUES
(1, '高等数学', '王教授', 'A101', 1, 1, 2, 1, 16, '#1890FF', 4.0, '必修'),
(1, '大学英语', '李老师', 'B203', 2, 3, 4, 1, 16, '#52C41A', 3.0, '必修'),
(1, '数据结构', '张教授', 'C305', 3, 5, 6, 1, 18, '#FAAD14', 3.5, '专业必修'),
(1, '操作系统', '刘教授', 'D407', 4, 7, 8, 1, 18, '#722ED1', 3.5, '专业必修'),
(1, '计算机网络', '陈教授', 'A201', 5, 1, 2, 1, 16, '#EB2F96', 3.0, '专业必修'),
(1, '软件工程', '赵教授', 'B110', 1, 5, 6, 1, 18, '#13C2C2', 3.0, '专业必修'),
(1, '数据库原理', '孙教授', 'C402', 3, 1, 2, 1, 16, '#FA8C16', 3.0, '专业必修');

-- 校园卡数据
INSERT INTO `campus_card` (`user_id`, `card_no`, `balance`, `user_name`, `status`) VALUES
(1, '62284800101234567890', 258.50, '张三', 'normal'),
(2, '62284800101234567891', 156.80, '李四', 'normal');

-- 消费记录
INSERT INTO `card_record` (`card_id`, `user_id`, `amount`, `type`, `location`, `description`, `record_time`) VALUES
(1, 1, 50.00, 'recharge', '线上充值', '微信充值', '2026-07-01 10:00:00'),
(1, 1, -12.50, 'consume', '第一食堂', '午餐', '2026-07-10 12:30:00'),
(1, 1, -8.00, 'consume', '第二食堂', '晚餐', '2026-07-10 18:15:00'),
(1, 1, -3.50, 'consume', '校园超市', '饮料', '2026-07-11 14:20:00'),
(1, 1, 100.00, 'recharge', '线上充值', '支付宝充值', '2026-07-12 09:00:00'),
(1, 1, -15.00, 'consume', '图书馆咖啡厅', '咖啡', '2026-07-13 15:00:00'),
(1, 1, -6.00, 'consume', '第一食堂', '早餐', '2026-07-14 07:30:00');

-- 资讯数据
INSERT INTO `news` (`title`, `summary`, `content`, `category_code`, `author`, `views`, `publish_time`) VALUES
('2026年春季学期开学典礼圆满举行', '我校于3月1日隆重举行春季学期开学典礼，校长发表重要讲话。', '春风送暖，万象更新。3月1日上午，我校2026年春季学期开学典礼在学校体育馆隆重举行。校长在致辞中回顾了过去一年学校取得的辉煌成就，并对新学期提出了殷切期望。全校师生代表共计2000余人参加了典礼。', 'campus', '校宣传部', 1280, '2026-03-02 09:00:00'),
('关于清明节放假安排的通知', '根据国务院办公厅通知精神，现将清明节放假安排通知如下。', '根据国务院办公厅通知精神，2026年清明节放假安排如下：4月4日至6日放假调休，共3天。请各部门做好值班安排，确保校园安全。', 'notice', '校办', 2340, '2026-03-25 14:00:00'),
('人工智能与未来教育学术报告会', '我院将于近期举办人工智能与未来教育主题学术报告会，欢迎参加。', '报告主题：人工智能与未来教育\n主讲人：王院士（清华大学）\n时间：2026年4月15日 14:00\n地点：信息楼报告厅\n\n报告将围绕人工智能技术在教育领域的最新应用展开，探讨未来教育的发展趋势。', 'academic', '计算机学院', 856, '2026-04-10 10:00:00'),
('2026届毕业生春季校园招聘会', '我校将于4月20日举办2026届毕业生春季校园招聘会。', '2026届毕业生春季校园招聘会将于4月20日在大学生活动中心举行，届时将有100余家知名企业参会，提供2000余个就业岗位。请毕业生提前准备简历，踊跃参加。', 'job', '就业指导中心', 1568, '2026-04-12 16:00:00'),
('图书馆开放时间调整通知', '自5月1日起，图书馆开放时间调整为7:00-22:30。', '为满足广大师生学习需求，自5月1日起，图书馆开放时间调整为7:00-22:30，周末正常开放。请相互转告。', 'notice', '图书馆', 3420, '2026-04-28 09:30:00');

-- 失物招领数据
INSERT INTO `lost_found` (`user_id`, `type`, `title`, `description`, `location`, `contact`, `category`, `status`, `event_time`, `publish_time`) VALUES
(1, 'lost', '丢失一张校园卡', '在第一食堂附近丢失一张校园卡，卡号尾号6789，请拾到者联系，必有重谢！', '第一食堂', '13800138000', '证件', 'active', '2026-07-12 12:00:00', '2026-07-12 14:00:00'),
(2, 'found', '拾到黑色钱包', '在图书馆三楼自习室拾到一个黑色钱包，内有身份证和若干现金，请失主联系认领。', '图书馆三楼', '13800138001', '其他', 'active', '2026-07-13 10:00:00', '2026-07-13 11:00:00'),
(1, 'lost', '丢失黑色雨伞', '7月10日下午在教学楼A栋到食堂的路上丢失一把黑色雨伞，长柄的。', '教学楼A栋', '13800138000', '其他', 'active', '2026-07-10 16:00:00', '2026-07-10 18:00:00'),
(2, 'found', '拾到蓝牙耳机', '在操场跑步道旁拾到一只白色蓝牙耳机，airpods款式。', '操场', '13800138001', '电子产品', 'active', '2026-07-11 07:00:00', '2026-07-11 09:00:00');
