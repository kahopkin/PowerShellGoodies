#InitiateDeploymentProcess.ps1 debug inputs
If($debugFlag){
    Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[39] debugFlag: " $debugFlag
    #$DebugPreference = "Continue"
    #$DebugPreference = "Inquire"
    $DebugPreference = "SilentlyContinue"
    #Write-Host -ForegroundColor Cyan "UtilityFunctions.ConfigureDeployInfo[403] debugFlag: " $debugFlag
    $today = Get-Date -Format 'ddd'       
    $Environment = "test"
    #$Environment = "prod"
    #$Environment = "dev"
    $Environment = (Get-Culture).TextInfo.ToTitleCase($Environment)
    #Write-Host -ForegroundColor Cyan "InitiateDeploymentProcess[101] calling  Environment=:$Environment"
    $Location = "usgovvirginia"       
    $AppName = $today        
    $AppName = "dtp"
    #$AppName = "dpp"   
        
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
}#>

#If($debugFlag){exit(1)}