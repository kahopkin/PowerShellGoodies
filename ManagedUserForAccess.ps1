
<#
Use a user-assigned managed identity to authorize access
https://docs.microsoft.com/en-us/azure/storage/common/customer-managed-keys-configure-existing-account?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&tabs=powershell
To authorize access to the key vault with a user-assigned managed identity, you'll need 
the resource ID and principal ID of the user-assigned managed identity. 
Call Get-AzUserAssignedIdentity to get the user-assigned 
managed identity and assign it to a variable that you'll reference in subsequent steps:
#>
$userIdentity = Get-AzUserAssignedIdentity -Name <user-assigned-identity> -ResourceGroupName <resource-group>
$principalId = $userIdentity.PrincipalId