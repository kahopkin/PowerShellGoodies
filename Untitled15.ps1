Get-AzureADDeletedApplication -all 1 | ForEach-Object { Remove-AzureADdeletedApplication -ObjectId $_.ObjectId  }


Get-AzureADDeletedApplication -all 1 | ForEach-Object { Remove-AzureADdeletedApplication -ObjectId $_.ObjectId  }



$deletedSite = Get-AzDeletedWebApp -ResourceGroupName rg-scan-dev-lt-001 -Name func-scan-dev-lt-001

Restore-AzDeletedWebApp -ResourceGroupName rg-transferdata-prod `
    -Name func-scan-dev-lt-001 `
    -DeletedId /subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/providers/Microsoft.Web/deletedSites/128144 `
    -TargetAppServicePlanName restoreappplan


    


    -TargetAppServicePlanName asp-scanfuncapp-dev-lt-001


$ResourceGroupName = "rg-scan-dev-lt-001"
$appName = "func-scan-dev-lt-001"
$AppServicePlanName = "asp-scanfuncapp-dev-lt-001"

$ResourceGroupName = "rg-transferdata-prod"
$appName = "func-scan-dev-lt-001"
$AppServicePlanName = "ASP-rgtransferdataprod-bdad"
$targetServicePlan= "asp-dtplocal-dev" 
$targetServicePlan = "appi-scanfuncapp-dev-lt-001"
$deletedId ="/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/providers/Microsoft.Web/deletedSites/112689"

Restore-AzDeletedWebApp -ResourceGroupName $ResourceGroupName -Name $appName -deletedId $deletedId

Restore-AzDeletedWebApp -ResourceGroupName $ResourceGroupName -Name $appName -deletedId $deletedId -TargetAppServicePlanName $targetServicePlan
Restore-AzDeletedWebApp -ResourceGroupName rg-transferdata-prod -Name func-scan-dev-lt-001 -deletedId /subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/providers/Microsoft.Web/deletedSites/128144 -TargetAppServicePlanName ASP-rgtransferdataprod-bdad

Restore-AzDeletedWebApp -TargetResourceGroupName $ResourceGroupName -TargetName $appName -TargetAppServicePlanName $AppServicePlanName -InputObject $deletedSite[1]



Get-AzDeletedWebApp -Name $appName -Location "USGov Virginia"


$ResourceGroupName = "rg-transferdata-prod"
$appName = "func-scan-dev-lt-001"
$deletedId ="/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/providers/Microsoft.Web/deletedSites/128144"
$AppServicePlanName = "ASP-rgtransferdataprod-bdad"
Restore-AzDeletedWebApp -ResourceGroupName $ResourceGroupName -Name $appName -deletedId $deletedId

Restore-AzDeletedWebApp -ResourceGroupName rg-transferdata-prod -Name func-scan-dev-lt-001 -deletedId /subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/providers/Microsoft.Web/deletedSites/128144



#InitiateDeploymentProcess.ps1
<#
# Make sure that the user is in the right folder to run the script.
# Running the script is required to be in the dtp\deploy\powershell folder
#>
								
#Install-Module -name Microsoft.Graph.Applications
Import-Module -name Microsoft.Graph.Applications

& "$PSScriptRoot\ConnectToMSGraph.ps1"
& "$PSScriptRoot\BuildLocalSettingsFile"
#& "$PSScriptRoot\GetAzureADToken.ps1"
& "$PSScriptRoot\CreateEnvironmentFiles.ps1"
& "$PSScriptRoot\UtilityFunctions.ps1"
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

$global:debugFlag = $false
$global:debugFlag = $true    

SetLogFolder


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
    #Write-Host -ForegroundColor Blue "InitiateDeploymentProcess[99] calling ConnectToAzure debugFlag=:$debugFlag"
    PrintWelcomeMessage
    ConnectToAzure  	 
	#Write-Host -ForegroundColor Blue "InitiateDeploymentProcess[101] calling ConnectToAzure debugFlag=:$debugFlag"
       
    ConfigureDeployInfo
	
    SetOutputFileNames

    # DEPLOY DTP (Transfer)        
    ConfigureTransferAppObj
        
    <#
    $Caller='InitiateDeploymentProcess[204]: TransferAppObj'       
    PrintObject -object $TransferAppObj -Caller $Caller
    #>
        
    # Deploy DPP (Pickup)    
    ConfigurePickupAppObj

    <#
    $Caller='InitiateDeploymentProcess[226]: DeployInfo'       
    PrintObject -object $DeployInfo -Caller $Caller
    #>

    #$Caller='InitiateDeploymentProcess[235]: PickupAppObj'       
    #PrintObject -object $PickupAppObj -Caller $Caller
    #>
    
    AddCustomRoleFromFile -DeployObject $TransferAppObj
    AddCustomRoleFromFile -DeployObject $PickupAppObj
    
    RunDeployment -DeployObject $TransferAppObj
    RunDeployment -DeployObject $PickupAppObj
    
    $Caller='InitiateDeploymentProcess[273]: DeployInfo.TransferAppObj'       
    PrintObject -object $DeployInfo.TransferAppObj -Caller $Caller

    $Caller='InitiateDeploymentProcess[276]: DeployInfo.PickupAppObj'       
    PrintObject -object $DeployInfo.PickupAppObj -Caller $Caller

    #StartBicepDeploy -DeployObject $DeployInfo
    #if($debugFlag -eq $false){   

    StartBicepDeploy -DeployObject $DeployInfo    
    #}

    #WriteJsonFile -FilePath $OutFileJSON -CustomObject $DeployInfo   

    
}
Else{
    Write-Host -ForegroundColor Red -BackgroundColor White "The successful deployment requires that you execute this script from the 'dtp\Deploy\powershell' folder."
    Write-Host -ForegroundColor Red -BackgroundColor White "Please change directory to the 'Deploy' folder and run this script again..."
    
} # if not on correct path










if($debugFlag)    
        {  
            Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
            -Name" $DeployInfo.DeploymentName "```
            -Location" $DeployObject.Location "```
            -TemplateFile" $DeployObject.BicepFile "```
            -EnvironmentType" $DeployObject.Environment.toLower() "```            
            -CurrUserName" $DeployInfo.CurrUserName"```
            -CurrUserId" $DeployInfo.CurrUserId"```
            -RoleDefinitionIdTransfer" $DeployObject.RoleDefinitionIdTransfer "```
            -RoleDefinitionIdPickup" $DeployObject.RoleDefinitionIdPickup "```
            -CryptoEncryptRoleId $CryptoEncryptRoleId ```
            -TimeStamp $TimeStamp ```
            -AppName" $DeployObject.AppName.toLower() "```
            -Solution" $DeployObject.Solution "```
            -ApiClientId" $DeployObject.TransferAppObj.APIAppRegAppId "```
            -ApiClientSecret" $DeployObject.TransferAppObj.APIAppRegClientSecret"```
            -SqlServerAdministratorLogin" $DeployObject.SqlAdmin "```
            -SqlServerAdministratorPassword" $DeployObject.SqlAdminPwdPlain "```
            -TemplateParameterFile" $DeployInfo.TemplateParameterFile
                 
            try
            {   
                New-AzSubscriptionDeployment `
                    -Name $DeployInfo.DeploymentName `
                    -Location $DeployObject.Location.toLower() `
                    -TemplateFile $DeployObject.BicepFile `
                    -EnvironmentType $DeployObject.Environment.toLower() `
                    -CurrUserName $DeployInfo.CurrUserName `
                    -CurrUserId $DeployInfo.CurrUserId `
                    -Solution $DeployObject.Solution `
                    -RoleDefinitionIdTransfer $DeployObject.RoleDefinitionIdTransfer `
                    -RoleDefinitionIdPickup $DeployObject.RoleDefinitionIdPickup `
                    -CryptoEncryptRoleId $CryptoEncryptRoleId `
                    -TimeStamp $TimeStamp `
                    -AppName $DeployObject.AppName.toLower() `
                    -ApiClientId $SecureApiClientId `
                    -ApiClientSecret $SecureApiClientSecret `
                    -SqlServerAdministratorLogin $SecureSqlServerAdministratorLogin `
                    -SqlServerAdministratorPassword $SecureSqlServerAdministratorPassword `
                    -DeployObject $DeployObject `
                    -TemplateParameterFile $DeployInfo.TemplateParameterFile
            
            }
            catch
            {          
                Write-Output  "Ran into an issue: $($PSItem.ToString())"
            }            
        }







































#UtilityFunctions
<#
#
#>

Function global:InitializeDeployInfoObject
{
    $global:TransferAppObj = [ordered]@{
        AppName = "AppName";
        Environment = "Environment";
        Location = "Location";
        Solution = "Transfer";        
        ResourceGroupName = "ResourceGroupName";
        RoleDefinitionId = "RoleDefinitionId";        
		RoleDefinitionFile =  $DeployFolder + "DTPStorageBlobDataReadWrite.json"
		BicepFile =  $DeployFolder + "transfer-main.bicep";        

		APIAppRegName = "APIAppRegName";
		APIAppRegAppId = "APIAppRegAppId";
		APIAppRegObjectId = "APIAppRegObjectId";
		APIAppRegClientSecret = "APIAppRegClientSecret";
		APIAppRegServicePrincipalId = "APIAppRegServicePrincipalId";
		APIAppRegExists = $false;
		
		ClientAppRegName = "ClientAppRegName";
		ClientAppRegAppId = "ClientAppRegAppId";
		ClientAppRegObjectId = "ClientAppRegObjectId";
		ClientAppRegServicePrincipalId = "ClientAppRegServicePrincipalId";
		ClientAppRegExists = $false;
    }#TransferAppObj

    $global:PickupAppObj = [ordered]@{
        AppName = "AppName";
        Environment = "Environment";
        Location = "Location";
        Solution = "Pickup";
        ResourceGroupName = "ResourceGroupName";
        RoleDefinitionId = "RoleDefinitionId";
        RoleDefinitionFile =  $DeployFolder + "DPPStorageBlobDataRead.json"
		BicepFile =  $DeployFolder + "pickup-main.bicep";

		APIAppRegName = "APIAppRegName";
		APIAppRegAppId = "APIAppRegAppId";
		APIAppRegObjectId = "APIAppRegObjectId";
		APIAppRegClientSecret = "APIAppRegClientSecret";
		APIAppRegServicePrincipalId = "APIAppRegServicePrincipalId";
		APIAppRegExists = $false;
		
		ClientAppRegName = "ClientAppRegName";
		ClientAppRegAppId = "ClientAppRegAppId";
		ClientAppRegObjectId = "ClientAppRegObjectId";
		ClientAppRegServicePrincipalId = "ClientAppRegServicePrincipalId";
		ClientAppRegExists = $false;
    }#PickupAppObj

	$global:DeployInfo = [ordered]@{
		CloudEnvironment = "CloudEnvironment";
        Environment = "Environment";		
        Location = "Location";		
        Solution = "All";   
        AppName = "AppName";
        SqlAdmin = "SqlAdmin";
        SqlAdminPwd = "SqlAdminPwd";
        SqlAdminPwdPlainText = "SqlAdminPwdPlainText";
        BicepFile = $DeployFolder + "main.bicep";
        OutFileJSON = "OutFileJSON";
        LogFile = "LogFile";
        DeploymentName = "DeploymentName";
        FileExists = $false;

		SubscriptionName = "SubscriptionName";
        SubscriptionId = "SubscriptionId";
        TenantName = "TenantName";
        TenantId = "TenantId";
		
        CurrUserName = "CurrUserName";
        CurrUserId = "CurrUserId";
        CurrUserPrincipalName = "CurrUserPrincipalName";        
        MyIP = "MyIP";
		
        StepCount = 1;        
        TemplateParameterFile = "TemplateParameterFile";
		ContributorRoleId = "ContributorRoleId";
		TransferAppObj = $TransferAppObj;
        PickupAppObj = $PickupAppObj;
		Cloud = "Cloud";
	}#DeployInfo

} #InitializeDeployInfoObject

Function global:CreateDeployInfo
{
    <#
    Param(
      [Parameter(Mandatory = $true)] [String]$OutFileJSON 
    )
    #>
	#if the json file exists: populate the deployInfo object's properties
    
    Write-Host "UtilityFunctions.CreateDeployInfo[100] File: `$DeployInfo.OutFileJSON=" $DeployInfo.OutFileJSON

    if (Test-Path $DeployInfo.OutFileJSON) 
    {
        $FullPath = Get-ChildItem -Path $DeployInfo.OutFileJSON | select FullName
        #Write-Host "UtilityFunctions.CreateDeployInfo[14] jsonFileName.FullPath: " $FullPath.FullName
        #Write-Host "UtilityFunctions.CreateDeployInfo[15] File: $DeployInfo.OutFileJSON Exists"
                
        $json = Get-Content $DeployInfo.OutFileJSON | Out-String | ConvertFrom-Json
        #Write-Host "UtilityFunctions.CreateDeployInfo[18] json.Tenant:" $json.Tenant
    
        $global:TransferAppObj = [ordered]@{
            AppName = $json.TransferAppObj.AppName;
            Environment = $json.TransferAppObj.Environment;            
            Location = $json.TransferAppObj.Location;
            Solution = $json.TransferAppObj.Solution;
            ResourceGroupName = $json.TransferAppObj.ResourceGroupName;
            RoleDefinitionId = $json.TransferAppObj.RoleDefinitionId;
            RoleDefinitionFile = $json.TransferAppObj.RoleDefinitionFile;            
            BicepFile = $json.TransferAppObj.BicepFile;           
            
            APIAppRegName = $json.TransferAppObj.APIAppRegName;
            APIAppRegAppId = $json.TransferAppObj.APIAppRegAppId;
            APIAppRegObjectId = $json.TransferAppObj.APIAppRegObjectId;
            APIAppRegClientSecret = $json.TransferAppObj.APIAppRegClientSecret;
            APIAppRegServicePrincipalId = $json.TransferAppObj.APIAppRegServicePrincipalId;            
            APIAppRegExists = $json.TransferAppObj.APIAppRegExists;

            ClientAppRegName = $json.TransferAppObj.ClientAppRegName;
            ClientAppRegAppId = $json.TransferAppObj.ClientAppRegAppId;
            ClientAppRegObjectId = $json.TransferAppObj.ClientAppRegObjectId;
            ClientAppRegServicePrincipalId = $json.TransferAppObj.ClientAppRegServicePrincipalId;            
            ClientAppRegExists = $json.TransferAppObj.ClientAppRegExists;
        }#TransferAppObj

        $global:PickupAppObj = [ordered]@{
            AppName = $json.PickupAppObj.AppName;
            Environment = $json.PickupAppObj.Environment;            
            Location = $json.PickupAppObj.Location;
            Solution = $json.PickupAppObj.Solution;
            ResourceGroupName = $json.PickupAppObj.ResourceGroupName;
            RoleDefinitionId = $json.PickupAppObj.RoleDefinitionId;
            RoleDefinitionFile = $json.PickupAppObj.RoleDefinitionFile;
            BicepFile = $json.PickupAppObj.BicepFile;            
            
            APIAppRegName = $json.PickupAppObj.APIAppRegName;
            APIAppRegAppId = $json.PickupAppObj.APIAppRegAppId;
            APIAppRegObjectId = $json.PickupAppObj.APIAppRegObjectId;
            APIAppRegClientSecret = $json.PickupAppObj.APIAppRegClientSecret;
            APIAppRegServicePrincipalId = $json.PickupAppObj.APIAppRegServicePrincipalId;            
            APIAppRegExists = $json.PickupAppObj.APIAppRegExists;
                       
            ClientAppRegName = $json.PickupAppObj.ClientAppRegName;
            ClientAppRegAppId = $json.PickupAppObj.ClientAppRegAppId;
            ClientAppRegObjectId = $json.PickupAppObj.ClientAppRegObjectId;
            ClientAppRegServicePrincipalId = $json.PickupAppObj.ClientAppRegServicePrincipalId;            
            ClientAppRegExists = $json.PickupAppObj.ClientAppRegExists;
            
        }#PickupAppObj

        $global:DeployInfo = [ordered]@{
			CloudEnvironment = $json.CloudEnvironment;
            Location = $json.Location;
			Environment = $json.Environment;
            AppName = $json.AppName;
            SqlAdmin = $json.SqlAdmin;
            SqlAdminPwd = $json.SqlAdminPwd;
            SqlAdminPwdPlainText = $json.SqlAdminPwdPlainText;
            BicepFile = $json.BicepFile;
            OutFileJSON =  $json.OutFileJSON;
            LogFile = $json.LogFile;
            DeploymentName = $json.DeploymentName;
            FileExists = $true;
            
			SubscriptionName = $json.SubscriptionName;
            SubscriptionId = $json.SubscriptionId;
            TenantName = $json.TenantName;
            TenantId = $json.TenantId;
						
            CurrUserName = $json.CurrUserName;
            CurrUserId = $json.CurrUserId;
            CurrUserPrincipalName = $json.CurrUserPrincipalName;            
            MyIP = $json.MyIP;

            StepCount = 1;            
            TemplateParameterFile = $json.TemplateParameterFile;
			ContributorRoleId = $json.ContributorRoleId;
			TransferAppObj = $TransferAppObj;
            PickupAppObj = $PickupAppObj;
            Cloud = $json.Cloud;
        }#DeployInfo

        WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo 
        $json = ConvertTo-Json $DeployInfo
        $json > $DeployInfo.OutFileJSON	
    
    }
    
    # if (Test-Path $DeployInfo.OutFileJSON) 
    <#else
    {
        #Write-Host -ForegroundColor Yellow "!!UtilityFunctions.CreateDeployInfo[54] $jsonFileName Doesn't Exists, Creating object"
        
    }
    #>
    #WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo   
    <#
	$Caller='UtilityFunctions.CreateDeployInfo[106]'
    $EnvFilePath = "C:\GitHub\dtp\Deploy\deployInfo"
    if ((Test-Path $EnvFilePath) -eq $false)  
    {
        $EnvFile = New-Item -Path C:\GitHub\dtp\Deploy -Name deployInfo -ItemType File
        Write-Host "[111] Created new env file:" $EnvFilePath 
    } #env file does not exist
    else
    {
        Remove-Item -Path $EnvFilePath 

        $EnvFile = New-Item -Path C:\GitHub\dtp\Deploy -Name deployInfo -ItemType File
    }
    #>
    
    #$Caller='UtilityFunctions.CreateDeployInfo[248]'
    #Write-Host -ForegroundColor Yellow $Caller
    #$DeployInfo

    #PrintObject -object $DeployInfo -Caller $Caller
    #WriteJsonFile -FilePath C:\GitHub\dtp\Deploy\deployInfo.json -CustomObject $DeployInfo 
    
    #$Caller='UtilityFunctions.CreateDeployInfo[106]'
    #PrintHash -object $DeployInfo -Caller $Caller

    #>
    #return $DeployInfo

}#CreateDeployInfo

Function global:WriteJsonFile{
    Param(
        [Parameter(Mandatory = $true)] [String]$FilePath    
      , [Parameter(Mandatory = $true)] $CustomObject    
    )
    
    #$Caller='UtilityFunctions.WriteJsonFile[146]'
    #PrintObject -object $CustomObject -Caller $Caller
    #PrintHash -object $CustomObject -Caller $Caller

    $json = ConvertTo-Json $CustomObject
    $json > $FilePath
}#WriteJsonFile

Function global:ConfigureDeployInfo
{
   
    #$DeployInfo = CreateDeployInfo($DeployInfo.OutFileJSON)
    
    #>

    If($debugFlag)
    {
        #Write-Host -ForegroundColor Cyan "UtilityFunctions.ConfigureDeployInfo[403] debugFlag: " $debugFlag
        $today = Get-Date -Format 'ddd'   	   
        $DeployInfo.Environment = "test"
        $DeployInfo.Environment = "prod"
        #$DeployInfo.Environment = "dev"
        $DeployInfo.Location = "usgovvirginia"       
        $DeployInfo.AppName = $today
        #$DeployInfo.AppName = 'transferdata'
        $DeployInfo.SqlAdmin = "dtpadmin"   
        $DeployInfo.SqlAdminPwd = ConvertTo-SecureString "1qaz2wsx#EDC$RFV" -AsPlainText -Force                             
        $DeployInfo.SqlAdminPwdPlainText = ConvertFrom-SecureString-AsPlainText -SecureString $DeployInfo.SqlAdminPwd                
        Write-Host -ForegroundColor Green "`nApp Name:" $DeployInfo.AppName "`n"

        #$DeployInfo.AppName = 'kat'
        #$DeployInfo.AppName = "KatTuesday" + $DeployInfo.Solution
        #$DeployInfo.AppName = "testkat"        
    }
    Else
	{   
        #Write-Host -ForegroundColor Cyan "UtilityFunctions.ConfigureDeployInfo[420] debugFlag: " $debugFlag        
        #Write-Host -ForegroundColor Cyan "UtilityFunctions.ConfigureDeployInfo[421] TenantId: " $DeployInfo.TenantId
        If($DeployInfo.TenantId -ne $null)
        {
            #Location = PickAzRegion
            $DeployInfo.Location = PickAzRegion           
            #Write-Host -ForegroundColor Green "UtilityFunctions.ConfigureDeployInfo[425] Location: " $DeployInfo.Location
            If($DeployInfo.Location -ne $null)
            {
                #$Environment = PickCodeEnvironment
                $DeployInfo.Environment = PickCodeEnvironment
                #Write-Host -ForegroundColor white "UtilityFunctions.ConfigureDeployInfo[431] DeployInfo.Environment: "+ $DeployInfo.Environment                
                $DeployInfo.AppName = Read-Host "Enter AppName"
                Write-Host -ForegroundColor Green "`nApp Name:" $DeployInfo.AppName "`n"
                "`nApp Name:" + $DeployInfo.AppName >> $DeployInfo.LogFile

                $DeployInfo.SqlAdmin = Read-Host "Enter SQL Server Admin Login"                
                $DeployInfo.SqlAdminPwd = Read-Host "Enter SQL Server Admin Password" -AsSecureString                               
                $DeployInfo.SqlAdminPwdPlainText = ConvertFrom-SecureString-AsPlainText -SecureString $DeployInfo.SqlAdminPwd                
                Write-Host -ForegroundColor Yellow "UtilityFunctions.ConfigureDeployInfo[290] DeployInfo.SqlAdminPwdPlainText:" $DeployInfo.SqlAdminPwdPlainText
                
                #Pick_Solution
                #"`nApp Solution:" + $DeployInfo.Solution  >> $DeployInfo.LogFile      
               
            }   
        }             
    }#else (not debugflag)

    SetOutputFileNames

    CreateDeployInfo
    
    <#    
    $json = ConvertTo-Json $DeployInfo
    $json    
    #>
    $CurrUser = Get-AzADUser -SignedIn
    $DeployInfo.CurrUserName = $CurrUser.DisplayName
    $DeployInfo.CurrUserPrincipalName = $CurrUser.UserPrincipalName
    $DeployInfo.CurrUserId = $CurrUser.Id       
    $DeployInfo.ContributorRoleId = (Get-AzRoleDefinition -Name Contributor | Select Id).Id    
    $DeployInfo.DeploymentName = "Deployment_" + $todayShort    
    
    If($DeployInfo.Environment.ToLower() -eq "test" -or $DeployInfo.Environment.ToLower() -eq "dev") 
    {
        #$TemplateParameterFile = "$LogsFolderParentPath\main.parameters.dev.json"
        $DeployInfo.TemplateParameterFile = "$LogsFolderParentPath`\main.parameters.dev.json"
    }
    Else 
    {
        #$TemplateParameterFile = "$LogsFolderParentPath\main.parameters.prod.json"
        $DeployInfo.TemplateParameterFile = "$LogsFolderParentPath`\main.parameters.prod.json"
    }

    #$json = ConvertTo-Json $DeployInfo
    #$json
}#ConfigureDeployInfo

Function global:ConfigureTransferAppObj
{
    #$TansferAppObj.Solution = "Transfer"
    $TransferAppObj.Environment = $DeployInfo.Environment
	$TransferAppObj.Location = $DeployInfo.Location
    #$AppName = $DeployInfo.AppName + $TransferAppObj.Solution	
    #$TransferAppObj.AppName = $DeployInfo.AppName.toLower()
    $TransferAppObj.AppName = ($DeployInfo.AppName + $TransferAppObj.Solution ).toLower()
    $TransferAppObj.APIAppRegName = $TransferAppObj.AppName + 'API'    
    $TransferAppObj.ClientAppRegName = $TransferAppObj.AppName + $TransferAppObj.Solution 
    #$TransferAppObj.ClientAppRegName = $TransferAppObj.AppName
    	
	$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($TransferAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($TransferAppObj.Environment) 
    #$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($TransferAppObj.Environment) 
    #$TransferAppObj.ResourceGroupName = "rg-"+ $DeployInfo.AppName + "-" + $TransferAppObj.Solution + "-"  + $TransferAppObj.Environment
        
    #Write-Host "UtilityFunctions.ConfigureTransferAppObj[339] TransferAppObj.ResourceGroupName=" $TransferAppObj.ResourceGroupName    
    
    $DeployInfo.TransferAppObj = $TransferAppObj	

}#ConfigureTransferAppObj

Function global:ConfigurePickupAppObj
{
    #$PickupAppObj.Solution = "Pickup"
    $PickupAppObj.Environment = $DeployInfo.Environment
	$PickupAppObj.Location = $DeployInfo.Location
    #$PickupAppObj.AppName = $DeployInfo.AppName.toLower()
	$PickupAppObj.AppName = ($DeployInfo.AppName + $PickupAppObj.Solution).toLower()
    #$PickupAppObj.AppName = $DeployInfo.AppName + "-" + $PickupAppObj.Solution
    #PickupAppObj.APIAppRegName = $PickupAppObj.AppName + $PickupAppObj.Solution + 'API'
    $PickupAppObj.APIAppRegName = $PickupAppObj.AppName + 'API'
    #$PickupAppObj.ClientAppRegName = $PickupAppObj.AppName + $PickupAppObj.Solution 	
    $PickupAppObj.ClientAppRegName = $PickupAppObj.AppName
		
	#$PickupAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + $PickupAppObj.Solution + "-"  + (Get-Culture).TextInfo.ToLower($PickupAppObj.Environment) 
	$PickupAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($PickupAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($PickupAppObj.Environment) 
    #$PickupAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-"  + (Get-Culture).TextInfo.ToLower($PickupAppObj.Environment) 
    
    #Write-Host "UtilityFunctions.ConfigurePickupAppObj[363] PickupAppObj.ResourceGroupName=" $PickupAppObj.ResourceGroupName    

    $DeployInfo.PickupAppObj = $PickupAppObj

}#ConfigurePickupAppObj

Function global:SetLogFolder
{

    $global:currDir = Get-Item (Get-Location)
    #Write-host "UtilityFunctions.SetLogFolder[383] `$currDir=`"$currDir`""
    $currDirPath = $currDir.FullName
    $global:correctPath = ("Deploy\powershell").ToLower()
    #Write-host "UtilityFunctions.SetLogFolder[20] correctPath:" $correctPath
    #this is where the repository files are
    #$global:RootFolder = "C:\GitHub\dtp\"
    $index = $currDirPath.IndexOf("Deploy")
    $global:RootFolder = $currDirPath.Substring(0,$index)
    #Write-host "UtilityFunctions.SetLogFolder[390] `$RootFolder=`"$RootFolder`""
    #this is where the templates for the .env files are
    $global:DeployFolder = $RootFolder + "Deploy\"
    #Write-host "UtilityFunctions.SetLogFolder[393] `$DeployFolder=`"$DeployFolder`""

    $global:TemplateDir = $DeployFolder + "LocalSetUp"
    #this is the full filepath for the subscription level custom role definition file

    $DeployPath = "Deploy\logs"

    $LogsFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    $global:LogsFolder = Get-ChildItem -Path  $LogsFolderParentPath | `
                        Where-Object { `
                            ($_.PSIsContainer -eq $true) -and `
                            $_.FullName.Contains($DeployPath)}
    #Write-Host -ForegroundColor Green "[69]LogsFolder.Length=" $LogsFolder.FullName.Length
    #Write-Host -ForegroundColor Green  "[43]" ($LogsFolder -eq $null)
    
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    If($LogsFolder -eq $null)
    {
        $folderName ="logs"
        $LogsFolder = New-Item -Path $LogsFolderParentPath -Name $folderName -ItemType Directory
        $global:LogsFolderPath = (Get-ItemProperty  $LogsFolder | select FullName).FullName
        
        Write-Host -ForegroundColor Yellow "================================================================================"
        Write-Host -ForegroundColor Yellow "[$today] CREATED LOGS FOLDER:" $LogsFolderPath        
        Write-Host -ForegroundColor Yellow "================================================================================"        
    } 
    Else
    {
        $global:LogsFolderPath = $LogsFolder.FullName
        #Write-Host -ForegroundColor Yellow "`n"
        Write-Host -ForegroundColor Yellow "================================================================================"
        Write-Host -ForegroundColor Yellow "[$today] LOGS FOLDER:" $LogsFolderPath        
        Write-Host -ForegroundColor Yellow "================================================================================"
        #Write-Host -ForegroundColor Yellow "UtilityFunctions.SetLogFolder[54] LogsFolderPath: $LogsFolderPath" 
    }
       
}#SetLogFolder


Function global:PrintLogInfo
{
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "`t`t`t FILES CREATED AND USED (PARAMETER FILES, ETC):"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor White "JSON output file:"
    Write-Host -ForegroundColor Yellow $DeployInfo.OutFileJSON
    Write-Host -ForegroundColor White "Output Log file:"
    Write-Host -ForegroundColor Yellow $DeployInfo.LogFile
    Write-Host -ForegroundColor White "DPP Custom Role Definition file:"
    Write-Host -ForegroundColor Yellow $PickupAppObj.RoleDefinitionFile
    Write-Host -ForegroundColor White "DTP Custom Role Definition file:"
    Write-Host -ForegroundColor Yellow $TransferAppObj.RoleDefinitionFile
    Write-Host -ForegroundColor White "BICEP Parameter file:"
    Write-Host -ForegroundColor Yellow $DeployInfo.TemplateParameterFile
    Write-Host -ForegroundColor Yellow "================================================================================"
   <# 
    "================================================================================"						>> $DeployInfo.LogFile
    "`t`t`t FILES CREATED AND USED (PARAMETER FILES, ETC):"													>> $DeployInfo.LogFile
    "`nJSON output file:"																					>> $DeployInfo.LogFile
    $DeployInfo.OutFileJSON																							>> $DeployInfo.LogFile
    "`nLog file:"																							>> $DeployInfo.LogFile
    $DeployInfo.LogFile																						>> $DeployInfo.LogFile
    "`nCustom Role Definition files:"																		>> $DeployInfo.LogFile
    $TransferAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    $PickupAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    "`nBICEP Parameter file:"																				>> $DeployInfo.LogFile
    $DeployInfo.TemplateParameterFile																		>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
    #>
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    Write-Host -ForegroundColor Green "`n================================================================================"
	Write-Host -ForegroundColor Green "[$today] STARTING DEPLOYMENT ..."
	Write-Host -ForegroundColor Green "================================================================================`n"    
    <#
	"================================================================================" 	>> $DeployInfo.LogFile
    "[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!" 							>> $DeployInfo.LogFile
    "================================================================================" 	>> $DeployInfo.LogFile
	#>
}#PrintLogInfo

Function global:PrintWelcomeMessage
{
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $global:StartTime = $today
    $global:todayShort = Get-Date -Format 'MM-dd-yyyy'

    Write-Host -ForegroundColor Green "================================================================================"
    Write-Host -ForegroundColor Green "[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!"
    Write-Host -ForegroundColor Green "================================================================================"
        
}#PrintWelcomeMessage


Function global:PrintDeployDuration
{
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $global:EndTime = $today
    $Duration = New-TimeSpan -Start $StartTime -End $EndTime
    
    Write-Host -ForegroundColor Cyan "================================================================================" 
	Write-Host -ForegroundColor Cyan "[$today] COMPLETED DEPLOYMENT "
    Write-Host -ForegroundColor Cyan "DEPLOYMENT DURATION [HH:MM:SS]:" $Duration
	Write-Host -ForegroundColor Cyan "================================================================================"  
    
    if($debugFlag)
    {
        $OutFileJSONFullPath = ((Get-ChildItem -Path $DeployInfo.OutFileJSON).Directory | select FullName).FullName
        $Destination = "C:\GitHub\_App Registration Logs\"+ $jsonFileName
        #Write-Host -ForegroundColor Yellow "RunDeployment[163] Copy json `$OutFileJSONFullPath=`"$OutFileJSONFullPath`""
        #Write-Host -ForegroundColor Yellow "RunDeployment[164] `$Destination=`"$Destination`""    
        Copy-Item $DeployInfo.OutFileJSON $Destination		
		
        <#$Destination = "$LogsFolderPath\$JsonFileName"
        Write-Host -ForegroundColor Yellow "RunDeployment[167] `$Destination=`"$Destination`""    
        Copy-Item $DeployInfo.OutFileJSON $Destination
        #>
        $Destination = "C:\GitHub\_App Registration Logs\"+ $LogFileName
        #Write-Host -ForegroundColor Yellow "RunDeployment[171] `$Destination=`"$Destination`""
        Copy-Item $DeployInfo.LogFile $Destination
    }
    #>
	<#
    "================================================================================"	>> $DeployInfo.LogFile
    "[$today] COMPLETED DEPLOYMENT "													>> $DeployInfo.LogFile
    "DEPLOYMENT DURATION [HH:MM:SS]:" + $Duration										>> $DeployInfo.LogFile
    "================================================================================" 	>> $DeployInfo.LogFile 
	#>
}#PrintDeployDuration



Function global:SetOutputFileNames
{
	$todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$jsonFileName = "DeploymentOutput-" + $todayShort + ".json"
    #$OutFileJSON = $RootFolder + "logs\$jsonFileName"
	
    #$global:fileNamePrefix = $DeployInfo.TenantName + "_" + $DeployInfo.AppName + "_"  + $DeployInfo.Environment + "_" + $todayShort 
    $global:fileNamePrefix = $DeployInfo.TenantName + "_" + $DeployInfo.AppName + "_"  + $DeployInfo.Environment
    
    $global:JsonFileName = $fileNamePrefix  +  ".json"   
    $global:LogFileName = $fileNamePrefix + "_Log.txt"
	#Write-Host -ForegroundColor Yellow "UtilityFunctions.SetOutputFileNames[521] `$JsonFileName=`"$JsonFileName`""    
	#Write-Host -ForegroundColor Yellow "UtilityFunctions.SetOutputFileNames[522] `$LogFileName=`"$LogFileName`""    
    #$DeployInfo.LogFile = $fileNamePrefix + "_Log.txt"
    $DeployInfo.LogFile = "$LogsFolderPath\$LogFileName"  
	$DeployInfo.OutFileJSON = "$LogsFolderPath\$JsonFileName"     	
	$global:OutFileJSON = "$LogsFolderPath\$JsonFileName"     
    $global:OutFile = "$LogsFolderPath\$LogFileName"
	#Write-Host -ForegroundColor Yellow "UtilityFunctions.SetOutputFileNames[525] `$DeployInfo.OutFileJSON=`"" $DeployInfo.OutFileJSON `"""
	#Write-Host -ForegroundColor Yellow "UtilityFunctions.SetOutputFileNames[526] `$DeployInfo.LogFile=`"" $DeployInfo.LogFile`"""    
	
}#SetOutputFileNames

Function global:PickAZCloud
{    
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickAZCloud"	
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"            
	<#"================================================================================"	>> $DeployInfo.LogFile
	"[$today] CONNECT TO AZURE CLOUD..." 												>> $DeployInfo.LogFile
	"================================================================================"  >> $DeployInfo.LogFile
	#>
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "[$today] CONNECT TO AZURE CLOUD..."
    Write-Host -ForegroundColor Cyan "================================================================================"    
    Write-Host -ForegroundColor White "Choose the Azure Cloud to log in:"

    $CloudArr= [System.Collections.ArrayList]::new()
    $CloudArr = Get-AzEnvironment 

    $CloudStringArr = [System.Collections.ArrayList]::new()    
    $i=1           
    foreach($item in $CloudArr)
    {           
        #Write-Host -ForegroundColor Cyan "item.Name=" $item.Name
        $item = $item.Name -csplit '(?<!^)(?=[A-Z])' -join ' '
        #Write-Host "`$item=`"$item`""
        $item = $item.Replace("U S","US")
        Write-Host -ForegroundColor Yellow "[ $i ] : $item"        
        #$item['ProperName', $item]
        [void]$CloudStringArr.Add($i)
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ C ] : Provide Custom Environment String"
    [void]$CloudStringArr.Add("C")
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
    [void]$CloudStringArr.Add("X")

    $AzCloud = Get_AZCloud -CloudArr $CloudArr -CloudStringArr $CloudStringArr
    Write-Host -ForegroundColor Green "`nYour Selection:`"$AzCloud`" Cloud`n"
    #"`nSelected Cloud:" + $AzCloud  + " Cloud" >> $DeployInfo.LogFile

     return $AzCloud
}


Function global:Get_AZCloud
{
    Param(
        [Parameter(Mandatory = $true)] [object[]] $CloudArr
        ,[Parameter(Mandatory = $true)] [string[]] $CloudStringArr
      )
   
    $cloudIndex = Read-Host "Enter Az Cloud Selection"
    $cloudIndex = $cloudIndex.ToUpper()

    If( ($cloudIndex -lt $CloudStringArr.Count) -or ($cloudIndex -eq "X") -or ($cloudIndex -eq "C") )
    {
        Switch ($cloudIndex)
	    {       
            X 
            {
                Write-Host -ForegroundColor Red "You chose to Quit... Try again later ...." 
                exit(1)
            }
            C
            {
                $cloud = Read-Host "Enter Custom Azure Cloud Environment String"
            }        
		    Default 
            {            
                $cloud = $CloudArr[$cloudIndex-1]    
                #Write-Host -ForegroundColor Cyan "Get_AZCloud[91] Cloud=" $cloud
    
            }
	    }
    }
    Else
    {
        Write-Host -ForegroundColor Red "INPUT NOT VALID, TRY AGAIN..." 
        $cloud = Get_AZCloud
    }

     #Write-Host -ForegroundColor Cyan "Get_AZCloud[100] Cloud=" $cloud
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_AZCloud `$cloud=`"$cloud`" `n"
	return $cloud
}


Function global:PickSubscription
{    
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickSubscription"
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tCHOOSE SUBSCRIPTION TO LOG IN..."
    Write-Host -ForegroundColor Cyan "================================================================================" 	
    Write-Host -ForegroundColor White "Press the letter in the bracket to choose Subscription"
    Write-Host -ForegroundColor Yellow "[ Y ] : Proceed with current subscription:" $AzureContext.Subscription.Name
    Write-Host -ForegroundColor Yellow "[ C ] : Change subscription"
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
    
    $choice = Read-Host "Enter Selection"
    #Write-Host -ForegroundColor Cyan 'UtilityFunctions.PickSubscription[610] Subscription choice:' $choice
    Switch($choice){
        Y{
            
            #get current logged in context
            $global:AzureContext = Get-AzContext
            $currContextTenantId = $AzureContext.Subscription.TenantId
            $DeployInfo.Environment = $AzureContext.Environment.Name
            $DeployInfo.REACT_APP_GRAPH_ENDPOINT = $AzureContext.Environment.ExtendedProperties.MicrosoftGraphEndpointResourceId + "v1.0/me"
                       
            #$currContextHomeTenantId = $AzureContext.Subscription.HomeTenantId
            #$currContextSubscriptionId = $Azureontext.Subscription.Id        
            #$currContextSubscriptionName = $AzureContext.Subscription.Name
            
            $DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
            $DeployInfo.SubscriptionName = $AzureContext.Subscription.Name

            $SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
            $DeployInfo.TenantName = $SubscriptionTenant.Name
            $DeployInfo.TenantId = $SubscriptionTenant.Id

            #Write-Host -ForegroundColor Yellow 'UtilityFunctions.PickSubscription[631] AzureContext:' $AzureContext.Subscription.Name
            #Write-Host -ForegroundColor Yellow 'UtilityFunctions.PickSubscription[632] AzureContext:' $AzureContext.Subscription.Name

            Write-Host -ForegroundColor Green "================================================================================"
            Write-Host -ForegroundColor Green "`t`t`t`t`t`t`tCURRENT CONTEXT:"
            Write-Host -ForegroundColor Green "================================================================================"
            Write-Host -ForegroundColor Cyan  "Tenant:" $DeployInfo.TenantName
            Write-Host -ForegroundColor Cyan  "TenantId:" $DeployInfo.TenantId
            Write-Host -ForegroundColor Cyan  "Subscription:" $DeployInfo.SubscriptionName
            Write-Host -ForegroundColor Cyan  "SubscriptionId:" $DeployInfo.SubscriptionId
            Write-Host -ForegroundColor Green "================================================================================"
           <#
		   "================================================================================"	>> $DeployInfo.LogFile
            "`t`t`t`t`t`t`tCURRENT CONTEXT:"													>> $DeployInfo.LogFile
            "================================================================================"	>> $DeployInfo.LogFile
            "Tenant:" + $DeployInfo.TenantName													>> $DeployInfo.LogFile
            "TenantId:" + $DeployInfo.TenantId													>> $DeployInfo.LogFile
			"Subscription:" + $DeployInfo.SubscriptionName										>> $DeployInfo.LogFile
			"SubscriptionId:" + $DeployInfo.SubscriptionId										>> $DeployInfo.LogFile
			"================================================================================"	>> $DeployInfo.LogFile
			#>
            Set-AzContext -Subscription $DeployInfo.SubscriptionId
            #Write-Host -ForegroundColor Green "Context is: " 
            Get-AzContext
        }
        C{
            #Write-Host -ForegroundColor Yellow 'choice:' $choice
            ConnectToSpecSubsc -Environment $AzCloud #-MgEnvironment $MgEnvironment    
            #ConnectToSpecSubsc -Environment $AzCloud -TenantId $SubscriptionTenant.Id -SubscriptionId $currContextSubscriptionId
        }
        X{
            "Quitting..." 
            exit(1)
            }
    }
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.PickSubscription`n"
    #return 
}#PickSubscription

Function global:ConnectToSpecSubsc{
    Param(
        [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$TenantId  
        , [Parameter(Mandatory = $true)] [String]$SubscriptionId      
        #, [Parameter(Mandatory = $false)] [String]$MgEnvironment        
    )    
   
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "[$today] Start ConnectToMSGraph.ConnectToSpecSubsc"
    #Write-Host -ForegroundColor Cyan "Environment: " $DeployInfo.Environment
    #Write-Host -ForegroundColor Cyan "TenantId: " $DeployInfo.TenantId
    #Write-Host -ForegroundColor Cyan "SubscriptionId: " $SubscriptionId
    #Write-Host -ForegroundColor Cyan "MgEnvironment: " $MgEnvironment

    $AzConnection = Connect-AzAccount -Tenant $DeployInfo.TenantId -Environment $DeployInfo.Environment -SubscriptionId $DeployInfo.SubscriptionId 
    $AzureContext = Get-AzContext
    #Write-Host -ForegroundColor Green "Context=" $AzureContext.Environment
    $DeployInfo.Environment = $AzureContext.Environment.Name
    $DeployInfo.ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority
    $DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
    $DeployInfo.SubscriptionName = $AzureContext.Subscription.Name
    $SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId        
    $DeployInfo.TenantName = $SubscriptionTenant.Name
    $DeployInfo.TenantId = $SubscriptionTenant.Id

    #Connect-MgGraph -Environment $DeployInfo.MgEnvironment -ErrorAction Stop

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green "[$today] CONNECTED to $AzureContext.Environment.Name `n"    
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: ConnectToMSGraph.ConnectToSpecSubsc`n"
}

Function global:PickAzRegion{
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickAzRegion"       
    #Get all az regions for the cloud chosen
    $GeographyGroupArr = Get-AzLocation `
                        | Select Location, DisplayName, GeographyGroup `
                        | Sort-Object -Property  Location 
    Switch($AzCloud)
    {
        #Commercial Cloud:
        AzureCloud
        {
            #$GeoGroup = Pick_GeoGroup -GeographyGroupArr $GeographyGroupArr
           #Select all the unique georgaphy groups:
            $UniqueGeoGroups = $( 
            foreach ($geoGroup in $GeographyGroupArr) 
            {
                $geoGroup.GeographyGroup
            }) | Sort-Object | Get-Unique

            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE GEOGRAPHY GROUP:"
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor White "Press the number in the bracket to choose GEOGRAPHY GROUP:"   
            
            $i=0            
            foreach($group in $UniqueGeoGroups)
            {                
                Write-Host -ForegroundColor Yellow "[ $i ] : $group "
                $i++
            }
            Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  

            $GeoGroup = Read-Host "Enter Selection"
            If($GeoGroup -match "x") {
                    "Quitting..." 
                    exit(1)
            }

            Write-Host -ForegroundColor Green "`nYour Selection: " $UniqueGeoGroups[$GeoGroup] "`n"
            #"`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] >> $DeployInfo.LogFile

            $LocationArr = $GeographyGroupArr `
                        | select Location, DisplayName, GeographyGroup `
                        | Where-Object -Property GeographyGroup -eq $UniqueGeoGroups[$GeoGroup] `
                        | Sort-Object -Property  GeographyGroup 

            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE REGION:"
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host "Press the number in the bracket to choose REGION:"

            $i=0 
            foreach ($location in $LocationArr)
            {
                Write-Host -ForegroundColor Yellow "[ $i ] :" $location.DisplayName 
                $i++
            }
            Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
            
            $LocationIndex =  Read-Host "Enter Selection"
            #Write-Host "UtilityFunctions.PickAzRegion[764] LocationArr.Length:" $LocationArr.Length
            #Write-Host "UtilityFunctions.PickAzRegion[765] LocationIndex:" $LocationIndex
            if($LocationIndex -le $LocationArr.Length)
                    {
                        $Location = $LocationArr[$LocationIndex].toLower()
                    }
            #Write-Host "UtilityFunctions.PickAzRegion[770] LocationIndex:"$LocationIndex
            #Write-Host "UtilityFunctions.PickAzRegion[771] Location:"$LocationArr[$LocationIndex].Location
            Switch($locationIndex)
            {
                X {
                    "Quitting..." 
                    exit(1)
                }
			    Default 
                {
                    $Location = $LocationArr[$LocationIndex].toLower()
                }
            }          
            <#
            $i=0
            foreach ($location in $GeographyGroupArr)
            {
                Write-Host -ForegroundColor Yellow "GeographyGroupArr[$i] :" $location.Location 
                $i++
            }
            #>
             Write-Host -ForegroundColor Green "`nYour Selection:" $LocationArr[$LocationIndex].DisplayName "Region`n"
            #"`nYour Selection:" + $LocationArr[$LocationIndex].DisplayName + "Region" >> $DeployInfo.LogFile
        }
        AzureUSGovernment
        {
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE REGION:"
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host "Press the number in the bracket to choose REGION:"
            $i=0
            foreach ($location in $GeographyGroupArr)
            {
                Write-Host -ForegroundColor Yellow "[ $i ] :" $location.DisplayName 
                $i++
            }
            Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
            
            $Location = Get_Region
            Write-Host -ForegroundColor Green "`nYour Selection:" ($Location.DisplayName).ToUpper() "Region`n"
            #"`nSelected Region:" + $Location.DisplayName + "Region" >> $DeployInfo.LogFile
        }
    }#switch 
    
    <#
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "UtilityFunctions.PickAzRegion[815] [$today] FINISHED: UtilityFunctions.PickAzRegion`n"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "UtilityFunctions.PickAzRegion[816] Location.DisplayName="$Location.DisplayName
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "UtilityFunctions.PickAzRegion[817] DeployInfo.Location="$DeployInfo.Location
	#>
   return $Location.Location
}#PickAzRegion

Function global:Pick_GeoGroup 
{
    Param(
          [Parameter(Mandatory = $true)] [object]$GeographyGroupArr
    )
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Pick_GeoGroup"
              
    #Select all the unique georgaphy groups:
    $UniqueGeoGroups = $( 
            foreach ($geoGroup in $GeographyGroupArr) 
            {
                $geoGroup.GeographyGroup
            }) | Sort-Object | Get-Unique

    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE GEOGRAPHY GROUP:"
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the number in the bracket to choose GEOGRAPHY GROUP:"   
    
    $i=0  
    #list options in UniqueGeoGroups:          
    foreach($group in $UniqueGeoGroups)
    {                
        Write-Host -ForegroundColor Yellow "[ $i ] : $group "
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"

    $LocationArr = Get_GeoGroup -GeographyGroupArr $GeographyGroupArr -UniqueGeoGroups $UniqueGeoGroups
    <#
    $i=0
    foreach ($location in $GeographyGroupArr)
    {
        Write-Host -ForegroundColor Yellow "GeographyGroupArr[$i] :" $location.Location 
        $i++
    }
    #>
    #Pick_Location -LocationArr $LocationArr
    $Location = Get_Region -LocationArr $LocationArr
    #Write-Host "UtilityFunctions.Pick_GeoGroup[863] Location:" $Location

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Pick_GeoGroup`n"
    return $LocationIndex
}#Pick_GeoGroup

Function global:Get_GeoGroup
{
    Param(
          [Parameter(Mandatory = $true)] [object]$GeographyGroupArr,
          [Parameter(Mandatory = $true)] [object]$UniqueGeoGroups 
    )

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_GeoGroup"
    
    $GeoGroup = Read-Host "Enter Selection for GEOGRAPHY GROUP"
    #Write-Host "UtilityFunctions.Get_GeoGroup[881] you selected: " $GeographyGroupArr[$GeoGroup].DisplayName
    Switch ($GeoGroup)
	{       
        X { "Quitting..." 
            exit(1)
        }
        
		Default {
          $LocationArr = $GeographyGroupArr `
                        | select Location, DisplayName, GeographyGroup `
                        | Where-Object -Property GeographyGroup -eq $UniqueGeoGroups[$GeoGroup] `
                        | Sort-Object -Property  GeographyGroup 
                  
        }
	}    
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_GeoGroup`n"
    return $LocationArr
}#Get_GeoGroup

Function global:Pick_Location
{
    Param(
        [Parameter(Mandatory = $false)] [object]$LocationArr 
    )
    $i = 0 
    foreach ($location in $LocationArr)
    {
        Write-Host -ForegroundColor Yellow "[ $i ] :" $location.DisplayName 
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
    
    $LocationIndex =  Read-Host "Enter Selection"
    Switch($locationIndex){
        X {
            "Quitting..." 
            exit(1)
        }
		Default 
        {
            $Location = $LocationArr[$LocationIndex].Location          
        }
    }
            
    #Write-Host -ForegroundColor White "UtilityFunctions.PickAzRegion[926] Location:" $Location
}#Pick_Location

Function global:Get_Region 
{ 
    Param(
        [Parameter(Mandatory = $false)] [object]$LocationArr 
    )
    #>
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_Region"
	$LocationIndex = Read-Host "Enter Selection"
   
    If($LocationIndex -lt $GeographyGroupArr.Count -or $LocationIndex -eq "X")
    {
        Switch ($LocationIndex)
	    {       
            X 
            {
                "Quitting..." 
                exit(1)
            }        
		    Default 
            {            
                $region = $GeographyGroupArr[$LocationIndex]    
            }
	    }
    }
    Else
    {
        Write-Host -ForegroundColor Red "INPUT NOT VALID, TRY AGAIN..." 
        $region = Get_Region
    }

    
    <#    
    Write-Host "UtilityFunctions.Get_Region[962] LocationIndex:" $LocationIndex
    Write-Host "UtilityFunctions.Get_Region[963] region:" $region.DisplayName
    #Write-Host "UtilityFunctions.Get_Region[964] LocationIndex.Type:" $LocationIndex.GetType()
    #Write-Host "UtilityFunctions.Get_Region[320] GeographyGroupArr.Count:" $GeographyGroupArr.Count
    Write-Host "UtilityFunctions.Get_Region[966] GeographyGroupArr.Length:" $GeographyGroupArr.Length
    Write-Host "UtilityFunctions.Get_Region[967] GeographyGroupArr.Count:" $GeographyGroupArr.Count
    Write-Host "UtilityFunctions.Get_Region[968] LocationIndex:" $LocationIndex
 
    #Write-Host -ForegroundColor White -BackgroundColor Black  " UtilityFunctions.Get_Region[970] region: " $region
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_Region`n"
    #>
	return $region
}

Function global:PickCodeEnvironment
{
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickCodeEnvironment"
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT ENVIRONMENT:"
	Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the letter in the bracket to choose ENVIRONMENT:"   
    Write-Host -ForegroundColor Yellow "[ 0 ] : TEST" 
	Write-Host -ForegroundColor Yellow "[ 1 ] : DEV"
	Write-Host -ForegroundColor Yellow "[ 2 ] : PROD"
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
        
    #$Environment = Get_CodeEnvironment  
	$DeployInfo.Environment = Get_CodeEnvironment     
    Write-Host -ForegroundColor Green "`nYour Selection:" $DeployInfo.Environment "Environment`n"
    #"`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.PickCodeEnvironment`n"
    return $DeployInfo.Environment.ToLower()
}#PickCodeEnvironment

Function global:Get_CodeEnvironment
{
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_CodeEnvironment"

    $environment = Read-Host "Enter Selection for CODE ENVIRONMENT"    
	Switch ($environment)
	{
       
        0{$environment="Test"}
        1{$environment="Dev"}
        2{$environment="Prod"}
        X { "Quitting..." 
                exit(1)
        }
        Default {
            $environment = Get_CodeEnvironment
        }
    }
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "You Selected: " $environment
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_CodeEnvironment`n"
    return $environment
}#Get_CodeEnvironment

Function global:Pick_Solution
{
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT SOLUTION TYPE:"
	Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the letter in the bracket to choose ENVIRONMENT:"   
    Write-Host -ForegroundColor Yellow "[ 1 ] : Transfer" 
	Write-Host -ForegroundColor Yellow "[ 2 ] : Pickup"	
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
    $DeployInfo.Solution = Get_Solution

}#Pick_Solution

Function global:Get_Solution
{
    $Solution = Read-Host "Enter Transfer OR PickUp"
    Switch ($Solution)
	{
       
        1{$Solution="Transfer"}
        2{$Solution="Pickup"}                    
        X { "Quitting..." 
                exit(1)
        }
        Default {
            $Solution = Get_Solution
        }
    }#Switch
    return $Solution
}

Function global:PrintObject{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller
      , [Parameter(Mandatory = $false)] [string] $FilePath

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan "================================================================================`n"
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] START $Caller.PrintObject"
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    #foreach ($item in $object) 
    {         
        Write-Host -ForegroundColor White -BackgroundColor Black "[$i]" $item.name "=" $item.value
        #$item.name +"=" + $item.value >> $FilePath
        $i++       
    }

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
    Write-Host -ForegroundColor Cyan "================================================================================`n"
}#PrintObject

Function global:PrintDeployObject{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller      

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan "================================================================================`n"
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] START $Caller.PrintObject"
    
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    #foreach ($item in $object) 
    {         
        Write-Host -ForegroundColor White -BackgroundColor Black "[$i]" $item.name "=" $item.value
        #$item.name +"=" + $item.value >> $FilePath
        $i++       
    }

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
    Write-Host -ForegroundColor Cyan "================================================================================`n"
}#PrintDeployObject


Function global:PrintHash{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    foreach ($item in $object.GetEnumerator())    
    {         
        Write-Host -ForegroundColor Cyan $item.name "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHash

Function global:PrintHashKeyValue{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    foreach ($item in $object.GetEnumerator())    
    {   
        write-host -ForegroundColor Cyan $item.key "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHashKeyValue


Function global:PrintSubscription{
Param(
        [Parameter(Mandatory = $true)] [object] $object      

    )

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n[$today] START "
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    {         
        Write-Host -ForegroundColor White $item.name "=" $item.value        
        $i++       
    }
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
}#PrintSubscription



Function global:PrintCloudOptionsStrArr
{
    Param(
        [Parameter(Mandatory = $true)] [string[]] $ValueArr      
      )
    $i=0            
    foreach($item in $ValueArr)
    {   
        #$camelString = $item
        $item = $item -csplit '(?<!^)(?=[A-Z])' -join ' '
        Write-Host -ForegroundColor Yellow "[ $i ] : $item"
        $item['ProperName', $item]
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
    #return $ValueArr
}#PrintCloudOptionsStrArr


Function global:ConvertFrom-SecureString-AsPlainText{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.Security.SecureString]
        $SecureString
    )
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
    $PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
    $PlainTextString;
}

Function global:WriteLogFile{

    "================================================================================" 	>  $DeployInfo.LogFile
    "[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!" 							>> $DeployInfo.LogFile
    "================================================================================"	>> $DeployInfo.LogFile
    
    "================================================================================"						>> $DeployInfo.LogFile
    "`t`t`t FILES CREATED AND USED (PARAMETER FILES, ETC):"													>> $DeployInfo.LogFile
    "`nJSON output file:"																					>> $DeployInfo.LogFile
    $DeployInfo.OutFileJSON																							>> $DeployInfo.LogFile
    "`nLog file:"																							>> $DeployInfo.LogFile
    $DeployInfo.LogFile																								>> $DeployInfo.LogFile
    "`nCustom Role Definition files:"																		>> $DeployInfo.LogFile
    $TransferAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    $PickupAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    "`nBICEP Parameter file:"																				>> $DeployInfo.LogFile
    $DeployInfo.TemplateParameterFile																		>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile

    "================================================================================"	>> $DeployInfo.LogFile
	"[$today] CONNECTED TO AZURE CLOUD..." 												>> $DeployInfo.LogFile
	"================================================================================"  >> $DeployInfo.LogFile
    "Selected Cloud:" + $AzCloud  + " Cloud" >> $DeployInfo.LogFile

#"`nSelected Cloud:" + $AzCloud  + " Cloud" >> $DeployInfo.LogFile
    "`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] >> $DeployInfo.LogFile
    "`nYour Selection:" + $LocationArr[$LocationIndex].DisplayName + "Region" >> $DeployInfo.LogFile
    "`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
"`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] >> $DeployInfo.LogFile
#"`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
    "You are currently logged in context:"																	>> $DeployInfo.LogFile
    "Tenant Name:" + $DeployInfo.TenantName																	>> $DeployInfo.LogFile
    "Tenant Id:" + $DeployInfo.TenantId																		>> $DeployInfo.LogFile
    "Subscription:" + $DeployInfo.SubscriptionName															>> $DeployInfo.LogFile
    "Subscription Id:" + $DeployInfo.SubscriptionId															>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
	
	"================================================================================"	>> $DeployInfo.LogFile
	"`t`t`t`t`t`t`tCURRENT CONTEXT:"													>> $DeployInfo.LogFile
	"================================================================================"	>> $DeployInfo.LogFile
	"Tenant:" + $DeployInfo.TenantName													>> $DeployInfo.LogFile
	"TenantId:" + $DeployInfo.TenantId													>> $DeployInfo.LogFile
	"Subscription:" + $DeployInfo.SubscriptionName										>> $DeployInfo.LogFile
	"SubscriptionId:" + $DeployInfo.SubscriptionId										>> $DeployInfo.LogFile
	"================================================================================"	>> $DeployInfo.LogFile

	"`nSelected Region:" + $Location.DisplayName + "Region" >> $DeployInfo.LogFile    
    "`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    "`nApp Name:" + $DeployInfo.AppName >> $DeployInfo.LogFile
    "`Sql Admin Name:" + $DeployInfo.SqlAdmin >> $DeployInfo.LogFile
    "`Sql Admin PwdP lainText:" + $DeployInfo.SqlAdminPwdPlainText >> $DeployInfo.LogFile
    
	
	
	
	"================================================================================"	>> $DeployInfo.LogFile
    "[$today] COMPLETED DEPLOYMENT "													>> $DeployInfo.LogFile
    "DEPLOYMENT DURATION [HH:MM:SS]:" + $Duration										>> $DeployInfo.LogFile
    "================================================================================" 	>> $DeployInfo.LogFile 



    "================================================================================"	>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": ADD API PERMISSION: " + $PermissionParentName	>> $DeployInfo.LogFile
    "================================================================================"	>> $DeployInfo.LogFile
    
    "================================================================================"								>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": ADDING SUBSCRIPTION SCOPE CUSTOM ROLE DEFINITION:" + $RoleAssignmentName	>> $DeployInfo.LogFile
    "================================================================================"								>> $DeployInfo.LogFile
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    "================================================================================" 			>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": CREATE RESOURCE GROUP: $DeployObject.ResourceGroupName" >> $DeployInfo.LogFile
    "================================================================================`n"		>> $DeployInfo.LogFile
}#WriteLogFile


Function global:StartBicepDeployOld {
    Param(     
          [Parameter(Mandatory = $true)] [Object] $DeployObject
    )
   
    
    $Caller='StartBicepDeploy[12]'
    PrintDeployObject -object $DeployObject -Caller $Caller
    #PrintObject -object $DeployObject -Caller $Caller
    #>
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START StartBicepDeploy "
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "StartBicepDeploy[19] debugFlag="$debugFlag

    "================================================================================"						>> $DeployInfo.LogFile
    "[" + $today + "] STARTING AZURE RESOURCE DEPLOYMENT..."												>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
    "Deploying the following resources:"																	>> $DeployInfo.LogFile
    "*** App Service Plan "																					>> $DeployInfo.LogFile
    "*** App Service "																						>> $DeployInfo.LogFile
    "*** Function App "																						>> $DeployInfo.LogFile
    "*** Key Vault "																						>> $DeployInfo.LogFile
    "***     - Customer Managed Keys for the Storage Accounts "												>> $DeployInfo.LogFile
    "***     - Customer Managed Keys for the SQL Database "													>> $DeployInfo.LogFile
    "***     - Secrets: FunctionApp AppId and secret "														>> $DeployInfo.LogFile
    "*** Managed Identity "																					>> $DeployInfo.LogFile
    "*** Application Insights "																				>> $DeployInfo.LogFile
    "*** Log Analytics workspace "																			>> $DeployInfo.LogFile
    "*** Virtual Network and SubNets "																		>> $DeployInfo.LogFile
    "*** Network Security Group "																			>> $DeployInfo.LogFile
    "*** Private DNS zones "																				>> $DeployInfo.LogFile
    "*** Private Endpoints "																				>> $DeployInfo.LogFile
    "*** Network Interfaces "																				>> $DeployInfo.LogFile
    "*** Main and Audit Storage Accounts "																	>> $DeployInfo.LogFile
    "*** SQL Server "																						>> $DeployInfo.LogFile
    "*** SQL Database "																						>> $DeployInfo.LogFile
    
    if( -not $debugFlag){
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan " [$today] STARTING AZURE RESOURCE DEPLOYMENT..."
	Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Yellow "Deploying the following resources:"
    Write-Host -ForegroundColor Yellow "*** App Service Plan "
    Write-Host -ForegroundColor Yellow "*** App Service "
    Write-Host -ForegroundColor Yellow "*** Function App "
    Write-Host -ForegroundColor Yellow "*** Key Vault "
    Write-Host -ForegroundColor Yellow "***     - Customer Managed Keys for the Storage Accounts "
    Write-Host -ForegroundColor Yellow "***     - Customer Managed Keys for the SQL Database "
    Write-Host -ForegroundColor Yellow "***     - Secrets: FunctionApp AppId and secret "
    Write-Host -ForegroundColor Yellow "*** Managed Identity "
    Write-Host -ForegroundColor Yellow "*** Application Insights "
    Write-Host -ForegroundColor Yellow "*** Log Analytics workspace "
    Write-Host -ForegroundColor Yellow "*** Virtual Network and SubNets "
    Write-Host -ForegroundColor Yellow "*** Network Security Group "
    Write-Host -ForegroundColor Yellow "*** Private DNS zones "
    Write-Host -ForegroundColor Yellow "*** Private Endpoints "
    Write-Host -ForegroundColor Yellow "*** Network Interfaces "
    Write-Host -ForegroundColor Yellow "*** Main and Audit Storage Accounts "
    Write-Host -ForegroundColor Yellow "*** SQL Server "
    Write-Host -ForegroundColor Yellow "*** SQL Database "        
    }
        
    #Write-Host -ForegroundColor Red "StartBicepDeploy[67] DeployObject.Solution=" $DeployObject.Solution
    
    $APIAppRegAppId = $DeployObject.APIAppRegAppId
    #Write-Host -ForegroundColor Cyan "StartBicepDeploy[68] APIAppRegAppId:"  $APIAppRegAppId
       
    $ClientAppRegAppId = $DeployObject.ClientAppRegAppId
    #Write-Host -ForegroundColor Cyan "StartBicepDeploy[70] ClientAppRegAppId:"  $ClientAppRegAppId
    if($DeployObject.Solution -eq "All")
    {
        $ApiClientId = $DeployObject.TransferAppObj.APIAppRegAppId
        $SecureApiClientId = ConvertTo-SecureString $DeployObject.TransferAppObj.APIAppRegAppId -AsPlainText -Force
        #Write-Host -ForegroundColor Magenta "StartBicepDeploy[77] All:: DeployObject.TransferAppObj.APIAppRegAppId:"  $DeployObject.TransferAppObj.ClientAppRegAppId
        if ($DeployObject.TransferAppObj.APIAppRegClientSecret.Length -gt 0)
        {
            $out =  "`$DeployObject.TransferAppObj.APIAppRegClientSecret=`"" + $DeployObject.TransferAppObj.APIAppRegClientSecret + "`""
            #Write-Host -ForegroundColor Green "StartBicepDeploy[82] " $out
            $APIAppRegClientSecret = $DeployObject.TransferAppObj.APIAppRegClientSecret
            $SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force        
            #$SecureSqlServerAdministratorLogin = ConvertTo-SecureString $DeployObject.SqlAdmin -AsPlainText -Force
            #$SecureSqlServerAdministratorPassword = ConvertTo-SecureString $DeployObject.SqlAdminPwd -AsPlainText -Force

        }
        else
        {
            #create a client secret key which will expire in two years.
		    $appPassword = New-AzADAppCredential -ObjectId $DeployObject.TransferAppObj.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
		    $PlaintextSecretTest = $appPassword.SecretText
            $DeployObject.TransferAppObj.APIAppRegClientSecret = $PlaintextSecretTest        
            $SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
            #$SecureSqlServerAdministratorLogin = ConvertTo-SecureString $DeployObject.SqlAdmin -AsPlainText -Force
            #$SecureSqlServerAdministratorPassword = ConvertTo-SecureString $DeployObject.SqlAdminPwd -AsPlainText -Force
        }

        $SecureSqlServerAdministratorLogin = ConvertTo-SecureString $DeployObject.SqlAdmin -AsPlainText -Force
        $SecureSqlServerAdministratorPassword = ConvertTo-SecureString $DeployObject.SqlAdminPwd -AsPlainText -Force
    }#if($DeployObject.Solution -eq "All")

    elseif($DeployObject.Solution -eq "Transfer")
    {
        $ApiClientId = $DeployObject.APIAppRegAppId
        $SecureApiClientId = ConvertTo-SecureString $DeployObject.APIAppRegAppId -AsPlainText -Force
        Write-Host -ForegroundColor Yellow "StartBicepDeploy[100] Transfer:: DeployObject.APIAppRegAppId:"  $DeployObject.APIAppRegAppId

        if ($DeployObject.APIAppRegClientSecret.Length -gt 0)
        {
            $out =  "`$DeployObject.APIAppRegClientSecret=`"" + $DeployObject.APIAppRegClientSecret + "`""
            #Write-Host -ForegroundColor Green "StartBicepDeploy[82] " $out
            $APIAppRegClientSecret = $DeployObject.APIAppRegClientSecret
            $SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force            
        }
        else
        {
            #create a client secret key which will expire in two years.
		    $appPassword = New-AzADAppCredential -ObjectId $DeployObject.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
		    $PlaintextSecretTest = $appPassword.SecretText
            $DeployObject.APIAppRegClientSecret = $PlaintextSecretTest        
            $SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
        }
    }#elseif($DeployObject.Solution -eq "Transfer")

    elseif($DeployObject.Solution -eq "Pickup")
    {
        $ApiClientId = $DeployObject.ClientAppRegAppId
        $SecureApiClientId = ConvertTo-SecureString $DeployObject.ClientAppRegAppId -AsPlainText -Force
        Write-Host -ForegroundColor Magenta "StartBicepDeploy[83] Pickup:: DeployObject.ClientAppRegAppId:"  $DeployObject.ClientAppRegAppId
    }#elseif($DeployObject.Solution -eq "Pickup")

    else
    {
        Write-Host -ForegroundColor Red "StartBicepDeploy[92] NO CLUE:: DeployObject.Solution:"  $DeployObject.Solution
        exit(1)
    }

    $SecureApiClientId = ConvertTo-SecureString $ApiClientId -AsPlainText -Force
            

    $TimeStamp = (Get-Date).tostring(“MM/dd/yyyy HH:mm”)
    #$TimeStamp = (Get-Date).tostring(“HH:mm”)    
    #assign Key Vault Crypto Service Encryption User to the managed id that was created
    #retrieve the user-assigned managed identity and assign to it the required RBAC role, scoped to the key vault. 
    $RoleAssignmentName = "Key Vault Crypto Service Encryption User"
    $CustomRole = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.Name -eq $RoleAssignmentName}
    $CryptoEncryptRoleId = $CustomRole.Id
    $DeployInfo.CryptoEncryptRoleId = $CustomRole.Id
    #Write-Host -ForegroundColor Green "StartBicepDeploy[112] `$CustomRoleId=`"" $CustomRoleId "`""
    #Write-Host -ForegroundColor Green "StartBicepDeploy[112] CryptoEncryptRoleId=" $CryptoEncryptRoleId

    $debugFlag = $false

    if($DeployObject.Solution -eq "All")
    {
        Write-Host -ForegroundColor Yellow "StartBicepDeploy[149] `$Solution=`"" $DeployObject.Solution "`""        
        if($debugFlag)    
        {  
           Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
            -Name" $DeployObject.DeploymentName "```
            -AppName" $DeployObject.AppName.toLower() "```
            -Location" $DeployObject.Location "```
            -EnvironmentType" $DeployObject.Environment.toLower() "```
            -CurrUserName" $DeployInfo.CurrUserName"```
            -CurrUserId" $DeployInfo.CurrUserId"```  
            -TimeStamp $TimeStamp ```            
            -TemplateFile" $DeployObject.BicepFile "```
            -TemplateParameterFile" $DeployObject.TemplateParameterFile "```
            -DeployObject $DeployObject"
                 
            try
            {   
                New-AzSubscriptionDeployment `
                    -Name $DeployObject.DeploymentName.toLower() `
                    -AppName $DeployObject.AppName`
                    -Location $DeployObject.Location `
                    -EnvironmentType $DeployObject.Environment `
                    -CurrUserName $DeployObject.CurrUserName `
                    -CurrUserId $DeployObject.CurrUserId `
                    -TimeStamp $TimeStamp `
                    -TemplateFile $DeployObject.BicepFile `
                    -TemplateParameterFile $DeployObject.TemplateParameterFile `
                    -DeployObject $DeployObject `
            
            }
            catch
            {          
                Write-Output  "Ran into an issue: $($PSItem.ToString())"
            }            
        }
        else #not debug
        {
            #Write-Host -ForegroundColor White "`n BICEP Azure Deploy Command: "            
            Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
            -Name" $DeployObject.DeploymentName "```
            -AppName" $DeployObject.AppName.toLower() "```
            -Location" $DeployObject.Location "```
            -EnvironmentType" $DeployObject.Environment.toLower() "```
            -CurrUserName" $DeployInfo.CurrUserName"```
            -CurrUserId" $DeployInfo.CurrUserId"```  
            -TimeStamp $TimeStamp ```            
            -TemplateFile" $DeployObject.BicepFile "```
            -TemplateParameterFile" $DeployObject.TemplateParameterFile "```
            -DeployObject DeployObject"
                  
            try
            {
                New-AzSubscriptionDeployment `
                    -Name $DeployObject.DeploymentName.toLower() `
                    -AppName $DeployObject.AppName`
                    -Location $DeployObject.Location `
                    -EnvironmentType $DeployObject.Environment `
                    -CurrUserName $DeployObject.CurrUserName `
                    -CurrUserId $DeployObject.CurrUserId `
                    -TimeStamp $TimeStamp `
                    -TemplateFile $DeployObject.BicepFile `
                    -TemplateParameterFile $DeployObject.TemplateParameterFile `
                    -DeployObject $DeployObject `
                    
            }
            catch
            {          
                Write-Output  "Ran into an issue: $($PSItem.ToString())"
            }
        }#else if debugflag
    }#if($DeployObject.Solution -eq "All")
    elseif($DeployObject.Solution -eq "Transfer")
    {
       
        if($debugFlag)    
        {  
            Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
            -Name" $DeployInfo.DeploymentName "```
            -Solution" $DeployObject.Solution "```
            -Location" $DeployObject.Location "```
            -AppName" $DeployObject.AppName.toLower() "```
            -EnvironmentType" $DeployObject.Environment.toLower() "``` 
            
            
            -CurrUserName" $DeployInfo.CurrUserName"```
            -CurrUserId" $DeployInfo.CurrUserId"```
            -TimeStamp $TimeStamp ```
            -TemplateFile" $DeployObject.BicepFile "```            
            -TemplateParameterFile" $DeployInfo.TemplateParameterFile
                 
            try
            {   
                New-AzSubscriptionDeployment `
                    -Name $DeployInfo.DeploymentName `
                    -Solution $DeployObject.Solution `
                    -Location $DeployObject.Location.toLower() `
                    -AppName $DeployObject.AppName.toLower() `
                    -EnvironmentType $DeployObject.Environment.toLower() `
                    
                    

                    -TemplateFile $DeployObject.BicepFile `
                    
                    -ResourceGroupName $DeployObject.ResourceGroupName.toLower() `
                    -CurrUserName $DeployInfo.CurrUserName `
                    -CurrUserId $DeployInfo.CurrUserId `
                    
                    -RoleDefinitionId $DeployObject.RoleDefinitionId `
                    -CryptoEncryptRoleId $CryptoEncryptRoleId `
                    -TimeStamp $TimeStamp `
                    
                    -ApiClientId $SecureApiClientId `
                    -ApiClientSecret $SecureApiClientSecret `
                    -TemplateParameterFile $DeployInfo.TemplateParameterFile
            
            }
            catch
            {          
                Write-Output  "Ran into an issue: $($PSItem.ToString())"
            }           
        }
        else
        {
            #Write-Host -ForegroundColor White "`n BICEP Azure Deploy Command: "          
            Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
            -Name" $DeployInfo.DeploymentName "```
            -Location" $DeployObject.Location "```
            -TemplateFile" $DeployObject.BicepFile "```
            -EnvironmentType" $DeployObject.Environment.toLower() "```
            -ResourceGroupName "$DeployObject.ResourceGroupName "```
            -CurrUserName" $DeployInfo.CurrUserName"```
            -CurrUserId" $DeployInfo.CurrUserId"```
            -RoleDefinitionId" $DeployObject.RoleDefinitionId "```
            -CryptoEncryptRoleId $CryptoEncryptRoleId ```
            -TimeStamp $TimeStamp ```
            -AppName" $DeployObject.AppName.toLower() "```
            -Solution" $DeployObject.Solution "```
            -ApiClientId" $ApiClientId "```
            -ApiClientSecret" $DeployObject.APIAppRegClientSecret"```
            -TemplateParameterFile" $DeployInfo.TemplateParameterFile
                  
            try
            {
                New-AzSubscriptionDeployment `
                    -Name $DeployInfo.DeploymentName.toLower() `
                    -Location $DeployObject.Location `
                    -TemplateFile $DeployObject.BicepFile `
                    -EnvironmentType $DeployObject.Environment `
                    -ResourceGroupName $DeployObject.ResourceGroupName `
                    -CurrUserName $DeployInfo.CurrUserName `
                    -CurrUserId $DeployInfo.CurrUserId `
                    -Solution $DeployObject.Solution `
                    -RoleDefinitionId $DeployObject.RoleDefinitionId `
                    -CryptoEncryptRoleId $CryptoEncryptRoleId `
                    -TimeStamp $TimeStamp `
                    -AppName $DeployObject.AppName`
                    -ApiClientId $SecureApiClientId `
                    -ApiClientSecret $SecureApiClientSecret `
                    -TemplateParameterFile $DeployInfo.TemplateParameterFile
              
            }
            catch
            {          
                Write-Output  "Ran into an issue: $($PSItem.ToString())"
            }
        }#else if debugflag
    }#elseif($DeployObject.Solution -eq "Transfer")
    elseif($DeployObject.Solution -eq "Pickup")
    {
        $debugFlag = $false
        if($debugFlag)    
        {  
            Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
            -Name" $DeployInfo.DeploymentName "```
            -Location" $DeployObject.Location "```
            -TemplateFile" $DeployObject.BicepFile "```
            -EnvironmentType" $DeployObject.Environment.toLower() "```
            -ResourceGroupName "$DeployObject.ResourceGroupName "```
            -CurrUserName" $DeployInfo.CurrUserName"```
            -CurrUserId" $DeployInfo.CurrUserId"```
            -RoleDefinitionId" $DeployObject.RoleDefinitionId "```
            -CryptoEncryptRoleId $CryptoEncryptRoleId ```
            -TimeStamp $TimeStamp ```
            -AppName" $DeployObject.AppName.toLower() "```
            -Solution" $DeployObject.Solution "```
            -ApiClientId" $ApiClientId "```            
            -TemplateParameterFile" $DeployInfo.TemplateParameterFile
                 
            try
            {   
                New-AzSubscriptionDeployment `
                    -Name $DeployInfo.DeploymentName `
                    -Location $DeployObject.Location.toLower() `
                    -TemplateFile $DeployObject.BicepFile `
                    -EnvironmentType $DeployObject.Environment.toLower() `
                    -ResourceGroupName $DeployObject.ResourceGroupName.toLower() `
                    -CurrUserName $DeployInfo.CurrUserName `
                    -CurrUserId $DeployInfo.CurrUserId `
                    -Solution $DeployObject.Solution `
                    -RoleDefinitionId $DeployObject.RoleDefinitionId `
                    -CryptoEncryptRoleId $CryptoEncryptRoleId `
                    -TimeStamp $TimeStamp `
                    -AppName $DeployObject.AppName.toLower() `
                    -ApiClientId $SecureApiClientId `
                    -TemplateParameterFile $DeployInfo.TemplateParameterFile
            
            }
            catch
            {          
                Write-Output  "Ran into an issue: $($PSItem.ToString())"
            }            
        }
        else
        {
            Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
            -Name" $DeployInfo.DeploymentName "```
            -Location" $DeployObject.Location "```
            -TemplateFile" $DeployObject.BicepFile "```
            -EnvironmentType" $DeployObject.Environment.toLower() "```
            -ResourceGroupName "$DeployObject.ResourceGroupName "```
            -CurrUserName" $DeployInfo.CurrUserName"```
            -CurrUserId" $DeployInfo.CurrUserId"```
            -RoleDefinitionId" $DeployObject.RoleDefinitionId "```
            -CryptoEncryptRoleId $CryptoEncryptRoleId ```
            -TimeStamp $TimeStamp ```
            -AppName" $DeployObject.AppName.toLower() "```
            -Solution" $DeployObject.Solution "```
            -ApiClientId" $ApiClientId "```
            -TemplateParameterFile" $DeployInfo.TemplateParameterFile
                  
            try
            {
                New-AzSubscriptionDeployment `
                    -Name $DeployInfo.DeploymentName.toLower() `
                    -Location $DeployObject.Location `
                    -TemplateFile $DeployObject.BicepFile `
                    -EnvironmentType $DeployObject.Environment `
                    -ResourceGroupName $DeployObject.ResourceGroupName `
                    -CurrUserName $DeployInfo.CurrUserName `
                    -CurrUserId $DeployInfo.CurrUserId `
                    -Solution $DeployObject.Solution `
                    -RoleDefinitionId $DeployObject.RoleDefinitionId `
                    -CryptoEncryptRoleId $CryptoEncryptRoleId `
                    -TimeStamp $TimeStamp `
                    -AppName $DeployObject.AppName`
                    -ApiClientId $SecureApiClientId `
                    -TemplateParameterFile $DeployInfo.TemplateParameterFile   
            }
            catch
            {          
                Write-Output  "Ran into an issue: $($PSItem.ToString())"
            }
        }#else if debugflag

    }# elseif($DeployObject.Solution -eq "Pickup")
     
    $managedUserName = 'id-'+ $DeployObject.AppName + '-' + $DeployObject.Environment
    #Write-Host -ForegroundColor Green "StartBicepDeploy[185] `$managedUserName=`"$managedUserName`""
    <#
    $userIdentity = Get-AzUserAssignedIdentity -Name $managedUserName -ResourceGroupName $DeployObject.ResourceGroupName
    $principalId = $userIdentity.PrincipalId
    #Write-Host -ForegroundColor Green "StartBicepDeploy[188] `$principalId=`"$principalId`""
    
    $keyvaultName = 'kv-'+ $DeployObject.AppName + '-' + $DeployObject.Environment
    #Write-Host -ForegroundColor Green "StartBicepDeploy[192] `$keyvaultName=`"$keyvaultName`""

    $keyvault = Get-AzKeyVault -Name $keyvaultName 
    #>
    <#
    New-AzRoleAssignment -ObjectId $principalId `
        -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
        -Scope $keyVault.ResourceId

    ####>
                       
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan " [$today] FINISHED AZURE RESOURCE DEPLOYMENT..."
	Write-Host -ForegroundColor Cyan "================================================================================"    
    "================================================================================"						>> $DeployInfo.LogFile
    "[" + $today + "] FINISHED AZURE RESOURCE DEPLOYMENT..."												>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
}#end of StartBicepDeployOld

12/07/2022

$today = Get-Date -Format "MM/dd/yyyy"
#Get-AzResourceGroup -Tag @{'DeployDate'='12/07/2022'}
Get-AzResourceGroup -Tag @{'DeployDate'=$today}


$ResGroupName = "rg-dtp-prod"
$ResGroupName = "rg-dtp-prod"
#Get-AzResourceGroup | Where-Object {$_.ResourceGroupName.StartsWith("rg-dp") -or $_.ResourceGroupName.StartsWith("rg-dt") }

$myResourceGroups = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName.StartsWith("rg-dp") -or $_.ResourceGroupName.StartsWith("rg-dt") } | Select -Property ResourceGroupName

$myResourceGroups = Get-AzResourceGroup | Where-Object {$_.Tags.DeployDate -eq $today -and $_.Tags.DeployedBy -eq 'Kat Hopkins'}
$myResourceGroups[0].Tags.DeployDate
$myResourceGroups[0].Tags.DeployedBy


clear

Function global:PickDeployMode
{
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickCodeEnvironment"
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT DEPLOY MODE:"
	Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the letter in the bracket to choose ENVIRONMENT:"   
    Write-Host -ForegroundColor Yellow "[ 0 ] : ALL - Deploy both the Transfer and Pickup Solution in your tenant" 
	Write-Host -ForegroundColor Yellow "[ 1 ] : TRANSFER"
	Write-Host -ForegroundColor Yellow "[ 2 ] : PICKUP"
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
        
    #$Environment = Get_CodeEnvironment  
	$DeployInfo.DeployMode = Get_DeployMode     
    Write-Host -ForegroundColor Green "`nYour Selection:" $DeployInfo.DeployMode "DeployMode`n"
    #"`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.PickCodeEnvironment`n"
    return $DeployInfo.DeployMode
}#PickDeployMode

Function global:Get_DeployMode
{
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_CodeEnvironment"

    $deployMode = Read-Host "Enter Selection for CODE ENVIRONMENT"    
	Switch ($deployMode)
	{
       
        0{$deployMode="All"}
        1{$deployMode="Transfer"}
        2{$deployMode="Pickup"}
        X { "Quitting..." 
                exit(1)
        }
        Default {
            $deployMode = Get_DeployMode
        }
    }
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "You Selected: " $environment
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_DeployMode`n"
    return $deployMode
}#Get_DeployMode