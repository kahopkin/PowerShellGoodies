#Surface Book
cd C:\GitHub\DeployDTP\dtpLocalDev
Connect-AzAccount -Environment AzureUSGovernment

$RootFolder = "C:\GitHub\DeployDTP\dtpLocalDev\"

$ResourceGroupName = ""
$AppName = ""

$RootFolder = "C:\GitHub\DeployDTP\dtpLocalDev\"
$ResourceGroupName = "rg-dtplocal-dev"
$AppName = "dtplocalapi"
$ArchivePath = $RootFolder + "DTP-API.zip"

Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath


$RootFolder = "C:\GitHub\DeployDTP\dtpLocalDev\"
$ResourceGroupName = "rg-dtplocal-dev"
$AppName = "dtplocal"
$ArchivePath = $RootFolder + "SiteDTP.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName

publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath


$RootFolder = "C:\GitHub\DeployDTP\dtpLocalDev\"
$ResourceGroupName = "rg-dpplocal-dev"
$AppName = "dpplocalapi"
$ArchivePath = $RootFolder + "DPP-Api.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
#$myApp.DefaultHostName
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath

$RootFolder = "C:\GitHub\DeployDTP\dtpLocalDev\"
$ResourceGroupName = "rg-dpplocal-dev"
$AppName = "dpplocal"
$ArchivePath = $RootFolder + "SiteDPP.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
#$myApp.DefaultHostName
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
