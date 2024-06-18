#PreReqCheck

Function global:CheckInstallPrereqs
{
	Param(
		[Parameter(Mandatory = $true)] [Int32] $StepCount
	)
	$Message = "CHECKING YOUR ENVIRONMENT FOR INSTALLATION PREREQUISITES: POWERSHELL, AZ POWERSHELL, GRAPH"
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING PreReqCheck.CheckInstallPrereqs[14]"
	}#If($debugFlag)#>
	$StepCount = PrintMessage -Message $Message -StepCount $StepCount
	CheckInstalledPSVersion
	CheckAzPsInstallation
	CheckMsGraphInstall
	CheckGraphApplicationModule
	#CheckGraphAuthenticationModule
	return $StepCount
}#CheckInstallPrereqs

Function global:CheckInstalledPSVersion
{
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING PreReqCheck.CheckInstalledPSVersion[30]"
	}#If($debugFlag)#> 

	#Check which version of PowerShell you have installed.
	$psVersion = $PSVersionTable.PSVersion
	#
	If($debugFlag){
		Write-Host -ForegroundColor White "`$psVersion= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$psVersion`""

	}#If($debugFlag)#>
	Else
	{
		Write-Host -ForegroundColor Green -BackgroundColor Black "Installed PowerShell Version=`"$psVersion`""
	}
}#CheckInstalledPSVersion

#do we need this?
#Install-Module -Name Az.ADDomainServicess -Repository PSGallery -Scope CurrentUser

Function global:CheckAzPsInstallation
{
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING PreReqCheck.CheckAzPsInstallation[56]"
	}#If($debugFlag)#> 
 
	#check Az module:
	$azInstalledModule = Get-InstalledModule Az -ErrorAction $ErrorAction
	If($azInstalledModule -ne $null)
	{
		$azInstalledModuleVersion = $azInstalledModule.Version

		$majorV = $azInstalledModuleVersion.Split(".")[0]
		$minorV = $azInstalledModuleVersion.Split(".")[1]
		#
		If($debugFlag)
		{
			Write-Host -ForegroundColor Yellow "PreReqCheck.CheckAzPsInstallation[70] "
			Write-Host -ForegroundColor Green "`$azInstalledModule.Version=`"$azInstalledModuleVersion`""
			Write-Host -ForegroundColor White "`$majorV= " -NoNewline
			Write-Host -ForegroundColor Cyan "`"$majorV`""
			Write-Host -ForegroundColor White "`$minorV= " -NoNewline
			Write-Host -ForegroundColor Yellow "`"$minorV`""
		}#If($debugFlag)#> 

		If($majorV -lt 8)
		{
			#
			If($debugFlag){
				Write-Host -ForegroundColor Yellow "PreReqCheck.CheckAzPsInstallation[82] Az Ps azInstalledModule `$majorV=`"$majorV`""
			 }#If($debugFlag)#> 
			Write-Host -ForegroundColor Green -BackgroundColor Black "Installing latest version of PowerShell"
			Install-Module -Name PowerShellGet -Force
		}#If($majorV -lt 8)
		Else
		{
			#
			If($debugFlag){
				Write-Host -ForegroundColor Yellow "PreReqCheck.CheckAzPsInstallation[92] Az Ps azInstalledModule `$majorV=`"$majorV`""
			}#If($debugFlag)#>
			 If($minorV -lt 1)
			{
				#
				If($debugFlag){
					Write-Host -ForegroundColor Yellow "PreReqCheck.CheckAzPsInstallation[99] azInstalledModule "
					Write-Host -ForegroundColor Green  "`$minorV=`"$minorV`""
				}#If($debugFlag)#>

				 #If not present, run below to install
				Write-Host -ForegroundColor Yellow -BackgroundColor Black "Az Ps Minor version is:"
				Write-Host -ForegroundColor Green -BackgroundColor Black "Installing an update...."
				Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
				try{
					Install-Module -Name Az.Resources -Repository PSGallery -Scope CurrentUser
				}
				catch{
					Write-host -ForegroundColor Red "Error:"
					Write-Host -ForegroundColor Red $_
				 }
			}
			Else
			{
				Write-Host -ForegroundColor Green -BackgroundColor Black "Az Ps Minor version is:" -NoNewline
				Write-Host -ForegroundColor Green -BackgroundColor Black "`$minorV=`"$minorV`""
			}
		}
	}#If($azInstalledModule -ne $null)
	Else
	{
		Write-Host -ForegroundColor Yellow "Installing the Az PowerShell module..."
		Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
		try{
			Install-Module -Name Az.Resources -Repository PSGallery -Scope CurrentUser
		}
		catch{
			Write-host -ForegroundColor Red "Error:"
			Write-Host -ForegroundColor Red $_
			}
	}
}#CheckAzPsInstallation


Function global:CheckMsGraphInstall
{
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING PreReqCheck.CheckMsGraphInstall[143]"
	}#If($debugFlag)#>

	$graphModule = Get-InstalledModule Microsoft.Graph -ErrorAction $ErrorAction

	If($graphModule -eq $null)
	{
		Write-Host -ForegroundColor Red -BackgroundColor Black "Microsoft.Graph is not installed."
		Write-Host -ForegroundColor Green -BackgroundColor Black "Installing Microsoft.Graph...."
		try
		{
			Install-Module Microsoft.Graph -Scope CurrentUser
		}
		catch
		{
			Write-host -ForegroundColor Red "Error:"
			Write-Host -ForegroundColor Red $_
			}
	}
	Else
	{
		$graphModuleVersion = $graphModule.Version
		$majorVgraph = $graphModuleVersion.Split(".")[0]
		$minorVgraph = $graphModuleVersion.Split(".")[1]
		#
		If($debugFlag){
			Write-Host -ForegroundColor Yellow "PreReqCheck.CheckMsGraphInstall[169] graphModuleVersion `$graphModuleVersion=`"$graphModuleVersion`""
			Write-Host -ForegroundColor Green "`$majorVgraph=`"$majorVgraph`""
			Write-Host -ForegroundColor Green "`$minorVgraph=`"$minorVgraph`""
		}#If($debugFlag)#>
	}
}#CheckMsGraphInstall


Function global:CheckGraphApplicationModule
{
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PreReqCheck.CheckGraphApplicationModule[155]"
	}#If($debugFlag)#> 

	$graphApplicationsMod = Get-InstalledModule Microsoft.Graph.* | Where-Object {$_.Name -eq "Microsoft.Graph.Applications"} -ErrorAction $ErrorAction
	If($graphApplicationsMod -eq $null)
	{
		#
		If($debugFlag){
			Write-Host -ForegroundColor Yellow -BackgroundColor White "PreReqCheck.CheckGraphApplication[163]"
			}#If($debugFlag)#> 

			Write-Host -ForegroundColor Red -BackgroundColor Black "Microsoft.Graph.Applications is not installed...."
		Write-Host -ForegroundColor Green -BackgroundColor Black "Installing Microsoft.Graph.Applications module, please choose 'Yes to all' in the popup"
		try
		{
			Install-Module -name Microsoft.Graph.Applications
			Import-Module -Name Microsoft.Graph.Applications
		}
		catch
		{
			Write-host -ForegroundColor Red "Error:"
			Write-Host -ForegroundColor Red $_
			}
	}
	Else
	{
			Write-Host -ForegroundColor Green -BackgroundColor Black "`Importing Microsoft.Graph.Applications"
		Import-Module -Name Microsoft.Graph.Applications
	}
}#CheckGraphApplicationModule

Function global:CheckGraphAuthenticationModule
{
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING PreReqCheck.CheckGraphAuthenticationModule[212]"
	}#If($debugFlag)#>
	$graphAuthenticationsMod = Get-InstalledModule Microsoft.Graph.* | Where-Object {$_.Name -eq "Microsoft.Graph.Authentication"}
	If($graphAuthenticationsMod -eq $null)
	{
		try
		{
			Install-Module -name Microsoft.Graph.Authentication
		}
		catch
		{
			Write-host -ForegroundColor Red "Error:"
			Write-Host -ForegroundColor Red $_
			}
	}
}#CheckGraphAuthenticationModule


<#
Temporarily moved from UtilityFunctions
#>


Function global:GetBuildFlag
{
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetBuildFlag[1051]"
	}#If($debugFlag)#> 

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tWOULD YOU LIKE TO BUILD THE APPLICATIONS?:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor White -BackgroundColor Black "Press the letter in the bracket to choose then press Enter:" 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 1 ] : Yes"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 0 ] : No"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"
	$BuildFlag = Read-Host "Enter your choice"
	Switch ($BuildFlag)
	{
			1{$BuildFlag = $true}
		0{$BuildFlag = $false} 
			X { "Quitting..."
			$BuildFlag = $false
			Exit(1)
		}
		Default {
			$BuildFlag = GetBuildFlag
			}
	}#Switch
	return $BuildFlag
}#GetBuildFlag


Function global:GetPublishFlag
{
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetPublishFlag[]"
	}#If($debugFlag)#> 

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tWOULD YOU LIKE TO PUBLISH THE APPLICATIONS?:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor White -BackgroundColor Black "Press the letter in the bracket to choose, then press Enter:" 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 1 ] : Yes"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 0 ] : No"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"
	$PublishFlag = Read-Host "Enter your choice"
	Switch ($PublishFlag)
	{
			1{$PublishFlag = $true}
		0{$PublishFlag = $false} 
			X { "Quitting..."
		$BuildFlag = $false
			Exit(1)
		}
		Default {
			$PublishFlag = Pick_DebugMode
			}
	}#Switch
	return $PublishFlag
}#GetPublishFlag


Function global:BuildApps
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.BuildApps[]"
	}#If($debugFlag)#> 

	$PSFolderPath = $RootFolder + "Deploy\powershell"
	$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName + "_" + $DeployObject.Environment
	$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

	#CLIENT WEBSITE
	$sitesDirPath = $RootFolder + "Sites"
	$BuildFlag = $DeployObject.BuildFlag
	$PublishFlag = $DeployObject.PublishFlag 

	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[839] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
		Write-host -ForegroundColor Yellow  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
		Write-Host -ForegroundColor Cyan "`$DeployObject.BuildFlag=`"`BuildFlag`""
		Write-host -ForegroundColor Cyan  "`$DeployObject.PublishFlag=`"`PublishFlag`""
	}#If($debugFlag)
	If($BuildFlag)
	{
		#$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName  + "_" + $DeployObject.Environment
		#$DtsReleasePath = $RootFolderParentPath + "\_" + $DtsReleaseFolderName

			$ResourceGroupName = $DeployObject.ResourceGroupName
		$FunctionAppName = $DeployObject.APIAppRegName
		$ClientAppName = $DeployObject.ClientAppRegName

		$FunctionAppArchivePath = $DtsReleasePath + '\' + $DeployObject.APIAppRegName + '_FunctionApp.zip'
		$WebSiteArchivePath = $DtsReleasePath + "\" + $DeployObject.ClientAppRegName + "_WebSite.zip"

		If($debugFlag){
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[866] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			 <#Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
			 #>
			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			 Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			 Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`""

			 #Write-Host -ForegroundColor Cyan "`$=" $
			}#debugFlag #>
		If (-not (Test-Path $DtsReleasePath))
		{
			$DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
			$DtsReleasePath = $DtsReleaseFolder.FullName
		}


		$ApiDirPath = $RootFolder + "API\dtpapi" 
			$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dtp\build\*"
		$buildType = "dtp"

			$ApiOutputFolder = $ApiDirPath + "\bin\Release\net6.0\publish"  

		If($debugFlag){
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[913] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."
			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""

			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			 Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			 Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`""

			 #Write-Host -ForegroundColor Cyan "`$=" $
			}#debugFlag #>

			cd $APIdirPath

		dotnet build --configuration Release
		dotnet publish --configuration Release

		#cd $ApiPublishedFolder
			Compress-Archive -Path $ApiPublishedFolder -DestinationPath $FunctionAppArchivePath -Force 

		#CLIENT
		cd $sitesDirPath
		#explorer $sitesDirPath
		npm run hydrateNodeModules

		#before running npm run build: make sure .env files are up to date
		npm run build:$buildType

			Compress-Archive -Path $SitePublishFolder -DestinationPath $WebSiteArchivePath -Force
		Write-Host -ForegroundColor Green -BackgroundColor Black "Opening folder with the zip files....."
		explorer $DtsReleasePath

	}#BuildFlag

	cd $PSFolderPath  
}#BuildApps


Function global:PublishApps
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PublishApps[]"
	}#If($debugFlag)#> 

	$PSFolderPath = $RootFolder + "Deploy\powershell"
	$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName + "_" + $DeployObject.Environment
	$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

	#CLIENT WEBSITE
	$sitesDirPath = $RootFolder + "Sites"
	$BuildFlag = $DeployObject.BuildFlag
	$PublishFlag = $DeployObject.PublishFlag 

		$ApiDirPath = $RootFolder + "API\dtpapi" 
			$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dtp\build\*"
		$buildType = "dtp"

	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PublishApps[977] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
		Write-host -ForegroundColor Yellow  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
		Write-Host -ForegroundColor Cyan "`$DeployObject.BuildFlag=`"`$BuildFlag`""
		Write-host -ForegroundColor Cyan  "`$DeployObject.PublishFlag=`"`$PublishFlag`""
	}#If($debugFlag)#>

	If($PublishFlag)
	{
		If($debugFlag){
			 Write-Host -ForegroundColor Magenta "UtilityFunctions.PublishApps[996] PUBLISHING CLIENT SITE ...."
		}#debugFlag #>

		$functionApp = Get-AzWebApp `
					-Name $FunctionAppName `
					-ResourceGroupName $ResourceGroupName
		#verify
		If($debugFlag){
			Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $functionApp.DefaultHostName
		}

		#Publish:
		$functionApp = Publish-AzWebApp -Force -WebApp $functionApp -ArchivePath $FunctionAppArchivePath
		Write-Host -ForegroundColor Cyan -BackgroundColor Black "SUCCESS! Published functionApp: DefaultHostName=" $functionApp.DefaultHostName

		#Publish  WEBSITE to Azure
		$myApp = Get-AzWebApp `
					-Name $ClientAppName `
					-ResourceGroupName $ResourceGroupName
		#verify
		Write-Host -ForegroundColor Green "checking ClientApp Get-AzWebApp: " $myApp.DefaultHostName
		$mySite = Publish-AzWebApp -Force -WebApp $myApp -ArchivePath $WebSiteArchivePath
		Write-Host -ForegroundColor Cyan -BackgroundColor Black "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName
	}#PublishFlag

	<#If($debugFlag){
		explorer $DtsReleasePath
	#}#>

	cd $PSFolderPath	
}#PublishApps


Function global:PickBuildAndPublish
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickBuildAndPublish[]"
	}#If($debugFlag)#> 

	$PSFolderPath = $RootFolder + "Deploy\powershell"
	$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName + "_" + $DeployObject.Environment
	$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

	#CLIENT WEBSITE
	$sitesDirPath = $RootFolder + "Sites"
	$BuildFlag = $DeployObject.BuildFlag
	$PublishFlag = $DeployObject.PublishFlag
	

	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[839] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
		Write-host -ForegroundColor Yellow  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
		Write-Host -ForegroundColor Cyan "`$DeployObject.BuildFlag=`"`$BuildFlag`""
		Write-host -ForegroundColor Cyan  "`$DeployObject.PublishFlag=`"`$PublishFlag`""
	}#If($debugFlag)

	If($BuildFlag)
	{
		#$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName  + "_" + $DeployObject.Environment
		#$DtsReleasePath = $RootFolderParentPath + "\_" + $DtsReleaseFolderName

			$ResourceGroupName = $DeployObject.ResourceGroupName
		$FunctionAppName = $DeployObject.APIAppRegName
		$ClientAppName = $DeployObject.ClientAppRegName

		$FunctionAppArchivePath = $DtsReleasePath + '\' + $DeployObject.APIAppRegName + '_FunctionApp.zip'
		$WebSiteArchivePath = $DtsReleasePath + "\" + $DeployObject.ClientAppRegName + "_WebSite.zip"

		If($debugFlag){
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[866] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			 <#Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
			 #>
			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			 Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			 Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`""

			 #Write-Host -ForegroundColor Cyan "`$=" $
			}#debugFlag #>
		If (-not (Test-Path $DtsReleasePath))
		{
			$DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
			$DtsReleasePath = $DtsReleaseFolder.FullName
		}

		$ApiDirPath = $RootFolder + "API\dtpapi" 
			$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dtp\build\*"
		$buildType = "dtp"

		$ApiOutputFolder = $ApiDirPath + "\bin\Release\net6.0\publish"  

		If($debugFlag){
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[913] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."
			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""

			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			 Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			 Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`""

			 #Write-Host -ForegroundColor Cyan "`$=" $
			}#debugFlag #>

			cd $APIdirPath

		dotnet build --configuration Release
		dotnet publish --configuration Release

		#cd $ApiPublishedFolder
			Compress-Archive -Path $ApiPublishedFolder -DestinationPath $FunctionAppArchivePath -Force 

		#CLIENT
		cd $sitesDirPath
		#explorer $sitesDirPath
		npm run hydrateNodeModules
		#npm install -g svgo
		#npx update-browserslist-db@latest
		#before running npm run build: make sure .env files are up to date
		npm run build:$buildType

			Compress-Archive -Path $SitePublishFolder -DestinationPath $WebSiteArchivePath -Force
		Write-Host -ForegroundColor Green -BackgroundColor Black "Opening folder with the zip files....."
		explorer $DtsReleasePath

	}#BuildFlag


	#$PublishFlag = GetPublishFlag
	If($PublishFlag)
		{
			If($debugFlag){
				#
				Write-Host -ForegroundColor Magenta "UtilityFunctions.PickBuildAndPublish[848] PUBLISHING CLIENT SITE ...."
			}#debugFlag #>

			$functionApp = Get-AzWebApp `
						-Name $FunctionAppName `
						-ResourceGroupName $ResourceGroupName
			#verify
			If($debugFlag){
				Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $functionApp.DefaultHostName
			}

			#Publish:
			$functionApp = Publish-AzWebApp -Force -WebApp $functionApp -ArchivePath $FunctionAppArchivePath
			Write-Host -ForegroundColor Cyan "SUCCESS! Published functionApp: DefaultHostName=" $functionApp.DefaultHostName

			#Publish  WEBSITE to Azure
			$myApp = Get-AzWebApp `
						-Name $ClientAppName `
						-ResourceGroupName $ResourceGroupName
			#verify
			Write-Host -ForegroundColor Green "checking ClientApp Get-AzWebApp: " $myApp.DefaultHostName
			$mySite = Publish-AzWebApp -Force -WebApp $myApp -ArchivePath $WebSiteArchivePath
			Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName
		}#PublishFlag

	<#If($debugFlag){
		explorer $DtsReleasePath
	#}#>

	cd $PSFolderPath	
}#PickBuildAndPublish

