. '.\Desired State Configuration\Agent\dscMMAgent.ps1'
$ComputerName = '10.10.0.25'
$Credential = Get-Credential -UserName administrator

$param = @{
    ComputerName       = $ComputerName
    OPSINSIGHTS_WS_ID  = 'xxxxxxxxxx'
    OPSINSIGHTS_WS_KEY = 'iiiii'
}
Get-MMAgent @param

$installParam = @{
    ComputerName = $ComputerName
    Path         = '.\Desired State Configuration\Agent\dscMMAgent.ps1'
    Force        = $true
    Credential   = $Credential
}
Install-RequiredModule @installParam

$dscParam = @{
    ComputerName = $ComputerName
    Path         = '.\MMAgent'
    Wait         = $true
    Force        = $true
    Credential   = $Credential
}
Start-DscConfiguration @dscParam -Verbose
