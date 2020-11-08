
function Push-DscConfiguration
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName,
        [Parameter(Mandatory)]
        [string]$Path
    )

    process
    {
        foreach ($Item in $ComputerName)
        {
            Install-RequiredModule -Path $Path -ComputerName $ComputerName


        }
    }
}
