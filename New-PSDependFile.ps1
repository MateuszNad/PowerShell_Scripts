buildhelpers_0_0_20 = @{
    Name           = 'buildhelpers'
    DependencyType = 'PSGalleryModule'
    Parameters     = @{
        Repository         = 'PSGallery'
        SkipPublisherCheck = $true
    }
    Version        = '0.0.20'
    Tags           = 'prod', 'test'
    PreScripts     = 'C:\RunThisFirst.ps1'
    DependsOn      = 'some_task'
}


function Initialize-PSDependFile
{
    param (
        [string]$Path,
        [string[]]$Exclude
    )

    $Modules = Get-Module -ListAvailable | Where-Object { $_.RepositorySourceLocation -and $_.Name -notlike $Exclude } | Group-Object -Property Name
    Foreach ($Module in $Modules)
    {
        # get the latest module
        $LatestModule = ($Modules | Where-Object Name -eq $Module.Name).Group[0]
        ("{0}{1}" -f $LatestModule.Name, $LatestModule.Version)


        "'{0}' = { Name = '{1}'}" -f $LatestModule.Name, $LatestModule.Version

        $ContentPSD += ("`t'{0}' = @{
            Name = '{1}'`n}" -f $LatestModule.Name, $LatestModule.Version)

    }
    $ContentPSD
}
Get-Module | Select *



$FilePath = 'W:\Mateusz\test.module.psd1'
$Exclude = '*VMWare*'




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


(Get-Module dbatools -ListAvailable ).RepositorySourceLocation | Search-PSRepository
$Ver = (Get-Module psnps -ListAvailable).RepositorySourceLocation
$Ver | Search-PSRepository




$FilePSD = @"
@{
    $ContentPSD
}
"@ | Out-File -FilePath $FilePath
$Modules = ''