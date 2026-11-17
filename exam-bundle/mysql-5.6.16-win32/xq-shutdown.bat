@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  Stop MySQL.
rem  The port must match my.ini and the start scripts (this project: 3306).
rem  Tries root/123456 first, then root with empty password.
rem  NOTE: keep this file ASCII-only (English). See README.md.
rem ------------------------------------------------------------------

echo Stopping MySQL on 127.0.0.1:3306 ...

bin\mysqladmin.exe -h 127.0.0.1 -P3306 -uroot -p123456 shutdown 2>nul
if not errorlevel 1 goto :ok

echo root/123456 rejected, trying empty password ...
bin\mysqladmin.exe -h 127.0.0.1 -P3306 -uroot shutdown 2>nul
if not errorlevel 1 goto :ok

echo.
echo [FAIL] Could not stop MySQL. Common causes:
echo        1^) MySQL is not running at all.
echo        2^) root password is neither 123456 nor empty. Run manually:
echo           bin\mysqladmin.exe -h 127.0.0.1 -P3306 -uroot -p shutdown
echo        3^) Still failing: end mysqld.exe in Task Manager.
echo.
pause
exit /b 1

:ok
echo.
echo [DONE] MySQL stopped.
pause
endlocal
