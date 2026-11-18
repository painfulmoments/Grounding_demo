@echo off
setlocal
set "_REHUB_RELEASE_DIR=%~dp0"
echo REHUB - Verify and extract the TWO local ZIP files
echo No download, installation, or administrator access is required.
echo.
powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; $env:PSModulePath=(Join-Path $PSHOME 'Modules')+[IO.Path]::PathSeparator+$env:PSModulePath; $root=$env:_REHUB_RELEASE_DIR; $files=@(@('REHUB-Windows-x64-v1.0.1-Runtime.zip','7c10e8cd81ef32d6e912d9793aff2f378d3074f66d9369019f2798f1aa8ad9cf'),@('REHUB-Windows-x64-v1.0.1-GameData.zip','3c4047a6aa0fc861661d15b4a51c11cf4a3a998f03dde4dda7aaf9349945db49')); foreach($item in $files){$path=Join-Path $root $item[0]; if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw ('Download both ZIP files first. Missing: '+$item[0])}; Write-Host ('Checking '+$item[0]); if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $item[1]){throw ('Checksum mismatch. Download this ZIP again: '+$item[0])}}; foreach($item in $files){Write-Host ('Extracting '+$item[0]); Expand-Archive -LiteralPath (Join-Path $root $item[0]) -DestinationPath $root -Force}; Write-Host ''; Write-Host ('Ready. Open: '+(Join-Path $root 'REHUB-Windows-x64\Launch-REHUB.exe'))"
if errorlevel 1 (
  echo.
  echo Extraction failed. Read the message above and keep both ZIP files together.
  pause
  exit /b 1
)
echo.
echo Complete. Open REHUB-Windows-x64 and double-click Launch-REHUB.exe.
pause
exit /b 0
