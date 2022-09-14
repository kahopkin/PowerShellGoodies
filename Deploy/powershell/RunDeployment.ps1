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
          [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location
        , [Parameter(Mandatory = $true)] [String]$AppName
        )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] START RunDeployment *****************"
    $Caller='RunDeployment'
    #Connect to Az and MS Graph   
    ConnectToMSGraph
    
    $todayFN = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    $DeploymentName = "Deployment_" + $todayFN        
    $ResGroupName += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment)
    
    "["+ $today +"] Starting Deployment: " + $DeploymentName > $OutFile
    "Tenant:	" + $Tenant  >> $OutFile
    "TenantId:	" + $TenantId  >> $OutFile
    "SubscriptionName:	" + $SubscriptionName  >> $OutFile
    "SubscriptionId:	" + $SubscriptionId  >> $OutFile
    "Environment:	$Environment"  >> $OutFile    
    "AppName:	$AppName"  >> $OutFile
    "ResourceGroup:	$ResGroupName"  >> $OutFile    
    "Location:	$Location"  >> $OutFile
        
    <#    
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[47] ResourceGroupName: $ResGroupName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[48] AppName: $AppName"    
    Write-Host -ForegroundColor Yellow "RunDeployment[205] Supplied Parameters:"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "RunDeployment[57] "    
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[62] ApiAppRegName: $ApiAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] ClientAppRegName: $ClientAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] ResGroupName: $ResGroupName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] Environment: $Environment"    
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[67] Location: $Location"
   #>
       
    if (! $AppName.ToLower().Contains("api"))
    {
        $ApiAppRegName = $AppName + 'api'        
    }
        
    $AppRegObj = IngestJsonFile($OutFileJSON)        

    if($AppRegObj.FileExists)
    {
        #Write-Host -ForegroundColor Cyan "RunDeployment[68] AppRegObj"
        #PrintObject -object $AppRegObj -Caller $Caller
        
        $ApiAppObjectId = $AppRegObj.ApiAppObjectId
        $ApiAppRegName =  $AppRegObj.ApiAppRegName
        
        Write-Host -ForegroundColor Green "RunDeployment[72] ApiAppRegName="$ApiAppRegName
        Write-Host -ForegroundColor Green "RunDeployment[73] ApiAppObjectId="$ApiAppObjectId
    
        $WebAppObjectId = $AppRegObj.WebAppObjectId
        $WebAppRegName = $AppRegObj.WebAppRegName
        
        Write-Host -ForegroundColor Green "RunDeployment[79] WebAppRegName=$WebAppRegName"
        Write-Host -ForegroundColor Green "RunDeployment[80] WebAppObjectId=$WebAppObjectId"
    }
    else
    {
        Write-Host -ForegroundColor Green "RunDeployment[87] calling ConfigureAPI, ConfigureWebClient !!!"   
                
        $ApiAppRegJson = ConfigureAPI -AppName $ApiAppRegName -AppRegObj $AppRegObj
                
        #Write-Host -ForegroundColor Cyan "RunDeployment[93] ApiAppRegJson"
        #PrintObject -object $AppRegObj -Caller $Caller
        
        $ClientAppRegJson = ConfigureWebClient -AppName $AppName -AppRegObj $AppRegObj
        #Write-Host -ForegroundColor Cyan "RunDeployment[98] ClientAppRegJson"
        #PrintObject -object $ClientAppRegJson -Caller $Caller
    }       
    
    #if($debugFlag -eq $false){
        Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[105] **** STARTING StartBicepDeploy *****"
        StartBicepDeploy `
        -ResGroupName $ResGroupName `
        -Environment $Environment.ToLower() `
        -Location $Location.ToLower() `
        -AppName $AppName.ToLower() `
        -AppRegObj $AppRegObj
    #}
   
    Write-Host -ForegroundColor Green -BackgroundColor Black "`nPLEASE SEE APP REGISTRATION INFO IN OUTPUT FILE: $OutFile****"

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n****[$today] DEPLOYMENT COMPLETED *******`n"

}#RunDeployment


Function global:ConfigureAPI
{
    Param(
           [Parameter(Mandatory = $true)] [String] $AppName
          ,[Parameter(Mandatory = $true)] $AppRegObj
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n***[$today] STARTING RunDeployment.ConfigureAPI App: $AppName ***"
    
    $Caller = 'ConfigureAPI'
    #Write-Host -ForegroundColor Cyan "RunDeployment.ConfigureAPI[193] AppRegObj:"
    #PrintObject -object $AppRegObj -Caller $Caller

    #Create API App Registration
    $ApiAppRegObj = CreateAppRegistration -AppName $AppName -AppRegObj $AppRegObj
    #Write-Host -ForegroundColor Cyan "RunDeployment.ConfigureAPI[131] $AppName : $AppName Created"

   <# 
    Write-Host -ForegroundColor Yellow "ConfigureAPI[169] SubscriptionId: " $ApiAppRegObj.SubscriptionId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] TenantId:" $ApiAppRegObj.TenantId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] AppName:" $ApiAppRegObj.AppName
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] ApiClientId: "$ApiAppRegObj.ApiClientId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] ApiAppObjectId: "$ApiAppRegObj.ApiAppObjectId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[175] ApiExisting: "$ApiAppRegObj.ApiExisting
    #>
    $AppId = $ApiAppRegObj.ApiClientId
    $AppObjectId = $ApiAppRegObj.ApiAppObjectId
    $AppName = $ApiAppRegObj.ApiAppRegName
    																														  
    if($ApiAppRegObj.ApiExisting -eq $false)
    {
       
        $ExposeScope = CreateScope `
            -AppName "$AppName" `
            -Value "DTP10.Users" `
            -UserConsentDisplayName "User Permit to use $AppName" `
            -UserConsentDescription "Permit use of $AppName for Users and Admins" `
            -AdminConsentDisplayName "Permit use of $AppName" `
            -AdminConsentDescription "Permit use of $AppName" `
            -IsEnabled $true `
            -Type "User"

        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[192] ExposeScope.Value:" $ExposeScope.Value
        
        #Write-Host -ForegroundColor Yellow "ConfigureAPI[168] CreateServicePrincipal for:" $AppName
        #$SPN = CreateServicePrincipal -AppId $AppId
        #Write-Host -ForegroundColor Yellow "ConfigureAPI[168] CreatedServicePrincipal SPN.AppId:" $SPN.AppId

        #Azure Storage:
        $PermissionParent = "e406a681-f3d4-42a8-90b6-c2b029497af1"
        $PermissionParentName = "Azure Storage"
        $RequiredDelegatedPermissionNames =
        @(
            "user_impersonation"
        )

        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[177] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $RequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        #MS Graph Delegated Permissions:
        $PermissionParent = "Microsoft Graph"
        $RequiredDelegatedPermissionNames =
        @(
            "User.Read"
        )

        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[193] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $GraphRequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames
        
        $RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
        $RequiredResourcesAccessList.Add($RequiredPermissions)
        $RequiredResourcesAccessList.Add($GraphRequiredPermissions)	    

        # Add the permissions to the application
        Update-MgApplication `
            -ApplicationId $AppObjectId `
            -RequiredResourceAccess $RequiredResourcesAccessList

    }#ApiAppRegObj.Existing -eq 'false'
    else
    {
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[213] ApiAppRegObj.Existing App Reg: " $ApiAppRegObj.Existing
        $ApiAppRegObj = IngestJsonFile($OutFileJSON)        
    }
    
    #Write-Host -ForegroundColor Green "RunDeployment.ConfigureAPI[218] $AppName Application's API Permissions are updated!"									   
    
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n*** [$today] FINISHED RunDeployment.ConfigureAPI App: $AppName *** "

    return $ApiAppRegObj
}#ConfigureAPI

Function global:ConfigureWebClient
{
    Param(
           [Parameter(Mandatory = $true)] [String] $AppName
          ,[Parameter(Mandatory = $true)] $AppRegObj
          )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n***[$today] START RunDeployment.ConfigureWebClient ***"
    
    #$Caller='ConfigureWebClient'
    #Write-Host -ForegroundColor Cyan "RunDeployment.ConfigureWebClient[236] AppRegObj:" 
    #PrintObject -object $AppRegObj -Caller $Caller

    #Create webAPI app Registration:    

    $clientAppRegObj = CreateAppRegistration -AppName $AppName -AppRegObj $AppRegObj
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment.ConfigureWebClient[242] AppName:  $AppName Created"
    <#
    $clientObj = ConvertFrom-Json $clientAppRegJson
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[244] SubscriptionId: " $clientAppRegObj.SubscriptionId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] TenantId:" $clientAppRegObj.TenantId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] WebAppRegName:" $clientAppRegObj.WebAppRegName
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] WebClientId: "$clientAppRegObj.WebClientId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] WebAppObjectId: "$clientAppRegObj.WebAppObjectId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[250] WebExisting: "$clientAppRegObj.WebExisting
    #>
    $AppId = $clientAppRegObj.WebClientId
    $AppObjectId = $clientAppRegObj.WebAppObjectId
    $AppName = $clientAppRegObj.WebAppRegName

    if($clientAppRegObj.WebExisting -eq $false)
    {        
        #Write-Host -ForegroundColor Yellow "ConfigureWebClient[254] CreateServicePrincipal for:" $AppName
        #$SPN = CreateServicePrincipal -AppId $AppId
        #Write-Host -ForegroundColor Yellow "ConfigureWebClient[256] CreatedServicePrincipal SPN.AppId:" $SPN.AppId
        
        #MS Graph Delegated Permissions:
        $PermissionParent = "Microsoft Graph"
        $RequiredDelegatedPermissionNames =
        @(
            "User.Read"
        )
        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[270] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $GraphRequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        $PermissionParentName = "Data Transfer Portal 1.0 API's"
        $PermissionParent = "435ed1e5-e4ab-4205-a2f5-2726945d19be"
        $RequiredDelegatedPermissionNames =
        @(
            "DTP10.Users"
        )
        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[286] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $RequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        $RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
        $RequiredResourcesAccessList.Add($RequiredPermissions)
        $RequiredResourcesAccessList.Add($GraphRequiredPermissions)

        # Add the permissions to the application
        Update-MgApplication -ApplicationId $AppObjectId -RequiredResourceAccess $RequiredResourcesAccessList
        #Write-Host -ForegroundColor Green "RunDeployment.ConfigureWebClient[297] $AppName Application's API Permissions are updated!"

    }#clientObj[0].Existing -eq 'false'
    else
    {
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[303] clientObj[0].Existing: " $clientObj[0].Existing
        $clientAppRegObj = IngestJsonFile($OutFileJSON) 							
    }
    																						
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n*** [$today] FINISHED RunDeployment.ConfigureWebClient ***"
	
    return $clientAppRegObj
 
}#ConfigureWebClient


Function global:CallDeployment{
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[136] *********** STARTING StartBicepDeploy **********"
    $Caller='CallDeployment'
    #if($debugFlag -eq $false){
    StartBicepDeploy `
        -ResGroupName $ResGroupName `
        -Environment $Environment.ToLower() `
        -Location $Location.ToLower() `
        -AppName $AppName.ToLower() `
        -ApiAppRegJson $ApiAppRegJson `
        -ClientAppRegJson $ClientAppRegJson
  #}
}#CallDeployment


Function global:IngestJsonFile{
Param(
      [Parameter(Mandatory = $true)] [String]$OutFileJSON    
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*** [$today] START IngestJsonFile ***"
    
    $Caller='IngestJsonFile'
    
    $object = @{}
    if (Test-Path $OutFileJSON) 
    {
        $FullPath = Get-ChildItem -Path $OutFileJSON | select FullName
        Write-Host "RunDeployment.IngestJsonFile[344] jsonFileName.FullPath: " $FullPath.FullName        
        Write-Host "RunDeployment.IngestJsonFile[345] File: $OutFileJSON Exists"

        $FileExists = $true
        $json = Get-Content $OutFileJSON | Out-String | ConvertFrom-Json
        #Write-Host "RunDeployment.IngestJsonFile[349] json.Tenant:" $json.Tenant
        
        $object.Add("Tenant", $json.Tenant) 
        $object.Add("TenantId", $json.TenantId)
        $object.Add("SubscriptionId",$json.SubscriptionId)

        $object.Add("ApiAppRegName", $json.ApiAppRegName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add("ApiClientSecret",$json.ApiClientSecret)
        $object.Add("ApiAppObjectId",$json.ApiAppObjectId)
        
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)

        $object.Add("FileExists", $true)             
    }
    else
    {
        Write-Host -ForegroundColor Green "!!RunDeployment.IngestJsonFile[368] $jsonFileName Doesn't Exists, Creating object"
        $object = @{
            Tenant = $Tenant
            TenantId = $TenantId
            SubscriptionId = $SubscriptionId
            FileExists = $false
        }     
    }    
    
    #Write-Host -ForegroundColor Cyan " *** RunDeployment.IngestJsonFile[464] object:"       
    #PrintObject -object $object -Caller $Caller
    $json = ConvertTo-Json $object
    $json > $OutFileJSON	
    																					
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n*** [$today] FINISHED IngestJsonFile ***`n"

    return $object
}#IngestJsonFile

