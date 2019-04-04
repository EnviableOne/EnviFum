
 # set inputs
 $hive = "localmachine"
 $regView = "Default"
 $key="SYSTEM\CurrentControlSet\Control\Lsa\"
 $value = "LmCompatibilityLevel"
 [System.Text.RegularExpressions.regex]$pattern = "http\=\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?:\:\d+)"

 #load registry
 $Reghive = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive,$RegView)
 $RegKey = $RegHive.OpenSubKey($key)
 $setting = $RegKey.GetValue($Value)

 #modify result
 If($setting -eq $null){
  $return = "Not Present"
 }
 Elseif ($setting -like "*;*"){
   $return = ($pattern.Match($setting)).value.replace("=","://")
 }
 Else {
  $return = $setting.replace("=","://")
 }
 #send result
 return $return


#HKLM\SYSTEM\CurrentControlSet\Control\Lsa\LmCompatibilityLevel