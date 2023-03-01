#GetAzureADToken
#https://github.com/Gordonby/Snippets/blob/master/Powershell/Get-Graph-Tokens.ps1


Function GetAzureADToken
{
    param(
        [String] $TenantId
        ,[String] $ClientId
        ,[String] $ClientSecret
        #,[String] $resourceId = "https://graph.windows.net"
        #,[String] $ActiveDirectoryAuthority
        #,$AzureContext
    )
    
    #Write-Host -ForegroundColor Magenta "`n GetAzureADToken[38]:: "
    #$oauth2tokenendpointv1 = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    
    $AzureContext = Get-AzContext    
    $oauth2tokenendpointv1 = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id +"/oauth2/token"    
    #Write-Host -ForegroundColor Yellow "`$oauth2tokenendpointv1 =`"$oauth2tokenendpointv1`""
        
    #$scope = [System.Web.HttpUtility]::UrlEncode($resourceId)
    $scope = [System.Web.HttpUtility]::UrlEncode($AzureContext.Environment.ActiveDirectoryAuthority)
    #Write-Host -ForegroundColor Cyan "`$scope =`"$scope`""

    $encSecret = [System.Web.HttpUtility]::UrlEncode($APIAppRegSecret)
    #Write-Host -ForegroundColor Cyan "`$encSecret =`"$encSecret`""

    $body = "grant_type=client_credentials&resource=$($scope)&client_id=$($ClientId)&client_secret=$($encSecret)"
    #Write-Host -ForegroundColor Green "`$body =`"$body`""
    
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv1 -Body $body -Method Post
    #Write-Host -ForegroundColor White "`$res =`"$res`""
    
    $authResult = $res.Content | ConvertFrom-Json
    #Write-Host -ForegroundColor Yellow "`$authResult=`"$authResult`""

    $accessToken = $authResult.access_token
    #return $authResult.access_token
    return $accessToken
}

#GetAzureADToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret

Function GetAzureADTokenWithAppReg
{
    param(
        [String] $tenantId,
        [String] $clientId,
        [String] $clientSecret,
        [String] $resourceId = "https://graph.windows.net"
    )
    $oauth2tokenendpointv1 = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    $scope = [System.Web.HttpUtility]::UrlEncode($resourceId)
    $encSecret = [System.Web.HttpUtility]::UrlEncode($clientSecret)
    $body = "grant_type=client_credentials&resource=$($scope)&client_id=$($clientId)&client_secret=$($encSecret)"
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv1 -Body $body -Method Post
    $authResult = $res.Content | ConvertFrom-Json
    return $authResult.access_token
}



Function GetMsGraphToken
{
    param(
        [String] $TenantId
        ,[String] $ClientId
        ,[String] $ClientSecret
        ,[String] $Scope
        # ,$AzureContext
    )
    Write-Host -ForegroundColor Magenta "[74]`n GetMsGraphToken"
    $AzureContext = Get-AzContext  
    $Scope = $AzureContext.Environment.GraphUrl + ".default"
    Write-Host -ForegroundColor Yellow "[77]`n `$Scope =`"$Scope`""

    $oauth2tokenendpointv2 = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id + "/oauth2/v2.0/token"
    Write-Host -ForegroundColor Cyan "[80]`n `$oauth2tokenendpointv2 =`"$oauth2tokenendpointv2`""
    
    $scope = [System.Web.HttpUtility]::UrlEncode($Scope)
    Write-Host -ForegroundColor Green "[83]`n `$Scope =`"$Scope`""
    
    $encSecret = [System.Web.HttpUtility]::UrlEncode($ClientSecret)
    Write-Host -ForegroundColor White "[86]`n `$encSecret =`"$encSecret`""
    
    $body = "grant_type=client_credentials&scope=$($Scope)&client_id=$($ClientId)&client_secret=$($encSecret)"
    Write-Host -ForegroundColor Yellow "[89]`n `$body =`"$body`""
    
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv2 -Body $body -Method Post
    #Write-Host -ForegroundColor Cyan "[91]`n `$res =`"$res`""
    
    $authResult = $res.Content | ConvertFrom-Json
    #Write-Host -ForegroundColor Green "[95]`n `$authResult =`"$authResult`""
    
    $accessToken = $authResult.access_token
    
    #return $authResult.access_token
    return $accessToken
}




Function GetMsGraphToken1
{
    param(
        [String] $TenantId
        ,[String] $ClientId
        ,[String] $ClientSecret
        ,[String] $scope = "https://graph.microsoft.com/.default"
    )
    $oauth2tokenendpointv2 = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

    $Scope = [System.Web.HttpUtility]::UrlEncode($Scope)
    $encSecret = [System.Web.HttpUtility]::UrlEncode($ClientSecret)
    $body = "grant_type=client_credentials&scope=$($Scope)&client_id=$($ClientId)&client_secret=$($encSecret)"
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv2 -Body $body -Method Post
    $authResult = $res.Content | ConvertFrom-Json
    return $authResult.access_token
}


<#

$CloudEnvironment="AzureUSGovernment"

$SubscriptionName="BMA-05: Dev"
$SubscriptionId="2b2df691-421a-476f-bfb6-7b7e008d6041"
$TenantName="BMTN Development"
$TenantId="f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0"
$ActiveDirectoryAuthority="https://login.microsoftonline.us/"
$AzureKeyVaultDnsSuffix="vault.usgovcloudapi.net"
$GraphUrl="https://graph.windows.net/"
$ManagementPortalUrl="https://portal.azure.us/"
$ServiceManagementUrl="https://management.core.usgovcloudapi.net/"
$StorageEndpointSuffix="core.usgovcloudapi.net"
$CurrUserName="Kat Hopkins (CA)"
$CurrUserFirst="Kat"
$CurrUserId="1f1f0e38-6e1c-4875-b7ea-80a526039896"
$CurrUserPrincipalName="kahopkins.ca@bmtndev.onmicrosoft.us"
$MyIP="141.156.182.114"

$CryptoEncryptRoleId="e147488a-f6f5-4113-8e2d-b22465e65bf6"
$ContributorRoleId="b24988ac-6180-42a0-ab88-20f7382dd24c"


$AppName="DtsPickupProd"
$Environment="Prod"
$Location="usgovvirginia"
$Solution="Pickup"
$ResourceGroupName="rg-dts-pickup-prod"
$RoleDefinitionId="RoleDefinitionId"
$RoleDefinitionFile="c:\github\dtp\Deploy\DPPStorageBlobDataRead.json"
$APIAppRegName="DtsPickupProdAPI"
$APIAppRegAppId="0f803265-28e7-472f-8fb9-86e0c7d40581"
$APIAppRegObjectId="d71aa82b-df1e-4b76-8d36-38cbe82259fe"
$APIAppRegSecret=".Xr.Tuf8Zl.LC2WsAv2vz6zAIi3Wm_FgG2"
$APIAppRegServicePrincipalId="f477df7c-04ee-4236-848e-241fc3cbd6d1"
$APIAppRegExists="True"
$ClientAppRegName="DtsPickupProd"
$ClientAppRegAppId="207a5236-095f-48d3-b96a-c3b6a5a1da75"
$ClientAppRegObjectId="d04207b0-7721-4d4e-90bc-f690db3775a9"
$ClientAppRegSecret=".-KU~jvW42.5pyxA5t3tK2OljcW_2DpRTo"
$ClientAppRegServicePrincipalId="896ababe-74f5-4c73-90d2-ae679f526e1d"
$ClientAppRegExists="True"

$AppName = $APIAppRegName
$website = $APIAppRegName + ".azurewebsites.us"

GetMsGraphToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret
#>