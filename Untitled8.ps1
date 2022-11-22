$AzureContext = Get-AzContext
$Subscription = $AzureContext.Subscription.Name
$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId   
$TenantName = $SubscriptionTenant.Name
$TenantId = $SubscriptionTenant.Id

$AzureContext.Environment.ActiveDirectoryAuthority
#https://login.microsoftonline.us/

$AzureContext.Environment.StorageEndpointSuffix
#core.usgovcloudapi.net

$AzureContext.Environment.AzureKeyVaultDnsSuffix
#vault.usgovcloudapi.net

$AzureContext.Environment.AzureKeyVaultServiceEndpointResourceId
https://vault.usgovcloudapi.net
#https://vault.usgovcloudapi.net

$AzureContext.Environment.GraphEndpointResourceId
#https://graph.windows.net/

$AzureContext.Environment.GraphUrl
#https://graph.windows.net/
