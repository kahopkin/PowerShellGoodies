
#InitiateDeploymentProcess.ps1
<#
# Make sure that the user is in the right folder to run the script.
# Running the script is required to be in the dtp\deploy\powershell folder
#>
								
#Install-Module -name Microsoft.Graph.Applications
Import-Module -Name Microsoft.Graph.Applications

#& "$PSScriptRoot\PreReqCheck.ps1"
& "$PSScriptRoot\UtilityFunctions.ps1"
& "$PSScriptRoot\ConnectToMSGraph.ps1"
& "$PSScriptRoot\BuildLocalSettingsFile"
#& "$PSScriptRoot\GetAzureADToken.ps1"
& "$PSScriptRoot\CreateEnvironmentFiles.ps1"
& "$PSScriptRoot\InitiateScripts.ps1"
& "$PSScriptRoot\CreateResourceGroup.ps1"
& "$PSScriptRoot\CreateAppRoles.ps1"
& "$PSScriptRoot\SetApplicationIdURI.ps1"
& "$PSScriptRoot\SetRedirectURI.ps1"
& "$PSScriptRoot\CreateAppRegistration.ps1"
& "$PSScriptRoot\CreateScopes.ps1"
& "$PSScriptRoot\CreateServicePrincipal.ps1"
& "$PSScriptRoot\AddAPIPermissions.ps1"
& "$PSScriptRoot\AddRoleAssignment.ps1"
& "$PSScriptRoot\StartBicepDeploy.ps1"
& "$PSScriptRoot\RunDeployment.ps1"


$global:debugFlag = Pick_DebugMode

#If($debugFlag){exit(1)}

<#If($debugFlag)
{
	$InputFilePath = "C:\GitHub\dtp\Deploy\Pickup_DebugIpnputParams.json"
	$InputFilePath = "C:\GitHub\dtp\Deploy\Transfer_DebugIpnputParams.json"
	$DebugIpnputParamsJSON = Get-Content $InputFilePath | Out-String | ConvertFrom-Json

	#Write-host -ForegroundColor Cyan  "[35]`$debugFlag=`"$debugFlag`""
	$Environment = $DebugIpnputParamsJSON.CloudEnvironment;
	$Location = $DebugIpnputParamsJSON.Location;
	$Environment = $DebugIpnputParamsJSON.Environment;
	$AppName = $DebugIpnputParamsJSON.AppName;
	$DeployMode = $DebugIpnputParamsJSON.DeployMode;
	$SqlAdmin = $DebugIpnputParamsJSON.SqlAdmin;
	$SqlAdminPwd = $DebugIpnputParamsJSON.SqlAdminPwd;
	$global:BuildFlag = $DebugIpnputParamsJSON.BuildFlag;
	$global:PublishFlag = $DebugIpnputParamsJSON.PublishFlag;
	 Switch ($PublishFlag)
	{
			1{$PublishFlag = $true}
		2{$PublishFlag = $false} 
			X { "Quitting..."
			$BuildFlag = $false
			 exit(1)
		}
		Default {
			$PublishFlag = $false
			}
	}#Switch

	 Switch ($BuildFlag)
	{
			1{$BuildFlag = $true}
		2{$BuildFlag = $false} 
			X { "Quitting..."
			$BuildFlag = $false
			 exit(1)
		}
		Default {
			$BuildFlag = $false
			}
	}#Switch
	If($debugFlag){
			Write-Host -ForegroundColor Cyan "`$Environment=`"$Environment`""
		Write-Host -ForegroundColor Cyan "`$Location=`"$Location`""
		Write-Host -ForegroundColor Cyan "`$AppName=`"$AppName`""
		Write-Host -ForegroundColor Cyan "`$DeployMode=`"$DeployMode`""
		Write-Host -ForegroundColor Yellow "`$SqlAdmin=`"$SqlAdmin`""
		Write-Host -ForegroundColor Yellow "`$SqlAdminPwd=`"$SqlAdminPwd`""
		Write-Host -ForegroundColor Green "`$BuildFlag=`"$BuildFlag`""
		Write-Host -ForegroundColor Green "`$PublishFlag=`"$PublishFlag`""
	}#If($debugFlag) #>
#}#If($debugFlag)

<#If(-not $debugFlag){  
#}#If(-not $debugFlag) #>  

PrintWelcomeMessage
SetLogFolder

<#If($debugFlag){
	$currDirPath = $currDir.FullName
	Write-host -ForegroundColor Cyan  "`$currDirPath=`"$currDirPath`""
	Write-host -ForegroundColor Cyan  "`$correctPath=`"$correctPath`""
}#>

If(($currDir.FullName).ToLower().Contains($correctPath))
{

	#Initialize the object:
	$DeployInfo = InitializeDeployInfoObject

	#Connect to Az and MS Graph 
	#If(-not $debugFlag){
	ConnectToAzure
	#}#If(-not $debugFlag) #>
	If($debugFlag)
	{
		 $DeployInfo = ConfigureDeployInfo `
			-Environment $Environment `
			-Location $Location `
			-AppName $AppName `
			-DeployMode $DeployMode
	}
	Else
	{
		$DeployInfo = ConfigureDeployInfo
	}

	#$DeployInfo
	PrintLogInfo -DeployObject $DeployInfo

	Switch( $DeployInfo.DeployMode )
	{
		"All"
		{
			 #Write-Host -ForegroundColor Green "InitiateDeploymentProcess[64] DeployInfo.DeployMode=" $DeployInfo.DeployMode
			$TransferAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
			$TransferAppObj = ConfigureTransferAppObj

			$RoleDefinition = AddCustomRoleFromFile -DeployObject $TransferAppObj

			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[171] calling:CreateAppRegistration for TransferAppObj AppName=" $TransferAppObj.APIAppRegName
			}#debugFlag #>
			$TransferAppObj = CreateAppRegistration -AppName $TransferAppObj.APIAppRegName -DeployObject $TransferAppObj
			$DeployInfo.TransferAppObj = $TransferAppObj

			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[176] calling:CreateAppRegistration for TransferAppObj AppName=" $TransferAppObj.APIAppRegName
				<#$Caller='InitiateDeploymentProcess[179] TransferAppObj::'
				PrintObject -object $TransferAppObj -Caller $Caller
				#>
			}#debugFlag #>

			 $TransferAppObj = CreateAppRegistration -AppName $TransferAppObj.ClientAppRegName -DeployObject $TransferAppObj 
			$DeployInfo.TransferAppObj = $TransferAppObj

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[187] AFTER:CreateAppRegistration for TransferAppObj AppName=" $TransferAppObj.APIAppRegName
				<#$Caller='InitiateDeploymentProcess[188] TransferAppObj::'
				PrintObject -object $TransferAppObj -Caller $Caller
				#>
			}#debugFlag #>

			 $DeploymentOutput = StartBicepDeploy -DeployObject $TransferAppObj -Solution $TransferAppObj.Solution
			 $TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL = "https://" + $DeploymentOutput.Outputs.storageAccountNameMain.Value + ".blob." + $DeployInfo.Cloud.StorageEndpointSuffix + "/"

			 If($debugFlag){
				 Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[196] DeploymentOutput="
				$DeploymentOutput
				Write-Host -ForegroundColor Cyan "TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL=" $TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL
				Write-Host -ForegroundColor Green "DeploymentOutput.mainStorageSystemAssignedPrincipalId=" $DeploymentOutput.Outputs.mainStorageSystemAssignedPrincipalId
			}#>

			CreateEnvironmentFiles `
				-RootFolder $RootFolder `
				-TemplateDir $TemplateDir `
				-DeployObject $TransferAppObj `
				-Cloud $DeployInfo.Cloud

			 #If(-not $debugFlag){
			#add the app and the DTS Admins and DTS Users to the resource group
			$GroupName = "DTS Users"
			$UserGroup = CreateAzGroup -GroupName $GroupName

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[303]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
				Write-Host -ForegroundColor Yellow "`$GroupName=`"$GroupName`""
				#Write-Host -ForegroundColor Yellow "`$UserGroup=`"$UserGroup`""
				Write-Host -ForegroundColor Magenta "[217] Calling AddRoleAssignment ...."
			}#debugFlag #>

			$AzRoleName = "Storage Blob Delegator"
			AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $TransferAppObj.ResourceGroupName `
				-User $UserGroup `
				-DeployObject $DeployInfo
	
			$APIAppRegName = $TransferAppObj.APIAppRegName
			$AppId = $TransferAppObj.APIAppRegAppId
			 $User = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName" -and $_.AppId -eq "$AppId"} 
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[320]"
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
				-ResourceGroupName $TransferAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo  

			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[339]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

				 Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
				Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
				Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
				Write-Host -ForegroundColor Green "User.Id=" $User.Id
				Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment..."
			}#debugFlag #>

			$AzRoleName = "User Access Administrator"
			AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $TransferAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo
			 #}#If(-not $debugFlag) #>

			PickBuildAndPublish -DeployObject $TransferAppObj
			PrintDeployDuration -DeployObject $TransferAppObj

			#PICKUP
			# Deploy DPP (Pickup)
			$PickupAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
			$PickupAppObj = ConfigurePickupAppObj

			 $RoleDefinition = AddCustomRoleFromFile -DeployObject $PickupAppObj
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[234] calling:CreateAppRegistration for AppName=" $PickupAppObj.APIAppRegName
			}#debugFlag #>

			$PickupAppObj = CreateAppRegistration -AppName $PickupAppObj.APIAppRegName -DeployObject $PickupAppObj
			$DeployInfo.PickupAppObj = $PickupAppObj

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[241] calling:CreateAppRegistration for APIAppRegName=" $PickupAppObj.APIAppRegName

				 <#$Caller='InitiateDeploymentProcess[243] PickupAppObj::'
				PrintObject -object $PickupAppObj -Caller $Caller
				#>
			}#debugFlag #>

			 $PickupAppObj = CreateAppRegistration -AppName $PickupAppObj.ClientAppRegName -DeployObject $PickupAppObj
			$DeployInfo.PickupAppObj = $PickupAppObj

			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[252] AFTER CreateAppRegistration ClientAppRegName=" $PickupAppObj.ClientAppRegName

				 <#$Caller='InitiateDeploymentProcess[254] PickupAppObj::'
				PrintObject -object $PickupAppObj -Caller $Caller
				#>
				$Caller='InitiateDeploymentProcess[257] DeployInfo::'
				PrintDeployObject -object $DeployInfo -Caller $Caller
			}#debugFlag #>

			$DeploymentOutput = StartBicepDeploy -DeployObject $PickupAppObj -Solution $PickupAppObj.Solution
			$SystemAssignedPrincipalId = $DeploymentOutput.Outputs.systemAssignedIdentityId.Value
			If($debugFlag){
				#Write-Host "InitiateDeploymentProcess[204]  DeploymentOutput.Outputs:"
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[259] DeploymentOutput="
				$DeploymentOutput
				Write-Host -ForegroundColor Yellow "SystemAssignedPrincipalId=" $SystemAssignedPrincipalId
			}#>
			#$DeploymentOutput

			CreateEnvironmentFiles `
					-RootFolder $RootFolder `
					-TemplateDir $TemplateDir `
					-DeployObject $PickupAppObj `
					-Cloud $DeployInfo.Cloud
		
			 #If($debugFlag){exit(1)}
			$AzRoleName = "Storage Blob Delegator"
			$GroupName = "DTS Users"
			 $UserGroup = CreateAzGroup -GroupName $GroupName

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[283]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
				Write-Host -ForegroundColor Yellow "`$GroupName=`"$GroupName`""
				Write-Host -ForegroundColor Yellow "`$UserGroup=`"$UserGroup`""
				Write-Host -ForegroundColor Magenta "[288] Calling AddRoleAssignment ...."
			}

			 AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $PickupAppObj.ResourceGroupName `
				-User $UserGroup `
				-DeployObject $DeployInfo

			 #Write-Host "InitiateDeploymentProcess[231]:APIAppRegName=" $TransferAppObj.APIAppRegName

			 $AzRoleName = "Contributor"
			$APIAppRegName = $PickupAppObj.APIAppRegName
			$AppId = $PickupAppObj.APIAppRegAppId
			 $User = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName" -and $_.AppId -eq "$AppId"} 

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[304]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

				 Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
				Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
				Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
				Write-Host -ForegroundColor Green "User.Id=" $User.Id
				Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment"
			} 

			AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $PickupAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo
 
			 $AzRoleName = "User Access Administrator"
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[322]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

				 Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
				Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
				Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
				Write-Host -ForegroundColor Green "User.Id=" $User.Id
				Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment"
			}
			AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $PickupAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo 
			PickBuildAndPublish -DeployObject $PickupAppObj

			 PrintDeployDuration -DeployObject $PickupAppObj
		}#All
		"Transfer"
		{
			 # DEPLOY DTP (Transfer)
			$TransferAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
			If($debugFlag)
			{
				$TransferAppObj = ConfigureTransferAppObj -SqlAdmin $SqlAdmin -SqlAdminPwd $SqlAdminPwd
			}
			Else
			{
				$TransferAppObj = ConfigureTransferAppObj
			}

			 $RoleDefinition = AddCustomRoleFromFile -DeployObject $TransferAppObj
	
			 $TransferAppObj = CreateAppRegistration -AppName $TransferAppObj.APIAppRegName -DeployObject $TransferAppObj
			$DeployInfo.TransferAppObj = $TransferAppObj

			<#If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[176] calling:CreateAppRegistration for TransferAppObj AppName=" $TransferAppObj.APIAppRegName
				$Caller='InitiateDeploymentProcess[179] TransferAppObj::'
				PrintObject -object $TransferAppObj -Caller $Caller
			 }#debugFlag #>

			 $TransferAppObj = CreateAppRegistration -AppName $TransferAppObj.ClientAppRegName -DeployObject $TransferAppObj 
			$DeployInfo.TransferAppObj = $TransferAppObj
	
			#If(-not $debugFlag){
			$DeploymentOutput = StartBicepDeploy -DeployObject $TransferAppObj -Solution $TransferAppObj.Solution						
			 $TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL =  $DeploymentOutput.Outputs.blobEndpoint.Value
			#$MainStorageSystemAssignedprincipalId = $DeploymentOutput.Outputs.MainStorageSystemAssignedprincipalId.Value

			 #}#If(-not $debugFlag) #>

			If($debugFlag){
				 Write-Host -ForegroundColor Magenta "`nInitiateDeploymentProcess[357] DeploymentOutput="
				$DeploymentOutput
				Write-Host -ForegroundColor Cyan "TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL=" $TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL
				#Write-Host -ForegroundColor Green "MainStorageSystemAssignedprincipalId=" $MainStorageSystemAssignedprincipalId
				#Write-Host -ForegroundColor Green "DeploymentOutput.mainStorageSystemAssignedPrincipalId=" $DeploymentOutput.Outputs.mainStorageSystemAssignedPrincipalId
			}#debugFlag #>


			#If(-not $debugFlag){
			#add the app and the DTS Admins and DTS Users to the resource group
			$GroupName = "DTS Users"
			$UserGroup = CreateAzGroup -GroupName $GroupName

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[325]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
				Write-Host -ForegroundColor Yellow "`$GroupName=`"$GroupName`""
				#Write-Host -ForegroundColor Yellow "`$UserGroup=`"$UserGroup`""
				Write-Host -ForegroundColor Magenta "[333] Calling AddRoleAssignment ...."
			}#debugFlag #>

			$AzRoleName = "Storage Blob Delegator"
			AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $TransferAppObj.ResourceGroupName `
				-User $UserGroup `
				-DeployObject $DeployInfo
	
			$APIAppRegName = $TransferAppObj.APIAppRegName
			$AppId = $TransferAppObj.APIAppRegAppId
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
				-ResourceGroupName $TransferAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo  

			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[362]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

				 Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
				Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
				Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
				Write-Host -ForegroundColor Green "User.Id=" $User.Id
				Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment..."
			}#debugFlag #>

			$AzRoleName = "User Access Administrator"
			AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $TransferAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo
			<#$AppId = $MainStorageSystemAssignedprincipalId
			$AzRoleName = "Key Vault Crypto Service Encryption User"
			$CustomRole = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.Name -eq $AzRoleName}
			$CryptoEncryptRoleId = $CustomRole.Id
			$DeployInfo.CryptoEncryptRoleId = $CustomRole.Id
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
				-DeployObject $DeployInfo
			#}#If(-not $debugFlag) #>  

			#Write-Host -ForegroundColor Cyan "TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL=" $TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL

			CreateEnvironmentFiles `
				-RootFolder $RootFolder `
				-TemplateDir $TemplateDir `
				-DeployObject $TransferAppObj `
				-Cloud $DeployInfo.Cloud

			PickBuildAndPublish -DeployObject $TransferAppObj

			PrintDeployDuration -DeployObject $TransferAppObj
			}#Transfer

		########## PICKUP

		"Pickup"
		{
			 # Deploy DPP (Pickup)
			$PickupAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
			$PickupAppObj = ConfigurePickupAppObj

			 $RoleDefinition = AddCustomRoleFromFile -DeployObject $PickupAppObj
			$PickupAppObj = CreateAppRegistration -AppName $PickupAppObj.APIAppRegName -DeployObject $PickupAppObj
			$DeployInfo.PickupAppObj = $PickupAppObj

			 <#If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[241] calling:CreateAppRegistration for APIAppRegName=" $PickupAppObj.APIAppRegName

				 $Caller='InitiateDeploymentProcess[243] PickupAppObj::'
				PrintObject -object $PickupAppObj -Caller $Caller

			 #}#debugFlag #>

			 $PickupAppObj = CreateAppRegistration -AppName $PickupAppObj.ClientAppRegName -DeployObject $PickupAppObj
			$DeployInfo.PickupAppObj = $PickupAppObj

			<#If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[252] AFTER CreateAppRegistration ClientAppRegName=" $PickupAppObj.ClientAppRegName

				 $Caller='InitiateDeploymentProcess[254] PickupAppObj::'
				PrintObject -object $PickupAppObj -Caller $Caller

				 $Caller='InitiateDeploymentProcess[257] DeployInfo::'
				PrintDeployObject -object $DeployInfo -Caller $Caller

			 #}#debugFlag #>

			 #If(-not $debugFlag){
			$DeploymentOutput = StartBicepDeploy -DeployObject $PickupAppObj -Solution $PickupAppObj.Solution
			 #$SystemAssignedPrincipalId = $DeploymentOutput.Outputs.systemAssignedIdentityId.Value
			If($debugFlag){
				#Write-Host "InitiateDeploymentProcess[204]  DeploymentOutput.Outputs:"
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[434] DeploymentOutput="
				$DeploymentOutput
				#Write-Host -ForegroundColor Yellow "SystemAssignedPrincipalId=" $SystemAssignedPrincipalId
			}#debugFlag #>

			 #If($debugFlag){exit(1)}


			$AzRoleName = "Storage Blob Delegator"
			$GroupName = "DTS Users"
			 $UserGroup = CreateAzGroup -GroupName $GroupName

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[444]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
				Write-Host -ForegroundColor Yellow "`$GroupName=`"$GroupName`""
				#Write-Host -ForegroundColor Yellow "`$UserGroup=`"$UserGroup`""
				Write-Host -ForegroundColor Magenta "[448] Calling AddRoleAssignment ...."
			}#debugFlag #>

			 AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $PickupAppObj.ResourceGroupName `
				-User $UserGroup `
				-DeployObject $DeployInfo

			 #Write-Host "InitiateDeploymentProcess[231]:APIAppRegName=" $TransferAppObj.APIAppRegName

			 $AzRoleName = "Contributor"
			$APIAppRegName = $PickupAppObj.APIAppRegName
			$AppId = $PickupAppObj.APIAppRegAppId
			 $User = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName" -and $_.AppId -eq "$AppId"} 

			 If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[465]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

				 Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
				Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
				Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
				Write-Host -ForegroundColor Green "User.Id=" $User.Id
				Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment"
			}#debugFlag #>

			 AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $PickupAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo
 
			 $AzRoleName = "User Access Administrator"
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[482]"
				Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""

				 Write-Host -ForegroundColor Yellow "`$APIAppRegName=`"$APIAppRegName`""
				Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
				Write-Host -ForegroundColor Green "User.DisplayName=" $User.DisplayName
				Write-Host -ForegroundColor Green "User.Id=" $User.Id
				Write-Host -ForegroundColor Magenta "Calling AddRoleAssignment"
			}#debugFlag #>

			AddRoleAssignment `
				-AzRoleName $AzRoleName `
				-ResourceGroupName $PickupAppObj.ResourceGroupName `
				-User $User `
				-DeployObject $DeployInfo 
			#}#If(-not $debugFlag) #> 

			#assign Key Vault Crypto Service Encryption User to the managed id that was created
			#retrieve the user-assigned managed identity and assign to it the required RBAC role, scoped to the key vault.
			<#
			$AzRoleName = "Key Vault Crypto Service Encryption User"
			$CustomRole = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.Name -eq $AzRoleName}
			$CryptoEncryptRoleId = $CustomRole.Id
			$DeployInfo.CryptoEncryptRoleId = $CustomRole.Id
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
				-DeployObject $DeployInfo
			#>

			CreateEnvironmentFiles `
					-RootFolder $RootFolder `
					-TemplateDir $TemplateDir `
					-DeployObject $PickupAppObj `
					-Cloud $DeployInfo.Cloud

			<#If($debugFlag){
				Write-Host -ForegroundColor Magenta "InitiateDeploymentProcess[511] Before PickBuildAndPublish ::: "
				Write-Host -ForegroundColor Yellow "`$PickupAppObj=`"$PickupAppObj`""
			 }#>

			PickBuildAndPublish -DeployObject $PickupAppObj
			 PrintDeployDuration -DeployObject $PickupAppObj

			}#Pickup
		Default
		{
			Write-Host -ForegroundColor Red "DeployInfo.DeployMode="$DeployInfo.DeployMode
		}
	}#switch

	#If(-not $debugFlag){
	AddUsersToUserGroup -UserGroup $GroupName
	#}#If(-not $debugFlag) #>
	WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo
 
	$DeployInfo.EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$DeployInfo.Duration = New-TimeSpan -Start $DeployInfo.StartTime -End $DeployInfo.EndTime
	PrintDeployDuration -DeployObject $DeployInfo
}
Else
{
	Write-Host -ForegroundColor Red -BackgroundColor White "The successful deployment requires that you execute this script from the 'dtp\Deploy\powershell' folder."
	Write-Host -ForegroundColor Red -BackgroundColor White "Please change directory to the 'Deploy' folder and run this script again..."
	
} # if not on correct path

#}#DeploySolution

