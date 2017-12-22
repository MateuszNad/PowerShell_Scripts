<#
.Synopsis
    Returns script all user's objects in database
.DESCRIPTION
    Get-SQLScriptDatabaseObjects returns all user's objects to files .sql
    The function will create directories with objects groups. Looks like it:

    Directory: D:\Schema\DBA

Mode                LastWriteTime         Length Name                                                                                                                                                                                      
----                -------------         ------ ----                                                                                                                                                                                      
d-----       2017-07-31     07:41                StoredProcedures                                                                                                                                                                          
d-----       2017-09-05     14:39                Tables                                                                                                                                                                                    
d-----       2017-09-05     14:39                UserDefinedFunctions                                                                                                                                                                      
d-----       2017-07-31     07:41                Views                                                                                                                                                                                     

.EXAMPLE
    Get-SQLScriptDatabaseObjects -ServerInstance serwer-sql -Database DBA -Path D:\Schema
.EXAMPLE
   Another example of how to use this cmdlet
.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
 
   Date:18.10.2017
   Version: 1.0.0.0 
   Keywords: Script, Object, SMO, Scripter, Database, ServerInstance
   Notes: Add additional parameter. Example, switching Include Header
   Changelog:
#>
function Get-SQLScriptDatabaseObjects {
    [CmdletBinding()]
    [Alias()]
    Param
    (
        #Name Server Instance
        [Parameter(Mandatory = $true,
            Position = 0)]
        [string]$ServerInstance = 'serwer-sql',
        #Database name 
        [string]$Database, 

        [string]$Path

    )

    $ErrorActionPreference = 'Stop'

    try {
        $Objects = @()
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null
        $SMOserver = New-Object ('Microsoft.SqlServer.Management.Smo.Server') -argumentlist $ServerInstance
        $db = $SMOserver.databases['Indexes']

        ($db).name
        #object you want do backup. 
        $IncludeTypes = @("Tables", "StoredProcedures", "Views", "UserDefinedFunctions", "Triggers") 
        
        if (Test-Path (Join-Path -Path $Path -ChildPath $Database)) {
            Remove-Item (Join-Path -Path $Path -ChildPath $Database) -Recurse -Force
        }
    }
    catch {
        return $_.Exception.Message
    }

    try {
        Foreach ($Type in $IncludeTypes) {
            $Objects = $db.$Type | Where-Object IsSystemObject -eq $false 
            # | where {!($_.IsSystemObject) -and $_.Name -eq “$objname”}

            Foreach ($Object in $Objects) {

                $Scripter = new-object ('Microsoft.SqlServer.Management.Smo.Scripter') ($SMOserver)
                #Parameter for SMO.Scripter
                $Scripter.Options.AppendToFile = $False
                $Scripter.Options.AllowSystemObjects = $False
                $Scripter.Options.ClusteredIndexes = $True
                $Scripter.Options.DriAll = $True
                $Scripter.Options.ScriptDrops = $False
                $Scripter.Options.IncludeHeaders = $True
                $Scripter.Options.ToFileOnly = $True
                $Scripter.Options.Indexes = $True
                $Scripter.Options.WithDependencies = $True
                $Scripter.Options.IncludeHeaders = $false
                
                #Create path file
                $ScriptFile = $Object -replace "\[|\]"
                $FullPath = (Join-Path $Path -ChildPath "\$Database\$Type\$($ScriptFile).SQL")
                $Scripter.Options.FileName = $FullPath

                if (-not(Test-Path (Split-Path -Path ($FullPath)))) {
                    New-Item -Path (Split-Path -Path ($FullPath)) -ItemType Directory 
                }
                $Scripter.Script($Object)
            }
        }
    }
    catch {
        return $_.Exception.Message
    }    

    #Disconnect() connection
    $SMOserver.ConnectionContext.Disconnect()
}