$o = New-Object -comobject outlook.application
 $n = $o.GetNamespace("MAPI")

 $Account = $n.Folders | ? { $_.Name -eq 'Mailbox'};
 $f = $Account.Folders | ? { $_.Name -match 'dmarc' };

$filepath = "c:\DMARC\"
 $f.Items | foreach {
  $_.attachments | foreach {
   Write-Host $_.filename
   $_.saveasfile((Join-Path $filepath "$_.filename"))
  }
 }