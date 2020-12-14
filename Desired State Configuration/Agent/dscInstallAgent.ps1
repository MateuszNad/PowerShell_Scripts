#Requires -Module xPSDesiredStateConfiguration

Configuration MMAgent
{
    param(
        [Parameter(Mandatory)]
        $ComputerName,
        $OIPackageLocalPath = "C:\Deploy\MMASetup-AMD64.exe",
        [Parameter(Mandatory)]
        $OPSINSIGHTS_WS_ID, #= Get-AutomationVariable -Name "OPSINSIGHTS_WS_ID"
        [Parameter(Mandatory)]
        $OPSINSIGHTS_WS_KEY#= Get-AutomationVariable -Name "OPSINSIGHTS_WS_KEY"
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName {
        Service OIService
        {
            Name      = "HealthService"
            State     = "Running"
            DependsOn = "[Package]OI"
        }

        xRemoteFile OIPackage
        {
            Uri             = "https://go.microsoft.com/fwlink/?LinkId=828603"
            DestinationPath = $OIPackageLocalPath
        }

        Package OI
        {
            Ensure    = "Present"
            Path      = $OIPackageLocalPath
            Name      = "Microsoft Monitoring Agent"
            ProductId = "8A7F2C51-4C7D-4BFD-9014-91D11F24AAE2"
            Arguments = '/C:"setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=' + $OPSINSIGHTS_WS_ID + ' OPINSIGHTS_WORKSPACE_KEY=' + $OPSINSIGHTS_WS_KEY + ' AcceptEndUserLicenseAgreement=1"'
            DependsOn = "[xRemoteFile]OIPackage"
        }
    }
}
