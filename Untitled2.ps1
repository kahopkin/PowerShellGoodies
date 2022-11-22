 npm build:dpp


$ResourceGroupName = 'rg-dts-prod-ht'
$webAppName = 'datapickup'
$webApp = Get-AzWebApp -Name  -ResourceGroupName $ResourceGroupName

nslookup datapickup.azurewebsites.us

$archivePath = '.\deployDPP.zip'
publish-AzWebApp -WebApp $webApp -ArchivePath $archivePath

$DestinationPath = 'ROOT\deployDTS\deployDPP.zip'
Compress-Archive -Path * -DestinationPath $DestinationPath

cd to deployDTS