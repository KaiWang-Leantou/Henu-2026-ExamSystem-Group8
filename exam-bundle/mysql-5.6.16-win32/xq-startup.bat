@echo off

rem ------------------------------------------------------------------
rem  Start MySQL in the background (port 3306) and return immediately.
rem  Difference from 2-start.bat: this one does not occupy the window,
rem  so it can be called from start.bat.
rem  To stop the server use xq-shutdown.bat.
rem  NOTE: keep this file ASCII-only (English). See README.md.
rem ------------------------------------------------------------------

cd /d "%~dp0"

if not exist "data\mysql\user.frm" (
    echo [ERROR] Data directory is not initialized. Run 1-init.bat first.
    exit /b 1
)

echo Starting MySQL in background on 127.0.0.1:3306 ...
start "MySQL-3306" "%~dp0bin\mysqld.exe" --console --basedir="%~dp0." --datadir="%~dp0data" --port=3306
exit /b 0
