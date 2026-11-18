using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using Microsoft.Win32;

internal static class Program
{
    internal const string LanguageSection = "/Script/REHUB.REHUBLanguageSettings";
    internal static readonly string SettingsPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "REHUBDemo", "Config", "Game.ini");

    [STAThread]
    private static int Main(string[] args)
    {
        try
        {
            if (Array.IndexOf(args, "--validate-only") >= 0)
            {
                string result = Validate();
                Console.WriteLine(result);
                foreach (string arg in args)
                    if (arg.StartsWith("--validation-result=", StringComparison.Ordinal))
                        File.WriteAllText(arg.Substring("--validation-result=".Length), result, new UTF8Encoding(true));
                return 0;
            }
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new SettingsForm());
            return 0;
        }
        catch (Exception ex)
        {
            if (Array.IndexOf(args, "--validate-only") >= 0) { Console.Error.WriteLine(ex.Message); return 1; }
            MessageBox.Show(ex.Message, "REHUB launcher", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }

    internal static Dictionary<string, string> ReadPreferences(string path)
    {
        var preferences = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (!File.Exists(path)) return preferences;
        string section = "";
        foreach (string line in File.ReadLines(path, Encoding.UTF8))
        {
            string text = line.Trim();
            if (text.Length == 0 || text[0] == ';' || text[0] == '#') continue;
            if (text.StartsWith("[") && text.EndsWith("]")) { section = text.Substring(1, text.Length - 2); continue; }
            int separator = text.IndexOf('=');
            if (separator < 1) continue;
            string key = text.Substring(0, separator).Trim();
            bool allowed = (section.Equals(LanguageSection, StringComparison.OrdinalIgnoreCase) && (key.Equals("DialogueLanguage", StringComparison.OrdinalIgnoreCase) || key.Equals("MicrophoneDeviceId", StringComparison.OrdinalIgnoreCase)))
                || (section.Equals("REHUB.Audio", StringComparison.OrdinalIgnoreCase) && key.Equals("PreferredOutputDeviceNameContains", StringComparison.OrdinalIgnoreCase));
            if (!allowed) continue;
            string value = text.Substring(separator + 1).Trim();
            if (value.Length >= 2 && value[0] == '"' && value[value.Length - 1] == '"') value = value.Substring(1, value.Length - 2);
            preferences[key] = value;
        }
        return preferences;
    }

    internal static string Quoted(string value)
    {
        value = (value ?? "").Trim();
        foreach (char ch in value) if (ch == '"' || Char.IsControl(ch)) throw new InvalidOperationException("A device name contains an unsupported character. / 设备名称包含不支持的字符。");
        return "\"" + value + "\"";
    }

    internal static string NewGameIni(string language, string microphone, string output)
    {
        return "; REHUB demo: language and audio preferences for this computer.\r\n"
            + "[SectionsToSave]\r\nbCanSaveAllSections=True\r\n\r\n"
            + "[REHUB.AI]\r\nDeepSeekModel=\"deepseek-flash\"\r\n\r\n"
            + "[" + LanguageSection + "]\r\nDialogueLanguage=" + (language == "Chinese" ? "Chinese" : "English")
            + "\r\nMicrophoneDeviceId=" + Quoted(microphone)
            + "\r\nbAutoSwitchMicrophoneOnNoAudio=True\r\nEnglishVoice=\"cally\"\r\n\r\n"
            + "[REHUB.Audio]\r\nPreferredOutputDeviceNameContains=" + Quoted(output) + "\r\n";
    }

    internal static List<Endpoint> Endpoints(bool input)
    {
        var endpoints = new List<Endpoint>();
        string path = @"SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\" + (input ? "Capture" : "Render");
        using (RegistryKey root = Registry.LocalMachine.OpenSubKey(path))
        {
            if (root == null) return endpoints;
            foreach (string id in root.GetSubKeyNames())
            {
                using (RegistryKey device = root.OpenSubKey(id))
                {
                    if (device == null || Convert.ToInt32(device.GetValue("DeviceState", 0)) != 1) continue;
                    using (RegistryKey properties = device.OpenSubKey("Properties"))
                    {
                        string name = Property(properties, "{a45c254e-df1c-4efd-8020-67d146a850e0},14");
                        if (name.Length == 0)
                        {
                            string description = Property(properties, "{a45c254e-df1c-4efd-8020-67d146a850e0},2");
                            string adapter = Property(properties, "{b3f8fa53-0004-438e-9003-51a46e139bfc},6");
                            name = description.Length > 0 ? description + (adapter.Length > 0 ? " (" + adapter + ")" : "") : id;
                        }
                        endpoints.Add(new Endpoint(name, (input ? "{0.0.1.00000000}." : "{0.0.0.00000000}.") + id, name));
                    }
                }
            }
        }
        endpoints.Sort(delegate(Endpoint a, Endpoint b) { return StringComparer.CurrentCultureIgnoreCase.Compare(a.Name, b.Name); });
        return endpoints;
    }

    private static string Property(RegistryKey key, string name)
    {
        return key == null ? "" : key.GetValue(name, "") as string ?? "";
    }

    internal static void CheckPackage(string root)
    {
        string paks = Path.Combine(root, "REHUB", "Content", "Paks");
        if (!NonEmpty(Path.Combine(root, "REHUB.exe")) || !NonEmpty(Path.Combine(root, "REHUB", "Binaries", "Win64", "REHUB-Win64-Shipping.exe")) || !Directory.Exists(paks))
            throw new InvalidOperationException("The complete Windows demo is missing. Extract both release ZIPs into the same folder and keep this launcher beside REHUB.exe.\r\n请将两个试玩 ZIP 完整解压到同一个目标文件夹，将启动器放在 REHUB.exe 旁。 ");
        foreach (string name in new[] { "global.ucas", "REHUB-Windows.ucas" })
            if (!NonEmpty(Path.Combine(paks, name)))
                throw new InvalidOperationException("Game data is missing. Download BOTH Runtime.zip and GameData.zip, then extract both into the SAME destination folder.\r\n缺少游戏资源，请下载两个 ZIP，并解压到同一个目标目录。");
    }

    private static bool NonEmpty(string path) { return File.Exists(path) && new FileInfo(path).Length > 0; }

    private static string Validate()
    {
        List<Endpoint> inputs = Endpoints(true), outputs = Endpoints(false);
        string english = NewGameIni("English", "default", "Headphones (Example)");
        string chinese = NewGameIni("Chinese", "{0.0.1.00000000}.{example}", "Example output");
        if (!english.Contains("DialogueLanguage=English") || !chinese.Contains("DialogueLanguage=Chinese") || !english.Contains("DeepSeekModel=\"deepseek-flash\"")) throw new Exception("Preference serialization failed.");
        foreach (string term in new[] { "AccessKey", "ApiKey", "AppKey", "Secret", "Token" })
            if (english.IndexOf(term, StringComparison.OrdinalIgnoreCase) >= 0) throw new Exception("Unexpected provider field in preferences.");
        bool rejected = false;
        try { NewGameIni("English", "default\r\nUnexpected=True", ""); } catch (InvalidOperationException) { rejected = true; }
        if (!rejected) throw new Exception("Invalid INI characters were accepted.");
        return "{\r\n  \"Valid\": true,\r\n  \"ActiveMicrophones\": " + inputs.Count + ",\r\n  \"ActiveOutputs\": " + outputs.Count
            + ",\r\n  \"DefaultInputFound\": " + (AudioDefault.Read(1).Length > 0 ? "true" : "false")
            + ",\r\n  \"DefaultOutputFound\": " + (AudioDefault.Read(0).Length > 0 ? "true" : "false")
            + ",\r\n  \"ProviderCredentialsWritten\": false,\r\n  \"RecordedAudio\": false,\r\n  \"NetworkRequests\": false\r\n}";
    }
}

internal sealed class Endpoint
{
    public string Display { get; private set; }
    public string Id { get; private set; }
    public string Name { get; private set; }
    public Endpoint(string display, string id, string name) { Display = display; Id = id; Name = name; }
    public override string ToString() { return Display; }
}

internal sealed class SettingsForm : Form
{
    private readonly ComboBox language = new ComboBox();
    private readonly ComboBox microphone = new ComboBox();
    private readonly ComboBox output = new ComboBox();
    private readonly Label status = new Label();
    private readonly List<Endpoint> inputs = Program.Endpoints(true);
    private readonly List<Endpoint> outputs = Program.Endpoints(false);
    private readonly string defaultOutputName;

    internal SettingsForm()
    {
        Text = "REHUB - Play settings / 试玩设置";
        Font = new Font("Segoe UI", 10F);
        AutoScaleMode = AutoScaleMode.Dpi;
        ClientSize = new Size(880, 420);
        MinimumSize = new Size(850, 460);
        StartPosition = FormStartPosition.CenterScreen;
        ShowInTaskbar = true;
        var saved = Program.ReadPreferences(Program.SettingsPath);
        string defaultOutputId = AudioDefault.Read(0);
        defaultOutputName = "";
        foreach (Endpoint endpoint in outputs) if (endpoint.Id.Equals(defaultOutputId, StringComparison.OrdinalIgnoreCase)) { defaultOutputName = endpoint.Name; break; }

        var layout = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(22), ColumnCount = 1, RowCount = 4 };
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 88));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 144));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 48));
        Controls.Add(layout);
        var intro = new Label { Dock = DockStyle.Fill, Text = "Connect Quest Link before starting. Select a microphone and headphones.\r\n先连接 Quest Link，再选择麦克风与播放设备。耳机播放有助于减少回声。\r\nInternet access is required for speech and AI dialogue. 语音对话需要联网。" };
        layout.Controls.Add(intro, 0, 0);
        var choices = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 2, RowCount = 3 };
        choices.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 270));
        choices.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        for (int i = 0; i < 3; ++i) choices.RowStyles.Add(new RowStyle(SizeType.Percent, 33.3333F));
        layout.Controls.Add(choices, 0, 1);
        language.Items.Add("English / 英文"); language.Items.Add("Chinese / 中文");
        string savedLanguage; language.SelectedIndex = saved.TryGetValue("DialogueLanguage", out savedLanguage) && savedLanguage == "Chinese" ? 1 : 0;
        AddRow(choices, 0, "Dialogue language / 对话语言", language);
        PopulateDevices(microphone, inputs, Preference(saved, "MicrophoneDeviceId", "default"), false);
        PopulateDevices(output, outputs, Preference(saved, "PreferredOutputDeviceNameContains", ""), true);
        AddRow(choices, 1, "Microphone / 录音麦克风", microphone);
        AddRow(choices, 2, "Sound output / 声音播放设备", output);
        status.Dock = DockStyle.Fill; status.ForeColor = Color.DarkSlateGray; status.Padding = new Padding(0, 8, 0, 0);
        status.Text = "Your language and audio selections are remembered on this PC.\r\n此电脑会记住语言和声音设置。更换设备后，请重新打开此窗口。";
        layout.Controls.Add(status, 0, 2);
        var buttons = new FlowLayoutPanel { Dock = DockStyle.Fill, FlowDirection = FlowDirection.RightToLeft, WrapContents = false };
        var start = new Button { Text = "Save and start VR / 保存并启动", Size = new Size(280, 40) };
        var save = new Button { Text = "Save settings / 保存设置", Size = new Size(245, 40) };
        start.Click += delegate { TryAction(true); }; save.Click += delegate { TryAction(false); };
        buttons.Controls.Add(start); buttons.Controls.Add(save); layout.Controls.Add(buttons, 0, 3);
        AcceptButton = start;
        Shown += delegate { WindowState = FormWindowState.Normal; Activate(); BringToFront(); };
    }

    private static string Preference(Dictionary<string, string> saved, string key, string fallback) { string value; return saved.TryGetValue(key, out value) ? value : fallback; }
    private static void AddRow(TableLayoutPanel table, int row, string caption, ComboBox combo)
    {
        var label = new Label { Text = caption, Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft, Margin = new Padding(0, 0, 8, 0) };
        combo.DropDownStyle = ComboBoxStyle.DropDownList; combo.Dock = DockStyle.Fill; combo.Margin = new Padding(0, 8, 0, 8); combo.DropDownWidth = 620;
        table.Controls.Add(label, 0, row); table.Controls.Add(combo, 1, row);
    }
    private void PopulateDevices(ComboBox combo, List<Endpoint> devices, string saved, bool playback)
    {
        string defaultName = playback ? defaultOutputName : "";
        combo.Items.Add(new Endpoint("Windows default / 系统默认" + (defaultName.Length > 0 ? " - " + defaultName : ""), "default", defaultName));
        foreach (Endpoint device in devices) combo.Items.Add(device);
        combo.SelectedIndex = 0;
        for (int i = 1; i < combo.Items.Count; ++i)
        {
            Endpoint item = (Endpoint)combo.Items[i];
            if ((playback ? item.Name : item.Id).Equals(saved, StringComparison.OrdinalIgnoreCase)) { combo.SelectedIndex = i; break; }
        }
    }
    private void TryAction(bool launch)
    {
        try
        {
            if (launch)
            {
                if (inputs.Count == 0) throw new InvalidOperationException("No active microphone found. Connect a recording device and reopen this launcher.\r\n未找到可用麦克风，请连接设备后重新打开启动器。");
                if (outputs.Count == 0 || (output.SelectedIndex == 0 && defaultOutputName.Length == 0)) throw new InvalidOperationException("Select an available playback device. / 请选择可用播放设备。");
                Program.CheckPackage(AppDomain.CurrentDomain.BaseDirectory);
            }
            Endpoint mic = (Endpoint)microphone.SelectedItem, speaker = (Endpoint)output.SelectedItem;
            string ini = Program.NewGameIni(language.SelectedIndex == 1 ? "Chinese" : "English", mic.Id, speaker.Name);
            Directory.CreateDirectory(Path.GetDirectoryName(Program.SettingsPath));
            File.WriteAllText(Program.SettingsPath, ini, new UTF8Encoding(true));
            status.ForeColor = Color.DarkGreen; status.Text = "Saved on this computer. / 已保存到本机。\r\n" + Program.SettingsPath;
            if (!launch) return;
            var start = new ProcessStartInfo(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "REHUB.exe"));
            start.WorkingDirectory = AppDomain.CurrentDomain.BaseDirectory;
            start.Arguments = "-GameIni=\"" + Program.SettingsPath + "\" -vr -windowed -ResX=1280 -ResY=720";
            start.UseShellExecute = false;
            Process.Start(start);
            Close();
        }
        catch (Exception ex) { MessageBox.Show(this, ex.Message, "REHUB", MessageBoxButtons.OK, MessageBoxIcon.Error); }
    }
}

internal static class AudioDefault
{
    [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] private class Enumerator { }
    [ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IEnumerator
    {
        [PreserveSig] int EnumAudioEndpoints(int flow, uint state, out IntPtr devices);
        [PreserveSig] int GetDefaultAudioEndpoint(int flow, int role, out IDevice device);
        [PreserveSig] int GetDevice([MarshalAs(UnmanagedType.LPWStr)] string id, out IDevice device);
    }
    [ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IDevice
    {
        [PreserveSig] int Activate(ref Guid iid, uint context, IntPtr parameters, out IntPtr obj);
        [PreserveSig] int OpenPropertyStore(int access, out IntPtr store);
        [PreserveSig] int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);
        [PreserveSig] int GetState(out uint state);
    }
    internal static string Read(int flow)
    {
        IEnumerator enumerator = null; IDevice device = null;
        try
        {
            enumerator = (IEnumerator)new Enumerator();
            if (enumerator.GetDefaultAudioEndpoint(flow, 0, out device) < 0 || device == null) return "";
            string id; return device.GetId(out id) < 0 ? "" : id;
        }
        catch (COMException) { return ""; }
        finally
        {
            if (device != null) Marshal.ReleaseComObject(device);
            if (enumerator != null) Marshal.ReleaseComObject(enumerator);
        }
    }
}
