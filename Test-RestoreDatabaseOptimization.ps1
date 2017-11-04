<#
.Synopsis
    Skrypt do testowania parametr�w BufferCount oraz MaxTransferSize dla przywracania bazy danych.
.DESCRIPTION
   Skrypt umo�liwia RESTORE bazy danych z okre�lona ilo�� powt�rze�. Skrypt na podstawie podanej, jako
   parameter warto�cia MaxTransferSize, SetOfBuffers oraz TotalMemory wylicza warto�� parametru BufferCount.

   Skrypt zwraca czas oraz szybko�� MB/sec. Odczytuje te warto�ci z dziennika bledow SQL Server, dlatego tez,
   przed ka�da operacja RESTORE wykonywana jest procedura sp_cycle_errorlog zamykajaca obecny dziennik bledow.

   Skrypt nie nale�y stosowa� w �rodowisku produkcyjnym.
   Wymaga PowerShell 5.0 oraz modu�y SqlServer. 
.EXAMPLE
  Test-RestoreDatabaseOptimization `
    -MaxTransferSize default,65536,524288,1048576,2097152,4194304 `
    -TotalMemory 1500 `
    -SetsofBuffers 2 `
    -CountOfRepeat 4 `
    -ServerInstance SERWER-SQL\MSSQLSERVER14 -Database AdventureWorks2014 `
    -BackupPath 'E:\SQLBackup\AdventureWorks2014_C.bak' `
    -Break 30
.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl

   Date: 23.10.2017
   Version: 1.0.0.0 
   Keywords: Restore, BufferCount, MaxTransferSize, TotalMemory, Duration, MB/sec, SqlServer
   Notes: 
   Changelog:
#>

#Requires -Version 5.0
#Requires -Modules SqlServer
function Test-RestoreDatabaseOptimization
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([String])]
    Param
    (
        #Nazwa instancji SQL Server
        [Parameter(Mandatory=$true)]
        [string]$ServerInstance,

        #Nazwa bazy danych
        [Parameter(Mandatory=$true)]
        [string]$Database,
        
        #Sciezka do pliki .bak
        [Parameter(Mandatory=$true)]
        [string]$BackupPath,

        #MaxTransferSize - maksymalna ilo�� danych, kt�re b�d� przetwarzane na bufor
        [Parameter(Mandatory=$true)]
        [ValidateSet('65536', '524288', '1048576', '2097152', '4194304','default')]
        [array]$MaxTransferSize,

        #Limit pami�ci to ilo�� pami�ci wewn�trznej puli bufor�w, kt�ra jest dost�pna dla tego procesu tworzenia kopii /przywracania.�
        [Parameter(Mandatory=$false)]
        [int]$TotalMemory,

        #Liczba Sets of Buffers, domy�lnie = 1
        [Parameter(Mandatory=$false)]
        [int]$SetsofBuffers = 1,
        
        #Liczba powtrze�
        [Parameter(Mandatory=$false)]
        [int]$CountOfRepeat,
        
        #Przerwa pomi�dzy odzyskiwaniami wyra�ona w sekundach
        [Parameter(Mandatory=$false)]
        [int]$Break = 10
    )

    Begin
    {
        $Error.Clear()
        <#if(-not (Get-Module SqlServer))
        {
            try 
            {
                Install-Module -Name SqlServer -Force
            }
            catch
            {
                return $Error[0]
            }
        }#>
    }
    Process
    {
        $Object =@()
        Foreach($MTS in $MaxTransferSize)
        {
            1 .. $CountOfRepeat | Foreach {

                $ObjResult = @{} | Select BufferCount, MaxTransferSize, TotalLimit, Duration, MBperSecond
                $query = "EXEC sp_cycle_errorlog
                GO
                DBCC TRACEON(3014,3605)
                GO `n"

                if($MTS -eq 'default')
                {
                     [int]$BufferCount = 6
                     [int]$MaxTransferSize = 1048576
                }
                else
                {
                    [int]$BufferCount = (($TotalMemory*1MB)/([int]$MTS))/$SetsOfBuffers
                    [int]$MaxTransferSize = $MTS
                }

                try 
                {
                            
                    $query += Restore-SqlDatabase -ServerInstance $ServerInstance -Database $Database -BackupFile $BackupPath `
                    -ReplaceDatabase -BufferCount $BufferCount -MaxTransferSize $MaxTransferSize -Script 
                    Write-Host "Restoring database $Database with options BufferCount $BufferCount and MaxTransferSize $MaxTransferSize" -ForegroundColor Yellow
                    #Write-Host $query
                    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -QueryTimeout 0
                    Sleep -Seconds $Break

                }
                catch
                {
                    return $Error[0]
                }
                
                try 
                {
                    $querResult = 'EXEC xp_ReadErrorLog 4, 1, "RESTORE DATABASE successfully"'
                    $result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database msdb -Query $querResult -ErrorAction Stop
                    Write-Host $result.Text -ForegroundColor Yellow
                
                    [regex]$regex = '\d{1,8}[\,\.]{1}\d{1,8}'
                    $TextResult = $regex.Matches($result.Text)
                }
                catch
                {
                    return $Error[0]
                }

                #Add to ObjResult
                $ObjResult.BufferCount = ($BufferCount)
                $ObjResult.MaxTransferSize = ($MaxTransferSize)
                $ObjResult.Duration = [float]$TextResult[0].Value
                $ObjResult.MBperSecond = [float]$TextResult[1].Value
                $objResult.TotalLimit = ((($BufferCount)*($MaxTransferSize))*$SetsOfBuffers)/1MB
                
                #$ObjResult
                $Object += $ObjResult
            }
        }

    }
    End
    {
        return $Object
    }
}