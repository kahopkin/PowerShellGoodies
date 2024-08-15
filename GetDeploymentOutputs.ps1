
$PSFolder = "C:\GitHub\dtp\Deploy\powershell"

#& "$PSFolder\PreReqCheck.ps1"
& "$PSFolder\UtilityFunctions.ps1"
& "$PSFolder\InitiateScripts.ps1"
<#
& "$PSFolder\ConnectToMSGraph.ps1"
& "$PSFolder\BuildLocalSettingsFile"
& "$PSFolder\GetAzureADToken.ps1"
& "$PSFolder\CreateEnvironmentFiles.ps1"

& "$PSFolder\CreateResourceGroup.ps1"
& "$PSFolder\CreateAppRoles.ps1"
& "$PSFolder\SetApplicationIdURI.ps1"
& "$PSFolder\SetRedirectURI.ps1"
& "$PSFolder\CreateAppRegistration.ps1"
& "$PSFolder\CreateScopes.ps1"
& "$PSFolder\CreateServicePrincipal.ps1"    
& "$PSFolder\AddAPIPermissions.ps1"
& "$PSFolder\AddRoleAssignment.ps1"
& "$PSFolder\AddCustomRoleFromFile.ps1"
& "$PSFolder\StartBicepDeploy.ps1"
& "$PSFolder\RunDeployment.ps1"
#>



$DeployInfo = InitializeDeployInfoObject
$DeployInfo.LogFile = "Logfile.js"
$DeploymentName="Dts_Transfer_Prod"

#
If($debugFlag){
    #Write-Host -ForegroundColor Cyan "`nInitiateDeploymentProcess[71] debugFlag=" $debugFlag
    $ObjectName = "DeployInfo"
    $Caller='InitiateDeploymentProcess[73] after PickDeployMethod::'    
    PrintDeployObject -ObjectName $ObjectName -Object $DeployInfo -Caller $Caller
}#If($debugFlag) #>



$DeploymentOutput = Get-AzDeployment -Name $DeploymentName
#$DeploymentOutput = $DeploymentOutput.Outputs

ParseDeploymentOutput -DeployObject $DeployInfo -DeploymentOutput $DeploymentOutput

$auditStName = $DeploymentOutput.Outputs.auditStName.Value
Write-Host -ForegroundColor Cyan "`$DeploymentOutput.Outputs.AuditStName=`""$auditStName

$ApplicationId = $DeployObject.APIAppRegAppId 

$SystemPrincipalName = $DeploymentOutput.Outputs.auditStName.Value
Write-Host -ForegroundColor Yellow "`$SystemPrincipalName=`"$SystemPrincipalName`""

If($DeploymentOutput.Outputs.auditStName -ne $null)
{    
    Write-Host -ForegroundColor Green "`$DeploymentOutput.Outputs.AuditStName=`""$auditStName
    Write-Host -ForegroundColor Green "`$DeploymentOutput.Outputs.ApplicationId=`""$ApplicationId

    $ResourceGroupName="rg-dts-transfer-prod"
    $KeyVault = "kv-dts-transfer-prod"
    Set-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $SystemPrincipalName -AssignIdentity
    $stAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $SystemPrincipalName
    Set-AzKeyVaultAccessPolicy -VaultName $KeyVault -ObjectId $stAccount.Identity.PrincipalId -PermissionsToKeys wrapkey,unwrapkey,get


    $KeyName = $DeployObject.AuditStKeyName
    $KeyVaultUri = $DeployObject.KeyVaultUri
    # In case to enable key auto rotation, don't set KeyVersion
    Set-AzStorageAccount -ResourceGroupName $ResourceGroupName `
                         -Name $SystemPrincipalName `
                         -KeyvaultEncryption `
                         -KeyName $KeyName `
                         -KeyVersion $key.Version `
                         -KeyVaultUri $keyVault.VaultUri

    $SystemPrincipal = Get-AzADServicePrincipal -DisplayName $SystemPrincipalName
    $SystemPrincipalName = $SystemPrincipal.DisplayName
    
    New-AzADServicePrincipal -ApplicationId $ApplicationId

    Write-Host -ForegroundColor Green "`$SystemPrincipalName=`"$SystemPrincipalName`""
    #ConfigureStorageEncryption -DeployObject $DeployInfo -StorageAccount $DeployInfo.MainStName                    
}   



