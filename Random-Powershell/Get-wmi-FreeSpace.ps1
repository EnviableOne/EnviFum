# PowerShell cmdlet to display a disk's free space
$Item = @("DeviceId", "MediaType", "Size", "FreeSpace")
# Next follows one command split over two lines by a backtick `
Get-WmiObject -query "Select * from Win32_logicaldisk Where MediaType=12" `
| Format-Table $Item -auto 


Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
| Format-Table DeviceID, MediaType, `
@{Name="Size(GB)";Expression={[decimal]("{0:N0}" -f($_.size/1gb))}}, `
@{Name="Free Space(GB)";Expression={[decimal]("{0:N0}" -f($_.freespace/1gb))}}, `
@{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}} `
-AutoSize