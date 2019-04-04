$gp1 = Get-ADGroupMember "St Benedicts Hospice Staff"
$gp2 = Get-ADGroupMember "VPN SSL Users - DGG" 

If($gp2.count -gte $gp1.count) {
 $gp2 | where {$gp1.name -contains $PSItem.name} | Get-aduser -properties name,sAMAccountName,mail | select name,sAMAccountName,mail | Format-Table
}
Else {
 $gp1 | where {$gp2.name -contains $PSItem.name} | Get-aduser -properties name,sAMAccountName,mail | select name,sAMAccountName,mail | Format-Table
} 