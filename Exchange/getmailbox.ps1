$Identity = get-mailbox peter.marquis@stft.nhs.uk
$MailBox = "suspect.email@stft.nhs.uk"
$dllpath = "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll";            
[void][Reflection.Assembly]::LoadFile($dllpath);            
$Service = new-object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010);            
$Service.AutodiscoverUrl($MailBox);            
$enumSmtpAddress = [Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress            
$smtpEmail=$Identity.PrimarySMTPAddress.ToString()
$Service.ImpersonatedUserId =  New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId($enumSmtpAddress,$smtpEmail);            

            
$pageSize=100;            
$pageLimitOffset=0;            
$getMoreItems=$true;            
$itemCount=0;            
$propGivenName = [Microsoft.Exchange.WebServices.Data.ContactSchema]::GivenName;            
$propSurname = [Microsoft.Exchange.WebServices.Data.ContactSchema]::Surname;            
$propEmail1 = [Microsoft.Exchange.WebServices.Data.ContactSchema]::EmailAddress1;            
$propEmail2 = [Microsoft.Exchange.WebServices.Data.ContactSchema]::EmailAddress2;            
$propEmail3 = [Microsoft.Exchange.WebServices.Data.ContactSchema]::EmailAddress3;            
$propDisplayName = [Microsoft.Exchange.WebServices.Data.ContactSchema]::DisplayName;            
            
while ($getMoreItems)            
{               
 $view = new-object Microsoft.Exchange.WebServices.Data.ItemView($pageSize,$pageLimitOffset,[Microsoft.Exchange.WebServices.Data.OffsetBasePoint]::Beginning);            
 $view.Traversal = [Microsoft.Exchange.WebServices.Data.ItemTraversal]::Shallow;            
 #Added properties to be returned with the query results            
 $view.PropertySet = new-object Microsoft.Exchange.WebServices.Data.PropertySet($propGivenName,$propSurname,$propEmail1,$propEmail2,$propEmail3,$propDisplayName);             
 #Added three filter properties for the contacts Email fields (there are three of them).            
 $searchFilterEmail1 = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+Exists($propEmail1);            
 $searchFilterEmail2 = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+Exists($propEmail2);            
 $searchFilterEmail3 = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+Exists($propEmail3);            
 #Add the filter objects to the filters collection using the OR operator            
 $searchFilters = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+SearchFilterCollection([Microsoft.Exchange.WebServices.Data.LogicalOperator]::Or);            
 $searchFilters.add($searchFilterEmail1);            
 $searchFilters.add($searchFilterEmail2);            
 $searchFilters.add($searchFilterEmail3);             
 #Perform the search against the default Contacts folder, and store the results in a variable            
 $contactItems = $Service.FindItems([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Contacts,$searchFilters,$view);            
 #Foreach contact, print the contacts display name and email addresses.            
 foreach ($item in $contactItems.Items)            
 {            
  if ($item.GetType().FullName -eq "Microsoft.Exchange.WebServices.Data.Contact")            
  {                
   Write-Host ([String]::Format("************** {0} ******************",$item.DisplayName));            
   Write-Host "First Name:"$item.GivenName;            
   Write-Host "Surname:"$item.Surname;               
   Write-Host "Email 1:"($item.EmailAddresses[[Microsoft.Exchange.WebServices.Data.EmailAddressKey]::EmailAddress1]).Address;            
   Write-Host "Email 2:"($item.EmailAddresses[[Microsoft.Exchange.WebServices.Data.EmailAddressKey]::EmailAddress2]).Address;            
   Write-Host "Email 2:"($item.EmailAddresses[[Microsoft.Exchange.WebServices.Data.EmailAddressKey]::EmailAddress3]).Address;               
  }            
 }            
 if ($contactItems.MoreAvailable -eq $false){$getMoreItems = $false}            
 if ($getMoreItems){$pageLimitOffset += $pageSize}             
}