<#
.Synopsis
   Install-ELKStack
.DESCRIPTION
   The script to install ELK Stack
.EXAMPLE
    Just run the script but most safety will be run the script in steps. First, pre-setup and next steps
.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
 
   Date: 
   Version: 1.0.0.0 
   Keywords: ELK Stack, Elasticsearch, Logstach, Kibana
   Notes: First fersion
   Changelog: Next change: adding error handling and changing this script to the function
#> 

#### Pre-setup ####

#Directory for all ELK
$Destination = 'E:\ELK'

#Parameters for NSSM
$NSSM = @{
    URL  = 'https://nssm.cc/release/nssm-2.24.zip'
    Name = 'NSSM'
}
#Parameters for Elasticsearch
$Elasticsearch = @{
    URL  = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.1.1.zip'
    Name = 'Elasticsearch'
}
#Parameters for Logstach
$Logstach = @{
    URL  = 'https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.zip'
    Name = 'Logstash'
}
#Parameter for Kibana
$Kibana = @{
    URL  = 'https://artifacts.elastic.co/downloads/kibana/kibana-6.1.1-windows-x86_64.zip'
    Name = 'Kibana'
}

#Check environment variable JAVA_HOME
Write-Host "Check JAVA_HOME "
if ((-not ([System.Environment]::GetEnvironmentVariable('JAVA_HOME'))) -or ($env:JAVA_HOME -eq '')) { 
    Write-Host 'In system not exist environment variable JAVA_HOME' -ForegroundColor Red
    Write-Host "You can use this command: `n[Environment]::SetEnvironmentVariable(""JAVA_HOME"", ""<your_path_to_jdk>"", ""Machine"")"
    Write-Host 'Add, close this script and run the script again.'
    return
}
else {
    Write-Host 'In system exist environment variable JAVA_HOME' -ForegroundColor Green
    Write-Host "JAVA_HOME: $([System.Environment]::GetEnvironmentVariable('JAVA_HOME'))" 
}

#Checks the location destination
if (-not(Test-Path $Destination)) {
    Write-Host "Create directory - $Destination"
    New-Item -Path $Destination -ItemType Directory
}

#The function downloading and unpacking resources
function Get-Resource([string]$url, [string]$name, [string]$Destination) {
    Write-Host "Downloading $Name"
    if (Test-Path $Destination) { Invoke-WebRequest -Uri $url -OutFile (Join-Path $Destination -ChildPath (Split-Path $url -Leaf)) }
    Write-Host "Unpacking $Name"
    Expand-Archive (Join-Path $Destination -ChildPath (Split-Path $url -Leaf)) -DestinationPath $Destination
    Write-Host "Rename directory to $Name"
    Rename-Item -Path (Join-Path $Destination -ChildPath ((Split-Path $url -Leaf).Replace('.zip', ''))) -NewName $name -Force 
}

#Step 1 - Install Elasticsearch
Write-Host "Downloading, unpacking Elasticsearch to $Destination" -ForegroundColor Yellow
Get-Resource -url $Elasticsearch.URL -destination $Destination -name $Elasticsearch.Name

Write-Host
Write-Host 'Expected message:' -ForegroundColor Green
Write-Host 'Installing service      :  "elasticsearch-service-x64"' -ForegroundColor Green
Write-Host "Using JAVA_HOME (64-bit):  ""$([System.Environment]::GetEnvironmentVariable('JAVA_HOME'))""" -ForegroundColor Green
Write-Host 'The service ''elasticsearch-service-x64'' has been installed.' -ForegroundColor Green
Write-Host

Write-Host "Installation Elasticsearch" -ForegroundColor Yellow
Invoke-Expression -command "$Destination\$($Elasticsearch.Name)\bin\elasticsearch-service.bat install”

Write-Host
Write-Host "Start service Elasticsearch"
Write-Host "Change Startup type to Automatic"
Get-Service elasticsearch* | Start-Service -PassThru
Get-Service elasticsearch* | Set-Service -StartupType Automatic 

Write-Host "Checking the address http://localhost:9200"
Sleep -Seconds 30
(Invoke-WebRequest -Uri http://localhost:9200).Content | ConvertFrom-Json | `
    Select-Object Cluster_Name, @{L = 'Version_Numer'; E = {($_.version).number}}, @{L = 'Build_Date'; E = {($_.version).build_date}}

#Step 2 - Download NSSM
Write-Host "Downloading, unpacking NSSM to $Destination" -ForegroundColor Yellow
Get-Resource -url ($NSSM.URL) -destination $Destination -name ($NSSM.Name)


#Step 3 - Install Logstash
Write-Host 
Write-Host "Downloading, unpacking Logstach to $Destination" -ForegroundColor Yellow
Get-Resource -url $Logstach.URL -destination $Destination -name $Logstach.Name

Write-Host 
Write-Host "Install Logstach service"
Write-Host
Write-Host "Parameters for NSSM"
Write-Host "Path: $Destination\$($Logstach.Name)\bin\Logstash.bat"
Write-Host "Startup directory: $Destination\$($Logstach.Name)\bin"
Write-Host "Arguments: -f $Destination\$($Logstach.Name)\bin\config.json"
Invoke-Expression -command “$Destination\nssm\win64\nssm install $($Logstach.Name) $Destination\$($Logstach.Name)\bin\Logstash.bat '-f $Destination\$($Logstach.Name)\bin\config.json'”
#Delete below comments when you will want check parameter for services
#Write-Host "Check parameters and close NSSM" -ForegroundColor Yellow
#Invoke-Expression -command “$Destination\nssm\win64\nssm edit $($Logstach.Name)"

Write-Host "Start service $($Logstach.Name)"
Write-Host "Change Startup type to Automatic"
Get-Service $($Logstach.Name) | Start-Service -PassThru
Get-Service $($Logstach.Name) | Set-Service -StartupType Automatic

# Step 4 - Install Kibana
Write-Host 
Write-Host "Downloading, unpacking Kibana to $Destination" -ForegroundColor Yellow
Get-Resource -url $Kibana.URL -destination $Destination -name $Kibana.Name

Write-Host 
Write-Host "Install Kibana service"
Write-Host
Write-Host "Parameters for NSSM"
Write-Host "Path: $Destination\$($Kibana.Name)\bin\kibana.bat"
Write-Host "Startup directory: $Destination\$($Kibana.Name)\bin"
Invoke-Expression -command “$Destination\nssm\win64\nssm install $($Kibana.Name) $Destination\$($Kibana.Name)\bin\Kibana.bat”
#Delete below comments when you will want check parameter for services
#Write-Host "Check parameters and close NSSM" -ForegroundColor Yellow
#Invoke-Expression -command “$Destination\nssm\win64\nssm edit $($Kibana.Name)"

Write-Host "Start service $($Kibana.Name)"
Write-Host "Change Startup type to Automatic"
Get-Service $($Kibana.Name) | Start-Service -PassThru 
Get-Service $($Kibana.Name) | Set-Service -StartupType Automatic

#Deleting all zip files
Write-Host "Deleting all zip files"
Get-ChildItem -Path $Destination -Filter *.zip | Remove-Item

#EFinish
Write-Host 
Write-Host "Congrats! Probably You've successfully installed the ELK Stack on your Windows server :)"
Write-Host "Kibana - http://localhost:5601"
Write-Host "Elasticsearch - http://localhost:9200"