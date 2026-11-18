@echo off
setlocal
set "_REHUB_RELEASE_DIR=%~dp0"
echo REHUB - Verify and extract the TWO local ZIP files
echo No download, installation, or administrator access is required.
echo.
powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; $root=$env:_REHUB_RELEASE_DIR; $files=@(@('REHUB-Windows-x64-v1.0.0-Runtime.zip','21bae36b6c4c311f77a1e49c81cb74e38587fc2783c023b7b9311caa4007da5a'),@('REHUB-Windows-x64-v1.0.0-GameData.zip','96371db0d2ce111b642e620a0158c6622b0eea42fa3a682f65a17f951109d29f')); foreach($item in $files){$path=Join-Path $root $item[0]; if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw ('Download both ZIP files first. Missing: '+$item[0])}; Write-Host ('Checking '+$item[0]); if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $item[1]){throw ('Checksum mismatch. Download this ZIP again: '+$item[0])}}; foreach($item in $files){Write-Host ('Extracting '+$item[0]); Expand-Archive -LiteralPath (Join-Path $root $item[0]) -DestinationPath $root -Force}; Write-Host ''; Write-Host ('Ready. Open: '+(Join-Path $root 'REHUB-Windows-x64\Launch-REHUB.cmd'))"
if errorlevel 1 (
  echo.
  echo Extraction failed. Read the message above and keep both ZIP files together.
  pause
  exit /b 1
)
echo.
echo Complete. Open REHUB-Windows-x64 and double-click Launch-REHUB.cmd.
pause
exit /b 0
