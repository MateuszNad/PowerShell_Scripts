## Synopsis

Skrypt do testowania parametrów BufferCount oraz MaxTransferSize w celu optymalizacji przywracania bazy danych.

## Examples

  Test-OptimizationRestoreDatabase `
    -MaxTransferSize default,65536,524288,1048576,2097152,4194304 `
    -TotalMemory 1500 `
    -SetsofBuffers 2 `
    -CountOfRepeat 4 `
    -ServerInstance SERWER-SQL\MSSQLSERVER14 -Database AdventureWorks2014 `
    -BackupPath 'E:\SQLBackup\AdventureWorks2014_C.bak' `
    -Break 30
