<#
#This file will build out the specified deployment artifacts for the DTS solution
# Usage: .\BuildDtsDeploymentArtifacts.ps1 `
#			-DTSSourceRoot <RootToSourceCode> `
#			-DestinationPath <FolderToOutputTo> `
#			[-Artifacts <string[]>] `
#			[-ForDisconnectedEnvironmentTransfer] `
#			[-CleanDestination] `
#			[-CompressOutput -CompressedOutputPath <FolderToOutputTo> `
#			[-CompressArchiveName <string>]]
# 
# Params:
#
# DTSSourceRoot: The root folder path holding the DTS Source code. This is used as the source in which to pull content needed to perform artifact compilation.
#
# DestinationPath: Folder that the generated artifacts will be output into
#
# Artifacts: This parameter is used to mix and match which artifacts to generate. By default, it will generate all DTS artifacts.
# -Valid values: 'OfflineFiles', 
#				'DocumentationUI', 
#				'TransferApi',
#				'PickupApi',
#				'TransferUI',
#				'PickupUI'
# -ex: ... -Artifacts DocumentationUI,TransferUI,PickupUI would build only the client applications 
# -ex: all: -Artifacts OfflineFiles, DocumentationUI, TransferApi, PickupApi, TransferUI, PickupUI
# 
# ForDisconnectedEnvironmentTransfer: A switch used to indicate that the DTP/DPP client artifacts should be built to target a disconnected environment.
# If this flag is specified, the site folder with the raw source for the client apps will be copied 
# and the node modules folder will be hydrated to allow for compilation in the disconnected environment.
# IF not specified, the DTP and DTP artifacts will be compiled and will generate the artifacts for a publish. 
# Note: If compiling client apps, ensure the .env files are populate PRIOR to running.
# 
# CleanDestination: Deletes the destination folder If it exists.
#
# CompressOutput: Indicates to the script to compress generated output into an archive.
#
# CompressedOutputPath: The folder to place the compressed output. Required when CompressOutput is specified. 
# The path specified CANNOT be the same as the destination folder.
# 
# CompressArchiveName: Optional. If specified, compressed output will be stored under an archive with the specifed name.
#
# Examples:
#
# 1) Full build for Disconnected Environment transfer: 
#	  .\BuildDtsDeploymentArtifacts.ps1 `
#			-DTSSourceRoot '..\..\DtsReleases\2.0.0\SourceCode' `
#			-DestinationPath '..\..\DtsReleases\2.0.0\Artifacts' `
#			-ForDisconnectedEnvironmentTransfer
#
# 2) Compile DTP/DPP client side applications: 
#	  .\BuildDtsDeploymentArtifacts.ps1 `
#			-DTSSourceRoot '..\..\DtsReleases\2.0.0\SourceCode' `
#			-DestinationPath '..\..\DtsReleases\2.0.0\Artifacts' `
#			-Artifacts TransferUI,PickupUI
#
# 3) Clean destination, Compile all artifacts for disconnected transfer, and compress
#	  .\BuildDtsDeploymentArtifacts.ps1 `
#			-DTSSourceRoot '..\..\DtsReleases\2.0.0\SourceCode' `
#			-DestinationPath '.\..\DtsReleases\2.0.0\Artifacts' `
#			-CleanDestination `
#			-ForDisconnectedEnvironmentTransfer `
#			-CompressOutput `
#			-CompressedOutputPath '..\..\DtsReleases\2.0.0' `
#			-CompressArchiveName 'DisconnectedTransfer'
#
#
# $DTSSourceRoot
# .\BuildDtsDeploymentArtifacts.ps1 `
#			-DTSSourceRoot '..\..\DtsReleases\2.0.0\SourceCode' `
#			-DestinationPath '.\..\DtsReleases\2.0.0\Artifacts' `
#			-CleanDestination `
#			-ForDisconnectedEnvironmentTransfer `
#			-CompressOutput `
#			-CompressedOutputPath '..\..\DtsReleases\2.0.0' `
#			-CompressArchiveName 'DisconnectedTransfer'
#>

[CmdletBinding(DefaultParameterSetName = 'Default')]
param (
	[Parameter(Mandatory = $true,
		Position=0,
		HelpMessage= 'Path to the root folder containing the DTS Source Code.')]
	[string]$DTSSourceRoot,

	[Parameter(Mandatory = $true,
		Position=1,
		HelpMessage= 'Path to the folder that the output will be stored in.')]
	[string]$DestinationPath = $null,

	[Parameter(Mandatory = $false,
		HelpMessage= 'Valid values are: OfflineFiles, DocumentationUI, TransferApi, PickupApi, TransferUI, PickupUI')]
	[ValidateSet('OfflineFiles', 'DocumentationUI', 'TransferApi','PickupApi','TransferUI','PickupUI', IgnoreCase = $true)]
	[string[]] $Artifacts = @('OfflineFiles', 'DocumentationUI', 'TransferApi', 'PickupApi', 'TransferUI', 'PickupUI'),

	[Switch]$ForDisconnectedEnvironmentTransfer,

	[Switch]$CleanDestination = $false,

	[Switch]$CompressOutput,

	[Parameter(Mandatory = $true,
		ParameterSetName='CompressOutput',
		HelpMessage= 'Path to the folder that the output will be stored in.')]
	[string]$CompressedOutputPath,

	[Parameter(Mandatory = $false,
		ParameterSetName='CompressOutput')]
	[string]$CompressArchiveName=$null
)

If($debugFlag){
	Write-host -ForegroundColor Magenta "`n BuildDtsDeploymentArtifacts.BuildArchive[113]::"
	Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
	Write-host -ForegroundColor Green  "`$DTSSourceRoot=`"$DTSSourceRoot`""
	$DTSSourceRootPath = (Get-Item $DTSSourceRoot).FullName
	Write-host -ForegroundColor Green  "`$DTSSourceRootPath=`"$DTSSourceRootPath`""
	Write-host -ForegroundColor Green  "`$DestinationPath=`"$DestinationPath`""
	Write-host -ForegroundColor Green  "`$CleanDestination=`"$CleanDestination`""
	Write-host -ForegroundColor Green  "`$ForDisconnectedEnvironmentTransfer=`"$ForDisconnectedEnvironmentTransfer`""
	Write-host -ForegroundColor Green  "`$CompressOutput=`"$CompressOutput`""
	Write-host -ForegroundColor Green  "`$CompressedOutputPath=`"$CompressedOutputPath`""
	Write-host -ForegroundColor Green  "`$CompressArchiveName=`"$CompressArchiveName`""
}

Function BuildArchive
{
	param (
		[Parameter(Mandatory = $true)] $ArchiveName,
		[Parameter(Mandatory = $true)] $ArchiveRoot,
		[Parameter(Mandatory = $true)] $OutputPath
	)
	$archiveOuputPath = Join-Path -Path $OutputPath -ChildPath "$ArchiveName.zip"

	If($debugFlag){

		Write-host -ForegroundColor Magenta "BuildDtsDeploymentArtifacts.BuildArchive[137]::"
		Write-host -ForegroundColor Green  "`$ArchiveName=`"$ArchiveName`""
		Write-host -ForegroundColor Green  "`$ArchiveRoot=`"$ArchiveRoot`""
		Write-host -ForegroundColor Green  "`$OutputPath=`"$OutputPath`""
		Write-host -ForegroundColor Green  "`$archiveOuputPath=`"$archiveOuputPath`""
	}

	If (Test-Path $archiveOuputPath)
	{
		Remove-Item -Path $archiveOuputPath
	}

	Compress-Archive -Path "$ArchiveRoot\*" -DestinationPath $archiveOuputPath
}

Function Output-Message {
	param (
		[Parameter(Mandatory = $true)]
		[String]$Message
	)
	#Write-Output "[$(Get-Date -Format 'MM/dd/yyyy HH:mm:ss.ffff')] $Message"
	Write-Host -ForegroundColor Cyan "[$(Get-Date -Format 'MM/dd/yyyy HH:mm:ss.ffff')] $Message"
}

Output-Message "Beginning artifact generation. "
Output-Message "DTS source root: $DTSSourceRoot"
Output-Message "Artifacts output destination: $DestinationPath"

If ([string]::IsNullOrWhiteSpace($DTSSourceRoot) -or !(Test-Path -Path $DTSSourceRoot)) {
	throw "Invalid source root path. Path: '$DTSSourceRoot'"
}

If ([string]::IsNullOrWhiteSpace($DestinationPath)) {
	throw "Invalid destination path. Path: '$DestinationPath'"
}

If ($CompressOutput) 
{
	If ([string]::IsNullOrWhiteSpace($CompressedOutputPath)) {
		throw "Invalid output compression path. Path: '$CompressedOutputPath'"
	}

	If ($CompressedOutputPath -eq $DestinationPath) {
		throw "CompressedArchivePath cannot be the same as the arfifact destination path."
	}
}

$documentationSlnRoot = Join-Path -Path $DTSSourceRoot -ChildPath "/Api/DTS.Documentation"
$dtpApiSlnRoot = Join-Path -Path $DTSSourceRoot -ChildPath "/Api/dtpapi"
$dppApiSlnRoot = Join-Path -Path $DTSSourceRoot -ChildPath "/Api/DPP"
$clientUISourceRoot = Join-Path -Path $DTSSourceRoot -ChildPath "/Sites"

If($debugFlag){
 Write-host -ForegroundColor Magenta "`n BuildDtsDeploymentArtifacts.BuildArchive[191]::"
	Write-host -ForegroundColor Green  "`$documentationSlnRoot=`"$documentationSlnRoot`""
	Write-host -ForegroundColor Green  "`$DTSSourceRoot=`"$DTSSourceRoot`""
	Write-host -ForegroundColor Green  "`$dtpApiSlnRoot=`"$dtpApiSlnRoot`""
	Write-host -ForegroundColor Green  "`$dppApiSlnRoot=`"$dppApiSlnRoot`""
	Write-host -ForegroundColor Green  "`$clientUISourceRoot=`"$clientUISourceRoot`""
}

If ($outDirExists -and (Test-Path -Path $DestinationPath)) {
	Output-Message "Removing existing output directory. Existing Path: '$DestinationPath'"
	Remove-Item $DestinationPath -Recurse
}

If (!(Test-Path -Path $DestinationPath)) {
	Output-Message "Creating output directory at $DestinationPath"
	New-Item $DestinationPath -ItemType Directory > $null
}

If ($Artifacts -contains "OfflineFiles") {
	Output-Message 'Copying deploy scripts to destination.'
	Copy-Item -Path (Join-Path -Path $DTSSourceRoot -ChildPath 'Deploy') -Destination (Join-Path $DestinationPath -ChildPath 'Deploy') -Recurse -Force

	Output-Message 'Copying offline docs to destination...'
	Copy-Item -Path (Join-Path -Path $DTSSourceRoot -ChildPath 'Docs') -Destination (Join-Path $DestinationPath -ChildPath 'Docs') -Recurse -Force

	Output-Message 'Copying utilities to destination...'
	Copy-Item -Path (Join-Path -Path $DTSSourceRoot -ChildPath 'Utilities') -Destination (Join-Path $DestinationPath -ChildPath 'Utilities') -Recurse -Force
}

If ($Artifacts -contains "DocumentationUI") {
	Output-Message 'Building Documentation Project...'
	#Compile DocFX project
	dotnet build $documentationSlnRoot
	$ArtifactsSiteDir = Join-Path -Path $documentationSlnRoot -ChildPath "_site"

	BuildArchive -archiveName "Documentation.Website" -archiveRoot $ArtifactsSiteDir -outputPath $DestinationPath
}

If ($Artifacts -contains "TransferApi") {
	Output-Message 'Building DTP API Project...'
	#Compile DTP API project
	$publishDir = Join-Path -Path $DestinationPath -ChildPath "TransferPortal"
	dotnet publish $dtpApiSlnRoot -o $publishDir

	BuildArchive -archiveName "TransferPortalApi.FunctionApp" -archiveRoot $publishDir -outputPath $DestinationPath

	#Remove uncompress publish files
	Remove-Item $publishDir -Recurse
}

If ($Artifacts -contains "PickupApi") {
	Output-Message 'Building DPP API Project...'
	#Compile DPP API project
	$publishDir = Join-Path -Path $DestinationPath -ChildPath "PickupPortal"
	dotnet publish $dppApiSlnRoot -o $publishDir

	BuildArchive -archiveName "PickupPortalApi.FunctionApp" -archiveRoot $publishDir -outputPath $DestinationPath

	#Remove uncompress publish files
	Remove-Item $publishDir -Recurse
}

If($Artifacts -contains "TransferUI" -or $Artifacts -contains "PickupUI")
{
	Output-Message 'Preparing Client side code...'

	If ($ForDisconnectedEnvironmentTransfer)
	{
		$sitesDestinationPath = Join-Path -Path $DestinationPath -ChildPath "Sites"

		#...Remove existing sites directory
		If (Test-Path $sitesDestinationPath) {
			Output-Message 'Removing existing Client side code...'
			Remove-Item -Path $sitesDestinationPath -Recurse -Force
		}

		#...copy the sites directory
		Output-Message 'Copying Client side code to destination...'
		Copy-Item -Path $clientUISourceRoot -Destination $sitesDestinationPath -Recurse -Force

			#Install/Validate npm packages in the Artifacts output
		Output-Message "Hydrating NPM packages"
		npm run hydrateNodeModules --prefix $sitesDestinationPath > $null
	}
	Else
	{
		#Install/Validate npm packages in the source root
		Output-Message "Validating NPM packages"
		If($debugFlag){
			Write-host -ForegroundColor Magenta "`n BuildDtsDeploymentArtifacts.PickupUI[263]::"
			Write-host -ForegroundColor Green  "`$clientUISourceRoot=`"$clientUISourceRoot`""
		}

			npm run hydrateNodeModules --prefix $clientUISourceRoot > $null

		If ($Artifacts -contains "TransferUI")
		{
			npm run build:dtp --prefix $clientUISourceRoot

			$dtpClientBuildDir = Join-Path -Path $clientUISourceRoot -ChildPath "packages/dtp/build"

			If (!(Test-Path -Path $dtpClientBuildDir))
			{
				Write-Error "Cannot compile DTP client ui. Missing build output."
			}
			If($debugFlag){
				Write-host -ForegroundColor Magenta "BuildDtsDeploymentArtifacts.TransferUI[274]::"
				Write-host -ForegroundColor Green  "`$dtpClientBuildDir=`"$dtpClientBuildDir`""
			}#>
			BuildArchive -archiveName "TransferPortalUI.Website" -archiveRoot $dtpClientBuildDir -outputPath $DestinationPath
		}

		If ($Artifacts -contains "PickupUI")
		{
			npm run build:dpp --prefix $clientUISourceRoot

			$dppClientBuildDir = Join-Path -Path $clientUISourceRoot -ChildPath "packages/dpp/build"

			If (!(Test-Path -Path $dppClientBuildDir))
			{
				Write-Error "Cannot compile DPP client ui. Missing build output."
			}

			BuildArchive -archiveName "PickupPortalUI.Website" -archiveRoot $dppClientBuildDir -outputPath $DestinationPath
		}
	}#Else(ForDisconnectedEnvironmentTransfer)
}#If ($Artifacts -contains "TransferUI" -or $Artifacts -contains "PickupUI") 

#After everything is finished,
#If specfied, compress the artifacts folder
If ($CompressOutput) {
	If ([string]::IsNullOrWhiteSpace($CompressArchiveName)) {
		$CompressArchiveName = "DtsArtifactGenerationOutput_$(Get-Date -Format 'MMddyyyyhhmmssffff')"
	}

	If (-not (Test-Path $CompressedOutputPath)) {
		Write-host -ForegroundColor Red  "DOES NOT EXIST:`$CompressedOutputPath=`"$CompressedOutputPath`""
		#$folderName = $CompressedOutputPath.split("\")
			#Write-host -ForegroundColor Yellow  "`$CompressedOutputPath=`"$CompressedOutputPath`""
		#New-Item -Path $LogsFolderParentPath -Name $folderName -ItemType Directory
	}

	$archivePath = Join-Path -Path $CompressedOutputPath -ChildPath "$CompressArchiveName.zip"

	If($debugFlag){
		Write-host -ForegroundColor Magenta "`n`tBuildDtsDeploymentArtifacts[315]::"
		Write-host -ForegroundColor Yellow  "`$CompressedOutputPath=`"$CompressedOutputPath`""
		Write-host -ForegroundColor Yellow  "`$CompressArchiveName=`"$CompressArchiveName`""
		Write-host -ForegroundColor Yellow  "`$archivePath=`"$archivePath`""
		Write-host -ForegroundColor Yellow  "`$DestinationPath=`"$DestinationPath`""
	}

	If (Test-Path $archivePath) {
		Output-Message "Removing existing archive path at '$archivePath'"
		Remove-Item $archivePath
	}

	Write-Output 'Begin artifact compression...'
	Compress-Archive -Path "$DestinationPath\*" -DestinationPath $archivePath
	Write-Output 'Artifact compression complete.'
}

 Write-Output 'Artifact generation complete.'