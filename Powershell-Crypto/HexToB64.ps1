Function Convert-HexToBase64
{
 param(
  [parameter(Mandatory=$true)][string]$HexString
  )
 $SrcByte = [byte[]]::new(20);
 for ($i=0;$i -lt $HexString.Length; $i+=2){
  $SrcByte[$i/2] = [convert]::ToByte($HexString.Substring($i,2),16);
 }
 $OutStr = [convert]::ToBase64String($SrcByte); 
 $OutStr;
}
Function Convert-Base64ToHex {
 param(
  [parameter(Mandatory=$true)][String]$Base64Str
 )
 If ($SrcType="STR"){
  $SrcByte = [convert]::FromBase64String($Base64Str);
 }
 Else{
  $SrcByte = $Base64Str;
 }
 $HexString = [System.Text.StringBuilder]::new($SrcByte.Length * 2);
 ForEach($byte in $SrcByte){
  $HexString.AppendFormat("{0:x2}", $byte) | Out-Null;
 }
 $HexString.ToString();
}