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
$myApp = az ad sp create --id $ClientApp.appId | ConvertFrom-Json

# Consent the application for all users
$myPermission = az ad app permission grant --id $ClientApp.AppId --api $ServerApp.AppId

# Disable implicit flow, we don't need this for authcode or device code flows
$myAppUpdated = az ad app update --id $ClientApp.AppId --set oauth2AllowIdTokenImplicitFlow=false *>&1

$header = @{
        'Content-Type' = 'application/json'
        'Authorization' = 'Bearer ' + $AccessToken
}

$header = @{
        'Content-Type' = 'application/json'
}


# Set application to use V2 access tokens
$Body = @{
    api = @{
        requestedAccessTokenVersion = 2
    }
} | ConvertTo-Json -Compress | ConvertTo-Json
# Pipe to ConvertTo-Json twice to escape all quotes, or az cli will remove them when parsing
#az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$($ClientApp.objectId)" --body $Body --headers "Content-Type=application/json"

$APIAppRegAppId="0f803265-28e7-472f-8fb9-86e0c7d40581"
Invoke-RestMethod `
    -Method Patch `
    -Uri "https://graph.microsoft.us/v1.0/applications/$APIAppRegObjectId" `
    -Headers $header `
    -Body $Body

# Output the ClientId for use later
Write-Output $ClientApp.AppId
