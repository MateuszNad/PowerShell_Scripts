#Requires -Module PackageManagement, ComputerManagementDsc, PowerSTIG

Configuration DockerAndCompose
{
    param(
        [Parameter(Mandatory)]
        [string]$DockerComposeUri,
        [string]$ComputerName
    )
    Import-DscResource -Module @{ModuleName = "PackageManagement"; ModuleVersion = "1.4.7" }
    Import-DscResource -Module @{ModuleName = "ComputerManagementDsc"; ModuleVersion = "8.4.0" }

    Node $ComputerName
    {
        WindowsFeature WF-Containers
        {
            Ensure = 'Present'
            Name   = 'Containers'
        }

        PackageManagementSource PSGallery
        {
            Ensure             = 'Present'
            Name               = 'PSGallery'
            ProviderName       = 'PowerShellGet'
            SourceLocation     = 'https://www.powershellgallery.com/api/v2'
            InstallationPolicy = 'Trusted'
        }

        PackageManagement DockerMsftProvider
        {
            Ensure    = 'Present'
            Name      = 'DockerMsftProvider'
            Source    = 'PSGallery'
            DependsOn = '[PackageManagementSource]PSGallery'
        }

        PackageManagement Docker
        {
            Ensure       = 'Present'
            Name         = 'Docker'
            ProviderName = 'DockerMsftProvider'
            DependsOn    = '[PackageManagement]DockerMsftProvider'
        }

        Script InstallDockerCompose
        {
            TestScript = { Test-Path -Path "$($Env:ProgramFiles)\Docker\docker-compose.exe" }
            SetScript  = {
                $paramInvokeWebRequest = @{
                    Uri             = $using:DockerComposeUri
                    UseBasicParsing = $true
                    OutFile         = "$($Env:ProgramFiles)\Docker\docker-compose.exe"
                }
                Invoke-WebRequest @paramInvokeWebRequest
            }
            GetScript  = {
                [PSCustomObject]@{
                    DockerCompose = "$($Env:ProgramFiles)\Docker\docker-compose.exe"
                }
            }
            DependsOn  = '[PackageManagement]Docker'
        }

        # See if a reboot is required after installing Exchange
        PendingReboot AfterInstallDocker
        {
            Name      = 'AfterInstallDocker'
            DependsOn = '[Script]InstallDockerCompose'
        }
    }
}
