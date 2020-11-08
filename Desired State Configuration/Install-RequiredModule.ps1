# $a = @'
# #Requires -module xPSDesiredStateConfiguration, DSCtest
# #Requires -RunAsAdministrator
# #Requires -Modules @{ ModuleName="AzureRM.Netcore"; MaximumVersion="0.12.0" }
# #Requires -PSEdition Core
# #Requires -Version 7

# Wirte-Host 'test'
# '@


# $test = [ScriptBlock]::Create($a)
# $RequiredPS = $test.Ast.ScriptRequirements

# $RequiredPS

function Install-RequiredModule
{
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string[]]$Path,
        [Parameter(Mandatory = $false)]
        [string[]]$ComputerName = 'localhost'
    )

    process
    {
        if ($PSCmdlet.ShouldProcess("Target", "Operation"))
        {
            $WhatIf = $true
        }

        try
        {
            $ContentFile = Get-Content $Path

            $ScriptBlock = [ScriptBlock]::Create($ContentFile)
            $RequiredPS = $ScriptBlock.Ast.ScriptRequirements

            foreach ($RequiredModule in $RequiredPS.RequiredModules)
            {
                # $RequiredModule
                $paramInstallModule = @{
                    Name            = $RequiredModule.Name
                    MaximumVersion  = $RequiredModule.MaximumVersion
                    RequiredVersion = $RequiredModule.RequiredVersion
                    WhatIf          = $WhatIf
                }

                Write-Verbose ($paramInstallModule | ConvertTo-Json)

                if ($ComputerName -ne 'localhost' )
                {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        Install-Module @using:paramInstallModule
                    }
                }
                else
                {
                    Install-Module @paramInstallModule
                }

            }
        }
        catch
        {
            Write-Warning $_
        }
    }
}

Install-RequiredModule -Path C:\Temp\test.ps1 -WhatIf
