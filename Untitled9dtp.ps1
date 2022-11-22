$RootFolder = "C:\GitHub\dtp"
$DeployFolder = "C:\GitHub\dtpResources\11\11-03-2022\"
$DestinationPath = $DeployFolder + "deployDTS.Zip"

$CompressListJson = ConvertTo-Json (Get-ChildItem -Path $DeployFolder | Select FullName).FullName
$CompressList = $CompressListJson | Out-String | ConvertFrom-Json



C:\GitHub\dtp\Deploy\powershell\CreateOfflineDeployZipPackage.ps1 `
    -DestinationPath $DestinationPath `
    -RootFolder $RootFolder `
    -CompressList $CompressList



$IPStuff = ConvertTo-Json (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress 



$IPStuff = Get-NetIPAddress | ConvertTo-Json
$IPStuffArr = $IPStuff | Out-String | ConvertFrom-Json
Get-NetIPAddress | ConvertTo-Json > IPStuff.json

#Create zip archive with the necessary folders and files:

#Rename deployDTS to deployDTS_Clients.zip


npm run build:dtp
npm run build:dpp

cd C:\GitHub\dtp\Sites\packages\dtp\build
$DestinationPath = 'C:\GitHub\dtpOfflineDeploy\deployDTPAPI.zip'
Compress-Archive * -DestinationPath $DestinationPath -Force

$DestinationPath = 'C:\GitHub\DeployDTP\deployDPP.zip'
Compress-Archive * -DestinationPath $DestinationPath -Force


<#For specific instructions, 
refer to 
C:\GitHub\dtp\Sites\developerSetup.md
#>

#Deploy DTP Data Transfer Portal:
cd C:\GitHub\dtp\Sites

npm run hydrateNodeModules
npm run build:dtp


#create complete zip package to ship to high side:
cd C:\GitHub\dtp\API\dtpapi 
dotnet publish 

cd .\bin\Debug\net6.0\publish

$DestinationPath = 'C:\GitHub\DeployDTP\deployDTPAPI.zip'
Compress-Archive * -DestinationPath $DestinationPath -Force 


$ResourceGroupName = 'rg-dtp-prod'
$AppName = 'datatransfer'
$archivePath = '\Downloads'
    
$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName    
publish-AzWebApp -WebApp $myApp -ArchivePath $archivePath

Function IPV()
{
$IPCHK = ((Invoke-WebRequest ifconfig.me/ip).Content.Trim())
$IPCHK | Out-FIle 'CHKIP.txt'
}
$CurrentIP = ((Invoke-WebRequest ifconfig.me/ip).Content.Trim())
$PreviousIP = Get-Content 'CHKIP.txt'

IF($PreviousIP -eq ((Invoke-WebRequest ifconfig.me/ip).Content.Trim()))
    {
        $PreviousIP
        }
ELSE {
       ##SEND EMAIL SCRIPT
        IPV #RUN CHECK IP COMMAND AGAIN.
}