#Requires -Module xPSDesiredStateConfiguration

Configuration MMAgent {
    param(        
        [Parameter(Mandatory)]        
        $OPSINSIGHTS_WS_ID,
        [Parameter(Mandatory)]        
        $OPSINSIGHTS_WS_KEY,
        [Parameter(Mandatory)]        
        [string[]]$ComputerName,
        $OIPackageLocalPath = "C:\Deploy\MMASetup-AMD64.exe"
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node $ComputerName {
        Service OIService
        {
            Name      = "HealthService"            
            State     = "Running"            
            DependsOn = "[Package]OI"
        }

        xRemoteFile OIPackage
        {
            Uri             = "https://go.microsoft.com/fwlink/?LinkId=828603"            
            DestinationPath = $OIPackageLocalPath
        }

        Package OI
        {
            Ensure    = "Present"            
            Path      = $OIPackageLocalPath            
            Name      = "Microsoft Monitoring Agent"            
            ProductId = "88EE688B-31C6-4B90-90DF-FBB345223F94"            
            Arguments = '/C:"setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=' + $OPSINSIGHTS_WS_ID + ' OPINSIGHTS_WORKSPACE_KEY=' + $OPSINSIGHTS_WS_KEY + ' AcceptEndUserLicenseAgreement=1"'            
            DependsOn = "[xRemoteFile]OIPackage"
        }    
    }
}
