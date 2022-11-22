#https://kb.netwrix.com/6010
#Applying Azure Active Directory Graph API Permissions via PowerShell for StealthAUDIT Azure Active Directory Inventory

# Install AzureAD for Powershell
Install-Module AzureAD

# Enter admin Azure credentials that can assign and grant permissions to the application. Format: user@tenant.onmicrosoft.com
$Credentials = Get-Credential

# Connect to Azure
Connect-AzureAD -Credential $Credentials

# Query Azure AD for all applications
Get-AzureADServicePrincipal -All $true | Format-Table displayname, appid, objectid

# Query Azure AD for applications that match a display name provided (replace Application Name)
Get-AzureADApplication -All $true | ? { $_.DisplayName -match "Application Name" } | Format-Table displayname, appid, objectid

# Once you succesfully have your application details, save the object to a variable.
$StealthAUDITApp = Get-AzureADApplication -All $true | ? { $_.DisplayName -match "Application Name" }

# Populate the Azure AD Graph service and permissions
$svcprincipal = Get-AzureADServicePrincipal -All $true | ? { $_.DisplayName -match "Azure Active Directory" }
$reqADGraph = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$reqADGraph.ResourceAppId = $svcprincipal.AppId

#Azure AD Graph Delegated Permission to apply
$delPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "311a71cc-e848-46a1-bdf8-97ff7156d8e6","Scope" # Sign in and read user profile

#Azure AD Graph Application Application Permissions to apply
$appPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "5778995a-e1bf-45b8-affa-663a9f3f4d04","Role" # Read directory data

# Put both permissions into an object
$reqADGraph.ResourceAccess = $delPermission1, $appPermission1

# Update the Application from Line 20 with the new permissions
Set-AzureADApplication -ObjectId $StealthAUDITApp.ObjectId -RequiredResourceAccess $reqADGraph