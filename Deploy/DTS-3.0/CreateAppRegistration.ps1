#CreateAppRegistration

Function global:CreateAppRegistration
{
	Param(
		[Parameter(Mandatory = $true)] [String] $AppName
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	$Message = "CREATING APP REGISTRATION: " + $AppName
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateAppRegistration.CreateAppRegistration[17]"
		Write-Host -ForegroundColor White "`$AppName=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$AppName`""
	}
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black $Message
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

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

	#this will be used to update the app registration manifest's 'accessTokenAcceptedVersion' property to equal 2
	$global:myGraphApiApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphApiApplication
	$myGraphApiApplication.RequestedAccessTokenVersion = 2

	#depending on the name, the app registrations need different configurations.
	#API app registration
	$WebAppUrl = "https://" + $AppName + "." + $DeployObject.WebDomain
	$redirectUris = @()
	<#
	If($debugFlag){
		$Caller = 'CreateAppRegistration[56]'
		Write-Host -ForegroundColor Cyan "`$WebAppUrl= `"$WebAppUrl`""
		#PrintObject -Object $DeployObject -Caller $Caller
		$ObjectName = "DeployObject"
		$Caller = "CreateAppRegistration[60] " + $ObjectName
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#>
	If ($redirectUris -notcontains "$WebAppUrl") {
		$redirectUris += "$WebAppUrl"
	}

	$global:mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
	$mySpaApplication.RedirectUris = $redirectUris

	#create a new Azure Active Directory App Reg
	If (($AdApplication.DisplayName.Length).Equals(0))
	{
		#Create the API APP REGISTRATION and Service Principal:
		If ($AppName -match 'api')
		{
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "CreateAppRegistration[78] Create the FUNCTION APP REGISTRATION :: BEFORE ConfigureAPI"
				Write-Host -ForegroundColor Green "Calling ConfigureAPI: AppName=" $AppName
			}
			$DeployObject = ConfigureAPI -AppName $AppName -DeployObject $DeployObject
		}
		#Create the CLIENT APP REGISTRATION
		Else
		{
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "CreateAppRegistration[87] Create the CLIENT APP REGISTRATION :: BEFORE ConfigureWebApp"
				Write-Host -ForegroundColor Green "Calling ConfigureWebApp: AppName=" $AppName
			}
			$DeployObject = ConfigureWebApp -AppName $AppName -DeployObject $DeployObject
		}#Else: Create CLIENT APP REGISTRATION
	} #app reg does not exist
	#EXISTING APP REGISTRATION
	 Else
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
				Write-Host -ForegroundColor Red "CreateAppRegistration[110] API APP REG EXISTS::"
				Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegName=" $DeployObject.APIAppRegName
				Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegAppId=" $DeployObject.APIAppRegAppId
				Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegObjectId=" $DeployObject.APIAppRegObjectId
				Write-Host -ForegroundColor Cyan "DeployObject.APIAppRegSecret=" $DeployObject.APIAppRegSecret
				Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegServicePrincipalId=" $DeployObject.APIAppRegServicePrincipalId
			}#debugFlag #>
			$Message = "App registration: " + $DeployObject.APIAppRegName + " exists, continuing deployment..."
			Write-Host -ForegroundColor Green -BackgroundColor Black $Message
		}#If($AppName -match 'api')
		Else #Client
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

			#$DeployObject.$SolutionObjName.ClientAppRegServicePrincipalId = $SPN.Id
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

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black "`t`t`tFINISHED CREATING APP REGISTRATION: "$AppName
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
}#end of func CreateAppRegistration

Function global:ConfigureAPI
{
	Param(
		[Parameter(Mandatory = $true)] [String] $AppName
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	$Message = "CONFIGURING THE API APP REGISTRATION: " + $AppName
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateAppRegistration.ConfigureAPI[175]"
		Write-Host -ForegroundColor White "`$AppName=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$AppName`""
	}
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$WebAppUrl = "https://" + $AppName + "." + $DeployObject.WebDomain
	$redirectUris = @()

	if ($redirectUris -notcontains "$WebAppUrl") {
		$redirectUris += "$WebAppUrl"
	}

	$global:mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
	$mySpaApplication.RedirectUris = $redirectUris

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

	$RequiredPermissions = AddAPIPermissions `
		-PermissionParentName $PermissionParentName `
		-PermissionParentId $PermissionParentId `
		-RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

	#API Permissions:
	#MS Graph Delegated Permissions:
	$GraphSP = Get-AzADServicePrincipal  | ? { $_.DisplayName -eq "Microsoft Graph" }
	$PermissionParentId = $GraphSP.AppId
	$PermissionParentName = "Microsoft Graph"
	$RequiredDelegatedPermissionNames =
	@(
		"User.Read"
		"User.Read.All"
		"Directory.Read.All"
	)

	$GraphRequiredPermissions = AddAPIPermissions `
		-PermissionParentName $PermissionParentName `
		-PermissionParentId $PermissionParentId `
		-RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

	$RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
	$RequiredResourcesAccessList.Add($RequiredPermissions)
	$RequiredResourcesAccessList.Add($GraphRequiredPermissions)

	$newAppRole = CreateAppRole `
		-AllowedMemberTypes "User" `
		-Description "Admin users of the $AppName API" `
		-DisplayName  "DTP API Admins" `
		-Value "DTPAPI.Admins"

	$AppRoles += $newAppRole

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
						-Api $myGraphApiApplication `
						-RequiredResourceAccess $RequiredResourcesAccessList

	$psCommand = "`$AdApplication = `n`t`t" +
					"New-AzADApplication  ```n`t`t" +
						"-DisplayName `"" +  $AppName + "`"```n`t`t" +
						"-SigninAudience `"AzureADMyOrg`" ```n`t`t" +
						"-AppRole `$AppRoles ```n`t`t" +
						"-SPARedirectUri `$mySpaApplication.RedirectUris ```n`t`t" +
						"-Api `$myGraphApiApplication ```n`t`t" +
						"-RequiredResourceAccess `$RequiredResourcesAccessList `` `n"
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateAppRegistration.ConfigureAPI[268]:"
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #>

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
	$APIAppRegSecretAsPlainText = $appPassword.SecretText
	$DeployObject.APIAppRegServicePrincipalId = $SPN.Id
	$DeployObject.APIAppRegExists = $true
	$DeployObject.APIAppRegSecret = $APIAppRegSecretAsPlainText
	$DeployObject.APIAppRegSecretAsPlainText = $APIAppRegSecretAsPlainText

	#Update the app registration manifest's 'accessTokenAcceptedVersion' property to equal 2
	$AdApplication = Update-AzADApplication -ObjectId $DeployObject.APIAppRegObjectId -Api $myGraphApiApplication

	$psCommand = "`$AdApplication = `n`Update-AzADApplication  ```n`t`t" +
						"-ObjectId `"" + $DeployObject.APIAppRegObjectId + "`"```n`t`t" +
						"-Api `$myGraphApiApplication `` `n"

	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateAppRegistration.ConfigureAPI[300]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>

	"API App Registration Name:	" +	$AppName	>> $DeployObject.LogFile
	"API App Registration ID:	" + $DeployObject.APIAppRegAppId	>> $DeployObject.LogFile
	"API App Registration ObjectID:	" + $DeployObject.APIAppRegObjectId >> $DeployObject.LogFile
	"API App Registration Secret:	" + $PlaintextSecretTest >> $DeployObject.LogFile

	return $DeployObject
}#ConfigureAPI


Function global:ConfigureWebApp
{
	Param(
		[Parameter(Mandatory = $true)] [String] $AppName
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	$Message = ": CONFIGURING THE CLIENT APP REGISTRATION: " + $AppName
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateAppRegistration.ConfigureWebApp[327]"
	}
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile


	 If($debugFlag){
		#$Caller ='CreateAppRegistration.ConfigureWebApp[330]'
		#PrintObject -Object $DeployObject -Caller $Caller
		Write-Host -ForegroundColor Magenta  "`n CreateAppRegistration.ConfigureWebApp[336] STARTING CreateAppRegistration.ConfigureWebApp "
		Write-Host -ForegroundColor White "`$AppName=" -NoNewline
		Write-Host -ForegroundColor Yellow "`"$AppName`""
		Write-Host -ForegroundColor White "`$DeployObject.APIAppRegName=" -NoNewline
		Write-Host -ForegroundColor Yellow $DeployObject.APIAppRegName
		Write-Host -ForegroundColor White "`$DeployObject.ClientAppRegName=" -NoNewline
		Write-Host -ForegroundColor Yellow  $DeployObject.ClientAppRegName
	} #If($debugFlag) #>

	$WebAppUrl = "https://" + $AppName + "." + $DeployObject.WebDomain
	$redirectUris = @()

	if ($redirectUris -notcontains "$WebAppUrl")
	{
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
	$AppRegName = $DeployObject.APIAppRegName
	$ApiAppId = $DeployObject.APIAppRegAppId
	<#
	$PermissionPrincipal = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$AppRegName"}
	$psCommand = "`$PermissionPrincipal = `n`tGet-AzADServicePrincipal  | Where-Object {`$_.DisplayName -eq `"$AppRegName`"} `n`t`t"
	#>
	#$PermissionPrincipal = Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "$AppRegName"}
	$PermissionPrincipal = Get-AzADServicePrincipal | Where-Object {$_.AppId -eq "$ApiAppId"}
	$psCommand = "`$PermissionPrincipal = `n`tGet-AzADServicePrincipal  | Where-Object {`$_.DisplayName -eq `"$AppRegName`"} `n`t`t"
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateAppRegistration.ConfigureWebApp[390]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>

	#$PermissionName = $DeployObject.$SolutionObjName.APIAppRegName + ".Standard.Users"
	$PermissionName = $DeployObject.APIAppRegName + ".Standard.Users"

	If($PermissionPrincipal.Count -eq 1)
	{
		$PermissionParentName = $PermissionPrincipal.DisplayName
		$PermissionParentId = $PermissionPrincipal.AppId
	}#If($PermissionPrincipal.Count -eq 1)
	Else
	{
		$PermissionParentName = $PermissionPrincipal[$PermissionPrincipal.Count-1].DisplayName
		$PermissionParentId = $PermissionPrincipal[$PermissionPrincipal.Count-1].AppId
	}#ElseIf($PermissionPrincipal.Count -eq 1)

	$RequiredDelegatedPermissionNames =
	@(
		"$PermissionName"
	)

	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "CreateAppRegistration.ConfigureWebApp[412]"
		Write-Host -ForegroundColor Green "`$APIAppRegName=`"$APIAppRegName`""
		Write-Host -ForegroundColor Green "`$ApiAppId=`"$ApiAppId`""
		Write-Host -ForegroundColor Yellow "`$PermissionName=`"$PermissionName`""
		Write-Host -ForegroundColor Yellow "`$PermissionParentName=`"$PermissionParentName`""
		Write-Host -ForegroundColor Yellow "`$PermissionParentId=`"$PermissionParentId`""
		$PermissionPrincipalId  = $PermissionPrincipal.Id
		Write-Host -ForegroundColor Yellow "`$PermissionPrincipalId=`"$PermissionPrincipalId`""
	}#If($debugFlag)#>

	$RequiredPermissions = AddAPIPermissions `
		-PermissionParentId $PermissionParentId `
		-PermissionParentName $PermissionParentName `
		-RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

	$RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
	$RequiredResourcesAccessList.Add($GraphRequiredPermissions)
	$RequiredResourcesAccessList.Add($RequiredPermissions)


	$redirectUris += "http://localhost:3000"
	$mySpaApplication.RedirectUris = $redirectUris

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

	<#
	$newAppRole = CreateAppRole `
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

	#Create the App Registration:

	$AdApplication = New-AzADApplication `
		-DisplayName $AppName `
		-SigninAudience "AzureADMyOrg" `
		-AppRole $AppRoles `
		-SPARedirectUri $mySpaApplication.RedirectUris `
		-Api $myGraphApiApplication `
		-RequiredResourceAccess $RequiredResourcesAccessList

	$psCommand = "`$AdApplication = `n`t`t" +
						"New-AzADApplication  ```n`t`t" +
							"-DisplayName `"" +  $AppName + "`"```n`t`t" +
							"-SigninAudience `"AzureADMyOrg`" ```n`t`t" +
							"-AppRole `$AppRoles ```n`t`t" +
							"-SPARedirectUri `$mySpaApplication.RedirectUris ```n`t`t" +
							"-Api `$myGraphApiApplication ```n`t`t" +
							"-RequiredResourceAccess `$RequiredResourcesAccessList `` `n"
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateAppRegistration.ConfigureWebApp[494]:"
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #>

	$DeployObject.ClientAppRegExists = $true
	$DeployObject.ClientAppRegName = $AdApplication.DisplayName
	$DeployObject.ClientAppRegAppId = $AdApplication.AppId
	$DeployObject.ClientAppRegObjectId = $AdApplication.Id

	#Configure ApplicationId URI
	SetApplicationIdURI -AppId $DeployObject.ClientAppRegAppId


	$SPN = CreateServicePrincipal -AppId $DeployObject.ClientAppRegAppId -DeployObject $DeployObject
	$DeployObject.ClientAppRegServicePrincipalId = $SPN.Id

	#Update the app registration manifest's 'accessTokenAcceptedVersion' property to equal 2
	Update-AzADApplication -ObjectId $DeployObject.ClientAppRegObjectId -Api $myGraphApiApplication

	$psCommand = "`$AdApplication = `n`Update-AzADApplication  ```n`t`t" +
					"-ObjectId `"" + $DeployObject.ClientAppRegObjectId + "`"```n`t`t" +
					"-Api `$myGraphApiApplication `` `n"

	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateAppRegistration.ConfigureAPI[300]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>

	"WebSite App Registration Name:	" +	$DeployObject.AppName  								>> $DeployObject.LogFile
	"WebSite App Registration ClientAppRegAppId:	" + $DeployObject.ClientAppRegAppId  	>> $DeployObject.LogFile
	"WebSite App Registration ClientAppRegObjectId:	" + $DeployObject.ClientAppRegObjectId  >> $DeployObject.LogFile
	#return $DeployObject
}#ConfigureWebApp