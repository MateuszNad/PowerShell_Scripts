# parameter
param(
    # Default pattern: 'test', 'delete', 'sanbox'

    $NamePattern = ('test', 'delete', 'sanbox'),
    [switch]$NoAzAutomation
)

if (-not $NoAzAutomation.IsPresent)
{
    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

        "Logging in to Azure..."
        Connect-AzAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
    }
    catch
    {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        }
        else
        {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
}
try
{
    Import-Module Az.Resources
    $ResourceGroups = Get-AzResourceGroup

    Write-Verbose "Speficied Name: $($NamePattern -join ', ')"
    foreach ($ResourceGroup in $ResourceGroups)
    {
        $NamePattern | ForEach-Object {
            if ($ResourceGroup.ResourceGroupName -match $_)
            {
                ("The resource group {0} matches with the pattern" -f $ResourceGroup.ResourceGroupName)
                Remove-AzResourceGroup -Name $ResourceGroup.ResourceGroupName -Verbose -Force
            }
        }
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
