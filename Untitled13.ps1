#PublishApps from datacenter2019
# 
Function ExpandArchive
{
#cd Downloads
$RootFolder = "C:\Users\deployadmin\Downloads\"
$FullPath = $RootFolder + "deployDTS.zip"
$DestinationFolder = $RootFolder +  ((Get-ItemProperty  $FullPath | select Name).Name).Split(".")[0]
$today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START ExtractZips FOR $FullPath *****************"
Expand-Archive -LiteralPath $FullPath -DestinationPath $DestinationFolder
$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
$EndTime = $today
$Duration = New-TimeSpan -Start $StartTime -End $EndTime
Write-Host -ForegroundColor Cyan "====================================================================================================" 
Write-Host -ForegroundColor Cyan "[$today] COMPLETED Expand-Archive "
Write-Host -ForegroundColor Cyan "DURATION [HH:MM:SS]:" $Duration
Write-Host -ForegroundColor Cyan "===================================================================================================="  
}#ExpandArchive

ExpandArchive

Function publishApps
{
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
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

#Get all zip folders in RootFolder
$CompressListJson = ConvertTo-Json `
    (Get-ChildItem -Path $RootFolder | Where-Object { $_.Extension -eq '.zip' } `
    | Select FullName).FullName
$CompressList = $CompressListJson | Out-String | ConvertFrom-Json


$ArchivePath = $RootFolder + 'deployDTPAPI.zip'
$Destination = 'C:\Users\deployadmin\Downloads\deployDTS\deployDTPAPI'
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $Destination

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
$myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
}

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