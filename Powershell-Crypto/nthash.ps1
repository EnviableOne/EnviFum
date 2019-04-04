Param(
  [Parameter(Mandatory=$true)] [String] $String, 
  [ValidateSet("LM", "NTLM", "LM2", "NTLM2")] [String] $HashName = "LM",
  [ValidateSet("Hex","B64")][String] $Outformat = "Hex"
 )
 import-module "c:\msrc\md4.ps1"
 Function LM-hash {
Param(
 [Parameter(mandatory=$true,ValueFromPipeline=$true,position=0)][ValidateLength(7,7)][string]$Invalue
)
 $plaintext = "KGS!@#$%"
# Convert string to byte array
$OEM = [System.Text.Encoding]::GetEncoding($Host.CurrentCulture.TextInfo.OEMCodePage)
$inBytes = $OEM.GetBytes($invalue)

# Create a binary string from our bytes
$bitString = ''
foreach($byte in $inBytes){
    $bitstring += [convert]::ToString($byte, 2).PadLeft(8, '0')
}

# Partition the byte string into 7-bit chunks
[byte[]]$key = $bitString -split '(?<=\G.{7}(?<!$))' |ForEach-Object {
    # Insert 0 as the least significant bit in each chunk
    # Convert resulting string back to [byte]
    [convert]::ToByte("${_}0", 2)
}

 # Create the first encryptor from our new key, and an empty IV
 $iv = new-object "System.Byte[]" 8
 $DESCSP = New-Object -TypeName System.Security.Cryptography.DESCryptoServiceProvider -Property @{key=$key; IV = $IV; mode = [System.Security.Cryptography.CipherMode]::ECB; Padding=[System.Security.Cryptography.PaddingMode]::None}
 $enc = $DESCSP.CreateEncryptor()

 # Calculate half of the hash
 $block1 = $enc.TransformFinalBlock($OEM.GetBytes($plaintext), 0, 8)
 return [System.BitConverter]::ToString($block1).replace("-","") 
 # Dispose of the encryptor
 $enc.Dispose()
}

  Switch ($HashName) {
 "LM"{
    If ($string.Length -gt 14){
	    Throw "TerminatingError - LM Hash does not support clear test greater than 14 chars"
    }
    Else {
     $string=$string.PadRight(14,$null).ToUpper()
    }
    $str1 = $string.substring(0,7)
    $str2 = $String.Substring(7)
    $data1 = LM-hash $str1
    $data2 = LM-hash $str2
    $data= $data1 + $data2
 }
 "NTLM" {
    $enc = [system.Text.UnicodeEncoding]::New($false,$false)
    $text = $enc.GetBytes($String) 
    $data1 = MD4Hash $text
}
 default {
    $data= "algorithm not implemented"
 }
}
return $data
