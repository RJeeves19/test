@{
    RootModule = 'PCConfig.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'f8b0e65a-9b8e-4c71-b2a1-b87d0e74af1c'
    Author = 'PCConfig Module'
    Description = 'Automated PC Configuration Module'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Start-PCConfiguration',
        'Get-PCIdentifier',
        'Set-ConfigurationPhase',
        'Get-ConfigurationPhase'
    )
    PrivateData = @{
        PSData = @{}
    }
}
