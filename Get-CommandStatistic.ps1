function Get-CommandStatistic {
    <#
.Synopsis
   Statystyki wykorzystania komend w skryptach

.DESCRIPTION
  Funkcja parsuję wszystkie skrypty .ps1 z wskazanej w parametrze lokalizacji w celu zwrócenia listy
   wykorzystywanych komend wraz z ilością wystąpień.

.EXAMPLE
    Get-CommandStatistic -Path 'C:\PowerShell\Przyklad' 

    Command                                  Count
    -------                                  -----
    Connect-PSToAzure                            5
    Set-PSSubscription                           4
    ...
    New-PSResourceGroup                          2

    Ścieżka do funkcji przekazana parametrem -Path zwróci wszystkie znalezione polecenia w przypadkowej kolejności.

.EXAMPLE
    Get-CommandStatistic -Path 'C:\PowerShell\Przyklad' | Sort-Object -Property Count -Descending | Select-Object -First 10

    Command                   Count
    -------                   -----
    New-Object                   11
    Create-Log                    8
    Get-AzureRMVM                 4
    ForEach-Object                4
    Out-Null                      3

    Wyniki funkcji zostaną posortowane i ograniczone do pierwszych 10 o największej liczbie wystąpień.

.NOTES
   Author: Mateusz Nadobnik
   Link: https://akademiapowershell.pl
 
   Date:    2019.01.01
   Version: 0.1.0
   Keywords: Command, Statistic, Parse, Tokenize 
   Notes: 
   Changelog:
#>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )
    [array]$Command = $null
    if (Test-Path -Path $Path) {
        # Pobranie wszystkich plików .ps1 również tych w podfolderach
        $Scripts = Get-ChildItem -Path $Path -Recurse -Filter *.ps1
        foreach ($Script in $Scripts) {
            
            try {
                $ContentScript = Get-Content -Path $Script.FullName -ErrorAction 'Stop'
            }
            catch {
                $ContentScript = $null
            }

            if ($ContentScript) {
                $Command += [System.Management.Automation.PSParser]::Tokenize($ContentScript, [ref]$null)
            }
        }
        # wyszukanie komend, pogrupowanie i selekcja włsciwosci
        $GroupedCommand = ($Command | Where-Object Type -eq 'Command' | Group-Object -Property Content |
            Select-Object -Property @{L = 'Command'; E = { $_.Name } }, Count)
                
        Write-Output $GroupedCommand
    }
    else {
        Write-Warning "Podana ścieżka nie istnieje."
    }
}