#https://geekshangout.com/microsoft-graph-and-invoke-restmethod-powershell/

# Connecting to Azure Parameters
$tenantID = "<insert your tenant ID>"
$applicationID = "<insert your application ID>"
$clientKey = "<insert the value of you created secret>"
 
# Authenticate to Microsoft Grpah
 Write-Host "Authenticating to Microsoft Graph via REST method"
 
$url = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$resource = "https://graph.microsoft.com/"
$restbody = @{
         grant_type    = 'client_credentials'
         client_id     = $applicationID
         client_secret = $clientKey
         resource      = $resource
}
     
 # Get the return Auth Token
$token = Invoke-RestMethod -Method POST -Uri $url -Body $restbody
     
# Set the baseurl to MS Graph-API (BETA API)
$baseUrl = 'https://graph.microsoft.com/beta'
         
# Pack the token into a header for future API calls
$header = @{
          'Authorization' = "$($Token.token_type) $($Token.access_token)"
         'Content-type'  = "application/json"
}
 
# Define the UPN for the user we want to get userPurpose for
$userid = 'test.user@mydomain.com'
 
# Build the Base URL for the API call
$url = $baseUrl + '/users/' + $userid + '/mailboxsettings/userpurpose'
  
# Call the REST-API
$userPurpose = Invoke-RestMethod -Method GET -headers $header -Uri $url
 
write-host $userPurpose.value