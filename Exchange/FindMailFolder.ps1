function FindMailFolder {
 $fvFolderView = new-object Microsoft.Exchange.WebServices.Data.FolderView($InboxFolder.ChildFolderCount)
 $ffFolderSearch = New-Object Microsoft.Exchange.WebServices.Data.searchfilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName,"DMARC")
 $fmfResult = $InboxFolder.FindFolders($ffFoldersearch,$fvFolderView)
 $fmfresult.ForEach([Microsoft.Exchange.WebServices.Data.FolderSchema]::Id -and [Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName) 

}