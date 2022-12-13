#retrieve the user-assigned managed identity and assign to it the required RBAC role, scoped to the key vault. 
$RoleAssignmentName = "Key Vault Crypto Service Encryption User"
$CustomRole = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.Name -eq $RoleAssignmentName}
$CustomRoleId = $CustomRole.Id
#$SolutionName =''
#$managedUserName = 'id-$SolutionName'

$managedUserName = 'id-wedtransfer-test'
Write-Host -ForegroundColor Green "StartBicepDeploy[183] `$managedUserName=`"$managedUserName`""

$ResourceGroupName = 'rg-wed-transfer-test'
$userIdentity = Get-AzUserAssignedIdentity -Name $managedUserName -ResourceGroupName $ResourceGroupName


$principalId = $userIdentity.PrincipalId
Write-Host -ForegroundColor Green "StartBicepDeploy[185] `$principalId=`"$principalId`""

$keyvaultName = 'kv-WedTransfer-test'
Write-Host -ForegroundColor Green "StartBicepDeploy[] `$keyvaultName=`"$keyvaultName`""

$keyvault = Get-AzKeyVault -Name $keyvaultName 
New-AzRoleAssignment -ObjectId $principalId `
    -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
    -Scope $keyVault.ResourceId