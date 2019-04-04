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