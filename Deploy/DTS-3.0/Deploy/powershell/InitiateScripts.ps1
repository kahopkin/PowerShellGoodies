#InitiateScripts
Function global:InitializeAzResourcesComplexObj
{
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Caller = "`n[" + $today + "] STARTING InitiateScripts.InitializeAzResourcesComplexObj[8]"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
	}#If($debugFlag)#>

	$Message = "INITIALIZE COMPLEX OBJECT FOR AZURE RESOURCES:"
	#$Object.StepCount = PrintMessage -Message $Message -StepCount $Object.StepCount
	#PrintMessageToFile -Message $Message -StepCount $Object.StepCount -LogFile $Object.LogFile

	$AzResourcesComplexObj = [ordered]@{
		VirtualNetwork = [ordered]@{
			Name = "Virtual Network";
			Description = "Create and configure the Virtual Network";
			#ResourceName = $Object.VirtualNetworkName;
			ResourceName = '';
			ResourceType = "Microsoft.Network/virtualNetworks"
			PropertyName = "VirtualNetworkResourceId";
		};
		ManagedUser = [ordered]@{
			Name = "Managed User";
			Description = "Create and configure the Managed User";
			#ResourceName = $Object.ManagedUserName;
			ResourceName = '';
			ResourceType = "Microsoft.ManagedIdentity/userAssignedIdentities";
			PropertyName = "ManagedUserPrincipalId";
		};
		KeyVault = [ordered]@{
			Name = "Key Vault";
			Description = "Create and configure the Key Vault";
			#ResourceName = $Object.KeyVaultName;
			ResourceName = '';
			ResourceType = "Microsoft.KeyVault/vaults";
			PropertyName = "KeyVaultResourceId";
		};
		AuditStorage = [ordered]@{
			Name = "Audit Storage Account";
			Description = "Create and configure the Audit Storage Account";
			#ResourceName = $Object.AuditStorageName;
			ResourceName = '';
			ResourceType = "Microsoft.Storage/storageAccounts";
			PropertyName = "AuditStorageSystemPrincipalId";
		};
		MainStorage = [ordered]@{
			Name = "Main Storage Account";
			Description = "Create and configure the Main Storage Account";
			#ResourceName = $Object.MainStorageName;
			ResourceName = '';
			ResourceType = "Microsoft.Storage/storageAccounts";
			PropertyName = "MainStorageSystemPrincipalId";
		};
		WebSite = [ordered]@{
			Name = "Web Site";
			Description = "Create and configure the Web Site";
			#ResourceName = $Object.$SolutionObjName.ClientAppRegName;
			ResourceName = '';
			ResourceType = "Microsoft.Web/sites";
			PropertyName = "WebSiteSystemPrincipalId";
		};
		FunctionApp = [ordered]@{
			Name = "Function App";
			Description = "Create and configure the Function App";
			#ResourceName = $Object.$SolutionObjName.APIAppRegName;
			ResourceName = '';
			ResourceType = "Microsoft.Web/sites";
			PropertyName = "FunctionAppSystemPrincipalId";
		};
		SQL = [ordered]@{
			Name = "SQL Server";
			Description = "Create and configure the SQL Server and database";
			#ResourceName = $Object.SqlServerName;
			ResourceName = '';
			ResourceType = "Microsoft.Sql/servers";
			PropertyName = "SqlSystemPrincipalId";
		};
		VirtualMachine = [ordered]@{
			Name = "Virtual Machine";
			Description = "Create and configure the Virtual Machine";
			#ResourceName = $Object.VMName;
			ResourceName = '';
			ResourceType = "Microsoft.Compute/virtualMachines";
			PropertyName = "VirtualMachinePrincipalId";
		};
	}#$AzResourcesComplexObj

	<#
	If($debugFlag){
		$ObjectName = "AzResourcesComplexObj"
		$Caller = "`InitiateScripts.InitializeAzResourcesComplexObj[860]::" + $ObjectName
		PrintCustomObjectAsObject -Object $AzResourcesComplexObj -Caller $Caller -ObjectName $ObjectName					
	  }#If($debugFlag)#>
	return $AzResourcesComplexObj
}#InitializeAzResourcesComplexObj


Function global:InitializeAzResources
{
	Param(
		[Parameter(Mandatory = $false)] [Object]$AzResourcesComplexObj
	)
	$AzResources = @()
	$i = 0

	ForEach ($item in $AzResourcesComplexObj.Keys)
	{
		$AzResources += $item
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black $item
		$i++
	}#ForEach
	return $AzResources
}#InitializeAzResourcesObj


Function global:InitializeAzResourcesObj
{
	Param(
		[Parameter(Mandatory = $false)] [Object]$AzResourcesComplexObj
	)
	$AzResourcesObj = [ordered]@{}
	$i = 1

	ForEach ($item in $AzResourcesComplexObj.Keys)
	{
		#$AzResourcesObj[$i] = $AzResourcesComplexObj.$item.Name
		$AzResourcesObj[$item] = $false;
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] :" $AzResourcesComplexObj.$item.Name ":" $AzResourcesComplexObj.$item.Description
		$i++
	}#foreach
	return $AzResourcesObj
}#InitializeAzResourcesObj


Function global:InitializeDeployObject
{
	Param(
			[Parameter(Mandatory = $true)] [Int32] $StepCount
	)
	$BicepFile = $BicepFolder + "main.bicep"
	$ParamFileName = "DeploymentParameters.json"
	$ParamFilePath = $DeployFolder + $ParamFileName
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING InitiateScripts.InitializeDeployObject[181]"
		#$BicepFile = $BicepFolder + "mainTest.bicep";
		Write-Host -ForegroundColor White "`$BicepFile = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$BicepFile`""
		Write-Host -ForegroundColor White "`$DeployParameterFile = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ParamFilePath`""
	}#If($debugFlag)#>

	$global:DeployObject = [ordered]@{
		DebugFlag = $debugFlag;

		CloudEnvironment = $null;
		Location = $null;
		Environment = $null;
		AppName = $null;
		DeployMode = $null;

		DeployComponents = $null;
		AzureResources = $null; 
		SolutionName = $null;
		SolutionNameSt = $null;
		DeploymentName = $null;
		ResourceGroupName = $null;

		APIAppRegName = $null;
		APIAppRegAppId = $null;
		APIAppRegObjectId = $null;
		APIAppRegSecret = $null;
		APIAppRegSecretAsPlainText = $null;
		APIAppRegServicePrincipalId = $null;
		APIAppRegExists = $false;

		ClientAppRegName = $null;
		ClientAppRegAppId = $null;
		ClientAppRegObjectId = $null;
		ClientAppRegSecret = $null;
		ClientAppRegServicePrincipalId = $null;
		ClientAppRegExists = $false;

		FunctionAppName = $null;
		FunctionAppSystemPrincipalId = $null;
		FunctionAppResourceId = $null;
		FunctionAppExists = $false;

		WebSiteName = $null;
		WebSiteSystemPrincipalId = $null;
		WebSiteResourceId = $null;
		WebSiteExists = $false;

		VirtualNetworkName = $null;
		VirtualNetworkResourceId = $null;
		VirtualNetworkExists = $false;

		ManagedUserName = $null;
		ManagedUserPrincipalId = $null;
		ManagedUserResourceId = $null;
		ManagedUserExists = $false;

		KeyVaultName = $null ;
		KeyVaultResourceId = $null;
		KeyVaultUri = $null;
		KeyVaultExists = $false;

		AuditStorageName = $null;
		AuditStorageSystemPrincipalId = $null;
		AuditStorageKeyName = $null;
		AuditStorageResourceId = $null;
		AuditStorageExists = $false;

		MainStorageName = $null
		MainStorageSystemPrincipalId = $null;
		MainStorageKeyName = $null;
		MainStorageResourceId = $null;
		MainStorageExists = $false;

		SqlServerName = $null;
		SqlAdmin = $null;
		SqlAdminPwd = $null;
		SqlAdminPwdAsPlainText = $null;
		SqlKeyName = $null;
		SqlSystemPrincipalId = $null;
		SqlResourceId = $null;
		SqlExists = $false;

		VirtualMachineName = $null;
		VirtualMachineResourceId = $null;
		VirtualMachineExists = $false;

		DefaultWorkspaceId = $null;
		DefaultWorkspaceName = $null;
		DefaultWorkspaceLocation = $null;

		SubscriptionName = $null;
		SubscriptionId = $null;
		TenantName = $null;
		TenantId = $null;

		ActiveDirectoryAuthority = $null;
		AzureKeyVaultDnsSuffix = $null;
		GraphUrl = $null;
		ManagementPortalUrl = $null;
		ServiceManagementUrl = $null;
		StorageEndpointSuffix = $null;
		REACT_APP_GRAPH_ENDPOINT = $null;
		REACT_APP_DTS_AZ_STORAGE_URL = $null;

		OpenIdIssuer = $null;
		WebDomain = $null;
		DnsSuffix = $null;
		GraphEndPoint = $null;
		GraphVersion = $null;
		AddressPrefix = $null;
		AddressSpace = $null;

		CurrUserName = $null;
		CurrUserId = $null;
		CurrUserPrincipalName = $null;

		DeveloperGroupId = $null;
		MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
		StepCount = $StepCount;

		RoleDefinitionName = $null;
		RoleDefinitionId = $null;
		CryptoEncryptRoleId = $null;
		ContributorRoleId = $null;

		BuildFlag = $null;
		PublishFlag = $null;

		DeployFolder = $DeployFolder;
		LogFile = $LogFile;
		RoleDefinitionFile =  $DeployFolder + "DTPStorageBlobDataReadWrite.json";
		DeployParameterFile = $ParamFilePath;
		BicepFile = $BicepFile;
		TemplateParameterFile = $TemplateDir;
		OutFileJSON = $OutFileJSON;

		StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss";
		EndTime = $null;
		Duration = $null;
		#TransferAppObj = $null;
	}#DeployObject
	$Message = "INITIALIZING DeployObject OBJECT THAT WILL COLLECT AND STORE ALL DEPLOYMENT RELATED DATA"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

	return $DeployObject
}#InitializeDeployObject


Function global:SetDeployFolder
{
	Param(
	[Parameter(Mandatory = $true)] [Int32] $StepCount
	)

	$Message = "SETTING DEPLOYMENT FOLDER PATH LOCATIONS"
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING InitiateScripts.SetDeployFolder[13]"
	}#If($debugFlag)#>

	$StepCount = PrintMessage -Message $Message -StepCount $StepCount

	$global:currDir = Get-Item (Get-Location)
	$global:currDirPath = ($currDir.FullName).toLower()
	#this is where the repository code files are
	#figure out a way to do whole word case insensitive find
	$LastIndexOf = ($currDirPath).LastIndexOf("deploy")

	$global:RootFolder = $currDirPath.Substring(0,$LastIndexOf)

	$RootFolderParentPath = ((Get-ItemProperty (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)

	$global:DeployFolder = $RootFolder + "Deploy\"
	$global:BicepFolder = $DeployFolder + "Bicep\"
	#this is where the templates for the .env files are
	$global:TemplateDir = $DeployFolder + "LocalSetUp\"

	#
	If($debugFlag){
		Write-host -ForegroundColor White  "`$currDir=`"$currDir`""
		Write-host -ForegroundColor Green  "`$currDirPath=`"$currDirPath`""
		Write-Host -ForegroundColor White "`$RootFolder= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$RootFolder`""
		#Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""
		Write-Host -ForegroundColor White "`$DeployFolder= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$DeployFolder`""

		Write-Host -ForegroundColor White "`$BicepFolder= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$BicepFolder`""

		Write-Host -ForegroundColor White "`$TemplateDir= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$TemplateDir`""
	}#debugFlag #>
	Else
	{
		Write-Host -ForegroundColor White -NoNewline "Deploy Folder Path: "
		Write-Host -ForegroundColor Yellow -BackgroundColor Black $DeployFolder
		Write-Host -ForegroundColor White -NoNewline "Bicep Folder Path: "
		Write-Host -ForegroundColor Yellow -BackgroundColor Black $BicepFolder
	}
	return $StepCount
}#SetDeployFolder


Function global:SetLogFolderPath
{
	Param(
		[Parameter(Mandatory = $true)] [Int32] $StepCount
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING InitiateScripts.SetLogFolderPath[68]"
	}#If($debugFlag)#>

	$LogsFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
	$LogsFolder = Get-ChildItem -Path  $LogsFolderParentPath | `
							Where-Object { `
							($_.PSIsContainer -eq $true) -and `
							$_.FullName -match 'deploy\\logs' }

	$global:LogsFolderPath = $LogsFolder.FullName + "\"

	If($LogsFolder -eq $null)
	{
		$folderName ="logs"
		$LogsFolder = New-Item -Path $LogsFolderParentPath -Name $folderName -ItemType Directory
		$LogsFolderPath = (Get-ItemProperty  $LogsFolder | select FullName).FullName + "\"
	}
	Else
	{
		$LogsFolderPath = $LogsFolder.FullName  + "\"
	}

	$Message = "THE LOGS CAN BE FOUND IN THE FOLDER:"
	$StepCount = PrintMessage -Message $Message -StepCount $StepCount

	#
	If($debugFlag)
	{
		Write-Host -ForegroundColor White -NoNewline "`$LogsFolderPath= "
		Write-Host -ForegroundColor Cyan "`"$LogsFolderPath`""
	}
	Else
	{
		Write-Host -ForegroundColor White -NoNewline "Logs Folder Path: "
		Write-Host -ForegroundColor Cyan $LogsFolderPath
	}
	return $StepCount
}#SetLogFolderPath


Function global:SetOutputFileNames
{
	  Param(
			[Parameter(Mandatory = $true)] [Int32] $StepCount
		, [Parameter(Mandatory = $false)] [Object] $DeployObject
	)
	$Message = "SETTING OUTPUT FILE NAMES:"
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING InitiateScripts.SetOutputFileNames[120]"
		#Write-Host -ForegroundColor Cyan "DeployObject==null: " ($DeployObject -eq $null)
	}#If($debugFlag)#>

	$ParamFileName = "DeploymentParameters.json"
	$ParamFilePath = $DeployFolder + $ParamFileName

	If($DeployObject -eq $null)
	{
		Write-Host -ForegroundColor Cyan "InitiateScripts.SetOutputFileNames[128] DeployObject==null: " ($DeployObject -eq $null)
		$todayShort = Get-Date -Format 'MM-dd-yyyy'
		$fileNamePrefix = "DeployLog_"  + $todayShort
		$JsonFileName = $fileNamePrefix  +  ".json"
		$LogFileName = $fileNamePrefix + "_Log.txt"
		$LogFile = $LogsFolderPath + $LogFileName
		$OutFileJSON = $LogsFolderPath + $JsonFileName
	}#If($debugFlag)#>
	Else
	{
		$fileNamePrefix =   $DeployObject.TenantName + "_" +
							$DeployObject.AppName + "_" +
							$DeployObject.Environment
		$JsonFileName = $fileNamePrefix  +  ".json"
		$LogFileName = $fileNamePrefix + "_Log.txt"
		$LogFile = $DeployObject.LogFile = $LogsFolderPath + $LogFileName
		$DeployObject.DeployParameterFile = $ParamFilePath
		$OutFileJSON = $DeployObject.OutFileJSON = $LogsFolderPath + $JsonFileName
	}
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	#
	If($debugFlag)
	{
		Write-Host -ForegroundColor White -NoNewline "`$LogsFolderPath= "
		Write-Host -ForegroundColor Cyan "`"$LogsFolderPath`""

		Write-Host -ForegroundColor White -NoNewline "`$LogFile= "
		Write-Host -ForegroundColor Cyan "`"$LogFile`""

		Write-Host -ForegroundColor White -NoNewline "`$OutFileJSON= "
		Write-Host -ForegroundColor Cyan "`"$OutFileJSON`""
	}
	Else
	{
		Write-Host -ForegroundColor White -BackgroundColor Black "JSON output file:"
		Write-Host -ForegroundColor Green -BackgroundColor Black $OutFileJSON
		Write-Host -ForegroundColor White -BackgroundColor Black "Output Log file:"
		Write-Host -ForegroundColor Green -BackgroundColor Black $LogFile
	}   
}#SetOutputFileNames


Function global:SetDeployInfoObj
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING InitiateScripts.SetDeployInfoObj[408]"
	}#If($debugFlag)#>
	$Message = "SETTING AZURE ENVIRONMENT SPECIFIC PROPERTIES"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

	$AzureContext = Get-AzContext
	If($AzureContext -eq $null)
	{
		ConnectToAzure -DeployObject $DeployObject
	} #$AzureContext -eq $null
	Else
	{
		$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
		$psCommand = "`$SubscriptionTenant = Get-AzTenant `` `n`t`t" +
												"-TenantId `"" + $AzureContext.Subscription.HomeTenantId + "`" `n"
		#
		If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "InitiateScripts.SetDeployInfoObj[351]:"
			Write-Host -ForegroundColor Green $psCommand
		}#If($PrintPSCommands) #>

		$DeployObject.TenantName = $SubscriptionTenant.Name
		$DeployObject.TenantId = $SubscriptionTenant.Id

		If($DeployObject.SubscriptionName -eq $null){$DeployObject.SubscriptionName = $AzureContext.Subscription.Name}
		If($DeployObject.SubscriptionId -eq $null){$DeployObject.SubscriptionId = $AzureContext.Subscription.Id}

		If($DeployObject.CloudEnvironment -eq $null){$DeployObject.CloudEnvironment = $AzureContext.Environment.Name}
		$DeployObject.ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority + $DeployObject.TenantId;
		$DeployObject.AzureKeyVaultDnsSuffix = $AzureContext.Environment.AzureKeyVaultDnsSuffix
		$DeployObject.GraphUrl = $AzureContext.Environment.GraphUrl;# + "v1.0/me";
		$DeployObject.ManagementPortalUrl = $AzureContext.Environment.ManagementPortalUrl
		$DeployObject.ServiceManagementUrl = $AzureContext.Environment.ServiceManagementUrl
		$DeployObject.StorageEndpointSuffix = $AzureContext.Environment.StorageEndpointSuffix

		$CurrUser = Get-AzADUser -SignedIn
		$DeployObject.CurrUserName = $CurrUser.DisplayName
		$DeployObject.CurrUserPrincipalName = $CurrUser.UserPrincipalName
		$DeployObject.CurrUserId = $CurrUser.Id

		$RoleDefinitionName = "Storage Blob Data Contributor"
		$RoleDefinitionId = (Get-AzRoleDefinition -Name $RoleDefinitionName | Select Id).Id
		$DeployObject.RoleDefinitionName = $RoleDefinitionName
		$DeployObject.RoleDefinitionId = $RoleDefinitionId
		$RoleName = "Key Vault Crypto Service Encryption User"
		$DeployObject.CryptoEncryptRoleId = (Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.Name -eq $RoleName}).Id
		$RoleName = "Contributor"
		$DeployObject.ContributorRoleId = (Get-AzRoleDefinition -Name $RoleName | Select Id).Id

		$GroupName = "CONTRIBUTOR - SUB - DEV"
		$Group = Get-AzADGroup -DisplayName $GroupName
		$DeployObject.DeveloperGroupId = $Group.Id

		$DefaultWorkspaces = (Get-AzOperationalInsightsWorkspace | Where-Object {$_.Name -match 'Default' -and $_.Location -eq $DeployObject.Location})
		$psCommand = "`n`$DefaultWorkspaces = `n`t`(Get-AzOperationalInsightsWorkspace  ```n`t`t" +
									" | Where-Object {`$_.Name -match `"Default`" -and `$_.Location -eq `"" + $DeployObject.Location + "`"})"
		#
		If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "InitiateScripts.SetDeployInfoObj[535]:"
			$Location = $DeployObject.Location
			Write-Host -ForegroundColor Cyan "`$DeployObject.Location= `"$Location`""
			Write-Host -ForegroundColor Green $psCommand
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		}#If($PrintPSCommands) #>

		If($DefaultWorkspaces -eq $null)
		{
			$DeployObject.DefaultWorkspaceName = $null
			$DeployObject.DefaultWorkspaceId = $null
			$DeployObject.DefaultWorkspaceLocation = $null
		}
		ElseIf($DefaultWorkspaces -isnot $null -and $DefaultWorkspaces.GetType().BaseType.Name -eq "Array")
		{
			Write-Host -ForegroundColor Cyan "BaseType= " $DefaultWorkspaces.GetType().BaseType.Name
			ForEach($Workspace in $DefaultWorkspaces)
			{
				If($Workspace.Name -inotmatch "USB")
				{					
					$DeployObject.DefaultWorkspaceName = $Workspace.Name
					$DeployObject.DefaultWorkspaceId = $Workspace.ResourceId
					$DeployObject.DefaultWorkspaceLocation = $Workspace.Location
					Write-Host -ForegroundColor Cyan "`DefaultWorkspaceName= " $Workspace.Name
					Write-Host -ForegroundColor Cyan "`DefaultWorkspaceId= " $Workspace.ResourceId
					Write-Host -ForegroundColor Cyan "`DefaultWorkspaceLocation= " $Workspace.Location
				}
				Else
				{
					Write-Host -ForegroundColor Yellow "`DefaultWorkspaceName= " $Workspace.Name
					Write-Host -ForegroundColor Yellow "`DefaultWorkspaceId= " $Workspace.ResourceId
					Write-Host -ForegroundColor Yellow "`DefaultWorkspaceLocation= " $Workspace.Location
				}
			}	
		}#If($DefaultWorkspaces.GetType().BaseType.Name -eq "Array")
		Else
		{
			$DeployObject.DefaultWorkspaceName = $DefaultWorkspaces.Name
			$DeployObject.DefaultWorkspaceId = $DefaultWorkspaces.ResourceId
			$DeployObject.DefaultWorkspaceLocation = $DefaultWorkspaces.Location
		}

		Write-Host -ForegroundColor Green "`DefaultWorkspaceName= " $DeployObject.DefaultWorkspaceName
		Write-Host -ForegroundColor Green "`DefaultWorkspaceId= " $DeployObject.DefaultWorkspaceId
		Write-Host -ForegroundColor Green "`DefaultWorkspaceLocation= " $DeployObject.DefaultWorkspaceLocation

		<#
		$DeployObject.DefaultWorkspaceName =
		$DefaultWorkspaceName = (Get-AzOperationalInsightsWorkspace | Where-Object {$_.Name -match 'Default' -and $_.Location -eq $DeployObject.Location}).Name
		$psCommand = "`$DefaultWorkspaceName = `n`t`(Get-AzOperationalInsightsWorkspace  ```n`t`t" +
									" | Where-Object {`$_.Name -match `"Default`" -and `$_.Location -eq `"" + $DeployObject.Location + "`"}).Name"
		#>
		<#
		If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "InitiateScripts.SetDeployInfoObj[455]:"
			Write-Host -ForegroundColor Green $psCommand
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		}#If($PrintPSCommands) #>

		<#
		If($DefaultWorkspaceName.GetType().BaseType.Name -eq "Array")
		{			
			ForEach($Workspace in $DefaultWorkspaceName)
			{
				If($Workspace -inotmatch "USB")
				{
					$DeployObject.DefaultWorkspaceName = $Workspace
				}
			}			
		}
		#>
	
		<#
		$DeployObject.DefaultWorkspaceId =
		$DefaultWorkspaceId = (Get-AzOperationalInsightsWorkspace | Where-Object {$_.Name -match 'Default' -and $_.Location -eq $DeployObject.Location}).ResourceId
		$psCommand = "`$DefaultWorkspaceLocation = `n`t`(Get-AzOperationalInsightsWorkspace  ```n`t`t" +
									" | Where-Object {`$_.Name -match `"Default`" -and `$_.Location -eq  `"" + $DeployObject.Location + "`"}).ResourceId"
		#>
		<#
		If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "InitiateScripts.SetDeployInfoObj[466]:"
			Write-Host -ForegroundColor Green $psCommand
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		}#If($PrintPSCommands) #>

		<#
		If($DefaultWorkspaceName.GetType().BaseType.Name -eq "Array")
		{			
			ForEach($Workspace in $DefaultWorkspaceName)
			{
				If($Workspace -inotmatch "USB")
				{
					$DeployObject.DefaultWorkspaceName = $Workspace
				}
			}			
		}

		$DeployObject.DefaultWorkspaceLocation =
		$DefaultWorkspaceLocation = (Get-AzOperationalInsightsWorkspace | Where-Object {$_.Name -match 'Default' -and $_.Location -eq $DeployObject.Location}).Location
		$psCommand = "`$DefaultWorkspaceLocation = `n`t`(Get-AzOperationalInsightsWorkspace  ```n`t`t" +
									" | Where-Object {`$_.Name -match `"Default`" -and `$_.Location -eq `"" + $DeployObject.Location + "`"}).Location"
		#>
		<#
		If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "InitiateScripts.SetDeployInfoObj[479]:"
			Write-Host -ForegroundColor Green $psCommand
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		}#If($PrintPSCommands) #>

		<#
		If($DefaultWorkspaceLocation.GetType().BaseType.Name -eq "Array")
		{			
			ForEach(WorkspaceLocation in $DefaultWorkspaceLocation)
			{
				If(WorkspaceLocation -inotmatch "USB")
				{
					$DeployObject.DefaultWorkspaceName = $Workspace
				}
			}			
		}
		#>
		$DeployObject.OpenIdIssuer = $DeployObject.OpenIdIssuer + "/" + $DeployObject.TenantId + "/v2.0"
	}#ElseIf($AzureContext NOT $null)

	$DeployObject.MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
	<#
	If($debugFlag){
		$ObjectName = "DeployObject"
		$Caller = "InitiateScripts.SetDeployInfoObj[573] AFTER SetDeployInfoObj finished" + $ObjectName
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
		PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#>
}#SetDeployInfoObj


Function global:SetDeployInfoPropsFromFile
{
	Param(
		[Parameter(Mandatory = $true)] [String] $FilePath
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	$Message = "SETTING DeployObject OBJECT`'S PROPERTIES FROM FILE:" + $FilePath
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING InitiateScripts.SetDeployInfoPropsFromFile[475]"
		Write-Host -ForegroundColor White "`$FilePath=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$FilePath`""
	}#If($debugFlag)#>
	Else
	{
		#Write-Host -ForegroundColor White -BackgroundColor Black "FilePath= " -NoNewline
		#Write-Host -ForegroundColor Green "`"$FilePath`""
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}

	#If the json file exists: populate the DeployObject object's properties					
	If (Test-Path ($FilePath) )
	{
		$FullPath = (Get-ChildItem -Path ($FilePath) | select FullName).FullName
		#Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "`$FullPath=`"$FullPath`""
		$json = Get-Content $FullPath | Out-String | ConvertFrom-Json
		$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

		If($DeployObject.DebugFlag -eq $null){ $DeployObject.DebugFlag = $json.DebugFlag;}
		If($DeployObject.DeploymentName -eq $null){ $DeployObject.DeploymentName = $json.DeploymentName;}
		#If($DeployObject.SolutionObjName -eq $null){$DeployObject.SolutionObjName = $json.SolutionObjName;}
		#If($DeployObject.DeployMode -eq $null){ $DeployObject.DeployMode = $json.DeployMode;}
		#If($DeployObject.DeployComponents -eq $null){ $DeployObject.DeployComponents = $json.DeployComponents;}
		#If($DeployObject.AzureResources -eq $null){$DeployObject.AzureResources = $json.AzureResources;}
		If($DeployObject.CloudEnvironment -eq $null){ $DeployObject.CloudEnvironment = $json.CloudEnvironment;}
		If($DeployObject.Location -eq $null){ $DeployObject.Location = $json.Location;}
		If($DeployObject.Environment -eq $null){ $DeployObject.Environment = $json.Environment;}
		If($DeployObject.AppName -eq $null){ $DeployObject.AppName = $json.AppName;}

		If($DeployObject.ResourceGroupName -eq $null){$DeployObject.ResourceGroupName = $json.ResourceGroupName;}

		If($DeployObject.BicepFile -eq $null){ $DeployObject.BicepFile = $json.BicepFile;}
		If($DeployObject.TemplateParameterFile -eq $null){ $DeployObject.TemplateParameterFile = $json.TemplateParameterFile;}
		If($DeployObject.OutFileJSON -eq $null){ $DeployObject.OutFileJSON = $json.OutFileJSON;}
		If($DeployObject.LogFile -eq $null){ $DeployObject.LogFile = $json.LogFile;}

		If($DeployObject.SubscriptionName -eq $null){ $DeployObject.SubscriptionName = $json.SubscriptionName;}
		If($DeployObject.SubscriptionId -eq $null){ $DeployObject.SubscriptionId = $json.SubscriptionId;}
		If($DeployObject.TenantName -eq $null){ $DeployObject.TenantName = $json.TenantName;}
		If($DeployObject.TenantId -eq $null){ $DeployObject.TenantId = $json.TenantId;}

		If($DeployObject.APIAppRegName -eq $null){ $DeployObject.APIAppRegName = $json.APIAppRegName;}
		If($DeployObject.APIAppRegAppId -eq $null){ $DeployObject.APIAppRegAppId = $json.APIAppRegAppId;}
		If($DeployObject.APIAppRegObjectId -eq $null){ $DeployObject.APIAppRegObjectId = $json.APIAppRegObjectId;}
		If($DeployObject.APIAppRegSecret -eq $null){ $DeployObject.APIAppRegSecret = $json.APIAppRegSecret;}
		If($DeployObject.APIAppRegSecretAsPlainText -eq $null){ $DeployObject.APIAppRegSecretAsPlainText = $json.APIAppRegSecretAsPlainText;}

		If($DeployObject.APIAppRegServicePrincipalId -eq $null){ $DeployObject.APIAppRegServicePrincipalId = $json.APIAppRegServicePrincipalId;}
		If($DeployObject.APIAppRegExists -eq $null){ $DeployObject.APIAppRegExists = $json.APIAppRegExists;}

		If($DeployObject.ClientAppRegName -eq $null){ $DeployObject.ClientAppRegName = $json.ClientAppRegName;}
		If($DeployObject.ClientAppRegAppId -eq $null){ $DeployObject.ClientAppRegAppId = $json.ClientAppRegAppId;}
		If($DeployObject.ClientAppRegObjectId -eq $null){ $DeployObject.ClientAppRegObjectId = $json.ClientAppRegObjectId;}
		If($DeployObject.ClientAppRegSecret -eq $null){ $DeployObject.ClientAppRegSecret = $json.ClientAppRegSecret;}
		If($DeployObject.ClientAppRegServicePrincipalId -eq $null){ $DeployObject.ClientAppRegServicePrincipalId = $json.ClientAppRegServicePrincipalId;}
		If($DeployObject.ClientAppRegExists -eq $null){ $DeployObject.ClientAppRegExists = $json.ClientAppRegExists;}

		If($DeployObject.FunctionAppName -eq $null){ $DeployObject.FunctionAppName = $json.FunctionAppName;}
		If($DeployObject.WebSiteName -eq $null){ $DeployObject.WebSiteName = $json.WebSiteName;}

		If($DeployObject.ActiveDirectoryAuthority -eq $null){ $DeployObject.ActiveDirectoryAuthority = $json.ActiveDirectoryAuthority;}
		If($DeployObject.AzureKeyVaultDnsSuffix -eq $null){ $DeployObject.AzureKeyVaultDnsSuffix = $json.AzureKeyVaultDnsSuffix;}
		If($DeployObject.GraphUrl -eq $null){ $DeployObject.GraphUrl = $json.GraphUrl;}
		If($DeployObject.ManagementPortalUrl -eq $null){ $DeployObject.ManagementPortalUrl = $json.ManagementPortalUrl;}
		If($DeployObject.ServiceManagementUrl -eq $null){ $DeployObject.ServiceManagementUrl = $json.ServiceManagementUrl;}
		If($DeployObject.StorageEndpointSuffix -eq $null){ $DeployObject.StorageEndpointSuffix = $json.StorageEndpointSuffix;}
		If($DeployObject.REACT_APP_GRAPH_ENDPOINT -eq $null){ $DeployObject.REACT_APP_GRAPH_ENDPOINT = $json.REACT_APP_GRAPH_ENDPOINT;}
		If($DeployObject.REACT_APP_DTS_AZ_STORAGE_URL -eq $null){ $DeployObject.REACT_APP_DTS_AZ_STORAGE_URL = $json.REACT_APP_DTS_AZ_STORAGE_URL;}

		If($DeployObject.CurrUserName -eq $null){ $DeployObject.CurrUserName = $json.CurrUserName;}
		If($DeployObject.CurrUserId -eq $null){ $DeployObject.CurrUserId = $json.CurrUserId;}
		If($DeployObject.CurrUserPrincipalName -eq $null){ $DeployObject.CurrUserPrincipalName = $json.CurrUserPrincipalName;}
		If($DeployObject.DeveloperGroupId -eq $null){ $DeployObject.DeveloperGroupId = $json.DeveloperGroupId;}
		If($DeployObject.MyIP -eq $null){ $DeployObject.MyIP = $json.MyIP;}

		If($DeployObject.CryptoEncryptRoleId -eq $null){ $DeployObject.CryptoEncryptRoleId = $json.CryptoEncryptRoleId;}
		If($DeployObject.ContributorRoleId -eq $null){ $DeployObject.ContributorRoleId = $json.ContributorRoleId;}

		If($DeployObject.WebSiteSystemPrincipalId -eq $null){$DeployObject.WebSiteSystemPrincipalId = $json.WebSiteSystemPrincipalId;}
		If($DeployObject.WebSiteResourceId -eq $null){$DeployObject.WebSiteResourceId = $json.WebSiteResourceId;}
		If($DeployObject.WebSiteExists -eq $null){$DeployObject.WebSiteExists = $json.WebSiteExists;}

		If($DeployObject.VirtualNetworkName -eq $null){$DeployObject.VirtualNetworkName = $json.VirtualNetworkName;}
		If($DeployObject.VirtualNetworkResourceId -eq $null){$DeployObject.VirtualNetworkResourceId = $json.VirtualNetworkResourceId;}
		If($DeployObject.VirtualNetworkExists -eq $null){$DeployObject.VirtualNetworkExists = $json.VirtualNetworkExists;}

		If($DeployObject.FunctionAppSystemPrincipalId -eq $null){$DeployObject.FunctionAppSystemPrincipalId = $json.FunctionAppSystemPrincipalId;}
		If($DeployObject.FunctionAppResourceId -eq $null){$DeployObject.FunctionAppResourceId = $json.FunctionAppResourceId;}
		If($DeployObject.FunctionAppExists -eq $null){$DeployObject.FunctionAppExists = $json.FunctionAppExists;}

		If($DeployObject.ManagedUserName -eq $null){ $DeployObject.ManagedUserName = $json.ManagedUserName;}
		If($DeployObject.ManagedUserPrincipalId -eq $null){ $DeployObject.ManagedUserPrincipalId = $json.ManagedUserPrincipalId;}
		If($DeployObject.ManagedUserResourceId -eq $null){$DeployObject.ManagedUserResourceId = $json.ManagedUserResourceId;}
		If($DeployObject.ManagedUserExists -eq $null){$DeployObject.ManagedUserExists = $json.ManagedUserExists;}

		If($DeployObject.KeyVaultName -eq $null){ $DeployObject.KeyVaultName = $json.KeyVaultName;}
		If($DeployObject.KeyVaultResourceId -eq $null){ $DeployObject.KeyVaultResourceId = $json.KeyVaultResourceId;}
		If($DeployObject.KeyVaultUri -eq $null){ $DeployObject.KeyVaultUri = $json.KeyVaultUri;}
		If($DeployObject.KeyVaultExists -eq $false){$DeployObject.KeyVaultExists = $json.KeyVaultExists;}

		If($DeployObject.AuditStorageName -eq $null){ $DeployObject.AuditStorageName = $json.AuditStorageName;}
		If($DeployObject.AuditStorageSystemPrincipalId -eq $null){ $DeployObject.AuditStorageSystemPrincipalId = $json.AuditStorageSystemPrincipalId;}
		If($DeployObject.AuditStorageKeyName -eq $null){ $DeployObject.AuditStorageKeyName = $json.AuditStorageKeyName;}
		If($DeployObject.AuditStorageResourceId -eq $null){$DeployObject.AuditStorageResourceId = $json.AuditStorageResourceId;}
		If($DeployObject.AuditStorageExists -eq $null){$DeployObject.AuditStorageExists = $json.AuditStorageExists;}

		If($DeployObject.MainStorageName -eq $null){ $DeployObject.MainStorageName = $json.MainStorageName;}
		If($DeployObject.MainStorageSystemPrincipalId -eq $null){ $DeployObject.MainStorageSystemPrincipalId = $json.MainStorageSystemPrincipalId;}
		If($DeployObject.MainStorageKeyName -eq $null){ $DeployObject.MainStorageKeyName = $json.MainStorageKeyName;}
		If($DeployObject.MainStorageResourceId -eq $null){$DeployObject.MainStorageResourceId = $json.MainStorageResourceId;}
		If($DeployObject.MainStorageExists -eq $null){$DeployObject.MainStorageExists = $json.MainStorageExists;}

		If($DeployObject.SqlServerName -eq $null){$DeployObject.SqlServerName = $json.SqlServerName;}
		If($DeployObject.SqlAdmin -eq $null){$DeployObject.SqlAdmin = $json.SqlAdmin;}
		If($DeployObject.SqlAdminPwd -eq $null){$DeployObject.SqlAdminPwd = $json.SqlAdminPwd;}
		If($DeployObject.SqlAdminPwdAsPlainText -eq $null){$DeployObject.SqlAdminPwdAsPlainText = $json.SqlAdminPwdAsPlainText;}

		If($DeployObject.SqlKeyName -eq $null){ $DeployObject.SqlKeyName = $json.SqlKeyName;}
		If($DeployObject.SqlSystemPrincipalId -eq $null){ $DeployObject.SqlSystemPrincipalId = $json.SqlSystemPrincipalId;}
		If($DeployObject.SqlResourceId -eq $null){$DeployObject.SqlResourceId = $json.SqlResourceId;}
		If($DeployObject.SqlExists -eq $null){$DeployObject.SqlExists = $json.SqlExists;}

		If($DeployObject.DefaultWorkspaceName -eq $null){ $DeployObject.DefaultWorkspaceName = $json.DefaultWorkspaceName;}
		If($DeployObject.DefaultWorkspaceId -eq $null){ $DeployObject.DefaultWorkspaceId = $json.DefaultWorkspaceId;}
		If($DeployObject.DefaultWorkspaceLocation -eq $null){ $DeployObject.DefaultWorkspaceLocation = $json.DefaultWorkspaceLocation;}

		If($DeployObject.VirtualMachineName -eq $null){$DeployObject.VirtualMachineName = $json.VirtualMachineName;}
		If($DeployObject.VirtualMachineResourceId -eq $null){$DeployObject.VirtualMachineResourceId = $json.VirtualMachineResourceId;}
		If($DeployObject.VirtualMachineExists -eq $null){$DeployObject.VirtualMachineExists = $json.VirtualMachineExists;}

		If($DeployObject.OpenIdIssuer -eq $null){ $DeployObject.OpenIdIssuer = $json.OpenIdIssuer;}
		If($DeployObject.WebDomain -eq $null){ $DeployObject.WebDomain = $json.WebDomain;}
		If($DeployObject.DnsSuffix -eq $null){ $DeployObject.DnsSuffix = $json.DnsSuffix;}
		If($DeployObject.GraphEndPoint -eq $null){$DeployObject.GraphEndPoint =  "https://" + $json.GraphEndPoint + "/";}
		If($DeployObject.GraphVersion -eq $null){ $DeployObject.GraphVersion = $json.GraphVersion;}

		If($DeployObject.AddressPrefix -eq $null){ $DeployObject.AddressPrefix = $json.AddressPrefix;}
		If($DeployObject.AddressSpace -eq $null){ $DeployObject.AddressSpace = $json.AddressSpace;}

		#If($DeployObject.BuildFlag -eq $null){ $DeployObject.BuildFlag = $json.BuildFlag;}
		#If($DeployObject.PublishFlag -eq $null){ $DeployObject.PublishFlag = $json.PublishFlag;}

		If($DeployObject.RoleDefinitionName -eq $null){ $DeployObject.RoleDefinitionName = $json.$DeployObject.RoleDefinitionName;}
		If($DeployObject.RoleDefinitionId -eq $null){ $DeployObject.RoleDefinitionId = $json.RoleDefinitionId;}
		If($DeployObject.RoleDefinitionFile -eq $null){ $DeployObject.RoleDefinitionFile = $json.RoleDefinitionFile;}
	}#If (Test-Path ($FilePath))
	Else
	{
		Write-Host -ForegroundColor Green -BackgroundColor Black "`"$FilePath`" does not exist YET..."
		Write-Host -ForegroundColor White -BackgroundColor Black " Continuing deployment...."
	}
}#SetDeployInfoPropsFromFile


Function global:ConfigureDeployInfo
{
	Param(
			[Parameter(Mandatory = $true)]  [Object] $DeployObject
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING InitiateScripts.ConfigureDeployInfo[696]"
	}#If($debugFlag)#>

	$Message = "CONFIGURING DEPLOYMENT SPECIFIC PROPERTIES"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

	<#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.ConfigureDeployInfo[670]"
		Write-Host -ForegroundColor Cyan "`$DeployObject.Environment=" $DeployObject.Environment
		Write-Host -ForegroundColor Cyan "`$DeployObject.Location=" $DeployObject.Location
		Write-Host -ForegroundColor Cyan "`$DeployObject.AppName=" $DeployObject.AppName
		Write-Host -ForegroundColor Cyan "`$DeployObject.DeployMode=" $DeployObject.DeployMode

		Write-Host -ForegroundColor Magenta "`nInitiateScripts.ConfigureDeployInfo[677]"
		$Caller ="InitiateScripts.ConfigureDeployInfo[687] ::"
		$ObjectName = "DeployObject"
		PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#>   


	$DeployObject.ResourceGroupName= "rg-"+ (Get-Culture).TextInfo.ToLower($DeployObject.AppName)  + "-" + (Get-Culture).TextInfo.ToLower($DeployObject.Environment)

	$DeployObject.DeploymentName = $DeployObject.AppName + "_" + $DeployObject.Environment

	#build the DeployObject.DeploymentName based on the solution that is being deployed
	$DeployObject.SolutionName= ($DeployObject.AppName).ToLower() + "-" + ($DeployObject.Environment).ToLower()
	$DeployObject.SolutionNameSt = $DeployObject.AppName.toLower() + $DeployObject.Environment.toLower()


	If( ("kv-" + $DeployObject.SolutionName).length -gt 23 )
	{
		$DeployObject.KeyVaultName =
		$AzResourcesComplexObj.KeyVault.ResourceName = ("kv-" + $DeployObject.SolutionName).Substring(0,24)
	}
	Else
	{
		$DeployObject.KeyVaultName =
		$AzResourcesComplexObj.KeyVault.ResourceName = "kv-" + $DeployObject.SolutionName
	}

	$DeployObject.ManagedUserName =
	$AzResourcesComplexObj.ManagedUser.ResourceName = "id-" + $DeployObject.SolutionName

	$DeployObject.VirtualNetworkName =
	$AzResourcesComplexObj.VirtualNetwork.ResourceName = "vnet-" + $DeployObject.SolutionName

	If( ("staudit" + $DeployObject.SolutionNameSt + "00").length -gt 23 )
	{
		$DeployObject.AuditStorageName =
		$AzResourcesComplexObj.AuditStorage.ResourceName = ("staudit" + $DeployObject.SolutionNameSt + "00").Substring(0,24)
	}
	Else
	{
		$DeployObject.AuditStorageName =
		$AzResourcesComplexObj.AuditStorage.ResourceName = "staudit" + $DeployObject.SolutionNameSt + "001"
	}

	If( ("st" + $DeployObject.SolutionNameSt + "001").length -gt 23 )
	{
		$DeployObject.MainStorageName =
		$AzResourcesComplexObj.MainStorage.ResourceName = ("st" + $DeployObject.SolutionNameSt + "001").Substring(0,24)
	}
	Else
	{
		$DeployObject.MainStorageName =
		$AzResourcesComplexObj.MainStorage.ResourceName = "st" + $DeployObject.SolutionNameSt + "001"
	}

	$DeployObject.VirtualMachineName =
	$AzResourcesComplexObj.VirtualMachine.ResourceName = "vm-" + $DeployObject.SolutionName
	$DeployObject.SqlServerName =
	$AzResourcesComplexObj.SQL.ResourceName = "sql-" + $DeployObject.SolutionName
	#$DeployObject.OutFileJSON =
	If($DeployObject.Environment -ieq "Prod")
	{
		$DeployObject.TemplateParameterFile = $BicepFolder + "main.parameters.prod.json"
	}
	Else
	{
		$DeployObject.TemplateParameterFile = $BicepFolder + "main.parameters.dev.json"
	}# If($DeployObject.Environment -eq "Prod")
	$DeployObject.OpenIdIssuer = $DeployObject.OpenIdIssuer + "/" + $DeployObject.TenantId + "/v2.0"
	<#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.ConfigureDeployInfo[808]"
		Write-Host -ForegroundColor Cyan "Location= " $DeployObject.Location
		Write-Host -ForegroundColor Cyan "Environment= " $DeployObject.Environment
		Write-Host -ForegroundColor Cyan "AppName= " $DeployObject.AppName
		Write-Host -ForegroundColor Cyan "DeployMode= " $DeployObject.DeployMode
		Write-Host -ForegroundColor Cyan "DeploymentName= " $DeployObject.DeploymentName
		Write-Host -ForegroundColor Green "TemplateParameterFile= " $DeployObject.TemplateParameterFile
		$Caller ="InitiateScripts.ConfigureDeployInfo[794] ::"
		$ObjectName = "DeployObject"
		PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#>   
}#ConfigureDeployInfo

