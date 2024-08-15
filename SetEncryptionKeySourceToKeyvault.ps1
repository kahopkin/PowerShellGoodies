
<#
#from::
https://learn.microsoft.com/en-us/powershell/module/az.storage/set-azstorageaccount?view=azps-9.7.1#examples
#https://learn.microsoft.com/en-us/powershell/module/az.storage/set-azstorageaccount?view=azps-9.1.0#examples
Example 5: Set Encryption KeySource to Keyvault
#>

Set-AzStorageAccount -ResourceGroupName "MyResourceGroup" -Name "mystorageaccount" -AssignIdentity
$account = Get-AzStorageAccount -ResourceGroupName "MyResourceGroup" -Name "mystorageaccount"

$keyVault = New-AzKeyVault -VaultName "MyKeyVault" -ResourceGroupName "MyResourceGroup" -Location "EastUS2"

$key = Add-AzKeyVaultKey -VaultName "MyKeyVault" -Name "MyKey" -Destination 'Software'

Set-AzKeyVaultAccessPolicy -VaultName "MyKeyVault" -ObjectId $account.Identity.PrincipalId -PermissionsToKeys wrapkey,unwrapkey,get

# In case to enable key auto rotation, don't set KeyVersion
Set-AzStorageAccount -ResourceGroupName "MyResourceGroup" -Name "mystorageaccount" -KeyvaultEncryption -KeyName $key.Name -KeyVersion $key.Version -KeyVaultUri $keyVault.VaultUri

# In case to enable key auto rotation after set keyvault properties with KeyVersion, can update account by set KeyVersion to empty
Set-AzStorageAccount -ResourceGroupName "MyResourceGroup" -Name "mystorageaccount" -KeyvaultEncryption -KeyName $key.Name -KeyVersion "" -KeyVaultUri $keyVault.VaultUri


