#GetAzureADToken
#https://github.com/Gordonby/Snippets/blob/master/Powershell/Get-Graph-Tokens.ps1

Function GetAzureADToken
{
    param(
        [String] $tenantId
        ,[String] $clientId
        ,[String] $clientSecret
        ,[String] $resourceId = "https://graph.windows.net"
        ,[String] $ActiveDirectoryAuthority
        ,$AzureContext
    )
    $tenantId= "8a09f2d7-8415-4296-92b2-80bb4666c5fc"
    $clientId="82b383b1-1db1-41b1-ac50-be42e12f6eea"
    $clientSecret="~F9DDM8_K-EMzWHyWY-9.h325Pbmi1ctTW"
    $resourceId = "https://graph.windows.net"

    #$oauth2tokenendpointv1 = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    $oauth2tokenendpointv1 = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id +"/oauth2/token"
    $oauth2tokenendpointv1
    #$scope = [System.Web.HttpUtility]::UrlEncode($resourceId)
    $scope = [System.Web.HttpUtility]::UrlEncode($AzureContext.Environment.ActiveDirectoryAuthority)
    $scope
    $encSecret = [System.Web.HttpUtility]::UrlEncode($clientSecret)
    $encSecret
    $body = "grant_type=client_credentials&resource=$($scope)&client_id=$($clientId)&client_secret=$($encSecret)"
    $body
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv1 -Body $body -Method Post
    $res
    $authResult = $res.Content | ConvertFrom-Json
    $authResult
    return $authResult.access_token
}


Function GetAzureADToken
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
        [String] $tenantId
        ,[String] $clientId
        ,[String] $clientSecret
        ,[String] $scope
         ,$AzureContext
    )
    $tenantId= "8a09f2d7-8415-4296-92b2-80bb4666c5fc"
    $clientId="82b383b1-1db1-41b1-ac50-be42e12f6eea"
    $clientSecret="~F9DDM8_K-EMzWHyWY-9.h325Pbmi1ctTW"
    $scope = $AzureContext.Environment.GraphUrl + ".default"

    $oauth2tokenendpointv2 = $AzureContext.Environment.ActiveDirectoryAuthority +   $AzureContext.Tenant.Id + "/oauth2/v2.0/token"
    $scope = [System.Web.HttpUtility]::UrlEncode($scope)
    $encSecret = [System.Web.HttpUtility]::UrlEncode($clientSecret)
    $body = "grant_type=client_credentials&scope=$($scope)&client_id=$($clientId)&client_secret=$($encSecret)"
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv2 -Body $body -Method Post
    $authResult = $res.Content | ConvertFrom-Json
    return $authResult.access_token
}




Function GetMsGraphToken
{
    param(
        [String] $tenantId,
        [String] $clientId,
        [String] $clientSecret,
        [String] $scope = "https://graph.microsoft.com/.default"
    )
    $oauth2tokenendpointv2 = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

    $scope = [System.Web.HttpUtility]::UrlEncode($scope)
    $encSecret = [System.Web.HttpUtility]::UrlEncode($clientSecret)
    $body = "grant_type=client_credentials&scope=$($scope)&client_id=$($clientId)&client_secret=$($encSecret)"
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv2 -Body $body -Method Post
    $authResult = $res.Content | ConvertFrom-Json
    return $authResult.access_token
}