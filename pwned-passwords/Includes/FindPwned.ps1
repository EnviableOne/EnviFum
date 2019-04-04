
Import-module D:\Cracking\audit\Select-INString.psm1
$Clock = [System.Diagnostics.Stopwatch]::StartNew();
$hashes = Get-Content D:\Cracking\audit\NTHASH.csv
$testfile = "D:\Cracking\Hashcat\Wordlists\pwned-passwords-ntlm-ordered-by-hash-v4.txt"
$out_file = "D:\cracking\audit\pwned-hashes.txt"
$OutputEncoding = [system.text.UTF8Encoding]::($false)
$i=$j=0
$sw = new-object system.IO.StreamWriter($Out_file,$OutputEncoding);

foreach ($hash in $hashes) {
 $output = Select-INString -String $hash -Filename $testfile
 If ($output -ne $null) {
  $sw.WriteLine($output)
  $j++
 }
 $i++
}
$Clock.Stop()
$sw.flush();
$sw.Close();
$sw.Dispose();
cls
Write-Output "Hashes Checked: $i, total pwned found: $j","Time elapsed:" $Clock.elapsed;