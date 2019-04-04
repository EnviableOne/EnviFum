Function Get-Version{
$Psobj = Get-wmiObject -Class win32_OperatingSystem  
return ("Version : " + $psobj.version + "`n`r" + $psobj.caption.Trim()+ ", " + $Psobj.CSDversion + ", Build " + $Psobj.buildnumber)
}