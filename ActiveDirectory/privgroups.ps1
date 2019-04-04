# GroupMembershipAdded.ps1
# Paul Ackerman
# Apr 2013
#
# This script is tied to a scheduled task which is based on event 4728 firing in the
# security event log in order to send an email alert when critical AD group memberships
# are modified. Event 4728 specifically occurs when a member is added to a group.
# Get the most recent event object from the security log
$Event = Get-EventLog -LogName Security -InstanceId 4728 -Newest 1
# Build an array of groups we want to monitor either directly or from a text file
#$groups = @("Domain Admins","Enterprise Admins","Schema Admins")
$filename = "C:\scripts\groups.txt"
$groups = get-content $filename
# Loop through each group and check to see if the event contained that group
foreach ($group in $groups){
 if ($Event.Message -like "*$group*" ) {
 # Event contains a critical group - fire an email alert
 $MailBody= $Event.Message + "`r`n`t" + $Event.TimeGenerated
 $MailSubject= "***ALERT*** A member was added to a critical Security Group"
 $SmtpClient = New-Object system.net.mail.smtpClient 
 $SmtpClient.host = "your mailserver"
 $MailMessage = New-Object system.net.mail.mailmessage
 $MailMessage.from = "AD_Audit@yourdomain.org"
 $MailMessage.To.add("SecOPS@yourdomain.org")
 $MailMessage.IsBodyHtml = 0
 $MailMessage.Subject = $MailSubject
 $MailMessage.Body = $MailBody
 $SmtpClient.Send($MailMessage)
 }
}