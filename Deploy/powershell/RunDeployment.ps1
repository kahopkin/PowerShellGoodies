

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
          [Parameter(Mandatory = $true)] [Object] $DeployObject        
         ,[Parameter(Mandatory = $false)] [string] $Solution
        )
    Write-Debug "RunDeployment.RunDeployment[27]"
    <#If($debugFlag)
    {
		Write-Host -ForegroundColor Magenta "RunDeployment.RunDeployment[29] "
    }#>
	
    <#
    $Caller='RunDeployment.RunDeployment[27] DeployObject'       
    PrintObject -object $DeployObject -Caller $Caller
    #>
	#Create Resource Group and Assign Contributor Permissions to the currently logged in user so the bicep deployment does not fail
    #$ResourceId = CreateResourceGroup -DeployObject $DeployObject
    
    #Uncomment this when not testing!!!
    #AssignUsersToResGroup -ResourceGroupName $ResourceGroupName
        
    "["+ $today +"] Starting Deployment: " + $DeployInfo.DeploymentName > $DeployInfo.LogFile
    "TenantName:`t" + $DeployInfo.TenantName  >> $DeployInfo.LogFile
    "TenantId:`t" + $DeployInfo.TenantId  >> $DeployInfo.LogFile
    "SubscriptionName:`t" + $DeployInfo.SubscriptionName  >> $DeployInfo.LogFile
    "SubscriptionId:`t" + $DeployInfo.SubscriptionId  >> $DeployInfo.LogFile
    "Environment:`t" + $DeployObject.Environment  >> $DeployInfo.LogFile    
    "AppName:`t" + $DeployObject.AppName   >> $DeployInfo.LogFile
    "ResourceGroup:`t"+ $DeployObject.ResourceGroupName  >> $DeployInfo.LogFile
    "Location:`t" + $DeployObject.Location  >> $DeployInfo.LogFile
    <#    
    Write-Host -ForegroundColor DarkYellow "RunDeployment[46] DeployObject.APIAppRegName=" $DeployObject.APIAppRegName
    Write-Host -ForegroundColor DarkYellow "RunDeployment[47] DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
    Write-Host -ForegroundColor DarkYellow "RunDeployment[48] DeployObject.APIAppRegExists=" $DeployObject.APIAppRegExists
    Write-Host -ForegroundColor DarkYellow "RunDeployment[49] DeployObject.ClientAppRegExists=" $DeployObject.ClientAppRegExists
    Write-Host -ForegroundColor DarkYellow "RunDeployment[50] DeployObject.Solution=" $DeployObject.Solution
    #>
    if( -not $DeployObject.APIAppRegExists)
    {    
        CreateAppRegistration -AppName $DeployObject.APIAppRegName -DeployObject $DeployObject
        
    }
    <#else
    {
        Write-Host -ForegroundColor Green "RunDeployment[55] Existing DeployObject.APIAppRegName=" $DeployObject.APIAppRegName
        #Write-Host -ForegroundColor Green "Starting Bicep Deployment...."
        #$Caller='RunDeployment[84]: TransferAppObj'       
        #PrintObject -object $TransferAppObj -Caller $Caller        
    }
	#>
    #Write-Host -ForegroundColor Yellow "RunDeployment[61] DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
    #Write-Host -ForegroundColor Yellow "RunDeployment[62] DeployObject.ClientAppRegExists=" $DeployObject.ClientAppRegExists
    if( -not $DeployObject.ClientAppRegExists)
    {
        CreateAppRegistration -AppName $DeployObject.ClientAppRegName -DeployObject $DeployObject        
    }
    <#else
    {
        Write-Host -ForegroundColor Green "RunDeployment[69] Existing DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
    }
	#>
	<#
	$Caller='RunDeployment[77]: DeployInfo'       
    PrintDeployObject -object $DeployInfo -Caller $Caller
    #>
    #Write-Host -ForegroundColor White "RunDeployment[76] calling WriteJsonFile: `$OutFileJSON=`"" $DeployInfo.OutFileJSON
    WriteJsonFile -FilePath $DeployInfo.OutFileJSON -CustomObject $DeployInfo    
    if($debugFlag -or $CurrUser.DisplayName -match 'Kat Hopkins')
    {
        $OutFileJSONFullPath = ((Get-ChildItem -Path $DeployInfo.OutFileJSON).Directory | select FullName).FullName
        $Destination = "C:\GitHub\_App Registration Logs\"+ $JsonFileName
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

}#RunDeployment



#Give Current User Contributor role for successful deployment:
    <#$AzRole = "Contributor"
		AddRoleAssignment -AzRole $AzRole `
       -ResourceGroupName  $DeployInfo.ResourceGroupName `
	   -User $CurrUser
	   #-UserPrincipalName  $DeployInfo.CurrUserPrincipalName `
	#>
