#CreateAppRegistration

Function global:CreateAppRegistration
{
    Param(
        [Parameter(Mandatory = $true)] [String] $AppName         
       ,[Parameter(Mandatory = $true)] [Object] $DeployObject  	
    )
    
    "================================================================================"	>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": CREATING APP REGISTRATION: " + $AppName			>> $DeployInfo.LogFile
    "================================================================================"	>> $DeployInfo.LogFile
    
    Write-Host -ForegroundColor Green "================================================================================"
    Write-Host -ForegroundColor Green "Step" $DeployInfo.StepCount": CREATING APP REGISTRATION: "$AppName
    Write-Host -ForegroundColor Green "================================================================================"
    $DeployInfo.StepCount++

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Cyan -BackgroundColor Black "`n  [$today] START CreateAppRegistration FOR $AppName  "
   
    #$Caller='CreateAppRegistration[13] BEFORE Param:AppRegObj'    
    #PrintObject -object $DeployObject -Caller $Caller
    
    $AdApplication = Get-AzADApplication -DisplayName $AppName    
    $nameLength = ($AdApplication.DisplayName.Length)    
    
    #Write-Host -ForegroundColor White "CreateAppRegistration[28] AdApplication.Name.Length=" $nameLength
    #Write-Host -ForegroundColor Yellow "CreateAppRegistration[29] AdApplication.Name=" $AdApplication.Name
    
    #depending on the name, the app registrations need different configurations.
    #API app registration        
    $WebAppUrl = "https://$AppName.azurewebsites.us"
    $redirectUris = @()
        
    if ($redirectUris -notcontains "$WebAppUrl") {
        $redirectUris += "$WebAppUrl"               
    }
        
    $global:mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
    $mySpaApplication.RedirectUris = $redirectUris

    #create a new Azure Active Directory App Reg
    if (($AdApplication.DisplayName.Length).Equals(0))
    {
        
        #Create the API APP REGISTRATION and Service Principal:
        if ($AppName -match 'api')
        {
           #Write-Host -ForegroundColor Green "CreateAppRegistration[47] start ConfigureAPI: AppName=" $AppName
           ConfigureAPI -AppName $AppName -DeployObject $DeployObject             
        }
        #Create the CLIENT APP REGISTRATION
        else
        {   
            Write-Host -ForegroundColor Green "CreateAppRegistration[56] start ConfigureWebApp: AppName=" $AppName
            ConfigureWebApp -AppName $AppName -DeployObject $DeployObject
        }#else: Create CLIENT APP REGISTRATION
        
        #Create the Enterprise Application for the app (Service Principal)
       
    } #app reg does not exist
    #EXISTING APP REGISTRATION
    else
	{
        #Write-Host -ForegroundColor Green "CreateAppRegistration[66] AppReg:" $AdApplication.DisplayName " EXISTS..."
        if($DeployObject.Solution -eq "Transfer")
        {
            Write-Host -ForegroundColor Green "CreateAppRegistration[69] Transfer AppReg:" $AdApplication.DisplayName " EXISTS..."
            $DeployObject.APIAppRegName = $AdApplication.DisplayName
		    $DeployObject.APIAppRegAppId = $AdApplication.AppId    
		    $DeployObject.APIAppRegObjectId = $AdApplication.Id
        }
        else  #PICKUP
        {
            Write-Host -ForegroundColor Green "CreateAppRegistration[73] PICKUP AppReg:" $AdApplication.DisplayName " EXISTS..."
            $DeployObject.APIAppRegName = $AdApplication.DisplayName
		    $DeployObject.APIAppRegAppId = $AdApplication.AppId    
		    $DeployObject.APIAppRegObjectId = $AdApplication.Id
        } #PICKUP
        #$Caller="CreateAppRegistration[65] DeployObject." + $DeployObject.Solution    
        #PrintObject -object $DeployObject -Caller $Caller
        #PrintHash -object $DeployObject -Caller $Caller        

    }#existing app registration
    #>

    #$json = ConvertTo-Json $DeployObject
    #$json > $DeployInfo.OutFileJSON 
    
    #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[171] Returning:AppRegObj: "
    #PrintObject -object $DeployObject -Caller $Caller
    #PrintHash -object $DeployObject -Caller $Caller

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Cyan -BackgroundColor Black  "`n  [$today] EXITING CreateAppRegistration for $DeployObject.AppName"

    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Green "`t`t`tFINISHED CREATING APP REGISTRATION: "$AppName
    Write-Host -ForegroundColor Cyan "================================================================================"    
    #return $DeployObject
} #end of func CreateAppRegistration


Function global:ConfigureAPI
{
    Param(
        [Parameter(Mandatory = $true)] [String] $AppName         
       ,[Parameter(Mandatory = $true)] [Object] $DeployObject      	
    )
    
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "CreateAppRegistration.ConfigureAPI[92] STARTING CreateAppRegistration.ConfigureAPI AppName= $AppName "    
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black  "CreateAppRegistration.ConfigureAPI[93] DeployObject.Solution=" $DeployObject.Solution
    
    #Create the App Roles at the time of creation
    
    $AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]
    
    #API Permissions:
    #Azure Storage: both Transfer and PickUp
    $PermissionParentId = "e406a681-f3d4-42a8-90b6-c2b029497af1"
    $PermissionParentName = "Azure Storage"
    $RequiredDelegatedPermissionNames =
    @(
        "user_impersonation"
    )

    #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[177] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $DeployObject.AppName"

    $RequiredPermissions = AddAPIPermissions `
        -PermissionParentName $PermissionParentName `
        -PermissionParentId $PermissionParentId `
        -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames            
    #>

    #API Permissions:
    #MS Graph Delegated Permissions: both Transfer and PickUp
    $GraphSP = Get-AzADServicePrincipal  | ? { $_.DisplayName -eq "Microsoft Graph" }
    $PermissionParentId = $GraphSP.AppId
    $PermissionParentName = "Microsoft Graph"
    $RequiredDelegatedPermissionNames =
    @(
        "User.Read"
    )

    #Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[175] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $DeployObject.AppName"
        
    $GraphRequiredPermissions = AddAPIPermissions `
        -PermissionParentName $PermissionParentName `
        -PermissionParentId $PermissionParentId `
        -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames
       
    $RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
    $RequiredResourcesAccessList.Add($RequiredPermissions)
    $RequiredResourcesAccessList.Add($GraphRequiredPermissions)
      
    if($DeployObject.Solution -eq "Transfer")
    {
        #Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureAPI[137] Transfer:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
	   <#
        $newAppRole = CreateAppRole `
            -AllowedMemberTypes "User" `
            -Description "Admin users of the $AppName API" `
            -DisplayName  "$AppName API Admins" `
            -Value "$AppName.Admins"
           #>
           $newAppRole = CreateAppRole `
            -AllowedMemberTypes "User" `
            -Description "Admin users of the $AppName API" `
            -DisplayName  "$AppName API Admins" `
            -Value "DTPAPI.Admins"                 
    
        $AppRoles += $newAppRole
        #Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureAPI[136] newAppRole.DisplayName= " $newAppRole.DisplayName
        <#
        $newAppRole = CreateAppRole `
            -AllowedMemberTypes "User" `
            -Description "Standard users of the $AppName API" `
            -DisplayName  "$AppName API Users" `
            -Value "$AppName.Users"
            #>                
        $newAppRole = CreateAppRole `
            -AllowedMemberTypes "User" `
            -Description "Standard users of the $AppName API" `
            -DisplayName  "$AppName API Users" `
            -Value "DTPAPI.Users"  
        $AppRoles += $newAppRole

        #Expose an API (Scope and Consent)
        $ScopeObj = [ordered]@{
            AppName = "$AppName";
            Value = "$AppName.Standard.Users";
            UserConsentDisplayName = "Permits use of $AppName via front-end app";
            UserConsentDescription = "Permits use of $AppName via front-end app" ;
            AdminConsentDisplayName = "Permits use of $AppName via front-end app";
            AdminConsentDescription = "Permits use of $AppName via front-end app"; 
            IsEnabled = $true ;
            Type = "User";
        }

        $AdApplication = New-AzADApplication `
                            -DisplayName $AppName `
                            -SigninAudience "AzureADMyOrg" `
                            -AppRole $AppRoles `
                            -SPARedirectUri $mySpaApplication.RedirectUris `
                            -RequiredResourceAccess $RequiredResourcesAccessList
		

        #Write-Host -ForegroundColor Green "NEW APP REGISTRATION CREATED: AdApplication.AppId =" $AdApplication.AppId 
        $ExposeScope = CreateScope -ScopeObj $ScopeObj
		$DeployObject.APIAppRegName = $AdApplication.DisplayName
		$DeployObject.APIAppRegAppId = $AdApplication.AppId    
		$DeployObject.APIAppRegObjectId = $AdApplication.Id
        
        #Configure ApplicationId URI
        SetApplicationIdURI -AppId $DeployObject.APIAppRegAppId 

        #Create the Service Principal (Enterprise App)
        $SPN = CreateServicePrincipal -AppId $DeployObject.APIAppRegAppId -DeployObject $DeployObject
        #create a client secret key which will expire in two years.
		$appPassword = New-AzADAppCredential -ObjectId $DeployObject.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
		$PlaintextSecretTest = $appPassword.SecretText

        $DeployObject.APIAppRegServicePrincipalId = $SPN.Id
		$DeployObject.APIAppRegExists = $true
        $DeployObject.APIAppRegClientSecret = $PlaintextSecretTest
               
    }#if($DeployObject.Solution -eq "Transfer")

    else #PickUp
    {
        #No AppRole
        #Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureAPI[202] PickUp:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
        try{
            $AdApplication = New-AzADApplication `
                            -DisplayName $AppName `
                            -SigninAudience "AzureADMyOrg" `
                            -SPARedirectUri $mySpaApplication.RedirectUris `
                            -RequiredResourceAccess $RequiredResourcesAccessList
            
            #Write-Host -ForegroundColor Green "CreateAppRegistration.ConfigureAPI[196] NEW APP REG CREATED: " $AdApplication.DisplayName

            $DeployObject.APIAppRegName = $AdApplication.DisplayName
            $DeployObject.APIAppRegAppId = $AdApplication.AppId    
            $DeployObject.APIAppRegObjectId = $AdApplication.Id
        
            #Create the Service Principal (Enterprise App)
            $SPN = CreateServicePrincipal -AppId $DeployObject.APIAppRegAppId -DeployObject $DeployObject
            #create a client secret key which will expire in two years.
            $appPassword = New-AzADAppCredential -ObjectId $DeployObject.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
		    $PlaintextSecretTest = $appPassword.SecretText            

            $DeployObject.APIAppRegServicePrincipalId = $SPN.Id
            $DeployObject.APIAppRegExists = $true		
		    $DeployObject.APIAppRegClientSecret = $PlaintextSecretTest        
            
        }
        catch{
            Write-Host -ForegroundColor Red "error"
        }

        #Configure ApplicationId URI
        SetApplicationIdURI -AppId $DeployObject.APIAppRegAppId 

        $ScopeObj = [ordered]@{
                AppName = "$AppName";
                Value = "$AppName.Standard.Users";
                UserConsentDisplayName = "Permits use of $AppName";
                UserConsentDescription = "Permits use of $AppName" ;
                AdminConsentDisplayName= "Permits use of $AppName";
                AdminConsentDescription = "Permits use of $AppName"; 
                IsEnabled = $true ;
                Type = "Admin";
            }#ScopeObj
        $ExposeScope = CreateScope -ScopeObj $ScopeObj
        
    }#Pickup

    #Write-Host  -ForegroundColor Yellow  "CreateAppRegistration[262] DeployObject.APIAppRegAppId:" $DeployObject.APIAppRegAppId	
    
    "API App Registration Name:	" +	$AppName  >> $DeployInfo.LogFile
    "API App Registration ID:	" + $DeployObject.APIAppRegAppId  >> $DeployInfo.LogFile
    "API App Registration ObjectID:	" + $DeployObject.APIAppRegObjectId  >> $DeployInfo.LogFile
    "API App Registration Secret:	" + $PlaintextSecretTest  >> $DeployInfo.LogFile            
           
    #$DeployObject.APIAppRegServicePrincipalId = $SPN.Id
    #Write-Host  -ForegroundColor Yellow "CreateAppRegistration.ConfigureAPI[262] FINISHED Creating DeployObject.APIAppRegName:" $DeployObject.APIAppRegName
}#ConfigureAPI


Function global:ConfigureWebApp
{
    Param( 
        [Parameter(Mandatory = $true)] [String] $AppName
       ,[Parameter(Mandatory = $true)] [Object] $DeployObject
          )
    <#
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "CreateAppRegistration.ConfigureWebApp[266] STARTING CreateAppRegistration.ConfigureWebApp AppName= $AppName "    
    Write-Host -ForegroundColor Magenta -BackgroundColor Black "CreateAppRegistration.ConfigureWebApp[267] DeployObject.Solution=" $DeployObject.Solution
    Write-Host -ForegroundColor Magenta -BackgroundColor Black "CreateAppRegistration.ConfigureWebApp[268] DeployObject.APIAppRegName=" $DeployObject.APIAppRegName
    Write-Host -ForegroundColor Magenta -BackgroundColor Black "CreateAppRegistration.ConfigureWebApp[269] DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
    #>
	
    #API Permissions:
    #MS Graph Delegated Permissions: User.Read
    $GraphSP = Get-AzADServicePrincipal  | ? { $_.DisplayName -eq "Microsoft Graph" }
    $PermissionParentId = $GraphSP.AppId        
    $PermissionParentName = "Microsoft Graph"
    $RequiredDelegatedPermissionNames =
    @(
        "User.Read"
    )
    # Write-Host -ForegroundColor Yellow "CreateAppRegistration.[257] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $DeployObject.AppName"

    $GraphRequiredPermissions = AddAPIPermissions `
        -PermissionParentId $PermissionParentId `
        -PermissionParentName $PermissionParentName `
        -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames
    
    #API Permission for the API App:
	$APIAppRegName = $DeployObject.APIAppRegName
	#Write-Host -ForegroundColor Magenta "CreateAppRegistration.ConfigureWebApp[309] `$APIAppRegName=`"$APIAppRegName`""

	$PermissionPrincipal = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName"} 
	<#
	Write-Host "CreateAppRegistration.ConfigureWebApp[313] PermissionPrincipal.DisplayName=" $PermissionPrincipal.DisplayName
	Write-Host "CreateAppRegistration.ConfigureWebApp[314] PermissionPrincipal.AppId="$PermissionPrincipal.AppId
	Write-Host "CreateAppRegistration.ConfigureWebApp[315] PermissionPrincipal.Id=" $PermissionPrincipal.Id
	#>

    $PermissionName = $DeployObject.APIAppRegName + ".Standard.Users"    
	$PermissionParentName = $PermissionPrincipal.DisplayName
	$PermissionParentId = $PermissionPrincipal.AppId
	$RequiredDelegatedPermissionNames =
	@(
		"$PermissionName"
	)
    <#
    Write-Host -ForegroundColor Yellow "CreateAppRegistration.ConfigureWebApp[326] PermissionName =" $PermissionName    
    Write-Host -ForegroundColor Yellow "CreateAppRegistration.ConfigureWebApp[327] PermissionParentName=" $PermissionPrincipal.DisplayName
	Write-Host -ForegroundColor Yellow "CreateAppRegistration.ConfigureWebApp[328] PermissionParentId="$PermissionPrincipal.AppId
	Write-Host -ForegroundColor Yellow "CreateAppRegistration.ConfigureWebApp[329] PermissionPrincipal.Id=" $PermissionPrincipal.Id
	#>
	#Write-Host -ForegroundColor Yellow "CreateAppRegistration.[317] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $DeployObject.AppName"
        
	$RequiredPermissions = AddAPIPermissions `
		-PermissionParentId $PermissionParentId `
		-PermissionParentName $PermissionParentName `
		-RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        
    $RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
	$RequiredResourcesAccessList.Add($GraphRequiredPermissions)
    $RequiredResourcesAccessList.Add($RequiredPermissions)

    #Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureWebApp[316] :: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
    $redirectUris += "http://localhost:3000"
    $mySpaApplication.RedirectUris = $redirectUris        

    if($DeployObject.Solution -eq "Transfer")
    {   
        
        #API Permissions:
        #Azure Storage:
        $PermissionParentId = "e406a681-f3d4-42a8-90b6-c2b029497af1"
        $PermissionParentName = "Azure Storage"
        $RequiredDelegatedPermissionNames =
        @(
            "user_impersonation"
        )
        
        $AzStoragePermissions = AddAPIPermissions `
            -PermissionParentName $PermissionParentName `
            -PermissionParentId $PermissionParentId `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames
        
        $RequiredResourcesAccessList.Add($AzStoragePermissions)
        
        #Write-Host -ForegroundColor Yellow "CreateAppRegistration.ConfigureWebApp[338] FINISHED AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $DeployObject.AppName"
        #Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureWebApp[343] Transfer:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count

        #App Roles
        #Create the App Roles at the time of creation
        $AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]         
        <#
        $newAppRole = CreateAppRole `
            -DisplayName  "$AppName Admins" `
            -Description "Admin enabled users of the $AppName web application" `
            -Value "$AppName.Admins" `
            -AllowedMemberTypes "User"
            #>
        $newAppRole = CreateAppRole `
            -DisplayName  "$AppName Admins" `
            -Description "Admin enabled users of the $AppName web application" `
            -Value "DTP.Admins" `
            -AllowedMemberTypes "User"
    
        $AppRoles += $newAppRole
        #Write-Host -ForegroundColor Green "CreateAppRegistration.ConfigureWebApp[350] newAppRole.DisplayName= " $newAppRole.DisplayName

        <#$newAppRole = CreateAppRole `
            -DisplayName  "$AppName Users" `
            -Description "Normal users of the $AppName web application" `
            -Value "$AppName.Users" `
            -AllowedMemberTypes "User"
          #>  
        $newAppRole = CreateAppRole `
            -DisplayName  "$AppName Users" `
            -Description "Normal users of the $AppName web application" `
            -Value "DTP.Users" `
            -AllowedMemberTypes "User"
        $AppRoles += $newAppRole			
        
		<#
        Write-Host -ForegroundColor Green "CreateAppRegistration.ConfigureWebApp[361] AppRoles.Count= " $AppRoles.Count
        Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureWebApp[362] Transfer:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
        Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[362] Create the App Registration " $AppName
		#>
        #Create the App Registration
        #Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureWebApp[362] Transfer:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
        $AdApplication = New-AzADApplication `
            -DisplayName $AppName `
            -SigninAudience "AzureADMyOrg" `
            -AppRole $AppRoles `
            -SPARedirectUri $mySpaApplication.RedirectUris `
            -RequiredResourceAccess $RequiredResourcesAccessList
        
        <#
        Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[374] Created the TRANSFER CLIENT App Registration " $AppName       
        $DeployObject.ClientAppRegName = $AppName
    	$DeployObject.ClientAppRegAppId = $AdApplication.AppId            
	    $DeployObject.ClientAppRegObjectId = $AdApplication.Id
        #>
		<#
        Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[377] DeployObject.ClientAppRegName =" $DeployObject.ClientAppRegName
        Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[378] DeployObject.ClientAppRegAppId =" $DeployObject.ClientAppRegAppId
        Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[379] DeployObject.ClientAppRegObjectId =" $DeployObject.ClientAppRegObjectId
		#>
        #Configure ApplicationId URI
        #SetApplicationIdURI -AppId $DeployObject.ClientAppRegAppId 
        <#
        $SPN = CreateServicePrincipal -AppId $DeployObject.ClientAppRegAppId -DeployObject $DeployObject
        
	    $DeployObject.ClientAppRegExists = $true		
		$DeployObject.ClientAppRegServicePrincipalId = $SPN.Id
        #>
			
    }#$DeployObject.Solution -eq "Transfer"
    else #Pickup
    {
        
        #Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureWebApp[403] Pickup:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
        #No Secrets
        #No App Roles for Pickup
        #No Expose an API for PickUp
        #No Application ID URI
        #No Scopes defined by this API
        #Create the App Registration
	    $AdApplication = New-AzADApplication `
		    -DisplayName $AppName `
		    -SigninAudience "AzureADMyOrg" `
            -SPARedirectUri $mySpaApplication.RedirectUris `
		    -RequiredResourceAccess $RequiredResourcesAccessList
    
        #Write-Host -ForegroundColor Green "CreateAppRegistration.ConfigureWebApp[408] NEW PICKUP CLIENT APP REG CREATED: " $AdApplication.DisplayName

        <#$DeployObject.ClientAppRegName = $AppName
		$DeployObject.ClientAppRegAppId = $AdApplication.AppId  
		$DeployObject.ClientAppRegObjectId = $AdApplication.Id

        $SPN = CreateServicePrincipal -AppId $DeployObject.ClientAppRegAppId -DeployObject $DeployObject

        $DeployObject.ClientAppRegServicePrincipalId = $SPN.Id
		$DeployObject.ClientAppRegExists = $true       
        #>
		
    }#Pickup	
	  
    $DeployObject.ClientAppRegName = $AppName
    $DeployObject.ClientAppRegAppId = $AdApplication.AppId            
	$DeployObject.ClientAppRegObjectId = $AdApplication.Id
    $SPN = CreateServicePrincipal -AppId $DeployObject.ClientAppRegAppId -DeployObject $DeployObject
        
	$DeployObject.ClientAppRegExists = $true		
	$DeployObject.ClientAppRegServicePrincipalId = $SPN.Id   
    #Write-Host "CreateAppRegistration[461] AdApplication created: ClientAppRegName =" $DeployObject.ClientAppRegName "; " $DeployObject.ClientAppRegAppId

    #Set app reg manifest's accessTokenAcceptedVersion=2
    #$uri = "https://graph.microsoft.com/v1.0/applications/<app objectId>"
    #az rest --method PATCH --uri '$uri' --headers 'Content-Type=application/json' --body '{\""api\"":{\""requestedAccessTokenVersion\"":2}}'
    
		
	#Write-Host -ForegroundColor Cyan  -BackgroundColor Black "[120] WebClient: " $AdApplication.DisplayName
	"WebSite App Registration Name:	" +	$DeployObject.AppName  >> $DeployInfo.LogFile
	"WebSite App Registration ClientAppRegAppId:	" + $DeployObject.ClientAppRegAppId  >> $DeployInfo.LogFile
	"WebSite App Registration ClientAppRegObjectId:	" + $DeployObject.ClientAppRegObjectId  >> $DeployInfo.LogFile           		            
            			

}#ConfigureWebApp