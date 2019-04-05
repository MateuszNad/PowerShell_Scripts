<#
.Synopsis
   Function splits diagnostics queries from Glenn Berry to separate files.
.DESCRIPTION
    Function splits diagnostic information queries from Glenn Berry to separate file. 
    In every file is only one query without additional comments.
    
    Link to queries: https://www.sqlskills.com/blogs/glenn/category/dmv-queries/
.EXAMPLE
    $paramSplitSQLServerDiagnosticQueries = @{
        OutPath = 'C:\SQL Server 2014 Diagnostic Information Queries\Splitted'
        Path    = 'C:\SQL Server 2014 Diagnostic Information Queries.sql'
    }
    Split-SQLServerDiagnosticQueries @paramSplitSQLServerDiagnosticQueries 
.EXAMPLE
   Split-DiagnosticQueries -OutPath 'C:\SQL Server 2014 Diagnostic Information Queries\Splitted' -Path 'C:\SQL Server 2014 Diagnostic Information Queries.sql' -Verbose
.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
 
   Date: 02.03.2019
   Version: 1.0.0.0 
   Keywords: Split, diagnostics queries, Glenn Berry 
   Notes: 
   Changelog:
#> 
function Split-SQLServerDiagnosticQueries {
    [cmdletbinding()]
    [Alias('Split-DiagnosticQueries')]
    param(
        [Parameter(Mandatory)]
        [ValidateScript( { '.sql' -eq (Get-Item $_).Extension })]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$OutPath
    )
    # regex for splits the file on queries
    [regex]$regexQuery = '((?=\(Query )((?:.*?\r?\n?)*);)'
    # regex for naming a new file 
    [regex]$regexFileName = '\((.*?)\)'

    $Content = (Get-Content $Path) -join "`n"

    $regexQuery.Matches($content) | ForEach-Object {
        $QueryContent = $_.Groups[1].Captures[0].Value
        # getting name for file
        $FileName = ($regexFileName.Matches($QueryContent))
        # saving the file with a query
        $Query = $QueryContent.Replace("$($fileName[0].Value) $($fileName[1].Value)", "--$($fileName[0].Value)_$($fileName[1].Value)" ) 
        Write-Verbose "Saving $($fileName[0].Value) $($fileName[1].Value) to file"
        $Query | Out-File -FilePath (Join-Path -Path $OutPath -ChildPath "$($fileName[0].Value)_$($fileName[1].Value).sql")
    }
}