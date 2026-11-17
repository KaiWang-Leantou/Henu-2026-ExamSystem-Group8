@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  Start MySQL in the foreground (this window).
rem  Closing the window stops the server.
rem
rem  --console keeps error output on screen, so a failed start is visible.
rem  NOTE: keep this file ASCII-only (English). See README.md.
rem ------------------------------------------------------------------

set "BASE=%~dp0"
if "%BASE:~-1%"=="\" set "BASE=%BASE:~0,-1%"

if not exist "data\mysql\user.frm" (
    echo [ERROR] Data directory is not initialized.
    echo         Run 1-init.bat first, then run this script again.
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo   MySQL 5.6.16
echo   Port     : 3306
echo   Data dir : %BASE%\data
echo   Accounts : exam / 123456    root / 123456
echo ------------------------------------------------------------
echo   Closing this window = stopping the database server.
echo ============================================================
echo.

"%BASE%\bin\mysqld.exe" --console --basedir="%BASE%" --datadir="%BASE%\data" --port=3306

echo.
echo MySQL stopped, exit code %ERRORLEVEL%
echo If you did not close it yourself, send the lines above to the group.
pause
endlocal
