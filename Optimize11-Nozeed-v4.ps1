#================================================================================
#   Windows-11-Gaming-Optimization-Script-By-NOZEED
#   Project: https://github.com/Nozeed/Optimize11-By-NOZEED
#   Author: NOZEED (@beernozeed)
#   Version: v4 - Enhanced OneDrive Removal + Full Visual/Animation Disable + Svchost Reduction
#   Based on: Script v3 Nozeed.ps1 (ULTIMATE GAMING OPTIMIZATION)
#   Description: Optimize Windows 11 (25H2/26H1/26H2) for Gaming/Performance
#                - Remove Bloat, Debloat, Disable Telemetry/Services,
#                  GPU Tweaks, Visual Effects, Animations, Network Latency, Svchost Reduction, etc.
#   Warning: Run as Administrator. Backup important data first! Create Restore Point recommended.
#   Last Update: 2026 - Added auto SvcHostSplitThresholdInKB for fewer processes (based on RAM)
#================================================================================

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting Windows 11 Gaming Optimization by NOZEED (v4)..." -ForegroundColor Green
Write-Host "Project: https://github.com/Nozeed/Optimize11-By-NOZEED" -ForegroundColor Cyan

# ======================
# 1. Remove OneDrive Completely (Enhanced)
# ======================
Write-Host "`n[Extra 1] Removing OneDrive Completely..." -ForegroundColor Cyan

taskkill /f /im OneDrive.exe *>$null 2>&1

$oneDriveSetupPaths = @(
    "$env:SystemRoot\SysWOW64\OneDriveSetup.exe",
    "$env:SystemRoot\System32\OneDriveSetup.exe"
)
foreach ($path in $oneDriveSetupPaths) {
    if (Test-Path $path) {
        Start-Process $path -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    }
}

Get-AppxPackage *OneDrive* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*OneDrive*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

$oneDriveFolders = @(
    "$env:UserProfile\OneDrive",
    "$env:LocalAppData\Microsoft\OneDrive",
    "$env:ProgramData\Microsoft OneDrive",
    "C:\OneDriveTemp"
)
foreach ($folder in $oneDriveFolders) {
    Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force

Remove-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue

Write-Host "OneDrive removal completed (restart recommended)." -ForegroundColor Green

# ======================
# 2. Disable All Visual Effects & Animations
# ======================
Write-Host "`n[Extra 2] Disabling All Visual Effects & Animations..." -ForegroundColor Cyan

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Type String -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer

Write-Host "Visual effects & animations fully disabled for max performance." -ForegroundColor Green

# ======================
# Original Sections (v3 preserved + Svchost Reduction added)
# ======================

# 1. Removing Bloatware & Components
Write-Host "`n[1/9] Removing Bloatware & Components..." -ForegroundColor Cyan
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

# 2. Restoring Classic Windows Features
Write-Host "[2/9] Restoring Classic Windows Features..." -ForegroundColor Cyan
$ContextMenuPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (!(Test-Path $ContextMenuPath)) { New-Item -Path $ContextMenuPath -Force }
Set-ItemProperty -Path $ContextMenuPath -Name "(Default)" -Value ""

$PhotoViewerPath = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
if (!(Test-Path $PhotoViewerPath)) { New-Item -Path $PhotoViewerPath -Force }
$Extensions = @(".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff")
foreach ($Ext in $Extensions) {
    Set-ItemProperty -Path $PhotoViewerPath -Name $Ext -Value "PhotoViewer.FileAssoc.Tiff"
}

# 3. GPU & Gaming Settings
Write-Host "[3/9] Tweaking GPU & Gaming Settings..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0
$MPOPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
if (!(Test-Path $MPOPath)) { New-Item -Path $MPOPath -Force }
Set-ItemProperty -Path $MPOPath -Name "OverlayTestMode" -Value 00000005
$NvidiaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
if (Test-Path $NvidiaPath) { Set-ItemProperty -Path $NvidiaPath -Name "DisablePreemption" -Value 1 -ErrorAction SilentlyContinue }

# 4. System Performance
Write-Host "[4/9] Optimizing System Performance..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /hibernate off

# 5. Memory & Storage + Svchost Reduction (NEW)
Write-Host "[5/9] Tweaking Memory & Storage + Reducing svchost.exe processes..." -ForegroundColor Cyan
$MemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $MemPath -Name "DisablePagingExecutive" -Value 1
Set-ItemProperty -Path $MemPath -Name "LargeSystemCache" -Value 1
Set-Service "storsvc" -StartupType Disabled -ErrorAction SilentlyContinue

# NEW: Auto-detect RAM and set SvcHostSplitThresholdInKB to reduce processes
$totalRamGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 0)
if ($totalRamGB -ge 8) {
    $thresholdKB = [math]::Round($totalRamGB * 1024 * 1024 * 1.1)  # 110% of total RAM in KB for safety
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control" -Name "SvcHostSplitThresholdInKB" -Value $thresholdKB -Type DWord -Force
    Write-Host "Detected $totalRamGB GB RAM → Set SvcHostSplitThresholdInKB to $thresholdKB KB (fewer svchost processes). Restart required." -ForegroundColor Green
} else {
    Write-Host "RAM less than 8GB detected ($totalRamGB GB) → Skipping Svchost reduction to avoid instability." -ForegroundColor Yellow
}

# 6. Network & Latency
Write-Host "[6/9] Reducing Network Latency..." -ForegroundColor Cyan
$Interfaces = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($Interface in $Interfaces) {
    Set-ItemProperty -Path $Interface.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Interface.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
}

# 7. Input Tweaks
Write-Host "[7/9] Disabling Mouse Acceleration..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0

# 8. Disable Unnecessary Services
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

# 9. Cleanup
Write-Host "[9/9] Finalizing with Component Cleanup..." -ForegroundColor Yellow
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# ======================
# End
# ======================
Write-Host "`n--- SUCCESS: SYSTEM OPTIMIZED by NOZEED (v4) ---" -ForegroundColor Green
Write-Host "Project: https://github.com/Nozeed/Optimize11-By-NOZEED" -ForegroundColor Cyan
Write-Host "Please RESTART your computer to apply all changes (especially Svchost & services tweaks)." -ForegroundColor Red
Write-Host "If OneDrive still lingers: winget uninstall --id Microsoft.OneDrive" -ForegroundColor Yellow
Write-Host "Check Task Manager after restart → svchost.exe should be fewer processes." -ForegroundColor Cyan
