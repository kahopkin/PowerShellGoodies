#InitiateDeploymentProcess.ps1
<#
Replace the values ALL CAPS below with your desired values.

The script Will create an Azure App Service with the name: <WEBSITENAME>.azurewebsites.us
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

<#
# Make sure that the user is in the right folder to run the script.
# Running the script is required to be in the dtp\deploy\powershell folder
#>

$currDir= Get-Item (Get-Location)

If($currDir.FullName.Contains("dtp\Deploy\powershell"))
{
    $Caller='InitiateDeploymentProcess[31]'        
    #PrintHashTable -object $currDirHash -Caller $Caller
    
    #Check if logs folder exists in the Deploy folder to save the output log file and the output json files. 
    #if doesn't exist: create the logs folder    
    $DeployPath = "dtp\Deploy\logs"
    $LogsFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    $LogsFolder = Get-ChildItem -Path  $LogsFolderParentPath | `
                    Where-Object { `
                        ($_.PSIsContainer -eq $true) -and `
                        $_.FullName.Contains($DeployPath)}
    #Write-Host -ForegroundColor Green "[69]LogsFolder.Length=" $LogsFolder.FullName.Length
    #Write-Host -ForegroundColor Green  "[43]" ($LogsFolder -eq $null)
    If($LogsFolder -eq $null)
    {
        $folderName ="logs"
        $LogsFolder = New-Item -Path $LogsFolderParentPath -Name $folderName -ItemType Directory
        $LogsFolderPath = (Get-ItemProperty  $LogsFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "Created LogsFolderPath: $LogsFolderPath" 
    } 
    Else
    {
        $LogsFolderPath = $LogsFolder.FullName
        #Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[54] LogsFolderPath: $LogsFolderPath" 
    }   

    #Output file and the json file needed for the Bicep deployment
    $todayLong = Get-Date -Format "MM-dd-yyyy-HH-mm"
    $OutFile = "$LogsFolderPath+""\OutputFile_" + $todayLong + ".txt"

    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    $jsonFileName = "DeploymentOutput-" + $todayShort + ".json"

    $OutFileJSON = "$LogsFolderPath\$jsonFileName"
    Write-Host -ForegroundColor Yellow "OutFileJSON: " $OutFileJSON

    $OutFile = "$LogsFolderPath\OutputFile_" + $todayShort + ".txt"
    Write-Host -ForegroundColor Yellow "OutPut Log File: " $OutFile
    
    & "$PSScriptRoot\ConnectToMSGraph.ps1"
    & "$PSScriptRoot\UtilityFunctions.ps1"
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

    $global:debugFlag = $false
    #$global:debugFlag = $true

    if($debugFlag)
    {

        Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[89] debugFlag: " $debugFlag
        $today = Get-Date -Format 'ddd'   
	    #$Environment = "prod"
        #$Environment = "dev"					
        $Environment = "test"
        $Location = "usgovvirginia"   
        $Location = "usgovtexas"
        $AppName = $today + "Site"    
        $AppName = $today
        $AppName = $today + $Environment
        $AppName = "depguide"+ $Environment
	
        if ($Environment.ToLower() -eq "test" -or $Environment.ToLower() -eq "dev") 
        {
            $global:TemplateParameterFile = "$LogsFolderParentPath\main.parameters.dev.json"
        }
        else 
        {
            $global:TemplateParameterFile = "$LogsFolderParentPath\main.parameters.prod.json"
        }
        Write-Host -ForegroundColor Green "TemplateParameterFile: " $TemplateParameterFile  
        
        RunDeployment `
            -Environment $Environment `
            -Location $Location `
            -AppName $AppName                
    }
    else
    {            
        RunDeployment    
    }
    
}
Else{
    Write-Host -ForegroundColor Red -BackgroundColor White "The successful deployment requires that you execute this script from the 'dtp\Deploy\powershell' folder."
    Write-Host -ForegroundColor Red -BackgroundColor White "Please change directory to the 'dtp\Deploy' folder and run this script again..."
    exit(1)
}