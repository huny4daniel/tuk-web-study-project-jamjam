@echo off
rem Hotel JAMJAM local deploy - runs deploy.ps1 (see comments there)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
pause
