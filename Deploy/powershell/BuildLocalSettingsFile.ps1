#BuildLocalSettingsFile
Function global:BuildLocalSettingsFile
{
    Param(          
        [Parameter(Mandatory = $false)] [string] $JsonFilePath
       ,[Parameter(Mandatory = $true)]  [string] $LocalSettingsFilePath
       ,[Parameter(Mandatory = $false)] [string] $LocalSettingsFileName
       ,[Parameter(Mandatory = $true)]  [Object] $DeployObject
       ,[Parameter(Mandatory = $true)]  [Object] $Cloud 
       ,[Parameter(Mandatory = $false)] [Object] $DeploymentOutput

    )
    
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "[$today] START BuildLocalSettingsFile:" $RootFolder
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Green "PARAMETERS:"
    Write-Host -ForegroundColor Green "`$JsonFilePath=`"$JsonFilePath`""   
    Write-Host -ForegroundColor Green "`$LocalSettingsFilePath=`"$LocalSettingsFilePath`""
    Write-Host -ForegroundColor Green "`$LocalSettingsFileName=`"$LocalSettingsFileName`""
    Write-Host -ForegroundColor Green "================================================================================"
    #> 
       
    $DeploymentName = $DeployObject.DeploymentName
    
    #Write-Host -ForegroundColor Yellow "BuildLocalSettingsFile[26]"
    #Write-Host "`$DeploymentName=`"$DeploymentName`""
    If($DeploymentOutput -eq $null){
        $DeploymentOutput = Get-AzDeployment -DeploymentName $DeploymentName
    }
    #Write-Host -ForegroundColor Magenta $DeploymentOutput.Outputs
       
    $TestFilePath = $LocalSettingsFilePath + $LocalSettingsFileName
    #Write-Host -ForegroundColor Yellow "`$TestFilePath=`"$TestFilePath`""

    if ((Test-Path $TestFilePath) -eq $false)  
    {
        $LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
        #Write-Host "BuildLocalSettingsFile[34] Created new LocalSettingsFile:" $LocalSettingsFile.FullName 
        #$LocalSettingsFilePath = 
    } #env file does not exist
    else    
    {
        #Write-Host -ForegroundColor yellow "[150] Removed and re-created env file:" $EnvFile.FullName 
        Remove-Item -Path $TestFilePath 
        $LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
        #Write-Host -ForegroundColor GREEN "BuildLocalSettingsFile[42] Delete and create:" $LocalSettingsFile.FullName 
    }
    #Write-Host -ForegroundColor Yellow "`$LocalSettingsFile=`"$LocalSettingsFile`""
   
    #$AuditStorageAccessKey = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    $AzureContext = Get-AzContext        
    
    $currContextTenantId = $AzureContext.Subscription.TenantId
    $subscriptionId = $AzureContext.Subscription.Id

    $LocalSettingsHash = @{}
    $LocalSettingsHash = @{
        IsEncrypted = $false;
        Host = @{};
        Values = @{};
    }

    $localSettingsJson = @()
    $hash = @{}
    #read json into a hash
    $DTPLocalSettingsHash = @{
        AuditStorageAccessKey = $DeploymentOutput.Outputs.auditStorageAccessKey.Value;
        AzEnvAuthenticationEndpoint = $Cloud.ActiveDirectoryAuthority;
        AzEnvGraphEndpoint = $Cloud.GraphUrl;
        AzEnvKeyVaultSuffix = $Cloud.AzureKeyVaultDnsSuffix;
        AzEnvManagementEndpoint = $Cloud.ServiceManagementUrl;
        AzEnvName = $Cloud.Name;
        AzEnvResourceManagerEndpoint = $Cloud.ResourceManagerUrl;
        AzEnvStorageEndpointSuffix = $Cloud.StorageEndpointSuffix;
        AzStorageAccessKey = $DeploymentOutput.Outputs.azStorageAccessKey.Value;
        'AzureWebJobs.ActivateSentinel.Disabled' = $true;
        'AzureWebJobs.CreateBlobContainer.Disabled' = $false;
        'AzureWebJobs.DeployARMTemplate.Disabled' = $true;
        'AzureWebJobs.GetAuditLogData.Disabled' = $false;
        'AzureWebJobs.GetUserSASToken.Disabled' = $false;
        'AzureWebJobs.GetUserTransferRequests.Disabled' = $false;
        'AzureWebJobs.MarkTransferComplete.Disabled' = $false;
        'AzureWebJobs.ReinstateRolesForUser.Disabled' = $false;
        'AzureWebJobs.RemoveRolesForUser.Disabled' = $false;
        'AzureWebJobs.RevokeAllUserDelegationKeys.Disabled' = $false;
        'AzureWebJobs.TransferDeleteAuditBlob.Disabled' = $true;
        'AzureWebJobs.TransferMessageToTable.Disabled' = $true;
        'AzureWebJobs.TransferReadAuditBlob.Disabled' = $true;
        'AzureWebJobs.TransferWriteAuditBlob.Disabled' = $true;
        'AzureWebJobs.ValidateTransferContainer.Disabled' = $true;
        AzureWebJobsStorage = $DeploymentOutput.Outputs.azureWebJobsStorage.Value;
        blobEndpoint = $DeploymentOutput.Outputs.blobEndpoint.Value;
        clientID = $DeployObject.APIAppRegAppId;
        clientSecret = $DeployObject.APIAppRegClientSecret;
        completedContainerName = 'completedContainers';
        createCTSContainer = $false;
        ctsStorageSASUri = 'ctsStorageSASUri';
        deleteAuditBlobContainerName = "insights-logs-storagedelete";
        FUNCTIONS_WORKER_RUNTIME = "dotnet";
        readAuditBlobContainerName = "insights-logs-storageread";
        roleDefinitionId = $DeployObject.RoleDefinitionId;
        sentinelTimer = "0 59 23 * * *";
        SqlConnectionString = $DeploymentOutput.Outputs.sqlConnectionString.Value;
        storageAccountResourceID = $DeploymentOutput.Outputs.storageAccountResourceID.Value;
        subscriptionID = $subscriptionId;
        tenantID = $currContextTenantId;
        validationTimeOut = "10";
        writeAuditBlobContainerName = "insights-logs-storagewrite";
    }  
    <# 
    Write-Host -ForegroundColor Cyan "BuildLocalSettingsFile[108] DTPLocalSettingsHash="
     $Caller='BuildLocalSettingsFile[109]: DTPLocalSettingsHash'       
    PrintObject -object $DTPLocalSettingsHash -Caller $Caller
    #>
    #Write-Host -ForegroundColor Yellow "`$JsonFilePath=`"$JsonFilePath`""
    $jsonObj = Get-Content $JsonFilePath | Out-String | ConvertFrom-Json
    #$json = Get-Content $JsonFilePath
    #$jsonObj = $json | ConvertFrom-Json
    foreach ($property in $jsonObj.PSObject.Properties) 
    {        
        #$hash[$property.Name] = $property.Value      
        $propType = $property.Value.GetType().BaseType.FullName       
        #$LocalSettingsHash.($property.Name)
        #$LocalSettingsHash.Values.Keys
        foreach ($prop in $property.Value.PSObject.Properties) 
        {
            #Write-Host -ForegroundColor Cyan $prop.Name "=" $prop.Value
            #Write-Host -ForegroundColor Yellow "prop.Value=" $prop.Name
            #Write-Host -ForegroundColor Cyan $prop.Name 
            <#if($property.Name -eq 'Values')
            {
                $prop.Name  >> $TestFilePath
            }
            #>
            #Write-Host -ForegroundColor Cyan "Value="$prop.Value 
            if($propType -eq "System.Object")        
            {          
                #Write-Host -ForegroundColor Green $propType 
                #Write-Host -ForegroundColor Yellow "Property=" $property.Name
                
                $LocalSettingsHash.($property.Name).Add($prop.Name, $DTPLocalSettingsHash.Name)
                #$LocalSettingsHash.($property.Name) = ( $DTPLocalSettingsHash.Name)
                #Write-Host -ForegroundColor Yellow $LocalSettingsHash.($property.Name) "="  $LocalSettingsHash.($property.Name)
                #foreach($prop in $property.Value.PSObject.Properties) 
                #Write-Host -ForegroundColor Yellow "Value=" $property.Value.PSObject.Properties
            }
            else{
                #Write-Host -ForegroundColor Green $property.Name"="$property.Value
                Write-Host -ForegroundColor Green "Property=" $property.Name
                #Write-Host -ForegroundColor Green "Value="$property.Value           
            }

        }#foreach(($prop in $property.Value.PSObject.Properties)
    }#foreach ($property in $jsonObj.PSObject.Properties) 
    <#Write-Host -ForegroundColor Green "BuildLocalSettingsFile[152] DTPLocalSettingsHash="
    $Caller='BuildLocalSettingsFile[153]: DTPLocalSettingsHash'       
    PrintObject -object $DTPLocalSettingsHash -Caller $Caller
  #>
    $json = ConvertTo-Json $LocalSettingsHash
    $json > $LocalSettingsFile	
  #>
}#BuildLocalSettingsFile

<#
$dtpResources = "C:\GitHub\dtpResources"
$currMonth =  Get-Date -Format 'MM'
$MonthFolderPath = $dtpResources + "\" +  $currMonth
#Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[251] MonthFolderPath="  $MonthFolderPath
$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')

$JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"
$LocalSettingsFileName = "JsonProps.txt"
$LocalSettingsFilePath = $MonthFolderPath + "\" +  $TodayFolder + "\"

BuildLocalSettingsFile -JsonFilePath $JsonFilePath `
    -LocalSettingsFilePath $LocalSettingsFilePath `
    -LocalSettingsFileName $LocalSettingsFileName
#>



<#


Function global:PrintHashKeyValue{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    foreach ($item in $object.GetEnumerator())    
    {   
        write-host -ForegroundColor Cyan $item.key "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHashKeyValue
#>
<#

  foreach ($Item in $LocalSettingsHash.GetEnumerator()) 
{
   Write-Host "$($_.Key) is $($_.Value)"
}

foreach ($Item in $LocalSettingsHash) 
{
   "The value of key $($_.Key) is $($_.Value)"
}


#>

 <# 
    $json = Get-Content 'C:\GitHub\dtp\Deploy\logs\DeploymentOutput.Outputs.json' | Out-String | ConvertFrom-Json
    #Write-Host "UtilityFunctions[18] json.Tenant:" $json.Tenant

    $global:DeploymentOutput.Outputs. = [ordered]@{
            ActiveDirectoryAuthority = $json.ActiveDirectoryAuthority;
            APIAppRegObjectId = $json.APIAppRegObjectId;
            APIAppRegName = $json.APIAppRegName;
            APIAppRegAppId = $json.APIAppRegAppId;
            APIAppRegClientSecret = $json.APIAppRegClientSecret;
            APIAppRegExists = $false;
            APIAppRegServicePrincipalId = $json.APIAppRegServicePrincipalId;
            AppName = $json.AppName;
            AuditStorageAccessKey = $json.AuditStorageAccessKey
            AuditStorageAccountName = $json.AuditStorageAccountName;            
            AzureKeyVaultDnsSuffix = $json.AzureKeyVaultDnsSuffix;
            ClientAppRegObjectId = $json.ClientAppRegObjectId;
            ClientAppRegName = $json.ClientAppRegName;
            ClientAppRegAppId = $json.ClientAppRegAppId;
            ClientAppRegServicePrincipalId = $json.ClientAppRegServicePrincipalId;
			ClientAppRegExists = $false;
            ContributorRoleId = $json.ContributorRoleId;
            CurrUserId = $json.CurrUserId;
            CurrUserName = $json.CurrUserName;
            Environment = $json.Environment;
            FileExists = $false;
            GraphUrl = $json.GraphUrl;
            MyIP = $json.MyIP
            Location = $json.Location;
            ManagementPortalUrl = $json.ManagementPortalUrl;  
            ResourceGroupName = $json.ResourceGroupName;
            RoleDefinitionId = $json.RoleDefinitionId;
            ServiceManagementUrl = $json.ServiceManagementUrl;
            Solution = $json.Solution;
            SqlConnectionString = $json.SqlConnectionString;
            StepCount = 1;
            StorageAccountName = $json.StorageAccountName;
            StorageAccountResourceID = $json.StorageAccountResourceID;
            StorageEndpointSuffix = $json.StorageEndpointSuffix;            
            SubscriptionId = $json.SubscriptionId;
            SubscriptionName = $json.SubscriptionName;
            TemplateParameterFile = $json.TemplateParameterFile;
            TenantId = $json.TenantId;
            TenantName = $json.TenantName;
            UserPrincipalName = $json.CurrUserPrincipalName;
        }  
    #>
