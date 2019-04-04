$Clock.Stop()
$sr.Close();
$sr.Dispose();
$sw.flush();
$sw.Close();
$sw.Dispose();
Write-Output "total Hashes Converted: $j","Time elapsed:" $Clock.elapsed;