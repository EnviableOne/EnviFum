Function Set-TeamsOptimizeLocal {
 Param (
  [switch]$online = $false,
  [switch]$remove = $false,
  [switch]$persistant = $false
 )
 $ifs = get-wmiobject win32_networkadapter -filter "netconnectionstatus=2 and PhysicalAdapter=$true" | where {$_.name -cnotlike "*vpn*"} | select netconnectionid, name, InterfaceIndex
 if ($ifs.count -ge 2) {
  #multiple connected networks

 }
 $intIndex = $ifs.InterfaceIndex # index of the interface connected to the internet
 [string]$gateway = (get-wmiobject Win32_NetworkAdapterConfiguration -filter "InterfaceIndex=$IntIndex" | select DefaultIPGateway).defaultIPGateway # default gateway of that interface
 if (!$online){
  $destPrefix = "52.120.0.0/14", "52.112.0.0/14", "13.107.64.0/18" # Teams Media endpoints
 }
 Else {
  # Query the web service for IPs in the Optimize category
  $uri = "https://endpoints.office.com/endpoints/worldwide?clientrequestid=$(([GUID]::NewGuid()).Guid)"
  $ep = Invoke-RestMethod -Uri $uri
  # Output only IPv4 Optimize IPs to $optimizeIps
  $destPrefix = $ep | where {$_.category -eq "Optimize"} | Select-Object -ExpandProperty ips | Where-Object { $_ -like '*.*' }
 }

 if(!$remove){
  # Add routes to the route table
  if (!$persistant){
   foreach ($prefix in $destPrefix) {New-NetRoute -DestinationPrefix $prefix -InterfaceIndex $intIndex -NextHop $gateway -PolicyStore ActiveStore}
  }
  Else {
   foreach ($prefix in $destPrefix) {New-NetRoute -DestinationPrefix $prefix -InterfaceIndex $intIndex -NextHop $gateway}
  }
 }
 Else{
  #remove routes from table
  foreach ($prefix in $destPrefix) {Remove-NetRoute -DestinationPrefix $prefix -InterfaceIndex $intIndex -NextHop $gateway -Confirm:$false}
 }
}

If (
 (Get-NetRoute -DestinationPrefix 0.0.0.0/0).nexthop -ne 
 ((get-wmiobject Win32_NetworkAdapterConfiguration -filter "InterfaceIndex=$((get-wmiobject win32_networkadapter -filter "netconnectionstatus=2 and PhysicalAdapter=$true" | where {$_.name -cnotlike "*vpn*"} | select InterfaceIndex).InterfaceIndex)" | select DefaultIPGateway).defaultIPGateway)
    ){
 #VPN active
  Try { Get-NetRoute -DestinationPrefix 52.120.0.0/14 -ErrorAction stop
    Write-Host "VPN Active, Route Present, Disabling"
    Set-TeamsOptimizeLocal -remove
   }
 Catch {
    Write-Host "VPN Active, Route Not Present, Enabling"
    Set-TeamsOptimizeLocal
 }
}
Else {
 #disable
 Try { Get-NetRoute -DestinationPrefix 52.120.0.0/14 -ErrorAction stop
       Write-Host "VPN Not Connected, Route set, Disabling"
       Set-TeamsOptimizeLocal -remove 
 }
 Catch {
        Write-host "VPN Not Connected, Route not set, Nothing done"
 }
}
