#================================================================================
#   Windows-11-Gaming-Optimization-Script-By-NOZEED
#   Project: https://github.com/Nozeed/Optimize11-By-NOZEED
#   Author: NOZEED (@beernozeed) + Grok Optimized
#   Description: Ultimate Gaming Optimize Win11 26H2 (FiveM Focused)
#   Warning: Run as Administrator | Restart after run
#================================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
}

Write-Host "🚀 NOZEED Gaming Optimize - Ultimate" -ForegroundColor Green
Write-Host "กำลังปรับแต่งให้แรงที่สุดสำหรับ..." -ForegroundColor Cyan

# 1. Bloatware + OneDrive + Copilot Removal
Write-Host "[1/6] Removing Bloat + OneDrive + Copilot..." -ForegroundColor Cyan
taskkill /f /im OneDrive.exe *>$null 2>&1
@("$env:SystemRoot\SysWOW64\OneDriveSetup.exe", "$env:SystemRoot\System32\OneDriveSetup.exe") | % { 
    if (Test-Path $_) { Start-Process $_ "/uninstall" -Wait -NoNewWindow -EA SilentlyContinue } 
}

$bloatList = @("*OneDrive*","*Xbox*","*Bing*","*Family*","*Camera*","*People*","*Zune*","*WebExperience*","*GetHelp*","*YourPhone*","*OfficeHub*","*Teams*","*FeedbackHub*","*Clipchamp*","*Copilot*")
foreach ($app in $bloatList) {
    Get-AppxPackage -AllUsers $app | Remove-AppxPackage -EA SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online -EA SilentlyContinue
}

# ลบ Copilot ถาวร
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f

# ลบ OneDrive เต็ม
@("$env:UserProfile\OneDrive", "$env:LocalAppData\Microsoft\OneDrive", "$env:ProgramData\Microsoft OneDrive", "C:\OneDriveTemp") | Remove-Item -Recurse -Force -EA SilentlyContinue
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1 -Type DWord

# 2. Visual + Classic
Write-Host "[2/6] Disable Visual Effects + Classic UI..." -ForegroundColor Cyan
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 3 -Type DWord
@("TaskbarAnimations","ListviewAlphaSelect") | % { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" $_ 0 -Type DWord }
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" 0 -Type DWord
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 -Type DWord
Stop-Process -Name explorer -Force; Start-Sleep 2; Start-Process explorer

# Classic Right-Click + Photo Viewer
New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
Set-ItemProperty "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" "(Default)" "" 

# 3. Gaming + Latency + Power Throttling
Write-Host "[3/6] Gaming & Low Latency Tweaks..." -ForegroundColor Cyan

# Power Throttling Off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f

# GameDVR + GameBar
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
reg add "HKCU:\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKCU:\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f

# Gaming Priority
$gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Set-ItemProperty $gamesPath "Affinity" 0 -Type DWord
Set-ItemProperty $gamesPath "Background Only" "False"
Set-ItemProperty $gamesPath "GPU Priority" 8 -Type DWord
Set-ItemProperty $gamesPath "Priority" 6 -Type DWord
Set-ItemProperty $gamesPath "Scheduling Category" "High"
Set-ItemProperty $gamesPath "SFIO Priority" "High"

# Network + System Responsiveness
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f

# FiveM / GTA5 Priority
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GTA5.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f

# 4. Memory + Svchost (32GB)
Write-Host "[4/6] Memory Optimization..." -ForegroundColor Cyan
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f

$totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
if ($totalRam -ge 16) {
    $thresh = [math]::Round($totalRam * 1024 * 1024 * 1.1)
    reg add "HKLM\SYSTEM\ControlSet001\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d $thresh /f
}

# 5. Services Disable
Write-Host "[5/6] Disabling unnecessary Services..." -ForegroundColor Cyan
$services = @("DiagTrack","dmwappushservice","SysMain","WSearch","XblAuthManager","XblGameSave","XboxNetApiSvc","upnphost","SSDPSRV","DoSvc","BITS","UsoSvc")
foreach ($s in $services) {
    if (Get-Service -Name $s -EA SilentlyContinue) {
        Stop-Service -Name $s -Force -EA SilentlyContinue
        Set-Service -Name $s -StartupType Disabled -EA SilentlyContinue
    }
}

# 6. Power Plan + Final
Write-Host "[6/6] Setting Ultimate Performance..." -ForegroundColor Green
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /hibernate off

Write-Host "✅ เสร็จสิ้น! Restart เครื่องเลยครับ" -ForegroundColor Green