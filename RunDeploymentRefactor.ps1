

#RunDeployment
<#
This script creates and configures two app registrations and
then it start a Bicep script that deploys the Data Transfer Portal application.
It writes an Output.txt file and saves it in the same directory where the deploy script is located.
The file contains the app registration data: ids, secret, tenantid, subscriptionid, etc.
This is a plain text file for the person who runs the deployment.
The resources the script creates are:
Resource Group
Function App
App Service
App Service Plan
Storage Account
Log Analytics Workspace
Application Insigths for the API
Application Insigths for the Web Client
#>

Function global:RunDeployment 
{
    Param(
          [Parameter(Mandatory = $false)] [String]$Environment
        , [Parameter(Mandatory = $false)] [String]$Location
        , [Parameter(Mandatory = $false)] [String]$AppName
        )
    
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    Write-Host -ForegroundColor Green "`n================================================================================"
	Write-Host -ForegroundColor Green "[$today] STARTING DEPLOYMENT ..."
	Write-Host -ForegroundColor Green "================================================================================`n"    
    "================================================================================" 	>> $OutFile
    "[$today] WELCOME TO THE DATA TRANSFER SOLUTION DEPLOYMENT!!" 							>> $OutFile
    "================================================================================" 	>> $OutFile

    $DeployInfo.DeploymentName = "Deployment_" + $todayShort
    
    DeployTransferApp `
        -Environment $DeployInfo.Environment `
        -Location $DeployInfo.Location `
        -AppName $DeployInfo.AppName
            
    DeployPickUpApp `
        -Environment $DeployInfo.Environment `
        -Location $DeployInfo.Location `
        -AppName $DeployInfo.AppName
       
	<#$ResourceGroupName += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment) 
    $DeployInfo.ResourceGroupName = $ResourceGroupName
    
    $DeployInfo.StorageAccountName = "st" + (Get-Culture).TextInfo.ToLower($AppName) + (Get-Culture).TextInfo.ToLower($Environment) + "001"
    $DeployInfo.AuditStorageAccountName=  "staudit" + (Get-Culture).TextInfo.ToLower($AppName) + (Get-Culture).TextInfo.ToLower($Environment) + "001"
    $DeployInfo.StorageAccountResourceID = "/subscriptions/"+ $DeployInfo.TenantId + "/resourceGroups/" + $ResourceGroupName + "/providers/Microsoft.Storage/storageAccounts/" + $DeployInfo.StorageAccountName
    #>
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "ResourceGroupName[41] " $DeployInfo.ResourceGroupName
    
    <#
	#Create Resource Group and Assign Contributor Permissions to the currently logged in user so the bicep deployment does not fail
    $ResourceId = CreateResourceGroup `
        -ResourceGroupName $ResourceGroupName `
        -Environment $Environment `
        -Location $Location
    
    #AssignUsersToResGroup -ResourceGroupName $ResourceGroupName
    #>
    #Give Current User Contributor role for successful deployment:
    <#$AzRole = "Contributor"
		AddRoleAssignment -AzRole $AzRole `
       -ResourceGroupName  $DeployInfo.ResourceGroupName `
	   -User $CurrUser
	   #-UserPrincipalName  $DeployInfo.CurrUserPrincipalName `
	#>

    "["+ $today +"] Starting Deployment: " + $DeploymentName > $OutFile
    "TenantName:`t" + $DeployInfo.TenantName  >> $OutFile
    "TenantId:`t" + $DeployInfo.TenantId  >> $OutFile
    "SubscriptionName:`t" + $DeployInfo.SubscriptionName  >> $OutFile
    "SubscriptionId:`t" + $DeployInfo.SubscriptionId  >> $OutFile
    "Environment:`t" + $DeployInfo.Environment  >> $OutFile    
    "AppName:`t" + $DeployInfo.AppName   >> $OutFile
    "ResourceGroup:`t"+ $DeployInfo.ResourceGroupName  >> $OutFile
    "Location:`t" + $DeployInfo.Location  >> $OutFile
            
    if (! $AppName.ToLower().Contains("api"))
    {
        #$APIAppRegName = $AppName + 'api'
        $DeployInfo.APIAppRegName = $AppName + 'API'
        #"APIAppRegName:`t" + $DeployInfo.APIAppRegName  >> $OutFile  
    }
        
    #$DeployInfo = IngestJsonFile($OutFileJSON)
    #Write-Host -ForegroundColor Green "RunDeployment[74] DeployInfo.FileExists=" $DeployInfo.FileExists
    if($DeployInfo.FileExists)
    {
        $Caller='RunDeployment.RunDeployment[84]'       
        #PrintObject -object $DeploxyInfo -Caller $Caller
        #PrintHash -object $DeployInfo -Caller $Caller
        
        $APIAppRegObjectId = $DeployInfo.APIAppRegObjectId
        $APIAppRegName =  $DeployInfo.APIAppRegName
        
        #Write-Host -ForegroundColor Green "Existing APIAppRegName="$APIAppRegName
        #Write-Host -ForegroundColor Green "Existing APIAppRegObjectId="$APIAppRegObjectId
    
        $ClientAppRegObjectId = $DeployInfo.ClientAppRegObjectId
        $ClientAppRegName = $DeployInfo.ClientAppRegName
        
        #Write-Host -ForegroundColor Green "Existing ClientAppRegName=$ClientAppRegName"
        #Write-Host -ForegroundColor Green "Existing ClientAppRegObjectId=$ClientAppRegObjectId"
    }
    else
    {
        #Write-Host -ForegroundColor White "RunDeployment[74] calling ConfigureAPI, ConfigureWebClient !!!"                   
        #Write-Host -ForegroundColor Green "RunDeployment[96] APIAppRegName="$DeployInfo.APIAppRegName
        #$ApiAppRegJson = ConfigureAPI -AppName $DeployInfo.APIAppRegName -DeployInfo $DeployInfo
        #ConfigureAPI -AppName $DeployInfo.APIAppRegName -DeployInfo $DeployInfo
		<#$DeployInfo.Solution = "Transfer"
        $DeployInfo.AppName = $AppName + $DeployInfo.Solution
        $ApiAppRegObj = CreateAppRegistration -AppName $DeployInfo.APIAppRegName -DeployInfo $DeployInfo 
		#>
		#$DeployInfo.Solution = "Pickup"
        #$clientAppRegObj = CreateAppRegistration -AppName $AppName -DeployInfo $DeployInfo
        <#
        $Caller='RunDeployment.RunDeployment[103]'
        PrintObject -object $DeployInfo -Caller $Caller
        exit(1)
        #>
        #PrintHash -object $DeployInfo -Caller $Caller        
        #$ClientAppRegJson = ConfigureWebClient -AppName $AppName -DeployInfo $DeployInfo
        #ConfigureWebClient -AppName $DeployInfo.AppName -DeployInfo $DeployInfo
        #$Caller='RunDeployment[110]'        
        #PrintHash -object $ClientAppRegJson -Caller $Caller
    }
    
    #Write-Host -ForegroundColor White "RunDeployment[122] calling WriteJsonFile: `$OutFileJSON=`"$OutFileJSON`""                   
    WriteJsonFile -FilePath $OutFileJSON -CustomObject $DeployInfo 
    #if($debugFlag -eq $false){
    exit(1)
    StartBicepDeploy `
        -ResourceGroupName $ResourceGroupName `
        -Environment $Environment.ToLower() `
        -Location $Location.ToLower() `
        -AppName $AppName.ToLower() `
        -DeployInfo $DeployInfo
    #}
    
    #This command gets a specific key for a Storage account.
    #$DeployInfo.AzureWebJobsStorage = (Get-AzStorageAccountKey -ResourceGroupName $DeployInfo.ResourceGroupName -Name $DeployInfo.StorageAccountName)| Where-Object {$_.KeyName -eq "key1"}
    
    #This command gets a specific key value for a Storage account. 
    #$DeployInfo.AzureWebJobsStorage = (Get-AzStorageAccountKey -ResourceGroupName "RG01" -Name "mystorageaccount")[0].Value
    
    $global:RootFolder = "C:\GitHub\dtp\"
    $global:TemplateDir = $RootFolder + "Deploy\LocalSetUp"
    CreateEnvironmentFiles -RootFolder $RootFolder -TemplateDir $TemplateDir
    
    #$CurrentUser = Disconnect-AzAccount -Scope CurrentUser       
    #Write-Host -ForegroundColor Green -BackgroundColor Black "`nPLEASE SEE APP REGISTRATION INFO IN THE LOGS FOLDER: $LogsFolder"

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $global:EndTime = $today
    $Duration = New-TimeSpan -Start $StartTime -End $EndTime
    
    Write-Host -ForegroundColor Cyan "================================================================================" 
	Write-Host -ForegroundColor Cyan "[$today] COMPLETED DEPLOYMENT "
    Write-Host -ForegroundColor Cyan "DEPLOYMENT DURATION [HH:MM:SS]:" $Duration
	Write-Host -ForegroundColor Cyan "================================================================================"  
    
    if($debugFlag)
    {
        $OutFileJSONFullPath = ((Get-ChildItem -Path $OutFileJSON).Directory | select FullName).FullName
        $Destination = "C:\GitHub\_App Registration Logs\"+ $jsonFileName
        #Write-Host -ForegroundColor Yellow "RunDeployment[163] Copy json `$OutFileJSONFullPath=`"$OutFileJSONFullPath`""
        #Write-Host -ForegroundColor Yellow "RunDeployment[164] `$Destination=`"$Destination`""    
        Copy-Item $OutFileJSON $Destination
		
		
        <#$Destination = "$LogsFolderPath\$JsonFileName"
        Write-Host -ForegroundColor Yellow "RunDeployment[167] `$Destination=`"$Destination`""    
        Copy-Item $OutFileJSON $Destination
        #>
        $Destination = "C:\GitHub\_App Registration Logs\"+ $LogFileName
        #Write-Host -ForegroundColor Yellow "RunDeployment[171] `$Destination=`"$Destination`""
        Copy-Item $OutFile $Destination
    }
    #>
      
    "================================================================================"	>> $OutFile
    "[$today] COMPLETED DEPLOYMENT "													>> $OutFile
    "DEPLOYMENT DURATION [HH:MM:SS]:" + $Duration										>> $OutFile
    "================================================================================" 	>> $OutFile 

}#RunDeployment



Function global:DeployTransferApp
{
    Param(
          [Parameter(Mandatory = $false)] [String]$Environment
        , [Parameter(Mandatory = $false)] [String]$Location
        , [Parameter(Mandatory = $false)] [String]$AppName
        )
    
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    Write-Host -ForegroundColor Green "`n================================================================================"
	Write-Host -ForegroundColor Green "[$today] STARTING DeployTransferApp ..."
	Write-Host -ForegroundColor Green "================================================================================`n"    
    "================================================================================" 	>> $OutFile
    "[$today] WELCOME TO THE DATA TRANSFER APP DeployTransferApp!!" 							>> $OutFile
    "================================================================================" 	>> $OutFile

    #Add Subscription level custom role from definition file:
    #Assign Subscription Custom Role: DTP Storage Blob Data ReadWrite from Deploy/ReaderSupportRole.json   
    
    #TransferAppObj
	#$RoleDefinitionFile = $DeployFolder + $TransferAppObj.RoleDefinitionFileDTP
    $RoleDefinitionFile = $DeployFolder + $DeployInfo.RoleDefinitionFileDTP
    AddCustomRoleFromFile -FilePath $RoleDefinitionFile

    $DeployInfo.Solution = "Transfer"
    $DeployInfo.AppName = $AppName + $DeployInfo.Solution
    
    $ResourceGroupName += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment) 
    $DeployInfo.ResourceGroupName = $ResourceGroupName
    
    #Create Resource Group and Assign Contributor Permissions to the currently logged in user so the bicep deployment does not fail
    $ResourceId = CreateResourceGroup `
        -ResourceGroupName $ResourceGroupName `
        -Environment $Environment `
        -Location $Location
    
    #AssignUsersToResGroup -ResourceGroupName $ResourceGroupName

    $ApiAppRegObj = CreateAppRegistration -AppName $DeployInfo.APIAppRegName -DeployInfo $DeployInfo 
    $clientAppRegObj = CreateAppRegistration -AppName $AppName -DeployInfo $DeployInfo
}#DeployTransferApp
    
Function global:DeployPickUpApp
{
    Param(
          [Parameter(Mandatory = $false)] [String]$Environment
        , [Parameter(Mandatory = $false)] [String]$Location
        , [Parameter(Mandatory = $false)] [String]$AppName
        )
    
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    Write-Host -ForegroundColor Green "`n================================================================================"
	Write-Host -ForegroundColor Green "[$today] STARTING DeployPickUpApp ..."
	Write-Host -ForegroundColor Green "================================================================================`n"    
    "================================================================================" 	>> $OutFile
    "[$today] WELCOME TO THE DATA TRANSFER APP DeployPickUp!!" 							>> $OutFile
    "================================================================================" 	>> $OutFile

    $DeployInfo.Solution = "Pickup"
    $DeployInfo.AppName = $AppName + $DeployInfo.Solution

    $ResourceGroupName += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment) 
    $DeployInfo.ResourceGroupName = $ResourceGroupName

    #Add Subscription level custom role from definition file:
    #Assign Subscription Custom Role: DTP Storage Blob Data ReadWrite from Deploy/ReaderSupportRole.json   
    
    #$RoleDefinitionFile = $DeployFolder + $PickupAppObj.RoleDefinitionFileDPP
    $RoleDefinitionFile = $DeployFolder + $DeployInfo.RoleDefinitionFileDPP
    AddCustomRoleFromFile -FilePath $RoleDefinitionFile


    #Create Resource Group and Assign Contributor Permissions to the currently logged in user so the bicep deployment does not fail
    $ResourceId = CreateResourceGroup `
        -ResourceGroupName $ResourceGroupName `
        -Environment $Environment `
        -Location $Location
    
    #AssignUsersToResGroup -ResourceGroupName $ResourceGroupName
    $ApiAppRegObj = CreateAppRegistration -AppName $DeployInfo.APIAppRegName -DeployInfo $DeployInfo 
    $clientAppRegObj = CreateAppRegistration -AppName $AppName -DeployInfo $DeployInfo

}#DeployPickUpApp