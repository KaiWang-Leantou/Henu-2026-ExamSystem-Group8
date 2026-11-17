@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ==================================================================
rem  One-click start: MySQL (3306) + Tomcat (8080)
rem
rem  First time setup, run these three in order:
rem      mysql-5.6.16-win32\1-init.bat
rem      mysql-5.6.16-win32\2-start.bat     (keep the window open)
rem      mysql-5.6.16-win32\3-createdb.bat
rem  After that, just run this script.
rem
rem  NOTE: keep this file ASCII-only (English). See README.md.
rem ==================================================================

set "JAVA_HOME=%~dp0Java\jdk1.7.0_15"
set "CLASSPATH=.;%JAVA_HOME%\lib"
set "Path=%JAVA_HOME%\bin;%Path%"

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [ERROR] Bundled JDK not found: %JAVA_HOME%
    echo         Check that exam-bundle is complete, antivirus may have removed files.
    echo.
    pause
    exit /b 1
)

if not exist "mysql-5.6.16-win32\data\mysql\user.frm" (
    echo [WARN] MySQL is not initialized yet, cannot start.
    echo.
    echo        Run these three steps first, then run this script again:
    echo          1^) mysql-5.6.16-win32\1-init.bat
    echo          2^) mysql-5.6.16-win32\2-start.bat
    echo          3^) mysql-5.6.16-win32\3-createdb.bat
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo   [1/2] Starting MySQL on 127.0.0.1:3306
echo ============================================================
cd /d "%~dp0mysql-5.6.16-win32"
cmd /c xq-startup.bat
ping -n 5 127.0.0.1 >nul

echo.
echo ============================================================
echo   [2/2] Starting Tomcat: http://localhost:8080/exam/
echo ============================================================
cd /d "%~dp0apache-tomcat-7.0.50\bin"
cmd /c startup.bat

echo.
echo ============================================================
echo   Started.
echo   URL      : http://localhost:8080/exam/
echo   Admin    : admin / 123456
echo   Stop all : mysql-5.6.16-win32\xq-shutdown.bat
echo              apache-tomcat-7.0.50\bin\shutdown.bat
echo ============================================================
echo.
pause
endlocal
