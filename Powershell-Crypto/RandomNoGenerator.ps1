#Random number Generator
Function RNG {
 Param(
  [Parameter(Mandatory=$true,position=0,HelpMessage="must be a number between 1 and 18")][validateRange(0,18)][ValidateNotNullOrEmpty()][int64]$nodig,
  [Parameter(Mandatory=$true,position=1)][ValidateNotNullOrEmpty()][int64]$noof,
  [switch]$nopad
  )
 $i=0
 [int64]$maxcount = "9" * $nodig
 For ($i=0; $i -lt $noof; $i++){
  $rnd = Get-Random -Minimum 0 -Maximum $maxcount
  If (!$nopad){
   $rnd.ToString().PadLeft($nodig,"0")
  }
  Else {
   $rnd.ToString()
  }
 }
}

[int64]$noof = Read-Host "How many numbers do you Want to generate?"
do {
[int64]$nodig = Read-Host "how many digits?"
If ($nodig -gt 18 -or $nodig -lt 1){
	Write-Warning "$nodig is not valid, must be between 1 and 18"
	}
} while ($nodig -gt 18 -or $nodig -lt 1)

RNG -nodig $nodig -noof $noof