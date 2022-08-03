#InitiateDeploymentProcess.ps1
<#
Replace the values ALL CAPS below with your desired values.

Will create an App Registration with the name: <APIAPPREGNAME>api
i.e. If $ApiAppRegName = "my", the App Registration Name will be: myapi
IF $ApiAppRegName="myapi", the App Registration name will be the same: myapi
$ApiAppRegName = "APIAPPREGNAME"

Will create an Azure App Service with the name: <WEBSITENAME>.azurewebsites.us
i.e.: if $SiteName = "test", the app service will be created: test.azurewebsites.us
$AppName = "WEBSITENAME"

$Environment = "ENVIRONMENT"
Possible values: test|dev|prod

$Location = "'LOCATION"
Possible Location values: usgovvirginia | usgovtexas | usgovarizona | usdodeast | usdodcentral

$Environment = "ENVIRONMENT"
$Location = "LOCATION"
$AppName = "WEBSITENAME"
#>

Import-Module -name Microsoft.Graph.Applications
#Install-Module -name Microsoft.Graph.Applications

$global:debugFlag = $false
$global:debugFlag = $true

if ($Environment -eq "Test" -or $Environment -eq "Dev") 
{
    $global:TemplateParameterFile = "..\main.parameters.dev.json"
}
else 
{
    $global:TemplateParameterFile = "..\main.parameters.prod.json"
}

#Check if logs fodler exists in the Deploy folder to save the output log file and the output json files. 
#if doesn't exist: create the logs folder
$ParentFolder ="../logs"

if (Test-Path $ParentFolder) 
{
    #Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[46] EXISTING $ParentFolder ParentFolder" 
    $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
    Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[48] EXISTING ParentFolder. FullPath:"  $ParentFolderPath
}
else
{
    $dir= Get-Item (Get-Location)
 
    $Parent =$dir.Parent    
    $folderName ="logs"

    $LogsFolder = New-Item -Path $Parent.FullName -Name $folderName -ItemType Directory
    #$ParentFolderPath = (Get-ItemProperty  $LogsFolder | select FullName).FullName
    Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[59] $LogsFolder  path: $ParentFolderPath" 
}

#Output file and the json file needed for the Bicep deployment
$todayLong = Get-Date -Format "MM-dd-yyyy-HH-mm"
$OutFile = "..\logs\OutputFile_" + $todayLong + ".txt"

$todayShort = Get-Date -Format 'MM-dd-yyyy'
$jsonFileName = "DeploymentOutput-" + $todayShort + ".json"

$OutFileJSON = "..\logs\$jsonFileName"
Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[70] OutFileJSON: " $OutFileJSON

$OutFile = "..\logs\OutputFile_" + $todayShort + ".txt"
Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[73] OutFile: " $OutFile
#$FullPath = Get-ChildItem -Path $OutFileJSON | select FullName

& "$PSScriptRoot\ConnectToMSGraph.ps1"
& "$PSScriptRoot\CreateResourceGroup.ps1"
& "$PSScriptRoot\CreateAppRoles.ps1"
& "$PSScriptRoot\SetApplicationIdURI.ps1"
& "$PSScriptRoot\SetRedirectURI.ps1"
& "$PSScriptRoot\CreateAppRegistration.ps1"
& "$PSScriptRoot\CreateScopes.ps1"
& "$PSScriptRoot\CreateServicePrincipal.ps1"
& "$PSScriptRoot\AddAPIPermissions.ps1"
& "$PSScriptRoot\StartBicepDeploy.ps1"
& "$PSScriptRoot\RunDeployment.ps1"

if($debugFlag)
{

    Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[91] debugFlag: " $debugFlag
    $today = Get-Date -Format 'ddd'   
    $Environment = "prod"
    $Location = "usgovvirginia"
    $SiteName = $today + "Site"
    $AppName = $today + "Site"
    #$AppName = $today + "Site" + $Environment
	
    RunDeployment `
        -Environment $Environment `
        -Location $Location `
        -AppName $AppName
}
else
{
     Write-Host -ForegroundColor Green "InitiateDeploymentProcess[106] debugFlag: " $debugFlag
     RunDeployment
}

