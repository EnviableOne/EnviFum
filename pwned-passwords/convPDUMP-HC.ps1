[GC]::Collect()
$In_File="C:\audit\ReduxPartDeux\pwddumpRedux2.txt";
$Out_File="C:\audit\ReduxPartDeux\HC-pwddumpRedux2.txt";
$j=0;
$line = "";
$output = "";
$Clock = [System.Diagnostics.Stopwatch]::StartNew()
$sr = new-object System.IO.StreamReader($In_File);
$sw = new-object system.IO.StreamWriter($Out_file,$false,[System.Text.Encoding]::UTF8);

$line=$sr.ReadLine();
while ($line -ne $null){
 $split = $line.split(":",5)
 $sect = $split[0].split("\")
 $user = $sect[1],$sect[0] -join "@"
 $line = $user,$split[3] -join ":"
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