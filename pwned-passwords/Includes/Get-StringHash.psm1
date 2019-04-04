#http://jongurgul.com/blog/get-stringhash-get-filehash/
Function Get-StringHash([String] $String, [ValidateSet("MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")] [String] $HashName = "SHA1",[ValidateSet("Hex","B64")][String]$Outformat = "Hex")
{
$StringBuilder = New-Object System.Text.StringBuilder
[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
[Void]$StringBuilder.Append($_.ToString("x2"))
}
If ($Outformat="Hex"){
$StringBuilder.ToString()
}
ElseIf($Outformat="B64") {
$StrHash_as_bytes = [text.encoding]::UTF8.GetBytes($StringBuilder.ToString())
$out=[system.convert]::Tobase64string($StrHash_as_bytes) 
}
}
