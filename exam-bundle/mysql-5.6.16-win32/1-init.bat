@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ------------------------------------------------------------------
rem  MySQL 5.6.16 data directory initialization
rem
rem  MySQL 5.6 has no --initialize / --initialize-insecure options
rem  (those were added in 5.7.6). The correct way for 5.6 is to load
rem  share\mysql_system_tables.sql through --bootstrap.
rem
rem  NOTE: keep this file ASCII-only (English). See README.md.
rem ------------------------------------------------------------------

set "BASE=%~dp0"
if "%BASE:~-1%"=="\" set "BASE=%BASE:~0,-1%"

echo ============================================================
echo   MySQL 5.6.16 initialization
echo   Install dir: %BASE%
echo ============================================================
echo.

if exist "data" (
    echo [SKIP] "data" already exists, nothing to do.
    echo.
    echo        To rebuild from scratch: delete the "data" folder first.
    goto :done
)

echo [1/3] Creating data directory ...
mkdir "data" 2>nul
if not exist "data" (
    echo [FAIL] Cannot create "data". Check folder permissions.
    goto :fail
)

echo [2/3] Building bootstrap SQL ...
(echo CREATE DATABASE IF NOT EXISTS mysql; & echo USE mysql;) > "%TEMP%\xq_mysql_hdr.sql"
copy /b "%TEMP%\xq_mysql_hdr.sql" + "share\mysql_system_tables.sql" + "share\mysql_system_tables_data.sql" "%TEMP%\xq_mysql_init.sql" >nul
if not exist "%TEMP%\xq_mysql_init.sql" (
    echo [FAIL] Could not build the bootstrap SQL file.
    goto :fail
)

echo [3/3] Loading system tables, about 10 seconds, do not close this window ...
pushd "data"
"%BASE%\bin\mysqld.exe" --bootstrap --basedir="%BASE%" --datadir="%BASE%\data" < "%TEMP%\xq_mysql_init.sql"
set "RC=%ERRORLEVEL%"
popd

del "%TEMP%\xq_mysql_hdr.sql" >nul 2>nul
del "%TEMP%\xq_mysql_init.sql" >nul 2>nul

if not "%RC%"=="0" (
    echo.
    echo [FAIL] mysqld returned %RC%
    echo        Delete the "data" folder and try again.
    echo        Details: see *.err inside the data folder.
    goto :fail
)
if not exist "data\mysql\user.frm" (
    echo.
    echo [FAIL] System tables were not created.
    echo        Delete the "data" folder and try again.
    goto :fail
)

echo.
echo [DONE] Initialization finished.
echo        Next: run 2-start.bat and keep its window open,
echo              then run 3-createdb.bat.
goto :done

:fail
echo.
echo Initialization did NOT complete. Read the messages above and retry.
:done
echo.
pause
endlocal
