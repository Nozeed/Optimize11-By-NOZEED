# ==============================================================================
# ULTIMATE GAMING OPTIMIZATION SCRIPT (25H2,26H1,26H2) By NozeeD
# ลบ Bloatware + Tweaks + Graphics สำหรับเกม
# V.3
# ==============================================================================
Write-Host "--- Starting Ultimate Optimization ---" -ForegroundColor Yellow

# 1. [COMPONENTS REMOVAL] - ลบแอปและฟีเจอร์ที่ไม่จำเป็น
Write-Host "[1/7] Removing Bloatware & Components..." -ForegroundColor Cyan
$AppList = @(
    "*Xbox*", "*Photos*", "*StickyNotes*", "*Wallet*", "*Bing*", "*Family*",
    "*WindowsCamera*", "*CommunicationsApps*", "*People*", "*Zune*", "*WebExperience*",
    "*DesktopAppInstaller*", "*GetHelp*", "*YourPhone*", "*OfficeHub*", "*MicrosoftEdge*"
)
foreach ($App in $AppList) {
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $App } | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# 2. [GPU & DISPLAY] - HAGS, Game Mode, Game DVR, MPO
Write-Host "[2/7] Tweaking GPU & Gaming Settings..." -ForegroundColor Cyan
# Enable Game Mode
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
# Disable Game DVR / Capture
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0
# Disable MPO (Multi-Plane Overlay) for NVIDIA/AMD Latency
$MPOPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
if (!(Test-Path $MPOPath)) { New-Item -Path $MPOPath -Force }
Set-ItemProperty -Path $MPOPath -Name "OverlayTestMode" -Value 00000005
# Disable GPU Preemption (NVIDIA Specific Tweak for Input Lag)
$NvidiaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
if (Test-Path $NvidiaPath) { Set-ItemProperty -Path $NvidiaPath -Name "DisablePreemption" -Value 1 -ErrorAction SilentlyContinue }

# 3. [SYSTEM PERFORMANCE] - CPU Priority, Visual Effects, Power Plan
Write-Host "[3/7] Optimizing System Performance..." -ForegroundColor Cyan
# Win32PrioritySeparation = 26 (Hex 0x1A) - Prioritize Foreground Apps/Games
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26
# Set Visual Effects to "Best Performance" (Disable Animations/Transparency)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
# Active High Performance Power Plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
# Disable Hibernation (Reduce Disk Writes)
powercfg /hibernate off

# 4. [MEMORY & STORAGE] - Paging Executive, Large System Cache, Storsvc
Write-Host "[4/7] Tweaking Memory & Storage..." -ForegroundColor Cyan
$MemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $MemPath -Name "DisablePagingExecutive" -Value 1
Set-ItemProperty -Path $MemPath -Name "LargeSystemCache" -Value 1
# ปิด Storage Service (storsvc)
Set-Service "storsvc" -StartupType Disabled -ErrorAction SilentlyContinue

# 5. [NETWORK & LATENCY] - Disable Nagle's Algorithm
Write-Host "[5/7] Reducing Network Latency..." -ForegroundColor Cyan
$Interfaces = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($Interface in $Interfaces) {
    Set-ItemProperty -Path $Interface.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Interface.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
}

# 6. [INPUT TWEAKS] - Mouse Acceleration
Write-Host "[6/7] Disabling Mouse Acceleration..." -ForegroundColor Cyan
$MousePath = "HKCU:\Control Panel\Mouse"
Set-ItemProperty -Path $MousePath -Name "MouseSpeed" -Value 0
Set-ItemProperty -Path $MousePath -Name "MouseThreshold1" -Value 0
Set-ItemProperty -Path $MousePath -Name "MouseThreshold2" -Value 0

# 7. [SERVICES] - Disable Unnecessary Services (Extreme)
Write-Host "[7/7] Disabling Services..." -ForegroundColor Cyan
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

# Clean up WinSXS (Safe way)
Write-Host "Cleaning up System Image..." -ForegroundColor Yellow
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Host "--- ALL TWEAKS APPLIED SUCCESSFULLY ---" -ForegroundColor Green
Write-Host "Please RESTART your computer to take effect." -ForegroundColor Red
