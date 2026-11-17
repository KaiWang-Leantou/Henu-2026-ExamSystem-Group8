@echo off
chcp 936 >nul
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  前台启动 MySQL（弹出本窗口，关闭窗口即停止服务器）
rem  带 --console 的作用：把错误信息直接打在窗口上，启动失败时能看见原因
rem ------------------------------------------------------------------

set "BASE=%~dp0"
if "%BASE:~-1%"=="\" set "BASE=%BASE:~0,-1%"

if not exist "data\mysql\user.frm" (
    echo [错误] 还没有初始化数据目录。
    echo        请先运行 1-初始化.bat，然后再运行本脚本。
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo   MySQL 5.6.16
echo   端口    : 3306
echo   数据目录: %BASE%\data
echo   账号    : exam / 123456   (root / 123456)
echo ------------------------------------------------------------
echo   关闭本窗口 = 停止数据库服务
echo ============================================================
echo.

"%BASE%\bin\mysqld.exe" --console --basedir="%BASE%" --datadir="%BASE%\data" --port=3306

echo.
echo MySQL 已停止（返回码 %ERRORLEVEL%）
echo 如果不是你主动关闭的，请把上面几行错误信息截图发到群里。
pause
endlocal
