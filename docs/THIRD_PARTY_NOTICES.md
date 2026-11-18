# Third-party notices and demo use

## Author-owned material

All rights in the author-owned portions of REHUB are reserved except for permission to download and run this demo for personal, educational, or project-evaluation purposes. Publishing the executable and these documents does not publish the complete project source or grant permission to extract, redistribute, or reuse its assets.

This permission does not replace the terms that apply to third-party components.

## Components and content

| Component | Attribution and applicable terms |
|---|---|
| Unreal Engine | Epic Games, Inc.; subject to the applicable Unreal Engine terms. See the [Unreal Engine EULA](https://www.unrealengine.com/en-US/eula/unreal). |
| MetaHuman technology and character content | Epic Games, Inc.; ownership and applicable Epic terms remain with the original rights holders. |
| Fab / Marketplace environment and other licensed content | The relevant asset creators and licensors retain ownership. Applicable acquisition and distribution terms remain in effect; see [Fab license information](https://www.fab.com/eula). |
| Runtime Audio Importer | Georgy Treshchev; runtime plugin used for audio decoding and playback. The plugin's supplied notices and applicable license remain in effect. |
| Runtime MetaHuman Lip Sync | Georgy Treshchev; runtime lip-sync technology. The plugin's supplied notices and applicable license remain in effect. |
| Convai runtime components | Convai and its licensors; applicable supplied runtime and third-party notices remain in effect. |
| Other runtime libraries and models in the package | Their respective authors and licensors; retain any notices and license files supplied with the release. |

The package may contain runtime libraries or model files required by these components. Their inclusion is not a separate license to reuse the source code, model, character, environment, or audio asset in another project.

## Included license texts

The following original license texts are included in this release. These notices cover the named components and do not replace other applicable third-party terms.

| Component | Original license text | Match used for this release |
|---|---|---|
| ONNX Runtime 1.20 | [MIT license](licenses/ONNXRuntime_v1.20.license) | The Unreal Engine NNERuntimeORT dependency identifies ONNX Runtime 1.20 and its supplied license. |
| libfvad / WebRTC voice activity detection code | [BSD license](licenses/libfvad-LICENSE.txt) | Supplied with the libfvad source compiled by Runtime Audio Importer. This is not a complete license inventory for Convai's WebRTC runtime. |
| OpenCV 4.5.5 | [Apache 2.0 license](licenses/OpenCV_v4.5.5.license) | Included `opencv_world455.dll`, file version 4.5.5. |
| OpenXR SDK loader | [Apache 2.0 license](licenses/OpenXR-SDK.txt) | Included OpenXR loader and the Unreal Engine OpenXR SDK dependency's supplied license. |
| oneTBB 2021.13.0 | [Apache 2.0 license](licenses/oneTBB_LICENSE.txt) | Included `tbb12.dll`, file version 2021.13.0, matches the supplied oneTBB license. |
| Ogg / Vorbis audio codecs | [BSD license](licenses/OggVorbis1.2.0_License.txt) | The Unreal Engine Ogg/Vorbis dependency metadata explicitly identifies this combined license file. |

The Boost DLLs and Convai runtime retain their applicable original terms. This selected list does not claim to be a complete inventory of every dependency inside those runtimes.

### 随包许可原文

上表链接为随包保留的原始许可文本。libfvad 的许可不代表完整覆盖 Convai WebRTC 的所有依赖；其他第三方组件仍适用各自原有条款。

## External services

Alibaba Cloud Intelligent Speech Interaction and the DeepSeek API are external services used for the cloud-enabled dialogue. Their services, account requirements, billing, and data-processing terms are provided by their respective operators. No ownership of these services or endorsement by their operators is claimed.

Meta Quest and Meta Horizon Link are device and software names belonging to their respective rights holders. REHUB is an independent project.

## 中文摘要

允许下载并运行 REHUB 试玩版，用于个人体验、教学或项目评估；作者自有内容的其他权利保留。此许可不包含完整源码开放，也不授予提取、转发或在其他项目中复用角色、环境、音效、模型和插件的权利。第三方内容仍适用原权利人的条款，随包提供的许可文件和声明应保留。
