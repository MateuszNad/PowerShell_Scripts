<#
.Synopsis
   Format-ToSplatting - Format parameters to splatting
.DESCRIPTION
   Function helps formatting parameters to splatting
   Splatting is a method of passing a collection of parameter values to a command as unit. PowerShell associates each 
   value in the collection with a command parameter. Splatted parameter values are stored in named splatting variables, 
   which look like standard variables, but begin with an At symbol (@) instead of a dollar sign ($). The At symbol tells 
   PowerShell that you are passing a collection of values, instead of a single value.
   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-6
.EXAMPLE
   PS C:\> Format-ToSplatting -Name 'Get-Help'
   
   $parameterGetHelp = @{
     Category                       = "Displays help only for items in the specified category and their aliases."
     Component                      = "Displays commands with the specified component value, such as 'Exchange."
     Detailed                       = "Adds parameter descriptions and examples to the basic help display."
     Examples                       = "Displays only the name, synopsis, and examples."
     Full                           = "Displays the entire help topic for a cmdlet, including parameter descriptions and attributes, examples, input and output object types, and additional notes."
     Functionality                  = "Displays help for items with the specified functionality."
     Name                           = "Gets help about the specified command or concept."
     Online                         = "Displays the online version of a help topic in the default Internet browser."
     Parameter                      = "Displays only the detailed descriptions of the specified parameters."
     Path                           = "Gets help that explains how the cmdlet works in the specified provider path."
     Role                           = "Displays help customized for the specified user role."
     ShowWindow                     = "Displays the help topic in a window for easier reading."
   } 
.EXAMPLE
   PS C:\> Get-Help *DbaDatabase | Format-ToSplatting 
   $parameterAttachDbaDatabase = @{
     SqlInstance                    = "The SQL Server instance."
     SqlCredential                  = "Login to the target instance using alternative credentials."
     Database                       = "The database(s) to attach."
     FileStructure                  = "A StringCollection object value that contains a list database files."
     DatabaseOwner                  = "Sets the database owner for the database."
     AttachOption                   = "An AttachOptions object value that contains the attachment options."
     EnableException                = "By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message."
     WhatIf                         = "If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run."
     Confirm                        = "If this switch is enabled, you will be prompted for confirmation before executing any operations that change state."
   } 
$parameterDetachDbaDatabase = @{
     SqlInstance                    = "The SQL Server instance."
     SqlCredential                  = "Login to the target instance using alternative credentials."
     Database                       = "The database(s) to detach."
     InputObject                    = "A collection of databases (such as returned by Get-DbaDatabase), to be detached."
     UpdateStatistics               = "If this switch is enabled, statistics for the database will be updated prior to detaching it."
     (...)
.EXAMPLE
   PS C:\> 'Get-Command', 'Get-Help' | Format-ToSplatting 
  $parameterGetCommand = @{
     All                            = "Gets all commands, including commands of the same type that have the same name."
     ArgumentList                   = "Gets information about a cmdlet or function when it is used with the specified  parameters ('arguments')."
     CommandType                    = "Gets only the specified types of commands."
     Module                         = "Gets the commands that came from the specified modules or snap-ins."
     Name                           = "Gets only commands with the specified name."
     Noun                           = "Gets commands (cmdlets, functions, workflows, and aliases) that have names that include the specified noun."
     Syntax                         = "Gets only specified data about the command."
     TotalCount                     = "Gets the specified number of commands."
     Verb                           = "Gets commands (cmdlets, functions, workflows, and aliases) that have names that include the specified verb."
     ListImported                   = "Gets only commands in the current session."
     ParameterName                  = "Gets commands in the session that have the specified parameters."
     ParameterType                  = "Gets commands in the session that have parameters of the specified type."
 } 
$parameterGetHelp = @{
     Category                       = "Displays help only for items in the specified category and their aliases."
     Component                      = "Displays commands with the specified component value, such as 'Exchange."
     Detailed                       = "Adds parameter descriptions and examples to the basic help display."
     Examples                       = "Displays only the name, synopsis, and examples."
     Full                           = "Displays the entire help topic for a cmdlet, including parameter descriptions and attributes, examples, input and output object types, and additional notes."
     Functionality                  = "Displays help for items with the specified functionality."
     Name                           = "Gets help about the specified command or concept."
     Online                         = "Displays the online version of a help topic in the default Internet browser."
     Parameter                      = "Displays only the detailed descriptions of the specified parameters."
     Path                           = "Gets help that explains how the cmdlet works in the specified provider path."
     Role                           = "Displays help customized for the specified user role."
     ShowWindow                     = "Displays the help topic in a window for easier reading."
} 
.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
 
   Date: 
   Version: 1.0.0.0 
   Keywords: 
   Notes: 
   Changelog:
#> 
function Format-ToSplatting {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name
    )
    process {
        foreach($Function in $Name) {
            # Name parameter
            $VariableName = "parameter$($Function.Replace('-',''))"
            # Get Parameter
            $Parameters = Get-Help -Name $Function -Parameter * | Select-Object Name, Description
       
            # 
            "$([char]36)$VariableName = @{"
            ForEach($Parameter in $Parameters) 
            {
                $ParameterName = ($Parameter.Name).PadRight(30)
                # Deleting all new lines
                $FlatDescription = "$($Parameter.Description.Text -replace "`n|`r|`t")".Trim(',')
                # Getting description to the first dot
                $DescriptionToDot = $FlatDescription.Substring(0,($FlatDescription.IndexOf('.')+1))

                # Checking lenght
                If($DescriptionToDot.Length -gt 200) {
                    $Description = ($FlatDescription.Substring(0,160)).TrimStart().Replace('"',"'")
                }
                else {
                    $Description = ($DescriptionToDot).TrimStart().Replace('"',"'")
                }

                "     $ParameterName = ""$Description"""
            }
            "} `n"
        }
    }
}