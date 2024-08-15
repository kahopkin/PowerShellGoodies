#CreateAppRegistration

Function global:CreateAppRegistration
{
	Param(
		[Parameter(Mandatory = $true)] [String] $AppName
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
 
	$SolutionObjName = $DeployObject.SolutionObjName
	"================================================================================"	>> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": CREATING APP REGISTRATION: " + $AppName			>> $DeployObject.LogFile
	"================================================================================"	>> $DeployObject.LogFile

	Write-Host -ForegroundColor Green "================================================================================"
	Write-Host -ForegroundColor Green "Step" $DeployObject.StepCount": CREATING APP REGISTRATION: "$AppName
	Write-Host -ForegroundColor Green "================================================================================"
	$DeployObject.StepCount++

	$AdApplication = Get-AzADApplication -DisplayName $AppName
	$nameLength = ($AdApplication.DisplayName.Length)

	$psCommand = "`$AdApplication = `n`t`t" +
							"Get-AzADApplication  ```n`t`t" +
								"-DisplayName `"" + $AppName + "`"`n"   
	# 
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateAppRegistration.CreateAppRegistration[35]:"
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #> 

	#depending on the name, the app registrations need different configurations.
	#API app registration 
	$WebAppUrl = "https://" + $AppName + "." + $DeployObject.WebDomain

	<#
	If($debugFlag){
		$Caller ='CreateAppRegistration[39] BEFORE Param:AppRegObj'
		Write-Host -ForegroundColor Cyan $Caller "`$WebAppUrl= `"$WebAppUrl`""
			PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#debugFlag #>

	$redirectUris = @()

	if ($redirectUris -notcontains "$WebAppUrl") {
		$redirectUris += "$WebAppUrl"
	}

	$global:mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
	$mySpaApplication.RedirectUris = $redirectUris

	#create a new Azure Active Directory App Reg
	if (($AdApplication.DisplayName.Length).Equals(0))
	{
		$APIAppRegName = $AdApplication.DisplayName
			$AppId = $AdApplication.AppId 

		If($debugFlag){
			 Write-Host -ForegroundColor Magenta "CreateAppRegistration[68] APP REG DOES NOT EXISTS::"
			 Write-Host -ForegroundColor Yellow "AppName=" $AppName
			Write-Host -ForegroundColor Yellow "AppId=" $AppId
		}#debugFlag #>

		#Create the API APP REGISTRATION and Service Principal:
		if ($AppName -match 'api')
		{
			If($debugFlag){
				 Write-Host -ForegroundColor Magenta "CreateAppRegistration[77] Create the FUNCTION APP REGISTRATION :: BEFORE ConfigureAPI" 
				Write-Host -ForegroundColor Green "Start ConfigureAPI: AppName=" $AppName
			}
			#Write-Host -ForegroundColor Green "CreateAppRegistration[73] start ConfigureAPI: AppName=" $AppName
			$DeployObject = ConfigureAPI -AppName $AppName -DeployObject $DeployObject
			}
		#Create the CLIENT APP REGISTRATION
		else
		{ 
			If($debugFlag){
				 Write-Host -ForegroundColor Magenta "CreateAppRegistration[86] Create the CLIENT APP REGISTRATION :: BEFORE ConfigureWebApp" 
				Write-Host -ForegroundColor Green "Start ConfigureWebApp: AppName=" $AppName
			}

			 $DeployObject = ConfigureWebApp -AppName $AppName -DeployObject $DeployObject
		}#else: Create CLIENT APP REGISTRATION

	} #app reg does not exist
	#EXISTING APP REGISTRATION
	else
	{
		$AppRegName = $AdApplication.DisplayName
			$AppId = $AdApplication.AppId 

			If($AppName -match 'api')
		{
			 $DeployObject.APIAppRegName = $AdApplication.DisplayName
			 $DeployObject.APIAppRegAppId = $AdApplication.AppId
			 $DeployObject.APIAppRegObjectId = $AdApplication.Id

			$SPN = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$AppRegName" -and $_.AppId -eq "$AppId"}

			 $psCommand = "`$SPN = `n`t`Get-AzADServicePrincipal  ```n`t`t" + 
									" | Where-Object {`$_.DisplayName -eq `"" + $AppRegName + "`" -and `$_.AppId -eq `"" + $AppId + "`"}"
			#
			 If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "CreateAppRegistration.CreateAppRegistration[105]:" 
				Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
			}#If($PrintPSCommands) #>

			$DeployObject.APIAppRegServicePrincipalId = $SPN.Id

			 #
			If($debugFlag)
			{
				 Write-Host -ForegroundColor Red "CreateAppRegistration[115] API APP REG EXISTS::"
				 Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegName=" $DeployObject.APIAppRegName
				Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegAppId=" $DeployObject.APIAppRegAppId
				Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegObjectId=" $DeployObject.APIAppRegObjectId
				Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegServicePrincipalId=" $DeployObject.APIAppRegServicePrincipalId
			}#debugFlag #>
		}#If($AppName -match 'api')
			Else
		{
			$DeployObject.ClientAppRegName = $AdApplication.DisplayName
				$DeployObject.ClientAppRegAppId = $AdApplication.AppId
				$DeployObject.ClientAppRegObjectId = $AdApplication.Id
			$SPN = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$AppRegName" -and $_.AppId -eq "$AppId"}
			$psCommand = "`$SPN = `n`t`Get-AzADServicePrincipal  ```n`t`t" + 
									" | Where-Object {`$_.DisplayName -eq `"" + $AppRegName + "`" -and `$_.AppId -eq `"" + $AppId + "`"}" 
			 #
			 If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "CreateAppRegistration.CreateAppRegistration[132]:" 
				Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
			}#If($PrintPSCommands) #>

			$DeployObject.ClientAppRegServicePrincipalId = $SPN.Id

			#
			If($debugFlag)
			{
				Write-Host -ForegroundColor Red "CreateAppRegistration[142] CLIENT APP REG EXISTS::"
				 Write-Host -ForegroundColor Yellow "DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
				Write-Host -ForegroundColor Yellow "DeployObject.ClientAppRegAppId=" $DeployObject.ClientAppRegAppId
				Write-Host -ForegroundColor Yellow "DeployObject.ClientAppRegObjectId=" $DeployObject.ClientAppRegObjectId
				Write-Host -ForegroundColor Yellow "DeployObject.ClientAppRegServicePrincipalId=" $DeployObject.ClientAppRegServicePrincipalId
			}#debugFlag #>
		}#else: Create CLIENT APP REGISTRATION
	}#existing app registration

	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Green "`t`t`tFINISHED CREATING APP REGISTRATION: "$AppName
	Write-Host -ForegroundColor Cyan "================================================================================"

	WriteJsonFile -FilePath $DeployObject.OutFileJSON -CustomObject $DeployObject
} #end of func CreateAppRegistration

Function global:ConfigureAPI
{
	Param(
		[Parameter(Mandatory = $true)] [String] $AppName 
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag){
		$Caller = "CreateAppRegistration.ConfigureAPI[166]" + $AppName
		Write-Host -ForegroundColor Cyan $Caller
		#PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#debugFlag #>
 
	$SolutionObjName = $DeployObject.SolutionObjName
	$WebAppUrl = "https://" + $AppName + "." + $DeployObject.WebDomain
	$redirectUris = @()

	if ($redirectUris -notcontains "$WebAppUrl") {
		$redirectUris += "$WebAppUrl"
	}

	$global:mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
	$mySpaApplication.RedirectUris = $redirectUris
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

	If($debugFlag){
		Write-Host -ForegroundColor Magenta -BackgroundColor Black  "CreateAppRegistration.ConfigureAPI[184] STARTING CreateAppRegistration.ConfigureAPI AppName= $AppName "
		Write-Host -ForegroundColor Yellow -BackgroundColor Black  "DeployObject.Solution=" $DeployObject.Solution
	}#debugFlag #>

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

	Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[201] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $DeployObject.AppName"

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

	$GraphRequiredPermissions = AddAPIPermissions `
		-PermissionParentName $PermissionParentName `
		-PermissionParentId $PermissionParentId `
		-RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

	$RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
	$RequiredResourcesAccessList.Add($RequiredPermissions)
	$RequiredResourcesAccessList.Add($GraphRequiredPermissions)

	if($DeployObject.Solution -eq "Transfer")
	{
		Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureAPI[230] Transfer:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
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
			-DisplayName  "DTP API Admins" `
			-Value "DTPAPI.Admins"
		$AppRoles += $newAppRole
		Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureAPI[245] newAppRole.DisplayName= " $newAppRole.DisplayName
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
			-DisplayName  "DTP API Users" `
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
		$DeployObject.APIAppRegSecret = $PlaintextSecretTest
	}#if($DeployObject.Solution -eq "Transfer")


	"API App Registration Name:	" +	$AppName  >> $DeployObject.LogFile
	"API App Registration ID:	" + $DeployObject.APIAppRegAppId  >> $DeployObject.LogFile
	"API App Registration ObjectID:	" + $DeployObject.APIAppRegObjectId  >> $DeployObject.LogFile
	"API App Registration Secret:	" + $PlaintextSecretTest  >> $DeployObject.LogFile
	
	WriteJsonFile -FilePath $DeployObject.OutFileJSON -CustomObject $DeployObject
	return $DeployObject
}#ConfigureAPI


Function global:ConfigureWebApp
{
	Param(
		[Parameter(Mandatory = $true)] [String] $AppName
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag){
		$Caller = "CreateAppRegistration.ConfigureWebApp[362] " + $AppName
		Write-Host -ForegroundColor Cyan $Caller
		#PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#debugFlag #>

	$SolutionObjName = $DeployObject.SolutionObjName
	 If($debugFlag){
			Write-Host -ForegroundColor Magenta  "`nCreateAppRegistration.ConfigureWebApp[400] STARTING CreateAppRegistration.ConfigureWebApp "
		Write-Host -ForegroundColor Cyan "AppName= $AppName "
		Write-Host -ForegroundColor Cyan "DeployObject.Solution=" $DeployObject.Solution
		Write-Host -ForegroundColor Cyan "`$DeployObject.APIAppRegName=" $DeployObject.APIAppRegName
		Write-Host -ForegroundColor Cyan "`$DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName 
	} #If($debugFlag) #>

	$WebAppUrl = "https://" + $AppName + "." + $DeployObject.WebDomain
	$redirectUris = @()

	if ($redirectUris -notcontains "$WebAppUrl") {
		$redirectUris += "$WebAppUrl"
	}

	$global:mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
	$mySpaApplication.RedirectUris = $redirectUris

	#API Permissions:
	#MS Graph Delegated Permissions: User.Read
	$GraphSP = Get-AzADServicePrincipal  | ? { $_.DisplayName -eq "Microsoft Graph" }
	$PermissionParentId = $GraphSP.AppId 
	$PermissionParentName = "Microsoft Graph"
	$RequiredDelegatedPermissionNames =
	@(
		"User.Read"
	)

	$GraphRequiredPermissions = AddAPIPermissions `
		-PermissionParentId $PermissionParentId `
		-PermissionParentName $PermissionParentName `
		-RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

	#API Permission for the API App:
	$APIAppRegName = $DeployObject.APIAppRegName
	Write-Host -ForegroundColor Cyan "`$APIAppRegName= `"$APIAppRegName`""
	$PermissionPrincipal = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$APIAppRegName"}

	$psCommand = "`$PermissionPrincipal = `n`tGet-AzADServicePrincipal  | Where-Object {`$_.DisplayName -eq `"$APIAppRegName`"} `n`t`t"
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateAppRegistration.ConfigureWebApp[410]:" 
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>

	$PermissionName = $DeployObject.APIAppRegName + ".Standard.Users"

	If($PermissionPrincipal.Count -eq 1)
	{
		$PermissionParentName = $PermissionPrincipal.DisplayName
		$PermissionParentId = $PermissionPrincipal.AppId
	}
	Else
	{
		$PermissionParentName = $PermissionPrincipal[$PermissionPrincipal.Count-1].DisplayName
		$PermissionParentId = $PermissionPrincipal[$PermissionPrincipal.Count-1].AppId
	}

	$RequiredDelegatedPermissionNames =
	@(
		"$PermissionName"
	)

	#
	If($debugFlag)
	{
		Write-Host -ForegroundColor Yellow "CreateAppRegistration.ConfigureWebApp[425] `nPermissionName =" $PermissionName
		Write-Host -ForegroundColor Yellow "PermissionParentName=" $PermissionParentName
		Write-Host -ForegroundColor Yellow "PermissionParentId=" $PermissionParentId
		Write-Host -ForegroundColor Yellow "PermissionPrincipal.Id=" $PermissionPrincipal.Id
	}#debugFlag #>

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
			-DisplayName  "DTP Admins" `
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
			-DisplayName  "DTP Users" `
			-Description "Normal users of the $AppName web application" `
			-Value "DTP.Users" `
			-AllowedMemberTypes "User"
		$AppRoles += $newAppRole

		#
		If($debugFlag){
		Write-Host -ForegroundColor Green "CreateAppRegistration.ConfigureWebApp[361] AppRoles.Count= " $AppRoles.Count
		Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureWebApp[362] Transfer:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
		Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[362] Create the App Registration " $AppName
		}#debugFlag #>
		#Create the App Registration
		#Write-Host -ForegroundColor White "CreateAppRegistration.ConfigureWebApp[362] Transfer:: RequiredResourcesAccessList.Count=" $RequiredResourcesAccessList.Count
		$AdApplication = New-AzADApplication `
			-DisplayName $AppName `
			-SigninAudience "AzureADMyOrg" `
			-AppRole $AppRoles `
			-SPARedirectUri $mySpaApplication.RedirectUris `
			-RequiredResourceAccess $RequiredResourcesAccessList

			#
		If($debugFlag){
		Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[374] Created the TRANSFER CLIENT App Registration " $AppName
			$DeployObject.ClientAppRegName = $AppName
		$DeployObject.ClientAppRegAppId = $AdApplication.AppId
			$DeployObject.ClientAppRegObjectId = $AdApplication.Id
		Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[377] DeployObject.ClientAppRegName =" $DeployObject.ClientAppRegName
		Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[378] DeployObject.ClientAppRegAppId =" $DeployObject.ClientAppRegAppId
		Write-Host -ForegroundColor Cyan "CreateAppRegistration.ConfigureWebApp[379] DeployObject.ClientAppRegObjectId =" $DeployObject.ClientAppRegObjectId
		}#debugFlag #>
		#Configure ApplicationId URI
		#SetApplicationIdURI -AppId $DeployObject.ClientAppRegAppId
		<#
		$SPN = CreateServicePrincipal -AppId $DeployObject.ClientAppRegAppId -DeployObject $DeployObject

			$DeployObject.ClientAppRegExists = $true
		$DeployObject.ClientAppRegServicePrincipalId = $SPN.Id
		#>

	}#$DeployObject.Solution -eq "Transfer"
	

	$DeployObject.ClientAppRegName = $AdApplication.DisplayName
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
	"WebSite App Registration Name:	" +	$DeployObject.AppName  >> $DeployObject.LogFile
	"WebSite App Registration ClientAppRegAppId:	" + $DeployObject.ClientAppRegAppId  >> $DeployObject.LogFile
	"WebSite App Registration ClientAppRegObjectId:	" + $DeployObject.ClientAppRegObjectId  >> $DeployObject.LogFile					
	
	If($debugFlag){
		Write-Host -ForegroundColor Magenta  "`nCreateAppRegistration.ConfigureWebApp[585] CreateAppRegistration.ConfigureWebApp"
		Write-Host -ForegroundColor Green "DeployObject.Solution=" $DeployObject.Solution
		Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
			Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegAppId=" $DeployObject.ClientAppRegAppId
			Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegObjectId=" $DeployObject.ClientAppRegObjectId
			Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegServicePrincipalId=" $DeployObject.ClientAppRegServicePrincipalId 
	} #If($debugFlag) #>
	WriteJsonFile -FilePath $DeployObject.OutFileJSON -CustomObject $DeployObject 
	#return $DeployObject
}#ConfigureWebApp