<#
Understanding Azure App Registration, Enterprise Apps, And Service Principals
https://xkln.net/blog/understanding-azure-app-registration-enterprise-apps-and-service-principals/

When we create a new App Registration in the Azure AD Portal it does two things:

1: It creates globally unique application object within our Azure AD tenancy:
   This is what we see when we navigate to Azure AD > App Registrations 
2: It creates a local instance of that object, also within our Azure AD tenancy
    This is what we see when we navigate to Azure AD > Enterprise applications within the Azure portal. 
    Here’s the really good news - Enterprise Apps are the service principals. 
    These are two names that refer to exactly the same thing - the local app object within our Azure AD directory.
    When a third party wants to use our app in their environment 
    they only get the local instance created, which then references our global object.
#>

<#
Unlike using the Azure Portal, when we create the App Registration with PowerShell using the New-AzADApplication cmdlet 
it doesn’t automatically create the Enterprise App and service principal. 
However, if instead we directly try to create the service principal,
it will automatically create the associated app registration for us.
There is no way to separate service principals from App registrations.

!!!!! 
One frustrating thing about creating Service Principals with PowerShell 
is they’re NOT visible under the Enterprise Apps filter.
Instead, we need to select “All Apps” and then filter by name.
We also don’t get access access to configuration items such as Conditional Access.
This is due to some missing tags on the Enterprise App object, 
namely WindowsAzureActiveDirectoryIntegratedApp.
!!!!
#>

$SPN = New-AzADServicePrincipal -DisplayName PowerShell-SPExample

#Get the Service Principal:
$SPN = Get-AzADServicePrincipal -ApplicationId $SPN.AppId

#Get the App Registation:
Get-AzADApplication -ApplicationId $SPN.AppId

#Get-AzADServicePrincipal -DisplayNameBeginsWith "PowerShell" | Select DisplayName, Tag
Get-AzADServicePrincipal -DisplayNameBeginsWith $SPN.DisplayName | Select DisplayName, Tag

#configuration items such as Conditional Access:
Update-AzADServicePrincipal -ObjectId $ObjId -Tag "WindowsAzureActiveDirectoryIntegratedApp" -ErrorAction Stop
Get-AzADServicePrincipal -ObjectId $ObjId | Select DisplayName, Tag

<#
There are two ways we can authenticate to Azure AD using Service Principals:
A secret (password)
A certificate
#>

<#Creating a Secret with PowerShell
We need to specify many of the same details when using PowerShell, 
with the one caveat - 
the description (set with the -CustomKeyIdentifier parameter) needs to be Base64 encoded.
#>
$Description = "CreatedWithPS"
$DescriptionB64 = ([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Description)))

$ObjId = Get-AzADApplication -DisplayName "PowerShell-ADAudit" | Select -ExpandProperty Id
$Secret = New-AzADAppCredential -ObjectId $ObjId -StartDate (Get-Date) -EndDate ((Get-Date).AddYears(10)) -CustomKeyIdentifier $DescriptionB64
$Secret

#Using a Service Principal with PowerShell
$Cred = Get-Credential # Username = Application (client) ID, Password = Generated Secret
$TenantId = "Your Azure AD Tenant Id"
Login-AzAccount -Tenant $TenantId -Credential $Cred -ServicePrincipal

#As we’ve successfully logged in with our service account let’s run some commands.
Get-AzADUser | Select -Last 1 | Select DisplayName