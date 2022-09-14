<#
KeyVaultStuff
https://docs.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-existing-account?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&tabs=powershell
#To create a new key vault with PowerShell, install version 2.0.0 or later of the Az.KeyVault
#https://www.powershellgallery.com/packages/Az.KeyVault/2.0.0
#>

Install-Module -Name Az.KeyVault -RequiredVersion 2.0.0

#creates a new key vault with both soft delete and purge protection enabled. 
$keyVault = New-AzKeyVault -Name $keyVaultName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -EnablePurgeProtection

#add a key to the key vault.
$key = Add-AzKeyVaultKey -VaultName $keyVault.VaultName `
    -Name $keyName `
    -Destination 'Software'


<#
When you enable customer-managed keys for an existing storage account, 
you must specify a managed identity that will be used to authorize access to the key vault that contains the key. 
The managed identity must have permissions to access the key in the key vault.

The managed identity that authorizes access to the key vault may be either 
a user-assigned or system-assigned managed identity.
#>
#Choose a managed identity to authorize access to the key vault
#Use a user-assigned managed identity to authorize access:
$userIdentity = Get-AzUserAssignedIdentity -Name $userAssignedIdentityName -ResourceGroupName $resourceGroupName
$principalId = $userIdentity.PrincipalId

#Use a system-assigned managed identity to authorize access:
<#
A system-assigned managed identity
 is associated with an instance of an Azure service, 
 in this case an Azure Storage account.

 Only existing storage accounts can use a system-assigned identity to authorize access to the key vault. 
 New storage accounts must use a user-assigned identity, 
 if customer-managed keys are configured on account creation.
#>

#To assign a system-assigned managed identity to your storage account:
$storageAccount = Set-AzStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $mainStAccountName `
    -AssignIdentity

<#
Next, get the principal ID for the system-assigned managed identity, 
and save it to a variable. 
You'll need this value in the next step to create the key vault access policy:
#>
$principalId = $storageAccount.Identity.PrincipalId

<#
The next step is to configure the key vault access policy. 
The key vault access policy grants permissions to the managed identity 
that will be used to authorize access to the key vault.
#>
Set-AzKeyVaultAccessPolicy `
    -VaultName $keyVault.VaultName `
    -ObjectId $principalId `
    -PermissionsToKeys wrapkey,unwrapkey,get


#Change the key:
#https://docs.microsoft.com/en-us/powershell/module/az.storage/set-azstorageaccount?view=azps-8.3.0
#call Set-AzStorageAccount and provide the new key name and version. 
#If the new key is in a different key vault, then you must also update the key vault URI.
