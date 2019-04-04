$osinfo = get-wmiobject -class "Win32_OperatingSystem" -namespace "root\CIMV2" -Property Caption,CSDVersion,Buildnumber
Get-WmiObject -class "win32_networkdisk"
 
