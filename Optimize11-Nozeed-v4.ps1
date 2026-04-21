[CmdletBinding()]
param(
    [switch]$SkipBloatwareRemoval,
    [switch]$SkipServiceTweaks,
    [switch]$SkipRestorePoint
)

$ErrorActionPreference = 'SilentlyContinue'

function Write-Section {
    param([string]$Message)
    Write-Host "`n==== $Message ====" -ForegroundColor Cyan
}

function Write-Good {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-WarnText {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Test-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

function Set-RegValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)]$Value,
        [ValidateSet('String','ExpandString','Binary','DWord','MultiString','QWord')][string]$Type = 'DWord'
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

function Export-RegistryBackup {
    param([string]$BackupRoot)

    $targets = @(
        @{ Hive = 'HKLM'; Key = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; File = '01-systemprofile.reg' },
        @{ Hive = 'HKLM'; Key = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; File = '02-games-task.reg' },
        @{ Hive = 'HKLM'; Key = 'SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'; File = '03-memory.reg' },
        @{ Hive = 'HKLM'; Key = 'SYSTEM\CurrentControlSet\Control\Power'; File = '04-power.reg' },
        @{ Hive = 'HKLM'; Key = 'SOFTWARE\Policies\Microsoft\Windows'; File = '05-policies.reg' },
        @{ Hive = 'HKCU'; Key = 'Software\Microsoft\Windows\CurrentVersion\Explorer'; File = '06-explorer.reg' },
        @{ Hive = 'HKCU'; Key = 'System\GameConfigStore'; File = '07-gameconfig.reg' },
        @{ Hive = 'HKLM'; Key = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'; File = '08-ifeo.reg' }
    )

    foreach ($target in $targets) {
        $fullKey = "$($target.Hive)\$($target.Key)"
        $output = Join-Path $BackupRoot $target.File
        & reg export $fullKey $output /y | Out-Null
    }
}

function New-SystemRestorePoint {
    if ($SkipRestorePoint) {
        Write-WarnText 'Skipped restore point creation.'
        return
    }

    Enable-ComputerRestore -Drive "$($env:SystemDrive)\" | Out-Null
    Checkpoint-Computer -Description 'Boost FiveM By Nozeed' -RestorePointType 'MODIFY_SETTINGS' | Out-Null
    Write-Good 'Restore point created.'
}

function Remove-Bloatware {
    if ($SkipBloatwareRemoval) {
        Write-WarnText 'Skipped bloatware removal.'
        return
    }

    $appPatterns = @(
        '*MicrosoftTeams*',
        '*Teams*',
        '*Xbox*',
        '*XboxGamingOverlay*',
        '*XboxSpeechToTextOverlay*',
        '*Bing*',
        '*Clipchamp*',
        '*GetHelp*',
        '*Getstarted*',
        '*MicrosoftSolitaireCollection*',
        '*OfficeHub*',
        '*People*',
        '*SkypeApp*',
        '*Todos*',
        '*YourPhone*',
        '*ZuneMusic*',
        '*ZuneVideo*',
        '*WindowsAlarms*',
        '*WindowsCamera*',
        '*WindowsFeedbackHub*',
        '*WindowsMaps*',
        '*MixedReality*',
        '*OneDrive*',
        '*Copilot*',
        '*549981C3F5F10*'
    )

    taskkill /f /im OneDrive.exe *> $null 2>&1
    foreach ($setup in @("$env:SystemRoot\SysWOW64\OneDriveSetup.exe", "$env:SystemRoot\System32\OneDriveSetup.exe")) {
        if (Test-Path $setup) {
            Start-Process -FilePath $setup -ArgumentList '/uninstall' -Wait -WindowStyle Hidden
        }
    }

    foreach ($pattern in $appPatterns) {
        Get-AppxPackage -AllUsers -Name $pattern | Remove-AppxPackage -AllUsers
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $pattern } | Remove-AppxProvisionedPackage -Online
    }

    foreach ($path in @(
        "$env:UserProfile\OneDrive",
        "$env:LocalAppData\Microsoft\OneDrive",
        "$env:ProgramData\Microsoft OneDrive",
        'C:\OneDriveTemp'
    )) {
        Remove-Item -Path $path -Recurse -Force
    }

    Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -Value 1
    Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -Value 1
    Set-RegValue -Path 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -Value 1
    Write-Good 'Bloatware, OneDrive, and Copilot tweaks applied.'
}

function Set-VisualTweaks {
    Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 2
    Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Value 0
    Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewAlphaSelect' -Value 0
    Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'IconsOnly' -Value 1
    Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Value 0
    Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 0
    Set-RegValue -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Name '(default)' -Value '' -Type String
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Good 'Visual and classic UI tweaks applied.'
}

function Set-GamingTweaks {
    Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Value 1
    Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR' -Value 0
    Set-RegValue -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0
    Set-RegValue -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_FSEBehaviorMode' -Value 2
    Set-RegValue -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1
    Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' -Name 'OverlayTestMode' -Value 5

    $systemProfile = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    $gamesProfile = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
    Set-RegValue -Path $systemProfile -Name 'SystemResponsiveness' -Value 0
    Set-RegValue -Path $systemProfile -Name 'NetworkThrottlingIndex' -Value 4294967295
    Set-RegValue -Path $gamesProfile -Name 'Affinity' -Value 0
    Set-RegValue -Path $gamesProfile -Name 'Background Only' -Value 'False' -Type String
    Set-RegValue -Path $gamesProfile -Name 'Clock Rate' -Value 10000
    Set-RegValue -Path $gamesProfile -Name 'GPU Priority' -Value 8
    Set-RegValue -Path $gamesProfile -Name 'Priority' -Value 6
    Set-RegValue -Path $gamesProfile -Name 'Scheduling Category' -Value 'High' -Type String
    Set-RegValue -Path $gamesProfile -Name 'SFIO Priority' -Value 'High' -Type String

    netsh int tcp set global autotuninglevel=normal | Out-Null
    netsh int tcp set global rss=enabled | Out-Null
    netsh int tcp set global chimney=enabled | Out-Null
    netsh int tcp set global dca=enabled | Out-Null
    netsh int tcp set global netdma=enabled | Out-Null
    ipconfig /flushdns | Out-Null

    foreach ($exe in @('FiveM.exe','FiveM_GTAProcess.exe','GTA5.exe')) {
        $perfPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$exe\PerfOptions"
        Set-RegValue -Path $perfPath -Name 'CpuPriorityClass' -Value 3
        Set-RegValue -Path $perfPath -Name 'IoPriority' -Value 3
        Set-RegValue -Path $perfPath -Name 'PagePriority' -Value 5
    }

    Get-Process -Name 'FiveM','FiveM_GTAProcess','GTA5' | ForEach-Object {
        try {
            $_.PriorityClass = 'High'
            Write-Good "Raised live process priority: $($_.ProcessName)"
        }
        catch {
        }
    }

    Write-Good 'Gaming and low-latency tweaks applied.'
}

function Set-MemoryTweaks {
    $memoryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    Set-RegValue -Path $memoryPath -Name 'DisablePagingExecutive' -Value 1
    Set-RegValue -Path $memoryPath -Name 'LargeSystemCache' -Value 0
    Set-RegValue -Path $memoryPath -Name 'SecondLevelDataCache' -Value 1024

    $totalRam = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    if ($totalRam -ge 32) {
        Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value 33554432
    }
    elseif ($totalRam -ge 16) {
        Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value 16777216
    }

    Write-Good "Memory tweaks applied for $totalRam GB RAM."
}

function Disable-UnneededServices {
    if ($SkipServiceTweaks) {
        Write-WarnText 'Skipped service tweaks.'
        return
    }

    $disableServices = @(
        'DiagTrack',
        'dmwappushservice',
        'MapsBroker',
        'PhoneSvc',
        'RemoteRegistry',
        'RetailDemo',
        'WSearch',
        'XblAuthManager',
        'XblGameSave',
        'XboxGipSvc',
        'XboxNetApiSvc',
        'Fax',
        'AJRouter',
        'WMPNetworkSvc',
        'lfsvc',
        'SharedAccess',
        'TrkWks',
        'WerSvc'
    )

    $manualServices = @(
        'SysMain',
        'DoSvc',
        'BITS',
        'UsoSvc',
        'Spooler',
        'PcaSvc',
        'DiagSvc'
    )

    foreach ($name in $disableServices) {
        $svc = Get-Service -Name $name
        if ($svc) {
            if ($svc.Status -ne 'Stopped') {
                Stop-Service -Name $name -Force
            }
            Set-Service -Name $name -StartupType Disabled
            Write-Good "Disabled service: $name"
        }
    }

    foreach ($name in $manualServices) {
        $svc = Get-Service -Name $name
        if ($svc) {
            if ($svc.Status -ne 'Stopped' -and $name -in @('SysMain','DoSvc')) {
                Stop-Service -Name $name -Force
            }
            Set-Service -Name $name -StartupType Manual
            Write-Good "Set service to Manual: $name"
        }
    }
}

function Set-PowerPlan {
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $schemes = powercfg /list
    $ultimateGuid = (($schemes | Select-String 'Ultimate Performance').ToString() -split '\s+')[3]
    if (-not $ultimateGuid) {
        $ultimateGuid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    }
    powercfg /setactive $ultimateGuid | Out-Null
    powercfg /hibernate off | Out-Null
    powercfg /change monitor-timeout-ac 0 | Out-Null
    powercfg /change disk-timeout-ac 0 | Out-Null
    powercfg /change standby-timeout-ac 0 | Out-Null
    Write-Good 'Ultimate Performance power plan enabled.'
}

Test-Admin

$root = Split-Path -Parent $PSCommandPath
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $root "backup-$stamp"
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
Start-Transcript -Path (Join-Path $backupRoot 'optimization-log.txt') -Force | Out-Null

Write-Host 'Boost FiveM By Nozeed - Ultimate Windows Optimizer' -ForegroundColor Magenta
Write-Host 'Target: FiveM, GTA V, gaming latency, browsing, Windsurf web dev, voice chat, and creator workflow' -ForegroundColor Gray

Write-Section 'Backup and safety'
Export-RegistryBackup -BackupRoot $backupRoot
New-SystemRestorePoint

Write-Section 'Bloatware, OneDrive, Copilot'
Remove-Bloatware

Write-Section 'Visual performance'
Set-VisualTweaks

Write-Section 'Gaming latency and process priority'
Set-GamingTweaks

Write-Section 'Memory optimization'
Set-MemoryTweaks

Write-Section 'Service optimization'
Disable-UnneededServices

Write-Section 'Power plan'
Set-PowerPlan

Stop-Transcript | Out-Null
Write-Host "`nDone. Backup and logs saved to: $backupRoot" -ForegroundColor Green
Write-Host 'Recommended: restart Windows before benchmarking FiveM/GTA V.' -ForegroundColor Green
