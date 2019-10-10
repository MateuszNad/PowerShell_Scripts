
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
        $DefaultProperties = ($PSItem | Get-TypeData).DefaultDisplayPropertySet.ReferencedProperties

        $PSItem.PSObject.Properties | ForEach-Object {
            # Value search
            if ($_.Value -like $value )
            {
                # Adding to the variable name of property`
                [array]$ValueInProperty += $_.Name
            }
        }
        if ($ValueInProperty)
        {
            # Adding a new property to the

            $PSItem | Add-Member -MemberType NoteProperty -Name "ValueInProperty" -Value $ValueInProperty
            $DefaultProperties = ($PSItem | Get-TypeData).DefaultDisplayPropertySet.ReferencedProperties
            $DefaultProperties = $DefaultProperties + 'ValueInProperty'
            # $DefaultProperties
            # $PSItem
            # $PSItem | Update-TypeData -DefaultDisplayPropertySet $DefaultProperties
            Remove-Variable -Name ValueInProperty
            Write-Output $PSItem
        }
    }
}
