$computers = Get-ADComputer -ldapfilter "(sAMAccountName=STFT*$)"  | Select -Exp Name

$i=0
$j=0
$k=0
$filenames = Get-Content "C:\filenames.txt"
$xmllocat = "" | select "computer", "filename"

foreach ($computer in $computers) {
$i++
$xmllocat.computer = $computer
$xmllocat.Filename = "Computer Not Alive"
 if (Test-Connection "$computer.stnhst.xsthealth.nhs.uk" -BufferSize 32 -Count 1 -Quiet){
  $xmllocat.filename = "Files Not Found"
  $j++
  foreach ($filename in $filenames) {
   if(Test-Path -literalPath "\\$computer\c$\windows\system32\sysprep\$filename"){
     $xmllocat.filename = $filename
     export-csv -inputobject $xmllocat -literalpath "C:\FoundFiles.csv" -append -encoding utf8
    $k++
    write-host "$j machines alive, $k files found"
   }
  }
 }
 export-csv -inputobject $xmllocat -literalpath "C:\FoundFiles.csv" -append -encoding utf8
}
write-host "Total: $i machines checked of $($computers.count), $j machines alive, $k files found"