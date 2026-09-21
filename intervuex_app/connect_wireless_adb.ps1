# Wireless ADB Helper Script
Param(
    [string]$IPAndPort,
    [string]$PairingPort,
    [string]$PairingCode
)

Write-Host "=== Wireless ADB Setup Helper ===" -ForegroundColor Cyan

if ($PairingPort -and $PairingCode) {
    Write-Host "Pairing device at IP and Port: $IPAndPort (Pairing Port: $PairingPort)..." -ForegroundColor Yellow
    $pairTarget = "$($IPAndPort.Split(':')[0]):$PairingPort"
    echo $PairingCode | adb pair $pairTarget
}

if ($IPAndPort) {
    Write-Host "Connecting to device at $IPAndPort..." -ForegroundColor Yellow
    adb connect $IPAndPort
    Write-Host "Setting up ADB reverse for port 8000 on $IPAndPort..." -ForegroundColor Green
    adb -s $IPAndPort reverse tcp:8000 tcp:8000
    adb devices
} else {
    Write-Host "Auto-reversing on active wireless device..." -ForegroundColor Yellow
    $device = (adb devices | Select-String "192\.168\." | Select-Object -First 1)
    if ($device) {
        $deviceId = $device.ToString().Split("`t")[0].Trim()
        Write-Host "Targeting device: $deviceId" -ForegroundColor Green
        adb -s $deviceId reverse tcp:8000 tcp:8000
    } else {
        Write-Host "Disconnecting stale sessions and reconnecting..." -ForegroundColor Yellow
        adb disconnect
    }
}
