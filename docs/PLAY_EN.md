# Play REHUB on Windows with Quest 3

[Download](https://github.com/painfulmoments/Grounding_demo/releases/latest) · [Project overview](../README.md) · [中文说明](PLAY_ZH.md)

## 1. Check the setup

This release is a **Windows x64 PC VR application**. Development/editor testing used **Meta Quest 3, Touch controllers, and wired Meta Horizon Link**. The Windows Shipping build has been launched and its scene visually reviewed, but a full packaged headset/cloud conversation playthrough remains pending. It is not an APK installed on the headset. Other headsets and Air Link are unverified for this release.

You need:

- A Windows x64 PC that meets [Meta Horizon Link's requirements](https://www.meta.com/help/quest/140991407990979/).
- Meta Horizon Link installed on the PC, a connected Quest 3, and its controllers.
- A working Windows microphone. A PC microphone is a valid choice; headset microphones do not work reliably on every Link setup.
- Headphones for playback, or a sufficiently quiet setup to keep game audio out of the microphone.
- Internet access to the author-provided demonstration speech and AI service. No separate cloud-account registration or API-key entry is required.

The development test PC used Windows 11, an RTX 5070 Laptop GPU with 8 GB VRAM, and 32 GB RAM. This is a reference test configuration, not a validated minimum specification.

## 2. Download the playable package

**Download BOTH ZIPs from the same Release. Extract BOTH to the same destination folder.**

Open the [latest Release](https://github.com/painfulmoments/Grounding_demo/releases/latest). Under **Assets**, download:

- **`REHUB-Windows-x64-v1.0.0-Runtime.zip`**
- **`REHUB-Windows-x64-v1.0.0-GameData.zip`**

These are two independent ZIP archives, not split 7-Zip volumes. Both are required. No 7-Zip installation is needed.

### Manual extraction

1. Create or choose one destination, for example **`C:\VR\`**.
2. Extract the Runtime ZIP to **`C:\VR\`**.
3. Extract the GameData ZIP to the **same `C:\VR\` destination**, allowing their common `REHUB-Windows-x64` folder to merge.
4. Open **`C:\VR\REHUB-Windows-x64\`** and use **`Launch-REHUB.exe`** there.

**Windows may suggest a separate destination named after each ZIP. Change both destinations to the same folder.** Do not leave the runtime and game data in two separate package-named folders, and do not move only the launcher or EXE out of the merged directory.

### Optional extraction helper

Download **`Extract-REHUB.cmd`** from the same Release. Place it in a folder alongside both ZIPs, then double-click it. The helper performs local extraction into a common directory; it does not download files or install software. You can use the manual steps above instead.

**GitHub's “Source code” archives are not the playable package.** Keep the extracted executable, libraries, and content folders together. Do not run the program from inside the archive or move only the EXE to another folder.

Unreal Editor and Visual Studio are not needed. If Windows reports a missing Visual C++ runtime, install the prerequisite provided with the release, if present, or use Microsoft's [official x64 Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist). Use the release's included runtime files rather than copying DLLs from unrelated software.

## 3. Online service access and privacy

The author provides the demonstration speech and AI service. You only need to select the dialogue language, microphone, and audio output in the launcher, then start the experience. There is no cloud-account registration or manual API-key setup for ordinary play.

An internet connection is required. Availability and usage capacity depend on the author's accounts, quotas, and upstream service status. The demo does not promise permanent access, unlimited usage, or a permanently free online service. If an online feature is unavailable, check your connection, try again later, or report the issue.

Microphone audio is sent to Alibaba Cloud for recognition. The dialogue path can send recognized text and exercise context to DeepSeek, and assistant text is sent to Alibaba Cloud for speech synthesis. Use the demo only if you are comfortable sending this information to these services.

## 4. Connect Link, configure, and launch

1. Open **Meta Horizon Link** on the PC and connect your Quest 3. Follow [Meta's Link setup guide](https://www.meta.com/help/quest/509273027107091/) if this is your first connection.
2. Put on the headset and enter **Link**. Confirm that you can see the Link environment.
3. On the PC, double-click **`Launch-REHUB.exe`** in the extracted demo folder.
4. Select **Chinese** or **English**, the actual microphone you intend to use, and the output device you will listen through.
5. Start the experience; no cloud credentials need to be entered.
6. Return to the headset and wait for the welcome message to finish before answering.

Select devices from **this computer's** list. Device numbers and endpoint identifiers from the development PC do not identify the same hardware on another PC. If you change the language or microphone after launching the game, close the game and start it again with the updated launcher selection.

For less acoustic echo, play the game through headphones while keeping your chosen microphone as the input. Changing to laptop speakers does not prevent a laptop microphone from recording the game sound again.

## 5. Take part in the exercise

| Control | Action |
|---|---|
| Left thumbstick | Move |
| Right thumbstick left/right | Turn |
| Right controller **A**, first click | Start recording your answer |
| Right controller **A**, second click | Finish and submit your answer |
| Desktop window close / **Alt+F4** | Exit |

**Do not hold A.** Wait for the digital human to finish, click A, pause briefly, speak clearly, pause briefly again, and click A to submit. Wait for the reply before recording another answer.

Answer the question you actually hear. When asked to observe something or take a few breaths, do that first and then report completion. The exercise includes visual observation, sound awareness, cognitive grounding, breathing regulation, and a closing stage. The wording of an AI-assisted follow-up can vary.

## 6. Troubleshooting

| Symptom | What to check |
|---|---|
| Still in the Link room | Confirm Link is connected and the Windows game is running. Verify that Meta Horizon Link is the active OpenXR runtime, then reconnect Link and relaunch the game if needed. |
| No welcome voice | Check the selected output device and its volume. Check network access as well. If the online demonstration service is unavailable, try again later or report the issue. |
| The digital human does not hear you | Confirm the launcher selected the microphone you are speaking into. Check its Windows input level. Try the PC microphone if the Quest input has no signal. |
| A reply seems unrelated | The recognizer may have misheard the answer. Let the digital human finish, then record one short, clear answer again. |
| A question is repeated | Complete the requested step and state completion clearly. Avoid rapidly clicking A or talking over the digital human. |
| Online speech or AI service unavailable | Check your internet connection, retry later, or report the issue. Service access depends on the author's account quotas and upstream availability. |
| Stuttering | Test with screen recording turned off. Close unnecessary GPU-heavy applications and review Link's graphics settings; performance varies with PC hardware. |
| A DLL, game data, or prerequisite is missing | Confirm that both ZIPs were extracted to the same destination and merged into one `REHUB-Windows-x64` folder. Install the included prerequisites or Microsoft's official x64 runtime if needed. |

Speech recognition, hardware input, and cloud availability cannot be guaranteed on every PC. If you report a problem in [Issues](https://github.com/painfulmoments/Grounding_demo/issues), include the Windows version, GPU, headset, Link connection type, and reproduction steps. Avoid including private personal information in attachments.

REHUB is a research and portfolio prototype and has not been clinically validated as a medical treatment.

[Third-party notices and use of the demo](THIRD_PARTY_NOTICES.md)
