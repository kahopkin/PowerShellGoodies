$debugFlag = $true

$AppName = "DTS"
#$AppName = "DTP"
#$AppName = "Kat"

#$Solution = "Dev"
$Solution = "Prod"

$ResourceGroupName =
$ResourceGroupName = "rg-dts-pickup-prod"

$RootFolder = "C:\GitHub\dtp\"
$RootFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)


$DtsReleaseFolderName = "DtsRelease_" + $AppName + "_" + $Solution
#$DtsReleaseFolderName = "DtsReleaseDev"
$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName
Write-host -ForegroundColor Cyan  "`$DtsReleasePath=`"$DtsReleasePath`""
if (-not (Test-Path $DtsReleasePath)) 
{
    $DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
    $DtsReleasePath = $DtsReleaseFolder.FullName
}

Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
Write-host -ForegroundColor Cyan  "`$DtsReleasePath=`"$DtsReleasePath`""
Write-host -ForegroundColor Yellow  "`$RootFolderParentPath=`"$RootFolderParentPath`""


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
Write-host -ForegroundColor Cyan  "`$DestinationPath=`"$DestinationPath`""

Compress-Archive * -DestinationPath $DestinationPath -Force 


#$ResourceGroupName = "rg-dtp-transfer-prod"
#$ResourceGroupName = "rg-kat-transfer-dev"
#FUNCTION APP NAME:
$AppName = "DtpAPI"
$AppName = "kattransferdevapi"

$Destination = $DtsReleasePath + "\TransferPortalApi.FunctionApp.Website.zip"
$ArchivePath = $DtsReleasePath + "\TransferPortalApi.FunctionApp.zip"
#$ArchivePath = $DestinationPath


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
#DTP SITE
$ArchivePath = $DtsReleasePath + "\TransferPortalUI.Website.zip"
Write-Host -ForegroundColor Cyan "SourceFolder:" $SourceFolder
Write-Host -ForegroundColor Cyan "ArchivePath:" $ArchivePath

Compress-Archive -Path $SourceFolder -DestinationPath $ArchivePath -Force

$AppName = "dtp"


Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""




$myApp = Get-AzWebApp `
            -Name $AppName `
            -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $myApp.DefaultHostName
$mySite = publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName