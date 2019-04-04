#------------------------------------------------------------------------------
#
# PowerShell console profile
# ed wilson, msft
#
# NOTES: contains five types of things: aliases, functions, psdrives,
# variables and commands.
# version 1.2
# 7/27/2015
# HSG 7-28-2015
#------------------------------------------------------------------------------
#Aliases
Set-Alias -Name ep -Value edit-profile | out-null
Set-Alias -Name tch -Value Test-ConsoleHost | out-null
Set-Alias -Name gfl -Value Get-ForwardLink | out-null
Set-Alias -Name gwp -Value Get-WebPage | out-null
Set-Alias -Name rifc -Value Replace-InvalidFileCharacters | out-null
Set-Alias -Name gev -Value Get-EnumValues | out-null

#Variables
New-Variable -Name doc -Value "$home\documents" `
   -Description "My documents library. Profile created" `
   -Option ReadOnly -Scope "Global"

if(!(Test-Path variable:backupHome))
{
 new-variable -name backupHome -value "$doc\WindowsPowerShell\profileBackup" `
     -Description "Folder for profile backups. Profile created" `
     -Option ReadOnly -Scope "Global"
}

#PS_Drives
New-PSDrive -Name Mod -Root ($env:PSModulePath -split ';')[0] `
 -PSProvider FileSystem | out-null

#Functions
Function Edit-Profile
{ ISE $profile }

Function Test-ConsoleHost
{
 if(($host.Name -match 'consolehost')) {$true}
 Else {$false}  
}

Function Replace-InvalidFileCharacters
{
 Param ($stringIn,
        $replacementChar)
 # Replace-InvalidFileCharacters "my?string"
 # Replace-InvalidFileCharacters (get-date).tostring()
 $stringIN -replace "[$( [System.IO.Path]::GetInvalidFileNameChars() )]", $replacementChar
}

Function Get-TranscriptName
{
 $date = Get-Date -format s
  "{0}.{1}.{2}.txt" -f "PowerShell_Transcript", $env:COMPUTERNAME,
  (rifc -stringIn $date.ToString() -replacementChar "-") }

Function Get-WebPage
{
 Param($url)
 # Get-WebPage -url (Get-CmdletFwLink get-process)
 (New-Object -ComObject shell.application).open($url)
}

Function Get-ForwardLink
{
 Param($cmdletName)
 # Get-WebPage -url (Get-CmdletFwLink get-process)
 (Get-Command $cmdletName).helpuri
}

Function BackUp-Profile
{
 Param([string]$destination = $backupHome)
  if(!(test-path $destination))
   {New-Item -Path $destination -ItemType directory -force | out-null}
  $date = Get-Date -Format s
  $backupName = "{0}.{1}.{2}.{3}" -f $env:COMPUTERNAME, $env:USERNAME,
   (rifc -stringIn $date.ToString() -replacementChar "-"),
   (Split-Path -Path $PROFILE -Leaf)
 copy-item -path $profile -destination "$destination\$backupName" -force
}

Function get-enumValues
{
 # get-enumValues -enum "System.Diagnostics.Eventing.Reader.StandardEventLevel"
Param([string]$enum)
$enumValues = @{}
[enum]::getvalues([type]$enum) |
ForEach-Object {
$enumValues.add($_, $_.value__)
}
$enumValues
}

Function Test-IsAdmin
{
 <#
    .Synopsis
        Tests if the user is an administrator
    .Description
        Returns true if a user is an administrator, false if the user is not an administrator       
    .Example
        Test-IsAdmin
    #>
 $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
 $principal = New-Object Security.Principal.WindowsPrincipal $identity
 $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
#Commands
Set-Location c:\
If(tch) {Start-Transcript -Path (Join-Path -Path `
 $doc -ChildPath $(Get-TranscriptName))}
BackUp-Profile
if(Test-IsAdmin)
   { $host.UI.RawUI.WindowTitle = "Elevated PowerShell" }
else { $host.UI.RawUI.WindowTitle = "Mr $($env:USERNAME) Non-elevated Posh" }
