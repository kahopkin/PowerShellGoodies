<#

#>

$APIAppRegAppId="0f803265-28e7-472f-8fb9-86e0c7d40581"
$APIAppRegSecret=".Xr.Tuf8Zl.LC2WsAv2vz6zAIi3Wm_FgG2"
$APIAppRegObjectId="d71aa82b-df1e-4b76-8d36-38cbe82259fe"

$CurrUserName="Jane Doe (Test User)"
$CurrUserFirst="Jane"
$CurrUserPrincipalName="janedoe@bmtndev.onmicrosoft.us"
$CurrUserId="71841acf-4751-4add-8649-0c50c6b75f10"

#$Scope = "Application.ReadWrite.All Directory.Read.All User.Read Application.ReadWrite.OwnedBy" 
$Scope = "Application.ReadWrite.All Directory.Read.All User.Read" 

$GraphConnectionStatus = Connect-MgGraph -Environment USGov -Scopes $Scope -ErrorAction Stop

$GraphConnectionStatus = Connect-MgGraph -Environment USGov -Scopes "Application.ReadWrite.All Directory.Read.All User.Read" 
# -ErrorAction Stop

#$accesstoken = (Get-AzAccessToken -Resource "https://graph.microsoft.us/").Token
$AccessToken = GetMsGraphToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret
 #-Scope $Scope




if ($AccessToken -eq $null) {
    
    # Get an access token to Graph API using the 'Azure AD PowerShell' client ID
    $AuthContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext "https://login.microsoftonline.com/$TenantId"
    $PromptBehavior = if ($Prompt) { "Always" } else { "Auto" }
    try {
        $AuthResult = $AuthContext.AcquireToken(
                        "https://graph.windows.net",              <# Resource #>
                        $APIAppRegAppId,   <# Client ID #>
                        [Uri]::new('urn:ietf:wg:oauth:2.0:oob'),  <# Redirect URI #>
                        $PromptBehavior                           <# Prompt, 'Auto' or 'Always' #>
                      )
        $AccessToken = $AuthResult.AccessToken
        if ($AccessTokenOut -ne $null) {
            $AccessTokenOut.Value = $AccessToken
        }
    } catch {
        throw $_
    }
}


$AzureContext = Get-AzContext 
$ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id
$GraphUrl = $AzureContext.Environment.GraphUrl + $AzureContext.Tenant.Id



# The link to the additional owner, in JSON
$Url = $GraphUrl + "/users/" + $CurrUserId
$AdditionalOwnerLink = @{
    "url" = $Url
}  | ConvertTo-Json


# Add new owner to Application
$Uri = $GraphUrl + "/applications/" + $APIAppRegObjectId + "/`$links/owners?api-version=1.6"
$Result = Invoke-WebRequest -Headers $Headers -Method Post `
            -Uri $Uri `
            -Body $AdditionalOwnerLink
if ($Result.StatusCode -eq 204) {    
    Write-Host "New owner '$Add' added to Application"
}


# Add new owner to ServicePrincipal
if ($SP -ne $null) {
    $Result = Invoke-WebRequest -Headers $Headers -Method Post `
                -Uri "https://graph.windows.net/$TenantId/servicePrincipals/$($SP.objectId)/`$links/owners?api-version=1.6" `
                -Body $AdditionalOwnerLink
    if ($Result.StatusCode -eq 204) {    
        Write-Host "New owner '$Add' added to ServicePrincipal"
    }
}

########

 $header = @{
        'Content-Type' = 'application/json'
        'Authorization' = 'Bearer ' + $AccessToken
    }

$body = @{
    'spa' = @{
        'redirectUris' = $redirectUris
    }
} 

$bodyJson = ConvertTo-Json $body

#Invoke-RestMethod -Method Patch -Uri "https://graph.microsoft.us/v1.0/applications/$ObjectId" -Headers $header -Body $bodyJson
Invoke-RestMethod -Method Patch -Uri $Uri -Headers $header -Body $bodyJson

Import-Module Microsoft.Graph.Applications
$CurrUserId="71841acf-4751-4add-8649-0c50c6b75f10"
$params = @{
	"@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/" + $CurrUserId
}

#New-MgApplicationOwnerByRef -ApplicationId $applicationId -BodyParameter $params  