<#
UpdateApplication
https://learn.microsoft.com/en-us/graph/api/application-update?view=graph-rest-1.0&tabs=powershell#example
#>
#Import-Module Microsoft.Graph.Applications

$GraphConnectionStatus = Connect-MgGraph -Environment USGov -Scopes "Application.Read.All Application.ReadWrite.All Directory.Read.All User.Read" 

$MgContext = Get-MgContext
#this will be the id for Microsoft Graph PowerShell Ent App
$ClientId = $MgContext.ClientId

#logged in user
$Account = $MgContext.Account

#Scopes: Scopes consented to
$Scopes = $MgContext.Scopes

Get-MgContext | Select -ExpandProperty Scopes


$APIAppRegAppId="0f803265-28e7-472f-8fb9-86e0c7d40581"
#objID
#$applicationId = "d71aa82b-df1e-4b76-8d36-38cbe82259fe"

$Query = "AppId eq `'" + $APIAppRegAppId + "`'"
Write-Host -ForegroundColor Yellow "`$Query=`"$Query`""

$MyApp = Get-MgApplication -Filter $Query 
#| Format-List Id, DisplayName, AppId, SignInAudience, PublisherDomain



<#$params = @{
	DisplayName = "New display name"
}
#>
#"accessTokenAcceptedVersion": 2,

$params = @{
	accessTokenAcceptedVersion = "2"
}

Update-MgApplication -ApplicationId $MyApp.Id -BodyParameter $params


 
Update-MgApplication -ApplicationId $APIAppRegAppId -BodyParameter $params

<#
apiApplication resource type

Namespace: microsoft.graph

{
  "acceptMappedClaims": true,
  "knownClientApplications": ["Guid"],
  "oauth2PermissionScopes": [{"@odata.type": "microsoft.graph.permissionScope"}],
  "preAuthorizedApplications": [{"@odata.type": "microsoft.graph.preAuthorizedApplication"}],
  "requestedAccessTokenVersion": 2
}
#>

$uri = "https://graph.microsoft.com/v1.0/applications/<app objectId>"
az rest --method PATCH --uri '$uri' --headers 'Content-Type=application/json' --body '{\""api\"":{\""requestedAccessTokenVersion\"":2}}'



#https://learn.microsoft.com/en-us/graph/sdks/create-requests?context=graph%2Fapi%2Fbeta&view=graph-rest-beta&tabs=PowerShell
<#
You can use a Header() function to attach custom headers to a request. 
For PowerShell, adding headers is only possible with the Invoke-GraphRequest method. 
A number of Microsoft Graph scenarios use custom headers to adjust the behavior of the request.
 GET https://graph.microsoft.com/v1.0/users/{user-id}/events
#>

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"
$requestUri = "/v1.0/users/" + $userId + "/events"

$events = Invoke-GraphRequest `
    -Method GET -Uri $requestUri `
    -Headers @{ Prefer = "outlook.timezone=""Pacific Standard Time""" }


<#
provide custom query parameter values by using a list of QueryOptions objects. 
For template-based SDKs, the parameters are URL-encoded and added to the request URI. 
For PowerShell and Go, defined query parameters for a given API are exposed as parameters to the corresponding command.
#>

# GET https://graph.microsoft.com/v1.0/users/{user-id}/calendars/{calendar-id}/calendarView

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"
$calendarId = "AQMkAGUy..."

$events = Get-MgUserCalendarView `
    -UserId $userId -CalendarId $calendarId `
    -StartDateTime "2020-08-31T00:00:00Z" `
    -EndDateTime "2020-09-02T00:00:00Z"


