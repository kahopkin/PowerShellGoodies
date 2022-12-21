cd Downloads
Connect-AzAccount -Environment AzureUSGovernment

$RootFolder = "C:\Users\deployadmin\Downloads\"

$ResourceGroupName = ""
$AppName = ""

#DTP API
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


#bmtn local dev
$ResourceGroupName ="rg-dtplocal-dev"
$AppName = "dtplocal"
$ResourceGroupName = "rg-dtp-prod"
$AppName = "dtp"
$RootFolder = "C:\GitHub\DeployDTP\dtpLocalDev\"
$ArchivePath = $RootFolder + "SiteDTP.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName

publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath


#STAGE
$ResourceGroupName = "rg-dtpstage-test"
$AppName = "dtpstage"
$RootFolder = "C:\GitHub\DeployDTP\dtpStageTest\"
$ArchivePath = $RootFolder + "SiteDTP.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
Write-Host -ForegroundColor Green "myApp.DefaultHostName:" $myApp.DefaultHostName

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
$ArchivePath = $RootFolder + "DPPApi.zip"
Write-Host -ForegroundColor Yellow "ResourceGroupName:" $ResourceGroupName
Write-Host -ForegroundColor Yellow "AppName:" $AppName
Write-Host -ForegroundColor Yellow "ArchivePath:" $ArchivePath

$myApp = Get-AzWebApp -Name $AppName -ResourceGroupName $ResourceGroupName
#verify 
$myApp.DefaultHostName
publish-AzWebApp -WebApp $myApp -ArchivePath $ArchivePath
