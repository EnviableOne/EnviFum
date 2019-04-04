Function Get-Parts {
param(
 [parameter(mandatory=$true,position=0)][String]$InStr,
 [parameter(position=1)][validateScript({($_ -gt 0) -and ($_ -lt $instr.length)})][int]$min = 3,
 [parameter(position=2)][validateScript({($_ -ge $min) -and ($_ -le $instr.length)})][int]$max = $InStr.length
 )
 $wlen = $instr.length
 $rlen = $wlen-1
 $i=0
 $j=$min

While ($i -le ($wlen)){
 while ($j -le $max -and $j -le $rlen){
    $InStr.substring($i,$j)
    $j++
 }
 if (!$i -eq 0){
  $rlen--
 }
 $j=$min
 $i++
}
}