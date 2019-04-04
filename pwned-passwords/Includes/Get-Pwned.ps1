Import-Module "$PSScriptRoot\includes\Select-INString.ps1"
Import-Module "$PSScriptRoot\includes\GetStringHash64.ps1"
Function Get-Pwned{
<#.SYNOPSIS
 This script checks an input password against a database of passwords 
 previously leaked in data breaches.

.DESCRIPTION
 The funtion takes a password either as a secure string or standard and 
 coverts this to a SHA1 hash, it then has two modes Online or Offline
 ..ONLINE MODE
  takes first five hex chars and checks if it has a local copy of the 
  hash file, it then queries from the pwnedpasswords api, for an update
  and downloads the file if it is newer, it then searches the file for
  the remaining Hex chars of the Hash, and if matched it, returns the
  number of times that password has been seen in breaches.
 ..OFFLINE MODE
  takes the full hash and check that against the offline version of the
  pwnedpasswords datatbase (a full 20+GB of text) and if matched
  returns the number of times that password has been seen in breaches.

.NOTES
 File Name : Get-Pwned.ps1
 Author : Peter J Marquis
 Requires : Powershell v4.0

.LICENCE
 Jan 2019 Enviable Network Support and Solutions LTD.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

.INPUTTYPE
 takes a string from the user
 Input Variable : $password
 Input Type : System.String or System.Security.SecureString

.RETURNVALUE
 returns the number of time this password was found in breaches loaded into pwned-passwords
 Output Variable : $pwned
 Output type : System.Int

.PARAMETERS
 Secure - indicates input is a secure string
 Standalone - indicates to generate output messages rather than pwned times
 online - indicates whether to use the local DB or not

.LINK
 About : https://www.enviable.uk/tools/powershell/Get-Pwned
 Binary Search: https://www.indented.co.uk/powershell-file-based-binary-search/
 HaveIBeenPwned: https://www.haveibeenpwned.com/
 Full password DB: https://www.haveibeenpwned.com/passwords/
#>
#requires -version 4.0
param(
 [Switch]$Secure,
 [Switch]$Standalone,
 [switch]$online,
 [parameter(Position=0,ValueFromPipeline=$true)][validateScript({$_.GetType() -eq [system.string] -or $_.GetType() -eq [system.security.securestring]})]$Password
 )
 #if no password supplied error or ask
 if($password -eq $null){ 
  if($standalone){
   $Password = read-Host "Input Password to test" -AsSecureString
  }
  Else {
   $ErrorObject = new-object System.MissingFieldException("No Value was supplied for the input Variable")
   
   Throw $ErrorObject
  }
 }

 #global Vars
 $RngPath = "$PSScriptRoot\ranges\"
 $Datafile = "$PSScriptRoot\pwned-passwords-sha1-ordered-by-hash-v4.txt"

 #If secure password convert back to plain
 If ($Secure -or $Password.GetType() -eq [system.security.securestring]) {
  [String]$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
  }
  #Generate SHA1 Hash
 $TestHash = Get-HashOut $Password -HashName SHA1 -Outformat Hex
 Remove-Variable password -Force
 #if online mode not set check DB
 If(!$online){
    $return = Select-INString $Testhash $DataFile
 }
 #otherwise check for update
 Else {
  #Generate lookup variables
  $Prefix = $TestHash.Substring(0,5)
  $RemHash = $TestHash.substring(5)
  $RngFile = "$Rngpath\$prefix.txt"
  $pwnedreq = "https://api.pwnedpasswords.com/range/$prefix"

  #check if range already exists download range
  if(![System.IO.File]::Exists($RngFile)){
   Invoke-RestMethod $pwnedreq -Method get -UseBasicParsing -proxy http://10.152.3.100:8080 -ProxyUseDefaultCredentials -OutFile $RngFile
  }
  Else {
   #get last-modified from range
   $lastmod = "{0:ddd}, {0:dd} {0:MMM} {0:yyyy} {0:hh}:{0:mm}:{0:ss}" -f  [system.IO.file]::GetLastWriteTime($RngFile)
   #add last-modified header
   $headers =@{}
   $headers.add("If-Modified-Since","$lastmod GMT")
   
   #check if online version is updated and download if it is
   try{Invoke-RestMethod $pwnedreq -Method get -UseBasicParsing -proxy http://10.152.3.100:8080 -ProxyUseDefaultCredentials -OutFile $RngFile -Headers $headers}
   #ifnot ignore not modified error
   catch{if ($_.Exception.Response.StatusCode.value__ -ne 304){
     Write-Error "StatusCode:" + $_.Exception.Response.StatusCode.value__ $ERRCde
     Write-Warning "StatusDescription:" + $_.Exception.Response.StatusDescription}
    }
   }
   #check file for match on the remainder
   $return=Select-INString $RemHash $RngFile
  }
  #set 0 matches
  if ($return -eq $null){
  
     $matches = 0
  }
  #otherise pull number from match
  Else {
  #get number after :
  $matches=$return.substring($return.lastindexof(":")+1)
  }
  #if running as script return no of occurances
  If (!$standalone) {
   return $matches
  }
  #otherwise create a messagebox
  Else {
   if ($matches -ne 0){
    $msg = "This password Occured $matches time(s) in Breaches"
    $iconstr = 16
   }
   Else {
    $msg = "this password has not appeared in any breaches as of yet, However this does not mean it is secure, it may have been compromised, and not publicly disclosed or added to the database yet"
    $iconstr = 48
   }
   $msgbox = [system.windows.messagebox]::show($msg,"Pwned Passwords",0,$iconstr)
  }
}