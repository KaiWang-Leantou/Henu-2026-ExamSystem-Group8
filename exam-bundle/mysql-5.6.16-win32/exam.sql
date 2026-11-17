-- ============================================================
--  上机考试系统 · 建库脚本（MySQL 5.6 / 端口 3306）
--  用法：先运行 2-start.bat 让数据库跑起来，再双击 3-createdb.bat
--  说明：表结构依据 webapps/exam/WEB-INF/classes/xq/exam/vo/*.hbm.xml 还原，
--        主键均为 identity（即 AUTO_INCREMENT）。
-- ============================================================

SET NAMES utf8;

CREATE DATABASE IF NOT EXISTS exam DEFAULT CHARACTER SET utf8;
USE exam;

-- ------------------------------------------------------------
-- 1. 教师表（同时承担管理员角色，tadmin=1 为管理员）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS teacher (
  id        INT           NOT NULL AUTO_INCREMENT,
  tname     VARCHAR(50)   NOT NULL              COMMENT '登录账号',
  tpass     VARCHAR(64)   NOT NULL              COMMENT '密码，40位小写SHA1',
  tfullname VARCHAR(50)   DEFAULT NULL          COMMENT '姓名',
  tadmin    TINYINT(1)    DEFAULT 0             COMMENT '是否管理员 1是 0否',
  PRIMARY KEY (id),
  UNIQUE KEY uk_teacher_tname (tname)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- 2. 考试表
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS exam (
  id         INT          NOT NULL AUTO_INCREMENT,
  ecreator   INT          DEFAULT NULL          COMMENT '创建教师 teacher.id',
  ename      VARCHAR(255) DEFAULT NULL          COMMENT '考试名称',
  epaper     VARCHAR(255) DEFAULT NULL          COMMENT '试卷文件名',
  etype      VARCHAR(50)  DEFAULT NULL          COMMENT '考试类型',
  etime      DATETIME     DEFAULT NULL          COMMENT '考试时间',
  eautostart TINYINT(1)   DEFAULT 0             COMMENT '到点自动开始',
  eactive    TINYINT(1)   DEFAULT 0             COMMENT '进行中',
  efinish    TINYINT(1)   DEFAULT 0             COMMENT '已结束',
  earchived  TINYINT(1)   DEFAULT 0             COMMENT '已归档',
  ecleared   TINYINT(1)   DEFAULT 0             COMMENT '已清空',
  PRIMARY KEY (id),
  KEY idx_exam_creator (ecreator)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- 3. 学生表
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS student (
  id     INT          NOT NULL AUTO_INCREMENT,
  sno    VARCHAR(50)  DEFAULT NULL              COMMENT '学号',
  sname  VARCHAR(50)  DEFAULT NULL              COMMENT '姓名',
  sclass VARCHAR(50)  DEFAULT NULL              COMMENT '班级',
  eid    INT          DEFAULT NULL              COMMENT '所属考试 exam.id',
  PRIMARY KEY (id),
  KEY idx_student_eid (eid),
  KEY idx_student_sno (sno)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- 4. 交卷表
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS submit (
  id    INT      NOT NULL AUTO_INCREMENT,
  eid   INT      DEFAULT NULL,
  sid   INT      DEFAULT NULL,
  stime DATETIME DEFAULT NULL                   COMMENT '交卷时间',
  PRIMARY KEY (id),
  KEY idx_submit_eid (eid),
  KEY idx_submit_sid (sid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- 5. 学生与考试的绑定表（记录入场IP等）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS binding (
  id  INT          NOT NULL AUTO_INCREMENT,
  eid INT          DEFAULT NULL,
  sid INT          DEFAULT NULL,
  ip  VARCHAR(64)  DEFAULT NULL                 COMMENT '学生机IP',
  PRIMARY KEY (id),
  KEY idx_binding_eid (eid),
  KEY idx_binding_sid (sid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- 6. 应用连接账号（对应 applicationContext.xml 里的 exam / 123456）
--    注意：MySQL 5.6 不支持 CREATE USER IF NOT EXISTS（那是 5.7.6+ 的语法），
--          这里用 GRANT ... IDENTIFIED BY 来"不存在则创建、存在则改密码"。
-- ------------------------------------------------------------
GRANT ALL PRIVILEGES ON exam.* TO 'exam'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON exam.* TO 'exam'@'127.0.0.1' IDENTIFIED BY '123456';

-- ------------------------------------------------------------
-- 7. 默认管理员：admin / 123456
--    密码使用与程序一致的 SHA1（DigestUtil.sha1），40 位小写。
--    注意：如果改成不插入这一行，程序会启用内置管理员 admin/admin，
--          但它只在 teacher 表里没有任何 tadmin=1 记录时才有效
--          （见 TeacherManager.noAdminUser()），有管理员后立即失效。
-- ------------------------------------------------------------
INSERT IGNORE INTO teacher (tname, tpass, tfullname, tadmin)
VALUES ('admin', '7c4a8d09ca3762af61e59520943dc26494f8941b', '管理员', 1);



-- ------------------------------------------------------------
-- 8. 把 root 密码设为 123456（与 xq-shutdown.bat 中的写法保持一致）
--    如果想保留空密码，把下面两行注释掉即可。
-- ------------------------------------------------------------
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('123456');
FLUSH PRIVILEGES;

-- ------------------------------------------------------------
-- 完成提示
-- 注意：这里故意不查 tfullname（含中文），因为 Windows 命令行默认代码页
--       是 936，mysql 客户端以 UTF-8 输出中文时在窗口里会显示成乱码。
--       中文本身存的没问题，用 Navicat / Workbench 查看即可。
-- ------------------------------------------------------------
SELECT 'OK - database ready' AS result;
SELECT id, tname, tadmin, tpass FROM teacher;
SHOW TABLES;
