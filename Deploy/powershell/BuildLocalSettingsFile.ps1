#BuildLocalSettingsFile
Function global:BuildLocalSettingsFile
{
	Param(
			[Parameter(Mandatory = $false)] [string] $JsonFilePath
		,[Parameter(Mandatory = $true)]  [string] $LocalSettingsFilePath
		,[Parameter(Mandatory = $false)] [string] $LocalSettingsFileName
		,[Parameter(Mandatory = $true)]  [Object] $DeployObject
		#,[Parameter(Mandatory = $true)]  [Object] $Cloud
		,[Parameter(Mandatory = $false)] [Object] $DeploymentOutput

	)

	$Message = " START BuildLocalSettingsFile:"
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING BuildLocalSettingsFile.BuildLocalSettingsFile[19]"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		Write-Host -ForegroundColor Green "PARAMETERS:"
		Write-Host -ForegroundColor Cyan "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Green "`$JsonFilePath=`"$JsonFilePath`"" 
		Write-Host -ForegroundColor Green "`$LocalSettingsFilePath=`"$LocalSettingsFilePath`""
		Write-Host -ForegroundColor Green "`$LocalSettingsFileName=`"$LocalSettingsFileName`""
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	} 

	$DeploymentName = $DeployObject.DeploymentName

	If($DeploymentOutput -eq $null){
		$DeploymentOutput = Get-AzDeployment -DeploymentName $DeploymentName
	}

	$TestFilePath = $LocalSettingsFilePath + $LocalSettingsFileName

	If ((Test-Path $TestFilePath) -eq $false)
	{
		$LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
		#Write-Host "BuildLocalSettingsFile[34] Created new LocalSettingsFile:" $LocalSettingsFile.FullName
		#$LocalSettingsFilePath =
	} #env file does not exist
	Else
	{
		#Write-Host -ForegroundColor yellow "[150] Removed and re-created env file:" $EnvFile.FullName
		Remove-Item -Path $TestFilePath
		$LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
		#Write-Host -ForegroundColor GREEN "BuildLocalSettingsFile[42] Delete and create:" $LocalSettingsFile.FullName
	}
	#Write-Host -ForegroundColor Yellow "`$LocalSettingsFile=`"$LocalSettingsFile`""
 
	#$auditStorageAccessKey = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
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
		auditStorageAccessKey = $DeploymentOutput.Outputs.auditStorageAccessKey.Value;
		AzEnvAuthenticationEndpoint = $DeployObject.ActiveDirectoryAuthority;
		AzEnvGraphEndpoint = $DeployObject.GraphUrl;
		AzEnvKeyVaultSuffix = $DeployObject.AzureKeyVaultDnsSuffix;
		AzEnvManagementEndpoint = $DeployObject.ServiceManagementUrl;
		AzEnvName = $DeployObject.CloudEnvironment;
		AzEnvResourceManagerEndpoint = $DeployObject.ResourceManagerUrl;
		AzEnvStorageEndpointSuffix = $DeployObject.StorageEndpointSuffix;
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
		clientSecret = $DeployObject.APIAppRegSecret;
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
	 $Caller ='BuildLocalSettingsFile[109]: DTPLocalSettingsHash'
	PrintObject -Object $DTPLocalSettingsHash -Caller $Caller
	#>
	#Write-Host -ForegroundColor Yellow "`$JsonFilePath=`"$JsonFilePath`""
	$jsonObj = Get-Content $JsonFilePath | Out-String | ConvertFrom-Json
	#$json = Get-Content $JsonFilePath
	#$jsonObj = $json | ConvertFrom-Json
	ForEach ($property in $jsonObj.PSObject.Properties)
	{
			#$hash[$property.Name] = $property.Value
		$propType = $property.Value.GetType().BaseType.FullName
			#$LocalSettingsHash.($property.Name)
		#$LocalSettingsHash.Values.Keys
		ForEach ($prop in $property.Value.PSObject.Properties)
		{
			#Write-Host -ForegroundColor Cyan $prop.Name "=" $prop.Value
			#Write-Host -ForegroundColor Yellow "prop.Value=" $prop.Name
			#Write-Host -ForegroundColor Cyan $prop.Name
			<#If($property.Name -eq 'Values')
			{
				$prop.Name  >> $TestFilePath
			}
			#>
			#Write-Host -ForegroundColor Cyan "Value="$prop.Value
			If($propType -eq "System.Object")
			 {
				 #Write-Host -ForegroundColor Green $propType
				#Write-Host -ForegroundColor Yellow "Property=" $property.Name

				 $LocalSettingsHash.($property.Name).Add($prop.Name, $DTPLocalSettingsHash.Name)
				#$LocalSettingsHash.($property.Name) = ( $DTPLocalSettingsHash.Name)
				#Write-Host -ForegroundColor Yellow $LocalSettingsHash.($property.Name) "="  $LocalSettingsHash.($property.Name)
				#ForEach($prop in $property.Value.PSObject.Properties)
				#Write-Host -ForegroundColor Yellow "Value=" $property.Value.PSObject.Properties
			}
			Else{
				#Write-Host -ForegroundColor Green $property.Name"="$property.Value
				Write-Host -ForegroundColor Green "Property=" $property.Name
				#Write-Host -ForegroundColor Green "Value="$property.Value
			 }

		}#ForEach(($prop in $property.Value.PSObject.Properties)
	}#ForEach ($property in $jsonObj.PSObject.Properties)
	<#Write-Host -ForegroundColor Green "BuildLocalSettingsFile[152] DTPLocalSettingsHash="
	$Caller ='BuildLocalSettingsFile[153]: DTPLocalSettingsHash'
	PrintObject -Object $DTPLocalSettingsHash -Caller $Caller
	#>
	$json = ConvertTo-Json $LocalSettingsHash
	$json > $LocalSettingsFile	
	#>
}#BuildLocalSettingsFile
