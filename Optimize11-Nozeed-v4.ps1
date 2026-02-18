#================================================================================
#   Windows-11-Gaming-Optimization-Script-By-NOZEED v4.4 - Clean Errors
#   Project: https://github.com/Nozeed/Optimize11-By-NOZEED
#   Author: NOZEED (@beernozeed)
#   Description: Gaming Optimize Win11 (low latency + fixed binding errors)
#   Warning: Run as Admin | Restart after run
#================================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Write-Host "NOZEED Gaming Optimize v4.4 (Clean)" -ForegroundColor Green

# 1. Bloatware + OneDrive Removal
Write-Host "[Bloat + OneDrive] Removing..." -ForegroundColor Cyan
taskkill /f /im OneDrive.exe *>$null 2>&1
@("$env:SystemRoot\SysWOW64\OneDriveSetup.exe", "$env:SystemRoot\System32\OneDriveSetup.exe") | % { if (Test-Path $_) { Start-Process $_ "/uninstall" -Wait -NoNewWindow -EA SilentlyContinue } }

$bloatList = @("*OneDrive*","*Xbox*","*Photos*","*StickyNotes*","*Wallet*","*Bing*","*Family*","*Camera*","*People*","*Zune*","*WebExperience*","*GetHelp*","*YourPhone*","*OfficeHub*","*Teams*","*FeedbackHub*","*Clipchamp*")
foreach ($app in $bloatList) {
    Get-AppxPackage -AllUsers $app | Remove-AppxPackage -EA SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online -EA SilentlyContinue
}

@("$env:UserProfile\OneDrive", "$env:LocalAppData\Microsoft\OneDrive", "$env:ProgramData\Microsoft OneDrive", "C:\OneDriveTemp") | Remove-Item -Recurse -Force -EA SilentlyContinue

New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1 -Type DWord -EA SilentlyContinue

# แยก path เพื่อหลีกเลี่ยง binding conflict
$clsid1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$clsid2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
if (Test-Path $clsid1) { Remove-ItemProperty $clsid1 "System.IsPinnedToNameSpaceTree" -EA SilentlyContinue }
if (Test-Path $clsid2) { Remove-ItemProperty $clsid2 "System.IsPinnedToNameSpaceTree" -EA SilentlyContinue }

# 2. Visual/Animation Disable
Write-Host "[Visuals] Disable..." -ForegroundColor Cyan
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 3 -Type DWord -EA SilentlyContinue
Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" 0 -Type String -EA SilentlyContinue
@("TaskbarAnimations","ListviewAlphaSelect") | % { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" $_ 0 -Type DWord -EA SilentlyContinue }
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" 0 -Type DWord -EA SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 -Type DWord -EA SilentlyContinue
Stop-Process -Name explorer -Force -EA SilentlyContinue; Start-Sleep 2; Start-Process explorer -EA SilentlyContinue

# 3. Classic Features
Write-Host "[Classic] Restore..." -ForegroundColor Cyan
New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
Set-ItemProperty "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" "(Default)" "" -EA SilentlyContinue
$pv = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
New-Item $pv -Force | Out-Null
@(".jpg",".jpeg",".png",".bmp",".gif",".tiff") | % { Set-ItemProperty $pv $_ "PhotoViewer.FileAssoc.Tiff" -EA SilentlyContinue }

# 4. Gaming + Latency Tweaks
Write-Host "[Gaming/Latency] Tweaks..." -ForegroundColor Cyan

$gameDvrPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
if (!(Test-Path $gameDvrPath)) { New-Item $gameDvrPath -Force | Out-Null }
Set-ItemProperty $gameDvrPath "AllowGameDVR" 0 -Type DWord -EA SilentlyContinue

Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1 -Type DWord -EA SilentlyContinue
Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0 -Type DWord -EA SilentlyContinue
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" 5 -Type DWord -EA SilentlyContinue

$gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (Test-Path $gamesPath) {
    Set-ItemProperty $gamesPath "GPU Priority" 8 -Type DWord -EA SilentlyContinue
    Set-ItemProperty $gamesPath "Priority" 6 -Type DWord -EA SilentlyContinue
    Set-ItemProperty $gamesPath "Scheduling Category" "High" -Type String -EA SilentlyContinue
    Set-ItemProperty $gamesPath "SFIO Priority" "High" -Type String -EA SilentlyContinue
}

Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2 -Type DWord -EA SilentlyContinue

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff -Type DWord -EA SilentlyContinue
$tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-ItemProperty $tcpPath "TcpAckFrequency" 1 -EA SilentlyContinue
Set-ItemProperty $tcpPath "TCPNoDelay" 1 -EA SilentlyContinue
Set-ItemProperty $tcpPath "NetworkThrottlingIndex" 0xffffffff -Type DWord -EA SilentlyContinue

Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -EA SilentlyContinue | % {
    Set-ItemProperty $_.PSPath "TcpAckFrequency" 1 -EA SilentlyContinue
    Set-ItemProperty $_.PSPath "TCPNoDelay" 1 -EA SilentlyContinue
}

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 26 -Type DWord -EA SilentlyContinue
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
powercfg /hibernate off 2>$null

# 5. Memory + Svchost Reduction
Write-Host "[Memory] Tweaks..." -ForegroundColor Cyan
$memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty $memPath "DisablePagingExecutive" 1 -Type DWord -EA SilentlyContinue
Set-ItemProperty $memPath "LargeSystemCache" 1 -Type DWord -EA SilentlyContinue
Set-Service "storsvc" -StartupType Disabled -EA SilentlyContinue

$totalRamGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 0)
if ($totalRamGB -ge 8) {
    $thresh = [math]::Round($totalRamGB * 1024 * 1024 * 1.1)
    Set-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" $thresh -Type DWord -EA SilentlyContinue
}

# 6. Mouse + Services
Write-Host "[Input/Services] Disable..." -ForegroundColor Cyan
@("MouseSpeed","MouseThreshold1","MouseThreshold2") | % { Set-ItemProperty "HKCU:\Control Panel\Mouse" $_ 0 -EA SilentlyContinue }

$services = @("SysMain","WSearch","TabletInputService","DiagTrack","DmWappushservice","PrintSpooler","RemoteRegistry","TrkWks","WbioSrvc","FrameServer")
foreach ($svc in $services) {
    if (Get-Service $svc -EA SilentlyContinue) {
        Stop-Service $svc -Force -EA SilentlyContinue
        Set-Service $svc -StartupType Disabled -EA SilentlyContinue
    }
}

# 7. Cleanup
Write-Host "[Cleanup] Running DISM..." -ForegroundColor Yellow
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>$null

Write-Host "`n--- Done! Restart your PC now ---" -ForegroundColor Green
Write-Host "DISM /ResetBase อาจ error หรือ ignore ใน Win11 ล่าสุด (ปกติ ไม่กระทบ tweaks อื่น)" -ForegroundColor Yellow
Write-Host "หลังรีสตาร์ท เช็ค Task Manager: svchost น้อยลง, latency เกมดีขึ้น" -ForegroundColor Cyan
Write-Host "Project: https://github.com/Nozeed/Optimize11-By-NOZEED" -ForegroundColor Cyan
