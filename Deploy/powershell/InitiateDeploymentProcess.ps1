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

#Install-Module -name Microsoft.Graph.Applications
Import-Module -name Microsoft.Graph.Applications


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

$global:debugFlag = $false
$global:debugFlag = $true

#Output file and the json file needed for the Bicep deployment
$todayLong = Get-Date -Format "MM-dd-yyyy-HH-mm"
$OutFile = "..\logs\OutputFile_" + $todayLong + ".txt"

$todayShort = Get-Date -Format 'MM-dd-yyyy'
$jsonFileName = "DeploymentOutput-" + $todayShort + ".json"

$OutFileJSON = "..\logs\$jsonFileName"
Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[70] OutFileJSON: " $OutFileJSON

$OutFile = "..\logs\OutputFile_" + $todayShort + ".txt"
Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[73] OutFile: " $OutFile

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
    $Environment = "test"
    $Location = "usgovvirginia"   
    $Location = "usgovtexas"
    $AppName = $today + "Site"
    $AppName = $today
	
    if ($Environment.ToLower() -eq "test" -or $Environment.ToLower() -eq "dev") 
    {
        $global:TemplateParameterFile = "..\main.parameters.dev.json"
    }
    else 
    {
        $global:TemplateParameterFile = "..\main.parameters.prod.json"
    }

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

<#
$AppRegObj = IngestJsonFile($OutFileJSON)
$ApiAppObjectId = $AppRegObj.ApiAppObjectId
$ApiAppRegName =  $AppRegObj.ApiAppRegName
SetRedirectURI -ObjectId $ApiAppObjectId
Write-Host -ForegroundColor Green "InitiateDeploymentProcess[112] ApiAppRegName="$ApiAppRegName
Write-Host -ForegroundColor Green "InitiateDeploymentProcess[113] ApiAppObjectId="$ApiAppObjectId
    
$WebAppObjectId = $AppRegObj.WebAppObjectId
$WebAppRegName = $AppRegObj.WebAppRegName
SetRedirectURI -ObjectId $WebAppObjectId
Write-Host -ForegroundColor Green "InitiateDeploymentProcess[117] WebAppRegName=$WebAppRegName"
Write-Host -ForegroundColor Green "InitiateDeploymentProcess[118] WebAppObjectId=$WebAppObjectId"
#SetRedirectURI -ObjectId $AppObjectId
#Write-Host -ForegroundColor Green "RunDeployment.ConfigureAPI[153] Finished setting the RedirectURI"
#>