Function Get-PwnedStatus{
<#.SYNOPSIS
 This script checks an input password against a database of
 501 million passwords previously leaked in data breaches.

.DESCRIPTION
 The script collects a password as a secure string to prevent overlooking
 once converted to a SHA1 hash the password is then searched for using a
 binary search against sorted list of password hashes from breaches  
 listed on haveibeenpwned.com and made available by Troy Hunt. The hash 
 is created using Get-StringHash from John Gurgul and the binary search 
 was crafted by Chris Dent in Select-INString.

.NOTES
 File Name : passwordTest.ps1
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
 returns the number of time this password was found in breaches
 Output Variable : $pwned
 Output type : System.Int

.LINK
 About : http://www.enviable.uk/tools/powershell/passwordTest
 Hashing Function:  http://jongurgul.com/blog/get-stringhash-get-filehash/
 Binary Search: http://www.indented.co.uk/powershell-file-based-binary-search/
#>
#requires -version 4.0
 param(
 [parameter(Mandatory=$true,ValueFromPipeline=$true)][validateScript({$_.GetType() -eq [system.string] -or $_.GetType() -eq [system.security.securestring]})]$Password,
 [ValidateSet("1", "2")]$Version = 1,
 [Switch]$Secure,
 [Switch]$Standalone
 )
 #If secure password convert back to plain
 If ($Secure){
  [String]$ClearPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
  $Password.Dispose()
  }
 Else{
  [String]$ClearPass=$Password
  }
#Generate SHA1 Hash
 $TestHash = Get-HashOut $ClearPass -HashName SHA1 -Outformat Hex
 If ($Version = 1){
 $filename = "C:\pwned-passwords\pwned-passwords-1.0-srt.txt"
 }
 Else {
 $filename = "C:\pwned-passwords\pwned-passwords-2.0-srt-NC.txt"
 }
#check Hash against password file
 [GC]::Collect() 
 $Return = Select-INString -string $TestHash -filename $filename
#Display Result
 If ($Return){
  $pwned = $true
 }
 Else {
  $pwned = $false
 }
 If ($Standalone) {
  write-host ("Password Breached: $pwned")  -BackgroundColor Black -ForegroundColor Yellow
 }
 Else {
 return $pwned
 }
#Clear variables
 Remove-Variable Password, ClearPass, TestHash, return
}
function Select-INString {
  <# .SYNOPSIS
  #   Select a matching string from an alphabetically sorted file.
  # .DESCRIPTION
  #   Select-INString is a specialised binary (half interval) searcher designed to find matches in sorted ASCII encoded text files.
  # .PARAMETER FileName
  #   The name of the file to search.
  # .PARAMETER String
  #   The string to find. The string is treated as a regular expression and must match the beginning of the line.
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
 default {Return "Not Implemented"}
}
}