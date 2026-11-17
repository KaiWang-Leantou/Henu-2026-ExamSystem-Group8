@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  Create the exam database, its 5 tables, the application account
rem  and the default administrator.
rem
rem  Prerequisite: MySQL must be running on port 3306
rem                (run 2-start.bat and keep its window open).
rem  Safe to run more than once: the SQL uses IF NOT EXISTS / IGNORE.
rem  Tries root with empty password first, then root/123456.
rem  NOTE: keep this file ASCII-only (English). See README.md.
rem ------------------------------------------------------------------

if not exist "exam.sql" (
    echo [ERROR] exam.sql not found in this folder.
    pause
    exit /b 1
)

echo ============================================================
echo   Create database: exam + 5 tables
echo   Accounts: exam/123456 (application), admin/123456 (administrator)
echo   Target  : 127.0.0.1:3306
echo ============================================================
echo.

echo [1/2] Trying root with empty password ...
bin\mysql.exe --default-character-set=utf8 -h 127.0.0.1 -P3306 -uroot < exam.sql
if not errorlevel 1 goto :ok

echo.
echo [2/2] Empty password rejected, trying root / 123456 ...
bin\mysql.exe --default-character-set=utf8 -h 127.0.0.1 -P3306 -uroot -p123456 < exam.sql
if not errorlevel 1 goto :ok

echo.
echo [FAIL] Both attempts failed. Common causes:
echo        1^) MySQL is not running. Run 2-start.bat and keep it open.
echo        2^) root password is neither empty nor 123456. Run manually:
echo           bin\mysql.exe --default-character-set=utf8 -h 127.0.0.1 -P3306 -uroot -p  ^< exam.sql
echo.
pause
exit /b 1

:ok
echo.
echo [DONE] Database created.
echo        Administrator: admin / 123456
echo        App account  : exam / 123456
echo        Next: go back to exam-bundle and run start.bat.
echo.
pause
endlocal
