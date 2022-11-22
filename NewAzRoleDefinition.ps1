<#
https://learn.microsoft.com/en-us/azure/role-based-access-control/tutorial-custom-role-powershell
#>
  try 
    { 
       $CurrUser = Get-AzADUser -SignedIn
    } 
    catch
    { 
    
        Write-Host "You're not connected.";
        $AzConnection = Connect-AzAccount -Environment AzureUSGovernment
    }

Connect-AzAccount -Environment AzureUSGovernment
$CurrUser = Get-AzADUser -SignedIn
$UserPrincipalName = $CurrUser.UserPrincipalName
$subScope = "/subscriptions/" + (Get-AzSubscription).Id
Get-AzRoleAssignment -SignInName $UserPrincipalName -Scope $subScope


#$subScope = (Get-AzSubscription).Id
#to get the list of operations for the Microsoft.Support resource provider:
Get-AzProviderOperation "Microsoft.Support/*" | FT Operation, Description -AutoSize

#output the Reader role in JSON format.
Get-AzRoleDefinition -Name "Reader" | ConvertTo-Json | Out-File C:\GitHub\PowerShellGoodies\ReaderSupportRole.json
Get-AzRoleDefinition -Name "User Access Administrator" | ConvertTo-Json | Out-File C:\GitHub\PowerShellGoodies\UserAccessAdministrator.json
Get-AzRoleDefinition  | ConvertTo-Json | Out-File C:\GitHub\PowerShellGoodies\AzRoleDefinitions.json



Get-AzRoleAssignment -SignInName $UserPrincipalName -Scope $subScope
#Get the ID of your subscription using the Get-AzSubscription command.
Get-AzSubscription

$global:DeployInfo = [ordered]@{
        ActiveDirectoryAuthority = "";
        ActiveDirectoryServiceEndpointResourceId = "";
        ApiAppObjectId = "";
        ApiAppRegName = "";
        ApiClientId = "";
        ApiClientSecret = "";
        ApiExisting = "$false";
        ApiServicePrincipalId = "";
        AppName = "";
        AzureKeyVaultDnsSuffix = "";
        ContributorRoleId = "";
        CurrUserName="";
        CurrUserId="";
        Environment = "";
        FileExists = "$false";
        GraphEndpoint = "";
        Location = "";
        ManagementPortalUrl = "";
        MgEnvironment =  "";
        REACT_APP_AAD_AUTHORITY = "https://login.microsoftonline.us/$AppId";
        REACT_APP_AAD_CLIENT_ID = "";
        REACT_APP_AAD_REDIRECT_URI = "";
        REACT_APP_DEFAULT_DATE_FORMAT = "";
        REACT_APP_DPP_API_ENDPOINT = "";
        REACT_APP_DPP_API_SCOPES = "array:api://$ApiClientId/.default";
        REACT_APP_DTS_AZ_STORAGE_URL = "";
        REACT_APP_GRAPH_ENDPOINT = "";
        REACT_APP_GRAPH_SCOPES = "array:User.Read";
        REACT_APP_LOGIN_SCOPES = "array:User.Read";
        REACT_APP_TRANSFER_HISTORY_POLLING_INTERVAL_MS = "";
		ResGroupName ="";
        ResourceManagerUrl = "";
        StorageEndpointSuffix = "";
        SubscriptionId = "";
        SubscriptionName = "";
        TemplateParameterFile = "";
        TenantId = "";
        TenantName = "";
        WebAppObjectId = "";
        WebAppRegName = "";
        WebClientId = "";
        WebClientServicePrincipalId = "";
        WebExisting = "$false";
    }


$RoleDefinitionFile = "C:\GitHub\dtp\Deploy\DTPStorageBlobDataReadWrite.json"

$JsonFile = "C:\GitHub\dtpResources\rg-dts-prod-lt\FunctionApp\lt-datatransferapiConfigurations.json"
$MyJsonObject = Get-Content $JsonFile -Raw | ConvertFrom-Json
$DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
$MyJsonObject.assignableScopes[0] = "/subscriptions/" + $DeployInfo.SubscriptionId

$MyJsonObject | ConvertTo-Json | Out-File $RoleDefinitionFile

$RoleAssignmentName = "DTP Storage Blob Data ReadWrite"
$CustomRoles = Get-AzRoleDefinition | ? {$_.IsCustom -eq $true -and $_.Name -eq $RoleAssignmentName}
$CustomRoleCount = ($CustomRoles | Measure-Object | Select Count).Count
$CustomRoleCount

if($CustomRoleCount -eq 0)
{
    New-AzRoleDefinition -InputFile $RoleDefinitionFile
    
}
else
{
    Write-Host "Custom role assignment: $RoleAssignmentName EXISTS"
}


$role = [Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition]::new()
$role.Name = 'Virtual Machine Operator 2'
$role.Description = 'Can monitor and restart virtual machines.'
$role.IsCustom = $true
$perms = 'Microsoft.Storage/*/read','Microsoft.Network/*/read','Microsoft.Compute/*/read'
$perms += 'Microsoft.Compute/virtualMachines/start/action','Microsoft.Compute/virtualMachines/restart/action'
$perms += 'Microsoft.Authorization/*/read'
$perms += 'Microsoft.ResourceHealth/availabilityStatuses/read'
$perms += 'Microsoft.Resources/subscriptions/resourceGroups/read'
$perms += 'Microsoft.Insights/alertRules/*','Microsoft.Support/*'
$role.Actions = $perms
$role.NotActions = (Get-AzRoleDefinition -Name 'Virtual Machine Contributor').NotActions
$subs = '/subscriptions/355e427a-6396-4164-bd2e-d0f24719ea04'
$role.AssignableScopes = $subs
New-AzRoleDefinition -Role $role



$role = Get-AzRoleDefinition -Name "Virtual Machine Contributor"

$role.Id = $null
$role.Name = "Virtual Machine Operator"
$role.Description = "Can monitor, start, and restart virtual machines."
$role.Actions.RemoveRange(0,$role.Actions.Count)
$role.Actions.Add("Microsoft.Compute/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/downloadRemoteDesktopConnectionFile/action")
$role.Actions.Add("Microsoft.Network/*/read")
$role.Actions.Add("Microsoft.Storage/*/read")
$role.Actions.Add("Microsoft.Authorization/*/read")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/resources/read")
$role.Actions.Add("Microsoft.Insights/alertRules/*")
$role.Actions.Add("Microsoft.Support/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/355e427a-6396-4164-bd2e-d0f24719ea04")

New-AzRoleDefinition -Role $role


#Create a custom role with the PSRoleDefinition object
$role = [Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition]::new()
$role.Name = 'DTP Storage Blob Data ReadWrite'
$role.Description = 'Allows a DTP user to read/write data appropriately to an assigned container.'
$role.IsCustom = $true
$perms = 'Microsoft.Storage/*/read','Microsoft.Network/*/read','Microsoft.Compute/*/read'
$perms += 'Microsoft.Compute/virtualMachines/start/action','Microsoft.Compute/virtualMachines/restart/action'
$perms += 'Microsoft.Authorization/*/read'
$perms += 'Microsoft.ResourceHealth/availabilityStatuses/read'
$perms += 'Microsoft.Resources/subscriptions/resourceGroups/read'
$perms += 'Microsoft.Insights/alertRules/*','Microsoft.Support/*'
$role.Actions = $perms
$role.NotActions = (Get-AzRoleDefinition -Name 'Virtual Machine Contributor').NotActions
$subs = '/subscriptions/355e427a-6396-4164-bd2e-d0f24719ea04'
$role.AssignableScopes = $subs
New-AzRoleDefinition -Role $role


$RoleDefinitionFile = "C:\GitHub\dtp\Deploy\DTP_Storage_Blob_Data_ReadWrite.json"

$RoleDefinitionFile = "C:\GitHub\dtp\Deploy\DTPStorageBlobDataReadWrite.json"
$RoleDefinitionFileOut="C:\GitHub\dtp\Deploy\DTPStorageBlobDataReadWriteOut.json"
$MyJsonObject = Get-Content $RoldeDefinitionFile -Raw | ConvertFrom-Json
$DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
$MyJsonObject.assignableScopes[0] = "/subscriptions/" + $DeployInfo.SubscriptionId

$MyJsonObject | ConvertTo-Json | Out-File $RoleDefinitionFileOut

if( (Get-AzRoleDefinition | ? {$_.IsCustom -eq $true} | FT Name, IsCustom) -eq $false){
    Write-Host "no custom role assignment"
}
else
{
    New-AzRoleDefinition -InputFile $RoleDefinitionFileOut
}


$JsonFile = "C:\GitHub\dtpResources\rg-dts-prod-lt\FunctionApp\lt-datatransferapiConfigurations.json"
$RoleDefinitionFileOut = "C:\GitHub\dtpResources\rg-dts-prod-lt\FunctionApp\lt-datatransferapiConfigurations.txt"
$MyJsonObject = Get-Content $JsonFile -Raw | ConvertFrom-Json
$PropNameArr =@()
$mylist = [System.Collections.Generic.List[string]]::new()
$i=0
foreach ($item in $MyJsonObject)
{
    #Write-Host $item.name "=" $item.value
    $myList.Add( $item.name +","+ $item.value)
    $i++
}


$mylist | Out-File $RoleDefinitionFileOut

$mylist | ConvertTo-Json | Out-File $RoleDefinitionFileOut

#Foreach-Object

Function global:PrintHash{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    Foreach-Object ($item in $object.keys)    
    {         
        Write-Host -ForegroundColor Cyan $item.name "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHash


#read file content

#$MyJsonObject = Get-Content $RoldeDefinitionFile | ConvertFrom-Json

<#
{
  "Name": "Reader Support Tickets",
  "IsCustom": true,
  "Description": "View everything in the subscription and also open support tickets.",
  "Actions": [
    "*/read",
    "Microsoft.Support/*"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/00000000-0000-0000-0000-000000000000"
  ]
}

{
  "properties": {
      "roleName": "DTP Storage Blob Data ReadWrite",
      "description": "Allows a DTP user to read/write data appropriately to an assigned container.",
      "assignableScopes": [
          "/subscriptions/{subscriptionID}"
      ],
      "permissions": [
          {
              "actions": [
                  "Microsoft.Storage/storageAccounts/blobServices/containers/read"
              ],
              "notActions": [],
              "dataActions": [
                  "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
                  "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
                  "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
                  "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
              ],
              "notDataActions": []
          }
      ]
  }
}
#>

Function global:AddDTPCustomRoleFromFile
{
    Param(
        [Parameter(Mandatory = $true)] [string] $FilePath
      )
          
    $RoleDefinitionFile = "C:\GitHub\dtp\Deploy\DTPStorageBlobDataReadWrite.json"
        
    $ParentFolderPath = ((Get-ItemProperty (Split-Path (Get-Item ($RoleDefinitionFile)).FullName -Parent) | select FullName).FullName)
    $RoleDefinitionFileOut = $ParentFolderPath + "\" + $(Get-Item ($RoleDefinitionFile)).BaseName + "Out.json"
        
    Write-Host -ForegroundColor Cyan "filepath: " $RoleDefinitionFile
    Write-Host -ForegroundColor Cyan "filepath: " $RoleDefinitionFileOut    
    Write-Host -ForegroundColor Cyan "DeployInfo.SubscriptionId: " $DeployInfo.SubscriptionId
    
    $MyJsonObject = Get-Content $RoleDefinitionFile -Raw | ConvertFrom-Json
    #$DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
    $MyJsonObject.assignableScopes[0] = "/subscriptions/" + $DeployInfo.SubscriptionId

    $MyJsonObject | ConvertTo-Json | Out-File $RoleDefinitionFileOut

    $RoleAssignmentName = "DTP Storage Blob Data ReadWrite"
    $CustomRoles = Get-AzRoleDefinition | ? {$_.IsCustom -eq $true -and $_.Name -eq $RoleAssignmentName}
    $CustomRoleCount = ($CustomRoles | Measure-Object | Select Count).Count
    $CustomRoleCount

    if($CustomRoleCount -eq 0)
    {
        New-AzRoleDefinition -InputFile $RoleDefinitionFile
    
    }
    else
    {
        Write-Host -ForegroundColor Red -BackgroundColor White "Custom role assignment: $RoleAssignmentName EXISTS"
    }
}#AddDTPCustomRole



Function global:AddDTPCustomRoleFromFile
{
    Param(
        [Parameter(Mandatory = $true)] [string] $FilePath
      )

    $RoleDefinitionFile = $FilePath

    $ParentFolderPath = ((Get-ItemProperty (Split-Path (Get-Item ($RoleDefinitionFile)).FullName -Parent) | select FullName).FullName)
    $RoleDefinitionFileOut = $ParentFolderPath + "\" + $(Get-Item ($RoleDefinitionFile)).BaseName + "Out.json"
    
    Write-Host -ForegroundColor Cyan "FilePath:" $FilePath
    Write-Host -ForegroundColor Cyan "RoleDefinitionFile:" $RoleDefinitionFile
    Write-Host -ForegroundColor Cyan "RoleDefinitionFileOut:" $RoleDefinitionFileOut    
    Write-Host -ForegroundColor Cyan "DeployInfo.SubscriptionId:" $DeployInfo.SubscriptionId
    
    $MyJsonObject = Get-Content $RoleDefinitionFile -Raw | ConvertFrom-Json
    $MyJsonObject.assignableScopes[0] = "/subscriptions/" + $DeployInfo.SubscriptionId

    $MyJsonObject | ConvertTo-Json | Out-File $RoleDefinitionFileOut

    $RoleAssignmentName = "DTP Storage Blob Data ReadWrite"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan " [$today] ADD CUSTOM ROLE:" $RoleAssignmentName "SCOPE: SUBSCRIPTION"
    Write-Host -ForegroundColor Cyan "================================================================================"    

    $CustomRoles = Get-AzRoleDefinition | ? {$_.IsCustom -eq $true -and $_.Name -eq $RoleAssignmentName}
    $CustomRoleCount = ($CustomRoles | Measure-Object | Select Count).Count
    $CustomRoleCount

    #$RoleDefinitionFilePath = (Get-Item ($RoleDefinitionFile)).FullName

    if($CustomRoleCount -eq 0)
    {        
        New-AzRoleDefinition -InputFile $RoleDefinitionFileOut
        Write-Host -ForegroundColor DarkGreen -BackgroundColor White "Added custom role assignment: $RoleAssignmentName, continuing deployment...."
    }
    else
    {
        Write-Host -ForegroundColor Red -BackgroundColor White "Custom role assignment: $RoleAssignmentName EXISTS"
    }

}#AddDTPCustomRoleFromFile


$RoleDefinitionFile = "C:\GitHub\dtp\Deploy\DTPStorageBlobDataReadWrite.json"
AddDTPCustomRoleFromFile -FilePath $RoleDefinitionFile