#InitiateScripts

Function global:PrintWelcomeMessage
{
	<#If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.PrintWelcomeMessage[7]"
	}#>
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$global:StartTime = $today
	$global:todayShort = Get-Date -Format 'MM-dd-yyyy'

	Write-Host -ForegroundColor Green "================================================================================"
	Write-Host -ForegroundColor Green "[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!"
	Write-Host -ForegroundColor Green "================================================================================"
		
}#PrintWelcomeMessage

Function global:SetLogFolder
{
	Write-Debug "InitiateScripts.SetLogFolder[21]"

	$global:currDir = Get-Item (Get-Location)

	#$currDirPath = ($currDir.FullName).ToLower()
	$global:correctPath = ("Deploy\powershell").ToLower()
	$currDirPath = $currDir.FullName

	#this is where the repository code files are
	#figure out a way to do whole word case insensitive find
	$index = ($currDirPath).ToLower().IndexOf("deploy")

	$global:RootFolder = $currDirPath.Substring(0,$index)
	$global:RootFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)

	#this is where the templates for the .env files are
	$global:DeployFolder = $RootFolder + "Deploy\"
	#$global:DeployFolder =  "..\Deploy\"

	$DeployPath = "deploy\logs"

	$global:TemplateDir = $DeployFolder + "LocalSetUp"
	#this is the full filepath for the subscription level custom role definition file

	$global:LogsFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
	$global:LogsFolder = Get-ChildItem -Path  $LogsFolderParentPath | `
						Where-Object { `
							($_.PSIsContainer -eq $true) -and `
							($_.FullName.Contains("deploy\logs") -or $_.FullName.Contains("Deploy\logs")) }
	$LogsFolderPath = $LogsFolder.FullName

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	If($LogsFolder -eq $null)
	{
		$folderName ="logs"
		$LogsFolder = New-Item -Path $LogsFolderParentPath -Name $folderName -ItemType Directory
		$global:LogsFolderPath = (Get-ItemProperty  $LogsFolder | select FullName).FullName
			Write-Host -ForegroundColor Yellow "================================================================================"
		Write-Host -ForegroundColor Yellow "[$today] CREATED LOGS FOLDER:" $LogsFolderPath
			Write-Host -ForegroundColor Yellow "================================================================================" 
	}
	Else
	{
		$global:LogsFolderPath = $LogsFolder.FullName
		Write-Host -ForegroundColor Yellow "================================================================================"
		Write-Host -ForegroundColor Yellow "[$today] LOGS FOLDER:" $LogsFolderPath
			Write-Host -ForegroundColor Yellow "================================================================================"
		#Write-Host -ForegroundColor Yellow "InitiateScripts.SetLogFolder[54] LogsFolderPath: $LogsFolderPath"
	}

	If($debugFlag){
		Write-host -ForegroundColor Magenta "`nInitiateScripts.SetLogFolder[49]::"
		Write-host -ForegroundColor Green  "`$currDir=`"$currDir`""
		Write-host -ForegroundColor Green  "`$currDirPath=`"$currDirPath`""

			Write-Host -ForegroundColor Green "`$correctPath=`"$correctPath`""

			Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
		Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""

		Write-host -ForegroundColor Green  "`$DeployFolder=`"$DeployFolder`""
		Write-host -ForegroundColor Green  "`$DeployPath=`"$DeployPath`""

			Write-host -ForegroundColor Green  "`$TemplateDir=`"$TemplateDir`""

		$LogsFolderFullName = $LogsFolder.FullName
		Write-Host -ForegroundColor Yellow "`$LogsFolder=`"$LogsFolderFullName`""
		Write-host -ForegroundColor Yellow "`$LogsFolderParentPath=`"$LogsFolderParentPath`""
		Write-Host -ForegroundColor Yellow "`$LogsFolderPath=`"$LogsFolderPath`""

		#Write-Host -ForegroundColor Cyan  "InitiateScripts.SetLogFolder[64] LogsFolder -eq null=" ($LogsFolder -eq $null)
	}#debugFlag #>
	
}#SetLogFolder

Function global:SetOutputFileNames
{

	Write-Debug "`nInitiateScripts.SetOutputFileNames[513]"
	<#If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.SetOutputFileNames[504]"
			Write-Host -ForegroundColor Red "InitiateScripts.SetOutputFileNames[506] `$DeployInfo.TenantName=`""$DeployInfo.TenantName
			Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[507] `$DeployInfo.AppName=`""$DeployInfo.AppName
			Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[508] `$DeployInfo.Environment=`""$DeployInfo.Environment

	}#>
	$todayShort = Get-Date -Format 'MM-dd-yyyy'
	#$OutFileJSON = $RootFolder + "logs\$jsonFileName"

	#$global:fileNamePrefix = $DeployInfo.TenantName + "_" + $DeployInfo.AppName + "_"  + $DeployInfo.Environment + "_" + $todayShort
	$global:fileNamePrefix = $DeployInfo.TenantName + "_" + $DeployInfo.AppName + "_" + $DeployInfo.Solution + "_"  + $DeployInfo.Environment
	#Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[709] `$fileNamePrefix=`"$fileNamePrefix`""
	$global:JsonFileName = $fileNamePrefix  +  ".json" 
	$global:LogFileName = $fileNamePrefix + "_Log.txt"
	#Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[521] `$JsonFileName=`"$JsonFileName`""
	#Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[522] `$LogFileName=`"$LogFileName`""
	#$DeployInfo.LogFile = $fileNamePrefix + "_Log.txt"

	<#
	$DeployInfo.LogFile = "$LogsFolderPath\$LogFileName" 
	$DeployInfo.OutFileJSON = "$LogsFolderPath\$JsonFileName" 
	$global:OutFileJSON = "$LogsFolderPath\$JsonFileName"
	$global:OutFile = "$LogsFolderPath\$LogFileName"
	#>

	$DeployInfo.LogFile = "..\logs\$LogFileName" 
	$DeployInfo.OutFileJSON = "..\Logs\$JsonFileName" 
	$global:OutFileJSON = "..\Logs\$JsonFileName"
	$global:OutFile = "..\Logs\$LogFileName"

	<#If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.SetOutputFileNames[120]"

		Write-Host -ForegroundColor Yellow "`$fileNamePrefix=`"$fileNamePrefix`""
		Write-Host -ForegroundColor Yellow "`$LogsFolderPath=`"$LogsFolderPath`""

			Write-Host -ForegroundColor Yellow "`$JsonFileName=`"$JsonFileName`""
		Write-Host -ForegroundColor Yellow "`$LogFileName=`"$LogFileName`""

			$OutFileJSON = $DeployInfo.OutFileJSON
		Write-Host -ForegroundColor Cyan "`$DeployInfo.OutFileJSON=`"$OutFileJSON`""
		$LogFile = $DeployInfo.LogFile
			Write-Host -ForegroundColor Yellow "`$DeployInfo.LogFile=`"$LogFile`""
	}#>

	
}#SetOutputFileNames

Function global:InitializeDeployInfoObject
{
	Write-Debug "InitiateScripts.InitializeDeployInfoObject[93]"
	<#If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.InitializeDeployInfoObject[94]"
	}#>
	$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$global:TransferAppObj = [ordered]@{
		DeploymentName = "DeploymentName";
		AppName = "AppName";
		Environment = "Environment";
		Location = "Location";
		Solution = "Transfer";
			ResourceGroupName = "ResourceGroupName";
		RoleDefinitionId = "RoleDefinitionId";
		#RoleDefinitionFile =  $DeployFolder + "DTPStorageBlobDataReadWrite.json"
		RoleDefinitionFile =   "..\DTPStorageBlobDataReadWrite.json"
			SqlAdmin = "SqlAdmin";
		SqlAdminPwd = "SqlAdminPwd";

		APIAppRegName = "APIAppRegName";
		APIAppRegAppId = "APIAppRegAppId";
		APIAppRegObjectId = "APIAppRegObjectId";
		APIAppRegClientSecret = "APIAppRegClientSecret";
		APIAppRegServicePrincipalId = "APIAppRegServicePrincipalId";
		APIAppRegExists = $false;

		ClientAppRegName = "ClientAppRegName";
		ClientAppRegAppId = "ClientAppRegAppId";
		ClientAppRegObjectId = "ClientAppRegObjectId";
		ClientAppRegServicePrincipalId = "ClientAppRegServicePrincipalId";
		ClientAppRegExists = $false;

			BuildFlag = $false;
		PublishFlag = $false;

		StartTime = $StartTime;
		EndTime = "EndTime";
		Duration = "Duration";

			REACT_APP_DTS_AZ_STORAGE_URL = "REACT_APP_DTS_AZ_STORAGE_URL";
	}#TransferAppObj

	$global:PickupAppObj = [ordered]@{
		DeploymentName = "DeploymentName";
		AppName = "AppName";
		Environment = "Environment";
		Location = "Location";
		Solution = "Pickup";
		ResourceGroupName = "ResourceGroupName";
		RoleDefinitionId = "RoleDefinitionId";
			RoleDefinitionFile =  "..\DPPStorageBlobDataRead.json"

		APIAppRegName = "APIAppRegName";
		APIAppRegAppId = "APIAppRegAppId";
		APIAppRegObjectId = "APIAppRegObjectId";
		APIAppRegClientSecret = "APIAppRegClientSecret";
		APIAppRegServicePrincipalId = "APIAppRegServicePrincipalId";
		APIAppRegExists = $false;

		ClientAppRegName = "ClientAppRegName";
		ClientAppRegAppId = "ClientAppRegAppId";
		ClientAppRegObjectId = "ClientAppRegObjectId";
		ClientAppRegServicePrincipalId = "ClientAppRegServicePrincipalId";
		ClientAppRegExists = $false;

			BuildFlag = $false;
		PublishFlag = $false;

		StartTime = $StartTime;
		EndTime = "EndTime";
		Duration = "Duration";


	}#PickupAppObj

	$global:DeployInfo = [ordered]@{
		DeploymentName = "DeploymentName";
		CloudEnvironment = "CloudEnvironment";
		Location = "Location";
		Environment = "Environment";
		AppName = "AppName";
		Solution = "All";
		#BicepFile = $DeployFolder + "main.bicep";
		#TemplateParameterFile = $DeployFolder + "TemplateParameterFile";
		BicepFile = "..\main.bicep";
		TemplateParameterFile = "..\TemplateParameterFile";
		OutFileJSON = "OutFileJSON";
		LogFile = "LogFile";

			SubscriptionName = "SubscriptionName";
		SubscriptionId = "SubscriptionId";
		TenantName = "TenantName";
		TenantId = "TenantId";
		CurrUserName = "CurrUserName";
		CurrUserId = "CurrUserId";
		CurrUserPrincipalName = "CurrUserPrincipalName";
			MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
		StepCount = 1;

		CryptoEncryptRoleId = "CryptoEncryptRoleId";
		ContributorRoleId ="ContributorRoleId";
		DeployMode = "DeployMode";

			StartTime = $StartTime;
		EndTime = "EndTime";
		Duration = "Duration";

			TransferAppObj = $TransferAppObj;
		PickupAppObj = $PickupAppObj;
		Cloud = "Cloud";

	}#DeployInfo
	return $DeployInfo
} #InitializeDeployInfoObject

Function global:CreateDeployInfo
{
	Write-Debug "InitiateScripts.CreateDeployInfo[273]"

	#if the json file exists: populate the deployInfo object's properties

	if (Test-Path ($DeployInfo.OutFileJSON))
	{
		$FullPath = (Get-ChildItem -Path ($DeployInfo.OutFileJSON) | select FullName).FullName
		<#If($debugFlag){
			Write-Host -ForegroundColor Magenta "`nInitiateScripts.CreateDeployInfo[309] File Exists:" $DeployInfo.OutFileJSON
		}#>

			#$json = Get-Content $DeployInfo.OutFileJSON | Out-String | ConvertFrom-Json
		$json = Get-Content $FullPath | Out-String | ConvertFrom-Json
			$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

			<#
		$TransferAppObj.DeploymentName = $json.TransferAppObj.DeploymentName;
			$TransferAppObj.SqlAdmin = $json.TransferAppObj.SqlAdmin;
		$TransferAppObj.SqlAdminPwd = $json.TransferAppObj.SqlAdminPwd;
			$TransferAppObj.APIAppRegName = $json.TransferAppObj.APIAppRegName;
		#>

			$TransferAppObj.APIAppRegAppId = $json.TransferAppObj.APIAppRegAppId;
		$TransferAppObj.APIAppRegObjectId = $json.TransferAppObj.APIAppRegObjectId;
		$TransferAppObj.APIAppRegClientSecret = $json.TransferAppObj.APIAppRegClientSecret;
		$TransferAppObj.APIAppRegServicePrincipalId = $json.TransferAppObj.APIAppRegServicePrincipalId;
			$TransferAppObj.APIAppRegExists = $json.TransferAppObj.APIAppRegExists;

		#$TransferAppObj.ClientAppRegName = $json.TransferAppObj.ClientAppRegName;
		$TransferAppObj.ClientAppRegAppId = $json.TransferAppObj.ClientAppRegAppId;
		$TransferAppObj.ClientAppRegObjectId = $json.TransferAppObj.ClientAppRegObjectId;
		$TransferAppObj.ClientAppRegServicePrincipalId = $json.TransferAppObj.ClientAppRegServicePrincipalId;
			$TransferAppObj.ClientAppRegExists = $json.TransferAppObj.ClientAppRegExists;
		$TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL = $json.TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL
		$PickupAppObj.DeploymentName = $json.PickupAppObj.DeploymentName;
			#$PickupAppObj.APIAppRegName = $json.PickupAppObj.APIAppRegName;
		$PickupAppObj.APIAppRegAppId = $json.PickupAppObj.APIAppRegAppId;
		$PickupAppObj.APIAppRegObjectId = $json.PickupAppObj.APIAppRegObjectId;
		$PickupAppObj.APIAppRegClientSecret = $json.PickupAppObj.APIAppRegClientSecret;
		$PickupAppObj.APIAppRegServicePrincipalId = $json.PickupAppObj.APIAppRegServicePrincipalId;
			$PickupAppObj.APIAppRegExists = $json.PickupAppObj.APIAppRegExists;

			#$PickupAppObj.ClientAppRegName = $json.PickupAppObj.ClientAppRegName;
		$PickupAppObj.ClientAppRegAppId = $json.PickupAppObj.ClientAppRegAppId;
		$PickupAppObj.ClientAppRegObjectId = $json.PickupAppObj.ClientAppRegObjectId;
		$PickupAppObj.ClientAppRegServicePrincipalId = $json.PickupAppObj.ClientAppRegServicePrincipalId;
			$PickupAppObj.ClientAppRegExists = $json.PickupAppObj.ClientAppRegExists;
		#StartTime = $json.PickupAppObj.StartTime;
		#EndTime = $json.PickupAppObj.EndTime;

			<#
		$DeployInfo.DeploymentName = $json.DeploymentName;
		$DeployInfo.CloudEnvironment = $json.CloudEnvironment;
		$DeployInfo.Location = $json.Location;
		$DeployInfo.Environment = $json.Environment;
		$DeployInfo.AppName = $json.AppName;
		$DeployInfo.Solution = $json.Solution;
		#>
		<#
		$DeployInfo.BicepFile = $json.BicepFile;
		$DeployInfo.TemplateParameterFile = $json.TemplateParameterFile;
		$DeployInfo.OutFileJSON =  $json.OutFileJSON;
		$DeployInfo.LogFile = $json.LogFile;
		#> 
			$DeployInfo.SubscriptionName = $json.SubscriptionName;
		$DeployInfo.SubscriptionId = $json.SubscriptionId;
		$DeployInfo.TenantName = $json.TenantName;
		$DeployInfo.TenantId = $json.TenantId;

		$DeployInfo.MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
		$DeployInfo.StepCount = 1;

			$DeployInfo.CryptoEncryptRoleId = $json.CryptoEncryptRoleId;
		#DeployMode = $json.DeployMode;

			$DeployInfo.Cloud = $json.Cloud;

		$DeployInfo.StepCount = 1;
		$DeployInfo.TransferAppObj = $TransferAppObj;
		$DeployInfo.PickupAppObj = $PickupAppObj;
	
			WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo
		<#
		If($debugFlag){
		$Caller='InitiateDeploymentProcess[382]: DeployInfo AFTER Get-Content from json ::'
		PrintDeployObject -object $DeployInfo
		}#>
	} 
	return $DeployInfo
}#CreateDeployInfo

Function global:ConfigureDeployInfo
{
	Param(
			[Parameter(Mandatory = $false)] [String] $Environment
		, [Parameter(Mandatory = $false)] [String] $Location
			, [Parameter(Mandatory = $false)] [String] $AppName 
			, [Parameter(Mandatory = $false)] [String] $DeployMode
	)

	Write-Debug "InitiateScripts.ConfigureDeployInfo[474]"

	<#If($debugFlag){
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.ConfigureDeployInfo[383]"
		Write-Host -ForegroundColor Cyan "`$Environment=`"$Environment`""
		Write-Host -ForegroundColor Cyan "`$Location=`"$Location`""
		Write-Host -ForegroundColor Cyan "`$AppName=`"$AppName`""
		#Write-Host -ForegroundColor Cyan "" $DeployInfo.TenantId`""
		Write-Host -ForegroundColor Cyan "`$DeployMode=`"$DeployMode`""
		Write-Host -ForegroundColor Cyan "`$BuildFlag=`"$BuildFlag`""
		Write-Host -ForegroundColor Cyan "`$PublishFlag=`"$PublishFlag`""
	#}#If($debugFlag)#>

	If($DeployInfo.TenantId -ne $null)
	{
		#Location = PickAzRegion
		If($Location.Length -eq 0)
		{
			$DeployInfo.Location = PickAzRegion
		}
		Else
		{
			$DeployInfo.Location = $Location
		}
		#Write-Host -ForegroundColor Green "InitiateScripts.ConfigureDeployInfo[425] Location: " $DeployInfo.Location
		If($DeployInfo.Location.Length -ne 0)
		{
			 If($Environment.Length -eq 0)
			{
				$DeployInfo.Environment = PickCodeEnvironment
			}
			Else
			{
				$DeployInfo.Environment = $Environment
			}
			$DeployInfo.Environment = (Get-Culture).TextInfo.ToTitleCase($DeployInfo.Environment)
			#Write-Host -ForegroundColor white "InitiateScripts.ConfigureDeployInfo[431] DeployInfo.Environment: "+ $DeployInfo.Environment
	
			 If($AppName.Length -eq 0)
			{
				Write-Host -ForegroundColor Cyan "================================================================================"
				Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`NAME THE APP (WEBSITE PREFIX):"
				Write-Host -ForegroundColor Cyan "================================================================================"
				Write-Host -ForegroundColor Yellow "Enter a BASE name for your apps."
				Write-Host -ForegroundColor Yellow "For example, if your desired website name is:"
				Write-Host -ForegroundColor Yellow "datatransfer.azurewebsites.us and datapickup.azurewebsites.us, enter: 'data' "
				Write-Host -ForegroundColor Yellow "The program will create the names:"
				Write-Host -ForegroundColor Yellow "datatransfer.azurewebsites.us and "
				Write-Host -ForegroundColor Yellow "datapickup.azurewebsites.us respectively"
				Write-Host -ForegroundColor Yellow "`n The name should be short [3-10 chars] and will serve as the prefix for the website and"
				Write-Host -ForegroundColor Yellow "is one of the main building blocks for the resource names that will be created on Azure"
				#Write-Host -ForegroundColor Yellow ""
				#Write-Host -ForegroundColor Yellow ""
				$DeployInfo.AppName = Read-Host "Enter AppName"
			}
			Else
			{
				$DeployInfo.AppName = $AppName
			}
			$DeployInfo.AppName = (Get-Culture).TextInfo.ToTitleCase($DeployInfo.AppName)
	


			 #"`nApp Name:" + $DeployInfo.AppName >> $DeployInfo.LogFile

			 If($DeployMode.Length -eq 0)
			{
				$DeployInfo.DeployMode = PickDeployMode
			}
			Else
			{
				$DeployInfo.DeployMode = $DeployMode
			}
			$DeployInfo.Solution = $DeployInfo.DeployMode
			#Write-Host -ForegroundColor Yellow "InitiateScripts.ConfigureDeployInfo[290] DeployInfo.SqlAdminPwdPlainText:" $DeployInfo.SqlAdminPwdPlainText
	

			#"`nApp Solution:" + $DeployInfo.Solution  >> $DeployInfo.LogFile

			}#If($DeployInfo.Location -ne $null) 
	}#If($DeployInfo.TenantId -ne $null)
	SetOutputFileNames

	$global:CurrUser = Get-AzADUser -SignedIn
	$DeployInfo.CurrUserName = $CurrUser.DisplayName
	$DeployInfo.CurrUserPrincipalName = $CurrUser.UserPrincipalName
	$DeployInfo.CurrUserId = $CurrUser.Id
	$DeployInfo.ContributorRoleId = (Get-AzRoleDefinition -Name Contributor | Select Id).Id
	<#
	If($DeployInfo.DeploymentName -eq "DeploymentName")
	{
		$DeployInfo.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $DeployInfo.TransferAppObj.Solution + "-" + $DeployInfo.PickupAppObj.Solution  + "-" +  $DeployInfo.Environment + "-" + $todayShort
	}
	Else
	{
		If($debugFlag){
			Write-Host "InitiateScripts.ConfigureDeployInfo[600] DeployInfo.DeploymentName=" $DeployInfo.DeploymentName
		}
	}
	#>

	$DeployInfo = CreateDeployInfo

	$DeployInfo.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $DeployInfo.TransferAppObj.Solution + "-" + $DeployInfo.PickupAppObj.Solution  + "-" +  $DeployInfo.Environment + "-" + $todayShort
	

	If($DeployInfo.Environment -eq "Test" -or $DeployInfo.Environment -eq "Dev")
	{
		#$TemplateParameterFile = "$LogsFolderParentPath\main.parameters.dev.json"
		#$DeployInfo.TemplateParameterFile = $LogsFolderParentPath + "\main.parameters.dev.json"
		$DeployInfo.TemplateParameterFile = "..\main.parameters.dev.json"
	}
	Else
	{
		#$TemplateParameterFile = "$LogsFolderParentPath\main.parameters.prod.json"
		#$DeployInfo.TemplateParameterFile = $LogsFolderParentPath + "\main.parameters.prod.json"
		$DeployInfo.TemplateParameterFile = "..\main.parameters.prod.json"
	}

	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.ConfigureDeployInfo[495]"
			Write-Host -ForegroundColor Cyan "Location= " $DeployInfo.Location
		Write-Host -ForegroundColor Cyan "Environment= " $DeployInfo.Environment
		Write-Host -ForegroundColor Cyan "Solution= " $DeployInfo.Solution
		Write-Host -ForegroundColor Cyan "AppName= " $DeployInfo.AppName
		Write-Host -ForegroundColor Cyan "DeployMode= " $DeployInfo.DeployMode
		Write-Host -ForegroundColor Cyan "DeploymentName= " $DeployInfo.DeploymentName
		Write-Host -ForegroundColor Green "TemplateParameterFile= " $DeployInfo.TemplateParameterFile
	}#>
	return $DeployInfo
}#ConfigureDeployInfo

Function global:ConfigureTransferAppObj
{
	Param(
			[Parameter(Mandatory = $false)] [String] $SqlAdmin
		, [Parameter(Mandatory = $false)] [String] $SqlAdminPwd
	)
	Write-Debug "`nInitiateScripts.ConfigureTransferAppObj[513]"

	$TransferAppObj.Solution = "Transfer"
	$TransferAppObj.Environment = $DeployInfo.Environment

	If(($DeployInfo.Environment).ToLower() -eq 'prod')
	{
		If( (($DeployInfo.AppName).ToLower() -eq 'dtp')  )
		{ 
			$TransferAppObj.AppName = ($DeployInfo.AppName)
		}
		ElseIf(($DeployInfo.AppName).ToLower() -eq 'dts')
		{
			$PickupAppObj.AppName = ($DeployInfo.AppName) + $DeployInfo.Solution
			}
		else
		{
			$TransferAppObj.AppName = ($DeployInfo.AppName) + $DeployInfo.Solution + $TransferAppObj.Environment
		}
	}
	Else
	{ 
		If( (($DeployInfo.AppName).ToLower() -eq 'dtp') -or  (($DeployInfo.AppName).ToLower() -eq 'dts') )
		{ 
			$TransferAppObj.AppName = ($DeployInfo.AppName) + $DeployInfo.Environment
		}
		else
		{
			$TransferAppObj.AppName = ($DeployInfo.AppName) + $DeployInfo.Solution + $TransferAppObj.Environment
		}

	}#else if Environment != prod

	$TransferAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $TransferAppObj.Solution + "-" + $TransferAppObj.Environment + "-" + $todayShort
	$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($TransferAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($TransferAppObj.Environment) 
	$TransferAppObj.APIAppRegName = $TransferAppObj.AppName + 'API'
	#$TransferAppObj.ClientAppRegName = $TransferAppObj.AppName + $TransferAppObj.Solution
	$TransferAppObj.ClientAppRegName = $TransferAppObj.AppName

	#$DeployInfo.TransferAppObj = $TransferAppObj
	
	#$TransferAppObj.Environment = (Get-Culture).TextInfo.ToTitleCase($TransferAppObj.Environment)
	$TransferAppObj.Location = $DeployInfo.Location
	<#If($debugFlag){
		Write-Host -ForegroundColor Red "InitiateScripts[591] "
		Write-Host -ForegroundColor Yellow "SqlAdmin=" $SqlAdmin
		Write-Host "SqlAdminPwd.Length=" $SqlAdminPwd.Length
	#}#>
	If($SqlAdmin.Length -eq 0)
	{
		$SqlAdmin = Read-Host "Enter SQL Server Admin Login" #-AsSecureString }
	}
	Else
	{
		$TransferAppObj.SqlAdmin = $SqlAdmin
	}
	If($SqlAdminPwd.Length -eq 0)
	{ 

		$SqlAdminPwdSecure = Read-Host "Enter SQL Server Admin Password" -AsSecureString
		$SqlAdminPwdPlainText = ConvertFrom-SecureString-AsPlainText -SecureString $SqlAdminPwdSecure
		$TransferAppObj.SqlAdminPwd = $SqlAdminPwdPlainText
	}
	Else
	{
		#Write-Host -ForegroundColor Red "InitiateScripts[702] SqlAdminPwd.Length=" $SqlAdminPwd.Length
		$DeployInfo.TransferAppObj.SqlAdminPwd = $SqlAdminPwd 
	}

	
	If($debugFlag)
	{
			Write-Host -ForegroundColor Cyan "`$BuildFlag=" $BuildFlag
		Write-Host -ForegroundColor Yellow "`$BuildFlag -eq null =" ($BuildFlag -eq $null)
		Write-Host -ForegroundColor Green "`$BuildFlag.Length=" $BuildFlag.Length

		Write-Host -ForegroundColor Cyan "`$PublishFlag=" $PublishFlag
		Write-Host -ForegroundColor Yellow "`$PublishFlag -eq null=" ($PublishFlag -eq $null)
		Write-Host -ForegroundColor Green "`$PublishFlag.Length=" $PublishFlag.Length

		if($BuildFlag.Length -eq 0)
		{
			$TransferAppObj.BuildFlag =  GetBuildFlag
		}
		else
		{
			$TransferAppObj.BuildFlag = $BuildFlag
		}

			if($PublishFlag.Length -eq 0)
		{
			$TransferAppObj.PublishFlag =  GetPublishFlag
		}
		else
		{
			$TransferAppObj.PublishFlag = $PublishFlag
		}

		Write-Host -ForegroundColor Magenta "`n================================================================================"
		Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureTransferAppObj[619]:"
		Write-Host -ForegroundColor Green "`$TransferAppObj.ResourceGroupName=" $TransferAppObj.ResourceGroupName
		Write-Host -ForegroundColor Green "`$TransferAppObj.DeploymentName=" $TransferAppObj.DeploymentName
		Write-Host -ForegroundColor Green "`$Solution=" $DeployInfo.Solution
		Write-Host -ForegroundColor Green "`$TransferAppObj.AppName=" $TransferAppObj.AppName
		Write-Host -ForegroundColor Green "`$TransferAppObj.APIAppRegName=" $TransferAppObj.APIAppRegName
		Write-Host -ForegroundColor Green "`$TransferAppObj.APIAppRegAppId=" $TransferAppObj.APIAppRegAppId
		Write-Host -ForegroundColor Green "`$TransferAppObj.APIAppRegObjectId=" $TransferAppObj.APIAppRegObjectId
		Write-Host -ForegroundColor Green "`$TransferAppObj.ClientAppRegName=" $TransferAppObj.ClientAppRegName
		Write-Host -ForegroundColor Green "`$TransferAppObj.ClientAppRegAppId=" $TransferAppObj.ClientAppRegAppId
		Write-Host -ForegroundColor Green "`$TransferAppObj.ClientAppRegObjectId=" $APIAppRegObjectId.ClientAppRegObjectId
		Write-Host -ForegroundColor Green "`$TransferAppObj.BuildFlag=" $TransferAppObj.BuildFlag
		Write-Host -ForegroundColor Green "`$TransferAppObj.PublishFlag=" $TransferAppObj.PublishFlag

		Write-Host -ForegroundColor Magenta "================================================================================" 
	}#>
	Else
	{
		$TransferAppObj.BuildFlag = GetBuildFlag
		$TransferAppObj.PublishFlag = GetPublishFlag
	}

	<#If($debugFlag){
	$Caller='InitiateDeploymentProcess.ConfigureTransferAppObj[703] ::'
	PrintDeployObject -object $DeployInfo
	}#>

	WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo
	return $TransferAppObj
}#ConfigureTransferAppObj

Function global:ConfigurePickupAppObj
{
	Write-Debug "InitiateScripts.ConfigurePickupAppObj[716]"

	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`nInitiateScripts.ConfigurePickupAppObj[719]"
		Write-Host -ForegroundColor Green "InitiateScripts.ConfigurePickupAppObj[720] DeployMode:" $DeployInfo.DeployMode
	}#>
	$PickupAppObj.Solution = "Pickup"

	$PickupAppObj.Environment = $DeployInfo.Environment
	#$PickupAppObj.Environment = (Get-Culture).TextInfo.ToTitleCase($PickupAppObj.Environment)

	$PickupAppObj.Location = $DeployInfo.Location
	If(($DeployInfo.Environment).ToLower() -eq 'prod')
	{
		If( (($DeployInfo.AppName).ToLower() -eq 'dpp'))
			{
			 $PickupAppObj.AppName = ($DeployInfo.AppName)
		}
		ElseIf(($DeployInfo.AppName).ToLower() -eq 'dts')
		{
			$PickupAppObj.AppName = ($DeployInfo.AppName) + $DeployInfo.Solution 
			} 
		Else
		{
			 $PickupAppObj.AppName = ($DeployInfo.AppName + $PickupAppObj.Solution + $DeployInfo.Environment)
		}
	}
	Else
	{
		If( (($DeployInfo.AppName).ToLower() -eq 'dpp') -or (($DeployInfo.AppName).ToLower() -eq 'dpp'))
			{
			 $PickupAppObj.AppName = ($DeployInfo.AppName) + $DeployInfo.Environment
		}
		Else
		{
			 $PickupAppObj.AppName = ($DeployInfo.AppName + $PickupAppObj.Solution + $PickupAppObj.Environment )
		} 

		If($debugFlag){
			Write-Host -ForegroundColor Cyan "`nInitiateScripts.ConfigurePickupAppObj[766] App Name EQ dtp:" $DeployInfo.AppName
			Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigurePickupAppObj[767] PickupAppObj:" $PickupAppObj.AppName
		} #debug#>
	}#else not prod

	$PickupAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $PickupAppObj.Solution + "-" + $PickupAppObj.Environment + "-" + $todayShort
	#$PickupAppObj.APIAppRegName = ($DeployInfo.AppName + $PickupAppObj.Solution + $PickupAppObj.Environment ) + 'API'
	$PickupAppObj.APIAppRegName = $PickupAppObj.AppName + 'API'
	#$PickupAppObj.ClientAppRegName = $PickupAppObj.AppName + $PickupAppObj.Solution 
	$PickupAppObj.ClientAppRegName = $PickupAppObj.AppName

	$PickupAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($PickupAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($PickupAppObj.Environment) 
 
	If($debugFlag)
	{ 

	Write-Host -ForegroundColor Green "`$BuildFlag -eq null =" ($BuildFlag -eq $null)
	Write-Host -ForegroundColor Green "`$BuildFlag=" $BuildFlag
	Write-Host -ForegroundColor Green "`$BuildFlag.Length=" $BuildFlag.Length

	Write-Host -ForegroundColor Green "`$PublishFlag -eq null=" ($PublishFlag -eq $null)
	Write-Host -ForegroundColor Green "`$PublishFlag=" $PublishFlag
	Write-Host -ForegroundColor Green "`$PublishFlag.Length=" $PublishFlag.Length
		if($BuildFlag.Length -eq 0)
		{
			$PickupAppObj.BuildFlag = GetBuildFlag
		}
		else
		{
			$PickupAppObj.BuildFlag = $BuildFlag
		}

			if($PublishFlag.Length -eq 0)
		{
			$PickupAppObj.PublishFlag = GetPublishFlag
		}
		else
		{
			$PickupAppObj.PublishFlag = $PublishFlag
		}
		Write-Host -ForegroundColor Magenta "`n================================================================================"
		Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigurePickupAppObj[769]:"
			Write-Host -ForegroundColor Green "`$PickupAppObj.DeploymentName=" $PickupAppObj.DeploymentName
		Write-Host -ForegroundColor Green "`$PickupAppObj.ResourceGroupName=" $PickupAppObj.ResourceGroupName
		Write-Host -ForegroundColor Green "`$PickupAppObj.AppName=" $PickupAppObj.AppName
		Write-Host -ForegroundColor Green "`$PickupAppObj.APIAppRegName=" $PickupAppObj.APIAppRegName
		Write-Host -ForegroundColor Green "`$PickupAppObj.ClientAppRegName=" $PickupAppObj.ClientAppRegName
		Write-Host -ForegroundColor Green "`$PickupAppObj.ClientAppRegAppId=" $PickupAppObj.ClientAppRegAppId
		Write-Host -ForegroundColor Green "`$PickupAppObj.ClientAppRegObjectId=" $PickupAppObj.ClientAppRegObjectId

		Write-Host -ForegroundColor Green "`$PickupAppObj.BuildFlag=" $PickupAppObj.BuildFlag
		Write-Host -ForegroundColor Green "`$PickupAppObj.PublishFlag=" $PickupAppObj.PublishFlag

		Write-Host -ForegroundColor Magenta "================================================================================" 
	}#>
	Else
	{
		$PickupAppObj.BuildFlag = GetBuildFlag
		$PickupAppObj.PublishFlag = GetPublishFlag
	}
	#Write-Host "InitiateScripts.ConfigurePickupAppObj[363] PickupAppObj.ResourceGroupName=" $PickupAppObj.ResourceGroupName
	#$DeployInfo.PickupAppObj = $PickupAppObj
	<#
	$Caller='InitiateScripts.ConfigurePickupAppObj[561]:: PickupAppObj'
	PrintObject -object $PickupAppObj -Caller $Caller
	#>
	return $PickupAppObj
}#ConfigurePickupAppObj


