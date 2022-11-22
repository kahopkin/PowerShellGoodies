#https://www.techguy.at/add-an-owner-to-an-azure-application-registration-with-powershell-and-ms-graph-api/

#Graph API Details
$GRAPHAPI_clientID = 'yourClientID'
$GRAPHAPI_tenantId = 'yourTenantID'
$GRAPHAPI_Clientsecret = 'yourSecret'

$GRAPHAPI_BaseURL = "https://graph.microsoft.com/v1.0"

#Enter Azure App Details
$AzureAppObjectID = "5b8d1a75-6b99-4af5-b1b7-0127b6c39304"
$NewOwnerUPN = "michael.seidl@au2mator.com"

#Auth MS Graph API and Get Header
$GRAPHAPI_tokenBody = @{  
    Grant_Type    = "client_credentials"  
    Scope         = "https://graph.microsoft.com/.default"  
    Client_Id     = $GRAPHAPI_clientID  
    Client_Secret = $GRAPHAPI_Clientsecret  
}   
$GRAPHAPI_tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$GRAPHAPI_tenantId/oauth2/v2.0/token" -Method POST -Body $GRAPHAPI_tokenBody  
$GRAPHAPI_headers = @{
    "Authorization" = "Bearer $($GRAPHAPI_tokenResponse.access_token)"
    "Content-type"  = "application/json"
}


#Get USer ID from UPN
$GetUserID_Params = @{
    Method = "Get"
    Uri    = "$GRAPHAPI_BaseURL/users/$NewOwnerUPN"
    header = $GRAPHAPI_headers
}


$Result = Invoke-RestMethod @GetUserID_Params

#$Result.id #UserID


#Set new Owner
$SetRegAppOwner_Body = @"
    {
        "@odata.id" : "https://graph.microsoft.com/v1.0/directoryObjects/$($Result.id)"
    }
"@


$SetRegAppOwner_Params = @{
    Method = "POST"
    Uri    = "$GRAPHAPI_BaseURL/applications/$AzureAppObjectID/owners/`$ref"
    header = $GRAPHAPI_headers
    body = $SetRegAppOwner_Body
}


Invoke-RestMethod @SetRegAppOwner_Params