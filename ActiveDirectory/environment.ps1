
#Get Network Info from WMI
$ObjWmi = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "IPEnabled = $true" -Property IPAddress,IPsubnet,DefaultIPGateway | Select IPAddress,IPsubnet,DefaultIPGateway -Last 1

#Add Environmental Variables
$ObjWmi | Add-Member -type NoteProperty -name "Domain" -value $env:USERDOMAIN
$objwmi | Add-Member -type NoteProperty -name "Computer Name" -value $env:computername
$objwmi | Add-Member -type NoteProperty -name "Username" -value $env:USERNAME
$objwmi | Add-Member -name "Home Dir" -type ScriptProperty -value {Get-PSDrive -name F | select  -ExpandProperty displayroot}
#add PCS Variables
$objwmi | Add-Member -name "PCS Terminal ID" -type scriptProperty -value {(((Select-String -LiteralPath "C:\dev\sslenv.ini" -Pattern term-id).tostring().split(":") | select -last 1 ).split("=") | select -last 1)}
$objwmi | Add-Member -name "PCS Library" -type ScriptProperty -value {Get-PSDrive -name N | select  -ExpandProperty displayroot}

#Convert Object to Text
$OutText = $ObjWmi | Out-String
#Write settings to file
$OutText.Trim() | Out-File -FilePath C:\temp\SYSSet.txt
#Display Variables
[System.Windows.MessageBox]::Show($OutText.trim(),"System Settings",0,64,1)  