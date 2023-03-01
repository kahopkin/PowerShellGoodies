<#
https://blog.simonw.se/calling-azure-function-from-powershell/
Calling Azure Function from PowerShell
#>
$ClientAppDisplayName = 'MySuperApiClient'
$ServerAppId = 'c491d3f8-0d15-4ea5-96fd-957601d579fa'
$RedirectUri = 'https://localhost'

# Get the server app
$ServerApp = az ad app show --id $ServerAppId | ConvertFrom-Json

# Get oAuthPermission for user_impersonation from server app
$oAuthPermissionId = az ad app show --id $ServerApp.AppId --query "oauth2Permissions[?value=='user_impersonation'].id" -o tsv

# Build part of a manifest for requiredResourceAccess
$requiredResourceAccess = @{
    resourceAppId  = $ServerApp.AppId
    resourceAccess = @(
        @{
            id   = $oAuthPermissionId
            type = 'Scope'
        }
    ) 
} | ConvertTo-Json -AsArray -Depth 4 -Compress | ConvertTo-Json
# Pipe to ConvertTo-Json twice to escape all quotes, or az cli will remove them when parsing

# Register client application
$ClientApp = az ad app create --display-name $ClientAppDisplayName --native-app --reply-urls $RedirectUri --required-resource-accesses $requiredResourceAccess | ConvertFrom-Json
# Create a service principal for the application
$null = az ad sp create --id $ClientApp.appId | ConvertFrom-Json

# Consent the application for all users
$null = az ad app permission grant --id $ClientApp.AppId --api $ServerApp.AppId

# Disable implicit flow, we don't need this for authcode or device code flows
$null = az ad app update --id $ClientApp.AppId --set oauth2AllowIdTokenImplicitFlow=false *>&1

# Set application to use V2 access tokens
$Body = @{
    api = @{
        requestedAccessTokenVersion = 2
    }
} | ConvertTo-Json -Compress | ConvertTo-Json
# Pipe to ConvertTo-Json twice to escape all quotes, or az cli will remove them when parsing
$null = az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$($ClientApp.objectId)" --body $Body --headers "Content-Type=application/json"

# Output the ClientId for use later
Write-Output $ClientApp.AppId


#set our client application to require users being assigned a role just like we did our server application.
$ClientAppId = '479fe3c1-a9a4-4098-b343-db98e7c6e81b'
az ad sp update --id $ClientAppId --set appRoleAssignmentRequired=true


#assign the default access role to users just like we did with the server app above, this time using our clent appId instead of the server.
$AppId = '479fe3c1-a9a4-4098-b343-db98e7c6e81b'
$UserPrincipalName = 'simon@simonw.se'

$App = az ad sp show --id $AppId | ConvertFrom-Json
$principalId = az ad user show --id $UserPrincipalName --query 'objectId' -o tsv

$Body = @{
    appRoleId = [Guid]::Empty.Guid
    principalId = $principalId
    resourceId = $App.objectId
} | ConvertTo-Json -Compress | ConvertTo-Json
az rest --method post --uri "https://graph.microsoft.com/v1.0/users/$UserPrincipalName/appRoleAssignments" --body $Body --headers "Content-Type=application/json"


#Get OAuth tokens from AzureAD with PowerShell
Install-Module MSAL.PS


<#
Now we need the clientID for the application we are requesting a token for, the tenant id for our tenant and a list of scopes. 
The redirect URI needs to match a redirect URI configured on our application.
#>

$ClientAppId = '479fe3c1-a9a4-4098-b343-db98e7c6e81b'
$TenantId = "b5fbba89-c11c-4ba3-baf3-67fb6d5fb61f"
$Scopes = 'https://mysuperapi.azurewebsites.net/user_impersonation'
$RedirectUri = 'http://localhost'

Import-Module 'MSAL.PS' -ErrorAction 'Stop'
$PublicClient = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($ClientAppId).WithRedirectUri($RedirectUri).Build()
$token = Get-MsalToken -PublicClientApplication $PublicClient -TenantId $TenantId -Scopes $Scopes

Invoke-RestMethod -Uri "https://mysuperapi.azurewebsites.net/api/mysuperfunc" -Headers @{Authorization = "Bearer $($token.AccessToken)" }