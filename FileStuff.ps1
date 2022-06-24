$jsonFileName = "DeploymentOutput_" + $today + ".json"
$jsonFileName = "test.json"
$OutFileJSON= "..\$jsonFileName"

if (Test-Path $jsonFileName) {
    Write-Host "File Exists"
    $myJson = Get-Content $OutFileJSON
    Write-Host "CreateAppRegistration[15] OutFileJSON.length=" $OutFileJSON.length()
}
else
{
    Write-Host "File Doesn't Exists"
}