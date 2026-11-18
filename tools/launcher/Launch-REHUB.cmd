@echo off
setlocal
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -STA -WindowStyle Normal -ExecutionPolicy Bypass -File "%~dp0Launch-REHUB.ps1"
if errorlevel 1 pause
endlocal
