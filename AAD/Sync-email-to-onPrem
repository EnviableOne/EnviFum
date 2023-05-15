try 
{ $var = Get-AzureADTenantDetail } 

catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] 
{ Write-Host "You're not connected. logging in..."; Connect-AzureAD}

$aadusers = Get-AzureADUser -Filter "(accountEnabled eq true) and (userType eq 'Member')" -all:$true

Foreach($aaduser in $aadusers){
 $onPremDN = $aaduser.extensionproperty.onPremisesDistinguishedName
 If ($onPremDN){
  If ($aaduser.mail -ne $null){
   Try{
    Set-ADUser $onPremDN -EmailAddress $aaduser.mail
   }
   Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    Write-Warning "User: $onPremDN Not found"
   }
  }
 }
}
