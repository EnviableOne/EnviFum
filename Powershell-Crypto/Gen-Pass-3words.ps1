 Function Gen-pass {
  param(
   [parameter(HelpMessage="If set Result not copied to Clipboard")][switch]$NoClip,
   [parameter(HelpMessage="If set Gui Messaging is not seen")][switch]$NoGUI
  )
  $rno = new-object "System.Byte[]" 6
  $rnd = New-Object "System.Byte[]" 2
  $Wordlist = "Path\to\password\components\textfile.txt"
  $wordparts = Get-content $Wordlist
  $range = $wordparts.count
  Add-Type -AssemblyName System.Windows.Forms
  Do {
   $rnw = [System.Security.Cryptography.RandomNumberGenerator]::Create()
   $rnw.getbytes($rno)
   $wrd1 = (($rno[0]*$rno[1]) % $range)+1
   $wrd2 = (($rno[2]*$rno[3]) % $range)+1
   $wrd3 = (($rno[4]*$rno[5]) % $range)+1
   [string]$pwd1 = (Get-Culture).textinfo.totitlecase($wordparts[$wrd1]) 
   [string]$pwd2 = (Get-Culture).textinfo.totitlecase($wordparts[$wrd2]) 
   [string]$pwd3 = (Get-Culture).textinfo.totitlecase($wordparts[$wrd3]) 
   do {
    $rnn = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rnn.getbytes($rnd)
    $int1 = ($rnd[0] % 10)
    $int2 = ($rnd[1] % 10)
   } while (($int1 -eq $int2) -or ($int1 -eq ($int2 + 1)) -or ($int1 -eq ($int2-1)) -or ($int2 -eq 0))
   $nos = $int1.ToString() + $int2.ToString()
   $pwd = ($pwd1 + $pwd2 + $pwd3 + $nos)
   if (!$NoClip) { set-clipboard -Value $pwd}
   If (!$NoGUI){
    $pwdmsg = ($pwd1 , $pwd2 , $pwd3 , $nos)
    $cliptxt = if (!$Noclip){"has"} Else {"has not"}
    $Result = [System.Windows.forms.MessageBox]::Show("Your New Password is: $pwdmsg `n`n`r and $cliptxt been coppied to the clipboard, `n`n`r Generate Another?","Crypto PwdGen",5,64,256)
    IF($Result -eq 4){
     $rno.Clear()
     $rnd.Clear()
     $int1 = $null
     $int2 = $null
     $nos = $null
     $pwd1 = $null
     $pwd2 = $null
     $pwd3 = $null
     $pwd = $null
     $rnw = $null
     $rnn = $null
    }
   } 
 } while (($Result -ne 2) -and !$NoGUI)

 If ($NoGUI) {return $pwd}
}