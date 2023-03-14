<#
Configure cross-tenant customer-managed keys for a new storage account
https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-cross-tenant-new-account?tabs=azure-powershell

#>

#Configure a user-assigned managed identity as a federated identity credential on the application, 
#so that it can impersonate the identity of the application.

New-AzADAppFederatedCredential -ApplicationObjectId $multiTenantApp.Id `
    -Name "MyFederatedIdentityCredential" `
    -Audience "api://AzureADTokenExchange" `
    -Issuer "https://login.microsoftonline.com/<tenant-id>/v2.0" `
    -Subject $userIdentity.PrincipalId `
    -Description "Federated Identity Credential for CMK"

<#
The customer grants the service provider's app access to the key in the key vault
The following steps are performed by the customer in the customer's tenant Tenant2
#>

$customerTenantId="<customer-tenant-id>"
$customerSubscriptionId="<customer-subscription-id>"

# Sign in to Azure in the customer's tenant.
Connect-AzAccount -Tenant $customerTenantId
# Set the context to the customer's subscription.
Set-AzContext -Subscription $customerSubscriptionId

<#
The customer installs the service provider application in the customer tenant
Once you receive the application ID of the service provider's multi-tenant application, 
install the application in your tenant, Tenant2, by creating a service principal.
#>

$customerRgName="<customer-resource-group>"
$customerLocation="<location>"
$multiTenantAppId="<multi-tenant-app-id>" # appId value from Tenant1 

# Create a resource group in the customer's subscription.
New-AzResourceGroup -Location $customerLocation -ResourceGroupName $customerRgName

# Create the service principal with the registered app's application ID (client ID).
$servicePrincipal = New-AzADServicePrincipal -ApplicationId $multiTenantAppId

<#
To create the key vault, 
the customer's account must be assigned the 
Key Vault Contributor role 
or another role that permits creation of a key vault.
#>

$kvName="<key-vault>"

$kv = New-AzKeyVault -Location $customerLocation `
    -Name $kvName `
    -ResourceGroupName $customerRgName `
    -SubscriptionId $customerSubscriptionId `
    -EnablePurgeProtection `
    -EnableRbacAuthorization

<#
Assign the Key Vault Crypto Officer role to a user account. 
This step ensures that the user can create the key vault and encryption keys. 
The example below assigns the role to the current signed-in user.
#>

$currentUserObjectId = (Get-AzADUser -SignedIn).Id

New-AzRoleAssignment -RoleDefinitionName "Key Vault Crypto Officer" `
    -Scope $kv.ResourceId `
    -ObjectId $currentUserObjectId

<#
To create the encryption key, 
the user's account must be assigned the Key Vault Crypto Officer role or another role that permits creation of a key.
#>
$keyName="<key-name>"

Add-AzKeyVaultKey -Name $keyName `
    -VaultName $kvName `
    -Destination software


<#
Assign the Azure RBAC role Key Vault Crypto Service Encryption User to the 
service provider's registered application, 
via the service principal that you created earlier, so that it can access the key vault.
#>
New-AzRoleAssignment -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
    -Scope $kv.ResourceId `
    -ObjectId $servicePrincipal.Id



#Create a new storage account encrypted with a key from a different tenant
<#
You must use an existing user-assigned managed identity to authorize access to the key vault 
when you configure customer-managed keys while creating the storage account. 
The user-assigned managed identity must have appropriate permissions to access the key vault
#>
$accountName = "<account-name>"
$kvUri = "<key-vault-uri>"
$keyName = "<keyName>"
$location = "<location>"
$multiTenantAppId = "<application-id>" # appId value from multi-tenant app

$userIdentity = Get-AzUserAssignedIdentity -Name <user-assigned-identity> -ResourceGroupName $rgName

New-AzStorageAccount -ResourceGroupName $rgName `
    -Name $accountName `
    -Kind StorageV2 `
    -SkuName Standard_LRS `
    -Location $location `
    -UserAssignedIdentityId $userIdentity.Id `
    -IdentityType SystemAssignedUserAssigned `
    -KeyName $keyName `
    -KeyVaultUri $kvUri `
    -KeyVaultUserAssignedIdentityId $userIdentity.Id `
    -KeyVaultFederatedClientId $multiTenantAppId


# revoke customer-managed keys by removing the key vault access policy
Remove-AzKeyVaultAccessPolicy -VaultName $keyVault.VaultName `
    -ObjectId $storageAccount.Identity.PrincipalId `

<#When you disable customer-managed keys, 
your storage account is once again encrypted with Microsoft-managed keys.
#>
Set-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName `
    -AccountName $storageAccount.StorageAccountName `
    -StorageEncryption




