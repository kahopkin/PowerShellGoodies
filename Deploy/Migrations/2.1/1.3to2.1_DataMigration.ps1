#REQUIRED MODULES:
# -Az.Storage
# -Az.Resources
# -AzTable

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true,
		 Position=0,
		 HelpMessage= 'Connection string for the storage account holding DTP data.')]
	[string]$DTPStorageConnectionString,

	[Parameter(Mandatory = $true,
		 Position=1,
		 HelpMessage= 'Connection string for the storage account holding DPP data.')]
	[string]$DPPStorageConnectionString,

	[Parameter(Mandatory = $true,
		 Position=1,
		 HelpMessage= 'The id of the subscription the installed DPP instace is located under.')]
	[string]$DPPSubscriptionId,

	[Parameter(Mandatory = $true,
		 Position=1,
		 HelpMessage= 'The name of the resource group DPP is located under.')]
	[string]$DPPResourceGroup,

	[Parameter(Mandatory = $true,
		 Position=1,
		 HelpMessage= 'The id of the role definition applied by DPP to allow access to data.')]
	[string]$DPPRoleDefinitionId
)

$AzDTPResources = @{
	SourceTransferTableName = "transfers"
	DestinationTransferTableName = "dtpTransfers"
}
$AzDPPResources = @{
	SourceTransferTableName = "CompletedContainers"
	DestinationTransferTableName = "dppTransfers"
}

Function Generate-CorrelationData 
{
	param (
		 [Parameter(Mandatory = $true)] $ExistingSourceTransfers,
		 [Parameter(Mandatory = $true)] $ExistingDestinationTransfers
	)

	$correlationData = @()

	$null = $ExistingSourceTransfers | select -Property PartitionKey,RowKey,ExpirationDate,UIStatusDate | % {
		 $existingSourceTransfer = $_
		 $existingDestintionTransfer = $ExistingDestinationTransfers | where { $_.TransferOwnerId -eq $existingSourceTransfer.PartitionKey -and $_.ContainerName -eq $existingSourceTransfer.RowKey } | select -First 1

			$transferId = If ($existingDestintionTransfer -and $existingDestintionTransfer.TransferId) { $existingDestintionTransfer.TransferId } Else { New-Guid }
		 $correlationData += @{
			 PartitionKey = $existingSourceTransfer.PartitionKey
			 RowKey = $existingSourceTransfer.RowKey
			 TransferId = $transferId
			 ExpirationDate = $existingSourceTransfer.ExpirationDate
			 TransferStatusTime = $existingSourceTransfer.UIStatusDate
		 }
	}

	return $correlationData
}

Function Get-AzRoleAssignmentResourceId {
	param (
		 [Parameter(Mandatory = $true)] $SubscriptionId,
		 [Parameter(Mandatory = $true)] $ResourceGroupName,
		 [Parameter(Mandatory = $true)] $StorageAccountName,
		 [Parameter(Mandatory = $true)] $ContainerName,
		 [Parameter(Mandatory = $true)] $RoleDefinitionId
	) 

	$scope = "/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName/blobServices/default/containers/$ContainerName/"

	$roleAssignment = Get-AzRoleAssignment -Scope $scope | where { $_.RoleDefinitionId -eq $RoleDefinitionId } | select -First 1

	if (-not $roleAssignment)
	{
		 Write-Verbose "SubscriptionId: $SubscriptionId"
		 Write-Verbose "ResourceGroupName: $ResourceGroupName"
		 Write-Verbose "StorageAccountName: $StorageAccountName"
		 Write-Verbose "ContainerName: $ContainerName"
		 Write-Verbose "RoleDefinitionId: $RoleDefinitionId"

		 throw 'Unable to retrieve Assignment Resource Id - No Role assignment found.'
	}

	return $roleAssignment.RoleDefinitionId
}

Function Migrate-DtpTransfers 
{
	param (
		 [Parameter(Mandatory = $true)] $SourceTable,
		 [Parameter(Mandatory = $true)] $CorrelatedTransferDataLookup,
		 [Parameter(Mandatory = $true)] $DestinationTable
	) 

	$existingDtpTransfers = Get-AzTableRow -table $SourceTable

	if (!$existingDtpTransfers) {
		 $existingDtpTransfers = @()
	}

	$erroredMigrations = @()

	foreach($existingTransferRecord in $existingDtpTransfers) {
		 Write-Host "Migrating DTP record with PartitionKey '$($existingTransferRecord.PartitionKey)' and RowKey '$($existingTransferRecord.RowKey)'"

		 try
		 {
			 $correlatedTransferData = $CorrelatedTransferDataLookup | where { $_.PartitionKey -eq $existingTransferRecord.PartitionKey -and $_.RowKey -eq $existingTransferRecord.RowKey } | select -First 1
			 if (-not $correlatedTransferData) {
				 throw "Cannot create transfer record. Unable to determine correlated transfer id. PartitionKey: $($existingTransferRecord.PartitionKey);Row Key: $($existingTransferRecord.RowKey)"
			 }

				 $newTransferId = $correlatedTransferData.TransferId

			 if ($existingTransferRecord.UIStatus -eq "Completed") {
				 $newTransferStatus = "Completed"
			 }
			 elseif ($existingTransferRecord.ExpirationDate -le (Get-Date)) {
				 $newTransferStatus = 'Expired'
			 }
			 else {
				 $newTransferStatus = "Opened"
			 }

			 $assignmentState = $null
			 $assignmentErrorMessage = $null
			 $deploymentId = $existingTransferRecord.DeploymentAssignmentId

			 if (-not $deploymentId) {
				 $assignmentState = "Errored"
				 $assignmentErrorMessage = "Could not migrate data. No deployment id was set."
				 $deploymentId = '00000000-0000-0000-0000-000000000000'

			 }
			 elseif ($existingTransferRecord.UIStatus -eq "Error") {
				 $assignmentState = "Errored"
				 $assignmentErrorMessage = $existingTransferRecord.ErrorMessage
			 }
			 else {
				 switch ($newTransferStatus) {
					 "Expired" { $assignmentState = "Expired" }
					 "Completed" { $assignmentState = "Revoked" }
					 "Opened" { $assignmentState = "Applied" }
				 }
			 }

			 $existingDestinationTransfer = Get-AzTableRow -table $DestinationTable -PartitionKey $newTransferId -RowKey 'Details'

			 if (-not $existingDestinationTransfer) {
				 Write-Host "Creating new DTP transfer. Old -> New Partition/Row Key: $($existingTransferRecord.PartitionKey)/$($existingTransferRecord.RowKey) => $newTransferId/Details"

				 $newTransferDetailRecordProps = @{
					 Type = 'TransferDetail'
					 TransferId = $newTransferId
					 TransferOwnerId = $existingTransferRecord.OID
					 ContainerName = $existingTransferRecord.ContainerName
					 ExpirationDate = $existingTransferRecord.ExpirationDate
					 CreatedOn = $existingTransferRecord.TableTimestamp
					 TransferStatus = $newTransferStatus
					 TransferStatusTime = $existingTransferRecord.UIStatusDate
				 }

				 $null = Add-AzTableRow `
					 -table $DestinationTable `
					 -partitionKey $newTransferId `
					 -rowKey 'Details' `
					 -property $newTransferDetailRecordProps
					 }
			 else {
				 Write-Host "Merging existing transfer record: TransferId: '$newTransferId'; PartitionKey: '$newTransferId'; RowKey: 'Details'"

				 $existingDestinationTransfer.Type = 'TransferDetail'
				 $existingDestinationTransfer.TransferId = $newTransferId
				 $existingDestinationTransfer.TransferOwnerId = $existingTransferRecord.OID
				 $existingDestinationTransfer.ContainerName = $existingTransferRecord.ContainerName
				 $existingDestinationTransfer.ExpirationDate = $existingTransferRecord.ExpirationDate
				 $existingDestinationTransfer.CreatedOn = $existingTransferRecord.TableTimestamp
				 $existingDestinationTransfer.TransferStatus = $newTransferStatus
				 $existingDestinationTransfer.TransferStatusTime = $existingTransferRecord.UIStatusDate

				 $null = Update-AzTableRow -table $DestinationTable -entity $existingDestinationTransfer
			 }

			 $assignmentPartitionKey = $existingTransferRecord.OID
			 $assignmentRowKey = "TransferAssignment_$newTransferId"
			 $existingDestinationAssignment = Get-AzTableRow -table $DtpDestinationTransferTable -PartitionKey $existingTransferRecord.OID -RowKey $assignmentRowKey

			 if (-not $existingDestinationAssignment) {
				 Write-Host "Creating Assignment: User '$($existingTransferRecord.OID)' as 'Owner' of the transfer '$newTransferId'"

				 $newTransferAssignmentRecordProps = @{
					 Type = "TransferAssignment"
					 AssignedOn = $existingTransferRecord.TableTimestamp
					 AssignedRole = "Owner"
					 AssignedBy = "DTS_INTERNAL_SYSTEM"
					 TransferId = $newTransferId
					 UserId = $existingTransferRecord.OID
					 DeploymentId = $deploymentId
					 AssignedContainerName = $existingTransferRecord.ContainerName
					 AssignmentState = $assignmentState
					 AssignmentStateTime = $existingTransferRecord.UIStatusDate
				 }

				 if ($null -ne $assignmentErrorMessage) {
					 $newTransferAssignmentRecordProps.AssignmentErrorMessage = $assignmentErrorMessage
				 }

				 $null = Add-AzTableRow `
					 -table $DestinationTable `
					 -partitionKey $assignmentPartitionKey `
					 -rowKey $assignmentRowKey `
					 -property $newTransferAssignmentRecordProps
			 }
			 else {
				 Write-Host "Merging existing assignment record: TransferId: '$newTransferId'; PartitionKey: '$assignmentPartitionKey'; RowKey: '$assignmentRowKey'"

					 $existingDestinationAssignment.Type = "TransferAssignment"
				 $existingDestinationAssignment.AssignedOn = $existingTransferRecord.TableTimestamp
				 $existingDestinationAssignment.AssignedRole = "Owner"
				 $existingDestinationAssignment.AssignedBy = "DTS_INTERNAL_SYSTEM"
				 $existingDestinationAssignment.TransferId = $newTransferId
				 $existingDestinationAssignment.UserId = $existingTransferRecord.OID
				 $existingDestinationAssignment.DeploymentId = $deploymentId
				 $existingDestinationAssignment.AssignedContainerName = $existingTransferRecord.ContainerName
				 $existingDestinationAssignment.AssignmentState = $assignmentState
				 $existingDestinationAssignment.AssignmentStateTime = $existingTransferRecord.UIStatusDate

					 if ($null -ne $assignmentErrorMessage) {
					 $existingDestinationAssignment.AssignmentErrorMessage = $assignmentErrorMessage
				 }

				 $null = Update-AzTableRow -table $DestinationTable -entity $existingDestinationAssignment
			 }
		 }
		 catch {
		 Write-Host $Error
			 $erroredMigrations += @{
				 SourcePartitionKey = $existingTransferRecord.PartitionKey
				 SourceRowKey = $existingTransferRecord.RowKey
				 Error = $Error[0]
			 }

			 $Error.Clear()
		 }
	}

	return @{
		 RanSuccessfully = $erroredMigrations.Length -eq 0
		 Errors = $erroredMigrations
	}
}

Function Migrate-DppTransfers 
{
	param (
		 [Parameter(Mandatory = $true)] $StorageAccountName,
		 [Parameter(Mandatory = $true)] $CorrelatedTransferDataLookup,
		 [Parameter(Mandatory = $true)] $SourceTable,
		 [Parameter(Mandatory = $true)] $DestinationTable
	) 

	$existingDppEntities = Get-AzTableRow -table $SourceTable

	$existingDppTransfers = $existingDppEntities | where { $_.PSobject.Properties.name -contains "ContainerName" -and $_.ContainerName -ne $null }

	$existingDppConsents = $existingDppEntities | where { $_.PSobject.Properties.name -contains "ConsentType" }

	if (!$existingDppTransfers) {
		 $existingDppTransfers = @()
	}

	if (!$existingDppConsents) {
		 $existingDppConsents = @()
	}

	$erroredMigrations = @()

	foreach($existingTransferRecord in $existingDppTransfers) {
		 Write-Host "Migrating DPP record with PartitionKey '$($existingTransferRecord.PartitionKey)' and RowKey '$($existingTransferRecord.RowKey)'"

		 try {
			 $correlatedTransferData = $CorrelatedTransferDataLookup | where { $_.PartitionKey -eq $existingTransferRecord.PartitionKey -and $_.RowKey -eq $existingTransferRecord.RowKey } | select -First 1
			 if (-not $correlatedTransferData) {
				 throw "Cannot create transfer record. Unable to determine correlated transfer id. PartitionKey: $($existingTransferRecord.PartitionKey);Row Key: $($existingTransferRecord.RowKey)"
			 }

			 $newTransferId = $correlatedTransferData.TransferId
			 $userId = $existingTransferRecord.OID
			 $containerName = $existingTransferRecord.ContainerName

			 $newTransferStatus = $null

			 if ($correlatedTransferData.ExpirationDate -le (Get-Date)) {
				 $newTransferStatus = 'Expired'
			 }
			 else {
				 $newTransferStatus = "Opened"
			 }

			 $existingDestinationTransfer = Get-AzTableRow -table $DestinationTable -PartitionKey $newTransferId -RowKey 'Details'

			 if (-not $existingDestinationTransfer) {
				 Write-Host "Creating new DPP transfer. Old -> New Partition/Row Key: $($existingTransferRecord.PartitionKey)/$($existingTransferRecord.RowKey) => $newTransferId/Details"

				 $newTransferDetailRecordProps = @{
					 Type = 'TransferDetail'
					 TransferId = $newTransferId
					 TransferOwnerId = $userId
					 ContainerName = $containerName
					 TransferStatus = $newTransferStatus
					 TransferStatusTime = (Get-Date)
					 CreatedOn = $existingTransferRecord.TableTimestamp
					 ImportedOn = (Get-Date)
					 ExpirationDate = $correlatedTransferData.ExpirationDate
					 CompletedOn = $correlatedTransferData.TransferStatusTime
					 CompletedByUserId = $userId
				 }

				 $null = Add-AzTableRow `
					 -table $DestinationTable `
					 -partitionKey $newTransferId `
					 -rowKey 'Details' `
					 -property $newTransferDetailRecordProps
					 }
			 else {
				 Write-Host "Merging existing transfer record: TransferId: '$newTransferId'; PartitionKey: '$($existingTransferRecord.PartitionKey)'; RowKey: '$($existingTransferRecord.RowKey)'"

				 $existingDestinationTransfer.Type = 'TransferDetail'
				 $existingDestinationTransfer.TransferId = $newTransferId
				 $existingDestinationTransfer.TransferOwnerId = $userId
				 $existingDestinationTransfer.ContainerName = $containerName
				 $existingDestinationTransfer.TransferStatus = $newTransferStatus
				 $existingDestinationTransfer.TransferStatusTime = (Get-Date)
				 $existingDestinationTransfer.CreatedOn = $existingTransferRecord.TableTimestamp
				 $existingDestinationTransfer.ImportedOn = (Get-Date)
				 $existingDestinationTransfer.ExpirationDate = $correlatedTransferData.ExpirationDate
				 $existingDestinationTransfer.CompletedOn = $correlatedTransferData.TransferStatusTime
				 $existingDestinationTransfer.CompletedByUserId = $userId

				 $null = Update-AzTableRow -table $DestinationTable -entity $existingDestinationTransfer
			 }

			 if ($existingTransferRecord.RBACApplied -ne $true) {
				 #Skip making an assignment record. This transfer never had an assignment
				 continue
			 }

				 $assignmentDeploymentId = Get-AzRoleAssignmentResourceId `
				 -SubscriptionId $DPPSubscriptionId `
				 -ResourceGroupName $DPPResourceGroup `
				 -RoleDefinitionId $DPPRoleDefinitionId `
				 -StorageAccountName $StorageAccountName `
				 -ContainerName $containerName

			 $assignmentState = $null 

			 switch ($newTransferStatus) {
				 "Expired" { $assignmentState = "Expired" }
				 "Opened" { $assignmentState = "Applied" }
			 }

			 $assignmentPartitionKey = $userId
			 $assignmentRowKey = "TransferAssignment_$newTransferId"
			 $existingDestinationAssignment = Get-AzTableRow -table $DestinationTable -PartitionKey $userId -RowKey $assignmentRowKey

			 if (-not $existingDestinationAssignment) {
				 Write-Host "Creating Assignment: User '$userId' as 'Owner' of the transfer '$newTransferId'"

				 $newTransferAssignmentRecordProps = @{
					 Type = "TransferAssignment"
					 AssignedOn = $existingTransferRecord.TableTimestamp
					 AssignedRole = "Owner"
					 AssignedBy = "DTS_INTERNAL_SYSTEM"
					 TransferId = $newTransferId
					 UserId = $userId
					 DeploymentId = $assignmentDeploymentId
					 AssignedContainerName = $containerName
					 AssignmentState = $assignmentState
					 AssignmentStateTime = $existingTransferRecord.TableTimestamp
					 IsHidden = $existingTransferRecord.Hidden
				 }

				 if ($null -ne $assignmentErrorMessage) {
					 $newTransferAssignmentRecordProps.AssignmentErrorMessage = $assignmentErrorMessage
				 }

				 $null = Add-AzTableRow `
					 -table $DestinationTable `
					 -partitionKey $assignmentPartitionKey `
					 -rowKey $assignmentRowKey `
					 -property $newTransferAssignmentRecordProps
			 }
			 else {
				 Write-Host "Merging existing assignment record: TransferId: '$newTransferId'; PartitionKey: '$assignmentPartitionKey'; RowKey: '$assignmentRowKey'"

					 $existingDestinationAssignment.Type = "TransferAssignment"
				 $existingDestinationAssignment.AssignedOn = $existingTransferRecord.TableTimestamp
				 $existingDestinationAssignment.AssignedRole = "Owner"
				 $existingDestinationAssignment.AssignedBy = "DTS_INTERNAL_SYSTEM"
				 $existingDestinationAssignment.TransferId = $newTransferId
				 $existingDestinationAssignment.UserId = $userId
				 $existingDestinationAssignment.DeploymentId = $assignmentDeploymentId
				 $existingDestinationAssignment.AssignedContainerName = $containerName
				 $existingDestinationAssignment.AssignmentState = $assignmentState
				 $existingDestinationAssignment.AssignmentStateTime = $existingTransferRecord.TableTimestamp
				 $existingDestinationAssignment.IsHidden = $existingTransferRecord.Hidden

					 if ($null -ne $assignmentErrorMessage) {
					 $existingDestinationAssignment.AssignmentErrorMessage = $assignmentErrorMessage
				 }

				 $null = Update-AzTableRow -table $DestinationTable -entity $existingDestinationAssignment
			 }

			 $newTransferDetailRecordProps = @{
				 Type = 'TransferDetails'
				 TransferId = $newTransferId
				 TransferOwnerId = $userId
				 ContainerName = $containerName
				 TransferStatus = $newTransferStatus
				 TransferStatusTime = (Get-Date)
				 CreatedOn = $existingTransferRecord.TableTimestamp
				 ImportedOn = (Get-Date)
				 ExpirationDate = $correlatedTransferData.ExpirationDate
				 CompletedOn = $correlatedTransferData.TransferStatusTime
				 CompletedByUserId = $userId
			 }
		 }
		 catch
		 {
			 $erroredMigrations += @{
				 SourcePartitionKey = $existingTransferRecord.PartitionKey
				 SourceRowKey = $existingTransferRecord.RowKey
				 Error = $Error
			 }

			 $Error.Clear()
		 }
	}

	foreach($existingSourceConsentRecord in $existingDppConsents) {
		 Write-Host "Migrating DPP consent record with PartitionKey '$($existingSourceConsentRecord.PartitionKey)' and RowKey '$($existingSourceConsentRecord.RowKey)'"

		 try {
			 $containerName = $existingSourceConsentRecord.TransferId

			 if (-not $containerName) {
				 throw "Cannot determine the container associated with the consent record. PartitionKey: $($existingSourceConsentRecord.PartitionKey);Row Key: $($existingSourceConsentRecord.RowKey)"
			 }

			 $correlatedTransferData = $CorrelatedTransferDataLookup | where { $_.PartitionKey -eq $existingSourceConsentRecord.PartitionKey -and $_.RowKey -eq $containerName } | select -First 1
			 if (-not $correlatedTransferData) {
				 throw "Cannot migrate consent record. Unable to determine correlated transfer id. PartitionKey: $($existingSourceConsentRecord.PartitionKey);Row Key: $($existingSourceConsentRecord.RowKey)"
			 }

			 $rowKey = "$($existingSourceConsentRecord.ConsentType)-$($existingSourceConsentRecord.ConsentGrantorId)"

			 $existingDestinationAssignment = Get-AzTableRow -table $DestinationTable -PartitionKey $correlatedTransferData.TransferId -RowKey $rowKey

			 if (-not $existingDestinationAssignment) {
				 $newConsentRecordProps = @{
					 Type = "UserConsent"
					 ConsentGrantorId = $existingSourceConsentRecord.ConsentGrantorId
					 ConsentType = $existingSourceConsentRecord.ConsentType
					 ConsentGrantedOn = $existingSourceConsentRecord.ConsentGrantedOn
					 TransferId = $correlatedTransferData.TransferId
				 }

				 $null = Add-AzTableRow `
					 -table $DestinationTable `
					 -partitionKey $correlatedTransferData.TransferId `
					 -rowKey $rowKey `
					 -property $newConsentRecordProps
			 }
			 else {
				 $existingDestinationAssignment.Type = 'UserConsent'
				 $existingDestinationAssignment.TransferId = $correlatedTransferData.TransferId
				 $existingDestinationAssignment.ConsentGrantorId = $existingSourceConsentRecord.ConsentGrantorId
				 $existingDestinationAssignment.ConsentType = $existingSourceConsentRecord.ConsentType
				 $existingDestinationAssignment.ConsentGrantedOn = $existingSourceConsentRecord.ConsentGrantedOn

				 $null = Update-AzTableRow -table $DestinationTable -entity $existingDestinationAssignment
			 }
		 }
		 catch {
			 $erroredMigrations += @{
				 SourcePartitionKey = $existingTransferRecord.PartitionKey
				 SourceRowKey = $existingTransferRecord.RowKey
				 Error = $Error
			 }

			 $Error.Clear()
		 }
	}

	return @{
		 RanSuccessfully = $erroredMigrations.Length -eq 0
		 Errors = $erroredMigrations
	}
}

Write-Host 'Connecting to DTP azure resources...'
$dtpStorageCtx = New-AzStorageContext -ConnectionString $DTPStorageConnectionString
$dtpSourceTable = Get-AzStorageTable -Name $AzDTPResources.SourceTransferTableName -Context $dtpStorageCtx
$dtpDestinationTable = Get-AzStorageTable -Name $AzDTPResources.DestinationTransferTableName -Context $dtpStorageCtx -ErrorVariable dtpGetDestinationTableErr -ErrorAction SilentlyContinue

if ($null -eq $dtpDestinationTable -and $dtpGetDestinationTableErr) {
	Write-Host "Creating new transfers table: $($AzDTPResources.DestinationTransferTableName)"
	$dtpDestinationTable = New-AzStorageTable –Name $AzDTPResources.DestinationTransferTableName –Context $dtpStorageCtx
}

$DtpSourceTransferTable = $dtpSourceTable.CloudTable
$DtpDestinationTransferTable = $dtpDestinationTable.CloudTable

Write-Verbose "Connected to DTP Resources"
Write-Verbose "Storage Account Name: $($StorageContext.StorageAccountName)"
Write-Verbose "Source Table Ref: $($DtpSourceTransferTable.Uri)"
Write-Verbose "Destination Table Ref: $($DtpDestinationTransferTable.Uri)"

$existingSourceDtpTransfers = Get-AzTableRow -table $DtpSourceTransferTable
$existingDestinationDtpTransfers = Get-AzTableRow -table $DtpDestinationTransferTable

if (!$existingSourceDtpTransfers) {
	$existingSourceDtpTransfers = @()
}

if (!$existingDestinationDtpTransfers) {
	$existingDestinationDtpTransfers = @()
}

Write-Host 'Connecting to DPP azure resources...'
$dppStorageCtx = New-AzStorageContext -ConnectionString $DPPStorageConnectionString
$dppSourceTable = Get-AzStorageTable -Name $AzDPPResources.SourceTransferTableName -Context $dppStorageCtx
$dppDestinationTable = Get-AzStorageTable -Name $AzDPPResources.DestinationTransferTableName -Context $dppStorageCtx -ErrorVariable dppGetDestinationTableErr -ErrorAction SilentlyContinue

if ($null -eq $dppDestinationTable -and $dppGetDestinationTableErr) {
	Write-Host "Creating new transfers table: $($AzDPPResources.DestinationTransferTableName)"
	$dppDestinationTable = New-AzStorageTable –Name $AzDPPResources.DestinationTransferTableName –Context $dppStorageCtx
}

$DppSourceTransferTable = $dppSourceTable.CloudTable
$DppDestinationTransferTable = $dppDestinationTable.CloudTable

Write-Verbose "Connected to DPP Resources"
Write-Verbose "Storage Account Name: $($StorageContext.StorageAccountName)"
Write-Verbose "Source Table Ref: $($DppSourceTransferTable.Uri)"
Write-Verbose "Destination Table Ref: $($DppDestinationTransferTable.Uri)"

$correlationDataLookup = Generate-CorrelationData -ExistingSourceTransfers $existingSourceDtpTransfers -ExistingDestinationTransfers $existingDestinationDtpTransfers

$dtpMigrationResult = Migrate-DtpTransfers -SourceTable $DtpSourceTransferTable -DestinationTable $DtpDestinationTransferTable -CorrelatedTransferDataLookup $correlationDataLookup

$dppMigrationResult = Migrate-DppTransfers -SourceTable $DppSourceTransferTable -DestinationTable $DppDestinationTransferTable -CorrelatedTransferDataLookup $correlationDataLookup -StorageAccountName $dppStorageCtx.StorageAccountName

"-------------------------------------------------"
Write-Host "DTP Data Record Migration Results:"

if ($dtpMigrationResult.RanSuccessfully) {
	Write-Host 'DTP Migration ran successfully' -ForegroundColor Green
}
else {
	Write-Host 'DTP Migration unsuccessful' -ForegroundColor Red
	$dtpMigrationResult.Errors | % {[PSCustomObject]$_} | Format-Table -AutoSize -Property SourcePartitionKey,SourceRowKey,Error
}

Write-Host "-------------------------------------------------"
Write-Host "DPP Data Record Migration Results:"

if ($dtpMigrationResult.RanSuccessfully) {
	Write-Host 'DPP Migration ran successfully' -ForegroundColor Green
}
else {
	Write-Host 'DPP Migration unsuccessful' -ForegroundColor Red
	$dppMigrationResult.Errors | % {[PSCustomObject]$_} | Format-Table -AutoSize -Property SourcePartitionKey,SourceRowKey,Error
}