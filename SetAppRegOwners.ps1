#SetAppRegOwners
<#
    This script sets the Single-page application Redirect URI
#>
Function global:SetAppRegOwners
{
    Param(
       [Parameter(Mandatory = $true)] [String]$ObjectId
	)

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n  [$today] START SetAppRegOwners ObjectID $ObjectId "
    $AdApplication = Get-AzADApplication -ObjectId $ObjectId
    $AppName = $AdApplication.DisplayName    
    <#
    #Write-Host -ForegroundColor Yellow "SetAppRegOwners[16] Adding redirect URIs for $AppName with $ObjectId";
    $redirectUris = @()
    $WebAppUrl = "https://$AppName.azurewebsites.us"
    if ($redirectUris -notcontains "$WebAppUrl") {
        $redirectUris += "$WebAppUrl"   
        #Write-Host "SetRedirectURI[21] Adding $WebAppUrl to redirect URIs";
    }
    #>

    $Scope = "Application.ReadWrite.All Directory.Read.All User.Read Application.ReadWrite.OwnedBy" 
    #$accesstoken = (Get-AzAccessToken -Resource "https://graph.microsoft.us/").Token
    $AccessToken = GetMsGraphToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret -Scope $Scope
    
    $AzureContext = Get-AzContext 
    $GraphUrl = "https://graph.microsoft.us/"
    $Uri = $GraphUrl + "v1.0/applications/$APIAppRegAppId/owners"

    $header = @{
        'Content-Type' = 'application/json'
        'Authorization' = 'Bearer ' + $AccessToken
    }

    <#$body = @{
        'spa' = @{
            'redirectUris' = $redirectUris
        }
    } 
    #>
    $body = @{
        
    } 
  
  #$APIAppRegAppId="0f803265-28e7-472f-8fb9-86e0c7d40581"
  $APIAppRegObjectId="d04207b0-7721-4d4e-90bc-f690db3775a9"

  $myGraphApiApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphApiApplication
  $myGraphApiApplication.RequestedAccessTokenVersion = 2
  
  Update-AzADApplication -ObjectId $APIAppRegObjectId -Api $myGraphApiApplication

  $APIAppRegObjectId="d71aa82b-df1e-4b76-8d36-38cbe82259fe"

  $myGraphApiApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphApiApplication

  Update-AzADApplication -ObjectId $AppObjectId -requestedAccessTokenVersion  $AppRoles
       
<#
#requestbody
{
    "directoryObject": {}
}
 #>
 $ObjectId="d71aa82b-df1e-4b76-8d36-38cbe82259fe"
    $bodyJson = ConvertTo-Json $body

    #Invoke-RestMethod -Method Patch -Uri "https://graph.microsoft.us/v1.0/applications/$ObjectId" -Headers $header -Body $bodyJson
    Invoke-RestMethod -Method Patch -Uri $Uri -Headers $header -Body $bodyJson
  
    <#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Green  -BackgroundColor Black " [$today] FINISHED SetAppRegOwners for $AppName"
    #>
}#SetAppRegOwners

<#
Connect-MgGraph -Environment USGov -ClientId 'YOUR_CLIENT_ID' `
  -TenantId 'YOUR_TENANT_ID' -Scopes 'https://graph.microsoft.us/.default'
  #>


<#
//ClientId: Azure AD->  App registrations -> Application ID
//Domain: <tenantname>.onmicrosoft.com
//TenantId: Azure AD -> Properties -> Directory ID

"Authentication": {
    "AzureAd": {

    "Azure ADInstance": "https://login.microsoftonline.us/",
    "CallbackPath": "/signin-oidc",
    "ClientId": "<clientid>",
    "Domain": "<domainname>",
    "TenantId": "<tenantid>"
    }
}
#>