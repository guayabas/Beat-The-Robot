# Function to bring a window with a specific title to the foreground
param (
    [string]$windowTitle,
    [int]$processId
)

# Get the window with the specified title
$window = Get-Process | Where-Object { $_.ProcessName -eq $windowTitle -and $_.Id -eq $processId }

if ($window) {
    # Use the Windows API to set the window to the foreground
    $hwnd = $window.MainWindowHandle
    $signature = @"
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
"@
    Add-Type -MemberDefinition $signature -Name "Win32SetForegroundWindow" -Namespace "Win32Functions" -PassThru
    [Win32Functions.Win32SetForegroundWindow]::SetForegroundWindow($hwnd)
} else {
    Write-Host "Window not found."
}
