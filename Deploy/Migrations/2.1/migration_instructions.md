# Migration to 2.1 Instructions
## 1.3 -> 2.1
### Data migration
Aside from the infrastructure changes which should be handled by the automation scripts, there is a data migration that has to happen to convert the data stored in 1.3 into the format needed for 2.1. 

In order to perform this, the '1.3to2.1_DataMigration.ps1' script needs to be kicked off. This script will convert the 1.3 transfer records into its equivalent "Transfer Detail" and "Transfer Assignment" records in the 2.1 data store. In addition, it will migrate over all consent records stored in 1.3 into the new 2.1 table to preserve that data.

```powershell

$dtpConnectionString = "DTP Storage account connection string"
$dppConnectionString = "DPP Storage account connection string"
$dppSubscriptionId = "Id of the subscription the DPP install lives in"
$dppResourceGroup = "Name of the resource group the DPP install lives in"
$dppRoleDefinition = "The id of the role definition DPP uses to create assignments to its containers for users"

.\1.3to2.1_DataMigration.ps1 `
	-DTPStorageConnectionString $dtpConnectionString `
	-DPPStorageConnectionString $dppConnectionString `
	-DPPSubscriptionId $dppSubscriptionId `
	-DPPResourceGroup $dppResourceGroup `
	-DPPRoleDefinitionId $dppRoleDefinition
	
```