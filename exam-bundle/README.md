# 上机考试系统（exam-bundle）

一套开箱即用的 Java EE 上机考试系统，所有依赖（JDK / Tomcat / MySQL）都打包在本目录内，
**不需要另外安装任何软件**，解压后按下面四步即可跑起来。

技术栈：`JSP + Struts2 2.3.16 + Spring 4.0.1 + Hibernate 4.3.1 + MySQL 5.6.16 + Tomcat 7.0.50 + JDK 1.7`

- MySQL 端口：**3306**
- Tomcat 端口：**8080**
- 访问地址：<http://localhost:8080/exam/>
- 管理员：**admin / 123456**

---

## 一、目录说明

```
exam-bundle/
├─ start.bat                    一键启动（MySQL + Tomcat）
├─ Java/jdk1.7.0_15/            自带 JDK（程序运行时用的就是它）
├─ apache-tomcat-7.0.50/        自带 Tomcat，应用部署在 webapps/exam/
│   └─ webapps/exam/            ★ 考试系统本体
│       ├─ index.jsp / WEB-INF/jsp/      页面（JSP 改完保存即生效）
│       ├─ WEB-INF/applicationContext.xml       ★ 数据库连接配置（真正生效的是这个）
│       ├─ WEB-INF/classes/              编译后的 Java 类 + Spring/Struts 配置
│       └─ WEB-INF/lib/                  36 个依赖 jar
└─ mysql-5.6.16-win32/          自带 MySQL（端口 3306）
    ├─ 1-初始化.bat             ① 生成数据目录
    ├─ 2-启动.bat               ② 前台启动数据库（能看到错误）
    ├─ 3-建库.bat               ③ 创建 exam 库与表
    ├─ xq-startup.bat           后台启动（被 start.bat 调用）
    ├─ xq-shutdown.bat          关闭数据库
    ├─ exam.sql                 建库脚本（表结构 + 默认账号）
    └─ my.ini                   配置（端口等，不含绝对路径）
```

---

## 二、首次运行（只需做一次）

> **前提：3306 端口必须空着。** 如果本机另装过 MySQL（比如 `D:\MYSQL` 的 `MySQL267` 服务），
> 必须先把那个服务停掉，否则本项目的 mysqld 会因为端口被占用而起不来。
> 详见第五节「环境说明与变更记录」。

| 步骤 | 操作 | 说明 |
|---|---|---|
| ① | 双击 `mysql-5.6.16-win32\1-初始化.bat` | 生成 `data` 目录（约 10 秒）。已有 data 时自动跳过 |
| ② | 双击 `mysql-5.6.16-win32\2-启动.bat` | 启动数据库，**窗口不要关**（关了就等于停服） |
| ③ | 双击 `mysql-5.6.16-win32\3-建库.bat` | 创建 `exam` 库、5 张表、默认管理员。只需成功一次 |
| ④ | 双击根目录 `start.bat` | 启动 Tomcat，浏览器打开 <http://localhost:8080/exam/> |

### 账号

| 用途 | 账号 / 密码 |
|---|---|
| 系统登录（管理员） | `admin` / `123456` |
| 应用连数据库 | `exam` / `123456` |
| 数据库 root | `root` / `123456` |

---

## 三、日常启动与关闭

| 操作 | 做法 |
|---|---|
| 启动全部 | 双击 `start.bat` |
| 单独启动数据库 | `mysql-5.6.16-win32\2-启动.bat` |
| 单独启动 Tomcat | `apache-tomcat-7.0.50\bin\startup.bat` |
| 关闭数据库 | `mysql-5.6.16-win32\xq-shutdown.bat` |
| 关闭 Tomcat | `apache-tomcat-7.0.50\bin\shutdown.bat` |

### 端口一览

| 服务 | 端口 | 备注 |
|---|---|---|
| MySQL（本项目） | **3306** | MySQL 默认端口 |
| Tomcat HTTP | 8080 | 浏览器访问 |
| Tomcat shutdown | 8005 | 关服务器用 |
| Tomcat AJP | 8009 | 本项目未用 |

---

## 四、常见问题

**Q1：`2-启动.bat` 一闪就没了 / 报 `Port 3306 in use`**
说明 3306 被别的 MySQL 占了。查一下：

```bat
netstat -ano | findstr :3306
sc query MySQL267
```

如果是系统里的 MySQL 服务，用**管理员**权限的 CMD 执行：

```bat
net stop MySQL267
sc config MySQL267 start= disabled
```

**Q2：启动报 `Can't connect to MySQL server on '127.0.0.1' (10061)`**
数据库没起来。确认 `2-启动.bat` 的窗口还开着，且没报错。

**Q3：页面能开但登录报数据库错误**
按顺序排查：
1. 跑过 `3-建库.bat` 吗？
2. `webapps\exam\WEB-INF\applicationContext.xml` 的端口是不是 3306？
3. 手动验证：`mysql-5.6.16-win32\bin\mysql.exe -h 127.0.0.1 -P3306 -uexam -p123456 -e "use exam; show tables;"`

**Q4：想改成别的端口**
必须**同时**改这 5 处，缺一不可：

| # | 文件 | 改什么 |
|---|---|---|
| 1 | `mysql-5.6.16-win32\my.ini` | `port=xxxx`（`[client]` 和 `[mysqld]` 各一处） |
| 2 | `mysql-5.6.16-win32\2-启动.bat` | `--port=xxxx` |
| 3 | `mysql-5.6.16-win32\xq-startup.bat` | `--port=xxxx` |
| 4 | `mysql-5.6.16-win32\xq-shutdown.bat`、`3-建库.bat` | `-Pxxxx` |
| 5 | `webapps\exam\WEB-INF\applicationContext.xml` | JDBC URL 里的端口 |

**Q5：初始化失败 / 想重新来过**
删掉 `mysql-5.6.16-win32\data` 整个目录，重新跑 `1-初始化.bat` → `2-启动.bat` → `3-建库.bat`。

**Q6：登录提示账号密码错误**
确认跑过 `3-建库.bat`。默认管理员是 `admin` / `123456`，密码在库里存的是
`md5("123456") = e10adc3949ba59abbe56e057f20f883e`。

---

## 五、环境说明与变更记录

### 2026-11-17 环境调整（重要）

为避免与项目自带 MySQL 抢 3306 端口，做了以下调整：

| 操作 | 命令（需管理员 CMD） | 结果 |
|---|---|---|
| 停止系统里的 MySQL 服务 | `net stop MySQL267` | 服务状态变为 Stopped |
| 取消开机自启 | `sc config MySQL267 start= demand` | 启动类型变为「手动」 |
| 项目端口统一为 3306 | 见 Q4 的 5 处清单 | 项目自带 MySQL 占用 3306 |

> 说明：`start= demand`（手动）只是不再开机自启，**仍可能被手动或某些软件拉起**。
> 如果想彻底禁止，用 `sc config MySQL267 start= disabled`（禁用）。
> 需要恢复原来的 MySQL 时：`sc config MySQL267 start= auto` 然后 `net start MySQL267`
> —— 但**必须先关掉本项目的 MySQL**，否则端口冲突。

### 关于两个 applicationContext.xml

项目里有两个同名文件：

| 路径 | 是否生效 | 说明 |
|---|---|---|
| `WEB-INF\applicationContext.xml` | ✅ **生效** | `web.xml` 没指定 `contextConfigLocation`，Spring 默认加载这个。它包含 service 层的 bean（teacherManager 等） |
| `WEB-INF\classes\applicationContext.xml` | ❌ 不生效 | 缺少 service bean 的旧版本，历史遗留 |

**改数据库连接请改 `WEB-INF\applicationContext.xml`**，改错文件不会有任何效果。两个文件目前都保持 3306 一致，以防将来有变。

---

## 六、开发说明

### 关于源码

`webapps/exam/WEB-INF/classes/` 下 **只有编译好的 `.class`，没有 `.java` 源码**。所以：

- **改页面/文案/样式**：直接改 `WEB-INF/jsp/*.jsp` 或 `assets/`，Tomcat 会编译 JSP，**刷新即生效**。
- **加新功能**：自己写新的 `.java`，用项目自带 `Java\jdk1.7.0_15\bin\javac.exe` 编译到
  `WEB-INF\classes`，再在 `WEB-INF\classes\struts.xml` 里注册 Action。
- **改已有逻辑**：需要先拿到源码（找原作者要工程，或反编译那 42 个 class）。

编译示例（在 `exam-bundle` 目录下执行）：

```bat
set JAVA_HOME=%~dp0Java\jdk1.7.0_15
"%JAVA_HOME%\bin\javac" -encoding UTF-8 -source 1.7 -target 1.7 ^
  -cp "apache-tomcat-7.0.50\webapps\exam\WEB-INF\lib\*" ^
  -d "apache-tomcat-7.0.50\webapps\exam\WEB-INF\classes" ^
  src\xq\exam\action\MyNewAction.java
```

### 关于版本管理

- `data/`（MySQL 数据目录）**不提交**，每人本地初始化生成；
- `exam.sql`、4 个 bat、`my.ini` **必须提交**——这正是新人能一键跑起来的前提；
- `WEB-INF/classes` 与 `WEB-INF/lib` 已在 `.gitignore` 里做了例外，编译产物可以正常提交；
- `.gitattributes` 强制 `*.bat` 使用 CRLF 换行（**否则 cmd 解析批处理会错行，脚本直接跑不起来**）。

### 数据库表

| 表 | 用途 |
|---|---|
| `teacher` | 教师/管理员，`tadmin=1` 为管理员 |
| `exam` | 考试 |
| `student` | 考生 |
| `submit` | 交卷记录 |
| `binding` | 考生与考试绑定（含入场 IP） |

---

## 七、已知限制

- JDK 1.7 与 Tomcat 7.0.50 均已停止维护，**请勿部署到公网**，仅限内网/课堂使用。
- 自带 MySQL 是 32 位版本，单进程内存受限，不适合压测场景。
- 数据库使用 3306，与本机其他 MySQL 存在**端口互斥**：两边不能同时启动。
