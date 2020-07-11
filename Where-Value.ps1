
<#
.Synopsis
    The function returns objects which have got input value in any properties.

.DESCRIPTION
    The function returns objects which have got input value in any properties. The function
    adds to the original object the property "ValueInProperty".
    There it saves properties` names in whose value was found.

.EXAMPLE
    przyklad_1

.EXAMPLE
    przyklad_2

.NOTES
    Author: autor
    Link: akademiapowershell.pl

    Date: 03-10-2019
    Version: version
    eywords: keywords
    Notes:
    Changelog:
#>

Function Where-Value
{
    [Cmdletbinding()]
    Param
    (
        [parameter(ValueFromPipeline)]
        $InputObject,
        [parameter(Mandatory)]
        $Value
    )
    Process
    {
        $PSItem.PSObject.Properties | ForEach-Object {
            # Value search
            if ($_.Value -match $value)
            {
                # Adding to the variable name of property`
                [array]$ValueInProperty += $_.Name
            }
        }

        if ([array]$ValueInProperty)
        {
            # Adding a new property
            #$PSItem | Add-Member -MemberType NoteProperty -Name "ValueInProperty" -Value $ValueInProperty
            #Remove-Variable -Name ValueInProperty
            Write-Output $PSItem
        }
    }
    End
    {
        Write-Verbose "The value $Value contains property: $ValueInProperty"
    }
}



<#
Ciekawy wpis. Dodam od siebie, że pierwsze zadanie najłatwiej wykonać: Get-Service | Select *Name*  Drugie faktycznie nie należy do tych trywialnych.

Co do 'Stopped' jako true, wydaje mi się, że to wynika, z niejawnej konwersji liczbowej wartości tego statusu (1) do typu [Bool]
[System.ServiceProcess.ServiceControllerStatus]::Stopped.value__ -eq $true
[System.ServiceProcess.ServiceControllerStatus]::Running.value__ -eq $false
#>
