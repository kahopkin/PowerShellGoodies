#GetAzureContext.p1

$AzureContext = Get-AzContext 

$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId        
$TenantName = $SubscriptionTenant.Name
$TenantId = $SubscriptionTenant.Id

$SubscriptionId = $AzureContext.Subscription.Id
$SubscriptionName = $AzureContext.Subscription.Name

$CloudEnvironment = $AzureContext.Environment.Name    
$ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority + $DeployInfo.TenantId;        
$AzureKeyVaultDnsSuffix = $AzureContext.Environment.AzureKeyVaultDnsSuffix
$GraphUrl = $AzureContext.Environment.GraphUrl 
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

Write-Host -ForegroundColor Magenta "`n GetAzureContext[39]:: "
Write-Host -ForegroundColor Yellow "`$ActiveDirectoryAuthority=`"$ActiveDirectoryAuthority`""
Write-Host -ForegroundColor Green "`$GraphUrl=`"$GraphUrl`""    
#Write-Host -ForegroundColor Cyan "`$website=`"$website`""
#Write-Host -ForegroundColor DarkYellow "`$TenantId=`"$TenantId`""
#Write-Host -ForegroundColor Yellow "`$CurrUserPrincipalName=`"$CurrUserPrincipalName`""

$Caller= "`n GetAzureContext[82] AzureContext::"
$ObjectName = "AzureContext"
#$FilePath = $LogsFolderPath + $ObjectName  + ".ps1"        
#PrintObjectAsVars -Object $AzureContext -Caller $Caller -ObjectName $ObjectName #-FilePath $FilePath
#PrintObjectAsVars -Object $AzureContext -Caller $Caller -FilePath $FilePath

