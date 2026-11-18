#requires -Version 5.1
param([switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'
$script:ApplicationRoot = $PSScriptRoot
$script:SettingsPath = Join-Path $env:LOCALAPPDATA 'REHUBDemo\Config\Game.ini'
$script:LanguageSection = '/Script/REHUB.REHUBLanguageSettings'

function Get-IniSettings {
    param([string]$Path)
    $settings = @{}
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $settings }
    $section = ''
    foreach ($line in [IO.File]::ReadAllLines($Path, [Text.Encoding]::UTF8)) {
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith(';') -or $trimmed.StartsWith('#')) { continue }
        if ($trimmed -match '^\[([^\]]+)\]$') { $section = $Matches[1]; continue }
        $separator = $trimmed.IndexOf('=')
        if ($separator -lt 1) { continue }
        $key = $trimmed.Substring(0, $separator).Trim()
        $allowed = ($section -eq $script:LanguageSection -and $key -in @('DialogueLanguage','MicrophoneDeviceId')) -or ($section -eq 'REHUB.Audio' -and $key -eq 'PreferredOutputDeviceNameContains')
        if (-not $allowed) { continue }
        $value = $trimmed.Substring($separator + 1).Trim()
        if ($value.Length -ge 2 -and $value.StartsWith('"') -and $value.EndsWith('"')) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        $settings[($section + '|' + $key)] = $value
    }
    return $settings
}

function Get-SettingValue {
    param([hashtable]$Settings, [string]$Section, [string]$Key, [string]$Default = '')
    $lookup = $Section + '|' + $Key
    if ($Settings.ContainsKey($lookup)) { return [string]$Settings[$lookup] }
    return $Default
}

function ConvertTo-IniString {
    param([AllowEmptyString()][string]$Value)
    # Double-quote each INI value so URLs are not truncated at //.
    if ($Value -match '[\x00-\x1F\x7F"]') {
        throw 'A setting contains a quote or control character. Remove it and try again.'
    }
    return '"' + $Value.Trim() + '"'
}

function New-GameIni {
    param([hashtable]$Values)
    $microphoneValue = ConvertTo-IniString ([string]$Values.MicrophoneDeviceId)
    $outputValue = ConvertTo-IniString ([string]$Values.PreferredOutputDeviceNameContains)
    $dialogueLanguage = if ($Values.DialogueLanguage -eq 'Chinese') { 'Chinese' } else { 'English' }
    return @"
; REHUB demo: language and audio preferences for this computer.
[SectionsToSave]
bCanSaveAllSections=True

[REHUB.AI]
DeepSeekModel="deepseek-flash"

[$script:LanguageSection]
DialogueLanguage=$dialogueLanguage
MicrophoneDeviceId=$microphoneValue
bAutoSwitchMicrophoneOnNoAudio=True
EnglishVoice="cally"

[REHUB.Audio]
PreferredOutputDeviceNameContains=$outputValue
"@
}

function Get-RegistryString {
    param($Properties, [string]$Name)
    $property = $Properties.PSObject.Properties[$Name]
    if ($null -ne $property -and $property.Value -is [string]) { return [string]$property.Value }
    return ''
}

function Get-ActiveAudioEndpoints {
    param([ValidateSet('Capture', 'Render')][string]$Flow)
    $root = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\' + $Flow
    $prefix = if ($Flow -eq 'Capture') { '{0.0.1.00000000}.' } else { '{0.0.0.00000000}.' }
    if (-not (Test-Path -LiteralPath $root)) { return }
    foreach ($device in Get-ChildItem -LiteralPath $root) {
        $state = (Get-ItemProperty -LiteralPath $device.PSPath).DeviceState
        if ($state -ne 1) { continue }
        $properties = Get-ItemProperty -LiteralPath (Join-Path $device.PSPath 'Properties')
        $name = Get-RegistryString $properties '{a45c254e-df1c-4efd-8020-67d146a850e0},14'
        if (-not $name) {
            $description = Get-RegistryString $properties '{a45c254e-df1c-4efd-8020-67d146a850e0},2'
            $adapter = Get-RegistryString $properties '{b3f8fa53-0004-438e-9003-51a46e139bfc},6'
            if ($description -and $adapter) { $name = "$description ($adapter)" }
            elseif ($description) { $name = $description }
            else { $name = $device.PSChildName }
        }
        [pscustomobject]@{ Display = $name; Name = $name; Id = ($prefix + $device.PSChildName) }
    }
}

function Initialize-AudioDefaultReader {
    if ('REHUBDemoAudio.DefaultEndpoint' -as [type]) { return }
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace REHUBDemoAudio {
    [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] public class Enumerator { }
    [ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IEnumerator {
        int EnumAudioEndpoints(int flow, uint state, out IntPtr devices);
        int GetDefaultAudioEndpoint(int flow, int role, out IDevice device);
        int GetDevice([MarshalAs(UnmanagedType.LPWStr)] string id, out IDevice device);
    }
    [ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IDevice {
        int Activate(ref Guid iid, uint context, IntPtr parameters, out IntPtr obj);
        int OpenPropertyStore(int access, out IntPtr store);
        int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);
        int GetState(out uint state);
    }
    public static class DefaultEndpoint {
        public static string Read(int flow) {
            IEnumerator enumerator = null; IDevice device = null;
            try {
                enumerator = (IEnumerator)new Enumerator();
                if (enumerator.GetDefaultAudioEndpoint(flow, 0, out device) < 0 || device == null) return "";
                string id; return device.GetId(out id) < 0 ? "" : id;
            } catch (COMException) { return ""; }
            finally {
                if (device != null) Marshal.ReleaseComObject(device);
                if (enumerator != null) Marshal.ReleaseComObject(enumerator);
            }
        }
    }
}
'@
}

if ($ValidateOnly) {
    Initialize-AudioDefaultReader
    $inputs = @(Get-ActiveAudioEndpoints Capture)
    $outputs = @(Get-ActiveAudioEndpoints Render)
    $example = @{
        DialogueLanguage='English'; MicrophoneDeviceId='default'; PreferredOutputDeviceNameContains=''
    }
    $iniText = New-GameIni $example
    if ($iniText -match '(?i)AccessKey|ApiKey|AppKey|Secret|Token') { throw 'Unexpected provider credential setting in generated preferences.' }
    if ($iniText -notmatch 'DeepSeekModel="deepseek-flash"') { throw 'Model preference is missing.' }
    [pscustomobject]@{
        Valid = $true; ActiveMicrophones = $inputs.Count; ActiveOutputs = $outputs.Count
        DefaultInputFound = -not [string]::IsNullOrEmpty([REHUBDemoAudio.DefaultEndpoint]::Read(1))
        DefaultOutputFound = -not [string]::IsNullOrEmpty([REHUBDemoAudio.DefaultEndpoint]::Read(0))
        ConfigPath = $script:SettingsPath; ProviderCredentialsWritten = $false
        RecordedAudio = $false; NetworkRequests = $false
    } | ConvertTo-Json
    exit 0
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

try {
    Initialize-AudioDefaultReader
    $saved = Get-IniSettings $script:SettingsPath
    $script:inputEndpoints = @(Get-ActiveAudioEndpoints Capture)
    $script:outputEndpoints = @(Get-ActiveAudioEndpoints Render)
    $defaultOutputId = [REHUBDemoAudio.DefaultEndpoint]::Read(0)
    $defaultOutput = @($script:outputEndpoints | Where-Object { $_.Id -eq $defaultOutputId })
    $script:defaultOutputName = if ($defaultOutput.Count -gt 0) { $defaultOutput[0].Name } else { '' }

    $form = New-Object Windows.Forms.Form
    $form.Text = 'REHUB - Play settings / 试玩设置'
    $form.ClientSize = New-Object Drawing.Size(820, 400)
    $form.MinimumSize = New-Object Drawing.Size(836, 439)
    $form.ShowInTaskbar = $true
    $form.Add_Shown({ $form.WindowState = 'Normal'; $form.Activate(); $form.BringToFront() })
    $form.StartPosition = 'CenterScreen'
    $form.Font = New-Object Drawing.Font('Segoe UI', 9)
    $form.AutoScaleMode = 'Dpi'

    $intro = New-Object Windows.Forms.Label
    $intro.Location = New-Object Drawing.Point(22, 16)
    $intro.Size = New-Object Drawing.Size(775, 72)
    $intro.Text = "Connect Quest Link before starting. Select a working microphone and headphones.`r`n先连接 Quest Link，再选择本机可用的麦克风与播放设备。耳机播放有助于减少回声。`r`nInternet access is required for speech and AI dialogue. 语音对话需要联网。"
    $form.Controls.Add($intro)

    $script:rowY = 96
    function Add-RowControl {
        param([string]$Label, [Windows.Forms.Control]$Control)
        $caption = New-Object Windows.Forms.Label
        $caption.Text = $Label
        $caption.Location = New-Object Drawing.Point(22, ($script:rowY + 5))
        $caption.Size = New-Object Drawing.Size(252, 28)
        $Control.Location = New-Object Drawing.Point(280, $script:rowY)
        $Control.Size = New-Object Drawing.Size(513, 27)
        $form.Controls.Add($caption)
        $form.Controls.Add($Control)
        $script:rowY += 39
    }

    $language = New-Object Windows.Forms.ComboBox
    $language.DropDownStyle = 'DropDownList'
    [void]$language.Items.Add('English / 英文')
    [void]$language.Items.Add('Chinese / 中文')
    $language.SelectedIndex = if ((Get-SettingValue $saved $script:LanguageSection 'DialogueLanguage' 'English') -eq 'Chinese') { 1 } else { 0 }
    Add-RowControl 'Dialogue language / 对话语言' $language

    function New-DeviceCombo {
        param([object[]]$Endpoints, [string]$SavedValue, [switch]$IsOutput)
        $combo = New-Object Windows.Forms.ComboBox
        $combo.DropDownStyle = 'DropDownList'
        $combo.DisplayMember = 'Display'
        $defaultCaption = if ($IsOutput -and $script:defaultOutputName) { 'Windows default / 系统默认 - ' + $script:defaultOutputName } else { 'Windows default / 系统默认' }
        [void]$combo.Items.Add([pscustomobject]@{Display=$defaultCaption;Name='';Id='default'})
        foreach ($endpoint in $Endpoints) { [void]$combo.Items.Add($endpoint) }
        $combo.SelectedIndex = 0
        for ($i=1; $i -lt $combo.Items.Count; $i++) {
            $matchesSaved = if ($IsOutput) { $combo.Items[$i].Name -eq $SavedValue } else { $combo.Items[$i].Id -eq $SavedValue }
            if ($matchesSaved) { $combo.SelectedIndex = $i; break }
        }
        return $combo
    }
    $microphone = New-DeviceCombo $script:inputEndpoints (Get-SettingValue $saved $script:LanguageSection 'MicrophoneDeviceId' 'default')
    Add-RowControl 'Recording microphone / 录音麦克风' $microphone
    $output = New-DeviceCombo $script:outputEndpoints (Get-SettingValue $saved 'REHUB.Audio' 'PreferredOutputDeviceNameContains') -IsOutput
    Add-RowControl 'Sound output / 声音播放设备' $output

    $status = New-Object Windows.Forms.Label
    $status.Location = New-Object Drawing.Point(22, 240)
    $status.Size = New-Object Drawing.Size(775, 60)
    $status.ForeColor = [Drawing.Color]::DarkSlateGray
    $status.Text = "Your language and audio selections are remembered on this PC.`r`n此电脑会记住你的语言和声音设置。连接或更换设备后，重新打开此窗口即可刷新列表。"
    $form.Controls.Add($status)

    $save = New-Object Windows.Forms.Button
    $save.Text = 'Save settings / 保存设置'
    $save.Location = New-Object Drawing.Point(280, 330)
    $save.Size = New-Object Drawing.Size(226, 42)
    $form.Controls.Add($save)
    $launch = New-Object Windows.Forms.Button
    $launch.Text = 'Save and start VR / 保存并启动'
    $launch.Location = New-Object Drawing.Point(521, 330)
    $launch.Size = New-Object Drawing.Size(272, 42)
    $form.Controls.Add($launch)

    $collectValues = {
        $values = @{}
        $values.DialogueLanguage = if ($language.SelectedIndex -eq 1) { 'Chinese' } else { 'English' }
        $values.MicrophoneDeviceId = [string]$microphone.SelectedItem.Id
        $values.PreferredOutputDeviceNameContains = if ($output.SelectedIndex -eq 0) { $script:defaultOutputName } else { [string]$output.SelectedItem.Name }
        return $values
    }
    $saveValues = {
        param([hashtable]$Values)
        $iniText = New-GameIni $Values
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($script:SettingsPath))
        [IO.File]::WriteAllText($script:SettingsPath, $iniText, (New-Object Text.UTF8Encoding($true)))
        $status.ForeColor = [Drawing.Color]::DarkGreen
        $status.Text = "Saved on this computer. / 已保存到本机。`r`n$script:SettingsPath"
    }
    $save.Add_Click({
        try { $values = & $collectValues; & $saveValues $values }
        catch { [void][Windows.Forms.MessageBox]::Show($_.Exception.Message, 'REHUB settings', 'OK', 'Error') }
    })
    $launch.Add_Click({
        try {
            $values = & $collectValues
            if ($script:inputEndpoints.Count -eq 0) { throw 'No active microphone found. Connect or enable a recording device, then reopen this launcher. / 未找到可用麦克风。请连接设备后重新打开启动器。' }
            if ($script:outputEndpoints.Count -eq 0 -or ($output.SelectedIndex -eq 0 -and -not $script:defaultOutputName)) { throw 'No usable playback device found. Select a connected output device. / 未找到可用播放设备。' }
            $exe = Join-Path $script:ApplicationRoot 'REHUB.exe'
            $gameBinary = Join-Path $script:ApplicationRoot 'REHUB\Binaries\Win64\REHUB-Win64-Shipping.exe'
            $content = Join-Path $script:ApplicationRoot 'REHUB\Content\Paks'
            if (-not (Test-Path -LiteralPath $exe -PathType Leaf) -or -not (Test-Path -LiteralPath $gameBinary -PathType Leaf) -or -not (Test-Path -LiteralPath $content -PathType Container)) {
                throw 'The complete Windows demo is missing. Extract every folder from the release archive and place this launcher beside REHUB.exe. / 请完整解压试玩包，保留目录结构，并将启动器放在 REHUB.exe 旁。'
            }
            foreach ($containerName in @('global.ucas', 'REHUB-Windows.ucas')) {
                $containerPath = Join-Path $content $containerName
                if (-not (Test-Path -LiteralPath $containerPath -PathType Leaf) -or (Get-Item -LiteralPath $containerPath).Length -eq 0) {
                    throw 'Game data is missing. Download BOTH Runtime.zip and GameData.zip, then extract both into the SAME destination folder. / 缺少游戏资源，请下载两个 ZIP，并解压到同一个目标目录。'
                }
            }
            & $saveValues $values
            $arguments = @(('-GameIni="' + $script:SettingsPath + '"'), '-vr', '-windowed', '-ResX=1280', '-ResY=720')
            Start-Process -FilePath $exe -ArgumentList $arguments -WorkingDirectory $script:ApplicationRoot
            $form.Close()
        }
        catch { [void][Windows.Forms.MessageBox]::Show($_.Exception.Message, 'REHUB could not start', 'OK', 'Error') }
    })
    [void]$form.ShowDialog()
    $form.Dispose()
}
catch {
    [void][Windows.Forms.MessageBox]::Show($_.Exception.Message, 'REHUB launcher', 'OK', 'Error')
    exit 1
}
