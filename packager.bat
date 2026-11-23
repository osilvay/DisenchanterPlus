@echo off
py -3 "%~dp0packager.py"
exit /b %errorlevel%
