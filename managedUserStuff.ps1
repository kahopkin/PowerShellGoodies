Write-Host -ForegroundColor Cyan "================================================================================"    	
Write-Host -ForegroundColor Cyan $Message
Write-Host -ForegroundColor Cyan "================================================================================"


"================================================================================"								>> $DeployInfo.LogFile
$Message																										>> $DeployInfo.LogFile
"================================================================================"								>> $DeployInfo.LogFile

$managedUserPrincipalId = "9620fe85-adba-4ac6-b74b-efa37c78634d"
$managedUserName= "id-dts-pickup-prod"
$MainStSystemPrincipalId=""
$AuditStSystemPrincipalId=""
$keyVaultName="kv-dts-pickup-prod"
$keyVaultURI= "https://kv-dts-pickup-prod.vault.usgovcloudapi.net/"
$MainStName= "stdtspickupprod001"


$AzRoleName="Storage Blob Delegator"
$ResourceGroupName="rg-dts-pickup-prod"
$Scope=""
$UserName="DTS Users"
$UserId="8234e0ff-86ab-4b29-a45c-2b7c02920d8d"
$Scope="/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod"




Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName" -and $_.AppId -eq "$AppId"}
$Scope="/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.KeyVault/vaults/kv-dts-pickup-prod"

Get-AzSystemAssignedIdentity -Scope $Scope

Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$MainStSystemPrincipal" -and $_.AppId -eq "$AppId"}

$MainStSystemPrincipal="stdtspickupprod001"
c85e42bf-eb02-488a-b6b4-7b9fb9dcf636
Get-AzResource -Name $MainStSystemPrincipal | Format-List

$AzADServicePrincipal = Get-AzADServicePrincipal -DisplayNameBeginsWith $MainStSystemPrincipal

$MainStSystemPrincipal = Get-AzADServicePrincipal -DisplayName $MainStSystemPrincipalName

($AzADServicePrincipal.AlternativeName)[1]


$ManagedUserName="id-dts-pickup-prod"
$ManagedUser = Get-AzADServicePrincipal -DisplayName $ManagedUserName


$ManagedUser = Get-AzADServicePrincipal -DisplayName $ManagedUserName

Get-AzADServicePrincipal -DisplayName $ManagedUserName | Format-List

