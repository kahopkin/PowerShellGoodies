#InitiateDeploymentProcess.ps1
<#
# Make sure that the user is in the right folder to run the script.
# Running the script is required to be in the dtp\deploy\powershell folder
#>
Import-Module -Name Microsoft.Graph.Applications

& "$PSScriptRoot\AddAPIPermissions.ps1"
& "$PSScriptRoot\AddRoleAssignment.ps1"
& "$PSScriptRoot\BuildLocalSettingsFile"
& "$PSScriptRoot\ConnectToMSGraph.ps1"
& "$PSScriptRoot\CreateAppRegistration.ps1"
& "$PSScriptRoot\CreateAppRoles.ps1"
& "$PSScriptRoot\CreateEnvironmentFiles.ps1"
& "$PSScriptRoot\CreateScopes.ps1"
& "$PSScriptRoot\CreateServicePrincipal.ps1"
& "$PSScriptRoot\InitiateScripts.ps1"
& "$PSScriptRoot\PreReqCheck.ps1"
& "$PSScriptRoot\PrintUtilityFunctions.ps1"
& "$PSScriptRoot\SetApplicationIdURI.ps1"
& "$PSScriptRoot\StartBicepDeploy.ps1"
& "$PSScriptRoot\UtilityFunctions.ps1"

$global:WarningAction = 
$global:ErrorAction = "SilentlyContinue"

$global:CurrUser =  $env:username 

$global:debugFlag =
$global:PrintPSCommands = 
$global:PickSubscriptionFlag =
$global:DeployObject =
$global:ParamFileObj = 
$global:DeployComponents =
$global:DeployConfigObj = 
#$global:AzureResourcesObj =
#$global:AzureResources =
#$global:AzResourcesObj =
#$global:AzResourcesComplexObj =
#$global:ComponentsChosen =
$global:LogsFolderPath =
$CloudEnvironment = 
$Location = 
$Environment = 
$AppName = 
$Solution = 
$AzureContext =
$createFileFlag = 
$uiDeployFlag = $null

$AzResourcesComplexObj = InitializeAzResourcesComplexObj
$AzureResources = InitializeAzResources -AzResourcesComplexObj $AzResourcesComplexObj
$AzResourcesObj = InitializeAzResourcesObj -AzResourcesComplexObj $AzResourcesComplexObj

$DeployComponents = (
	"AppRegistration", 
	"AzureInfrastructure", 
	"EnvFile", 
	"BuildArchives", 
	"PublishApps", 
	"CustomRole", 
	"RoleAssignments"
)

<#
# the values are for placeholders only.  This object is used to generate the parameter file if Deploy by File is chosen.
# No values are hard coded, these are simply placeholders for the user deploying to substitute
#>
$ParamFileObj = [ordered]@{
	DebugFlag = "`$true|`$false";
	DeployMode = "Partial|Full";
	CloudEnvironment = "AzureUSGovernment";
	Location = "Location";
	Environment = "Prod|Dev|Test";
	AppName = "AppName";
	#Solution = "Transfer";
	SqlAdmin = "SqlAdminName";
	SqlAdminPwd = "SqlAdminPwd";
	BuildFlag = "Yes|No";
	PublishFlag = "Yes|No";
	DeployComponents = $DeployComponents; 
	AzureResources = $AzureResources;
	OpenIdIssuer = "sts.windows.net|sts.windows.com";
	WebDomain = "azurewebsites.us|azurewebsites.com";
	DnsSuffix = "usgovcloudapi.net|uscloudapi.com";
	GraphEndPoint = "graph.microsoft.us|graph.microsoft.com";
	GraphVersion = "1.0";
	AddressPrefix = "10.10.0";
	AddressSpace = "22";
}#ParamFileObj

$DeployConfigObj = [ordered]@{ 
	AppRegistration = $false;
	AzureInfrastructure = $false;
	EnvFile = $false;
	BuildArchives = $false;
	PublishApps = $false;
	RoleAssignments = $false;
}#DeployConfigObj

$AzResourcesComplexObj = InitializeAzResourcesComplexObj
$AzureResources = InitializeAzResources -AzResourcesComplexObj $AzResourcesComplexObj
$AzResourcesObj = InitializeAzResourcesObj -AzResourcesComplexObj $AzResourcesComplexObj

$PrintPSCommands = $false

$StepCount = 0

PrintWelcomeMessage

#
If($CurrUser -eq "kahopkin")
{
	$WarningAction = "Continue"
	$PrintPSCommands = $true
	#$PrintPSCommands = $false
	$debugFlag = $true
	#$uiDeployFlag = $true
	#$createFileFlag = $true
	#$PickSubscriptionFlag = "1"
	#CheckGraphApplicationModule
}
Else
{
	$debugFlag =  $null;
	$PrintPSCommands = $false;
	$StepCount = CheckInstallPrereqs -StepCount $StepCount
}#Else($debugFlag) #>

#CheckGraphApplicationModule
#UNCOMMENT BELOW LINE BEFORE CHECK IN!!!
#$StepCount = CheckInstallPrereqs -StepCount $StepCount

If($debugFlag -eq $null)
{
	$debugFlag = PickDebugMode 
}#($debugFlag -eq $null)

$StepCount = SetDeployFolder -StepCount $StepCount

If($currDirPath -match "\\powershell")
{
	#
	If($debugFlag)
	{ 
		$PrintPSCommands = $true
		$WarningAction = "Continue"	
	}#If($debugFlag)#>
	Else 
	{
		$WarningAction = "SilentlyContinue"
		$createFileFlag = $false
		$PrintPSCommands = $false
		#Give user a choice whether to run deployment using an input file or with the UI
		$uiDeployFlag = PickDeployMethod -DeployObject $DeployObject 
	}#Else($debugFlag) #>

	$StepCount = SetLogFolderPath -StepCount $StepCount

	#Initialize the DeployObject object and vars:
	$DeployObject = InitializeDeployObject -StepCount $StepCount
 
	$AllContexts = Get-AzContext -ListAvailable
	$psCommand = "`$AllContexts = Get-AzContext -ListAvailable"
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[162]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>

	If($AllContexts -eq $null)
	{
			ConnectToAzure -DeployObject $DeployObject 
	}
	ElseIf($AllContexts.Count -gt 1)
	{ 
		$AzureContext = SelectDeploymentContext -DeployObject $DeployObject -AllContexts $AllContexts
	}#Else(AzContext -gt 1) #>
	<#Else
	{
		Write-Host -ForegroundColor Red -BackgroundColor White "`$AllContexts.Count=" $AllContexts.Count
	}#($AllContexts.Count -eq 0)#>

	PrintCurrentContext -DeployObject $DeployObject
	#PickSubscription -CurrContext $AzureContext -DeployObject $DeployObject -PickSubscriptionFlag $PickSubscriptionFlag

	<#
	If($debugFlag){
		$ObjectName = "DeployObject"
		$Caller = "InitiateDeploymentProcess[192] AFTER SetDeployInfoObj" + $ObjectName
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#>

	If($uiDeployFlag -eq $null)
	{
		$uiDeployFlag = PickDeployMethod -DeployObject $DeployObject
	}

	If($uiDeployFlag -eq $false)
	{
		$createFileFlag = PickCreateParamFile -DeployObject $DeployObject
	}

	If($createFileFlag)
	{
		ParseInputFile -FilePath $DeployObject.DeployParameterFile -DeployObject $DeployObject 
	}
	<#Else
	{
		Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[188] `$createFileFlag= `"$createFileFlag`""
	}#ElseIf($createFileFlag)#>
	
	GetDeployParameterValues -DeployObject $DeployObject
	ConfigureDeployInfo -DeployObject $DeployObject
	SetDeployInfoObj -DeployObject $DeployObject 
	SetOutputFileNames -StepCount $DeployObject.StepCount -DeployObject $DeployObject
	PrintLogInfo -DeployObject $DeployObject 
	SetDeployInfoPropsFromFile -FilePath $DeployObject.OutFileJSON -DeployObject $DeployObject 
	
	WriteJsonFile -FilePath $DeployObject.OutFileJSON -CustomObject $DeployObject
	PrintLogInfo -DeployObject $DeployObject

	# DEPLOY DTP (Transfer) 
	ConfigureTransferAppObj -DeployObject $DeployObject
	#WriteJsonFile -FilePath $DeployObject.OutFileJSON -CustomObject $DeployObject

	$SolutionObjName = $DeployObject.SolutionObjName
	$APIAppRegAppId = $DeployObject.APIAppRegAppId 
	$APIAppRegName = $DeployObject.APIAppRegName 
	$ClientAppRegAppId = $DeployObject.ClientAppRegAppId
	$ClientAppRegName = $DeployObject.ClientAppRegName

	If($DeployConfigObj.AppRegistration)
	{ 
		#
		If($debugFlag){
			$Caller = "InitiateDeploymentProcess[312] CALLING CreateAppRegistration for API: " + $APIAppRegName
			Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
			Write-Host -ForegroundColor Cyan "`$APIAppRegName= "$APIAppRegName
		}#If($debugFlag)#>
		
		CreateAppRegistration -AppName $APIAppRegName -DeployObject $DeployObject
		
		#
		If($debugFlag){
			$Caller = "InitiateDeploymentProcess[326] CALLING CreateAppRegistration for Client App" + $ClientAppRegName
			Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
			Write-Host -ForegroundColor Cyan "`$DeployObject.`$DeployObject.ClientAppRegName= `"$ClientAppRegName`""
		}#If($debugFlag)#>
		
		CreateAppRegistration -AppName $ClientAppRegName -DeployObject $DeployObject

		WriteJsonFile -FilePath $DeployObject.OutFileJSON -CustomObject $DeployObject
	}#$DeployConfigObj.AppRegistration


	If($DeployConfigObj.AzureInfrastructure)
	{
		$i = 0
		$ResourceGroupName = $DeployObject.ResourceGroupName
		$KeyVaultName = $DeployObject.KeyVaultName

		ForEach ($resource in $AzureResourcesObj.GetEnumerator())
		{ 
			If($resource -ne $null)
			{		
				$key = $resource.Name
				$value = $resource.Value
				$itemType = $value.GetType().Name
				<#
				Write-Host -ForegroundColor Magenta -BackgroundColor White  "[$i]"
				Write-Host -ForegroundColor Cyan "`$key= `"$key`""
				Write-Host -ForegroundColor Cyan "`$value= `"$value`""
				Write-Host -ForegroundColor Yellow "`$itemType=`"$itemType`""
				#>

				$chosenResource = $AzResourcesComplexObj.$key
				$Name = $chosenResource.Name
				$Description = $chosenResource.Description
				$ResourceName = $chosenResource.ResourceName
				$ResourceType = $chosenResource.ResourceType
				$PropertyName = $chosenResource.PropertyName

				$DeployInfoPropExists = $key + "Exists"
				$ObjectResourceId = $key + "ResourceId"
				#
				If($debugFlag)
				{ 
					Write-Host -ForegroundColor Magenta -BackgroundColor White  "`nValue=TRUE: [$i] = " -NoNewline
					Write-Host -ForegroundColor Cyan "`$key= `"$key`"  " -NoNewline
					Write-Host -ForegroundColor Yellow "`$value= `"$value`""  #>
					$ObjectName = "chosenResource"
					$Caller = "InitiateDeploymentProcess[381] :: " + $ObjectName
					#Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
					#PrintCustomObjectAsObject -Object $chosenResource -Caller $Caller -ObjectName $ObjectName 
					 Write-Host -ForegroundColor Yellow "`$DeployInfoPropExists= " -NoNewline
					Write-Host -ForegroundColor Green "`"$DeployInfoPropExists`""
				}#If($debugFlag)#>
				
				$DeployObject.$DeployInfoPropExists =
					CheckForExistingResource `
						-ResourceGroupName $ResourceGroupName `
						-ResourceType  $ResourceType `
						-ResourceName $ResourceName `
						-PropertyName $PropertyName `
						-ObjectResourceId $ObjectResourceId `
						-DeployObject $DeployObject
				 $i++
			}#If($resource -ne $null)
		}#Foreach($resource in $AzureResourcesObj

		WriteJsonFile -FilePath $DeployObject.OutFileJSON -CustomObject $DeployObject
		#
		If($debugFlag){ 
			$ObjectName = "DeployObject"
			$Caller = "`n InitiateDeploymentProcess[390]:: BEFORE  StartBicepDeploy :: " + $ObjectName
			Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
			#PrintCustomObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
			PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName  			
		}#If($debugFlag)#>

		$DeploymentOutput = StartBicepDeploy -DeployObject $DeployObject -Solution $DeployObject.Solution
		$ProvisioningState = $DeploymentOutput.ProvisioningState
			
		If(-not( $ProvisioningState -in "Running","Failed") -and $DeploymentOutput.Outputs -ne $null)
		{
			#
			If($debugFlag){
				$DeploymentOutput
				$DeploymentOutputPath = $LogsFolderPath + "DeploymentOutput.json"
				ConvertTo-Json $DeploymentOutput > $DeploymentOutputPath 
				$DeploymentOutputJson = ConvertTo-Json $DeploymentOutput
				#$DeploymentOutputJson
				$ObjectName = "DeploymentOutput.Outputs" 
				$ObjectName = "DeploymentOutput.Parameters.solutionObject"
				$Caller ='InitiateDeploymentProcess[409]:: $DeploymentOutput.Parameters.solutionObject '
				Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
				<#
				For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
				PrintCustomObjectAsObject -Object $DeploymentOutput.Parameters.solutionObject -Caller $Caller -ObjectName $ObjectName
				#>
				$Caller ='InitiateDeploymentProcess[413]:: $DeploymentOutput.Parameters.solutionObject '
				Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
				For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
				PrintDeploymentOutput -ObjectName $ObjectName -Object $DeploymentOutput.Parameters.solutionObject -Caller $Caller
			}#debugFlag #>
			
			#ParseDeploymentOutput -DeployObject $DeployObject -DeploymentOutput $DeploymentOutput
			If($debugFlag){exit(1)}
		}#If(-not( $ProvisioningState -in "Running","Failed"))

		#
		If($DeployObject.AzureResources.AuditStorage -or $DeployObject.AzureResources.MainStorage)
		{
			SetStorageEncryption -DeployObject $DeployObject
		}
		#>
	}#If(DeployConfigObj.AzureInfrastructure)

If($debugFlag){exit(1)}

	#add the app and the DTS Admins and DTS Users to the resource group
	$GroupName = "DTS Users"
	$UserGroup = CreateAzGroup -GroupName $GroupName

	If($debugFlag){
		Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[246]"
		Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
		Write-Host -ForegroundColor Yellow "`$GroupName=`"$GroupName`""
		#Write-Host -ForegroundColor Yellow "`$UserGroup=`"$UserGroup`""
		Write-Host -ForegroundColor Magenta "[333] Calling AddRoleAssignment ...."
	}#debugFlag #>

	$AzRoleName = "Storage Blob Delegator"
	AddRoleAssignment `
		-AzRoleName $AzRoleName `
		-ResourceGroupName $DeployObject.ResourceGroupName `
		-User $UserGroup `
		-DeployObject $DeployObject 
	############################################################################################## 
	$APIAppRegName = $DeployObject.APIAppRegName
	$AppId = $DeployObject.APIAppRegAppId
	$User = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName" -and $_.AppId -eq "$AppId"} 
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[343]"
		Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

			Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
		Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
		Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
		Write-Host -ForegroundColor Green "User.Id=" $User.Id
		Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment..."
	}#debugFlag #>

				 $AzRoleName = "Contributor"
					AddRoleAssignment `
					 -AzRoleName $AzRoleName `
					 -ResourceGroupName $ResourceGroupName `
					 -User $User `
					 -DeployObject $DeployObject  

				 #
				 If($debugFlag){
					 Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[456]"
					 Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

						Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
					 #Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
					 Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
					 #Write-Host -ForegroundColor Green "User.Id=" $User.Id
					 Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment..."
				 }#debugFlag #>

				 $AzRoleName = "User Access Administrator"
				 AddRoleAssignment `
					 -AzRoleName $AzRoleName `
					 -ResourceGroupName $ResourceGroupName `
					 -User $User `
					 -DeployObject $DeployObject

				 ##########################################################
				}#If(-not( $ProvisioningState -in "Running","Failed")) 
			 #}#If(DeployConfigObj.AzureInfrastructure)
		
			 If($DeployConfigObj.RoleAssignments)
			{
				#add the app and the DTS Admins and DTS Users to the resource group
				 $GroupName = "DTS Users"
				$AzRoleName = "Storage Blob Delegator"
				$UserGroup = CreateAzGroup -GroupName $GroupName -DeployObject $DeployObject

				 #Add Storage Blob Delegator role for: DTS Users 
				 $AzRoleName = "Storage Blob Delegator"
				<#If($debugFlag){
					Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess.RoleAssignments[234]"
					Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
					Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
					Write-Host -ForegroundColor Yellow "`$GroupName=`"$GroupName`""
					#Write-Host -ForegroundColor Green "`$UserGroup=`"$UserGroup`"" 
				 }#debugFlag #>

				AddRoleAssignment `
					-AzRoleName $AzRoleName `
					-ResourceGroupName $ResourceGroupName `
					-User $UserGroup `
					-DeployObject $DeployObject
	
				$APIAppRegName = $DeployObject.TransferAppObj.APIAppRegName
				$AppId = $DeployObject.TransferAppObj.APIAppRegAppId
				 $User = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName" -and $_.AppId -eq "$AppId"} 

				 <#
				If($debugFlag){
					Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[549]"
					Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

			Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
		Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
		Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
		Write-Host -ForegroundColor Green "User.Id=" $User.Id
		Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment..."
	}#debugFlag #>
	##############################################################################################
	$AzRoleName = "User Access Administrator"
	AddRoleAssignment `
		-AzRoleName $AzRoleName `
		-ResourceGroupName $DeployObject.ResourceGroupName `
		-User $User `
		-DeployObject $DeployObject
	##############################################################################################

	<#
		$AppId = $MainStorageSystemAssignedprincipalId
		$AzRoleName = "Key Vault Crypto Service Encryption User"
		$CustomRole = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.Name -eq $AzRoleName}
		$CryptoEncryptRoleId = $CustomRole.Id
		$DeployObject.CryptoEncryptRoleId = $CustomRole.Id
		$User = Get-AzADServicePrincipal | Where-Object {$_.AppId -eq "$AppId"} 
		If($debugFlag){
			Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[322]"
			Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
			 Write-Host -ForegroundColor Yellow "`$CryptoEncryptRoleId=`"$CryptoEncryptRoleId`""
			 Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
			Write-Host -ForegroundColor Green "User.Id=" $User.Id
			Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment"
		}
		AddRoleAssignment `
			-AzRoleName $AzRoleName `
			-ResourceGroupName $PickupAppObj.ResourceGroupName `
			-User $User `
			-DeployObject $DeployObject
	#}#If(-not $debugFlag) #>  

	#Write-Host -ForegroundColor Cyan "TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL=" $DeployObject.REACT_APP_DTS_AZ_STORAGE_URL
	<#
	CreateEnvironmentFiles `
		-RootFolder $RootFolder `
		-TemplateDir $TemplateDir `
		-DeployObject $DeployObject `
		-Cloud $DeployObject.Cloud
	#>

	#PickBuildAndPublish -DeployObject $DeployObject

	PrintDeployDuration -DeployObject $DeployObject
	 

}#If($currDirPath -match '\\powershell')
Else
{
	Write-Host -ForegroundColor Red -BackgroundColor White "The successful deployment requires that you execute this script from the 'dtp\Deploy\powershell' folder."
	Write-Host -ForegroundColor Red -BackgroundColor White "Please change directory to the 'Deploy' folder and run this script again..."
} # if not on correct path
	