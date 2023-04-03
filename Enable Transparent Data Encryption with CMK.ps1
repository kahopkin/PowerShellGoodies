<#
PowerShell and Azure CLI: Enable Transparent Data Encryption with customer-managed key from Azure Key Vault

https://learn.microsoft.com/en-us/azure/azure-sql/database/transparent-data-encryption-byok-configure?view=azuresql&tabs=azure-powershell
Prerequisites for PowerShell:
- You must have an Azure subscription and be an administrator on that subscription.
- [Recommended but Optional] Have a hardware security module (HSM) or local key store for creating a local copy of the TDE Protector key material.
- You must have Azure PowerShell installed and running.
- Create an Azure Key Vault and Key to use for TDE.

The key vault must have the following property to be used for TDE:
- soft-delete and purge protection

The key must have the following attributes to be used for TDE:
- No expiration date
- Not disabled
- Able to perform get, wrap key, unwrap key operations
#>

$ResourceGroupName = ""
$KeyVaultName = ""
#If you have an existing server, use the following to add an Azure Active Directory (Azure AD) identity to your server:
$server = Set-AzSqlServer `
            -ResourceGroupName <SQLDatabaseResourceGroupName> `
            -ServerName <LogicalServerName> `
            -AssignIdentity

#If you are creating a server, use the New-AzSqlServer cmdlet with the tag -Identity to add an Azure AD identity during server creation:
$server = New-AzSqlServer `
            -ResourceGroupName <SQLDatabaseResourceGroupName> `
            -Location <RegionName> `
            -ServerName <LogicalServerName> `
            -ServerVersion "12.0" `
            -SqlAdministratorCredentials <PSCredential> `
            -AssignIdentity

#Grant Key Vault permissions to your server
Set-AzKeyVaultAccessPolicy `
    -VaultName <KeyVaultName> `
    -ObjectId $server.Identity.PrincipalId `
    -PermissionsToKeys get, wrapKey, unwrapKey


#Add the Key Vault key to the server and set the TDE Protector
<#
- Use the Get-AzKeyVaultKey cmdlet to retrieve the key ID from key vault
- Use the Add-AzSqlServerKeyVaultKey cmdlet to add the key from the Key Vault to the server.
- Use the Set-AzSqlServerTransparentDataEncryptionProtector cmdlet to set the key as the TDE protector for all server resources.
- Use the Get-AzSqlServerTransparentDataEncryptionProtector cmdlet to confirm that the TDE protector was configured as intended.

The combined length for the key vault name and key name cannot exceed 94 characters.
#>
# add the key from Key Vault to the server
Add-AzSqlServerKeyVaultKey `
    -ResourceGroupName <SQLDatabaseResourceGroupName> `
    -ServerName <LogicalServerName> `
    -KeyId <KeyVaultKeyId>

# set the key as the TDE protector for all resources under the server
Set-AzSqlServerTransparentDataEncryptionProtector `
    -ResourceGroupName <SQLDatabaseResourceGroupName> `
    -ServerName <LogicalServerName> `
    -Type AzureKeyVault `
    -KeyId <KeyVaultKeyId>

# confirm the TDE protector was configured as intended
Get-AzSqlServerTransparentDataEncryptionProtector `
    -ResourceGroupName <SQLDatabaseResourceGroupName> `
    -ServerName <LogicalServerName>

#Turn on TDE
Set-AzSqlDatabaseTransparentDataEncryption `
    -ResourceGroupName <SQLDatabaseResourceGroupName> `
    -ServerName <LogicalServerName> `
    -DatabaseName <DatabaseName> `
    -State "Enabled"

#Check the encryption state and encryption activity
# get the encryption state of the database
Get-AzSqlDatabaseTransparentDataEncryption `
    -ResourceGroupName <SQLDatabaseResourceGroupName> `
    -ServerName <LogicalServerName> `
    -DatabaseName <DatabaseName> 

#Useful PowerShell cmdlets
#Use the Set-AzSqlDatabaseTransparentDataEncryption cmdlet to turn off TDE.
Set-AzSqlDatabaseTransparentDataEncryption `
    -ServerName <LogicalServerName> `
    -ResourceGroupName <SQLDatabaseResourceGroupName> `
    -DatabaseName <DatabaseName> `
    -State "Disabled"

#Use the Get-AzSqlServerKeyVaultKey cmdlet to return the list of Key Vault keys added to the server.
# KeyId is an optional parameter, to return a specific key version
Get-AzSqlServerKeyVaultKey `
    -ServerName <LogicalServerName> `
    -ResourceGroupName <SQLDatabaseResourceGroupName>

#Use the Remove-AzSqlServerKeyVaultKey to remove a Key Vault key from the server.
# the key set as the TDE Protector cannot be removed
Remove-AzSqlServerKeyVaultKey `
    -KeyId <KeyVaultKeyId> `
    -ServerName <LogicalServerName> `
    -ResourceGroupName <SQLDatabaseResourceGroupName>