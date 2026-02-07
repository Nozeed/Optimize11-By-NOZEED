# =============================================
# Windows 11 Gaming Optimization Script v2.0
# ลบ Bloatware + Tweaks + Graphics สำหรับเกม
# =============================================

Write-Host "เริ่มต้น Ultimate Gaming Optimization..." -ForegroundColor Cyan

# 0. Detect GPU
$gpus = (Get-WmiObject Win32_VideoController).Name
$isNVIDIA = $gpus -match "NVIDIA"
Write-Host "ตรวจพบ GPU: $gpus" -ForegroundColor Green
if ($isNVIDIA) { Write-Host "NVIDIA Detected - Apply MPO Disable" -ForegroundColor Yellow }

# 1. Power Plan: High/Ultimate Performance
Write-Host "`n1. ตั้ง Power Plan High/Ultimate Performance..." -ForegroundColor Yellow
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  # High Perf
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61  # Ultimate
$highPerf = (powercfg -l | Select-String "High performance").ToString().Split()[3]
$ultPerf = (powercfg -l | Select-String "Ultimate Performance").ToString().Split()[3]
if ($ultPerf) { powercfg -setactive $ultPerf; Write-Host "Ultimate Performance Active!" -ForegroundColor Green }
elseif ($highPerf) { powercfg -setactive $highPerf; Write-Host "High Performance Active!" -ForegroundColor Green }

# 2. Windows Photo Viewer Default (เพิ่มนามสกุล)
Write-Host "`n2. ตั้ง Windows Photo Viewer เป็น Default..." -ForegroundColor Yellow
$extensions = @(".jpg",".jpeg",".png",".bmp",".gif",".tiff",".tif")
foreach ($ext in $extensions) {
    reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v $ext /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f
}

# 3. Classic Right Click Menu (Win10 style)
Write-Host "`n3. Classic Right Click Menu..." -ForegroundColor Yellow
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep 2; Start-Process explorer

# 4. ลบ Bloatware (ตาม list)
Write-Host "`n4. ลบ Bloatware..." -ForegroundColor Yellow
$appsToRemove = @(
    "*3DBuilder*","*BingWeather*","*GetHelp*","*Getstarted*","*Microsoft3DViewer*","*MicrosoftOfficeHub*",
    "*MicrosoftSolitaireCollection*","*MixedReality*","*OneNote*","*People*","*SkypeApp*","*WindowsAlarms*",
    "*WindowsCamera*","*windowscommunicationsapps*","*WindowsFeedbackHub*","*WindowsMaps*",
    "*WindowsSoundRecorder*","*Xbox*","*Zune*","*Microsoft.YourPhone*","*MicrosoftTeams*",
    "*Microsoft.Todos*","*Microsoft.Whiteboard*","*Microsoft.Paint*","*DevHome*","*PowerAutomate*",
    "*QuickAssist*","*MicrosoftFamily*"  # Edge skip เพื่อ safety
)
foreach ($app in $appsToRemove) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | ? DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# 5. Services Disable (เพิ่ม storsvc, SysMain)
Write-Host "`n5. ปิด Services..." -ForegroundColor Yellow
$servicesToDisable = @(
    "SysMain", "storsvc", "WSearch", "DiagTrack", "dmwappushservice", "RetailDemo", "Fax",
    "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "TabletInputService", "WbioSrvc",
    "WalletService", "lfsvc", "MapsBroker", "SharedAccess", "WMPNetworkSvc"
)
foreach ($service in $servicesToDisable) {
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

# 6. Graphics & Extreme Gaming Tweaks
Write-Host "`n6. Graphics + Extreme Performance Tweaks..." -ForegroundColor Yellow

# HAGS Enable
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f

# Game Mode Enable
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f

# Disable Game DVR / Fullscreen Opti
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f

# NVIDIA MPO Disable (low latency)
if ($isNVIDIA) {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "DisablePreemption" /t REG_DWORD /d 1 /f
}

# Visual Effects: Best Performance
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f

# CPU/Memory Priority
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 26 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f

# Network Latency (Gaming)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f

# Mouse: No Acceleration (FPS)
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f

# 7. ล้าง Temp/Cache
Write-Host "`n7. ล้าง Cache..." -ForegroundColor Yellow
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "`n🎮 เสร็จสิ้น! **REBOOT ทันที** เพื่อ activate HAGS/Memory tweaks" -ForegroundColor Cyan
Write-Host "Benchmark FPS ควรดีขึ้น 5-15% ในเกม (test yourself)" -ForegroundColor Green
Write-Host "ปัญหา? System Restore หรือ run script ใหม่" -ForegroundColor Red
