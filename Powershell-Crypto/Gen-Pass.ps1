Function Gen-pass {
 param(

 )
 $Wordlist = "Path\to\password\components\textfile.txt"
 $rno = new-object "System.Byte[]" 5
 $wordparts = Get-content $wordlist
 $range = $wordparts.count
  
 do {
  $result = $null
  $rnd = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  $rnd.getbytes($rno)
  $wrdno = (($rno[0]*$rno[1]*$rno[2]) % $range)+1
  [string]$pwd = $wordparts[$wrdno]
  $int1 = ($rno[3] % 10)
  $int2 = ($rno[4] % 10)
  $pwd = (Get-Culture).textinfo.totitlecase($pwd) + $int1.ToString() + $int2.ToString()
  $Result = [System.Windows.MessageBox]::Show("Your New Password is $pwd `n`n`r to send to cliboard click Yes","Crypto PwdGen",3,64)
  if ($Result -eq 6){
   set-clipboard -Value $pwd
  }
  ElseIF($Result -eq 7){
   $rno.Clear()
   $int1 = $null
   $int2 = $null
   $pwd = $null
   $rnd = $null
  }
  Else {
   return
  }
 } while ($Result -ne 6) 
 return
 }