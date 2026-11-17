@echo off
chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  关闭 MySQL（端口必须与 my.ini / 启动脚本一致：本项目用 3306）
rem  会自动尝试 root/123456，失败再试 root 空密码
rem ------------------------------------------------------------------

echo 正在关闭 MySQL（127.0.0.1:3306）...

bin\mysqladmin.exe -h 127.0.0.1 -P3306 -uroot -p123456 shutdown 2>nul
if not errorlevel 1 goto :ok

echo root/123456 不行，改试空密码 ...
bin\mysqladmin.exe -h 127.0.0.1 -P3306 -uroot shutdown 2>nul
if not errorlevel 1 goto :ok

echo.
echo [失败] 关闭失败，常见原因：
echo        1^) MySQL 本来就没有运行
echo        2^) root 密码既不是 123456 也不是空 —— 请手动执行下面这条并输入你的密码：
echo           bin\mysqladmin.exe -h 127.0.0.1 -P3306 -uroot -p shutdown
echo        3^) 实在关不掉：任务管理器里结束 mysqld.exe
echo.
pause
exit /b 1

:ok
echo.
echo [完成] MySQL 已关闭。
pause
endlocal
