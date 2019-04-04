Function Select-INString {
  <# .SYNOPSIS
  #   Select a matching string from an alphabetically sorted file.
  # .DESCRIPTION
  #   Select-INString is a specialised binary (half interval) searcher designed to find matches in sorted ASCII encoded text files.
  # .PARAMETER FileName
  #   The name of the file to search.
  # .PARAMETER String
  #   The string to find. The string is treated as a regular expression and must match the beginning of the line. 
  #   however it is now escaped to allow it to contain regex control carachters as part of the string.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   Select-INString 
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     11/08/2014 - Chris Dent - First release.
  #     07/07/2018 - Peter Marquis - Added regex escape sequence, converted to [void] instead of | Out-Null for speed
  #>
  param(
    [Parameter(Mandatory = $true)]
    [String]$String,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ } )]
    [String]$FileName
  )
  
  $FileName = (Get-Item $FileName).FullName
  $FileStream = New-Object IO.FileStream($FileName, [IO.FileMode]::Open)
  $BinaryReader = New-Object IO.BinaryReader($FileStream)
  
  $Length = $BinaryReader.BaseStream.Length
  $Position = $Length / 2
 
  [Int64]$HalfInterval = $Length / 2
  $Position = $Length - $HalfInterval
  $string=[regex]::Escape($string)

  while ($Position -gt 1 -and $Position -lt $Length -and $Position -ne $LastPosition) {
    $LastPosition = $Position
    $HalfInterval = $HalfInterval / 2
 
    [void]$BinaryReader.BaseStream.Seek($Position, [IO.SeekOrigin]::Begin) 
    
    # Track back to the start of the line
    while ($true) {
      $Character = $BinaryReader.ReadByte()
      if ($BinaryReader.BaseStream.Position -eq 1) {
        [void]$BinaryReader.BaseStream.Seek(-1, [IO.SeekOrigin]::Current)
        break
      } elseif ($Character -eq [Byte][Char]"`n") {
        break
      } else {
        [void]$BinaryReader.BaseStream.Seek(-2, [IO.SeekOrigin]::Current)
      }
    }
    
    # Read the line
    $Characters = @()
    if ($BinaryReader.BaseStream.Position -lt $BinaryReader.BaseStream.Length) {
      do {
        $Characters += [Char][Int]$BinaryReader.ReadByte()
      } until ($Characters[-1] -eq [Char]"`n" -or $BinaryReader.BaseStream.Position -eq $BinaryReader.BaseStream.Length)
      $Line = (New-Object String (,[Char[]]$Characters)).Trim()
    } else {
      # End of file
      $FileStream.Close()
      return $null
    }
    $line=[regex]::Escape($line)
    if ($Line -match "^$String") {
      # Close the file stream and return the match immediately
      $FileStream.Close()
      return $Line
    } elseif ($Line -lt $String) {
      $Position = $Position + $HalfInterval
    } elseif ($Line -gt $String) {
      $Position = $Position - $HalfInterval
    }
  }
  
  # Close the file stream if no matches are found.
  $FileStream.Close()
}
Function Get-HashOut {
<# .SYNOPSIS
  #   Generate a hash using the built-in library and output it as either a hexidecimal or Base-64 string.
  # .DESCRIPTION
  #   Get-HashOut is a simple function to implement the class System.Security.Cryptography.HashAlgorithm and generate 
  #   an hash using MD5, RIPEMD160, SHA1, SHA-256, SHA-384, SHA-512, all are included for speed, SHA-256 and above 
  #   use the SHA2 algortithm, SHA-3 has not been implemented in the library yet.
  # .PARAMETER String (Required)
  #   The input string to Hash.
  # .PARAMETER Hashname
  #   The Hash Function to use
  #   allowed values are MD5, RIPEMD160, SHA1, SHA-256, SHA-384, SHA-512
  #   Default value SHA-1
  # .PARAMETER Outformat
  #   The encoding used to output the Hash value as a string, 
  #   allowed values are Hex (for hexidecimal) and B64 (for Base64)
  #   Default value Hex
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   Select-INString 
  # .NOTES
  #   Author: Peter Marquis
  #   Notes: Insired by Many, but highly modified by me for speed and flexibility.
  #
  #>
 Param(
  [Parameter(Mandatory=$true)] [String] $String, 
  [ValidateSet("MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")] [String] $HashName = "SHA1",
  [ValidateSet("Hex","B64")][String] $Outformat = "Hex"
 )
 $enc = [system.Text.Encoding]::UTF8
 $data1 = $enc.GetBytes($String) 

 # Create a New Crypto Provider 
 $Hasher = [System.Security.Cryptography.HashAlgorithm]::Create($HashName)

 # Now hash and display results 
 $result1 = $Hasher.ComputeHash($data1)
 $Base64Hash=[System.Convert]::ToBase64String($result1)
 $HexHash=[System.BitConverter]::ToString($result1).Replace("-","")

 Switch ($Outformat){
 Hex {Return $HexHash}
 B64 {Return $Base64Hash}
 default {Return "Not Implemented - Returning Hex `r`n$HexHash"}
}
}
Function Get-Pwned{
<#.SYNOPSIS
 This script checks an input password against a database of passwords 
 previously leaked in data breaches.

.DESCRIPTION
 The funtion takes a password either as a secure string or standard and 
 coverts this to a SHA1 hash, it then takes first five hex chars of the 
 hash and queries from the database on pwnedpasswords.com, made available 
 by Troy Hunt, to see if its local copy is up to date, and if not, gets a
 list of hashes with the first five chars, the remaining Hex chars of the 
 password is then searched against this file to find a match, and if 
 matched it returns the number of times that result has been seen.
 The hash is created using Get-HashOut by me and the binary search was crafted 
 by Chris Dent in Select-INString.

.NOTES
 File Name : v2kannon.ps1
 Author : Peter J Marquis
 Requires : Powershell v4.0

.LICENCE
 Copyright 2017 Enviable Network Support and Solutions LTD.

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
 filter - indicates function is used by a password filter and returns boolean if safe

.LINK
 About : http://www.enviable.uk/tools/powershell/Get-Pwned
 Binary Search: http://www.indented.co.uk/powershell-file-based-binary-search/
#>
#requires -version 4.0
param(
 [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)][validateScript({$_.GetType() -eq [system.string] -or $_.GetType() -eq [system.security.securestring]})]$Password,
 [Switch]$Secure,
 [Switch]$Standalone
 )
 #global Vars
 $RngPath = "C:\pwned-passwords\ranges\"
 #If secure password convert back to plain
 If ($Secure -or $Password.GetType() -eq [system.security.securestring]) {
  [String]$ClearPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
  $Password.Dispose()
  }
 Else{
  [String]$ClearPass=$Password
  $password = ""
  }
 #Generate SHA1 Hash
 $TestHash = Get-HashOut $ClearPass -HashName SHA1 -Outformat Hex
 $ClearPass = $null
 Remove-Variable ClearPass
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
  try{Invoke-RestMethod $pwnedreq -Method get -UseBasicParsing -proxy http://10.152.3.100:8080 -ProxyUseDefaultCredentials -OutFile "C:\pwned-passwords\ranges\$prefix.txt" -Headers $headers}
  #ifnot ignore not modified error
  catch{if ($_.Exception.Response.StatusCode.value__ -ne 304){Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ $ERRCde
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription}
  }
  }
  #check file for match on the remainder
  $return=Select-INString $RemHash $RngFile
  
  if ($return -eq $null){
  #set no matches
     $matches = 0
  }
  Else {
  #get number after :
  $matches=$return.substring($return.lastindexof(":")+1)
  }
  #return no of occurances
  If (!$standalone) {
   return $matches
  }
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