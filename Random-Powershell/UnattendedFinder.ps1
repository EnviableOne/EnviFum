#start clock
$Clock = [System.Diagnostics.Stopwatch]::StartNew();
#load computers from AD
$computers = Get-ADComputer -ldapfilter "(sAMAccountName=*$)"  | Select -Exp Name
#load paths and files to search
$filenames = Get-Content "C:\filenames.txt"
$filepaths = Get-Content "C:\filepaths.txt"
#initialise variables
[int]$i,[int]$j,[int]$k,[int]$l=0,0,0,0
$totComp = $computers.count
$xmllocat = "" | select "computer", "filename", "Location"

foreach($computer in $computers) {
 $i++
 $xmllocat.computer = $computer
 $xmllocat.Filename = "CNA"
 $xmllocat.Location = "CNA"
 #if host is up
 if (Test-Connection "$computer.stnhst.xsthealth.nhs.uk" -BufferSize 32 -Count 1 -Quiet){
  $xmllocat.Location = "FNF"
  $xmllocat.filename = "FNF"
  $j++
  foreach($filepath in $filepaths){
   $xmllocat.Location = $filepath
   foreach($filename in $filenames){
    #if file exist
    if (Test-Path -literalPath "\\$computer\c$\$filepath\$filename"){
     $xmllocat.filename = $filename
     $k++
     export-csv -inputobject $xmllocat -literalpath "C:\UnattendedFound.csv" -append -encoding utf8
     }
    }
   }
  }
  $l++
  #output Status
  if ($l -eq 25){
   $l=0
   $prog = ($i/$totcomp)
   $progress =[system.string]::format("{0:#00.00}%",$prog*100)
   $alive = [system.string]::format("{0:#00.00}%",($j/$i)*100)
   $elapsed = $clock.elapsedmilliseconds/1000
   $estcomp = (Get-date).addseconds($elapsed*(1-$prog)/$prog)
   if ($estcomp.Date -eq (Get-date).date) {$estcomp = $estcomp.ToLongTimeString()}
   Write-host "$progress of machines checked, $alive machines alive, $k files found, est comp $estcomp"
  }
}
$Clock.Stop();
$et = $Clock.Elapsed
$elapsed = [system.string]::format("{0:00}h:{1:00}m:{2:00}.{3:00}s",$et.Hours,$et.minutes,$et.Seconds,$et.Milliseconds/10)
write-host "Total: $i machines checked of $totcomp, $j machines alive, $k files found, $elapsed"