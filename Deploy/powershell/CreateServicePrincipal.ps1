#CreateServicePrincipal
<#This creates the Enterprise app.

!!!!! 
One frustrating thing about creating Service Principals with PowerShell 
is they’re NOT visible under the Enterprise Apps filter.
Instead, we need to select "All Apps" and then filter by name.
We also don’t get access access to configuration items such as Conditional Access.
This is due to some missing tags on the Enterprise App object, 
namely WindowsAzureActiveDirectoryIntegratedApp.
#>

# Create a Service Principal Name (SPN) for the application created earlier
Function global:CreateServicePrincipal
{
	 Param(
			[Parameter(Mandatory = $true)] [String] $AppId
		, [Parameter(Mandatory = $true)] [Object] $DeployObject
	 )
	$Message = "CREATE SERVICE PRINCIPAL (ENTERPRISE APPLICATION): " + $AppId
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateServicePrincipal.CreateServicePrincipal[25]" 
	}
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$SolutionObjName = $DeployObject.SolutionObjName

	#Write-Host -ForegroundColor Magenta "[$today] AppRegObj.AppRoleAssignmentRequired:" $AppRoleAssignmentRequired
	$SPN = Get-AzADServicePrincipal -ApplicationId $AppId
	$psCommand = "`$SPN = `n`t`Get-AzADServicePrincipal  ```n`t`t" +
								"-ApplicationId `"" + $AppId + "`" `n"  
	# 
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "CreateServicePrincipal.CreateServicePrincipal[40]:" 
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #>

	if($SPN.DisplayName -eq $null)
	{
			$SPN = New-AzADServicePrincipal -ApplicationId $AppId `
				-AppRoleAssignmentRequired `
				-ServicePrincipalType 'Application'
		$psCommand = "`$SPN = `n`t`New-AzADServicePrincipal  ```n`t`t" +
								"-ApplicationId `"" + $AppId + "`" `n`t`t" + 
								 "-ServicePrincipalType 'Application'"
		#
			If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "CreateServicePrincipal.CreateServicePrincipal[54]:" 
			Write-Host -ForegroundColor Green $psCommand
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		}#If($PrintPSCommands) #>

		#https://learn.microsoft.com/en-us/powershell/module/az.resources/new-azadserviceprincipal?view=azps-9.1.0
		#-AppRoleAssignmentRequired ($DeployObject.AppRoleAssignmentRequired).ToBoolean()
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[17] Waiting for the SPN to be created...30 seconds"
		Start-Sleep -Seconds 10
		#Write-Host -ForegroundColor Green -BackgroundColor Black "CreateServicePrincipal[40] Created Service Principal Name (SPN):" $SPN.AppDisplayName
		#Write-Host -ForegroundColor Green -BackgroundColor Black "CreateServicePrincipal[41] SPN.ID:" $SPN.Id
		#>
		If( $SPN.AppDisplayName.Contains("api"))
		{
			 $DeployObject.APIAppRegServicePrincipalId = $SPN.Id
			}
		Else
		{
			 $DeployObject.ClientAppRegServicePrincipalId = $SPN.Id
			}
		<#
			$AppRoleAssignmentList = New-Object 'System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRoleAssignment]'
			$SPN = Get-AzADServicePrincipal -ObjectId $SPN.Id
			$AppRoles = $SPN.AppRole

			 ForEach($AppRole in $AppRoles)
			{
				$AppRoleDisplayName = $AppRole.DisplayName
				$AppRoleId = $AppRole.Id
				 $PrincipalId = $DeployObject.CurrUserId
				$DisplayName = $DeployObject.CurrUserName
				#
				If($debugFlag){
				 Write-Host -ForegroundColor Green "`$AppRoleDisplayName=`"$AppRoleDisplayName`""
				 Write-Host -ForegroundColor Yellow "`$AppRoleId=`"$AppRoleId`""
				 Write-Host "`$PrincipalId=`"$PrincipalId`""
				}#If($debugFlag) #
				$AppRoleAssignment = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRoleAssignment
				 $AppRoleAssignment.PrincipalId = $PrincipalId
				$AppRoleAssignment.PrincipalDisplayName = $DisplayName
				$AppRoleAssignment.AppRoleId = $AppRole.Id
				$AppRoleAssignment.ResourceId = $SPN.Id
				$AppRoleAssignment.ResourceDisplayName = $SPN.DisplayName
				$AppRoleAssignmentList.Add($AppRoleAssignment)
			}#ForEach
			 #Write-Host -ForegroundColor Red "Adding AppRoleAssignments..."
			#Update-AzADServicePrincipal -ObjectId $SPN.Id -AppRoleAssignedTo $AppRoleAssignmentList
		#>
	}#ElseIf($SPN.DisplayName -eq $null)
	else
	{
		Write-Host -ForegroundColor Green "CreateServicePrincipal[107] EXISTING SPN.Name:" $SPN.AppDisplayName
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[108] SPN.Id:" $SPN.Id
		If($SPN.AppRoleAssignmentRequired -eq $false)
		{
			Update-AzADServicePrincipal -ObjectId $SPN.Id -AppRoleAssignmentRequired
			$psCommand = "`$SPN = `n`t`Update-AzADServicePrincipal  ```n`t`t" +
								"-ObjectId `"" + $SPN.Id + "`"```n`t`t" +
								"-AppRoleAssignmentRequired `n"
			#
			 If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "CreateServicePrincipal.CreateServicePrincipal[117]:" 
				Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
			}#If($PrintPSCommands) #>
		}
		$RoleAssignment = Get-AzRoleAssignment -ObjectId $SPN.Id
			$psCommand = "`$RoleAssignment = `n`t`Get-AzRoleAssignment  ```n`t`t" +
								"-ObjectId `"" + $SPN.Id + "`"`n"
			#
			 If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "CreateServicePrincipal.CreateServicePrincipal[127]:" 
				Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
			}#If($PrintPSCommands) #>
		$AppRoleAssignmentList = New-Object 'System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRoleAssignment]'
		$SPN = Get-AzADServicePrincipal -ObjectId $SPN.id
		$AppRoles = $SPN.AppRole
		#Write-Host "AppRoles.Count" $AppRoles.Count
		ForEach($AppRole in $AppRoles)
		{
			$AppRoleDisplayName = $AppRole.DisplayName
			$AppRoleId = $AppRole.Id
			 $PrincipalId = $DeployObject.CurrUserId
			$DisplayName = $DeployObject.CurrUserName
			#
			If($debugFlag){
			 Write-Host -ForegroundColor Green "`$AppRoleDisplayName=`"$AppRoleDisplayName`""
			 Write-Host -ForegroundColor Yellow "`$AppRoleId=`"$AppRoleId`""
			 Write-Host "`$PrincipalId=`"$PrincipalId`""
			}#If($debugFlag)#>

			$AppRoleAssignment = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRoleAssignment
			 $AppRoleAssignment.PrincipalId = $PrincipalId
			$AppRoleAssignment.PrincipalDisplayName = $DisplayName
			$AppRoleAssignment.AppRoleId = $AppRole.Id
			$AppRoleAssignment.ResourceId = $SPN.Id
			$AppRoleAssignment.ResourceDisplayName = $SPN.DisplayName
			$AppRoleAssignmentList.Add($AppRoleAssignment)
		}#ForEach
		#Update-AzADServicePrincipal -ObjectId $SPN.Id -AppRoleAssignedTo $AppRoleAssignmentList
	}#ElseIf($SPN.DisplayName -eq $null)

	return $SPN
}#CreateServicePrincipal