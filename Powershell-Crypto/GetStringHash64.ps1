Function Get-HashOut 
{
 Param(
  [Parameter(Mandatory=$true)] [String] $String, 
  [ValidateSet("MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")] [String] $HashName = "SHA1",
  [ValidateSet("Hex","B64","Int")][String] $Outformat = "Hex"
 )
 $enc = [system.Text.Encoding]::UTF8
 $data1 = $enc.GetBytes($String) 

 # Create a New Crypto Provider 
 $Hasher = [System.Security.Cryptography.HashAlgorithm]::Create($HashName)

 # hash the input 
 $result1 = $Hasher.ComputeHash($data1)
  
 #display result
 Switch ($Outformat){
 Hex {
  $HexHash=[System.BitConverter]::ToString($result1).Replace("-","")
  Return $HexHash
  }
 B64 {
  $Base64Hash=[System.Convert]::ToBase64String($result1)
  Return $Base64Hash
  }
 Int {
  [bigint]$Inthash=new BigInterger($result1)
  Return $IntHash
  }
 default {Return "Not Implemented"}
}
}