@echo off
setlocal
if not exist "%~dp0Launch-REHUB.exe" (
  echo Launch-REHUB.exe is missing. Extract the complete Windows demo first.
  pause
  exit /b 1
)
start "" "%~dp0Launch-REHUB.exe"
endlocal
