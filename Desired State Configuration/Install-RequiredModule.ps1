<#
 .EXAMPLE
  PS C:\> Install-RequiredModule -Path 'C:\dscConfiguration.ps1' -Force -WhatIf -Verbose

 .EXAMPLE
  PS C:\> Install-RequiredModule -Path 'C:\dscConfiguration.ps1' -Force -Verbose
#>
function Install-RequiredModule
{
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string[]]$Path,
        [Parameter(Mandatory = $false)]
        [string[]]$ComputerName = 'localhost',
        [PSCredential]$Credential = [pscredential]::Empty,
        [switch]$Force
    )

    process
    {
        $ForceParam = $false
        if ($PSCmdlet.ShouldProcess("$ComputerName", "Install-RequiredModule"))
        {
            $WhatIf = $false
        }
        else
        {
            $WhatIf = $true
        }

        # $PSBoundParameters.Keys
        switch ($PSBoundParameters.Keys)
        {
            'Force'
            {
                $ForceParam = $true
            }
        }

        try
        {
            # $ContentFile = Get-Content $Path -Raw
            if (-not(Test-Path $Path))
            {
                Write-Output "Nie poprawna sciezka do pliku"
                return
            }

            $RequiredPS = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$null).ScriptRequirements

            foreach ($RequiredModule in $RequiredPS.RequiredModules)
            {
                # $RequiredModule
                $paramInstallModule = @{
                    Name   = $RequiredModule.Name
                    WhatIf = $WhatIf
                    Force  = $ForceParam
                }

                if ($null -ne $RequiredModule.MaximumVersion)
                {
                    $paramInstallModule.MaximumVersion = $RequiredModule.MaximumVersion
                }

                if ($null -ne $RequiredModule.RequiredVersion)
                {
                    $paramInstallModule.RequiredVersion = $RequiredModule.RequiredVersion
                }

                Write-Verbose ($paramInstallModule | ConvertTo-Json)

                if ($PSBoundParameters.ContainsKey('ComputerName'))
                {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        $VerbosePreference = $using:VerbosePreference
                        Write-Verbose "Install module on $using:ComputerName"
                        Install-Module @using:paramInstallModule
                    } -Credential $Credential

                }
                else
                {
                    Install-Module @paramInstallModule
                }
            }
        }
        catch
        {
            $ScriptBlock.Ast.ScriptRequirements
            Write-Warning $_
        }
    }
}



# DockerAndCompose -DockerComposeUri 'https://github.com/docker/compose/releases/download/1.27.4/docker-compose-Windows-x86_64.exe' -ComputerName 10.10.0.24
# Publish-DscConfiguration -Path .\DockerAndCompose -Verbose -Credential administrator -ComputerName 10.10.0.24 -Force
# Start-DscConfiguration -ComputerName 10.10.0.24 -Force -Wait -Path .\DockerAndCompose -Credential administrator


# Install-RequiredModule -Path 'C:\Users\Lenovo\Documents\Projekty\12_PowerShell\15_Repositories\PowerShell_Scripts\Desired State Configuration\Agent\dscInstallAgent.ps1' -ComputerName '10.10.0.24' -Force -Credential administrator  -Verbose
# Get-MMAgent -ComputerName 10.10.0.24 -Verbose -OPSINSIGHTS_WS_ID '1fc1ae0a-ee55-4070-9691-dc1adc10797f' -OPSINSIGHTS_WS_KEY ''
# Publish-DscConfiguration -Path .\MMAgent -ComputerName '10.10.0.24' -Credential administrator -Verbose -Force
# Start-DscConfiguration -Credential administrator -ComputerName 10.10.0.24 -Wait -Path .\MMAgent -Force


Start-DscConfiguration -ComputerName 10.10.0.24 -Force -Wait -Path .\DockerAndCompose -Credential administrator
