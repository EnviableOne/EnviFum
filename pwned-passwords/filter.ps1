param(
 [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)][String]$User,
 [parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]$Password
 )

write-verbose "Loading modules..."
import-module ActiveDirectory
Import-module "$PSScriptroot\Includes\Get-Pwned.psm1"
Import-module "$psscriptroot\Includes\Get-parts.psm1"
$return=$null

write-verbose "testing username..."
if (($user.tolower() -eq $Password.tolower()) -or ($Password.Tolower().contains($User.tolower()))) {
 $return = "user,N/A";
}

If ($return -eq $null){
 $userchars = Get-Parts $user
 $i = 0
 while (($i -lt $userchars.count) -and ($return=$null)){
  If($Password.tolower().contains($userchars[$i])){
   $return = "partuser,$($userchars[$i])"
  }
  $i++
 }
}

IF($return -eq $null){
 write-verbose "testing full name ..."
 $dispname = Get-ADUser -Identity $user -Properties displayName | foreach{  $_.givenname + $_.surname}
 $namechars = Get-parts $dispname
 $j = 0
 while (($j -lt $namechars.count) -and ($return -eq $null)){
  If($Password.tolower().contains($namechars[$i])){
   $return = "partname,$namechars[$i]"
  }
  $j++
 }
}
$k=0
if($return -eq $null){
 Write-verbose "Testing Blacklist ..."
 $content = (Get-content "$PSScriptRoot\opfcont.txt") 
 Foreach ($item in $content) {
  If ($Password.tolower().contains($item)) { 
   $return = "contains,$item"
  }
  $k++
 }
}

If($return -eq $null) {
 Write-verbose "testing pwned ..."
 $pwned = Get-pwned $Password
 If($pwned -ne 0){
  $return = "pwned,$pwned"
 }
}
if($return -eq $null){
 $return = 0
}
 add-content -literalPath "$PSScriptRoot\PwdChangelog.txt" -value "$(Get-Date),$i,$j,$k,$($env:COMPUTERNAME),$User,$return"

 return $return