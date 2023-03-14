<#
Configure customer-managed keys for an existing account
https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-existing-account?tabs=azure-powershell
#>

#To assign a system-assigned managed identity to your storage account
$accountName = "<storage-account>"

$storageAccount = Set-AzStorageAccount -ResourceGroupName $rgName `
    -Name $accountName `
    -AssignIdentity

#Next assign to the system-assigned managed identity the required RBAC role, scoped to the key vault

$principalId = $storageAccount.Identity.PrincipalId

New-AzRoleAssignment -ObjectId $storageAccount.Identity.PrincipalId `
    -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
    -Scope $keyVault.ResourceId

<#
You can use either a system-assigned or user-assigned managed identity to authorize access to the key vault 
when you configure customer-managed keys for an existing storage account.

To configure customer-managed keys for an existing account with automatic updating of the key version with PowerShell, 
install the Az.Storage module, version 2.0.0 or later.
#>

#update the storage account's encryption settings'
$accountName = "<storage-account>"

Set-AzStorageAccount -ResourceGroupName $rgName `
    -AccountName $accountName `
    -KeyvaultEncryption `
    -KeyName $key.Name `
    -KeyVersion "" `
    -KeyVaultUri $keyVault.VaultUri

<#
to manually update the key version, 
then explicitly specify the version at the time that you configure encryption with customer-managed keys.
#>
$accountName = "<storage-account>"

Set-AzStorageAccount `
    -ResourceGroupName $rgName `
    -AccountName $accountName `
    -KeyvaultEncryption `
    -KeyName $key.Name `
    -KeyVersion $key.Version `
    -KeyVaultUri $keyVault.VaultUri

#Revoking a customer-managed key removes the association between the storage account and the key vault.
Remove-AzKeyVaultAccessPolicy -VaultName $keyVault.VaultName `
    -ObjectId $storageAccount.Identity.PrincipalId `

#When you disable customer-managed keys, your storage account is once again encrypted with Microsoft-managed keys.
Set-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName `
    -AccountName $storageAccount.StorageAccountName `
    -StorageEncryption
