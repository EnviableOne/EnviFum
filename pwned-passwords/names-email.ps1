[GC]::Collect()
$In_File="C:\msrc\mail-list.txt";
$Out_File="C:\msrc\mail-Out.txt";
$j=0;
$m=0;
$n=0;
$multi=0;
$line = "";
$output = "";
$Clock = [System.Diagnostics.Stopwatch]::StartNew()
$sr = new-object System.IO.StreamReader($In_File);
$sw = new-object system.IO.StreamWriter($Out_file,$false,[System.Text.Encoding]::UTF8);

$line=$sr.ReadLine();
while ($line -ne $null){
 $dname = $line.replace(","," ");
 $vals= $line.split(",")
 $Adobj=Get-AdObject -filter ("displayName -eq '$dname'") -Properties sAMAccountName,mail,givenName,sn
 if ($Adobj -eq $null) {
    $dname = ($Vals[1] + " " + $Vals[0])
    $Adobj=Get-AdObject -filter ("displayName -eq '$dname'") -Properties sAMAccountName,mail,givenName,sn
    $m++
}
 if ($Adobj -eq $null) {
    $n++
}
Elseif($Adobj.count -ne 1) {
    $multi++
}
Else {
    $line = ($Adobj.mail + "," + $Adobj.sAMAccountName + "," + $Adobj.sn + " " + $Adobj.givenName);
    $sw.WriteLine($line);
}
 
 
 $j++;
 $line=$sr.ReadLine();
}
$Clock.Stop()
$t=$j-$n
$f=$j-$m
$s=$m-$n
$sr.Close();
$sr.Dispose();
$sw.flush();
$sw.Close();
$sw.Dispose();
cls;
Write-output ("Results:","========","Total Lines Checked: $j" , "Found Users: $t" , "As Written: $f ", "Reversed: $s" ,"Not Matched: $n" , "Multiple Users: $multi `n`r" , "Time elapsed: $Clock.ElapsedMilliseconds");