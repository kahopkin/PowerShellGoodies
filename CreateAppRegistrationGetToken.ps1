<#
Create and Configure Azure AD Application using PowerShell
https://morgantechspace.com/2021/03/create-and-configure-azure-ad-application-using-powershell.html#get-user-access-token

#>

Connect-AzAccount -Environment AzureUSGovernment

#create a new app
$aadApplication = New-AzureADApplication `
                    -DisplayName "MTS Demo App" `
                    -IdentifierUris "http://mtsdemoapp.contoso.com" `
                    -HomePage "http://mtsdemo.contoso.com"

#add the current user as Owner of the new app, 
$currentUser = (Get-AzureADUser -ObjectId (Get-AzureADCurrentSessionInfo).Account.Id)

Add-AzureADApplicationOwner `
    -ObjectId $aadApplication.ObjectId `
    -RefObjectId $currentUser.ObjectId

#configure the required Application and Delegated permissions in the newly created Azure AD application.
#Get Service Principal of Microsoft Graph Resource API 
$graphSP =  Get-AzureADServicePrincipal -All $true | Where-Object {$_.DisplayName -eq "Microsoft Graph"}
 
#Initialize RequiredResourceAccess for Microsoft Graph Resource API 
$requiredGraphAccess = New-Object Microsoft.Open.AzureAD.Model.RequiredResourceAccess
$requiredGraphAccess.ResourceAppId = $graphSP.AppId
$requiredGraphAccess.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]
 
#Set Application Permissions
$ApplicationPermissions = @('User.Read.All','Reports.Read.All')
 
#Add app permissions
ForEach ($permission in $ApplicationPermissions) 
{
    $reqPermission = $null
    #Get required app permission
    $reqPermission = $graphSP.AppRoles | Where-Object {$_.Value -eq $permission}

    if($reqPermission)
    {
        $resourceAccess = New-Object Microsoft.Open.AzureAD.Model.ResourceAccess
        $resourceAccess.Type = "Role"
        $resourceAccess.Id = $reqPermission.Id    
        #Add required app permission
        $requiredGraphAccess.ResourceAccess.Add($resourceAccess)
    }
    else
    {
        Write-Host "App permission $permission not found in the Graph Resource API" -ForegroundColor Red
    }
}#for
 
#Set Delegated Permissions
#Leave it as empty array if not required
$DelegatedPermissions = @('Directory.Read.All', 'Group.ReadWrite.All') 
 
#Add delegated permissions
ForEach ($permission in $DelegatedPermissions) 
{
    $reqPermission = $null
    #Get required delegated permission
    $reqPermission = $graphSP.Oauth2Permissions | Where-Object {$_.Value -eq $permission}
    if($reqPermission)
    {
        $resourceAccess = New-Object Microsoft.Open.AzureAD.Model.ResourceAccess
        $resourceAccess.Type = "Scope"
        $resourceAccess.Id = $reqPermission.Id    
        #Add required delegated permission
        $requiredGraphAccess.ResourceAccess.Add($resourceAccess)
    }
    else
    {
        Write-Host "Delegated permission $permission not found in the Graph Resource API" -ForegroundColor Red
    }
}
 
#Add required resource accesses
$requiredResourcesAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.RequiredResourceAccess]
$requiredResourcesAccess.Add($requiredGraphAccess)
 
#Set permissions in existing Azure AD App
$appObjectId=$aadApplication.ObjectId
#$appObjectId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
Set-AzureADApplication -ObjectId $appObjectId -RequiredResourceAccess $requiredResourcesAccess

# set permissions while creating a new application.
	
New-AzureADApplication `
    -DisplayName "Permission Test App" `
    -IdentifierUris "http://ptdemoapp.contoso.com" `
    -RequiredResourceAccess $requiredResourcesAccess

#Create client secret or Application password
$appObjectId=$aadApplication.ObjectId
#$appObjectId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$appPassword = New-AzureADApplicationPasswordCredential `
                    -ObjectId $appObjectId `
                    -CustomKeyIdentifier "AppAccessKey" `
                    -EndDate (Get-Date).AddYears(2)

$appPassword.Value #Display app secret key

#Create new Service Principal or Enterprise Application for Azure AD Application
#Provide Application (client) Id
$appId = $aadApplication.AppId
#$appId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$servicePrincipal = New-AzureADServicePrincipal -AppId $appId -Tags @("WindowsAzureActiveDirectoryIntegratedApp")

#Grant consent (user and admin) to Service Principal/Enterprise Application
$appObjectId = $aadApplication.ObjectId
#$appObjectId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$requiredResourcesAccess = (Get-AzureADApplication -ObjectId $appObjectId).RequiredResourceAccess


#to get the service principal object of your Azure AD application by providing the application’s AppId (Application client id)
#Provide Application (client) Id
$appId=$aadApplication.AppId
#$appId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$servicePrincipal = Get-AzureADServicePrincipal -All $true | Where-Object {$_.AppId -eq $appId}


#Grant Admin consent for Application permissions
ForEach ($resourceAppAccess in $requiredResourcesAccess)
{
    $resourceApp = Get-AzureADServicePrincipal -All $true | Where-Object {$_.AppId -eq $resourceAppAccess.ResourceAppId}
    ForEach ($permission in $resourceAppAccess.ResourceAccess)
    {
        if ($permission.Type -eq "Role")
        {
            New-AzureADServiceAppRoleAssignment `
                -ObjectId $servicePrincipal.ObjectId `
                -PrincipalId $servicePrincipal.ObjectId `
                -ResourceId $resourceApp.ObjectId `
                -Id $permission.Id
        }
    }
}



#Grant User or Admin consent for Delegated permissions
# Set ADAL (Microsoft.IdentityModel.Clients.ActiveDirectory.dll) assembly path from Azure AD module location
$AADModule = Import-Module -Name AzureAD -ErrorAction Stop -PassThru

$adalPath = Join-Path $AADModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

$adalformPath = Join-Path $AADModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

[System.Reflection.Assembly]::LoadFrom($adalPath) | Out-Null
[System.Reflection.Assembly]::LoadFrom($adalformPath) | Out-Null 
      
# Azure AD PowerShell client id. 
$ClientId = "1950a258-227b-4e31-a9cf-717495945fc2"
$RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
$resourceURI = "https://graph.microsoft.com"
$authority = "https://login.microsoftonline.com/common"
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority     
 
# Get token by prompting login window.
$platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Always"
$authResult = $authContext.AcquireTokenAsync($resourceURI, $ClientID, $RedirectUri, $platformParameters)
$accessToken = $authResult.Result.AccessToken

#to grant consent for all the users or required users. 
#$requiredResourcesAccess - Refer Configure required API permissions section to form this detail or get it from Get-AzureADApplication for your app
#$servicePrincipal - The servicePrincipal (Enterprise application) object of your Azure AD application
#$accessToken - Require graph access token with required permissions to update oauth2PermissionGrants
 
$GrantConsnetForAllUsers=$true #Set $true to give consent for all users and set $false to give consent for individual user

if ($GrantConsnetForAllUsers) 
{
    #Grant consent for all users
    $consentType = "AllPrincipals"
    $principalId = $null
} 
else 
{
    #Grant consent for the required user alone
    $consentType = "Principal"
    #Get or provide object id for the required Azure AD user
    $principalId = (Get-AzureADUser -SearchString "user@contoso.com").ObjectId
    #$principalId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
 
ForEach ($resourceAppAccess in $requiredResourcesAccess)
{
    $delegatedPermissions = @()
    #$resourceApp - get servicePrincipal of Resource API App(ex: Microsoft Graph, Office 365 SharePoint Online)
    $resourceApp = Get-AzureADServicePrincipal -All $true | Where-Object {$_.AppId -eq $resourceAppAccess.ResourceAppId}
    ForEach ($permission in $resourceAppAccess.ResourceAccess)
    {
        if ($permission.Type -eq "Scope")
        {
            $permissionObj = $resourceApp.OAuth2Permissions | Where-Object {$_.Id -contains $permission.Id}
            $delegatedPermissions += $permissionObj.Value
        }
    }
 
    if($delegatedPermissions)
    {
        #Get existing grant entry
        $existingGrant = Get-AzureADOAuth2PermissionGrant -All $true | Where { $_.ClientId -eq $servicePrincipal.ObjectId -and $_.ResourceId -eq $resourceApp.ObjectId -and  $_.PrincipalId -eq $principalId}
 
        if(!$existingGrant)
        {
            #Create new grant entry
            $postContent = @{
            clientId = $servicePrincipal.ObjectId
            consentType = $consentType
            principalId = $principalId
            resourceId  = $resourceApp.ObjectId
            scope       = $delegatedPermissions -Join " "
        }
 
        $requestBody = $postContent | ConvertTo-Json

        Write-Host "Grant consent for $delegatedPermissions ($($resourceApp.DisplayName))" -ForegroundColor Green
    
        $headers = @{Authorization = "Bearer $accessToken"}

        $response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants" -Body $requestBody -Method POST -Headers $headers -ContentType "application/json"
 
        } 
        else 
        {
            #Update existing grant entry
            $delegatedPermissions+=$existingGrant.Scope -Split " "
            $delegatedPermissions = $delegatedPermissions | Select -Unique
            $patchContent = @{
                scope = $delegatedPermissions -Join " "
            }
 
            $requestBody = $patchContent | ConvertTo-Json

            Write-Host "Update consent for $delegatedPermissions ($($resourceApp.DisplayName))" -ForegroundColor Green

            $headers = @{Authorization = "Bearer $accessToken"}

            $response = Invoke-RestMethod `
                        -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants/$($existingGrant.ObjectId)" `
                        -Body $requestBody `
                        -Method PATCH `
                        -Headers $headers `
                        -ContentType "application/json"
 
        }
    }
}#ForEach ($resourceAppAccess in $requiredResourcesAccess)

#Get access token on behalf of the app – Application permissions
#Get or provide your Office 365 Tenant Id or Tenant Domain Name
$tenantId = (Get-AzureADTenantDetail).ObjectId
#$tenantId = "contoso.onmicrosoft.com"
 
#Provide Application (client) Id of your app
$appClientId=$aadApplication.AppId
#$appClientId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
 
#Provide Application client secret key
$clientSecret = $appPassword.Value
#$clientSecret ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
 
$requestBody = @{client_id=$appClientId;client_secret=$clientSecret;grant_type="client_credentials";scope="https://graph.microsoft.com/.default";}

$oauthResponse = Invoke-RestMethod `
                    -Method Post `
                    -Uri https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token `
                    -Body $requestBody

$accessToken = $oauthResponse.access_token

#Get access token on behalf of a user – Delegated permissions
#Get or provide your Office 365 Tenant Id or Tenant Domain Name
$tenantId = (Get-AzureADTenantDetail).ObjectId
#$tenantId = "contoso.onmicrosoft.com"
 
#Provide Application (client) Id of your app
$appClientId=$aadApplication.AppId
#$appClientId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
 
#Provide Application client secret key
$clientSecret = $appPassword.Value
#$clientSecret ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
 
$username= "user@contoso.com"
$password= "user_password"
$scope="Directory.Read.All openid profile offline_access"
 
$requestBody = @{client_id=$appClientId;client_secret=$clientSecret;grant_type="password";username=$username;password=$password;scope=$scope;}
$oauthResponse = Invoke-RestMethod `
                    -Method Post `
                    -Uri https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token `
                    -Body $requestBody
$accessToken = $oauthResponse.access_token


#Use the access token to call Microsoft Graph

$apiUrl = "https://graph.microsoft.com/v1.0/users"
$users = Invoke-RestMethod -Headers @{Authorization = "Bearer $accessToken"} -Uri $apiUrl -Method Get



