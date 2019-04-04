function Get-UserDetails {
 Param(
  [Parameter(Mandatory=$true,position=1)] [String]$user,
  [switch]$Verb,
  [switch]$ToFile,
  [switch]$ToWindow)

 if($verb){
  $Out=get-aduser -identity $user -properties givenName,Surname,mail,sAMAccountName,Department,title,description,memberof,created,modified | Select givenName,Surname,mail,Department,title,description,UserPrincipalName,sAMAccountName,SID,ObjectGUID,created,modified,enabled,memberof
  $memberof= get-aduser -identity $user -properties memberof | select-object -ExpandProperty memberof | Get-ADGroup -Properties name | select name -Unique | Sort-Object name 
  $memberof = For-Each (get-childobject $memberof)  {Select $_.name.value.tostring()}
  $out | add-member "groups" $memberof
 }    
 else{
  $Out=get-aduser -identity $user -properties givenName,Surname,sAMAccountName,mail,Department,title,description,created,modified | Select givenName,Surname,sAMAccountName,mail,Department,title,description,modified
  $locked = (Search-ADAccount -LockedOut | Where-Object SamAccountName -eq $user | Measure-Object).count -ge 1
  $expired = (Search-ADAccount -AccountExpired | Select-Object Name,SamAccountName,AccountExpirationDate | Where-Object SamAccountName -EQ $user| Measure-Object).count -ge 1
  $disabled = (Search-ADAccount -AccountDisabled | Select-Object Name,SamAccountName,Enabled | Where-Object SamAccountName -EQ $user | Measure-Object).count -lt 1
  $out | add-member "Locked" $locked
  $out | Add-Member "Expired" $expired
  $out | Add-Member "Enabled" $disabled
 }
 
 if($ToFile){
   $Out | Export-Csv "$user.csv" -Force
 }
   if($towindow){
    $out=$Out | Out-string -Verbose
    $Out=$Out.trim() 
    [System.Windows.Forms.Messagebox]::Show($out,"Get-User Details : $user",0)
  }
  Else{
   $Out = $Out | Out-string
   $Out.trim()
  }
}
Set-Alias -name gud -Value Get-UserDetails