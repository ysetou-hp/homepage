$ErrorActionPreference = 'Stop'

$appPath = Join-Path $PSScriptRoot 'index.html'
$appUrl = ([Uri]$appPath).AbsoluteUri
$html = [IO.File]::ReadAllText($appPath)
$appTitle = [regex]::Match($html, '<title>(.*?)</title>').Groups[1].Value
if ([string]::IsNullOrWhiteSpace($appTitle)) {
    throw 'The app title could not be found in index.html.'
}

Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class MemoAppWindow {
    public delegate bool WindowCallback(IntPtr handle, IntPtr parameter);
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(WindowCallback callback, IntPtr parameter);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetWindowText(IntPtr handle, StringBuilder text, int length);
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr handle);
    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr handle, out uint processId);
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr handle, int command);
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr handle, IntPtr after, int x, int y,
        int width, int height, uint flags);
}
'@

Start-Process -FilePath 'chrome.exe' -ArgumentList @(
    "--app=`"$appUrl`"", '--window-size=800,650'
)

# Chrome can restore a saved size instead of applying --window-size.
# Find this app's visible Chrome window, then set its outer dimensions.
$script:appWindow = [IntPtr]::Zero
$callback = [MemoAppWindow+WindowCallback] {
    param($handle, $parameter)
    if (-not [MemoAppWindow]::IsWindowVisible($handle)) { return $true }
    $title = New-Object Text.StringBuilder 1024
    [void][MemoAppWindow]::GetWindowText($handle, $title, $title.Capacity)
    if ($title.ToString() -ne $appTitle) { return $true }
    [uint32]$windowProcessId = 0
    [void][MemoAppWindow]::GetWindowThreadProcessId($handle, [ref]$windowProcessId)
    $windowProcess = Get-Process -Id $windowProcessId -ErrorAction SilentlyContinue
    if ($null -ne $windowProcess -and $windowProcess.ProcessName -eq 'chrome') {
        $script:appWindow = $handle
        return $false
    }
    return $true
}

$deadline = [DateTime]::UtcNow.AddSeconds(15)
while ([DateTime]::UtcNow -lt $deadline) {
    [void][MemoAppWindow]::EnumWindows($callback, [IntPtr]::Zero)
    if ($script:appWindow -ne [IntPtr]::Zero) { break }
    Start-Sleep -Milliseconds 200
}
if ($script:appWindow -eq [IntPtr]::Zero) {
    throw 'The Chrome app window could not be found.'
}

# Allow Chrome's initial restore to finish before resizing.
Start-Sleep -Milliseconds 750
[void][MemoAppWindow]::ShowWindowAsync($script:appWindow, 9)
Start-Sleep -Milliseconds 100
# SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
if (-not [MemoAppWindow]::SetWindowPos(
    $script:appWindow, [IntPtr]::Zero, 0, 0, 850, 850, 0x0016
)) {
    throw 'The Chrome app window could not be resized.'
}
