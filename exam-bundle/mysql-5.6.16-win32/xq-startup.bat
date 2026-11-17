@echo off
chcp 936 >nul

rem ------------------------------------------------------------------
rem  后台启动 MySQL（3306），本窗口立刻返回，可继续做别的事
rem  与 2-启动.bat 的区别：这个不占用当前窗口，适合被 start.bat 调用。
rem  停止服务器请用 xq-shutdown.bat
rem ------------------------------------------------------------------

cd /d "%~dp0"

if not exist "data\mysql\user.frm" (
    echo [错误] 还没有初始化数据目录，请先运行 1-初始化.bat
    exit /b 1
)

echo 正在后台启动 MySQL（127.0.0.1:3306）...
start "MySQL-3306" "%~dp0bin\mysqld.exe" --console --basedir="%~dp0." --datadir="%~dp0data" --port=3306
exit /b 0
