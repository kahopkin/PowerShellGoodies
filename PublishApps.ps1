cd Downloads

Connect-AzAccount -Environment AzureUSGovernment

$ResourceGroupName = ""
$AppName = ""

$ResourceGroupName = "rg-transferdata-prod"
$AppName = "TransferData"
$RootFolder = "C:\Users\deployadmin\Downloads\deployDTS\"
$ArchivePath = $RootFolder + "deployDTS_Clients.zip"

Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "RootFolder:" $RootFolder
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

#Get all zip folders in RootFolder
$CompressListJson = ConvertTo-Json `
    (Get-ChildItem -Path $RootFolder | Where-Object { $_.Extension -eq '.zip' } `
    | Select FullName).FullName

$CompressList = $CompressListJson | Out-String | ConvertFrom-Json


$ArchivePath = $RootFolder + 'deployDTS_Clients.zip'
$Destination = $RootFolder + 'deployDTPAPI'
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $Destination

cd $RootFolder + "deployDTS_Clients\Sites"





$ArchivePath = $RootFolder + 'deployDTPAPI.zip'
$Destination = $RootFolder + 'deployDTPAPI'
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $Destination

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
$myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath

<#
$ResourceGroupName = 'rg-pickupdata-prod'
$AppName = 'pickupdata'
$ArchivePath = '\Downloads\deployDTS\'
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
#>