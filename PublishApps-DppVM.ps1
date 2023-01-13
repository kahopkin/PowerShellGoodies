#PublishApps
cd Downloads
Connect-AzAccount -Environment AzureUSGovernment

$RootFolder = "C:\Users\deployadmin\Downloads\"

$ResourceGroupName = ""
$AppName = ""

$ResourceGroupName = "rg-dtp-prod"
$AppName = "dtpapi"


$ArchivePath = $RootFolder + "deployDTS_Clients.zip"
$ArchivePath = $RootFolder + "deployDTPAPI.zip"


Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
$myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath



$ResourceGroupName = "rg-dpp-prod"
$AppName = "dpp"
$ArchivePath = $RootFolder + "SiteDPP.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName

publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath



$ResourceGroupName = "rg-dpp-prod"
$AppName = "dppapi"
$ArchivePath = $RootFolder + "DPP-Api.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
#$myApp.DefaultHostName
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
