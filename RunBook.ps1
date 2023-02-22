#https://learn.microsoft.com/en-us/azure/automation/automation-create-alert-triggered-runbook
#Runbook
# Sign in to your Azure subscription
$sub = Get-AzSubscription -ErrorAction SilentlyContinue
if(-not($sub))
{
    Connect-AzAccount
}

# If you have multiple subscriptions, set the one to use
# Select-AzSubscription -SubscriptionId <SUBSCRIPTIONID>


$resourceGroup = "rg-Automation"
$automationAccount = "autoadmin"
$userAssignedManagedIdentity = "KatManagedUserIdentity"

$resourceGroup = "rg-DataCenter2019"

#assign a role to the system-assigned managed identity.
$SAMI = (Get-AzAutomationAccount -ResourceGroupName $resourceGroup -Name $automationAccount).Identity.PrincipalId
$SAMIName = (Get-AzAutomationAccount -ResourceGroupName $resourceGroup -Name $automationAccount).AutomationAccountName
Write-Host -ForegroundColor Yellow "`$SAMI=`"$SAMI`""

New-AzRoleAssignment `
    -ObjectId $SAMI `
    -ResourceGroupName $resourceGroup `
    -RoleDefinitionName "DevTest Labs User"

Write-Host -ForegroundColor Green "Added DevTest Labs User role to "$SAMIName

#Assign a role to a user-assigned managed identity
$UAMI = (Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroup -Name $userAssignedManagedIdentity)
$UAMIName = $UAMI.Name

New-AzRoleAssignment `
    -ObjectId $UAMI.PrincipalId `
    -ResourceGroupName $resourceGroup `
    -RoleDefinitionName "DevTest Labs User"

Write-Host -ForegroundColor Green "Added DevTest Labs User role to "$SAMIName

#For the system-assigned managed identity, 
#show ClientId and record the value for later use

$samiId = $UAMI.ClientId

#from https://learn.microsoft.com/en-us/azure/automation/automation-create-alert-triggered-runbook
#Stop-AzureVmInResponsetoVMAlert

#$samiId = "979adfbf-214a-4171-beaf-f51ed094ba00"

#Create Runbook: This is in the browser , automation account: 
#Process automation->RunBooksCreate Runbook
[OutputType("PSAzureOperationResponse")]
param
(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData
)
$ErrorActionPreference = "stop"

if ($WebhookData)
{
    # Get the data object from WebhookData
    $WebhookBody = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)

    # Get the info needed to identify the VM (depends on the payload schema)
    $schemaId = $WebhookBody.schemaId
    Write-Verbose "schemaId: $schemaId" -Verbose
    if ($schemaId -eq "azureMonitorCommonAlertSchema") {
        # This is the common Metric Alert schema (released March 2019)
        $Essentials = [object] ($WebhookBody.data).essentials
        # Get the first target only as this script doesn't handle multiple
        $alertTargetIdArray = (($Essentials.alertTargetIds)[0]).Split("/")
        $SubId = ($alertTargetIdArray)[2]
        $ResourceGroupName = ($alertTargetIdArray)[4]
        $ResourceType = ($alertTargetIdArray)[6] + "/" + ($alertTargetIdArray)[7]
        $ResourceName = ($alertTargetIdArray)[-1]
        $status = $Essentials.monitorCondition
    }
    elseif ($schemaId -eq "AzureMonitorMetricAlert") {
        # This is the near-real-time Metric Alert schema
        $AlertContext = [object] ($WebhookBody.data).context
        $SubId = $AlertContext.subscriptionId
        $ResourceGroupName = $AlertContext.resourceGroupName
        $ResourceType = $AlertContext.resourceType
        $ResourceName = $AlertContext.resourceName
        $status = ($WebhookBody.data).status
    }
    elseif ($schemaId -eq "Microsoft.Insights/activityLogs") {
        # This is the Activity Log Alert schema
        $AlertContext = [object] (($WebhookBody.data).context).activityLog
        $SubId = $AlertContext.subscriptionId
        $ResourceGroupName = $AlertContext.resourceGroupName
        $ResourceType = $AlertContext.resourceType
        $ResourceName = (($AlertContext.resourceId).Split("/"))[-1]
        $status = ($WebhookBody.data).status
    }
    elseif ($schemaId -eq $null) {
        # This is the original Metric Alert schema
        $AlertContext = [object] $WebhookBody.context
        $SubId = $AlertContext.subscriptionId
        $ResourceGroupName = $AlertContext.resourceGroupName
        $ResourceType = $AlertContext.resourceType
        $ResourceName = $AlertContext.resourceName
        $status = $WebhookBody.status
    }
    else {
        # Schema not supported
        Write-Error "The alert data schema - $schemaId - is not supported."
    }

    Write-Verbose "status: $status" -Verbose
    if (($status -eq "Activated") -or ($status -eq "Fired"))
    {
        Write-Verbose "resourceType: $ResourceType" -Verbose
        Write-Verbose "resourceName: $ResourceName" -Verbose
        Write-Verbose "resourceGroupName: $ResourceGroupName" -Verbose
        Write-Verbose "subscriptionId: $SubId" -Verbose

        # Determine code path depending on the resourceType
        if ($ResourceType -eq "Microsoft.Compute/virtualMachines")
        {
            # This is an Resource Manager VM
            Write-Verbose "This is an Resource Manager VM." -Verbose

	        # Ensures you do not inherit an AzContext in your runbook
	        Disable-AzContextAutosave -Scope Process

	        # Connect to Azure with system-assigned managed identity
	        #$AzureContext = (Connect-AzAccount -Identity).context

            #Connect to Azure with the User Assigned Identity
            <#
            $resourceGroup = "rg-Automation"
            $automationAccount = "autoadmin"
            $userAssignedManagedIdentity = "KatManagedUserIdentity"
            $UAMI = (Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroup -Name $userAssignedManagedIdentity)
            $samiId = $UAMI.ClientId
            #>
            $samiId = "979adfbf-214a-4171-beaf-f51ed094ba00"
            $AzureContext = (Connect-AzAccount -Identity -AccountId $samiId).context

	        # set and store context
	        $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

            # Stop the Resource Manager VM
            Write-Verbose "Stopping the VM - $ResourceName - in resource group - $ResourceGroupName -" -Verbose
            Stop-AzVM -Name $ResourceName -ResourceGroupName $ResourceGroupName -DefaultProfile $AzureContext -Force
            # [OutputType(PSAzureOperationResponse")]
        }
        else {
            # ResourceType not supported
            Write-Error "$ResourceType is not a supported resource type for this runbook."
        }
    }
    else {
        # The alert status was not 'Activated' or 'Fired' so no action taken
        Write-Verbose ("No action taken. Alert status: " + $status) -Verbose
    }
}
else {
    # Error
    Write-Error "This runbook is meant to be started from an Azure alert webhook only."
}