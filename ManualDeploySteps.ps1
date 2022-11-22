Connect-AzAccount -Environment AzureUSGovernment

$ResourceGroupName = "rg-dtp-prod"
$AppName = "func-api-dtp-prod"
$archivePath = "C:\Users\demoadmin\Downloads\deployDTPAPI.zip"
    
$functionApp = Get-AzWebApp -Name $AppName
publish-AzWebApp -WebApp $functionApp -ArchivePath $archivePath




winget install Microsoft.DotNet.SDK.6

cd dtp\API\dtpapi
dotnet build
dotnet publish

cd .\bin\Debug\net6.0\publish
$DestinationPath = 'C:\GitHub\DeployDTP\deployDTPAPI.zip' 
Compress-Archive * -DestinationPath $DestinationPath -Force

npm build:dpp

#You must connect to Azure before attempting the rest:
Connect-AzAccount -Environment AzureUSGovernment

$ResourceGroupName = 'rg-dts-prod-ht'
$webAppName = 'FUNCTION_APP_NAME'
$functionApp = Get-AzWebApp -Name  -ResourceGroupName $ResourceGroupName

nslookup datapickup.azurewebsites.us

$archivePath = '.\C:\GitHub\DeployDTP\deployDTPAPI.zip'
publish-AzWebApp -WebApp $functionApp -ArchivePath $archivePath

publish-AzWebApp -WebApp $webApp -ArchivePath $archivePath

$DestinationPath = 'ROOT\deployDTS\deployDPP.zip'
Compress-Archive -Path * -DestinationPath $DestinationPath

cd to deployDTS


$ResourceGroupName = 'rg-dts-prod-ht'
$webAppName = 'datapickup'

$webApp = Get-AzWebApp -Name datapickup -ResourceGroupName rg-dts-prod-ht 
$webApp = Get-AzWebApp -Name $webAppName -ResourceGroupName $ResourceGroupName 
    $ResourceGroupName = 'RESOURCE_GROUP_NAME'
    $webAppName = 'APP_SERVICE_NAME'
    $webApp = Get-AzWebApp -Name  -ResourceGroupName $ResourceGroupName

$archivePath = '.\deployDPP.zip'
publish-AzWebApp -WebApp $webApp -ArchivePath .\deployDPP.zip
publish-AzWebApp -WebApp $webApp -ArchivePath $archivePath 


cd C:\GitHub\dtp\API\dtpapi

cd C:\GitHub\dtp\API\DPP

$ResourceGroupName = 'rg-dtp-prod'
$AppName = 'func-api-dtp-prod'
$archivePath = '\Downloads'
    
$functionApp = Get-AzWebApp -Name  -ResourceGroupName $ResourceGroupName    
publish-AzWebApp -WebApp $functionApp -ArchivePath $archivePath

cd 

cd C:\GitHub\dtp\API\DPP
dotnet publish

cd C:\GitHub\dtp\API\DPP
dotnet publish 

cd C:\GitHub\dtp\API\DPP\bin\Debug\net6.0\publish
$DestinationPath = 'C:\GitHub\DeployDTP\deployDPPAPI.zip' 
Compress-Archive * -DestinationPath $DestinationPath -Force

$DestinationPath = 'C:\GitHub\DeployDTP\deployDTP.zip'
Compress-Archive * -DestinationPath $DestinationPath -Force

$DestinationPath = 'C:\GitHub\DeployDTP\deployDPP.zip'
Compress-Archive * -DestinationPath $DestinationPath -Force

cd C:\GitHub\dtp\API\DPP
dotnet publish
cd C:\GitHub\dtp\API\DPP\bin\Debug\net6.0\publish
$DestinationPath = 'C:\GitHub\DeployDTP\deployDPPAPI.zip' 
Compress-Archive * -DestinationPath $DestinationPath -Force
