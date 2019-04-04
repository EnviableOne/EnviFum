# remove the SET alias (normally used for set-variable)
 if (test-path alias:set) { remove-item alias:set > $null }
 function set
 {
  [string]$var = $args
  if ($var -eq "")
    {get-childitem env: | sort-object name}
   else
    {
    if ($var -match "^(\S*?)\s*=\s*(.*)$")
    {set-item -force -path "env:$($matches[1])" -value $matches[2];}
    else
    {write-error "ERROR Usage: VAR=VALUE"}
   } 
 }
