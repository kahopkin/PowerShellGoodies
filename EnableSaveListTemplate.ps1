<#
https://www.sharepointdiary.com/2017/08/sharepoint-online-save-list-as-template-missing.html

#>
#Variables for Admin Center and Site Collection URL
$AdminCenterURL = "https://crescent-admin.sharepoint.com/"
$SiteURL="https://crescent.sharepoint.com/Sites/marketing"
 
#Connect to SharePoint Online
Connect-SPOService -url $AdminCenterURL -Credential (Get-Credential)
 
#Disable DenyAddAndCustomizePages Flag
Set-SPOSite $SiteURL -DenyAddAndCustomizePages $False


#Read more: https://www.sharepointdiary.com/2017/08/sharepoint-online-save-list-as-template-missing.html#ixzz8krX9gMt8