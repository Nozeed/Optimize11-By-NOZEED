#================================================================================
#   Windows-11-Gaming-Optimization-Script-By-NOZEED v4.3 - All Errors Fixed
#   Project: https://github.com/Nozeed/Optimize11-By-NOZEED
#   Author: NOZEED (@beernozeed)
#   Description: Gaming Optimize Win11 (low latency + error-proof)
#   Warning: Run as Admin | Restart after run
#================================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Write-Host "NOZEED Gaming Optimize v4.3 (Errors Fixed)" -ForegroundColor Green

# 1. Bloatware + OneDrive Removal
Write-Host "[Bloat + OneDrive] Removing..." -ForegroundColor Cyan
taskkill /f /im OneDrive.exe *>$null 2>&1
@("$env:SystemRoot\SysWOW64\OneDriveSetup.exe", "$env:SystemRoot\System32\OneDriveSetup.exe") | % { if (Test-Path $_) { Start-Process $_ "/uninstall" -Wait -NoNewWindow -EA 0 } }

$bloatList = @("*OneDrive*","*Xbox*","*Photos*","*StickyNotes*","*Wallet*","*Bing*","*Family*","*Camera*","*People*","*Zune*","*WebExperience*","*GetHelp*","*YourPhone*","*OfficeHub*","*Teams*","*FeedbackHub*","*Clipchamp*")
foreach ($app in $bloatList) {
    Get-AppxPackage -AllUsers $app | Remove-AppxPackage -EA 0
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online -EA 0
}

@("$env:UserProfile\OneDrive", "$env:LocalAppData\Microsoft\OneDrive", "$env:ProgramData\Microsoft OneDrive", "C:\OneDriveTemp") | Remove-Item -Recurse -Force -EA 0

New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1 -Type DWord -EA 0
Remove-ItemProperty "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" -EA 0 -ErrorAction SilentlyContinue
Remove-ItemProperty "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" -EA 0 -ErrorAction SilentlyContinue

# 2. Visual/Animation Disable
Write-Host "[Visuals] Disable..." -ForegroundColor Cyan
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 3 -Type DWord -EA 0
Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" 0 -Type String -EA 0
@("TaskbarAnimations","ListviewAlphaSelect") | % { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" $_ 0 -Type DWord -EA 0 }
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" 0 -Type DWord -EA 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 -Type DWord -EA 0
Stop-Process -Name explorer -Force -EA 0; Start-Sleep 2; Start-Process explorer

# 3. Classic Features
Write-Host "[Classic] Restore..." -ForegroundColor Cyan
New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
Set-ItemProperty "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" "(Default)" "" -EA 0
$pv = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
New-Item $pv -Force | Out-Null
@(".jpg",".jpeg",".png",".bmp",".gif",".tiff") | % { Set-ItemProperty $pv $_ "PhotoViewer.FileAssoc.Tiff" -EA 0 }

# 4. Gaming + Latency Tweaks
Write-Host "[Gaming/Latency] Tweaks..." -ForegroundColor Cyan

# Create GameDVR path if missing
$gameDvrPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
if (!(Test-Path $gameDvrPath)) { New-Item $gameDvrPath -Force | Out-Null }
Set-ItemProperty $gameDvrPath "AllowGameDVR" 0 -Type DWord -EA 0

Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1 -Type DWord -EA 0
Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0 -Type DWord -EA 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" 5 -Type DWord -EA 0

$gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Set-ItemProperty $gamesPath "GPU Priority" 8 -Type DWord -EA 0
Set-ItemProperty $gamesPath "Priority" 6 -Type DWord -EA 0
Set-ItemProperty $gamesPath "Scheduling Category" "High" -Type String -EA 0
Set-ItemProperty $gamesPath "SFIO Priority" "High" -Type String -EA 0

Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2 -Type DWord -EA 0

# Network tweaks
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff -Type DWord -EA 0
$tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-ItemProperty $tcpPath "TcpAckFrequency" 1 -EA 0
Set-ItemProperty $tcpPath "TCPNoDelay" 1 -EA 0
Set-ItemProperty $tcpPath "NetworkThrottlingIndex" 0xffffffff -Type DWord -EA 0

Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -EA 0 | % {
    Set-ItemProperty $_.PSPath "TcpAckFrequency" 1 -EA 0
    Set-ItemProperty $_.PSPath "TCPNoDelay" 1 -EA 0
}

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 26 -Type DWord -EA 0
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
powercfg /hibernate off 2>$null

# 5. Memory + Svchost Reduction
Write-Host "[Memory] Tweaks..." -ForegroundColor Cyan
$memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty $memPath "DisablePagingExecutive" 1 -Type DWord -EA 0
Set-ItemProperty $memPath "LargeSystemCache" 1 -Type DWord -EA 0
Set-Service "storsvc" -StartupType Disabled -EA 0

$totalRamGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 0)
if ($totalRamGB -ge 8) {
    $thresh = [math]::Round($totalRamGB * 1024 * 1024 * 1.1)
    Set-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" $thresh -Type DWord -EA 0
}

# 6. Mouse + Services (Fixed syntax)
Write-Host "[Input/Services] Disable..." -ForegroundColor Cyan
@("MouseSpeed","MouseThreshold1","MouseThreshold2") | % { Set-ItemProperty "HKCU:\Control Panel\Mouse" $_ 0 -EA 0 }

$services = @("SysMain","WSearch","TabletInputService","DiagTrack","DmWappushservice","PrintSpooler","RemoteRegistry","TrkWks","WbioSrvc","FrameServer")
foreach ($svc in $services) {
    if (Get-Service $svc -EA 0) {
        Stop-Service $svc -Force -EA 0
        Set-Service $svc -StartupType Disabled -EA 0
    }
}

# 7. Cleanup (Dism without -EA)
Write-Host "[Cleanup] Running DISM (may show warning if /ResetBase ignored)..." -ForegroundColor Yellow
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>$null

Write-Host "`n--- Done! Restart your PC now ---" -ForegroundColor Green
Write-Host "If DISM shows error about ResetBase: It's normal in recent Win11 (feature disabled by MS). Other tweaks still work." -ForegroundColor Yellow
Write-Host "Check Task Manager after restart: svchost should be fewer, latency in games better." -ForegroundColor Cyan
Write-Host "Project: https://github.com/Nozeed/Optimize11-By-NOZEED" -ForegroundColor Cyan
