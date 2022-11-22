# Only Az.Accounts is needed
#Connect-AzAccount -Environment AzureUSGovernment

#create bearer token
createBearerToken -targetEndPoint "MSGraphAPI"

# https://docs.microsoft.com/en-us/graph/api/user-list-ownedobjects?view=graph-rest-1.0&tabs=http
$currentTask = "Getting all my AzureAD owned applications"
Write-Host "$currentTask"
$uri = "$(($htAzureEnvironmentRelatedUrls).($checkContext.Environment.Name).MSGraphUrl)/beta/me/ownedObjects"
$method = "GET"
$requestAllAzureAdOwnedObjects = ((AzAPICall -uri $uri -method $method -currentTask $currentTask))
$aadOwnedApplications = $requestAllAzureAdOwnedObjects | Where-Object { $_."@odata.type" -match "application" }

# https://docs.microsoft.com/en-us/graph/api/application-list-owners?view=graph-rest-1.0&tabs=http
$currentTask = "Getting all AzureAD application owner of specific application"
Write-Host "$currentTask"
$uri = "$(($htAzureEnvironmentRelatedUrls).($checkContext.Environment.Name).MSGraphUrl)/beta/applications/<AzureAD Application Object ID>/owners" #AzureAD Application Object ID
$method = "GET"
$requestAllAzureAdOwnerOfSpecificApp = ((AzAPICall -uri $uri -method $method -currentTask $currentTask))
$requestAllAzureAdOwnerOfSpecificApp.displayName