@echo off
set JAVA_HOME=%~dp0\Java\jdk1.7.0_15
set CLASSPATH=.;%JAVA_HOME%\lib
set Path=%JAVA_HOME%\bin;%Path%
cd mysql-5.6.16-win32
cmd /c xq-startup.bat
cd ../apache-tomcat-7.0.50/bin
cmd /c startup.bat
