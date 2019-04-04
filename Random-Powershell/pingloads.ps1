#$computers = @("wsus-pcs","wsus01-com","wsus-servers","EMIS-SPOKE-3","EMIS-SPOKE-4","EMIS-SPOKE-5","EMIS-SPOKE-6","EMIS-SPOKE-7","EMIS-SPOKE-8","EMIS-SPOKE-9")

$Results = New-Object System.Collections.ArrayList

foreach ($mc in $mcs){
 $item = New-Object System.Object
 $item | Add-Member -MemberType NoteProperty -Name "Computer" -Value $mc
 $item | Add-Member -MemberType NoteProperty -Name "Alive" -Value $(Test-Connection $mc -TimeToLive 1 -count 1 -Quiet)
 $results += $item
 }
 $results