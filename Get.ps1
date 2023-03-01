& "$PSScriptRoot\UtilityFunctions.ps1"

$AzureContext = Get-AzContext 

$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId        
$TenantName = $SubscriptionTenant.Name
$TenantId = $SubscriptionTenant.Id

$SubscriptionId = $AzureContext.Subscription.Id
$SubscriptionName = $AzureContext.Subscription.Name

$CloudEnvironment = $AzureContext.Environment.Name    
$ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority + $DeployInfo.TenantId;        
$AzureKeyVaultDnsSuffix = $AzureContext.Environment.AzureKeyVaultDnsSuffix
$GraphUrl = $AzureContext.Environment.GraphUrl + "v1.0/me";
$ManagementPortalUrl = $AzureContext.Environment.ManagementPortalUrl
$ServiceManagementUrl = $AzureContext.Environment.ServiceManagementUrl
$StorageEndpointSuffix = $AzureContext.Environment.StorageEndpointSuffix
   
$CurrUser = Get-AzADUser -SignedIn
if($CurrUser.DisplayName -match " ")
{
	$firstSpace = ($CurrUser.DisplayName).IndexOf(" ")
	$CurrUserFirst = ($CurrUser.DisplayName).split(" ")[0]
}
else
{
	$firstSpace = -1
	$CurrUserFirst = $CurrUser.DisplayName
}

$CurrUserName = $CurrUser.DisplayName

$CurrUserPrincipalName = $CurrUser.UserPrincipalName
$CurrUserId = $CurrUser.Id              

$MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();



$Caller= "`n InitiateScripts.SetDeployInfoObj[383] DeployObject::"
#$ObjectName = $DeployObject.Solution + "AppObj"
$ObjectName = "DeployInfo"
$FilePath = $LogsFolderPath + $ObjectName  + ".ps1"        
#PrintObjectAsVars -Object $DeployObject -Caller $Caller -ObjectName $ObjectName -FilePath $FilePath
PrintObjectAsVars -Object $DeployObject -Caller $Caller -FilePath $FilePath