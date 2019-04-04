$Event = Get-EventLog -LogName Security -InstanceId 4624 -Newest 1
$filename = "C:\scripts\authusers.txt"
$authUsers = get-content $filename
$authorized = $false
# Loop through each user and check to see if the event contained an authorized user
foreach ($authUser in $authUsers){
 if ($Event.Message -like "*$authUser*" ) {$authorized = $true}
If ($authorized -eq $false) { 
 Send-MailMessage –To “Security@stft.nhs.uk” –Subject “Unauth Priv Use Alert on $env.computername” –Body “$Event” –SmtpServer “mail.stft.nhs.uk” -From NoSoupForYou@stft.nhs.uk –Priority High -UseSsl
}