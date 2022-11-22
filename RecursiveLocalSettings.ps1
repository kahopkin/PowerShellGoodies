#RecursiveLocalSettings
Function global:RecursiveLocalSettings
{
    Param(            
        [Parameter(Mandatory = $false)] [string] $JsonFilePath
       ,[Parameter(Mandatory = $true)] [string] $LocalSettingsFilePath
       ,[Parameter(Mandatory = $true)] [string] $LocalSettingsFileName

    )
    
 #   $json = Get-Content $JsonFilePath
 #   $jsonObj = $json | ConvertFrom-Json

    foreach ($property in $jsonObj.PSObject.Properties) 
    {
        $propType = $property.Value.GetType().BaseType.FullName      
        #Write-Host -ForegroundColor Green "Property=" $property.Name
        #Write-Host -ForegroundColor Green  $property.Name
        #Write-Host -ForegroundColor Yellow $propType
        #Write-Host -ForegroundColor Cyan "Value="$property.Value 
        if($propType -eq "System.Object")        
        {
            Write-Host -ForegroundColor Green $propType 
            
        }
        else
        {
            Write-Host -ForegroundColor Yellow "Property=" $property.Name
        }
         
    }#foreach ($property in $jsonObj.PSObject.Properties) 
            
        #$hash[$property.Name] = $property.Value      
        #$propType = $property.Value.GetType().BaseType.FullName       
        #$LocalSettingsHash.($property.Name)
        # $LocalSettingsHash.Values.Keys
        foreach ($property in $jsonObj.Value.PSObject.Properties) 
        {
            #Write-Host -ForegroundColor Cyan $prop.Name"="$prop.Name
            #Write-Host -ForegroundColor Yellow $prop.Value #"="$prop.Name
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
                
                $LocalSettingsHash.($property.Name).Add($property.Name, $DTPLocalSettingsHash.Name)
                #$LocalSettingsHash.($property.Name) = ( $DTPLocalSettingsHash.Name)
                Write-Host -ForegroundColor Cyan $LocalSettingsHash.($property.Name) "="  $LocalSettingsHash.($property.Name)
                #foreach($prop in $property.Value.PSObject.Properties) 
                #Write-Host -ForegroundColor Yellow "Value=" $property.Value.PSObject.Properties
            }
            else{
                #Write-Host -ForegroundColor Green $property.Name"="$property.Value
                Write-Host -ForegroundColor Green "Property=" $prop.Name
                #Write-Host -ForegroundColor Green "Value="$prop.Value           
            }
        }#foreach(($prop in $property.Value.PSObject.Properties)
    #}#foreach ($property in $jsonObj.PSObject.Properties) 

  <#
    $json = ConvertTo-Json $LocalSettingsHash
    $json > $LocalSettingsFile	
  #>
}#BuildLocalSettingsFile


$dtpResources = "C:\GitHub\dtpResources"
$currMonth =  Get-Date -Format 'MM'
$MonthFolderPath = $dtpResources + "\" +  $currMonth
#Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[251] MonthFolderPath="  $MonthFolderPath
$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')

$JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"
$LocalSettingsFileName = "JsonProps.txt"
$LocalSettingsFilePath = $MonthFolderPath + "\" +  $TodayFolder + "\"

$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
Write-Host -ForegroundColor Yellow "================================================================================"
Write-Host -ForegroundColor Yellow "[$today] START RecursiveLocalSettings:" $RootFolder
Write-Host -ForegroundColor Cyan "================================================================================"
Write-Host -ForegroundColor Green "`tPARAMETERS:"
Write-Host -ForegroundColor Green "`$JsonFilePath=`"$JsonFilePath`""   
Write-Host -ForegroundColor Green "`$LocalSettingsFilePath=`"$LocalSettingsFilePath`""
Write-Host -ForegroundColor Green "`$LocalSettingsFileName=`"$LocalSettingsFileName`""
Write-Host -ForegroundColor Green "================================================================================"
      
$TestFilePath = $LocalSettingsFilePath + $LocalSettingsFileName
Write-Host -ForegroundColor Green "`$TestFilePath=`"$TestFilePath`""
if ((Test-Path $TestFilePath) -eq $false)  
{
    $LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
    #Write-Host "[27] Created new LocalSettingsFile:" $LocalSettingsFile.FullName 
    #$LocalSettingsFilePath = 
} #env file does not exist
else    
{
    #Write-Host -ForegroundColor yellow "[150] Removed and re-created env file:" $EnvFile.FullName 
    Remove-Item -Path $TestFilePath 
    $LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
    #Write-Host -ForegroundColor GREEN "[34] Delete and create:" $LocalSettingsFile.FullName 
}


$json = Get-Content 'C:\GitHub\dtp\Deploy\logs\DeploymentOutput.json' | Out-String | ConvertFrom-Json
#Write-Host "UtilityFunctions[18] json.Tenant:" $json.Tenant

$global:DeployInfo = [ordered]@{
        ActiveDirectoryAuthority = $json.ActiveDirectoryAuthority;
        ApiAppObjectId = $json.ApiAppObjectId;
        ApiAppRegName = $json.ApiAppRegName;
        ApiClientId = $json.ApiClientId;
        ApiClientSecret = $json.ApiClientSecret;
        ApiExisting = $false;
        ApiServicePrincipalId = $json.ApiServicePrincipalId;
        AppName = $json.AppName;
        AuditStorageAccessKey = $json.AuditStorageAccessKey
        AuditStorageAccountName = $json.AuditStorageAccountName;            
        AzureKeyVaultDnsSuffix = $json.AzureKeyVaultDnsSuffix;
        ClientAppObjectId = $json.ClientAppObjectId;
        ClientAppRegName = $json.ClientAppRegName;
        ClientAppId = $json.ClientAppId;
        ClientAppServicePrincipalId = $json.ClientAppServicePrincipalId;
		ClientApp = $false;
        ContributorRoleId = $json.ContributorRoleId;
        CurrUserId = $json.CurrUserId;
        CurrUserName = $json.CurrUserName;
        Environment = $json.Environment;
        FileExists = $false;
        GraphUrl = $json.GraphUrl;
        MyIP = $json.MyIP
        Location = $json.Location;
        ManagementPortalUrl = $json.ManagementPortalUrl;  
        ResGroupName = $json.ResGroupName;
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
        UserPrincipalName = $json.UserPrincipalName;
    }  
#>
          
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
    AuditStorageAccessKey = $DeployInfo.AuditStorageAccessKey;
    AzEnvAuthenticationEndpoint = $DeployInfo.ActiveDirectoryAuthority;
    AzEnvGraphEndpoint = $DeployInfo.GraphUrl;
    AzEnvKeyVaultSuffix = $DeployInfo.AzureKeyVaultDnsSuffix;
    AzEnvManagementEndpoint = $DeployInfo.ServiceManagementUrl;
    AzEnvName = $DeployInfo.Environment;
    AzEnvResourceManagerEndpoint = $DeployInfo.ManagementPortalUrl;
    AzEnvStorageEndpointSuffix = $DeployInfo.StorageEndpointSuffix;
    AzStorageAccessKey = $DeployInfo.AzStorageAccessKey;
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
    AzureWebJobsStorage = $DeployInfo.AzureWebJobsStorage;
    blobEndpoint = $DeployInfo.blobEndpoint;
    clientID = $DeployInfo.ClientAppId;
    clientSecret = $DeployInfo.$DeployInfo.ApiClientSecret;
    completedContainerName = 'completedContainers';
    createCTSContainer = $false;
    ctsStorageSASUri = 'ctsStorageSASUri';
    deleteAuditBlobContainerName = "insights-logs-storagedelete";
    FUNCTIONS_WORKER_RUNTIME = "dotnet";
    readAuditBlobContainerName = "insights-logs-storageread";
    roleDefinitionId = $DeployInfo.RoleDefinitionId;
    sentinelTimer = "0 59 23 * * *";
    SqlConnectionString = $DeployInfo.SqlConnectionString;
    storageAccountResourceID = $DeployInfo.StorageAccountResourceID;
    subscriptionID = $DeployInfo.SubscriptionId;
    tenantID = $DeployInfo.TenantId;
    validationTimeOut = "10";
    writeAuditBlobContainerName = "insights-logs-storagewrite";
}  
      
$jsonObj = Get-Content $JsonFilePath | Out-String | ConvertFrom-Json
     
BuildLocalSettingsFile -JsonFilePath $JsonFilePath `
    -LocalSettingsFilePath $LocalSettingsFilePath `
    -LocalSettingsFileName $LocalSettingsFileName
#>

