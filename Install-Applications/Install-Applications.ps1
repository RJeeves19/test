# Installation orchestrator script
param (
    [string]$ConfigPath = ".\Install-Config",
    [string]$StateFile = "$env:TEMP\InstallState.json",
    [string]$LogFile = ".\Install.log"
)

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

function Set-AutoRestart {
    param($NextApp)
    $scriptPath = $MyInvocation.MyCommand.Path
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName "ContinueApplicationInstall" -Action $action -Trigger $trigger -Principal $principal -Force
    
    # Save state
    @{
        LastCompletedApp = $NextApp
        PendingReboot = $true
    } | ConvertTo-Json | Set-Content -Path $StateFile
}

function Remove-AutoRestart {
    Unregister-ScheduledTask -TaskName "ContinueApplicationInstall" -Confirm:$false
}

function Install-Application {
    param($AppConfig)
    
    Write-Log "Starting installation of $($AppConfig.ApplicationName)"
    
    try {
        # Run installer
        $process = Start-Process -FilePath $AppConfig.InstallerPath -ArgumentList $AppConfig.InstallerArguments -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Log "Installation completed successfully"
            
            # Verify installation
            if (Test-Path $AppConfig.VerificationPath) {
                Write-Log "Installation verified successfully"
                return $true
            }
        }
        
        Write-Log "Installation failed with exit code: $($process.ExitCode)"
        return $false
    }
    catch {
        Write-Log "Error during installation: $_"
        return $false
    }
}

# Main installation logic
try {
    Write-Log "Starting installation process"
    
    # Get all application configs
    $configs = Get-ChildItem -Path $ConfigPath -Filter "*.json" | 
        ForEach-Object { Get-Content $_.FullName | ConvertFrom-Json } |
        Sort-Object InstallationOrder
    
    # Get current state
    $state = if (Test-Path $StateFile) {
        Get-Content $StateFile | ConvertFrom-Json
    } else {
        @{
            LastCompletedApp = $null
            PendingReboot = $false
        }
    }
    
    # Process each application
    foreach ($app in $configs) {
        # Skip if already installed
        if ($state.LastCompletedApp -ge $app.InstallationOrder) {
            Write-Log "Skipping $($app.ApplicationName) - already installed"
            continue
        }
        
        # Install application
        if (Install-Application $app) {
            if ($app.RequiresReboot) {
                Write-Log "Setting up auto-restart for next application"
                Set-AutoRestart $app.InstallationOrder
                Restart-Computer -Force
                exit
            }
        }
        else {
            Write-Log "Installation failed for $($app.ApplicationName)"
            exit 1
        }
    }
    
    # Cleanup after all installations
    Remove-AutoRestart
    Remove-Item $StateFile -ErrorAction SilentlyContinue
    Write-Log "All installations completed successfully"
}
catch {
    Write-Log "Fatal error: $_"
    exit 1
}
