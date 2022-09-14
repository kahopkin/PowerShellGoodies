$ParentFolder ="../logs"
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$jsonFileName = "DeploymentOutput-" + $todayShort + ".json"

$OutFileJSON = "..\logs\$jsonFileName"

Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[70] OutFileJSON: " $OutFileJSON

if (Test-Path $ParentFolder) 
{
    Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[36] EXISTING Logs Folder" $ParentFolder
    $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
    Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[38] EXISTING Logs Folder. FullPath:"  $ParentFolderPath
}

$curDir = Get-Location
Split-Path -Path $curDir -Parent
