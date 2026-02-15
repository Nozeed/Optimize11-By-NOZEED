# ==============================================================================
# ULTIMATE GAMING OPTIMIZATION SCRIPT (25H2,26H1,26H2) By NozeeD
# ลบ Bloatware + Tweaks + Graphics สำหรับเกม
# V.3
# ==============================================================================
# รันในฐานะ Administrator เท่านั้น
Write-Host "--- Starting Ultimate Optimization 2.0 (Extreme Edition) ---" -ForegroundColor Yellow

# 1. [COMPONENTS REMOVAL] - ลบแอปและฟีเจอร์ที่ไม่จำเป็น (รวมลิสต์ใหม่)
Write-Host "[1/9] Removing Bloatware & Components..." -ForegroundColor Cyan
$AppList = @(
    "*Xbox*", "*Photos*", "*StickyNotes*", "*Wallet*", "*Bing*", "*Family*",
    "*WindowsCamera*", "*CommunicationsApps*", "*People*", "*Zune*", "*WebExperience*",
    "*DesktopAppInstaller*", "*GetHelp*", "*YourPhone*", "*OfficeHub*", "*MicrosoftEdge*",
    "*Teams*", "*OneDrive*", "*FeedbackHub*", "*Clipchamp*", "*Outlook*", "*Todo*", 
    "*PowerAutomate*", "*QuickAssist*"
)
foreach ($App in $AppList) {
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $App } | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# 2. [RESTORE CLASSICS] - คืนค่า Context Menu และ Photo Viewer
Write-Host "[2/9] Restoring Classic Windows Features..." -ForegroundColor Cyan
# Restore Classic Right-Click Context Menu
$ContextMenuPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (!(Test-Path $ContextMenuPath)) { New-Item -Path $ContextMenuPath -Force }
Set-ItemProperty -Path $ContextMenuPath -Name "(Default)" -Value ""

# Restore Classic Windows Photo Viewer
$PhotoViewerPath = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
if (!(Test-Path $PhotoViewerPath)) { New-Item -Path $PhotoViewerPath -Force }
$Extensions = @(".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff")
foreach ($Ext in $Extensions) {
    Set-ItemProperty -Path $PhotoViewerPath -Name $Ext -Value "PhotoViewer.FileAssoc.Tiff"
}

# 3. [GPU & DISPLAY] - HAGS, Game Mode, Game DVR, MPO
Write-Host "[3/9] Tweaking GPU & Gaming Settings..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0
# Disable MPO (Multi-Plane Overlay)
$MPOPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
if (!(Test-Path $MPOPath)) { New-Item -Path $MPOPath -Force }
Set-ItemProperty -Path $MPOPath -Name "OverlayTestMode" -Value 00000005
# NVIDIA Preemption Disable (Lower Input Lag)
$NvidiaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
if (Test-Path $NvidiaPath) { Set-ItemProperty -Path $NvidiaPath -Name "DisablePreemption" -Value 1 -ErrorAction SilentlyContinue }

# 4. [SYSTEM PERFORMANCE] - CPU Priority, Visual Effects, Power Plan
Write-Host "[4/9] Optimizing System Performance..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /hibernate off

# 5. [MEMORY & STORAGE] - Paging Executive, Large System Cache
Write-Host "[5/9] Tweaking Memory & Storage..." -ForegroundColor Cyan
$MemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $MemPath -Name "DisablePagingExecutive" -Value 1
Set-ItemProperty -Path $MemPath -Name "LargeSystemCache" -Value 1
# ปิด Storage Service (storsvc)
Set-Service "storsvc" -StartupType Disabled -ErrorAction SilentlyContinue

# 6. [NETWORK & LATENCY] - TCP No Delay
Write-Host "[6/9] Reducing Network Latency..." -ForegroundColor Cyan
$Interfaces = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($Interface in $Interfaces) {
    Set-ItemProperty -Path $Interface.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Interface.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
}

# 7. [INPUT TWEAKS] - Mouse Acceleration
Write-Host "[7/9] Disabling Mouse Acceleration..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0

# 8. [SERVICES] - Disable Unnecessary Services
Write-Host "[8/9] Disabling Unnecessary Services..." -ForegroundColor Cyan
$ServiceList = @(
    "SysMain", "WSearch", "TabletInputService", "DiagTrack", "DmWappushservice",
    "PrintSpooler", "RemoteRegistry", "TrkWks", "WbioSrvc", "FrameServer"
)
foreach ($Svc in $ServiceList) {
    if (Get-Service $Svc -ErrorAction SilentlyContinue) {
        Stop-Service $Svc -Force -ErrorAction SilentlyContinue
        Set-Service $Svc -StartupType Disabled
    }
}

# 9. [CLEANUP] - WinSXS Cleanup
Write-Host "[9/9] Finalizing with Component Cleanup..." -ForegroundColor Yellow
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Host "--- SUCCESS: SYSTEM OPTIMIZED ---" -ForegroundColor Green
Write-Host "Please RESTART your computer to apply all changes." -ForegroundColor Red
