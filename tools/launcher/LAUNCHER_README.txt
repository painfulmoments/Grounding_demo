REHUB - Windows demo / Windows 试玩

1. Download BOTH Runtime.zip and GameData.zip from the same release.
2. Extract both ZIPs into the SAME destination folder. Keep every subfolder.
   Launch-REHUB.exe must be beside the root REHUB.exe.
3. Connect Quest 3 to your Windows PC, open Meta Horizon Link, and enter Link
   inside the headset.
4. Double-click Launch-REHUB.exe. Choose English or Chinese, a working microphone
   on your computer, and your sound output. Use headphones to reduce echo.
5. Click Save and start VR. Wait for the welcome speech to finish.

No cloud API-key entry is required in this demo. Speech and AI dialogue require
internet access and the demo's cloud services to be available.

Controls: left stick moves; right stick turns. Click right A once to start
recording, then click A again to submit. Do not hold A. Close the desktop game
window or press Alt+F4 to exit.

下载同一版本的 Runtime.zip 和 GameData.zip，将两者解压到同一个目标文件夹，
保留完整目录结构。先连接 Quest Link，再双击 Launch-REHUB.exe。
选择语言、本机麦克风和播放设备，点击“保存并启动”。本演示无需填写云服务密钥，
语音与 AI 对话需要网络及演示服务可用。建议用耳机播放，减少声音被麦克风再次录入。
右手 A 按一次开始录音，再按一次结束提交，不用长按。退出使用电脑窗口关闭或 Alt+F4。

Language and device selections are saved locally at:
  %LOCALAPPDATA%\REHUBDemo\Config\Game.ini
Reconnect a device? Reopen the launcher to refresh its device list.
No Unreal Editor, Python, Visual Studio or administrator access is needed by
this launcher. It uses the Windows .NET Framework and does not change system settings.

Maintainer verification without showing the setup window:
  .\Launch-REHUB.exe --validate-only --validation-result=Launcher-validation.json

Launch-REHUB.cmd is an alternative shortcut to the same launcher. The original
PowerShell launcher is kept as a fallback; the normal entry point is the EXE.
