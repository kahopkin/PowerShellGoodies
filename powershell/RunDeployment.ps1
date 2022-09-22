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
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START RunDeployment"
    
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
            
    if (! $AppName.ToLower().Contains("api"))
    {
        $ApiAppRegName = $AppName + 'api'        
    }
        
    $AppRegObj = IngestJsonFile($OutFileJSON)        

    if($AppRegObj.FileExists)
    {
        $Caller='RunDeployment'       
        #PrintObject -object $AppRegObj -Caller $Caller
        #PrintHashTable -object $AppRegObj -Caller $Caller
        
        $ApiAppObjectId = $AppRegObj.ApiAppObjectId
        $ApiAppRegName =  $AppRegObj.ApiAppRegName
        
        Write-Host -ForegroundColor Green "RunDeployment[63] ApiAppRegName="$ApiAppRegName
        Write-Host -ForegroundColor Green "RunDeployment[64] ApiAppObjectId="$ApiAppObjectId
    
        $WebAppObjectId = $AppRegObj.WebAppObjectId
        $WebAppRegName = $AppRegObj.WebAppRegName
        
        Write-Host -ForegroundColor Green "RunDeployment[69] WebAppRegName=$WebAppRegName"
        Write-Host -ForegroundColor Green "RunDeployment[70] WebAppObjectId=$WebAppObjectId"
    }
    else
    {
        #Write-Host -ForegroundColor White "RunDeployment[74] calling ConfigureAPI, ConfigureWebClient !!!"                   
        $ApiAppRegJson = ConfigureAPI -AppName $ApiAppRegName -AppRegObj $AppRegObj
        $Caller='RunDeployment[77]'
        #PrintObject -object $ApiAppRegJson -Caller $Caller
        #PrintHashTable -object $AppRegObj -Caller $Caller
        
        $ClientAppRegJson = ConfigureWebClient -AppName $AppName -AppRegObj $AppRegObj
        #$Caller='RunDeployment[82]'        
        #PrintHashTable -object $ClientAppRegJson -Caller $Caller
    }    

#if($debugFlag -eq $false){
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[86] STARTING StartBicepDeploy"

    StartBicepDeploy `
    -ResGroupName $ResGroupName `
    -Environment $Environment.ToLower() `
    -Location $Location.ToLower() `
    -AppName $AppName.ToLower() `
    -AppRegObj $AppRegObj
#}
   
    Write-Host -ForegroundColor Green -BackgroundColor Black "`nPLEASE SEE APP REGISTRATION INFO IN OUTPUT FILE: $OutFile"

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor DarkGreen -BackgroundColor White  "`n[$today] RunDeployment: DEPLOYMENT COMPLETED`n"

}#RunDeployment


Function global:ConfigureAPI
{
    Param(
           [Parameter(Mandatory = $true)] [String] $AppName
          ,[Parameter(Mandatory = $true)] $AppRegObj
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] STARTING RunDeployment.ConfigureAPI App: $AppName "
        
    #Create API App Registration
    $ApiAppRegObj = CreateAppRegistration -AppName $AppName -AppRegObj $AppRegObj    
    
    #$Caller = 'RunDeployment.ConfigureAPI[117]'
    #Write-Host -ForegroundColor Cyan "RunDeployment.ConfigureAPI[143] ApiAppRegObj:"
    #PrintHashTable -object $ApiAppRegObj -Caller $Caller

    $AppId = $ApiAppRegObj.ApiClientId
    $AppObjectId = $ApiAppRegObj.ApiAppObjectId
    $AppName = $ApiAppRegObj.ApiAppRegName
    																														  
    if($ApiAppRegObj.ApiExisting -eq $false)
    {
        
        Write-Host -ForegroundColor White "RunDeployment.ConfigureAPI[128] Calling CreateScope:"        
       $ExposeScope = CreateScope `
            -AppName "$AppName" `
            -Value "DTP.Standard.Use" `
            -UserConsentDisplayName "Permits use of $AppName via front-end app" `
            -UserConsentDescription "Permits use of $AppName via front-end app" `
            -AdminConsentDisplayName "Permits use of $AppName via front-end app" `
            -AdminConsentDescription "Permits use of $AppName via front-end app" `
            -IsEnabled $true `
            -Type "User"

        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[139] ExposeScope.Value:" $ExposeScope.Value                
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[140] CreateServicePrincipal for:" $AppName
        $SPN = CreateServicePrincipal -AppId $AppId -AppRegObj $ApiAppRegObj
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[142] Created ServPrinc for $AppName SPN.AppId:" $SPN.AppId

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

        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[175] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

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
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[189] ApiAppRegObj.Existing App Reg: " $ApiAppRegObj.Existing
        $ApiAppRegObj = IngestJsonFile($OutFileJSON)        
    }
    
    #Write-Host -ForegroundColor Green "RunDeployment.ConfigureAPI[218] $AppName Application's API Permissions are updated!"									       
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor DarkGreen -BackgroundColor White  "`n [$today] FINISHED RunDeployment.ConfigureAPI App: $AppName  "

    return $ApiAppRegObj
}#ConfigureAPI

Function global:ConfigureWebClient
{
    Param(
           [Parameter(Mandatory = $true)] [String] $AppName
          ,[Parameter(Mandatory = $true)] $AppRegObj
          )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor DarkGreen -BackgroundColor White "`n[$today] START RunDeployment.ConfigureWebClient "
    
    #$Caller='ConfigureWebClient[217]'    
    #PrintObject -object $AppRegObj -Caller $Caller
    #PrintHashTable -object $AppRegObj -Caller $Caller

    #Create webAPI app Registration:
    $clientAppRegObj = CreateAppRegistration -AppName $AppName -AppRegObj $AppRegObj
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment.ConfigureWebClient[216] AppName:  $AppName Created"
        
    $AppId = $clientAppRegObj.WebClientId
    $AppObjectId = $clientAppRegObj.WebAppObjectId
    $AppName = $clientAppRegObj.WebAppRegName
    $ApiAppRegName = $clientAppRegObj.ApiAppRegName
    <#
    Write-Host -ForegroundColor Cyan "AppId=""$AppId"""
    Write-Host -ForegroundColor Cyan "AppObjectId=""$AppObjectId"""
    Write-Host -ForegroundColor Cyan "AppName=""$AppName"""
    Write-Host -ForegroundColor Cyan "ApiAppRegName=""$ApiAppRegName"""
    #>    
    if($clientAppRegObj.WebExisting -eq $false)
    {        
        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[247] CreateServicePrincipal for:" $AppName
        $SPN = CreateServicePrincipal -AppId $AppId -AppRegObj $clientAppRegObj
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[232] CreatedServicePrincipal SPN.AppId:" $SPN.AppId
        
        #MS Graph Delegated Permissions:
        $PermissionParent = "Microsoft Graph"
        $RequiredDelegatedPermissionNames =
        @(
            "User.Read"
        )
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[257] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $GraphRequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        $PermissionPrincipal= Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$ApiAppRegName"} 
        #Write-Host "[267]PermissionPrincipal.DisplayName=" $PermissionPrincipal.DisplayName
        #Write-Host "[267]PermissionPrincipal.AppId="$PermissionPrincipal.AppId
        #Write-Host "[267]PermissionPrincipal.Id=" $PermissionPrincipal.Id
        $PermissionParentName = $PermissionPrincipal.DisplayName
        $PermissionParent = $PermissionPrincipal.AppId
        $RequiredDelegatedPermissionNames =
        @(
            "DTP.Standard.Use"
        )
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[259] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

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
        #Write-Host -ForegroundColor Green "RunDeployment.ConfigureWebClient[279] AppObjectId = " $AppObjectId
        Update-MgApplication -ApplicationId $AppObjectId -RequiredResourceAccess $RequiredResourcesAccessList
        Write-Host -ForegroundColor Green "RunDeployment.ConfigureWebClient[275] $AppName Application's API Permissions are updated!"

    }#clientAppRegObj.WebExisting -eq 'false'
    else
    {
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[286] clientAppRegObj[0].Existing: " $clientAppRegObj["Existing"]
        $clientAppRegObj = IngestJsonFile($OutFileJSON) 							
    }
    																						
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor DarkGreen -BackgroundColor White "`n[$today] FINISHED RunDeployment.ConfigureWebClient"
	
    return $clientAppRegObj
 
}#ConfigureWebClient


Function global:CallDeployment{
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[136] STARTING StartBicepDeploy"
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
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START IngestJsonFile "
    
    $Hashtable = [ordered]@{}
    if (Test-Path $OutFileJSON) 
    {
        $FullPath = Get-ChildItem -Path $OutFileJSON | select FullName
        Write-Host "RunDeployment.IngestJsonFile[319] jsonFileName.FullPath: " $FullPath.FullName        
        #Write-Host "RunDeployment.IngestJsonFile[342] File: $OutFileJSON Exists"
                
        $json = Get-Content $OutFileJSON | Out-String | ConvertFrom-Json
        #Write-Host "RunDeployment.IngestJsonFile[349] json.Tenant:" $json.Tenant

        $Hashtable = [ordered]@{
            Tenant = $json.Tenant;
            TenantId = $json.TenantId;
            SubscriptionId = $json.SubscriptionId ;
            FileExists = $true;       
	        ApiAppRegName = $json.ApiAppRegName;
	        ApiClientId = $json.ApiClientId;
	        ApiClientSecret = $json.ApiClientSecret;
	        ApiAppObjectId = $json.ApiAppObjectId;
            ApiServicePrincipalId="ApiServicePrincipalId"
            ApiExisting=$true;
	        WebAppRegName = $json.WebAppRegName;
	        WebClientId = $json.WebClientId;
	        WebAppObjectId = $json.WebAppObjectId
            WebClientServicePrincipalId = "WebClientServicePrincipalId"
            WebExisting=$true
        }      
    }
    else
    {
        Write-Host -ForegroundColor Yellow "!!RunDeployment.IngestJsonFile[345] $jsonFileName Doesn't Exists, Creating object"
        $Hashtable = [ordered]@{
            Tenant = $Tenant;
            TenantId = $TenantId;
            SubscriptionId = $SubscriptionId;
            FileExists = $false;       	       
            ApiAppRegName = "ApiAppRegName";
	        ApiClientId ="ApiClientId";
	        ApiClientSecret = "ApiClientSecret";
	        ApiAppObjectId = "ApiAppObjectId";
            ApiServicePrincipalId="ApiServicePrincipalId";
            ApiExisting=$false;
	        WebAppRegName = "WebAppRegName";
	        WebClientId = "WebClientId";
	        WebAppObjectId = "WebAppObjectId";
            WebClientServicePrincipalId = "WebClientServicePrincipalId"
            WebExisting=$false
        }  
    }#else    

    #$Caller='IngestJsonFile[365]'
    #PrintObject -object $Hashtable -Caller $Caller
    #PrintHashTable -object $AppRegObj -Caller $Caller

    $json = ConvertTo-Json $Hashtable
    $json > $OutFileJSON	
    																					
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED IngestJsonFile `n"

    return $Hashtable
}#IngestJsonFile


#$Caller=''
Function global:PrintObject{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $true)] [string] $Caller

    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n[$today] START $Caller.PrintObject Caller "
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    {         
        write-host  -ForegroundColor Yellow -BackgroundColor Black "[$i]" $item.name "=" $item.value
        $i++       
    }

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
}#PrintObject


#$Caller=''
Function global:PrintHashTable{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $true)] [string] $Caller

    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHashTable: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    foreach ($item in $object.GetEnumerator()) 
    {         
        write-host -ForegroundColor Cyan $item.name "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHashTable $Caller"
}#PrintObject