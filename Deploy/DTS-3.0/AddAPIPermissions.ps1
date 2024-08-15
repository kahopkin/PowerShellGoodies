#AddAPIPermissions
<#
AddAPIPermissions -AppId $AppId -PermissionParent $PermissionParent
#>

Function global:AddAPIPermissions{
	Param(
		[Parameter(Mandatory = $true)] [String] $PermissionParentId
		, [Parameter(Mandatory = $true)] [String] $PermissionParentName
		, [Parameter(Mandatory = $true)] [String[]] $RequiredDelegatedPermissionNames
	)

	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING AddAPIPermissions.AddAPIPermissions[17]"
		Write-Host -ForegroundColor Yellow "`$PermissionParentName=`"$PermissionParentName`""
		Write-Host -ForegroundColor Yellow "`$PermissionParentId=`"$PermissionParentId`""
		Write-Host -ForegroundColor Yellow "`$PermissionParentName=`"$PermissionParentName`""
		Write-Host -ForegroundColor Yellow "`$RequiredDelegatedPermissionNames=`"$RequiredDelegatedPermissionNames`""
	}#If($debugFlag)#>

	$Message = "ADD API PERMISSION: " + $PermissionParentName
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
	<#DEBUG
	$i=0
	Write-Host -ForegroundColor Yellow "AddAPIPermissions[29] RequiredDelegatedPermissionNames:"
	foreach ($item in $RequiredDelegatedPermissionNames)
	{
		$item = $item.Trim()
		Write-Host "AddAPIPermissions[$i]=" $item
		$i++
	}
	#>
	$ApiObj = Get-AzADServicePrincipal -DisplayName $PermissionParentName
	$psCommand = "`$ApiObj = Get-AzADServicePrincipal -DisplayName `"" + $PermissionParentName + "`"`n"
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta -BackgroundColor White "AddAPIPermissions.AddAPIPermissions[35]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>

	$type = $ApiObj.GetType()
	If( $type.BaseType.FullName -eq "System.Object" )
	{
		#System.Object
		#Write-Host -ForegroundColor Yellow "type.BaseType.FullName:" $type.BaseType.FullName
		$AllDelegatedPermissions = $ApiObj.Oauth2PermissionScope
		$RequiredDelegatedPermissions = $AllDelegatedPermissions | Where-Object -FilterScript { $_.Value -in $RequiredDelegatedPermissionNames }

		# Create a RequiredResourceAccess object containing the required application and delegated permissions
		$RequiredPermissions = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess"
		$RequiredPermissions.ResourceAppId = $ApiObj.AppId
		$i=0
		# Create delegated permission objects (Scope)
		#Write-Host -ForegroundColor Blue -BackgroundColor White "NewDelegatedPermissions: LOOP"
		ForEach ($RequiredDelegatedPermission in $RequiredDelegatedPermissions)
		{
			$NewDelegatedPermission = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess" -Property @{ Id = $RequiredDelegatedPermission.Id; Type = "Scope" }
			$RequiredPermissions.ResourceAccess += $NewDelegatedPermission
			#Write-Host "[$i]" $NewDelegatedPermission.Id
			#Write-Host -ForegroundColor Cyan "AppId: " $item.AppId
			#Write-Host -ForegroundColor Cyan "Oauth2PermissionScope: " $item.Oauth2PermissionScope.value
			$i++
		}
	}
	Else #System.Array
	{
		#System.Array
		#Write-Host -ForegroundColor Green "type.BaseType.FullName:" $type.BaseType.FullName
		$i = 0
		ForEach ($item in $ApiObj)
		{
			$AllDelegatedPermissions = $item.Oauth2PermissionScope
			#Write-Host "[$i] AllDelegatedPermissions=" $AllDelegatedPermissions
			If($PermissionParentId -ne $null -and $item.AppId -eq $PermissionParentId)
			{
				#Write-Host -ForegroundColor Cyan "AppId: " $item.AppId
				#Write-Host -ForegroundColor Cyan "Oauth2PermissionScope: " $item.Oauth2PermissionScope.value
				$RequiredDelegatedPermissions = $AllDelegatedPermissions | Where-Object -FilterScript { $_.Value -in $RequiredDelegatedPermissionNames }
				#Write-Host "RequiredDelegatedPermissions.Count: "$RequiredDelegatedPermissions.Count
				# Create a RequiredResourceAccess object containing the required application and delegated permissions
				$RequiredPermissions = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess"
				$RequiredPermissions.ResourceAppId = $item.AppId
				$j = 0
				# Create delegated permission objects (Scope)
				#Write-Host -ForegroundColor Blue -BackgroundColor White "NewDelegatedPermissions: LOOP"
				ForEach ($RequiredDelegatedPermission in $RequiredDelegatedPermissions)
				{
					$NewDelegatedPermission = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess" -Property @{ Id = $RequiredDelegatedPermission.Id; Type = "Scope" }
					$RequiredPermissions.ResourceAccess += $NewDelegatedPermission
					#Write-Host "[$j]" $NewDelegatedPermission.Id
					$j++
				}
				$i++
			}#$PermissionParentId -ne $null
		}#outer ForEach
	} #Else
	return $RequiredPermissions
}#AddAPIPermissions