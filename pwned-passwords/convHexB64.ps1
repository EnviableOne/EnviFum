Function Convert-HexToBase64
{
 param(
  [parameter(Mandatory=$true)][string]$HexString
  )
 $SrcByte = [byte[]]::new(20);
 for ($i=0;$i -lt $HexString.Length; $i+=2){
  $SrcByte[$i/2] = [convert]::ToByte($HexString.Substring($i,2),16);
 }
 $OutStr = [convert]::ToBase64String($SrcByte); 
 $OutStr;
}
[GC]::Collect()
$In_File=".\pwned-passwords-srt.txt";
$Out_File=".\pwned-passwords-srt-b64.txt";
$j=0;
$line = "";
$output = "";
$Clock = [System.Diagnostics.Stopwatch]::StartNew()
$sr = new-object System.IO.StreamReader($In_File);
$sw = new-object system.IO.StreamWriter($Out_file,$false,[System.Text.Encoding]::UTF8);

$line=$sr.ReadLine();
while ($line -ne $null){
 $line = Convert-HexToBase64 $line;
 $sw.WriteLine($line);
 $j++;
 $line=$sr.ReadLine();
}
$Clock.Stop()
$sr.Close();
$sr.Dispose();
$sw.flush();
$sw.Close();
$sw.Dispose();
Write-Output "total Hashes Converted: $j","Time elapsed:" $Clock.elapsed;