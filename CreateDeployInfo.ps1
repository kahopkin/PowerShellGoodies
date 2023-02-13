
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
        
    If($debugFlag){
        $string = "`$DeployInfo.OutFileJSON=`"" + $DeployInfo.OutFileJSON + "`""
        Write-Host -ForegroundColor Red "`nSTART InitiateScripts.CreateDeployInfo[300] File:"$string
        #Write-Host "InitiateScripts.CreateDeployInfo[301] jsonFileName.FullPath: " $FullPath
    }#>
    
    if (Test-Path ($DeployInfo.OutFileJSON)) 
    {
        $FullPath = (Get-ChildItem -Path ($DeployInfo.OutFileJSON) | select FullName).FullName
        If($debugFlag){
            Write-Host -ForegroundColor Magenta "InitiateScripts.CreateDeployInfo[309] File Exists:" $DeployInfo.OutFileJSON 
        }#>
                
        #$json = Get-Content $DeployInfo.OutFileJSON | Out-String | ConvertFrom-Json
        $json = Get-Content $FullPath | Out-String | ConvertFrom-Json
        #Write-Host "InitiateScripts.CreateDeployInfo[18] json.Tenant:" $json.Tenant
        $StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
        
        <#$TransferAppObj.DeploymentName = $json.TransferAppObj.DeploymentName;        
        $TransferAppObj.SqlAdmin = $json.TransferAppObj.SqlAdmin;
        $TransferAppObj.SqlAdminPwd = $json.TransferAppObj.SqlAdminPwd;
        #>
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
       
        <#$DeployInfo.DeploymentName = $json.DeploymentName;			
        $DeployInfo.CloudEnvironment = $json.CloudEnvironment;
        $DeployInfo.Location = $json.Location;
        $DeployInfo.Environment = $json.Environment;
        $DeployInfo.AppName = $json.AppName;
        $DeployInfo.Solution = $json.Solution;
        #>
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