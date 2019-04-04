[GC]::Collect()
$In_File="D:\Cracking\hashcat\Wordlists\pwned-passwords-ntlm-ordered-by-count.txt";
$Out_File="D:\Cracking\hashcat\Wordlists\pwned-passwords-ntlm-NC.txt";
$j=0;
$line = "";
$output = "";
$OutputEncoding = [System.Text.UTF8Encoding]::($false);
$Clock = [System.Diagnostics.Stopwatch]::StartNew();
$sr = new-object System.IO.StreamReader($In_File);
$sw = new-object system.IO.StreamWriter($Out_file,$OutputEncoding);

$line=$sr.ReadLine();
while ($line -ne $null){
 $line = $line.Substring(0, $line.IndexOf(‘:’));
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
Write-Output "total lines Converted: $j","Time elapsed:" $Clock.elapsed;