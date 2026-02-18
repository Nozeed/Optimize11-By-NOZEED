#================================================================================
#   Windows-11-Gaming-Optimization-Script-By-NOZEED v4.2 - Fixed Errors
#   Project: https://github.com/Nozeed/Optimize11-By-NOZEED
#   Author: NOZEED (@beernozeed)
#   Description: Gaming Optimize Win11 (low latency + fixed syntax errors)
#   Warning: Run as Admin | Restart after run
#================================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Write-Host "NOZEED Gaming Optimize v4.2 (Fixed)" -ForegroundColor Green

# 1. Bloatware + OneDrive Removal
Write-Host "[Bloat + OneDrive] Removing..." -ForegroundColor Cyan
taskkill /f /im OneDrive.exe *>$null 2>&1
@("$env:SystemRoot\SysWOW64\OneDriveSetup.exe", "$env:SystemRoot\System32\OneDriveSetup.exe") | % { if (Test-Path $_) { Start-Process $_ "/uninstall" -Wait -NoNewWindow -EA SilentlyContinue } }

$bloatList = @("*OneDrive*","*Xbox*","*Photos*","*StickyNotes*","*Wallet*","*Bing*","*Family*","*Camera*","*People*","*Zune*","*WebExperience*","*GetHelp*","*YourPhone*","*OfficeHub*","*Teams*","*FeedbackHub*","*Clipchamp*")
foreach ($app in $bloatList) {
    Get-AppxPackage -AllUsers $app | Remove-AppxPackage -EA SilentlyContinue
    Get-AppxProvisionedPackage -Online | ? DisplayName -like $app | Remove-AppxProvisionedPackage -Online -EA SilentlyContinue
}

@("$env:UserProfile\OneDrive", "$env:LocalAppData\Microsoft\OneDrive", "$env:ProgramData\Microsoft OneDrive", "C:\OneDriveTemp") | Remove-Item -Recurse -Force -EA SilentlyContinue

New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1 -Type DWord -Force -EA SilentlyContinue
Remove-ItemProperty "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}","HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" -EA SilentlyContinue

# 2. Visual/Animation Disable
Write-Host "[Visuals] Disable..." -ForegroundColor Cyan
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 3 -Type DWord -Force -EA SilentlyContinue
Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" 0 -Type String -Force -EA SilentlyContinue
@("TaskbarAnimations","ListviewAlphaSelect") | % { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" $_ 0 -Type DWord -Force -EA SilentlyContinue }
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" 0 -Type DWord -Force -EA SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 -Type DWord -Force -EA SilentlyContinue
Stop-Process -Name explorer -Force; Start-Sleep 2; explorer

# 3. Classic Features
Write-Host "[Classic] Restore..." -ForegroundColor Cyan
New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
Set-ItemProperty "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" "(Default)" "" -EA SilentlyContinue
$pv = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
New-Item $pv -Force | Out-Null
@(".jpg",".jpeg",".png",".bmp",".gif",".tiff") | % { Set-ItemProperty $pv $_ "PhotoViewer.FileAssoc.Tiff" -EA SilentlyContinue }

# 4. Gaming + Latency Tweaks
Write-Host "[Gaming/Latency] Tweaks..." -ForegroundColor Cyan

# Game Mode, DVR off (สร้าง path ก่อนถ้าไม่มี)
$gameDvrPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
if (!(Test-Path $gameDvrPath)) { New-Item $gameDvrPath -Force | Out-Null }
Set-ItemProperty $gameDvrPath "AllowGameDVR" 0 -Type DWord -Force -EA SilentlyContinue

Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1 -Type DWord -Force -EA SilentlyContinue
Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0 -Type DWord -Force -EA SilentlyContinue
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" 5 -Type DWord -Force -EA SilentlyContinue

$games = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Set-ItemProperty $games "GPU Priority" 8 -Type DWord -Force -EA SilentlyContinue
Set-ItemProperty $games "Priority" 6 -Type DWord -Force -EA SilentlyContinue
Set-ItemProperty $games "Scheduling Category" "High" -Type String -Force -EA SilentlyContinue
Set-ItemProperty $games "SFIO Priority" "High" -Type String -Force -EA SilentlyContinue

Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2 -Type DWord -Force -EA SilentlyContinue

# Network
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff -Type DWord -Force -EA SilentlyContinue
$tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-ItemProperty $tcp "TcpAckFrequency" 1 -EA SilentlyContinue
Set-ItemProperty $tcp "TCPNoDelay" 1 -EA SilentlyContinue
Set-ItemProperty $tcp "NetworkThrottlingIndex" 0xffffffff -Type DWord -Force -EA SilentlyContinue

Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -EA SilentlyContinue | % {
    Set-ItemProperty $_.PSPath "TcpAckFrequency" 1 -EA SilentlyContinue
    Set-ItemProperty $_.PSPath "TCPNoDelay" 1 -EA SilentlyContinue
}

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 26 -Type DWord -Force -EA SilentlyContinue
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /hibernate off

# 5. Memory + Svchost
Write-Host "[Memory] Tweaks..." -ForegroundColor Cyan
$mem = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty $mem "DisablePagingExecutive" 1 -Type DWord -Force -EA SilentlyContinue
Set-ItemProperty $mem "LargeSystemCache" 1 -Type DWord -Force -EA SilentlyContinue
Set-Service "storsvc" -StartupType Disabled -EA SilentlyContinue

$totalRamGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure -Property Capacity -Sum).Sum / 1GB, 0)
if ($totalRamGB -ge 8) {
    $thresh = [math]::Round($totalRamGB * 1024 * 1024 * 1.1)
    Set-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" $thresh -Type DWord -Force -EA SilentlyContinue
}

# 6. Mouse + Services (แก้ syntax Set-Service)
Write-Host "[Input/Services] Disable..." -ForegroundColor Cyan
@("MouseSpeed","MouseThreshold1","MouseThreshold2") | % { Set-ItemProperty "HKCU:\Control Panel\Mouse" $_ 0 -EA SilentlyContinue }

$servicesToDisable = @("SysMain","WSearch","TabletInputService","DiagTrack","DmWappushservice","PrintSpooler","RemoteRegistry","TrkWks","WbioSrvc","FrameServer")
foreach ($svc in $servicesToDisable) {
    if (Get-Service $svc -EA SilentlyContinue) {
        Stop-Service $svc -Force -EA SilentlyContinue
        Set-Service $svc -StartupType Disabled -EA SilentlyContinue
    }
}

# 7. Cleanup (เรียก Dism ตรง ๆ ไม่ใส่ -EA)
Write-Host "[Cleanup] Running DISM..." -ForegroundColor Yellow
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Host "`n--- Done! Restart PC now ---" -ForegroundColor Green
Write-Host "Check Task Manager & games for improvements." -ForegroundColor Yellow
Write-Host "Project: https://github.com/Nozeed/Optimize11-By-NOZEED" -ForegroundColor Cyan
