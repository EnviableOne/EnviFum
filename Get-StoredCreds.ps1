$user = "marp0201"
$pwdString = Get-Content "C:\audit\pwdaudit\includes\spongecake.txt"
$Credpwd = $pwdString | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $User,$Credpwd

Test-Cred $cred