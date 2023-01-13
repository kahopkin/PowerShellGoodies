
#InitiateDeploymentProcess.ps1
<#
# Make sure that the user is in the right folder to run the script.
# Running the script is required to be in the dtp\deploy\powershell folder
#>
								
#Install-Module -name Microsoft.Graph.Applications
Import-Module -Name Microsoft.Graph.Applications

#& "$PSScriptRoot\PreReqCheck.ps1"
& "$PSScriptRoot\UtilityFunctions.ps1"
& "$PSScriptRoot\ConnectToMSGraph.ps1"
& "$PSScriptRoot\BuildLocalSettingsFile"
#& "$PSScriptRoot\GetAzureADToken.ps1"
& "$PSScriptRoot\CreateEnvironmentFiles.ps1"
& "$PSScriptRoot\InitiateScripts.ps1"
& "$PSScriptRoot\CreateResourceGroup.ps1"
& "$PSScriptRoot\CreateAppRoles.ps1"
& "$PSScriptRoot\SetApplicationIdURI.ps1"
& "$PSScriptRoot\SetRedirectURI.ps1"
& "$PSScriptRoot\CreateAppRegistration.ps1"
& "$PSScriptRoot\CreateScopes.ps1"
& "$PSScriptRoot\CreateServicePrincipal.ps1"    
& "$PSScriptRoot\AddAPIPermissions.ps1"
& "$PSScriptRoot\AddRoleAssignment.ps1"
& "$PSScriptRoot\StartBicepDeploy.ps1"
& "$PSScriptRoot\RunDeployment.ps1"

#$global:debugFlag = $false
#$global:debugFlag = $true
$debugFlag = Pick_DebugMode

Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[34] debugFlag: " $debugFlag

#Function global:DeploySolution{

PrintWelcomeMessage
SetLogFolder

<#If($debugFlag)
{
    #$DebugPreference = "Continue"
    #$DebugPreference = "Inquire"
    $DebugPreference = "SilentlyContinue"
    #Write-Host -ForegroundColor Cyan "UtilityFunctions.ConfigureDeployInfo[403] debugFlag: " $debugFlag
    $today = Get-Date -Format 'ddd'       
    $Environment = "test"
    $Environment = "prod"
    #$Environment = "dev"
    $Environment = (Get-Culture).TextInfo.ToTitleCase($Environment)
    #Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[101] calling  Environment=:$Environment"
    $Location = "usgovvirginia"       
    $AppName = $today        
    #$AppName = "dtp"
    $AppName = "dpp"   
        
    $AppName = (Get-Culture).TextInfo.ToTitleCase($AppName)
            
    $SqlAdmin = "dtpadmin"
    #$SqlAdmin = ConvertTo-SecureString "dtpadmin"  -AsPlainText -Force 
    
    #$SqlAdminPwd = ConvertTo-SecureString "1qaz2wsx#EDC`$RFV" -AsPlainText -Force
    $SqlAdminPwd = "1qaz2wsx#EDC`$RFV"
    #$TransferAppObj.SqlAdminPwd = ConvertTo-SecureString "1qaz2wsx#EDC$RFV" -AsPlainText -Force
    
    $DeployMode = "Transfer"
    #$DeployMode = "Pickup"
    #$DeployMode = "All"

    #Write-Host -ForegroundColor Red "InitiateDeploymentProcess[77] DeployMode=" $DeployMode
}
#>

#If($debugFlag){exit(1)}

If(($currDir.FullName).ToLower().Contains($correctPath))
{

    #$Caller='InitiateDeploymentProcess[54]'        
    #PrintHash -object $currDirHash -Caller $Caller   
    #Check if logs folder exists in the Deploy folder to save the output log file and the output json files. 
    #if doesn't exist: create the logs folder    
    
    #$global:EnvironmentObj = [ordered]@{}
    #$global:EnvironmentExtendedProps = [ordered]@{}
    
    #Initialize the object:
    InitializeDeployInfoObject  
    
    #Connect to Az and MS Graph   
    #Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[99] calling ConnectToAzure debugFlag=:$debugFlag"
    
    ConnectToAzure
	#Write-Host -ForegroundColor Blue "InitiateDeploymentProcess[101] calling ConnectToAzure debugFlag=:$debugFlag"
    
    If($debugFlag)
    {
        ConfigureDeployInfo `
            -Environment $Environment `
            -Location $Location `
            -AppName $AppName `
            -DeployMode $DeployMode             
    }
    Else
    {
    
        ConfigureDeployInfo 
    }

    PrintLogInfo -DeployObject $DeployInfo
    
    <#
    $Caller='InitiateDeploymentProcess[56]: DeployInfo'       
    PrintObject -object $DeployInfo -Caller $Caller
    #>	
    #Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[119] debugFlag: " $debugFlag
    
    #$deploySuccessFlag = $false

    Switch( $DeployInfo.DeployMode )
    {
        "All"
        {                     
            #Write-Host -ForegroundColor Green "InitiateDeploymentProcess[64] DeployInfo.DeployMode=" $DeployInfo.DeployMode
            $TransferAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
            # DEPLOY DTP (Transfer)        
            
             
            If($debugFlag)
            {
              $TransferAppObj = ConfigureTransferAppObj `
                        -SqlAdmin $SqlAdmin `
                        -SqlAdminPwd $SqlAdminPwd          
            }
            Else
            {
                $TransferAppObj = ConfigureTransferAppObj 
            }        
            <#
            $Caller='InitiateDeploymentProcess[63]: Before RunDeployment :: TransferAppObj'       
            PrintObject -object $TransferAppObj -Caller $Caller
            #>
            
            $RoleDefinitionId = AddCustomRoleFromFile -DeployObject $TransferAppObj   
            <#AddRoleAssignment `
                -RoleDefinitionId $RoleDefinitionId `
                -ResourceGroupName $ResourceGroupName `
                -User
            #>
            
            RunDeployment -DeployObject $TransferAppObj
            $DeploymentOutput = StartBicepDeploy -DeployObject $TransferAppObj -Solution $TransferAppObj.Solution
            #$deploySuccessFlag = $true
            <#$deploySuccessFlag = $false
            If($deploySuccessFlag){
            #>
            CreateEnvironmentFiles `
                -RootFolder $RootFolder `
                -TemplateDir $TemplateDir `
                -DeployObject $TransferAppObj `
                -Cloud $DeployInfo.Cloud
                #-DeploymentOutput $DeploymentOutput
            #}

            #>
            # Deploy DPP (Pickup)
            $PickupAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
            ConfigurePickupAppObj    
            $RoleDefinitionId = AddCustomRoleFromFile -DeployObject $PickupAppObj
            RunDeployment -DeployObject $PickupAppObj
            $DeploymentOutput = StartBicepDeploy -DeployObject $PickupAppObj #-Solution $PickupAppObj.Solution
            #$deploySuccessFlag = $true
            <#$deploySuccessFlag = $false
            If($deploySuccessFlag){
            #>
            CreateEnvironmentFiles `
                -RootFolder $RootFolder `
                -TemplateDir $TemplateDir `
                -DeployObject $PickupAppObj `
                -Cloud $DeployInfo.Cloud 
                #-DeploymentOutput $DeploymentOutput
            #}

            PrintDeployDuration -DeployObject $DeployInfo

            <#
            $Caller='InitiateDeploymentProcess[70]: Before RunDeployment :: PickupAppObj'       
            PrintObject -object $PickupAppObj -Caller $Caller
            #>           
            
            <#
            $Caller='InitiateDeploymentProcess[88]: AFTER RunDeployment :: TransferAppObj'       
            PrintObject -object $TransferAppObj -Caller $Caller
            #>
            <#
            $Caller='InitiateDeploymentProcess[93]: AFTER RunDeployment :: PickupAppObj'       
            PrintObject -object $PickupAppObj -Caller $Caller
            #>            
            
        }
        "Transfer"
        {
            #Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[97] DeployInfo.DeployMode=" $DeployInfo.DeployMode
            # DEPLOY DTP (Transfer)    
            $TransferAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
            If($debugFlag)
            {
                $TransferAppObj = ConfigureTransferAppObj `
                        -SqlAdmin $SqlAdmin `githu
                        -SqlAdminPwd $SqlAdminPwd          
            }
            Else
            {
                $TransferAppObj = ConfigureTransferAppObj 
            } 
                                
            $RoleDefinition = AddCustomRoleFromFile -DeployObject $TransferAppObj
            RunDeployment -DeployObject $TransferAppObj -Solution $TransferAppObj.Solution
            
            $DeploymentOutput = StartBicepDeploy -DeployObject $TransferAppObj -Solution $TransferAppObj.Solution
            $TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL = "https://" + $DeploymentOutput.Outputs.storageAccountNameMain.Value + ".blob." + $DeployInfo.Cloud.StorageEndpointSuffix + "/"
            #Write-Host "InitiateDeploymentProcess[204]  DeploymentOutput.Outputs:"
            #Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[230] TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL=" $TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL
            #$DeploymentOutput
            #$DeploymentOutput.Outputs.appName
            #$deploySuccessFlag = $false
            #$deploySuccessFlag = $true
            <#
            $Caller='InitiateDeploymentProcess[215]: Before CreateEnvironmentFiles :: TransferAppObj'       
            PrintObject -object $TransferAppObj -Caller $Caller
            #>            
            #If($deploySuccessFlag){
            CreateEnvironmentFiles `
                -RootFolder $RootFolder `
                -TemplateDir $TemplateDir `
                -DeployObject $TransferAppObj `
                -Cloud $DeployInfo.Cloud 
                #-DeploymentOutput $DeploymentOutput
            #}
            <#
                #add the app and the DTS Admins and DTS Users to the resource group
                $GroupName = "DTS Users"
                $UserGroup = CreateAzGroup -GroupName $GroupName
              
                AddRoleAssignment `
                    -AzRoleName $RoleDefinition.Name `
                    -ResourceGroupName $TransferAppObj.ResourceGroupName `
                    -User $UserGroup `
                    -DeployObject $DeployInfo
                
                $GroupName = "DTS Admins"                
                $UserGroup = CreateAzGroup -GroupName $GroupName

                AddRoleAssignment `
                    -AzRoleName $RoleDefinition.Name `
                    -ResourceGroupName $TransferAppObj.ResourceGroupName `
                    -User $UserGroup `
                    -DeployObject $DeployInfo
                
                #Write-Host "InitiateDeploymentProcess[231]:APIAppRegName=" $TransferAppObj.APIAppRegName
                $User = Get-AzADServicePrincipal -DisplayName $TransferAppObj.APIAppRegName
                #Write-Host "InitiateDeploymentProcess[231]:User=" $User.Id               
                AddRoleAssignment `
                    -AzRoleName $RoleDefinition.Name `
                    -ResourceGroupName $TransferAppObj.ResourceGroupName `
                    -User $User `
                    -DeployObject $DeployInfo
                #>

            PrintDeployDuration -DeployObject $TransferAppObj            
        }
        "Pickup"
        {
            #Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[235] DeployInfo.DeployMode=" $DeployInfo.DeployMode
            #Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[120] DeployInfo.PickupAppObj.DeployMode=" $DeployInfo.PickupAppObj.DeployMode
            
            # Deploy DPP (Pickup)    
            $PickupAppObj.StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
            $PickupAppObj = ConfigurePickupAppObj    
            <#
            $Caller='InitiateDeploymentProcess[291] PickupAppObj'       
            PrintObject -object $PickupAppObj -Caller $Caller
            #>            
            
            $RoleDefinition = AddCustomRoleFromFile -DeployObject $PickupAppObj            
            RunDeployment -DeployObject $PickupAppObj -Solution $PickupAppObj.Solution            
            $DeploymentOutput = StartBicepDeploy -DeployObject $PickupAppObj -Solution $PickupAppObj.Solution
            #Write-Host "InitiateDeploymentProcess[298]  DeploymentOutput.Outputs:"
            #$DeploymentOutput
            <#$deploySuccessFlag = $true
            $deploySuccessFlag = $false
            If($deploySuccessFlag){
            #>
                CreateEnvironmentFiles `
                    -RootFolder $RootFolder `
                    -TemplateDir $TemplateDir `
                    -DeployObject $PickupAppObj `
                    -Cloud $DeployInfo.Cloud 
                    #-DeploymentOutput $DeploymentOutput
            #}
            <#
            $JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"
            $LocalSettingsFileName = "local.settings.json"
            $LocalSettingsFilePath = $RootFolder + "API\DPP\"
            BuildLocalSettingsFile `
                -JsonFilePath $JsonFilePath `
                -LocalSettingsFilePath $LocalSettingsFilePath `
                -LocalSettingsFileName $LocalSettingsFileName `
                -DeployObject $PickupAppObj `
                -DeploymentOutput $DeploymentOutput `
                -Cloud $DeployInfo.Cloud
            #>
                <#
                #add the app and the DTS Admins and DTS Users to the resource group
                $GroupName = "DTS Users"
                $UserGroup = CreateAzGroup -GroupName $GroupName
              
                AddRoleAssignment `
                    -AzRoleName $RoleDefinition.Name `
                    -ResourceGroupName $PickupAppObj.ResourceGroupName `
                    -User $UserGroup `
                    -DeployObject $DeployInfo
                
                $GroupName = "DTS Admins"
                $UserGroup = CreateAzGroup -GroupName $GroupName
             
                AddRoleAssignment `
                    -AzRoleName $RoleDefinition.Name `
                    -ResourceGroupName $PickupAppObj.ResourceGroupName `
                    -User $UserGroup `
                    -DeployObject $DeployInfo
                #Write-Host "InitiateDeploymentProcess[282] PickupAppObj.APIAppRegName=" $PickupAppObj.APIAppRegName
                $User = Get-AzADServicePrincipal -DisplayName $PickupAppObj.APIAppRegName
                               
                AddRoleAssignment `
                    -AzRoleName $RoleDefinition.Name `
                    -ResourceGroupName $PickupAppObj.ResourceGroupName `
                    -User $User `
                    -DeployObject $DeployInfo
                #>

                PrintDeployDuration -DeployObject $PickupAppObj
            #}
        }
        Default
        {
            Write-Host -ForegroundColor Red "DeployInfo.DeployMode="$DeployInfo.DeployMode
        }
    }#switch
   
    
    #if($debugFlag -eq $false){   

    #StartBicepDeploy -DeployObject $DeployInfo    
    #}
	
    <#
    $json = ConvertTo-Json $DeployInfo
    $json
    #>
    <#
    $Caller='InitiateDeploymentProcess[145]: AFTER StartBicepDeploy :: DeployInfo' 
    PrintDeployObject -object $DeployInfo
    #>
	#Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[148] DeployInfo.OutFileJSON=" $DeployInfo.OutFileJSON
    WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo
    
    #$RootFolder = "C:\GitHub\dtp\"
    #$TemplateDir = $RootFolder + "Deploy\LocalSetUp"
    

    $DeployInfo.EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    $DeployInfo.Duration = New-TimeSpan -Start $DeployInfo.StartTime -End $DeployInfo.EndTime
    #PrintDeployDuration -DeployObject $DeployInfo
    #PrintDeployDuration
    
}
Else
{
    Write-Host -ForegroundColor Red -BackgroundColor White "The successful deployment requires that you execute this script from the 'dtp\Deploy\powershell' folder."
    Write-Host -ForegroundColor Red -BackgroundColor White "Please change directory to the 'Deploy' folder and run this script again..."
    
} # if not on correct path

#}#DeploySolution








