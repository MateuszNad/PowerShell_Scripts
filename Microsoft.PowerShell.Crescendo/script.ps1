# New-CrescendoCommand -Verb Get -Noun DockerContainer -Verbose | ConvertTo-Json -Depth 5 | Out-File example.docker.json
#  SchemaFile 'https://raw.githubusercontent.com/PowerShell/Crescendo/master/Microsoft.PowerShell.Crescendo/src/Microsoft.PowerShell.Crescendo.Schema.json'
# https://github.com/tyconsulting/TestJsonSchema-PS

Export-CrescendoModule -ConfigurationFile .\example.docker.json -ModuleName docker -Force

# import module
Remove-Module -Name Docker -ErrorAction SilentlyContinue
Import-Module .\docker.psm1

# example
Get-DockerContainer -Force -Filter name=th

# Command      : "dotnet HotelReserva…"
# CreatedAt    : 2020-03-19 15:52:07 +0100 CET
# ID           : ed41424ee78f
# Image        : reservationsystem
# Labels       :
# LocalVolumes : 0
# Mounts       :
# Names        : thirsty_driscoll
# Networks     : nat
# Ports        :
# RunningFor   : 9 months ago
# Size         : 0B
# State        : exited
# Status       : Exited (2147516566) 9 months ago
