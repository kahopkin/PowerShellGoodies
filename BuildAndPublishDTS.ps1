$debugFlag = $true
$RootFolder = "C:\GitHub\dtp\"
$RootFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)
#$DtsReleasePath = "C:\GitHub\DtsReleaseDev\"

#$AppName = "DTS"
$AppName = "DTP"
$Solution = "Dev"
$Solution = "Prod"

$DtsReleaseFolderName = "DtsRelease_" + $AppName + "_" + $Solution
$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

if (-not (Test-Path $DtsReleasePath)) 
{
    $DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
    $DtsReleasePath = $DtsReleaseFolder.FullName
}

Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""

#FUNCTION APP:
#DPP API

$ApiDirPath = $RootFolder + "API\DPP"
 #C:\GitHub\dtp\API\DPP\bin\Release\net6.0\publish
$ApiOutputFolder = $ApiDirPath + "\bin\Release\net6.0\publish"
Write-host -ForegroundColor Green  "`$ApiDirPath=`"$ApiDirPath`""
Write-host -ForegroundColor Yellow  "`$ApiOutputFolder=`"$ApiOutputFolder`""

cd $APIdirPath
dotnet build --configuration Release 
dotnet publish --configuration Release
#output from build and publish:
#C:\GitHub\dtp\API\DPP\bin\Release\net6.0\publish

$ApiPublishedFolder =  $RootFolder + "API\DPP\bin\Release\net6.0\publish"
Write-Host -ForegroundColor Yellow "ApiPublishedFolder:" $ApiPublishedFolder

cd $ApiPublishedFolder 
#$DestinationPath = $DtsReleasePath + '\DPP_FunctionApp.zip' 
$DestinationPath = $DtsReleasePath + '\PickupPortalApi.FunctionApp.zip' 

#this matches Eric's naming
#$DestinationPath = $DtsReleasePath + '\PickupPortalApi.FunctionApp.zip'  
Write-host -ForegroundColor Cyan  "`$DestinationPath=`"$DestinationPath`""
Compress-Archive * -DestinationPath $DestinationPath -Force 

#Publish API FUNCTION APP:

#$ResourceGroupName = "rg-dts-pickup-dev"
$ResourceGroupName = "rg-dts-pickup-prod"

##FUNCTION APP NAME:
#$AppName = "dtspickupdevapi"
$AppName = "dtspickupapi"

$Destination = $DtsReleasePath + "\PickupPortalApi.FunctionApp.Website.zip"
$ArchivePath = $DestinationPath

Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-Host -ForegroundColor Cyan "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName
$debugFlag = $true

#CLIENT WEBSITE

#DPP SITE
#Build sites packages
$RootFolder = "C:\GitHub\dtp\"
#$RootFolder = "C:\GitHub\dtpResources\dtp-2.0.0-Jan2023\"
$dirPath = $RootFolder + "Sites"
Write-Host -ForegroundColor Cyan "dirPath:" $dirPath

cd $dirPath

#npm install -g svgo
If(-not $debugFlag){npm run hydrateNodeModules}

#before running npm run build: make sure .env files are up to date
npm run build:dpp

#create zip
$SourceFolder = $RootFolder + "\Sites\packages\dpp\build\*"

#Publish WEBSITE to Azure
#DPP SITE
$ArchivePath = $DtsReleasePath + "\PickupPortalUI.Website.zip"

Compress-Archive -Path $SourceFolder -DestinationPath $ArchivePath -Force

#$ResourceGroupName = "rg-dts-pickup-dev"
$ResourceGroupName = "rg-dts-pickup-prod"
#$AppName = "dtspickupdev"
$AppName = "dtspickup"

Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-Host -ForegroundColor Cyan "ArchivePath:" $ArchivePath


$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName

#$AppName = "DTS"
$AppName = "DTP"
$Solution = "Dev"
$Solution = "Prod"
$RootFolder = "C:\GitHub\dtp\"
$RootFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)
#$DtsReleasePath = "C:\GitHub\DtsReleaseDev\"

$AppName = "DTS"
$Solution = "Dev"


$DtsReleaseFolderName = "DtsRelease_" + $AppName + "_" + $Solution
#$DtsReleaseFolderName = "DtsReleaseDev"
$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

if (-not (Test-Path $DtsReleasePath)) 
{
    $DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
    $DtsReleasePath = $DtsReleaseFolder.FullName
}

Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""



$ApiDirPath = $RootFolder + "API\dtpapi"
                             
$ApiOutputFolder = $ApiDirPath + "\bin\Release\net6.0\publish"
Write-host -ForegroundColor Green  "`$ApiDirPath=`"$ApiDirPath`""
Write-host -ForegroundColor Yellow  "`$ApiOutputFolder=`"$ApiOutputFolder`""

cd $APIdirPath
dotnet build --configuration Release 
dotnet publish --configuration Release

$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish"
Write-Host -ForegroundColor Yellow "ApiPublishedFolder:" $ApiPublishedFolder

cd $ApiPublishedFolder 
#$DestinationPath = $DtsReleasePath + '\DTP_FunctionApp.zip' 
$DestinationPath = $DtsReleasePath + '\TransferPortalApi.FunctionApp.zip' 

#this matches Eric's naming
#$DestinationPath = $DtsReleasePath + '\PickupPortalApi.FunctionApp.zip'  
Write-host -ForegroundColor Cyan  "`$DestinationPath=`"$DestinationPath`""
Compress-Archive * -DestinationPath $DestinationPath -Force 


$ResourceGroupName = "rg-dts-transfer-dev"
#FUNCTION APP NAME:
$AppName = "dtstransferdevapi"

$Destination = $DtsReleasePath + "\TransferPortalApi.FunctionApp.Website.zip"
$ArchivePath = $DtsReleasePath + "\TransferPortalApi.FunctionApp.zip"
$ArchivePath = $DestinationPath


Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-Host -ForegroundColor Cyan "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName




#CLIENT WEBSITE

#DTP SITE
#Build sites packages
$RootFolder = "C:\GitHub\dtp\"
#$RootFolder = "C:\GitHub\dtpResources\dtp-2.0.0-Jan2023\"
$dirPath = $RootFolder + "Sites"
Write-Host -ForegroundColor Cyan "dirPath:" $dirPath

cd $dirPath

#npm install -g svgo
npm run hydrateNodeModules

#before running npm run build: make sure .env files are up to date
npm run build:dtp

#create zip
$SourceFolder = $RootFolder + "\Sites\packages\dtp\build\*"

#Publish WEBSITE to Azure
#DPP SITE
$ArchivePath = $DtsReleasePath + "\TransferPortalUI.Website.zip"

Compress-Archive -Path $SourceFolder -DestinationPath $ArchivePath -Force

$ResourceGroupName = "rg-dts-transfer-dev"
$AppName = "dtstransferdev"


Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-Host -ForegroundColor Cyan "ArchivePath:" $ArchivePath



$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName