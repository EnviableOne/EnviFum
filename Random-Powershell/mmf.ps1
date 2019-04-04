function Select-INStringMMF {
  <# .SYNOPSIS
  #   Select a matching string from an alphabetically sorted file.
  # .DESCRIPTION
  #   Select-INString is a specialised binary (half interval) searcher designed to find matches in sorted ASCII encoded text files.
  # .PARAMETER FileName
  #   The name of the file to search.
  # .PARAMETER String
  #   The string to find. The string is treated as a regular expression and must match the beginning of the line.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   Select-INString 
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     11/08/2014 - Chris Dent - First release.
  #     26/02/2018 - P Marquis - Added memory mapped files, escaped regex control chars and optomised
  #>
   param(
    [Parameter(Mandatory = $true)]
    [String]$String,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ } )]
    [String]$FileName
  )
 $FileName = (Get-Item $FileName).FullName
 Try 
 {
  $MMFile=[System.IO.memoryMappedFile]::CreateFromFile($FileName,[System.IO.FileMode]::Open,"pwnpwd", 0, [System.IO.MemoryMappedFiles.MemoryMappedFileAccess]::Read)
  $MMStream = $MMFile.CreateViewStream()
  $BinaryReader = New-Object IO.BinaryReader($MMStream) 
 }
 Catch [System.IO.IOException] 
 {
  [System.Windows.MessageBox]::Show("Unable to open file") 

 }
 Catch 
 {
  $FileStream = New-Object IO.FileStream($FileName, [IO.FileMode]::Open)
  $BinaryReader = New-Object IO.BinaryReader($FileStream)
 }
 $Length = $BinaryReader.BaseStream.Length
 $Position = $Length / 2
 
 [Int64]$HalfInterval = $Length / 2
 $Position = $Length - $HalfInterval
 $string=[regex]::Escape($string)

 while ($Position -gt 1 -and $Position -lt $Length -and $Position -ne $LastPosition) 
  {
   $LastPosition = $Position
   $HalfInterval = $HalfInterval / 2
 
   [void]$BinaryReader.BaseStream.Seek($Position, [IO.SeekOrigin]::Begin) 
   
   # Track back to the start of the line
   while ($true) 
   {
    $Character = $BinaryReader.ReadByte()
    if ($BinaryReader.BaseStream.Position -eq 1) 
    {
     [void]$BinaryReader.BaseStream.Seek(-1, [IO.SeekOrigin]::Current)
     break
    } 
    elseif ($Character -eq [Byte][Char]"`n") 
    {
     break
    } 
    else 
    {
     [void]$BinaryReader.BaseStream.Seek(-2, [IO.SeekOrigin]::Current)
    }
   }
   # Read the line
   $Characters = @()
   if ($BinaryReader.BaseStream.Position -lt $BinaryReader.BaseStream.Length) 
   {
    $Characters = $BinaryReader.ReadBytes(40)
    $Line = (New-Object String (,[Char[]]$Characters)).Trim()
   } 
   else 
   {
    # End of file
    $FileStream.Close()
    Return $null
   }
   $Line=[regex]::Escape($Line)
   if ($Line -match "^$String") 
   {
    # Close the file stream and return the match immediately
    $FileStream.Close()
    Return $Line
   } 
   elseif ($Line -lt $String) 
   {
    $Position = $Position + $HalfInterval
   } 
   elseif ($Line -gt $String) 
   {
    $Position = $Position - $HalfInterval
   }
  }
  Finally
  { 
   # Close the file stream if no matches are found.
   $FileStream.Close()
  }
 }
