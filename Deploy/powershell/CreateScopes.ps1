#CreateScopes
Function global:CreateScope
{
	param
	(
			[Parameter(Mandatory = $true)] [object]$ScopeObj
	)

	$Message = "CREATING APP SCOPE: " + $ScopeObj.Value
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateScopes.CreateScope[13]"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}

	#"[" + $today + "] Creating Scope: " + $Value 										>> $DeployObject.LogFile
	<#
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Green  -BackgroundColor Black "`n [$today] START CreateScope FOR "$ScopeObj.AppName
	Write-Host -ForegroundColor Magenta "ScopeObj.Value=" $ScopeObj.Value
	Write-Host -ForegroundColor Magenta "ScopeObj.UserConsentDisplayName=" $ScopeObj.UserConsentDisplayName
	Write-Host -ForegroundColor Magenta "ScopeObj.UserConsentDescription=" $ScopeObj.UserConsentDescription
	Write-Host -ForegroundColor Magenta "ScopeObj.AdminConsentDisplayName=" $ScopeObj.AdminConsentDisplayName
	Write-Host -ForegroundColor Magenta "ScopeObj.AdminConsentDescription=" $ScopeObj.AdminConsentDescription
	Write-Host -ForegroundColor Magenta "ScopeObj.IsEnabled=" $ScopeObj.IsEnabled
	Write-Host -ForegroundColor Magenta "ScopeObj.Type=" $ScopeObj.Type
	#>

	try
	{
		If(($app = Get-AzADApplication -Filter "DisplayName eq '$($ScopeObj.AppName)'"  -ErrorAction SilentlyContinue))
		{

			<#
			Write-Host "CreateScope[81]: ScopeObj.AppName=" $ScopeObj.AppName
			Write-Host "CreateScope[82]: app.Id=" $app.Id
			Write-Host "CreateScope[83]: app.DisplayName=" $app.DisplayName
			#>
			$Scopes = New-Object -TypeName "System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope]"
			$Scope = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope"
			 $Scope.Id = New-Guid
			$Scope.Value = $ScopeObj.Value
			$Scope.UserConsentDisplayName = $ScopeObj.UserConsentDisplayName
			$Scope.UserConsentDescription = $ScopeObj.UserConsentDescription
			$Scope.AdminConsentDisplayName = $ScopeObj.AdminConsentDisplayName
			$Scope.AdminConsentDescription = $ScopeObj.AdminConsentDescription
			 $Scope.IsEnabled = $ScopeObj.IsEnabled
			$Scope.Type = $ScopeObj.Type

			 $Scopes.Add($Scope)
			$app.Api.Oauth2PermissionScope = $Scopes
			Set-AzADApplication -ObjectId $app.Id -Api $app.Api
			#Write-Host -ForegroundColor Green "CreateScopes[99] Scope " $Scope.Value " ADDED"
		}
	}
	catch {
		$message = $_.Exception.message
		Write-Host -ForegroundColor Red "CreateScopes[80] ##vso[task.LogIssue type=error;] $message `n"
			Exit(1)
	}

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black "[$today] FINISHED CreateScope FOR $AppName"
	return $Scope
}



Function global:CreateScopesOld
{ 
	Param(
	[Parameter(Mandatory = $true)] [String] $AppName
	,[Parameter(Mandatory = $true)] [object]$ScopeObj
	)
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START CreateScopes FOR $AppName "
	#Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] Creating Scopes FOR" $AppName
	"================================================================================"	>> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": CREATING APP SCOPE: " + $AppName				>> $DeployObject.LogFile
	"================================================================================"	>> $DeployObject.LogFile

	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "Step" $DeployObject.StepCount ": CREATING APP SCOPE: "$AppName
	Write-Host -ForegroundColor Cyan "================================================================================"
	$DeployObject.StepCount++

	if(($app = Get-AzADApplication -Filter "DisplayName eq '$($AppName)'"  -ErrorAction SilentlyContinue))
	{
		$Scopes = New-Object -TypeName "System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope]"

			if($app.Api.Oauth2PermissionScope.Count -gt 0)
			{
					#Write-Host -ForegroundColor Green "CreateScopes[16] app.Api.Oauth2PermissionScope.Count:" $app.Api.Oauth2PermissionScope.Count
					$app.Api.Oauth2PermissionScopes | foreach-object { $scopes.Add($_) }
			}

			#$ifScopeWithSameValueExist = $app.Api.Oauth2PermissionScopes | Select-Object Value | Where-Object {$_.Value -eq "$($scope)"}

			$Scope = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope"
			$Scope.Id = New-Guid
			$Scope.Value = "user_impersonation"
			$Scope.UserConsentDisplayName = "User Permit to use DTP"
			$Scope.UserConsentDescription = "Permit use of DTP for Users and Admins"
			$Scope.AdminConsentDisplayName = "Permit use of DTP"
			$Scope.AdminConsentDescription = "Permit use of DTP"
			$Scope.IsEnabled = $true
			$Scope.Type = "User"
			$Scopes.Add($Scope)
	}

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black "[$today] FINISHED CreateScopes FOR $AppName `n"
}#CreateScopesOld


Function global:CreateScopeOld
{
	param
	(
			[Parameter(Mandatory = $true)] [object]$ScopeObj
	)
	"================================================================================"	>> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": CREATING APP SCOPE: " + $ScopeObj.Value			>> $DeployObject.LogFile
	"================================================================================"	>> $DeployObject.LogFile

	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "Step" $DeployObject.StepCount ": CREATING APP SCOPE:" $ScopeObj.Value
	Write-Host -ForegroundColor Cyan "================================================================================"
	$DeployObject.StepCount++

	#"[" + $today + "] Creating Scope: " + $Value >> $DeployObject.LogFile
	<#
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Green  -BackgroundColor Black "`n [$today] START CreateScope FOR "$ScopeObj.AppName
	Write-Host -ForegroundColor Magenta "ScopeObj.Value=" $ScopeObj.Value
	Write-Host -ForegroundColor Magenta "ScopeObj.UserConsentDisplayName=" $ScopeObj.UserConsentDisplayName
	Write-Host -ForegroundColor Magenta "ScopeObj.UserConsentDescription=" $ScopeObj.UserConsentDescription
	Write-Host -ForegroundColor Magenta "ScopeObj.AdminConsentDisplayName=" $ScopeObj.AdminConsentDisplayName
	Write-Host -ForegroundColor Magenta "ScopeObj.AdminConsentDescription=" $ScopeObj.AdminConsentDescription
	Write-Host -ForegroundColor Magenta "ScopeObj.IsEnabled=" $ScopeObj.IsEnabled
	Write-Host -ForegroundColor Magenta "ScopeObj.Type=" $ScopeObj.Type
	#>

	try
	{
		if(($app = Get-AzADApplication -Filter "DisplayName eq '$($ScopeObj.AppName)'"  -ErrorAction SilentlyContinue))
		{

			<#
			Write-Host "CreateScope[81]: ScopeObj.AppName=" $ScopeObj.AppName
			Write-Host "CreateScope[82]: app.Id=" $app.Id
			Write-Host "CreateScope[83]: app.DisplayName=" $app.DisplayName
			#>
			$Scopes = New-Object -TypeName "System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope]"
			$Scope = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope"
			 $Scope.Id = New-Guid
			$Scope.Value = $ScopeObj.Value
			$Scope.UserConsentDisplayName = $ScopeObj.UserConsentDisplayName
			$Scope.UserConsentDescription = $ScopeObj.UserConsentDescription
			$Scope.AdminConsentDisplayName = $ScopeObj.AdminConsentDisplayName
			$Scope.AdminConsentDescription = $ScopeObj.AdminConsentDescription
			 $Scope.IsEnabled = $ScopeObj.IsEnabled
			$Scope.Type = $ScopeObj.Type

			 $Scopes.Add($Scope)
			$app.Api.Oauth2PermissionScope = $Scopes
			Set-AzADApplication -ObjectId $app.Id -Api $app.Api
			#Write-Host -ForegroundColor Green "CreateScopes[99] Scope " $Scope.Value " ADDED"
		}
	}
	catch {
		$message = $_.Exception.message
		Write-Host -ForegroundColor Red "CreateScopes[80] ##vso[task.LogIssue type=error;] $message `n"
			exit(1)
	}

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black "[$today] FINISHED CreateScope FOR $AppName"
	return $Scope
}#CreateScopeOld

