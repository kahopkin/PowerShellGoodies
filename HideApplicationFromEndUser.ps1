#https://learn.microsoft.com/en-us/graph/api/serviceprincipal-post-serviceprincipals?view=graph-rest-1.0&tabs=powershell
#Import-Module Microsoft.Graph.Applications
$AppId = "094cc3b3-b546-419f-98fc-bffb5a038cbb"
$params = @{
	AppId = "094cc3b3-b546-419f-98fc-bffb5a038cbb"
}

New-MgServicePrincipal -BodyParameter $params



#https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/hide-application-from-user-portal?pivots=ms-powershell
#Hide an application from the end user

$context = Get-MgContext -ErrorAction Stop

#Get-MgEnvironment 
#Get-MgEnvironment | Select Name | Format-table
    #USGovDoD,Germany,USGov,China,Global
Connect-MgGraph -Environment USGov
$objectId = "8837dabd-583a-4b64-8e72-572c8538dda5"
$APIAppRegServicePrincipalId="66d7a8e4-c6be-4f2d-ba7a-c40f4bf3af37"

$servicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $objectId
$tags = $servicePrincipal.tags
$tags += "HideApp"
$tags += "ShowApp"
Update-MgServicePrincipal -ServicePrincipalID  $objectId -Tags $tags

$tenantId = $DeployObject.TenantId
#BMTN
$tenantId =  "f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0"
$AppName = "Graph"
$AppId ="d79e5400-8b72-4123-9ef3-354f18214597"
$secret =".kqQ18auIkP6-~vd2u.2QLellUpgD71aqM"
$secretId="bda26bf7-95f0-4100-b674-a734570c02cb"
$expires="12/22/2024"
Connect-MgGraph -Environment USGov -ClientId $AppId -TenantId $tenantId -Scopes 'https://graph.microsoft.us/.default'

#https://learn.microsoft.com/en-us/graph/migrate-azure-ad-graph-configure-permissions?view=graph-rest-1.0&tabs=powershell%2Cupdatepermissions-azureadgraph-powershell
Import-Module Microsoft.Graph.Applications

Get-MgServicePrincipal -Filter "appId eq '094cc3b3-b546-419f-98fc-bffb5a038cbb'"


$objectId ="66d7a8e4-c6be-4f2d-ba7a-c40f4bf3af37"

    $AdApplication = Get-AzADApplication -ObjectId $ObjectId
    $AppName = $AdApplication.DisplayName    
    
    #Write-Host -ForegroundColor Yellow "SetRedirectURI[16] Adding redirect URIs for $AppName with $ObjectId";
    $redirectUris = @()
    $WebAppUrl = "https://$AppName.azurewebsites.us"
    if ($redirectUris -notcontains "$WebAppUrl") {
        $redirectUris += "$WebAppUrl"   
        #Write-Host "SetRedirectURI[21] Adding $WebAppUrl to redirect URIs";
    }
      
    $accesstoken = (Get-AzAccessToken -Resource "https://graph.microsoft.us/").Token
    
    $header = @{
        'Content-Type' = 'application/json'
        'Authorization' = 'Bearer ' + $accesstoken
    }

    $tags += "ShowApp"

    $body = @{
        'spa' = @{
            'redirectUris' = $redirectUris
        }
    } 
        
    $bodyJson = ConvertTo-Json $body

    Invoke-RestMethod -Method Patch -Uri "https://graph.microsoft.us/v1.0/applications/$ObjectId" -Headers $header -Body $bodyJson
  