using System.Windows;
using Naqra.Core;

namespace Naqra.App;

/// <summary>Runs a wheel choice or a tool window's job with the same toast, sound and Float.</summary>
public static class Runner
{
    /// <summary>A drop on the wheel: tools with options open their window, everything else runs right away.</summary>
    public static void Start(NaqraOperation operation, IReadOnlyList<string> files)
    {
        if (operation.Window is { } window && ToolWindows.Open(window, files)) return;
        Run(operation, files);
    }

    public static void Run(string title, IReadOnlyList<string> files, OperationWork work, bool producesFiles = true) =>
        Run(new NaqraOperation("window", title, "", work) { ProducesFiles = producesFiles }, files);

    public static async void Run(NaqraOperation operation, IReadOnlyList<string> files)
    {
        var hud = Hud.Shared;
        hud.ShowMessage($"{operation.Title}…", Hud.Style.Working);
        var dispatcher = Application.Current.Dispatcher;
        var context = new OperationContext(
            text => dispatcher.BeginInvoke(() => hud.Update(text)),
            fraction => dispatcher.BeginInvoke(() => hud.SetProgress(fraction)));
        try
        {
            var outputs = await Task.Run(() => operation.Run(files, context));
            var message = context.Message ?? outputs.Count switch
            {
                0 => $"{operation.Title} done",
                1 => $"Saved {Path.GetFileName(outputs[0])}",
                _ => $"Saved {outputs.Count} files",
            };
            hud.ShowMessage(message, Hud.Style.Success);
            Sounds.Done();
            if (operation.ProducesFiles && outputs.Count > 0 && Settings.Current.ShowResultsInFloat) Floats.ShowResults(outputs);
        }
        catch (Exception e)
        {
            Log.Write($"{operation.Id} failed: {e}");
            hud.ShowMessage(e is NaqraException ? e.Message : L10n.T("Something went wrong: ") + e.Message, Hud.Style.Failure);
            Sounds.Failed();
        }
    }
}

/// <summary>A small log in %APPDATA%\Naqra\naqra.log, for bug reports.</summary>
public static class Log
{
    private static readonly string FilePath = Path.Combine(Settings.Folder, "naqra.log");
    private static readonly object Gate = new();

    public static void Write(string text)
    {
        try
        {
            lock (Gate)
            {
                Directory.CreateDirectory(Settings.Folder);
                if (File.Exists(FilePath) && new FileInfo(FilePath).Length > 2_000_000) File.Delete(FilePath);
                File.AppendAllText(FilePath, $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} {text}{Environment.NewLine}");
            }
        }
        catch (IOException) { }
    }
}
