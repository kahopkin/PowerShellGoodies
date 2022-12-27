$MyDeployment = Get-AzDeployment -DeploymentName Deployment_11-10-2022
#These are set as outputs in bicep
$MyDeployment.Outputs
$MyDeployment.Outputs.endpointSuffix.Value


#Complete offline deploy package prep steps: 
$RootFolder = "C:\GitHub\dtp\"
$DeployFolder = "C:\GitHub\DeployDTP\"

#DTP API: Function App
#cd C:\GitHub\dtp\API\dtpapi
$dirPath = $RootFolder + "API\dtpapi"
cd $dirPath

dotnet build
dotnet publish

#cd C:\GitHub\dtp\API\dtpapi\bin\Debug\net6.0\publish 
$dirPath = $RootFolder + "API\dtpapi\bin\Debug\net6.0\publish"
cd $dirPath
$DestinationPath = $DeployFolder + '\deployDTPAPI.zip' 
Compress-Archive * -DestinationPath $DestinationPath -Force 

#DPP API:
#cd C:\GitHub\dtp\API\DPP
$dirPath = $RootFolder + "API\DPP"
cd $dirPath 
dotnet build
dotnet publish 

#cd C:\GitHub\dtp\API\DPP\bin\Debug\net6.0\publish
$dirPath = $RootFolder + "API\DPP\bin\Debug\net6.0\publish"
cd $dirPath 
$DestinationPath = $DeployFolder + 'deployDPPAPI.zip' 
Compress-Archive * -DestinationPath $DestinationPath -Force 

#cd C:\GitHub\dtp\Sites
$dirPath = $RootFolder + "Sites"
cd $dirPath
npm run hydrateNodeModules

#before running npm run build: make sure .env files are up to date
npm run build:dtp

npm run build:dpp

<#Copy the build folder from 
    C:\GitHub\dtp\Sites\packages\dtp\build 
        to 
    C:\GitHub\dtp
#>

$Source = $RootFolder + "Sites\packages\dtp\build"
$Destination = $RootFolder + "build"
Copy-Item $Source $Destination -Recurse

#Create the deployDTS_Clients.zip
<#this is hard coded in the script if no object gets passed in:
$CompressList = @(  
        "$RootFolder" + "\build"
        "$RootFolder" + "\Deploy"
        "$RootFolder" + "\Docs" 
        "$RootFolder" + "\Sites"
        "$RootFolder" + "\wiki"
        "$RootFolder" + "\.gitignore"
        "$RootFolder" + "\.gitmodules"
        "$RootFolder" + "\CODEOWNERS"   
        "$RootFolder" + "\README.md"
        "$RootFolder" + "\SECURITY.md"    
    )
#>

#Load C:\GitHub\dtp\Deploy\powershell\CreateOfflineDeployZipPackage.ps1
#C:\GitHub\dtp\Deploy\powershell\CreateOfflineDeployZipPackage.ps1 `

#Create zip archive for Clients
& "C:\GitHub\dtp\Deploy\powershell\CreateOfflineDeployZipPackage.ps1"
$RootFolder = "C:\GitHub\dtp"
$DeployFolder = "C:\GitHub\dtpOfflineDeploy\"
$DestinationPath = $DeployFolder + "deployDTS_Clients.zip"
CreateZip -DestinationPath $DestinationPath -RootFolder $RootFolder 

#create Complete Offline zip archive containing all zips and installers:
& "C:\GitHub\dtp\Deploy\powershell\CreateOfflineDeployZipPackage.ps1"
$RootFolder = "C:\GitHub\dtp"
$DeployFolder = "C:\GitHub\dtpOfflineDeploy\"
$DestinationPath = $DeployFolder + "deployDTS.Zip"
$CompressListJson = ConvertTo-Json (Get-ChildItem -Path $DeployFolder | Select FullName).FullName
$CompressList = $CompressListJson | Out-String | ConvertFrom-Json
CreateZip -DestinationPath $DestinationPath -RootFolder $RootFolder -CompressList $CompressList


#test
& "C:\GitHub\dtp\Deploy\powershell\CreateOfflineDeployZipPackage.ps1"
$DeployFolder = "C:\GitHub\dtpResources\11\11-03-2022\Deploy"
$DestinationPath = $DeployFolder + "deployDTS.Zip"
$CompressListJson = ConvertTo-Json (Get-ChildItem -Path $DeployFolder | Select FullName).FullName
$CompressList = $CompressListJson | Out-String | ConvertFrom-Json
CreateZip -DestinationPath $DestinationPath -RootFolder $RootFolder -CompressList $CompressList


C:\GitHub\dtpResources\11\11-03-2022\DeploydeployDTS.Zip

C:\GitHub\dtpResources\11\11-03-2022\DeploydeployDTS.Zip




$RootFolder = "C:\GitHub\dtp"

$RootFolder = "C:\GitHub\dtpOfflineDeploy\"

$DeployFolder = "C:\GitHub\dtp\Deploy\LocalSetUp\"
$CompressListJson = ConvertTo-Json (Get-ChildItem -Path $DeployFolder | Select FullName).FullName
$CompressList = $CompressListJson | Out-String | ConvertFrom-Json


$DestinationPath = $DeployFolder + "deployDTS.Zip"