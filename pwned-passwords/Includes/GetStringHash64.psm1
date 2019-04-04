Function Get-HashOut 
{
 Param(
  [Parameter(Mandatory=$true)] [String] $String, 
  [ValidateSet("MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")] [String] $HashName = "SHA1",
  [ValidateSet("Hex","B64")][String] $Outformat = "Hex"
 )
 $enc = [system.Text.Encoding]::UTF8
 $data1 = $enc.GetBytes($String) 

 # Create a New Crypto Provider 
 $Hasher = [System.Security.Cryptography.HashAlgorithm]::Create($HashName)

 # Now hash and display results 
 $result1 = $Hasher.ComputeHash($data1)
 $Base64Hash=[System.Convert]::ToBase64String($result1)
 $HexHash=[System.BitConverter]::ToString($result1).Replace("-","")

 Switch ($Outformat){
 Hex {Return $HexHash}
 B64 {Return $Base64Hash}
 default {Return "Not Implemented"}
}
}