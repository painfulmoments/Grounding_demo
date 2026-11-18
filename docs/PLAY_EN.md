# Play REHUB on Windows with Quest 3

[Download](https://github.com/painfulmoments/REHUB-Demo/releases/latest) · [Project overview](../README.md) · [中文说明](PLAY_ZH.md)

## 1. Check the setup

This release is a **Windows x64 PC VR application**. Development/editor testing used **Meta Quest 3, Touch controllers, and wired Meta Horizon Link**; this first packaged release has not yet completed a full headset playthrough. It is not an APK installed on the headset. Other headsets and Air Link are unverified for this release.

You need:

- A Windows x64 PC that meets [Meta Horizon Link's requirements](https://www.meta.com/help/quest/140991407990979/).
- Meta Horizon Link installed on the PC, a connected Quest 3, and its controllers.
- A working Windows microphone. A PC microphone is a valid choice; headset microphones do not work reliably on every Link setup.
- Headphones for playback, or a sufficiently quiet setup to keep game audio out of the microphone.
- Internet access, an enabled Alibaba Cloud Intelligent Speech Interaction account, and a DeepSeek API account for the cloud-enabled dialogue.

The development test PC used Windows 11, an RTX 5070 Laptop GPU with 8 GB VRAM, and 32 GB RAM. This is a reference test configuration, not a validated minimum specification.

## 2. Download the playable package

**Download BOTH ZIPs from the same Release. Extract BOTH to the same destination folder.**

Open the [latest Release](https://github.com/painfulmoments/REHUB-Demo/releases/latest). Under **Assets**, download:

- **`REHUB-Windows-x64-v1.0.0-Runtime.zip`**
- **`REHUB-Windows-x64-v1.0.0-GameData.zip`**

These are two independent ZIP archives, not split 7-Zip volumes. Both are required. No 7-Zip installation is needed.

### Manual extraction

1. Create or choose one destination, for example **`C:\VR\`**.
2. Extract the Runtime ZIP to **`C:\VR\`**.
3. Extract the GameData ZIP to the **same `C:\VR\` destination**, allowing their common `REHUB-Windows-x64` folder to merge.
4. Open **`C:\VR\REHUB-Windows-x64\`** and use **`Launch-REHUB.cmd`** there.

**Windows may suggest a separate destination named after each ZIP. Change both destinations to the same folder.** Do not leave the runtime and game data in two separate package-named folders, and do not move only the launcher or EXE out of the merged directory.

### Optional extraction helper

Download **`Extract-REHUB.cmd`** from the same Release. Place it in a folder alongside both ZIPs, then double-click it. The helper performs local extraction into a common directory; it does not download files or install software. You can use the manual steps above instead.

**GitHub's “Source code” archives are not the playable package.** Keep the extracted executable, libraries, and content folders together. Do not run the program from inside the archive or move only the EXE to another folder.

Unreal Editor and Visual Studio are not needed. If Windows reports a missing Visual C++ runtime, install the prerequisite provided with the release, if present, or use Microsoft's [official x64 Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist). Use the release's included runtime files rather than copying DLLs from unrelated software.

## 3. Prepare the cloud credentials

The public demo uses your own cloud accounts. No shared service key is included. Prepare these values for the launcher:

| Launcher value | Purpose |
|---|---|
| Alibaba Cloud AccessKey ID | Account authentication for the speech service |
| Alibaba Cloud AccessKey Secret | The matching secret for that AccessKey ID |
| Alibaba Cloud NLS AppKey | Speech-service project identifier |
| English recognition AppKey, when used | A separate NLS project for English speech recognition |
| DeepSeek API key | AI-assisted conversational replies |

### Alibaba Cloud speech

Activate Intelligent Speech Interaction, create an NLS project, and obtain its AppKey. Select and **publish** the recognition configuration that matches the language you will speak. Each AppKey identifies a project and its cloud configuration. See [Alibaba Cloud's project setup instructions](https://help.aliyun.com/en/isi/getting-started/manage-projects).

For English recognition, use a published general-English model for **16 kHz** audio. If the launcher is configured with a separate English-recognition AppKey, it must point to that English project. Changing REHUB's dialogue language does **not** change the cloud ASR model: the ASR language and scenario are selected in the NLS console, not in the recognition request. See the [official one-sentence recognition API](https://help.aliyun.com/zh/isi/user-guide/restful-api-2).

The English speech voice used by this project is **`cally`**, documented as an American English voice supporting 16 kHz synthesis. Voice availability depends on the service account and configuration. See the [official voice table](https://help.aliyun.com/en/isi/user-guide/overview-of-speech-synthesis).

### DeepSeek

Obtain a key from the [DeepSeek platform](https://platform.deepseek.com/) and enter it in the launcher. The launcher defaults to **`deepseek-flash`** and allows you to change the model. Model names and service availability can change; if a model is rejected, check the [official model list](https://api-docs.deepseek.com/api/list-models/) and [API setup guide](https://api-docs.deepseek.com/quick_start/) for a model currently supported by your account.

The cloud services can charge your accounts. Microphone audio is sent to Alibaba Cloud for recognition; the dialogue path can send recognized text and exercise context to DeepSeek; assistant text is sent to Alibaba Cloud for speech synthesis. Enter credentials only in the local setup. Do not include them in public screenshots or issue reports.

## 4. Connect Link, configure, and launch

1. Open **Meta Horizon Link** on the PC and connect your Quest 3. Follow [Meta's Link setup guide](https://www.meta.com/help/quest/509273027107091/) if this is your first connection.
2. Put on the headset and enter **Link**. Confirm that you can see the Link environment.
3. On the PC, double-click **`Launch-REHUB.cmd`** in the extracted demo folder.
4. Select **Chinese** or **English**, the actual microphone you intend to use, and the output device you will listen through.
5. Enter your cloud credentials and start the experience.
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
| No welcome voice | Check the selected output device and its volume. Then check NLS activation, credentials, project configuration, and network access. |
| The digital human does not hear you | Confirm the launcher selected the microphone you are speaking into. Check its Windows input level. Try the PC microphone if the Quest input has no signal. |
| A reply seems unrelated | The recognizer may have misheard the answer. Let the digital human finish, then record one short, clear answer again. |
| A question is repeated | Complete the requested step and state completion clearly. Avoid rapidly clicking A or talking over the digital human. |
| Cloud authentication or model error | Recheck the credentials, project activation, published ASR language, account access, and current model availability. |
| Stuttering | Test with screen recording turned off. Close unnecessary GPU-heavy applications and review Link's graphics settings; performance varies with PC hardware. |
| A DLL, game data, or prerequisite is missing | Confirm that both ZIPs were extracted to the same destination and merged into one `REHUB-Windows-x64` folder. Install the included prerequisites or Microsoft's official x64 runtime if needed. |

Speech recognition, hardware input, and cloud availability cannot be guaranteed on every PC. If you report a problem in [Issues](https://github.com/painfulmoments/REHUB-Demo/issues), include the Windows version, GPU, headset, Link connection type, and reproduction steps. Remove credentials from attachments.

REHUB is a research and portfolio prototype and has not been clinically validated as a medical treatment.

[Third-party notices and use of the demo](THIRD_PARTY_NOTICES.md)
