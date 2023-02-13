$RootFolder = "C:\GitHub\dtp\"
$RootFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)
#$DtsReleasePath = "C:\GitHub\DtsReleaseDev\"

$AppName = "DPP"
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

#FUNCTION APPS:
#DPP API

$ApiDirPath = $RootFolder + "API\DPP"
$ApiOutputFolder = $ApiDirPath + "\publish"
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
$DestinationPath = $DtsReleasePath + '\DPP_FunctionApp.zip' 
#this matches Eric's naming
#$DestinationPath = $DtsReleasePath + '\PickupPortalApi.FunctionApp.zip'  
Write-host -ForegroundColor Cyan  "`$DestinationPath=`"$DestinationPath`""
Compress-Archive * -DestinationPath $DestinationPath -Force 

$ResourceGroupName = "rg-dpp-pickup-dev"
$AppName = "dpppickupdevapi"
#$ArchivePath = $DtsReleasePath + '\DPP_FunctionApp.zip' 
$ArchivePath = $DtsReleasePath + '\PickupPortalApi.FunctionApp.zip'


$ResourceGroupName = "rg-dpp-pickup-dev"
$AppName = "dpppickupdevapi"


#$ResourceGroupName = "rg-demo-pickup-dev"
#$AppName = "demopickupdevapi"
$ArchivePath = $DtsReleasePath + '\DPP_FunctionApp.zip' 
#$ArchivePath = $DtsReleasePath + '\DemoApp_DPP_FunctionApp.zip' 

#$SourceFolder = $RootFolder + "API\DPP\bin\Release\net6.0\publish"

#Publish DPP API to Azure
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green  $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Green "app PUBLISHED DefaultHostName=" $mySite.DefaultHostName


#DPP SITE
#Build sites packages
$RootFolder = "C:\GitHub\dtp\"
#$RootFolder = "C:\GitHub\dtpResources\dtp-2.0.0-Jan2023\"
$dirPath = $RootFolder + "Sites"
Write-Host -ForegroundColor Cyan "dirPath:" $dirPath

cd $dirPath

#npm install -g svgo
npm run hydrateNodeModules

#before running npm run build: make sure .env files are up to date
npm run build:dpp
#create zip
$SourceFolder = $RootFolder + "\Sites\packages\dpp\build\*"
$Destination = $DtsReleasePath + "\SiteDPP.zip"
$Destination = $DtsReleasePath + "\PickupPortalUI.Website.zip"
Write-Host -ForegroundColor Yellow "SourceFolder:" $SourceFolder
Write-Host -ForegroundColor Yellow "Destination:" $Destination

Compress-Archive -Path $SourceFolder -DestinationPath $Destination -Force


#Publish WEBSITE to Azure
#DPP SITE
$ArchivePath = $DtsReleasePath + "\SiteDPP.zip"
v
#$ResourceGroupName = "rg-demo-pickup-dev"
#$AppName = "dppickupdev"

$ResourceGroupName = "rg-dpp-pickup-dev"
$AppName = "dpppickupdev"

Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green  $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Cyan "DefaultHostName=" $mySite.DefaultHostName





###########
# DTP API #
###########
$RootFolder = "C:\GitHub\dtp\"
$RootFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)
#$DtsReleasePath = "C:\GitHub\DtsReleaseDev\"

$AppName = "DTP"
$Solution = "Dev"

if (-not (Test-Path $DtsReleasePath)) 
{
    $DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
    $DtsReleasePath = $DtsReleaseFolder.FullName
}

Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""

$DtsReleaseFolderName = "DtsRelease_" + $AppName + "_" + $Solution
$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

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


#DTP API APP:

$ApiDirPath = $RootFolder + "API\dtpapi"
$ApiOutputFolder = $ApiDirPath + "\publish"

$ArchivePath = $DtsReleasePath + "\TransferPortalApi.FunctionApp.zip"
$SourceFolder = $RootFolder + "API\dtpapi\bin\Release\net6.0\publish"
#              C:\GitHub\dtp\API\dtpapi\bin\Release\net6.0\publish
#C:\GitHub\dtp\API\dtpapi\bin\Release\net6.0\publish
$ApiDirPath = $SourceFolder + "API\dtpapi"
#$ApiOutputFolder = $ApiDirPath + "\publish"
$ApiOutputFolder = $SourceFolder

Write-host -ForegroundColor Green  "`$ApiDirPath=`"$ApiDirPath`""
Write-host -ForegroundColor Green  "`$ArchivePath=`"$ArchivePath`""
Write-host -ForegroundColor Yellow  "`$ApiOutputFolder=`"$ApiOutputFolder`""

cd $APIdirPath
dotnet build --configuration Release 
dotnet publish --configuration Release
#output from build and publish:
#C:\GitHub\dtp\API\dtpapi\bin\Release\net6.0\publish

$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish"
Write-Host -ForegroundColor Yellow "ApiPublishedFolder:" $ApiPublishedFolder

cd $ApiPublishedFolder 
$DestinationPath = $DtsReleasePath + '\DTP_FunctionApp.zip' 
Write-host -ForegroundColor Cyan  "`$DestinationPath=`"$DestinationPath`""
Compress-Archive * -DestinationPath $DestinationPath -Force 

Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green  $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Green "DefaultHostName=" $mySite.DefaultHostName

#DTP CLIENT WEBSITSE

#Build sites packages
$RootFolder = "C:\GitHub\dtp\"
$dirPath = $RootFolder + "Sites"
Write-Host -ForegroundColor Cyan "dirPath:" $dirPath

cd $dirPath

#npm install -g svgo
#npm run hydrateNodeModules

#before running npm run build: make sure .env files are up to date
#create zip
npm run build:dtp

$SourceFolder = $RootFolder + "\Sites\packages\dtp\build\*"
$Destination = $DtsReleasePath + "\SiteDTP.zip"
Write-Host -ForegroundColor Yellow "SourceFolder:" $SourceFolder
Write-Host -ForegroundColor Yellow "Destination:" $Destination
Compress-Archive -Path $SourceFolder -DestinationPath $Destination -Force
#DTP SITE

$ArchivePath = $DtsReleasePath + "\SiteDTP.zip"
$ResourceGroupName = "rg-dtp-transfer-dev"
#$ResourceGroupName = "rg-demo-transfer-dev"
$AppName = "dtptransferdev"
#$AppName = "demotransferdev"


Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green  $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Green "DefaultHostName=" $mySite.DefaultHostName
