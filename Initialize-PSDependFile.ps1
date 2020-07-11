<#
.Synopsis
    Krótki opis

.DESCRIPTION
    Trochę dłuższy opis

.EXAMPLE
    (Get-Module dbatools -ListAvailable ).RepositorySourceLocation | Search-PSRepository

.LINK
    Author: Mateusz Nadobnik
    Link: mnadobnik.pl

    Date:
    Version: 1.0.0.0
    eywords:
    Notes:
    Changelog:
#>
function Search-PSRepository
{
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Uri]$RepositorySourceLocation
    )

    begin
    {
        $Repositories = Get-PSRepository
    }
    process
    {
        foreach ($Repository in $Repositories)
        {
            if (($Repository.SourceLocation) -eq $RepositorySourceLocation.OriginalString )
            {
                #$RepositorySourceLocation
                $Repository.Name
            }
        }
    }
}


<#
.EXAMPLE
    $FilePath = 'W:\Mateusz\test.module.psd1'
    $Exclude = '*VMWare*'
    Initialize-PSDependFile -Path $FilePath -Exclude $Exclude

#>
function Initialize-PSDependFile
{
    param (
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [string[]]$Exclude,
        [Parameter(Mandatory = $false)]
        [string[]]$Include #do poprawienia
    )

    begin
    {

    }
    process
    {
        $Modules = Get-Module -ListAvailable | Where-Object { $_.RepositorySourceLocation -and $_.Name -notlike $Exclude } | Group-Object -Property Name
        Foreach ($Module in $Modules)
        {
            # get the latest module
            $LatestModule = ($Modules | Where-Object Name -eq $Module.Name).Group[0]
            $PSRepository = $LatestModule.RepositorySourceLocation | Search-PSRepository

            $ModuleJson += @"
`t'$($LatestModule.Name)_$($LatestModule.Version)' = @{
    `tName = '$($LatestModule.Name)'
    `tParameters = @{
        `tRepository         = '$PSRepository'
        `tSkipPublisherCheck = `$true
    `t}
    `tVersion = '$($LatestModule.Version)'
`t}`n
"@
        }
    }
    end
    {
        $FullJson = @"
@{
$ModuleJson
}
"@
        $FullJson | Out-File -FilePath $Path
        # Clear $FullJson
        $FullJson = ''
    }
}