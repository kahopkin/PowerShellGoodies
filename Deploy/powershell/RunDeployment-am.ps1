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

Function global:RunDeployment {
    Param(
          [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location        
        , [Parameter(Mandatory = $true)] [String]$AppName
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*** [$today] START RunDeployment ***"

    #Connect to Az and MS Graph   
    ConnectToMSGraph
    
    $todayFN = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    $DeploymentName = "Deployment_" + $todayFN
        
    #Create Resource Group	
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
        
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[49] AppName: $AppName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[50] ResGroupName: $ResGroupName"
    #Write-Host -ForegroundColor Yellow "RunDeployment[205] Supplied Parameters:"
    #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "RunDeployment[57] "
    <#
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[62] ApiAppRegName: $ApiAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] ClientAppRegName: $ClientAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] ResGroupName: $ResGroupName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] Environment: $Environment"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] AppName: $AppName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[67] Location: $Location"
   #>
   
    $object = @{}
    if (! $AppName.ToLower().Contains("api"))
    {
        $ApiAppRegName = $AppName + 'api'
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "RunDeployment[82] ApiAppRegName: $ApiAppRegName"
    }
        
    if (Test-Path $OutFileJSON) 
    {
        $FullPath = Get-ChildItem -Path $OutFileJSON | select FullName
        Write-Host "RunDeployment[79] jsonFileName.FullPath: " $FullPath.FullName        
        Write-Host "RunDeployment[80] File: $OutFileJSON Exists"

        $FileExists = $true
        $json = Get-Content $OutFileJSON | Out-String | ConvertFrom-Json
        
        $object.Add("Tenant", $json.Tenant) 
        $object.Add("TenantId", $json.TenantId)
        $object.Add("SubscriptionId",$json.SubscriptionId)
        $object.Add("ApiAppRegName", $json.ApiAppRegName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add("ApiClientSecret",$json.ApiClientSecret)
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)
        
        $ApiAppRegJson = ConvertTo-Json $object											   
        $ClientAppRegJson = $ApiAppRegJson
    }
    else
    {
        Write-Host -ForegroundColor Green "!!!! RunDeployment[109] $jsonFileName Doesn't Exists, calling ConfigureAPI, ConfigureWebClient......"
        $object = @{
            Tenant = $Tenant
            TenantId = $TenantId
            SubscriptionId = $SubscriptionId        
        }        
        $json = ConvertTo-Json $object
        $json > $OutFileJSON 
        $FileExists = $false
		
        $ApiAppRegJson = ConfigureAPI -AppName $ApiAppRegName
                
        $ClientAppRegJson = ConfigureWebClient -AppName $AppName}
        Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[127] *** STARTING StartBicepDeploy ***"
	
        StartBicepDeploy `
            -ResGroupName $ResGroupName `
            -Environment $Environment.ToLower() `
            -Location $Location.ToLower() `
            -AppName $AppName.ToLower() `
            -ApiAppRegJson $ApiAppRegJson `
            -ClientAppRegJson $ClientAppRegJson  
        
    Write-Host -ForegroundColor Red -BackgroundColor Black "`nPLEASE SEE APP REGISTRATION INFO IN OUTPUT FILE: $OutFile*** "

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n*** [$today] DEPLOYMENT COMPLETED ***"
    
}#RunDeployment

Function global:ConfigureAPI{
Param(
          [Parameter(Mandatory = $true)] [String]$AppName
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n***[$today] STARTING RunDeployment.ConfigureAPI App: $AppName ***"
    #Create API App Registration

    $ApiAppRegJson = CreateAppRegistration $AppName
    Write-Host -ForegroundColor Cyan "RunDeployment.ConfigureAPI[136] $AppName : $AppName Created"

    $clientObj = ConvertFrom-Json $ApiAppRegJson
   <# 
    Write-Host -ForegroundColor Yellow "ConfigureAPI[169] SubscriptionId: " $clientObj[0].SubscriptionId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] TenantId:" $clientObj[0].TenantId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] AppName:" $clientObj[0].AppName
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] ApiClientId: "$clientObj[0].ApiClientId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[] ApiAppObjectId: "$clientObj[0].ApiAppObjectId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[175] ApiExisting: "$clientObj[0].ApiExisting
    #>
    $AppId = $clientObj[0].ApiClientId
    $AppObjectId = $clientObj[0].ApiAppObjectId
    $AppName = $clientObj[0].ApiAppRegName

    Write-Host -ForegroundColor Cyan "RunDeployment.ConfigureAPI[184] clientObj[0].ApiExisting:" $clientObj[0].ApiExisting
    if($clientObj[0].ApiExisting -eq 'false')
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

        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[172] ExposeScope.Value:" $ExposeScope.Value
        #$SPN = CreateServicePrincipal -AppId $AppId
        #Write-Host -ForegroundColor Yellow "ConfigureAPI[56] Spn.AppDisplayName:" $Spn.AppDisplayName

        #Azure Storage:
        $PermissionParent = "e406a681-f3d4-42a8-90b6-c2b029497af1"
        $PermissionParentName = "Azure Storage"
        $RequiredDelegatedPermissionNames =
        @(
            "user_impersonation"
        )

        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[204] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

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

        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[224] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $GraphRequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames


        #Azure Service Management:
        <#$PermissionParent = "40a69793-8fe6-4db1-9591-dbc5c57b17d8"
        $PermissionParentName = "Azure Service Management"
        $RequiredDelegatedPermissionNames =
            @(
                "user_impersonation"
            )

        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[242] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $AzServiceMgmtPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames
        #>
        $RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
        $RequiredResourcesAccessList.Add($RequiredPermissions)
        $RequiredResourcesAccessList.Add($GraphRequiredPermissions)
	    #$RequiredResourcesAccessList.Add($AzServiceMgmtPermissions)

        # Add the permissions to the application
        Update-MgApplication -ApplicationId $AppObjectId -RequiredResourceAccess $RequiredResourcesAccessList
		Write-Host -ForegroundColor Green "RunDeployment.ConfigureAPI[234] $AppName Application's API Permissions are updated!"
		
        #SetRedirectURI -ObjectId $AppObjectId

    }#clientObj[0].Existing -eq 'false'
    else
    {
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[241] clientObj[0].Existing: " $clientObj[0].Existing
        $json = Get-Content -Raw $jsonFileName | Out-String | ConvertFrom-Json
        
        $object.Add("ApiAppRegName", $json.AppName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add('ApiClientSecret',$json.ApiClientSecret)
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)     
        $object.Add("ApiExisting", $json.ApiExisting)  
        $object.Add("WebExisting", $json.WebExisting)  
        $ApiAppRegJson = ConvertTo-Json $object
    }   

    Write-Host -ForegroundColor Green "RunDeployment.ConfigureAPI[255] $AppName Application's API Permissions are updated!"
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*** [$today] FINISHED RunDeployment.ConfigureAPI App: $AppName *** "
    return $ApiAppRegJson
}#ConfigureAPI

Function global:ConfigureWebClient{
    Param(
          [Parameter(Mandatory = $true)] [String]$AppName
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n***[$today] START RunDeployment.ConfigureWebClient ***"

    #Create webAPI app Registration
    
    $clientAppRegJson = CreateAppRegistration -AppName $AppName
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment.ConfigureWebClient[271] AppName:  $AppName Created"

    $clientObj = ConvertFrom-Json $clientAppRegJson
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[273] SubscriptionId: " $clientObj[0].SubscriptionId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] TenantId:" $clientObj[0].TenantId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] WebAppRegName:" $clientObj[0].WebAppRegName
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] WebClientId: "$clientObj[0].WebClientId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[] WebAppObjectId: "$clientObj[0].WebAppObjectId
    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[280] WebExisting: "$clientObj[0].WebExisting
    
    $AppId = $clientObj[0].WebClientId
    $AppObjectId = $clientObj[0].WebAppObjectId
    $AppName = $clientObj[0].WebAppRegName

    if($clientObj[0].WebExisting -eq 'false')
    {
        #$SPN = CreateServicePrincipal -AppId $AppId
        #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[128] Spn.AppDisplayName:" $Spn.AppDisplayName

        #MS Graph Delegated Permissions:
        $PermissionParent = "Microsoft Graph"
        $RequiredDelegatedPermissionNames =
        @(
            "User.Read"
        )
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[296] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

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
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[312] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

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
        Write-Host -ForegroundColor Green "RunDeployment.ConfigureWebClient[327] $AppName Application's API Permissions are updated!"
        #Write-Host -ForegroundColor Cyan $ApiAppRegJson       
        #SetRedirectURI -ObjectId $AppObjectId
    }#clientObj[0].Existing -eq 'false'
    else
    {
        Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[333] clientObj[0].Existing: " $clientObj[0].Existing
        $json = Get-Content -Raw $jsonFileName | Out-String | ConvertFrom-Json
        
        $object.Add("ApiAppRegName", $json.ApiAppRegName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add("ApiClientSecret",$json.ApiClientSecret)
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)     
        $object.Add("ApiExisting", $json.ApiExisting)  
        $object.Add("WebExisting", $json.WebExisting)  
        $clientAppRegJson = ConvertTo-Json $object
		#AppId = $json.WebClientId									   
    }

    Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureWebClient[348] AppId:" $AppId
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*** [$today] FINISHED RunDeployment.ConfigureWebClient ***"
    
    return $clientAppRegJson
	
}#ConfigureWebClient