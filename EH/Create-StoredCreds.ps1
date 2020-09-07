$ErrorActionPreference = "Stop"
Import-Module C:\EnviFun\ad\TestCred.ps1
$Creds = Get-Credential
while(!(Test-Cred $Creds)){
 $Creds = Get-Credential
}
$SecureStringText = $Creds.Password | ConvertFrom-SecureString
Set-Content "C:\audit\pwdaudit\includes\SpongeyAdm.txt" $SecureStringText
