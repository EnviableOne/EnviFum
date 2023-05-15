$groups=Get-AzureADGroup -all:$true
$results = @()
Foreach ($Group in $groups){
 $members = Get-AzureADGroupMember -ObjectId $group.objectid -All:$True
 foreach($member in $members){
  $result = new-object PSCustomObject
   $result | Add-Member -MemberType NoteProperty -Name Groupid -Value $Group.objectid
   $result | Add-Member -MemberType NoteProperty -Name Group -Value $Group.DisplayName
   $result | Add-Member -MemberType NoteProperty -Name Memberid -Value $member.objectid
   $result | Add-Member -MemberType NoteProperty -Name Username -Value $member.DisplayName
   $result | Add-Member -MemberType NoteProperty -Name UPN -Value $member.userPrincipalName
   $result | Add-Member -MemberType NoteProperty -Name UserType -Value $member.UserType
  $results += $result
 }
}
$results | ft #Export-Csv -NoTypeInformation -Encoding UTF8 -Path C:\temp\AAD-Groups.csv
