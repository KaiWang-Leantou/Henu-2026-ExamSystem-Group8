@echo off
chcp 936 >nul
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  创建 exam 库、5 张表、应用连接账号、默认管理员
rem  前提：MySQL 已在 3306 端口运行（先双击 2-启动.bat 并保持窗口不关）
rem  本脚本可重复运行：内部全部使用 IF NOT EXISTS / INSERT IGNORE / GRANT
rem  脚本会自动尝试两种登录方式：root 空密码、root/123456
rem ------------------------------------------------------------------

if not exist "exam.sql" (
    echo [错误] 找不到 exam.sql，请确认它和本脚本在同一个目录。
    pause
    exit /b 1
)

echo ============================================================
echo   建库：exam 库 + 5 张表 + 账号 exam/123456 + 管理员 admin/123456
echo   目标：127.0.0.1:3306
echo ============================================================
echo.

echo [1/2] 尝试以 root（无密码）执行 exam.sql ...
bin\mysql.exe --default-character-set=utf8 -h 127.0.0.1 -P3306 -uroot < exam.sql
if not errorlevel 1 goto :ok

echo.
echo [2/2] 空密码不行，改试 root / 123456 ...
bin\mysql.exe --default-character-set=utf8 -h 127.0.0.1 -P3306 -uroot -p123456 < exam.sql
if not errorlevel 1 goto :ok

echo.
echo [失败] 两种方式都没成功，常见原因：
echo        1^) 数据库没启动 —— 请先运行 2-启动.bat 并保持那个窗口打开
echo        2^) root 密码既不是空也不是 123456 —— 请手动执行：
echo           bin\mysql.exe --default-character-set=utf8 -h 127.0.0.1 -P3306 -uroot -p  ^< exam.sql
echo.
pause
exit /b 1

:ok
echo.
echo [完成] 建库成功。
echo        管理员账号：admin / 123456
echo        应用连接账号：exam / 123456
echo        下一步：回到 exam-bundle 根目录双击 start.bat 启动 Tomcat。
echo.
pause
endlocal
