# adb_reverse_helper.ps1
# Script to automate adb reverse for connecting physical Android device to local FastAPI server

Write-Host "Starting adb reverse..."
# Try to find adb in standard locations if not in PATH
$adbPath = "adb"
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    if (-not (Test-Path $adbPath)) {
        Write-Host "Could not find adb. Please ensure Android SDK is installed." -ForegroundColor Red
        exit 1
    }
}

& $adbPath reverse tcp:8000 tcp:8000
if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully forwarded port 8000." -ForegroundColor Green
    Write-Host "Your Android device can now access the local server at http://127.0.0.1:8000"
} else {
    Write-Host "Failed to run adb reverse. Make sure your device is connected via USB and USB debugging is enabled." -ForegroundColor Red
}
