@echo off
chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  MySQL 5.6.16 数据目录初始化
rem  说明：5.6 没有 --initialize / --initialize-insecure（那是 5.7.6 才有的），
rem        正确做法是用 --bootstrap 把 share 目录下的系统表 SQL 灌进去。
rem ------------------------------------------------------------------

set "BASE=%~dp0"
if "%BASE:~-1%"=="\" set "BASE=%BASE:~0,-1%"

echo ============================================================
echo   MySQL 5.6.16 初始化
echo   安装目录: %BASE%
echo ============================================================
echo.

if exist "data" (
    echo [跳过] 已存在 data 目录，不重复初始化。
    echo.
    echo        如果需要强制重建：先手动删除 data 目录，再运行本脚本。
    goto :done
)

echo [1/3] 创建 data 目录 ...
mkdir "data" 2>nul
if not exist "data" (
    echo [失败] 无法创建 data 目录，请检查当前目录是否有写权限。
    goto :fail
)

echo [2/3] 生成初始化 SQL ...
(echo CREATE DATABASE IF NOT EXISTS mysql; & echo USE mysql;) > "%TEMP%\xq_mysql_hdr.sql"
copy /b "%TEMP%\xq_mysql_hdr.sql" + "share\mysql_system_tables.sql" + "share\mysql_system_tables_data.sql" "%TEMP%\xq_mysql_init.sql" >nul
if not exist "%TEMP%\xq_mysql_init.sql" (
    echo [失败] 生成初始化 SQL 失败。
    goto :fail
)

echo [3/3] 写入系统表（约 10 秒，请勿关闭窗口）...
pushd "data"
"%BASE%\bin\mysqld.exe" --bootstrap --basedir="%BASE%" --datadir="%BASE%\data" < "%TEMP%\xq_mysql_init.sql"
set "RC=%ERRORLEVEL%"
popd

del "%TEMP%\xq_mysql_hdr.sql" >nul 2>nul
del "%TEMP%\xq_mysql_init.sql" >nul 2>nul

if not "%RC%"=="0" (
    echo.
    echo [失败] mysqld 返回码 %RC%
    echo        请删除 data 目录后重试；若仍然失败，查看 data 目录下的 *.err 日志。
    goto :fail
)
if not exist "data\mysql\user.frm" (
    echo.
    echo [失败] 系统表没有生成，请删除 data 目录后重试。
    goto :fail
)

echo.
echo [完成] 初始化成功！
echo        下一步：双击 2-启动.bat 启动数据库，
echo                保持其窗口不关，再双击 3-建库.bat 创建 exam 库与默认账号。
goto :done

:fail
echo.
echo 初始化未完成，请根据上面的提示处理后重试。
:done
echo.
pause
endlocal
