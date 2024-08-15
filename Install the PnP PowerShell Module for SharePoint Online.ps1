#Install the PnP PowerShell Module for SharePoint Online
#Read more: https://www.sharepointdiary.com/2021/02/how-to-install-pnp-powershell-module-for-sharepoint-online.html#ixzz8BPKSxMux
#https://www.sharepointdiary.com/2021/02/how-to-install-pnp-powershell-module-for-sharepoint-online.html

$url = "https://microsoft-my.sharepoint.com/personal/kahopkin_microsoft_com1/_layouts/15/AdminRecycleBin.aspx"
$url = "https://microsoft-my.sharepoint.com/personal/kahopkin_microsoft_com1"
Connect-PnPOnline -Url $url

#https://www.sharepointdiary.com/2021/02/how-to-install-pnp-powershell-module-for-sharepoint-online.html
Get-Module SharePointPnPPowerShellOnline -ListAvailable | Select-Object Name,Version

	
Uninstall-Module SharePointPnPPowerShellOnline -Force -AllVersions

	
Install-Module PnP.PowerShell

#verify the installation by getting a list of PnP PowerShell cmdlets
Get-Command -Module PnP.Powershell

<#
In case you are not a global admin, use: 
Register-PnPManagementShellAccess -ShowConsentUrl 
and share the URL you get from this cmdlet with the Tenant Admin, and they can complete this consent step from the URL you share.

In case you are not a global admin, use: Register-PnPManagementShellAccess -ShowConsentUrl 
and share the URL you get from this cmdlet with the Tenant Admin, 
and they can complete this consent step from the URL you share.
#Read more: https://www.sharepointdiary.com/2021/02/how-to-install-pnp-powershell-module-for-sharepoint-online.html#ixzz8BPJtNvYh
#>
Register-PnPManagementShellAccess -ShowConsentUrl 

#Connect SharePoint Online site using PnP PowerShell

#Connect to PnP Online
Connect-PnPOnline -Url "https://Crescent.sharepoint.com/sites/Marketing/" -Credential (Get-Credential)
 
#Get All Lists
Get-PnPList

Connect-PnPOnline using MFA:

<#To connect to SharePoint Online using PnP PowerShell MFA (Multifactor authentication): 
Use the “-Interactive” switch instead of “Credentials” if your account is MFA enabled. 
Behind the scenes, each cmdlet executes a client-side object model code to achieve functions.
#>
#Connect to SharePoint site
Connect-PnPOnline -Url "https://Crescent.sharepoint.com/sites/Marketing/" -Interactive
 
#Get All Lists
Get-PnPList

#PowerShell to connect to OneDrive for Business
#connect to OneDrive site and create a new folder
Parameters
$OneDriveSiteURL = "https://microsoft-my.sharepoint.com/personal/kahopkin_microsoft_com1/"
$FolderName = "Archives"
   
Try {
    #PowerShell to Connect to OneDrive for Business
    Connect-PnPOnline -Url $OneDriveSiteURL -Interactive
       
    #ensure folder in SharePoint Online using powershell
    Resolve-PnPFolder -SiteRelativePath "Documents/$FolderName"
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}

#update PnP PowerShell? To update the PnP PowerShell, run:

Update-Module -Name "PnP.PowerShell"


#To check the installed version of PnP PowerShell in your system, use:
Get-InstalledModule -Name "PnP.PowerShell"
Uninstall PnP PowerShell Module

#If you would like to remove the PnP PowerShell, you can run the following:
Uninstall-Module -Name "PnP.PowerShell"

#If you want to use the PnP PowerShell module for SharePoint Server (On-Premises), You can install it along with Pnp.PowerShell module as:
Install-Module -Name SharePointPnPPowerShell2019 -AllowClobber

