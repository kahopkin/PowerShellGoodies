#AppRolesProcess
#.\CreateAppRoles.ps1 -AppName "TueClient" -AppRolesList "DTP Admins,DTP Users"

Function global:CreateAppRole
{
	Param(
		[Parameter(Mandatory = $true)] [String[]] $AllowedMemberTypes
		,[Parameter(Mandatory = $true)] [String] $Description
		,[Parameter(Mandatory = $true)] [String] $DisplayName
		,[Parameter(Mandatory = $true)] [String] $Value
		,[Switch] $Disabled
	)

	$Message = "CREATING APP ROLE: " + $DisplayName
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateAppRoles.CreateAppRole[19]"
	}
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	try
	{
		<#
		Write-Host -ForegroundColor Green "CreateAppRole[29] DisplayName:" $DisplayName
		Write-Host -ForegroundColor Green "CreateAppRole[30] Description:" $Description
		Write-Host -ForegroundColor Green "CreateAppRole[30] Value:" $Value
		#>
		$AppRole = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole
		$AppRole.AllowedMemberTypes = New-Object System.Collections.Generic.List[string]

		$AppRole.DisplayName = $DisplayName
		$AppRole.Description = $Description
		$AppRole.Value = $Value;
		$AppRole.Id = New-Guid
		$AppRole.IsEnabled =  (-not $Disabled)
		$AppRole.AllowedMemberTypes = @($AllowedMemberTypes)

		#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		#Write-Host -ForegroundColor Green  -BackgroundColor Black "[$today] FINISHED CreateAppRole"
		return $AppRole
	}
	catch {
		$message = $_.Exception.message
		Write-Host -ForegroundColor Red  "`CreateAppRole[129] ##vso[task.LogIssue type=error;] $message"
		exit 1
	}   
}
