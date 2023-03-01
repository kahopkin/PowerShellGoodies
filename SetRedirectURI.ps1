#SetRedirectURI
<#
    This script sets the Single-page application Redirect URI
#>
Function global:SetRedirectURI
{
    Param(
       [Parameter(Mandatory = $true)] [String]$ObjectId
	)

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n  [$today] START SetRedirectURI ObjectID $ObjectId "
    $AdApplication = Get-AzADApplication -ObjectId $ObjectId
    $AppName = $AdApplication.DisplayName    
    
    #Write-Host -ForegroundColor Yellow "SetRedirectURI[16] Adding redirect URIs for $AppName with $ObjectId";
    $redirectUris = @()
    $WebAppUrl = "https://$AppName.azurewebsites.us"
    if ($redirectUris -notcontains "$WebAppUrl") {
        $redirectUris += "$WebAppUrl"   
        #Write-Host "SetRedirectURI[21] Adding $WebAppUrl to redirect URIs";
    }
     
    $AzureContext = Get-AzContext  
    $GraphUrl = $AzureContext.Environment.GraphUrl 
    $Scope = $AzureContext.Environment.GraphUrl + ".default"
    Write-Host -ForegroundColor Yellow "[26]`n `$Scope =`"$Scope`""

    #$oauth2tokenendpointv2 = $AzureContext.Environment.ActiveDirectoryAuthority +   $AzureContext.Tenant.Id + "/oauth2/v2.0/token"
    #Write-Host -ForegroundColor Cyan "[80]`n `$oauth2tokenendpointv2 =`"$oauth2tokenendpointv2`""

     
    $AccessToken = (Get-AzAccessToken -Resource $GraphUrl).Token
    
    $AccessToken = Get-AzAccessToken -ResourceTypeName MSGraph

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

# Set application to use V2 access tokens
$Body = @{
    api = @{
        requestedAccessTokenVersion = 2
    }
} | ConvertTo-Json -Compress | ConvertTo-Json

    Invoke-RestMethod -Method Patch -Uri "https://graph.microsoft.us/v1.0/applications/$ObjectId" -Headers $header -Body $bodyJson
  
    <#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Green  -BackgroundColor Black " [$today] FINISHED SetRedirectURI for $AppName"
    #>
}#SetApplicationIdURI

