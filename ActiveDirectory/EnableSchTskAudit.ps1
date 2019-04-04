$computer = gc env:computername
$path = “c:\windows\tasks”
$user = “everyone”
$path = $path.replace(“\”, “\\”)

$SD = ([WMIClass] “Win32_SecurityDescriptor”).CreateInstance()
$ace = ([WMIClass] “Win32_ace”).CreateInstance()
$Trustee = ([WMIClass] “Win32_Trustee”).CreateInstance()
$SID = (new-object security.principal.ntaccount $user).translate([security.principal.securityidentifier])
[byte[]] $SIDArray = ,0 * $SID.BinaryLength
$SID.GetBinaryForm($SIDArray,0)

$Trustee.Name = $user
$Trustee.SID = $SIDArray

$ace.AccessMask = [System.Security.AccessControl.FileSystemRights]"Modify"
$ace.AceFlags = "0x67"
$ace.AceType = 2
$ace.Trustee = $trustee

$SD.SACL = $ace
$SD.ControlFlags="0x10"

$wPrivilege = gwmi Win32_LogicalFileSecuritySetting -ComputerName $computer -Filter "path='$path'"
$wPrivilege.psbase.Scope.Options.EnablePrivileges = $true
$wPrivilege.setsecuritydescriptor($SD)