function global:Get-PrimaryDomainSID ()
{
  # Note: this script obtains SID of the primary AD domain for the local computer. It works both
  #       if the local computer is a domain member (DomainRole = 1 or DomainRole = 3)
  #       or if the local computer is a domain controller (DomainRole = 4 or DomainRole = 4).
  #       The code works even under local user account and does not require calling user
  #       to be domain account.

  [string] $domainSID = $null

  [int] $domainRole = gwmi Win32_ComputerSystem | Select -Expand DomainRole
  [bool] $isDomainMember = ($domainRole -ne 0) -and ($domainRole -ne 2)

  if ($isDomainMember) {

    [string] $domain = gwmi Win32_ComputerSystem | Select -Expand Domain
    [string] $krbtgtSID = (New-Object Security.Principal.NTAccount $domain\krbtgt).Translate([Security.Principal.SecurityIdentifier]).Value
    $domainSID = $krbtgtSID.SubString(0, $krbtgtSID.LastIndexOf('-'))
  }

  return $domainSID
}

Function Get-WinLoginLog{
 Param (
  [parameter(Mandatory=$true)][string]$Computer = (Read-Host Remote computer name),
  [DateTime]$start,
  [DateTime]$end,
  [int]$Days = 7,
  [string]$User
 )
 cls
 if (!$start) {$start=(Get-date).AddDays(-$Days)}
 if (!$end) {$end=(Get-date)}
 
 Write-host "Checking Host alive ..." -NoNewline
 If (!(Test-Connection $computer -Quiet -TTL 10 -Count 2)) {
  Write-host "Dead"
  Write-Error "$computer does not respond"
  Write-Warning "Check $computer is powered on and connected to the network"
  return;
  }
 Write-Host "done" -ForegroundColor Green
 
 $Result = @()
 $HashLookup=@{}
 $i=0
 if (!$user){
  Write-Host "Gathering Remote Users..." -NoNewline -ForegroundColor DarkYellow
  $users = Get-WMIObject -ComputerName $computer -Query "Select Caption,SID from Win32_UserAccount where domain='$computer'" | select SID,Caption
  while ($i -lt $users.count) {
   $Hashlookup.add($users[$i].SID,$Users[$i].Caption)
   $i++
   }
  Write-host "done" -ForegroundColor Gray
 } 
 
 Write-Host "Gathering Event Logs, this can take a while..."
 Write-Host "Gathering System Log ..." -NoNewline -ForegroundColor Cyan
 $SysLogs = Get-EventLog System -After $start -before $end -ComputerName $Computer
 Write-Host "done" -ForegroundColor Gray
 Write-Host "Gathering Security Log ..." -NoNewline -ForegroundColor Cyan
 $SecLogs = Get-EventLog Security -After $start -Before $end -ComputerName $Computer
 Write-Host "done" -ForegroundColor Gray
 IF (!$SysLogs -and !$Seclogs) {
  Write-Error "Problem with $Computer."
  Write-Warning "If you see a 'Network Path not found' error, try starting the Remote Registry service on that computer."
  Write-Warning "Or there are no logon/logoff events (XP requires auditing be turned on)"
  break
 }
 If ($SysLogs) { 
 Write-Host "Processing System Log..." -ForegroundColor Cyan
 Write-Host "$($SysLogs.count) Entries to Process..." -NoNewline -ForegroundColor DarkCyan
 :doWah ForEach ($Log in $SysLogs){ 
  Switch ($Log.InstanceId){
    7001{$ET = "Logon";break}
    7002{$ET = "Logoff";break}
    1{$ET = "Restart"; break}
    6006{$ET = "Restart"; break}
    6005{$ET = "Restart"; break}
    default{continue doWah}
   }
   $Luser = invoke-command{IF ($ET -eq "Restart") {"All"} else{ [System.Security.Principal.SecurityIdentifier]::New($Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}}
   $Result += New-Object PSObject -Property @{
    Time = $Log.TimeWritten;
    Source_Log = "System";
    Event_Type = $ET;
    User = $luser;
    Repstr=$Log.ReplacementStrings[1];
   }
  }
 }
 Write-Host "done" -foregroundcolor Gray
 If ($SecLogs) { 
  Write-Host "Processing Security Log..." -ForegroundColor Cyan
  Write-Host "$($SecLogs.count) Entries to Process..." -NoNewline -ForegroundColor DarkCyan
  :diddy ForEach ($Log in $SecLogs){ 
   Switch ($Log.InstanceId){
    4624{$ET = "Logon"; Break}
    4647{$ET = "Logoff"; Break}
    4778{$ET = "RDP Connect"; Break}
    4779{$ET = "RDP Disconnect"; Break}
    4800{$ET = "Session Locked"; Break}
    4801{$ET = "Session UnLocked"; Break}
    default{continue diddy}
   }
   If ($log.ReplacementStrings[0].startswith($(Get-PrimaryDomainSID))){
    $luser=[System.Security.Principal.SecurityIdentifier]::new($Log.ReplacementStrings[0]).Translate([System.Security.Principal.NTAccount])
   }
   Else {$luser = $Hashlookup[$log.ReplacementStrings[0]] 
   }
   $Result += New-Object PSObject -Property @{
    Time = $Log.TimeWritten
    Source_Log = "Security";
    Event_Type = $ET;
    User = $luser
    repstr = $Log.ReplacementStrings[0]
   }
  }
 }
 $longTXT = 'yyyy-MM-dd_hh-mm'
 $ShrtTXT = 'yyyyMMddhhmm'
 write-host "done" -foregroundcolor Gray
 IF ($start -eq $null){
    IF($end -eq $null){
        $ref = (Get-Date).ToString($longTXT)
    }
    Else{
        $ref = "Until_$($end.ToString($longTXT))"
    }
}
Else {
    IF($End -eq $null){
        $ref = "Since_$($start.ToString($longTXT))"
    }
    Else {
        $ref = "From-$($start.ToString($shrtTXT))-To-$($end.ToString($ShrtTXT))"
    }
}
 $Result | Select Time,Source_Log,Event_Type,User,repstr | Sort Time -Descending | Export-Csv -Path C:\wsus-reports\Logs-$computer-$ref.csv -NoTypeInformation 
 Remove-Variable * -ErrorAction SilentlyContinue
 Write-Host "logs Processed, Output at: C:\wsus-reports\Logs-$computer-$ref.csv"
 }
 ## Get-EventLog -LogName system -after (Get-date).AddDays(-90) -ComputerName z | where{(($_.EventId -eq 6005) -or ($_.EventId -eq 6006) -or (($_.InstanceId -eq 1) -and ($_.Message -like '*low power*')))} | ft