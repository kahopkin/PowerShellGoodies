<#
Make API calls using the Microsoft Graph SDKs
https://learn.microsoft.com/en-us/graph/sdks/create-requests?context=graph%2Fapi%2Fbeta&view=graph-rest-beta&tabs=PowerShell
#>

#reate a request object and then run the GET method on the request.
# GET https://graph.microsoft.com/v1.0/users/{user-id}

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"

$user = Get-MgUser -UserId $userId


#customize the request to include the $select query parameter with a list of properties.
# GET https://graph.microsoft.com/v1.0/users/{user-id}?$select=displayName,jobTitle

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"

# The -Property parameter causes a $select parameter to be included in the request
$user = Get-MgUser -UserId $userId -Property DisplayName,JobTitle

<#
Retrieve a list of entities
Retrieving a list of entities is similar to retrieving a single entity except there a number of other options for configuring the request. 
The $filter query parameter can be used to reduce the result set to only those rows that match the provided condition. 
The $orderBy query parameter will request that the server provide the list of entities sorted by the specified properties.
Advanced query capabilities on Azure AD directory objects.:https://learn.microsoft.com/en-us/graph/aad-advanced-queries
#>

# GET https://graph.microsoft.com/v1.0/users/{user-id}/messages?$select=subject,sender&
# $filter=<some condition>&orderBy=receivedDateTime

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"

# -Sort is equivalent to $orderby
# -Filter is equivalent to $filter
$messages = Get-MgUserMessage -UserId $userId -Property Subject,Sender `
-Sort ReceivedDateTime -Filter "some condition"

<#
Access an item of a collection
For SDKs that support a fluent style, collections of entities can be accessed using an array index. 
For template-based SDKs, it is sufficient to embed the item identifier in the path segment following the collection. 
For PowerShell, identifiers are passed as parameters.
#>

# GET https://graph.microsoft.com/v1.0/users/{user-id}/messages/{message-id}

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"
$messageId = "AQMkAGUy.."

$message = Get-MgUserMessage -UserId $userId -MessageId $messageId


<#
Use $expand to access related entities
You can use the $expand filter to request a related entity, 
or collection of entities, at the same time that you request the main entity.
#>

# GET https://graph.microsoft.com/v1.0/users/{user-id}/messages?$expand=attachments

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"
$messageId = "AQMkAGUy.."

# -ExpandProperty is equivalent to $expand
$message = Get-MgUserMessage -UserId $userId -MessageId $messageId -ExpandProperty Attachments

<#
Delete an entity
Delete requests are constructed in the same way as requests to retrieve an entity,
but use a DELETE request instead of a GET.
#>
# DELETE https://graph.microsoft.com/v1.0/users/{user-id}/messages/{message-id}

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"
$messageId = "AQMkAGUy.."

Remove-MgUserMessage -UserId $userId -MessageId $messageId


<#
Make a POST request to create a new entity
For SDKs that support a fluent style, new items can be added to collections with an Add method. 
For template-based SDKs, the request object exposes a post method. 
For PowerShell, a New-* command is available that accepts parameters that map to the entity to add. 
The created entity is usually returned from the call.
#>
# POST https://graph.microsoft.com/v1.0/users/{user-id}/calendars

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"

New-MgUserCalendar -UserId $userId -Name "Volunteer"

<#
Updating an existing entity with PATCH
Most updates in Microsoft Graph are performed using a PATCH method and therefore it is only necessary 
to include the properties that you want to change in the object you pass.
#>
# PATCH https://graph.microsoft.com/v1.0/teams/{team-id}

$teamId = "71766077-aacc-470a-be5e-ba47db3b2e88"

Update-MgTeam -TeamId $teamId -FunSettings @{ AllowGiphy = $true; GiphyContentRating = "strict" }

<#
Use HTTP headers to control request behavior
You can use a Header() function to attach custom headers to a request. 
For PowerShell, adding headers is only possible with the Invoke-GraphRequest method. 
A number of Microsoft Graph scenarios use custom headers to adjust the behavior of the request.
#>
# GET https://graph.microsoft.com/v1.0/users/{user-id}/events

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"
$requestUri = "/v1.0/users/" + $userId + "/events"

$events = Invoke-GraphRequest -Method GET -Uri $requestUri `
-Headers @{ Prefer = "outlook.timezone=""Pacific Standard Time""" }

<#
Provide custom query parameters
For SDKs that support a fluent style, you can provide custom query parameter values by using a list of QueryOptions objects. 
For template-based SDKs, the parameters are URL-encoded and added to the request URI. 
For PowerShell and Go, defined query parameters for a given API are exposed as parameters to the corresponding command.
#>
# GET https://graph.microsoft.com/v1.0/users/{user-id}/calendars/{calendar-id}/calendarView

$userId = "71766077-aacc-470a-be5e-ba47db3b2e88"
$calendarId = "AQMkAGUy..."

$events = Get-MgUserCalendarView -UserId $userId -CalendarId $calendarId `
-StartDateTime "2020-08-31T00:00:00Z" -EndDateTime "2020-09-02T00:00:00Z"

<#

#>


<#

#>


<#

#>


<#

#>


<#

#>


<#

#>