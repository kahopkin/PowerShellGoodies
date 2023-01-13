#InitiateScripts

Function global:PrintWelcomeMessage
{
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.PrintWelcomeMessage[7]"
    }#>
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $global:StartTime = $today
    $global:todayShort = Get-Date -Format 'MM-dd-yyyy'

    Write-Host -ForegroundColor Green "================================================================================"
    Write-Host -ForegroundColor Green "[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!"
    Write-Host -ForegroundColor Green "================================================================================"
        
}#PrintWelcomeMessage

Function global:SetLogFolder
{
    Write-Debug "InitiateScripts.SetLogFolder[21]"
	
    $global:currDir = Get-Item (Get-Location)
    
    $currDirPath = ($currDir.FullName).ToLower()
    $global:correctPath = ("Deploy\powershell").ToLower()
    
    #this is where the repository code files are    
    $index = $currDirPath.IndexOf("deploy")    
    $global:RootFolder = $currDirPath.Substring(0,$index)
    
    #this is where the templates for the .env files are
    $global:DeployFolder = $RootFolder + "Deploy\"
    #$global:DeployFolder =  "..\Deploy\"
    
    $DeployPath = "deploy\logs"

    $global:TemplateDir = $DeployFolder + "LocalSetUp"
    #this is the full filepath for the subscription level custom role definition file
    
    $global:LogsFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    $global:LogsFolder = Get-ChildItem -Path  $LogsFolderParentPath | `
                        Where-Object { `
                            ($_.PSIsContainer -eq $true) -and `
                            ($_.FullName.Contains("deploy\logs") -or $_.FullName.Contains("Deploy\logs")) }
    
    If($debugFlag){
        Write-host -ForegroundColor Cyan "InitiateScripts.SetLogFolder[49]::"
        Write-host -ForegroundColor Green  "`$currDir=`"$currDir`""
        Write-host -ForegroundColor Green  "`$currDirPath=`"$currDirPath`""
        
        Write-Host -ForegroundColor Green "`$correctPath=`"$correctPath`""
               
        Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
        
        Write-host -ForegroundColor Green  "`$DeployFolder=`"$DeployFolder`""
        Write-host -ForegroundColor Green  "`$DeployPath=`"$DeployPath`""
        
        Write-host -ForegroundColor Green  "`$TemplateDir=`"$TemplateDir`""

        $LogsFolderFullName = $LogsFolder.FullName
        Write-Host -ForegroundColor Yellow "`$LogsFolder=`"$LogsFolderFullName`""
        Write-host -ForegroundColor Yellow "`$LogsFolderParentPath=`"$LogsFolderParentPath`""
        Write-Host -ForegroundColor Yellow "`$LogsFolderPath=`"$LogsFolderPath`""

        #Write-Host -ForegroundColor Cyan  "InitiateScripts.SetLogFolder[64] LogsFolder -eq null=" ($LogsFolder -eq $null)
    }#>    


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
        Write-Host -ForegroundColor Yellow "================================================================================"
        Write-Host -ForegroundColor Yellow "[$today] LOGS FOLDER:" $LogsFolderPath        
        Write-Host -ForegroundColor Yellow "================================================================================"
        #Write-Host -ForegroundColor Yellow "InitiateScripts.SetLogFolder[54] LogsFolderPath: $LogsFolderPath" 
    }
    
    <#If($debugFlag)
    {
        Write-host -ForegroundColor Cyan "InitiateScripts.SetLogFolder[57]::"
        Write-host -ForegroundColor Green  "`$currDir=`"$currDir`""
        Write-Host -ForegroundColor Green "`$correctPath=`"$correctPath`""
               
        Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
        
        Write-host -ForegroundColor Green  "`$DeployFolder=`"$DeployFolder`""
        Write-host -ForegroundColor Green  "`$DeployPath=`"$DeployPath`""
        
        Write-host -ForegroundColor Green  "`$TemplateDir=`"$TemplateDir`""

        $LogsFolderFullName = $LogsFolder.FullName
        Write-Host -ForegroundColor Yellow "`$LogsFolder=`"$LogsFolderFullName`""
        Write-host -ForegroundColor Yellow "`$LogsFolderParentPath=`"$LogsFolderParentPath`""
        Write-Host -ForegroundColor Yellow "`$LogsFolderPath=`"$LogsFolderPath`""

        #Write-Host -ForegroundColor Cyan  "InitiateScripts.SetLogFolder[64] LogsFolder -eq null=" ($LogsFolder -eq $null)
    }#>    
    
}#SetLogFolder

Function global:SetOutputFileNames
{
	
    Write-Debug "InitiateScripts.SetOutputFileNames[513]"
	<#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.SetOutputFileNames[504]"        
	    Write-Host -ForegroundColor Red "InitiateScripts.SetOutputFileNames[506] `$DeployInfo.TenantName=`""$DeployInfo.TenantName
	    Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[507] `$DeployInfo.AppName=`""$DeployInfo.AppName
	    Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[508] `$DeployInfo.Environment=`""$DeployInfo.Environment
	   
    }#>
    $todayShort = Get-Date -Format 'MM-dd-yyyy'    
    #$OutFileJSON = $RootFolder + "logs\$jsonFileName"

    #$global:fileNamePrefix = $DeployInfo.TenantName + "_" + $DeployInfo.AppName + "_"  + $DeployInfo.Environment + "_" + $todayShort 
    $global:fileNamePrefix = $DeployInfo.TenantName + "_" + $DeployInfo.AppName + "_"  + $DeployInfo.Environment
    #Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[709] `$fileNamePrefix=`"$fileNamePrefix`""    
    $global:JsonFileName = $fileNamePrefix  +  ".json"   
    $global:LogFileName = $fileNamePrefix + "_Log.txt"
	#Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[521] `$JsonFileName=`"$JsonFileName`""    
	#Write-Host -ForegroundColor Yellow "InitiateScripts.SetOutputFileNames[522] `$LogFileName=`"$LogFileName`""    
    #$DeployInfo.LogFile = $fileNamePrefix + "_Log.txt"
    
    <#
    $DeployInfo.LogFile = "$LogsFolderPath\$LogFileName"  
	$DeployInfo.OutFileJSON = "$LogsFolderPath\$JsonFileName"     	
	
    $global:OutFileJSON = "$LogsFolderPath\$JsonFileName"     
    $global:OutFile = "$LogsFolderPath\$LogFileName"
    #>
    
    $DeployInfo.LogFile = "..\logs\$LogFileName"  
	$DeployInfo.OutFileJSON = "..\Logs\$JsonFileName"     	
	
    $global:OutFileJSON = "..\Logs\$JsonFileName"     
    $global:OutFile = "..\Logs\$LogFileName"

    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "`nInitiateScripts.SetOutputFileNames[120]"

        Write-Host -ForegroundColor Yellow "`$fileNamePrefix=`"$fileNamePrefix`""
        Write-Host -ForegroundColor Yellow "`$LogsFolderPath=`"$LogsFolderPath`""
        
        Write-Host -ForegroundColor Yellow "`$JsonFileName=`"$JsonFileName`""
        Write-Host -ForegroundColor Yellow "`$LogFileName=`"$LogFileName`""
        
        $OutFileJSON = $DeployInfo.OutFileJSON
        Write-Host -ForegroundColor Cyan "`$DeployInfo.OutFileJSON=`"$OutFileJSON`""
        $LogFile = $DeployInfo.LogFile
	    Write-Host -ForegroundColor Yellow "`$DeployInfo.LogFile=`"$LogFile`""
    }#>
	
	
}#SetOutputFileNames

Function global:InitializeDeployInfoObject
{
    Write-Debug "InitiateScripts.InitializeDeployInfoObject[93]"
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.InitializeDeployInfoObject[94]"
    }#>
    $StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $global:TransferAppObj = [ordered]@{
        DeploymentName = "DeploymentName";
        AppName = "AppName";
        Environment = "Environment";
        Location = "Location";
        Solution = "Transfer";        
        ResourceGroupName = "ResourceGroupName";
        RoleDefinitionId = "RoleDefinitionId";        
		#RoleDefinitionFile =  $DeployFolder + "DTPStorageBlobDataReadWrite.json"
        RoleDefinitionFile =   "..\DTPStorageBlobDataReadWrite.json"
		#BicepFile =  $DeployFolder + "transfer-main.bicep";        
        BicepFile =  "..\transfer-main.bicep";
        SqlAdmin = "SqlAdmin";
        SqlAdminPwd = "SqlAdminPwd";

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
        StartTime = $StartTime;
        EndTime = "EndTime";
		Duration = "Duration";

        REACT_APP_DTS_AZ_STORAGE_URL = "REACT_APP_DTS_AZ_STORAGE_URL";
    }#TransferAppObj

    $global:PickupAppObj = [ordered]@{
        DeploymentName = "DeploymentName";
        AppName = "AppName";
        Environment = "Environment";
        Location = "Location";
        Solution = "Pickup";
        ResourceGroupName = "ResourceGroupName";
        RoleDefinitionId = "RoleDefinitionId";
        #RoleDefinitionFile =  $DeployFolder + "DPPStorageBlobDataRead.json"
        RoleDefinitionFile =  "..\DPPStorageBlobDataRead.json"
		#BicepFile =  $DeployFolder + "pickup-main.bicep";
        BicepFile =  "..pickup-main.bicep";

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

        StartTime = $StartTime;
        EndTime = "EndTime";
		Duration = "Duration";        
    }#PickupAppObj

	$global:DeployInfo = [ordered]@{
        DeploymentName = "DeploymentName";		
        CloudEnvironment = "CloudEnvironment";
        Location = "Location";		        
        Environment = "Environment";		
        AppName = "AppName";
        Solution = "All";
        #BicepFile = $DeployFolder + "main.bicep";
        #TemplateParameterFile = $DeployFolder + "TemplateParameterFile";
        BicepFile = "..\main.bicep";
        TemplateParameterFile = "..\TemplateParameterFile";
        OutFileJSON = "OutFileJSON";
        LogFile = "LogFile";
        
        SubscriptionName = "SubscriptionName";
        SubscriptionId = "SubscriptionId";
        TenantName = "TenantName";
        TenantId = "TenantId";		    

        CurrUserName = "CurrUserName";
        CurrUserId = "CurrUserId";
        CurrUserPrincipalName = "CurrUserPrincipalName";        
        MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
        StepCount = 1;

        CryptoEncryptRoleId = "CryptoEncryptRoleId";
        ContributorRoleId ="ContributorRoleId";
        DeployMode = "DeployMode";
        
        StartTime = $StartTime;
        EndTime = "EndTime";
		Duration = "Duration";
        
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
    Write-Debug "InitiateScripts.CreateDeployInfo[209]"
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.CreateDeployInfo[209]"
    }#>
	#if the json file exists: populate the deployInfo object's properties
        
    <#If($debugFlag)
    {
        $string = "`$DeployInfo.OutFileJSON=`"" + $DeployInfo.OutFileJSON + "`""
        Write-Host -ForegroundColor Red "`nSTART InitiateScripts.CreateDeployInfo[119] File:"$string
        Write-Host "InitiateScripts.CreateDeployInfo[129] jsonFileName.FullPath: " $FullPath
    }#>
    

    if (Test-Path ($DeployInfo.OutFileJSON)) 
    {
        $FullPath = (Get-ChildItem -Path ($DeployInfo.OutFileJSON) | select FullName).FullName
        <#If($debugFlag)
        {
            Write-Host "InitiateScripts.CreateDeployInfo[127] File:" $DeployInfo.OutFileJSON "Exists"
        }
        #>
                
        #$json = Get-Content $DeployInfo.OutFileJSON | Out-String | ConvertFrom-Json
        $json = Get-Content $FullPath | Out-String | ConvertFrom-Json
        #Write-Host "InitiateScripts.CreateDeployInfo[18] json.Tenant:" $json.Tenant
        $StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
        
        $TransferAppObj.DeploymentName = $json.TransferAppObj.DeploymentName;
        <#
        $TransferAppObj.AppName = $json.TransferAppObj.AppName;
        $TransferAppObj.Environment = $json.TransferAppObj.Environment;            
        $TransferAppObj.Location = $json.TransferAppObj.Location;
        $TransferAppObj.Solution = $json.TransferAppObj.Solution;
        $TransferAppObj.ResourceGroupName = $json.TransferAppObj.ResourceGroupName;
        $TransferAppObj.RoleDefinitionId = $json.TransferAppObj.RoleDefinitionId;
        
        $TransferAppObj.RoleDefinitionFile = $json.TransferAppObj.RoleDefinitionFile;            
        $TransferAppObj.BicepFile = $json.TransferAppObj.BicepFile;
        #>
        $TransferAppObj.SqlAdmin = $json.TransferAppObj.SqlAdmin;
        $TransferAppObj.SqlAdminPwd = $json.TransferAppObj.SqlAdminPwd;

        #$TransferAppObj.APIAppRegName = $json.TransferAppObj.APIAppRegName;
        $TransferAppObj.APIAppRegAppId = $json.TransferAppObj.APIAppRegAppId;
        $TransferAppObj.APIAppRegObjectId = $json.TransferAppObj.APIAppRegObjectId;
        $TransferAppObj.APIAppRegClientSecret = $json.TransferAppObj.APIAppRegClientSecret;
        $TransferAppObj.APIAppRegServicePrincipalId = $json.TransferAppObj.APIAppRegServicePrincipalId;            
        $TransferAppObj.APIAppRegExists = $json.TransferAppObj.APIAppRegExists;

        #$TransferAppObj.ClientAppRegName = $json.TransferAppObj.ClientAppRegName;
        $TransferAppObj.ClientAppRegAppId = $json.TransferAppObj.ClientAppRegAppId;
        $TransferAppObj.ClientAppRegObjectId = $json.TransferAppObj.ClientAppRegObjectId;
        $TransferAppObj.ClientAppRegServicePrincipalId = $json.TransferAppObj.ClientAppRegServicePrincipalId;            
        $TransferAppObj.ClientAppRegExists = $json.TransferAppObj.ClientAppRegExists;

        $PickupAppObj.DeploymentName = $json.PickupAppObj.DeploymentName;
        <# 
        $PickupAppObj.AppName = $json.PickupAppObj.AppName;
        $PickupAppObj.Environment = $json.PickupAppObj.Environment;            
        $PickupAppObj.Location = $json.PickupAppObj.Location;
        $PickupAppObj.Solution = $json.PickupAppObj.Solution;
        $PickupAppObj.ResourceGroupName = $json.PickupAppObj.ResourceGroupName;
        $PickupAppObj.RoleDefinitionId = $json.PickupAppObj.RoleDefinitionId;        
        $PickupAppObj.RoleDefinitionFile = $json.PickupAppObj.RoleDefinitionFile;
        $PickupAppObj.BicepFile = $json.PickupAppObj.BicepFile;            
        #>    
        #$PickupAppObj.APIAppRegName = $json.PickupAppObj.APIAppRegName;
        $PickupAppObj.APIAppRegAppId = $json.PickupAppObj.APIAppRegAppId;
        $PickupAppObj.APIAppRegObjectId = $json.PickupAppObj.APIAppRegObjectId;
        $PickupAppObj.APIAppRegClientSecret = $json.PickupAppObj.APIAppRegClientSecret;
        $PickupAppObj.APIAppRegServicePrincipalId = $json.PickupAppObj.APIAppRegServicePrincipalId;            
        $PickupAppObj.APIAppRegExists = $json.PickupAppObj.APIAppRegExists;
                       
        #$PickupAppObj.ClientAppRegName = $json.PickupAppObj.ClientAppRegName;
        $PickupAppObj.ClientAppRegAppId = $json.PickupAppObj.ClientAppRegAppId;
        $PickupAppObj.ClientAppRegObjectId = $json.PickupAppObj.ClientAppRegObjectId;
        $PickupAppObj.ClientAppRegServicePrincipalId = $json.PickupAppObj.ClientAppRegServicePrincipalId;            
        $PickupAppObj.ClientAppRegExists = $json.PickupAppObj.ClientAppRegExists;
        #StartTime = $json.PickupAppObj.StartTime;
        #EndTime = $json.PickupAppObj.EndTime;
       
        $DeployInfo.DeploymentName = $json.DeploymentName;			
        $DeployInfo.CloudEnvironment = $json.CloudEnvironment;
        $DeployInfo.Location = $json.Location;
        $DeployInfo.Environment = $json.Environment;
        $DeployInfo.AppName = $json.AppName;
        $DeployInfo.Solution = $json.Solution;
          
		<#
        $DeployInfo.BicepFile = $json.BicepFile;
        $DeployInfo.TemplateParameterFile = $json.TemplateParameterFile;
        $DeployInfo.OutFileJSON =  $json.OutFileJSON;
        $DeployInfo.LogFile = $json.LogFile;
        #>              
        $DeployInfo.SubscriptionName = $json.SubscriptionName;
        $DeployInfo.SubscriptionId = $json.SubscriptionId;
        $DeployInfo.TenantName = $json.TenantName;
        $DeployInfo.TenantId = $json.TenantId;            
            
        <#$DeployInfo.CurrUserName = $json.CurrUserName;
        $DeployInfo.CurrUserId = $json.CurrUserId;
        $DeployInfo.CurrUserPrincipalName = $json.CurrUserPrincipalName;     
        #>       
        $DeployInfo.MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
        $DeployInfo.StepCount = 1;
        
        $DeployInfo.CryptoEncryptRoleId = $json.CryptoEncryptRoleId;
        #DeployMode = $json.DeployMode;
          
        $DeployInfo.Cloud = $json.Cloud;

        $DeployInfo.StepCount = 1;
        $DeployInfo.TransferAppObj = $TransferAppObj;
        $DeployInfo.PickupAppObj = $PickupAppObj;        
        <#
		$Caller='InitiateDeploymentProcess[232]: DeployInfo AFTER Get-Content from json ::' 
		PrintDeployObject -object $DeployInfo
        #>
        WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo 
    }   

}#CreateDeployInfo

Function global:ConfigureDeployInfo
{
    Param(
          [Parameter(Mandatory = $false)] [String] $Environment
        , [Parameter(Mandatory = $false)] [String] $Location        
        , [Parameter(Mandatory = $false)] [String] $AppName         
        , [Parameter(Mandatory = $false)] [String] $DeployMode
    )
    Write-Debug "InitiateScripts.ConfigureDeployInfo[474]"
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureDeployInfo[407]"
        #Write-Host -ForegroundColor Red "START InitiateScripts.ConfigureDeployInfo[409]"   
        Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigureDeployInfo[411] Environment: " $Environment
        Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigureDeployInfo[411] AppName: " $AppName
        #Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigureDeployInfo[412] TenantId: " $DeployInfo.TenantId
        Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigureDeployInfo[413] DeployMode: " $DeployMode
    }#>
    
    If($DeployInfo.TenantId -ne $null)
    {
        #Location = PickAzRegion
        If($Location.Length -eq 0)
        { 
            $DeployInfo.Location = PickAzRegion 
        }
        Else
        {
            $DeployInfo.Location = $Location
        }
        #Write-Host -ForegroundColor Green "InitiateScripts.ConfigureDeployInfo[425] Location: " $DeployInfo.Location
        If($DeployInfo.Location.Length -ne 0)
        {                
            If($Environment.Length -eq 0)
            { 
                $DeployInfo.Environment = PickCodeEnvironment 
            }
            Else
            {
                $DeployInfo.Environment = $Environment 
            }
            $DeployInfo.Environment = (Get-Culture).TextInfo.ToTitleCase($DeployInfo.Environment)
            #Write-Host -ForegroundColor white "InitiateScripts.ConfigureDeployInfo[431] DeployInfo.Environment: "+ $DeployInfo.Environment                
                
            If($AppName.Length -eq 0)
            { 
                $DeployInfo.AppName = Read-Host "Enter AppName"
            }
            Else
            {
                $DeployInfo.AppName = $AppName
            }
            $DeployInfo.AppName = (Get-Culture).TextInfo.ToTitleCase($DeployInfo.AppName)
                
            
               
            #"`nApp Name:" + $DeployInfo.AppName >> $DeployInfo.LogFile
                
            If($DeployMode.Length -eq 0)
            { 
                $DeployInfo.DeployMode = PickDeployMode 
            }
            Else
            {
                $DeployInfo.DeployMode = $DeployMode 
            }
            $DeployInfo.Solution = $DeployInfo.DeployMode
            #Write-Host -ForegroundColor Yellow "InitiateScripts.ConfigureDeployInfo[290] DeployInfo.SqlAdminPwdPlainText:" $DeployInfo.SqlAdminPwdPlainText
                
            
            #"`nApp Solution:" + $DeployInfo.Solution  >> $DeployInfo.LogFile      
            
        }#If($DeployInfo.Location -ne $null)   
    }#If($DeployInfo.TenantId -ne $null)                 
    
    SetOutputFileNames
    
    $global:CurrUser = Get-AzADUser -SignedIn
    $DeployInfo.CurrUserName = $CurrUser.DisplayName
    $DeployInfo.CurrUserPrincipalName = $CurrUser.UserPrincipalName
    $DeployInfo.CurrUserId = $CurrUser.Id       
    $DeployInfo.ContributorRoleId = (Get-AzRoleDefinition -Name Contributor | Select Id).Id    
    <#
    If($DeployInfo.DeploymentName -eq "DeploymentName")
    {
        $DeployInfo.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $DeployInfo.TransferAppObj.Solution + "-" + $DeployInfo.PickupAppObj.Solution  + "-" +  $DeployInfo.Environment + "-" + $todayShort    
    }
    Else
    {
        If($debugFlag)
        {
            Write-Host "InitiateScripts.ConfigureDeployInfo[600] DeployInfo.DeploymentName=" $DeployInfo.DeploymentName
        }
    }
    #>

    CreateDeployInfo

    $DeployInfo.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $DeployInfo.TransferAppObj.Solution + "-" + $DeployInfo.PickupAppObj.Solution  + "-" +  $DeployInfo.Environment + "-" + $todayShort    
    

    If($DeployInfo.Environment -eq "Test" -or $DeployInfo.Environment -eq "Dev") 
    {
        #$TemplateParameterFile = "$LogsFolderParentPath\main.parameters.dev.json"
        #$DeployInfo.TemplateParameterFile = $LogsFolderParentPath + "\main.parameters.dev.json"
        $DeployInfo.TemplateParameterFile = "..\main.parameters.dev.json"
    }
    Else 
    {
        #$TemplateParameterFile = "$LogsFolderParentPath\main.parameters.prod.json"
        #$DeployInfo.TemplateParameterFile = $LogsFolderParentPath + "\main.parameters.prod.json"
        $DeployInfo.TemplateParameterFile = "..\main.parameters.prod.json"
    }

    #SetOutputFileNames
    #$json = ConvertTo-Json $DeployInfo
    #$json
    #PrintLogInfo -DeployObject $DeployInfo
	<#
	$Caller = 'InitiateScripts.ConfigureDeployInfo[500] :DeployInfo'
    Write-Host -ForegroundColor Yellow $Caller	
	PrintDeployObject -object $DeployInfo
    #>
    #WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureDeployInfo[537]"                
        Write-Host -ForegroundColor Cyan "Environment= " $DeployInfo.Environment
        Write-Host -ForegroundColor Cyan "Location= " $DeployInfo.Location
        Write-Host -ForegroundColor Cyan "AppName= " $DeployInfo.AppName
        Write-Host -ForegroundColor Cyan "DeployMode= " $DeployInfo.DeployMode
        Write-Host -ForegroundColor Cyan "DeploymentName= " $DeployInfo.DeploymentName
        Write-Host -ForegroundColor Green "TemplateParameterFile= " $DeployInfo.TemplateParameterFile 
    }#>
    
    

}#ConfigureDeployInfo

Function global:ConfigureTransferAppObj
{
    Param(       
          [Parameter(Mandatory = $false)] [String] $SqlAdmin
        , [Parameter(Mandatory = $false)] [String] $SqlAdminPwd
    )    
    Write-Debug "InitiateScripts.ConfigureTransferAppObj[562]"
        
    If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureTransferAppObj[566]"
        Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureTransferAppObj[567] SqlAdmin=" $SqlAdmin
        
    }#>
    
    $TransferAppObj.Solution = "Transfer"    
    $TransferAppObj.Environment = $DeployInfo.Environment
    
    If(($DeployInfo.Environment).ToLower() -eq 'prod')
    {
        If(($DeployInfo.AppName).ToLower() -eq 'dtp')
        {
            <#If($debugFlag)
            {
                Write-Host -ForegroundColor Yellow "InitiateScripts.ConfigureDeployInfo[433] App Name EQ dtp:" $DeployInfo.AppName
            }#>
            
            $TransferAppObj.AppName = ($DeployInfo.AppName)
        }
        else
        {
            <#If($debugFlag)
            {
                Write-Host -ForegroundColor Blue -BackgroundColor White "InitiateScripts.ConfigureDeployInfo[438] OTHER: App Name:" $DeployInfo.AppName
            }#>
            
            $TransferAppObj.AppName = ($DeployInfo.AppName + $TransferAppObj.Solution)
            
        }
        #$TransferAppObj.AppName = ($DeployInfo.AppName)
        #$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName)  + "-"  + (Get-Culture).TextInfo.ToLower($TransferAppObj.Environment) 
        <#If($debugFlag)
        {
            Write-Host -ForegroundColor Green "InitiateScripts.ConfigureDeployInfo[479] App Name EQ dtp:" $DeployInfo.AppName
            #Write-Host -ForegroundColor Yellow "InitiateScripts.ConfigureDeployInfo[476] App Name EQ dtp:" $DeployInfo.AppName
        }#>              
        
    }
    Else
    {
        #Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigureDeployInfo[484] App Name EQ dtp:" $DeployInfo.AppName
        $TransferAppObj.AppName = ($DeployInfo.AppName + $TransferAppObj.Solution + $TransferAppObj.Environment )
        #$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($TransferAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($TransferAppObj.Environment) 
    }
    <#
    If($TransferAppObj.DeploymentName -eq "DeploymentName")
    {
        $TransferAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $TransferAppObj.Solution + "-" + $TransferAppObj.Environment + "-" + $todayShort    
    }
    Else
    {
        $TransferAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $TransferAppObj.Solution + "-" + $TransferAppObj.Environment + "-" + $todayShort    
        Write-Host "InitiateScripts.ConfigureDeployInfo[635] TransferAppObj.DeploymentName = " $TransferAppObj.DeploymentName
    }#>
    #Write-Host -ForegroundColor Yellow "InitiateScripts.ConfigureTransferAppObj[488] App Name :" $TransferAppObj.AppName
    <#If($TransferAppObj.DeploymentName -eq "DeploymentName")
    {        
        $TransferAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $TransferAppObj.Solution + "-" + $TransferAppObj.Environment + "-" + $todayShort    
    }
    
    Else
    {
        If($debugFlag)
        {
            Write-Host "InitiateScripts.ConfigureTransferAppObj[703] TransferAppObj.DeploymentName=" $TransferAppObj.DeploymentName
        }
    }
    #>
    $TransferAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $TransferAppObj.Solution + "-" + $TransferAppObj.Environment + "-" + $todayShort    
    $TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($TransferAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($TransferAppObj.Environment)        

    $TransferAppObj.APIAppRegName = $TransferAppObj.AppName + 'API'    
    #$TransferAppObj.ClientAppRegName = $TransferAppObj.AppName + $TransferAppObj.Solution 
    $TransferAppObj.ClientAppRegName = $TransferAppObj.AppName
    		
    #$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($TransferAppObj.Environment) 
    #$TransferAppObj.ResourceGroupName = "rg-"+ $DeployInfo.AppName + "-" + $TransferAppObj.Solution + "-"  + $TransferAppObj.Environment
        
    #Write-Host "InitiateScripts.ConfigureTransferAppObj[497] TransferAppObj.ResourceGroupName=" $TransferAppObj.ResourceGroupName    
    
    #$DeployInfo.TransferAppObj = $TransferAppObj
    	    
    #$TransferAppObj.Environment = (Get-Culture).TextInfo.ToTitleCase($TransferAppObj.Environment)
	$TransferAppObj.Location = $DeployInfo.Location
    #Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigureDeployInfo[513] App Name:" $DeployInfo.AppName
    
    If($SqlAdmin.Length -eq 0)
    {  
        $SqlAdmin = Read-Host "Enter SQL Server Admin Login" #-AsSecureString }
    } 
    Else
    {
        $TransferAppObj.SqlAdmin = $SqlAdmin
    }
    #$DeployInfo.TransferAppObj.SqlAdmin = $DeployInfo.SqlAdmin
                
    #Write-Host "InitiateScripts[690] SqlAdminPwd.Length=" $SqlAdminPwd.Length
    If($SqlAdminPwd.Length -eq 0)
    { 

        $SqlAdminPwdSecure = Read-Host "Enter SQL Server Admin Password" -AsSecureString
        $SqlAdminPwdPlainText = ConvertFrom-SecureString-AsPlainText -SecureString $SqlAdminPwdSecure
        $TransferAppObj.SqlAdminPwd = $SqlAdminPwdPlainText       
    }
    Else
    {
        #Write-Host -ForegroundColor Red "InitiateScripts[702] SqlAdminPwd.Length=" $SqlAdminPwd.Length
        $DeployInfo.TransferAppObj.SqlAdminPwd = $SqlAdminPwd        
    }                
        
    If($debugFlag)
    {   
        Write-Host -ForegroundColor Magenta "================================================================================"
        Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureTransferAppObj[700]:"
        Write-Host -ForegroundColor Green "`$TransferAppObj.AppName=" $TransferAppObj.AppName 
        Write-Host -ForegroundColor Green "`$TransferAppObj.APIAppRegName=" $TransferAppObj.APIAppRegName
        Write-Host -ForegroundColor Green "`$TransferAppObj.APIAppRegName=" $TransferAppObj.APIAppRegAppId
        Write-Host -ForegroundColor Green "`$TransferAppObj.ClientAppRegName=" $TransferAppObj.ClientAppRegName
        Write-Host -ForegroundColor Green "`$TransferAppObj.ResourceGroupName=" $TransferAppObj.ResourceGroupName
        Write-Host -ForegroundColor Green "`$TransferAppObj.DeploymentName=" $TransferAppObj.DeploymentName

        Write-Host -ForegroundColor Magenta "================================================================================"        
    }#>
    return $TransferAppObj
}#ConfigureTransferAppObj

Function global:ConfigurePickupAppObj
{
    Write-Debug "InitiateScripts.ConfigurePickupAppObj[650]"
    
    If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigurePickupAppObj[698]"
        Write-Host -ForegroundColor Green "InitiateScripts.ConfigurePickupAppObj[699] DeployMode:" $DeployInfo.DeployMode
    }#>
    $PickupAppObj.Solution = "Pickup"
    
    $PickupAppObj.Environment = $DeployInfo.Environment
    #$PickupAppObj.Environment = (Get-Culture).TextInfo.ToTitleCase($PickupAppObj.Environment)
    
	$PickupAppObj.Location = $DeployInfo.Location
    
    #$PickupAppObj.AppName = $DeployInfo.AppName #+ $PickupAppObj.Solution
	#$PickupAppObj.AppName = ($DeployInfo.AppName + $PickupAppObj.Solution)
    #$PickupAppObj.AppName = ($DeployInfo.AppName + $PickupAppObj.Solution + $PickupAppObj.Environment )
    If(($DeployInfo.Environment).ToLower() -eq 'prod')
    {
        If(($DeployInfo.AppName).ToLower() -eq 'dpp')
        {
            #Write-Host -ForegroundColor Yellow "InitiateScripts.ConfigureDeployInfo[697] App Name EQ dpp:" $DeployInfo.AppName
            $PickupAppObj.AppName = ($DeployInfo.AppName)
        }
        else
        {
            #Write-Host -ForegroundColor Blue -BackgroundColor White "InitiateScripts.ConfigureDeployInfo[702] OTHER: App Name:" $DeployInfo.AppName
            $PickupAppObj.AppName = ($DeployInfo.AppName + $PickupAppObj.Solution)
        }

        #$PickupAppObj.AppName = ($DeployInfo.AppName)
        #$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName)  + "-"  + (Get-Culture).TextInfo.ToLower($PickupAppObj.Environment) 
        #Write-Host -ForegroundColor Green "InitiateScripts.ConfigurePickupAppObj[501] App Name EQ dtp:" $PickupAppObj.AppName
        #Write-Host -ForegroundColor Yellow "InitiateScripts.ConfigureDeployInfo[476] App Name EQ dtp:" $DeployInfo.AppName
    }
    <#Else
    {
        #Write-Host -ForegroundColor Cyan "InitiateScripts.ConfigurePickupAppObj[507] App Name EQ dtp:" $DeployInfo.AppName
        $PickupAppObj.AppName = ($DeployInfo.AppName + $PickupAppObj.Solution + $PickupAppObj.Environment )
        #$TransferAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($PickupAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($PickupAppObj.Environment) 
    }#>
    <#
    If($PickupAppObj.DeploymentName -eq "DeploymentName")
    {   
        $PickupAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $PickupAppObj.Solution + "-" + $PickupAppObj.Environment + "-" + $todayShort    
    }
    Else
    {
        If($debugFlag)
        {
            Write-Host "InitiateScripts.ConfigurePickupAppObj[810] PickupAppObj.DeploymentName=" $PickupAppObj.DeploymentName
        }
    }
    #>
    $PickupAppObj.DeploymentName = "Deployment-" + $DeployInfo.AppName + "-" + $PickupAppObj.Solution + "-" + $PickupAppObj.Environment + "-" + $todayShort    
    #$PickupAppObj.APIAppRegName = ($DeployInfo.AppName + $PickupAppObj.Solution + $PickupAppObj.Environment ) + 'API'
    $PickupAppObj.APIAppRegName = $PickupAppObj.AppName + 'API'
    #$PickupAppObj.ClientAppRegName = $PickupAppObj.AppName + $PickupAppObj.Solution 	
    $PickupAppObj.ClientAppRegName = $PickupAppObj.AppName
		
	$PickupAppObj.ResourceGroupName = "rg-"+ (Get-Culture).TextInfo.ToLower($DeployInfo.AppName) + "-" + (Get-Culture).TextInfo.ToLower($PickupAppObj.Solution) + "-"  + (Get-Culture).TextInfo.ToLower($PickupAppObj.Environment) 
    
    If($debugFlag)
    {   
        Write-Host -ForegroundColor Magenta "================================================================================"
        Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigurePickupAppObj[759]:"        
        Write-Host -ForegroundColor Green "`$PickupAppObj.DeploymentName=" $PickupAppObj.DeploymentName
        Write-Host -ForegroundColor Green "`$PickupAppObj.ResourceGroupName=" $PickupAppObj.ResourceGroupName
        Write-Host -ForegroundColor Green "`$PickupAppObj.AppName=" $PickupAppObj.AppName 
        Write-Host -ForegroundColor Green "`$PickupAppObj.APIAppRegName=" $PickupAppObj.APIAppRegName
        Write-Host -ForegroundColor Green "`$PickupAppObj.ClientAppRegName=" $PickupAppObj.ClientAppRegName
        Write-Host -ForegroundColor Green "`$PickupAppObj.ClientAppRegAppId=" $PickupAppObj.ClientAppRegAppId
        Write-Host -ForegroundColor Green "`$PickupAppObj.ClientAppRegObjectId=" $PickupAppObj.ClientAppRegObjectId                

        Write-Host -ForegroundColor Magenta "================================================================================"        
    }#>
    
    #Write-Host "InitiateScripts.ConfigurePickupAppObj[363] PickupAppObj.ResourceGroupName=" $PickupAppObj.ResourceGroupName    

    #$DeployInfo.PickupAppObj = $PickupAppObj
    <#
    $Caller='InitiateScripts.ConfigurePickupAppObj[561]:: PickupAppObj'       
    PrintObject -object $PickupAppObj -Caller $Caller
    #>
    return $PickupAppObj
}#ConfigurePickupAppObj


