# Build and validation

[Project overview](../README.md) · [Play guide](PLAY_EN.md) · [中文试玩说明](PLAY_ZH.md)

## Release scope

**v1.0.1 is a documentation and packaging update.** It uses the same Windows Shipping game executables and cooked game data as v1.0.0. The README, user-selected teaser, play guides and extraction instructions are synchronized with this release. Earlier release archives remain historical snapshots.

The public repository contains documentation and the small setup/extraction tools. The complete Unreal project and its source history remain private. No Unreal Editor is required to play.

## Evidence and limits

| Check | Recorded result | What it establishes |
| --- | --- | --- |
| Engine / target | Unreal Engine **5.7**, Windows x64 Shipping | Build environment and application target |
| Build / Cook / Stage / Archive | Completed successfully | The Windows package was produced; not a headset playthrough |
| Default map | `/Game/Waterfall` | The packaged scene selection |
| Runtime dependencies | Ambient audio, ONNX runtime and native dependencies included | These files are distributed with the application |
| Archive integrity | ZIP CRC checks and SHA-256 checks | Package integrity, not gameplay correctness |
| Extraction | Native Windows ZIP extraction checked | The two independent ZIPs merge into the expected folder |
| Native setup tool | Device enumeration, configuration generation, visible UI and saving selections checked | Language, microphone and playback preferences; no API-key entry |
| Desktop startup | Shipping application launched and scene visually reviewed | Desktop scene startup, not headset rendering/tracking |
| Cloud short requests | Chinese and English speech synthesis/recognition succeeded; DeepSeek `deepseek-flash` replied | Independent service connectivity at the time of the check |
| Full packaged Quest Link conversation | **Not completed** | Tracking, physical A-button recording and a complete conversation on another PC remain unverified |
| Other headsets / Air Link / standalone Quest | **Not verified / no standalone APK provided** | No broader compatibility claim |

Development/editor headset testing used a **Quest 3, Touch controllers and wired Meta Horizon Link**. Those earlier tests do not replace validation of this packaged release on a clean PC. No additional headset test was performed during the documentation review because a headset was unavailable.

## Files and installation

The two downloads are **independent ZIPs**, not numbered pieces of one archive. Both share the `REHUB-Windows-x64` top-level folder. The extraction helper checks the expected SHA-256 of each ZIP before extracting them into the same destination.

- Runtime: game executable, setup tool, native libraries, ambient audio and documentation.
- GameData: cooked `.ucas` content, required with the Runtime package.
- Entry point: **`Launch-REHUB.exe`** in the merged folder.
- Included x64 prerequisite: **`Engine/Extras/Redist/en-us/vc_redist.x64.exe`**. The ARM64 installer in the same directory is not the installer for this x64 build.

Allow **8 GB free space** for downloads and extraction with a margin. Development used Windows 11, an RTX 5070 Laptop GPU (8 GB VRAM) and 32 GB RAM. This configuration is not a measured minimum hardware specification.

## Online behavior

The author provides demonstration speech and AI access, so players do not enter API keys. Internet access is required and service availability depends on the author's account quota and upstream providers. Microphone audio and dialogue text are processed as described in the [play guide](PLAY_EN.md#3-online-service-access-and-privacy).

Service request checks are not a microphone capture test or a complete dialogue test. A successful build, valid ZIP and successful cloud response must not be summarized as a fully verified headset experience.

## 中文摘要

v1.0.1 只更新文档与发布包装，沿用 v1.0.0 的游戏程序及资源。已核对构建、桌面场景、启动器、ZIP 与 Windows 解压；中文和英文 TTS／STT 及 DeepSeek 独立短请求曾成功。**完整打包版 Quest Link 对话、实体手柄录音及换电脑体验尚未完成验证。** 先连接并进入 Link，再打开 `Launch-REHUB.exe`；试玩者无需填写 API Key。详细步骤见[中文试玩说明](PLAY_ZH.md)。
