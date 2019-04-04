#Simple Standalone execution
$SecString = Read-Host -Prompt "input the password to test" -AsSecureString
$PwndTimes = Get-Pwned $SecString -Secure
$TimesStr = $PwndTimes.ToString()
if ($PwndTimes -eq 0){
 $response = "This password has not been disclosed in any breaches yet, however this does not mean it is secure, however it is ok to use."
 $iconstr = "Information"
 }
else {
 $response = "This password has been disclosed in $TimesStr data breaches, and should not be used on any live systems"
 $iconstr = "Stop"
}
[void][System.Windows.MessageBox]::Show($response,"Pwned Passwords Check",0,$iconStr,0,0)
$SecString.Dispose()
