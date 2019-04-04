$computers = Get-Content "C:\MSRC\FNFPCs.txt"

$i=0
$j=0
$k=0
$filenames = Get-Content "C:\filenames.txt"
$xmllocat = "" | select "computer", "filename"

foreach ($computer in $computers) {
 Get-ADComputer $computer -Properties 
}
write-host "Total: $i machines checked of $($computers.count), $j machines alive, $k files found"

$Windir,$OSArchitecture,$OSVersion = Get-WmiObject -class Win32_OperatingSystem -ComputerName $_ | foreach {$_.WindowsDirectory,$_.OSArchitecture,$_.Version} 

@{Release="1809";BuildNumber="17763"}
@{Release="1803";BuildNumber="17134"}
@{Release="1709";BuildNumber="16299"}
@{Release="1703";BuildNumber="15063"}
@{Release="1607";BuildNumber="14393"}
@{Release="1511";BuildNumber="10586"}
@{Release="Base";BuildNumber="10240"}