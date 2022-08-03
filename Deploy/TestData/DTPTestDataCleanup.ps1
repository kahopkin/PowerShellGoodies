# DTPTestDataCleanup.ps1
<#
    This script will delete/reset the data in the Resource Group/Storage Account specified.
    - Deletes all DTP manifest files in the specified 'completed containers' blob container.
    - Deletes all the DTP users' containers and uploaded files listed within the transfer table.
    - Deletes all the DTP transfer records in the transfer table.
    - Removes the role assignments (see $roleDefinitionNames) specified for each user listed within the transfer table for the specified storage account (see $scope). 
    - Deletes all the DTP audit records in the insights-logs-storagedelete, insights-logs-storageread, insights-logs-storagewrite containers.

    Requires the Az.Resources module
    Requires the AzTable module
#>


<#
    .SYNOPSIS Deletes all the blobs in the specified container.

    .PARAMETER StorageAccountContext
        Storage Account Context object to that specifies the Azure storage context.

    .PARAMETER ContainerName
        The container name that the blobs will be deleted from.

    .EXAMPLE
        $ResourceGroupName = "RESORCEGROUPNAME"
        $StorageAccountName = "STORAGEACCOUNTNAME"
        $CompletedContainerName = "COMPLETEDCONTAINERSNAME"

        # Get a reference to the storage account and the context
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName 
        $storageAccountContext = $storageAccount.Context

        # Call to delete the manifest files in the Completed Container
        DeleteBlobs -StorageAccountContext $storageAccountContext -ContainerName $CompletedContainerName
#>
function DeleteBlobs {
    Param(
          [Parameter(Mandatory = $true)] 
          [Object]
          $StorageAccountContext,
          
          [Parameter(Mandatory = $true)] 
          [String]
          $ContainerName
    )

    # Deletes all the blobs in the container
    Get-AzStorageBlob -Container $ContainerName -Context $StorageAccountContext | Remove-AzStorageBlob 

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Deleted all blobs in $ContainerName *****************"

}#DeleteBlobs


<#
    .SYNOPSIS Gets the Records within Transfer Storage Table.

    .PARAMETER StorageAccountContext
        Storage Account Context object to that specifies the Azure storage context.

    .EXAMPLE
        $ResourceGroupName = "RESORCEGROUPNAME"
        $StorageAccountName = "STORAGEACCOUNTNAME"

        # Get a reference to the storage account and the context
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName 
        $storageAccountContext = $storageAccount.Context

        # Call to get the transferRecords from the transfer table
        $transferRecords = GetTransferTableRecords -StorageAccountContext $storageAccountContext
#>
function GetTransferTableRecords {
    Param(
          [Parameter(Mandatory = $true)] 
          [Object]
          $StorageAccountContext
    )

    $transferTableName = "transfers"

    # Get the transfer table
    $transferTable = Get-AzStorageTable -Context $StorageAccountContext -Name $transferTableName

    # Get the transfer table records
    # Must use the CloudTable object when working with table data via the AzTable PowerShell module!
    # https://docs.microsoft.com/en-us/azure/storage/tables/table-storage-how-to-use-powershell
    $cloudTable = $transferTable.CloudTable
    $transferRecords = Get-AzTableRow -Table $cloudTable
    
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Retrieved Transfer Records *****************"

    return $transferRecords

}#GetTransferTableRecords


<#
    .SYNOPSIS Deletes the specified Container.

    .PARAMETER StorageAccountContext
        Storage Account Context object to that specifies the Azure storage context.

    .PARAMETER ContainerName
        The container name that will be deleted.

    .EXAMPLE
        $ResourceGroupName = "RESORCEGROUPNAME"
        $StorageAccountName = "STORAGEACCOUNTNAME"
        $containerName = "SOMECONTAINER"

        # Get a reference to the storage account and the context
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName 
        $storageAccountContext = $storageAccount.Context

        # Call to delete the container
        DeleteContainer -StorageAccountContext $storageAccountContext -ContainerName $containerName
#>
function DeleteContainer {
    Param(
          [Parameter(Mandatory = $true)] 
          [Object]
          $StorageAccountContext,
          
          [Parameter(Mandatory = $true)] 
          [String]
          $ContainerName
    )

    # Delete the container
    Remove-AzStorageContainer -Name $ContainerName -Context $StorageAccountContext -Force

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Deleted all blobs in container $ContainerName *****************"

}#DeleteContainer


<#
    .SYNOPSIS Deletes the specified Transfer Record.

    .PARAMETER StorageAccountContext
        Storage Account Context object to that specifies the Azure storage context.

    .PARAMETER PartitionKey
        The Partition Key of the record that will be deleted in the transfer table.

    .PARAMETER RowKey
        The Row Key of the record that will be deleted in the transfer table.

    .EXAMPLE
        $ResourceGroupName = "RESORCEGROUPNAME"
        $StorageAccountName = "STORAGEACCOUNTNAME"
        $partitionKey = "SomePartitionKey"
        $rowKey = "SomeRowKey"

        # Get a reference to the storage account and the context
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName 
        $storageAccountContext = $storageAccount.Context

        # Call to delete the transfer record
        DeleteTransferRecord -StorageAccountContext $storageAccountContext -PartitionKey $partitionKey -RowKey $rowKey
#>
function DeleteTransferRecord {
    Param(
          [Parameter(Mandatory = $true)] 
          [Object]
          $StorageAccountContext,

          [Parameter(Mandatory = $true)] 
          [String]
          $PartitionKey,

          [Parameter(Mandatory = $true)] 
          [String]
          $RowKey
    )

    $transferTableName = "transfers"

    # Get the transfer table
    $transferTable = Get-AzStorageTable -Context $StorageAccountContext -Name $transferTableName

    # Get the transfer table records
    # Must use the CloudTable object when working with table data via the AzTable PowerShell module!
    # https://docs.microsoft.com/en-us/azure/storage/tables/table-storage-how-to-use-powershell
    $cloudTable = $transferTable.CloudTable

    # Delete the transfer record
    Remove-AzTableRow -PartitionKey $PartitionKey -RowKey $RowKey -Table $cloudTable

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Deleted Transfer Record $RowKey *****************"

}#DeleteTransferRecord


<#
    .SYNOPSIS Removes the specified RBAC assignments from the specified users.

    .PARAMETER UserOIDs
        List of user Ids.

    .PARAMETER Scope
        The Scope in which the RBAC removal will apply.

    .PARAMETER RoleDefinitionNames
        List of roles to remove for each specified user.

    .EXAMPLE
        $ResourceGroupName = "RESORCEGROUPNAME"
        $StorageAccountName = "STORAGEACCOUNTNAME"

        # Get the subscription
        $subscription = Get-AzSubscription
        $subscriptionnId = $subscription.Id

        # Set the scope for the RBAC reset operations
        $scope = "/subscriptions/" + $subscriptionnId + "/resourcegroups/" + $ResourceGroupName + "/providers/Microsoft.Storage/storageAccounts/" + $StorageAccountName

        $roleDefinitionNames = @(
            'DTP Storage Blob Data ReadWrite'
            'Storage Blob Data Contributor'
        )

        $UserOIDs = @(
            'OID1'
            'OID2'
        )

        # Call to remove the RBAC from the users
        RemoveRBAC -UserOIDs $UserOIDs -RoleDefinitionNames $RoleDefinitionNames -Scope $scope
#>
function RemoveRBAC {
    Param(
          [Parameter(Mandatory = $true)] 
          [string[]]
          $UserOIDs,

          [Parameter(Mandatory = $true)] 
          [String]
          $Scope, 

          [Parameter(Mandatory = $true)] 
          [string[]]
          $RoleDefinitionNames
    )


    # For each user
    foreach ($userOID in $UserOIDs) {
        # For each role
        foreach ($role in $RoleDefinitionNames) {
            # Get the user's role assignments
            $rollAssignments = Get-AzRoleAssignment -RoleDefinitionName $role -ObjectId $userOID -Scope $Scope 

            # Remove the user's RBAC assignments
            foreach ($rollAssignment in $rollAssignments) {
                Remove-AzRoleAssignment -InputObject $rollAssignment -PassThru
            }

            $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
            Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Deleted role [$role] assignments for user $userOID *****************"

        }
    }

}#RemoveRBAC


<#
    .SYNOPSIS Deletes all the audit records in the audit storage account.

    .PARAMETER ResourceGroupName
        The Resource Group for the audit storage account.

    .PARAMETER AuditStorageAccountName
        The audit Storage Account name.

    .EXAMPLE
        $ResourceGroupName = "RESORCEGROUPNAME"
        $AuditStorageAccountName = "AUDITSTORAGEACCOUNTNAME"

        # Call to delete the audit records
        ResetAuditLogs -ResourceGroupName $ResourceGroupName -AuditStorageAccountName $AuditStorageAccountName 
#>
function ResetAuditLogs {
    Param(
          [Parameter(Mandatory = $true)] 
          [String]
          $ResourceGroupName, 

          [Parameter(Mandatory = $true)] 
          [string]
          $AuditStorageAccountName
    )

    $storagedelete = "insights-logs-storagedelete"
    $storageread = "insights-logs-storageread"
    $storagewrite = "insights-logs-storagewrite"

    # Get a reference to the storage account and the context
    $auditStorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -name $AuditStorageAccountName 
    $auditStorageAccountContext = $auditStorageAccount.Context

    # Calls to delete the blobs in these containers
    DeleteBlobs -StorageAccountContext $auditStorageAccountContext -ContainerName $storagedelete
    DeleteBlobs -StorageAccountContext $auditStorageAccountContext -ContainerName $storageread 
    DeleteBlobs -StorageAccountContext $auditStorageAccountContext -ContainerName $storagewrite

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Deleted audit Records *****************"

    return $ResetAuditLogs

}#ResetAuditLogs


<#
    .SYNOPSIS The main entry point for the script.  Will manage:   
		- Deletes all DTP manifest files in the specified 'completed containers' blob container.
		- Deletes all the DTP users' containers and uploaded files listed within the transfer table.
		- Deletes all the DTP transfer records in the transfer table.
		- Removes the role assignments (see $roleDefinitionNames) specified for each user listed within the transfer table for the specified storage account (see $scope). 
		- Deletes all the DTP audit records in the insights-logs-storagedelete, insights-logs-storageread, insights-logs-storagewrite containers.

    .PARAMETER ResourceGroupName
        The Resource Group for the audit storage account.

    .PARAMETER StorageAccountName
        The Storage Account name.

     .PARAMETER AuditStorageAccountName
        The audit Storage Sccount name.

     .PARAMETER CompletedContainerName
        The container name that the manifest files can be found.

     .PARAMETER RoleDefinitionNames
        List of roles to remove for each specified user.

    .EXAMPLE
        $resourceGroupName = "RESORCEGROUPNAME"
        $storageAccountName = "STORAGEACCOUNTNAME"
        $auditStorageAccountName = "AUDITSTORAGEACCOUNTNAME"
        $completedContainerName = "COMPLETEDCONTAINERSNAME"

        $roleDefinitionNames = @(
            'DTP Storage Blob Data ReadWrite'
            'Storage Blob Data Contributor'
        )

        # Call to reset the DTP data
        ResetDTPData -ResourceGroupName $resourceGroupName `
                     -StorageAccountName $storageAccountName `
                     -AuditStorageAccountName $auditStorageAccountName `
                     -CompletedContainerName $completedContainerName `
                     -RoleDefinitionNames $roleDefinitionNames 
#>
function ResetDTPData {
    Param(
          [Parameter(Mandatory = $true)] 
          [String]
          $ResourceGroupName,

          [Parameter(Mandatory = $true)] 
          [String]
          $StorageAccountName, 

          [Parameter(Mandatory = $true)] 
          [String]
          $AuditStorageAccountName, 

          [Parameter(Mandatory = $true)] 
          [String]
          $CompletedContainerName, 

          [Parameter(Mandatory = $true)] 
          [string[]]
          $RoleDefinitionNames
    )

    try
    {
        $UserOIDs = @()

        # Authenticate
        Connect-AzAccount -EnvironmentName AzureUSGovernment

        $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
        Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] CONNECTED to Azure  *****************"

        # Get the subscription
        $subscription = Get-AzSubscription
        $subscriptionnId = $subscription.Id

        # Set the scope for the RBAC reset operations
        $scope = "/subscriptions/" + $subscriptionnId + "/resourcegroups/" + $ResourceGroupName + "/providers/Microsoft.Storage/storageAccounts/" + $StorageAccountName

        # Get a reference to the storage account and the context
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName 
        $storageAccountContext = $storageAccount.Context

        $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
        Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Retrieved storage account context   *****************"

        # Call to delete the manifest files in the Completed Container
        DeleteBlobs -StorageAccountContext $storageAccountContext -ContainerName $CompletedContainerName
        
        # Call to get the transferRecords from the transfer table
        $transferRecords = GetTransferTableRecords -StorageAccountContext $storageAccountContext

        $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
        Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Processing transfer records *****************"

        # Process each transfer record
        foreach ($item in $transferRecords) {
            $partitionKey = $item.PartitionKey
            $rowKey = $item.RowKey
            $oid = $item.OID
            $containerName = $item.ContainerName

            # Call to delete the container
            DeleteContainer -StorageAccountContext $storageAccountContext -ContainerName $containerName

            # Call to delete the transfer record
            DeleteTransferRecord -StorageAccountContext $storageAccountContext -PartitionKey $partitionKey -RowKey $rowKey

            # Get a list of unique OIDs
            if ($UserOIDs.Contains($oid) -eq $false) {
                $UserOIDs += $oid
            }
        }

        $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
        Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Removing RBAC *****************"

        # Call to remove the RBAC from the users
        RemoveRBAC -UserOIDs $UserOIDs -RoleDefinitionNames $RoleDefinitionNames -Scope $scope

        # Call to delete the audit records
        ResetAuditLogs -ResourceGroupName $ResourceGroupName -AuditStorageAccountName $AuditStorageAccountName 

        $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
        Write-Host -ForegroundColor Green -BackgroundColor Black  "`n************* [$today] Complete *****************"

    }
    catch
    {
      Write-Host -ForegroundColor Red -BackgroundColor Black "An error occurred:"
      Write-Host -ForegroundColor Red -BackgroundColor Black $_
    }

}#ResetDTPData

<#
    Read Me:
    1. Replace the values below with your desired values.
        I.E.
            $resourceGroupName = "RESORCEGROUPNAME"
            $storageAccountName = "STORAGEACCOUNTNAME"
            $auditStorageAccountName = "AUDITSTORAGEACCOUNTNAME"
            $completedContainerName = "COMPLETEDCONTAINERSNAME"

    2. Specify the name(s) of the roledifinitions that should be removed.
        I.E.
            $roleDefinitionNames = @(
                'DTP Storage Blob Data ReadWrite'
                'Storage Blob Data Contributor'
            )
#>

#$resourceGroupName = "RESORCEGROUPNAME"
#$storageAccountName = "STORAGEACCOUNTNAME"
#$auditStorageAccountName = "AUDITSTORAGEACCOUNTNAME"
#$completedContainerName = "COMPLETEDCONTAINERSNAME"

$resourceGroupName = "dtp10"
$storageAccountName = "dtp10b739"
$auditStorageAccountName = "dtp10audit"
$completedContainerName = "completedcontainers"

$roleDefinitionNames = @(
    'DTP Storage Blob Data ReadWrite'
    'Storage Blob Data Contributor'
)

$confirmation = Read-Host "This script will delete/reset the data in the Resource Group '$resourceGroupName' and Storage Account '$storageAccountName'. Are you sure? [Y/N]"

if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
    # Call to delete/reset the DTP data
    ResetDTPData -ResourceGroupName $resourceGroupName `
                 -StorageAccountName $storageAccountName `
                 -AuditStorageAccountName $auditStorageAccountName `
                 -CompletedContainerName $completedContainerName `
                 -RoleDefinitionNames $roleDefinitionNames 
}
