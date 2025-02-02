# Module Variables
$script:ConfigPath = Join-Path $PSScriptRoot "Config"
$script:LogPath = Join-Path $PSScriptRoot "Logs"
$script:StateKeyPath = "HKLM:\SOFTWARE\PCConfig"
$script:PhaseKeyName = "CurrentPhase"

# Initialize Module
function Initialize-Module {
    if (-not (Test-Path $script:LogPath)) {
        New-Item -ItemType Directory -Path $script:LogPath -Force
    }
    if (-not (Test-Path $script:StateKeyPath)) {
        New-Item -Path $script:StateKeyPath -Force
    }
}

function Get-PCIdentifier {
    $mac = Get-WmiObject Win32_NetworkAdapter | 
        Where-Object { $_.PhysicalAdapter } | 
        Select-Object -First 1 -ExpandProperty MACAddress
    return $mac.Replace(':', '')
}

function Write-Log {
    param($Message, $Level = "Info")
    
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): [$Level] $Message"
    $logFile = Join-Path $script:LogPath "PCConfig_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $logMessage
}

function Get-ConfigurationPhase {
    $phase = Get-ItemProperty -Path $script:StateKeyPath -Name $script:PhaseKeyName -ErrorAction SilentlyContinue
    if ($phase) {
        return $phase.$script:PhaseKeyName
    }
    return 0
}

function Set-ConfigurationPhase {
    param([int]$Phase)
    Set-ItemProperty -Path $script:StateKeyPath -Name $script:PhaseKeyName -Value $Phase
}

function Register-RebootTask {
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"Import-Module PCConfig; Start-PCConfiguration`""
    
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    Register-ScheduledTask -TaskName "PCConfig_Continue" -Action $action -Trigger $trigger -Principal $principal -Force
}

function Start-PCConfiguration {
    Initialize-Module
    $pcId = Get-PCIdentifier
    Write-Log "Starting configuration for PC: $pcId"
    
    $currentPhase = Get-ConfigurationPhase
    
    switch ($currentPhase) {
        0 {
            Write-Log "Phase 1: Configuring Power Settings"
            # TODO: Implement power settings configuration
            Set-ConfigurationPhase 1
            Register-RebootTask
            Restart-Computer -Force
        }
        1 {
            Write-Log "Phase 2: Configuring User Accounts"
            # TODO: Implement user account configuration
            Set-ConfigurationPhase 2
            Register-RebootTask
            Restart-Computer -Force
        }
        2 {
            Write-Log "Phase 3: Configuring Registry Settings"
            # TODO: Implement registry configuration
            Set-ConfigurationPhase 3
            Register-RebootTask
            Restart-Computer -Force
        }
        3 {
            Write-Log "Phase 4: Installing Applications"
            # TODO: Implement application installation
            Set-ConfigurationPhase 4
            Unregister-ScheduledTask -TaskName "PCConfig_Continue" -Confirm:$false
            Write-Log "Configuration Complete"
        }
    }
}

# Export functions
Export-ModuleMember -Function Start-PCConfiguration, Get-PCIdentifier, Set-ConfigurationPhase, Get-ConfigurationPhase
