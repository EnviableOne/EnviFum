#Load Variables $expUsers = @(); 
#Current Date $cdate = Get-Date -Format MM-dd-yyyy; 
$result = @(); $users =@(); 
#Max Days 
$mdate = (Get-Date).AddDays(30); 
#List Active Users in TFALL Users OU with Password Never Expires attribute False 
$users = Get-ADUser -Filter {enabled -eq $true} -Properties "msDS-UserPasswordExpiryTimeComputed","Mail","PasswordneverExpires" | Where {($_.PasswordNeverExpires -eq $false)} | Select SamAccountName,Mail,Name,Enabled,msDS-UserPasswordExpiryTimeComputed,PasswordNeverExpires; 
#Convert Expiration Date to MM/dd/YYYY format 
$expUsers = $users | select -Property "SamAccountName","Name","Mail","Enabled","PasswordNeverExpires",@{Name="ExpirationDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}; 
#Get Users whos's expiring in 30 Days 
$exp_Users = $expUsers | Where {$_.ExpirationDate -lt $mdate -and $_.ExpirationDate -gt $cdate -and $_.ExpirationDate -ne 01/01/1601} 
foreach ($user in $exp_Users){ 
 #Convert data to make it readable 
 $result += New-Object -TypeName psobject -Property @{ 
  SamaccountName = @($user).SamaccountName; 
  Name = @($user).Name; 
  Mail = @($user).Mail; 
  Enabled = @($user).Enabled; 
  PasswordNeverExpires = @($user).PasswordNeverExpires; 
  ExpirationDate = @($user).ExpirationDate; 
  } 
 } 
#Export Users with Password Never Expires 
$result | Sort ExpirationDate | format-table

#or
Search-ADAccount -AccountExpiring -TimeSpan "7" | Select-Object Name,SamAccountName,mail,AccountExpirationDate | Sort-Object AccountExpirationDate 