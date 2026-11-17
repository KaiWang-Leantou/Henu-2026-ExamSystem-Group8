@echo off
chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"

rem ==================================================================
rem  一键启动：MySQL(3306) + Tomcat(8080)
rem  首次使用请先依次执行：
rem      mysql-5.6.16-win32\1-初始化.bat
rem      mysql-5.6.16-win32\2-启动.bat      （保持窗口不关）
rem      mysql-5.6.16-win32\3-建库.bat
rem  之后再跑本脚本即可。
rem ==================================================================

set "JAVA_HOME=%~dp0Java\jdk1.7.0_15"
set "CLASSPATH=.;%JAVA_HOME%\lib"
set "Path=%JAVA_HOME%\bin;%Path%"

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [错误] 找不到自带的 JDK：%JAVA_HOME%
    echo        请确认 exam-bundle 目录完整，没有被杀毒软件删掉文件。
    echo.
    pause
    exit /b 1
)

if not exist "mysql-5.6.16-win32\data\mysql\user.frm" (
    echo [提示] MySQL 还没有初始化，无法启动。
    echo.
    echo        请按顺序执行下面三步，然后再运行本脚本：
    echo          1^) mysql-5.6.16-win32\1-初始化.bat
    echo          2^) mysql-5.6.16-win32\2-启动.bat
    echo          3^) mysql-5.6.16-win32\3-建库.bat
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo   [1/2] 启动 MySQL（127.0.0.1:3306）
echo ============================================================
cd /d "%~dp0mysql-5.6.16-win32"
cmd /c xq-startup.bat
timeout /t 4 /nobreak >nul

echo.
echo ============================================================
echo   [2/2] 启动 Tomcat（http://localhost:8080/exam/）
echo ============================================================
cd /d "%~dp0apache-tomcat-7.0.50\bin"
cmd /c startup.bat

echo.
echo ============================================================
echo   启动完成
echo   访问地址：http://localhost:8080/exam/
echo   管理员  ：admin / 123456
echo   关闭服务：mysql-5.6.16-win32\xq-shutdown.bat
echo             apache-tomcat-7.0.50\bin\shutdown.bat
echo ============================================================
echo.
pause
endlocal
