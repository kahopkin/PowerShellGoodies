<#
TestAzFunctions.ps1
#>

$debugFlag = $true

$currDir = Get-Item (Get-Location)
$currDirPath = $currDir.FullName

if($currDirPath -notmatch "PowerShellGoodies")
{
    cd C:\GitHub\PowerShellGoodies
    
}

$dtpDirPath="c:\github\dtp\deploy\powershell"

If($debugFlag){
    #Write-host -ForegroundColor Magenta "`nInitiateScripts.SetLogFolder[41]::"
    Write-host -ForegroundColor Green  "`$currDir=`"$currDir`""
    Write-host -ForegroundColor Green  "`$currDirPath=`"$currDirPath`""
               
    Write-host -ForegroundColor Cyan  "`$dtpDirPath=`"$dtpDirPath`""
    #Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""
}#debugFlag #>


								
#Install-Module -name Microsoft.Graph.Applications
Import-Module -Name Microsoft.Graph.Applications

#& "$PSScriptRoot\PreReqCheck.ps1"
& "$dtpDirPath\UtilityFunctions.ps1"
& "$dtpDirPath\ConnectToMSGraph.ps1"
& "$dtpDirPath\BuildLocalSettingsFile"
#& "$dtpDirPath\GetAzureADToken.ps1"
& "$dtpDirPath\CreateEnvironmentFiles.ps1"
& "$dtpDirPath\InitiateScripts.ps1"
& "$dtpDirPath\CreateResourceGroup.ps1"
& "$dtpDirPath\CreateAppRoles.ps1"
& "$dtpDirPath\SetApplicationIdURI.ps1"
& "$dtpDirPath\SetRedirectURI.ps1"
& "$dtpDirPath\CreateAppRegistration.ps1"
& "$dtpDirPath\CreateScopes.ps1"
& "$dtpDirPath\CreateServicePrincipal.ps1"    
& "$dtpDirPath\AddAPIPermissions.ps1"
& "$dtpDirPath\AddRoleAssignment.ps1"
& "$dtpDirPath\StartBicepDeploy.ps1"
& "$dtpDirPath\RunDeployment.ps1"


$DeployInfo = InitializeDeployInfoObject



#Connect to Az and MS Graph              
$AzureContext = Get-AzContext

$DeployInfo = SetDeployInfoObj -DeployObject $DeployInfo

PrintCurrentContext -DeployObject $DeployInfo
$DeployInfo.BicepFile =  $DeployFolder +  "mainDebug.bicep"        

$Caller='`n TestAzFunctions.[55] DeployInfo::'
PrintObjectAsVars -Object $DeployInfo -Caller $Caller





$hash1 = @{ Name = "firstSubnet"; AddressPrefix = "10.0.0.0/24"}
$hash2 = @{ Name = "secondSubnet"; AddressPrefix = "10.0.1.0/24"}
$subnetArray = $hash1, $hash2
New-AzResourceGroupDeployment -ResourceGroupName testgroup `
  -TemplateFile <path-to-bicep> `
  -exampleArray $subnetArray
