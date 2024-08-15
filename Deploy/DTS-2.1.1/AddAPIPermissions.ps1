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
	#"[" + $today + "] Adding API Permission: " + $PermissionParentName >> $DeployInfo.LogFile

	"================================================================================"	>> $DeployInfo.LogFile
	"Step" + $DeployInfo.StepCount + ": ADD API PERMISSION: " + $PermissionParentName	>> $DeployInfo.LogFile
	"================================================================================"	>> $DeployInfo.LogFile
	#>
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "Step" $DeployInfo.StepCount": ADD API PERMISSION:"$PermissionParentName
	Write-Host -ForegroundColor Cyan "================================================================================"
	$DeployInfo.StepCount++


	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	If($debugFlag){
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "AddAPIPermissions[24] Adding API Permission PermissionParentName= $PermissionParentName"
	Write-Host -ForegroundColor Yellow "AddAPIPermissions[26] PermissionParentId:" $PermissionParentId
	Write-Host -ForegroundColor Yellow "AddAPIPermissions[27] PermissionParentName:" $PermissionParentName
	Write-Host -ForegroundColor Yellow "AddAPIPermissions[28] RequiredDelegatedPermissionNames:" $RequiredDelegatedPermissionNames
	}#>

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
	$type = $ApiObj.GetType()
	If( $type.BaseType.FullName -eq "System.Object" )
	{
		#System.Object
		#Write-Host -ForegroundColor Yellow "AddAPIPermissions[48] type.BaseType.FullName:" $type.BaseType.FullName
		$AllDelegatedPermissions = $ApiObj.Oauth2PermissionScope
		$RequiredDelegatedPermissions = $AllDelegatedPermissions | Where-Object -FilterScript { $_.Value -in $RequiredDelegatedPermissionNames }

		# Create a RequiredResourceAccess object containing the required application and delegated permissions
		$RequiredPermissions = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess"
		$RequiredPermissions.ResourceAppId = $ApiObj.AppId
		$i=0
		# Create delegated permission objects (Scope)
		#Write-Host -ForegroundColor Blue -BackgroundColor White "AddAPIPermissions[62] NewDelegatedPermissions: LOOP"
		foreach ($RequiredDelegatedPermission in $RequiredDelegatedPermissions)
		{
			$NewDelegatedPermission = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess" -Property @{ Id = $RequiredDelegatedPermission.Id; Type = "Scope" }
			$RequiredPermissions.ResourceAccess += $NewDelegatedPermission
			 #Write-Host "[$i]" $NewDelegatedPermission.Id
			 #Write-Host -ForegroundColor Cyan "AppId: " $item.AppId
			#Write-Host -ForegroundColor Cyan "Oauth2PermissionScope: " $item.Oauth2PermissionScope.value
			$i++
		}

	}
	else #System.Array
	{
		#System.Array
		#Write-Host -ForegroundColor Green "AddAPIPermissions[71] type.BaseType.FullName:" $type.BaseType.FullName
		$i=0
		foreach ($item in $ApiObj)
		{
			$AllDelegatedPermissions = $item.Oauth2PermissionScope
			#Write-Host "[$i] AllDelegatedPermissions=" $AllDelegatedPermissions
			If($PermissionParentId -ne $null -and $item.AppId -eq $PermissionParentId)
			{
				#Write-Host -ForegroundColor Cyan "AppId: " $item.AppId
				#Write-Host -ForegroundColor Cyan "Oauth2PermissionScope: " $item.Oauth2PermissionScope.value
				$RequiredDelegatedPermissions = $AllDelegatedPermissions | Where-Object -FilterScript { $_.Value -in $RequiredDelegatedPermissionNames }
				#Write-Host "AddAPIPermissions[75] RequiredDelegatedPermissions.Count: "$RequiredDelegatedPermissions.Count
				# Create a RequiredResourceAccess object containing the required application and delegated permissions
				$RequiredPermissions = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess"
				$RequiredPermissions.ResourceAppId = $item.AppId
				$j=0
				# Create delegated permission objects (Scope)
				#Write-Host -ForegroundColor Blue -BackgroundColor White "AddAPIPermissions[62] NewDelegatedPermissions: LOOP"
				foreach ($RequiredDelegatedPermission in $RequiredDelegatedPermissions)
				{
					$NewDelegatedPermission = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess" -Property @{ Id = $RequiredDelegatedPermission.Id; Type = "Scope" }
					$RequiredPermissions.ResourceAccess += $NewDelegatedPermission 
					 #Write-Host "[$j]" $NewDelegatedPermission.Id
					 $j++
				}

				$i++
			}
			<#Else
			{
				Write-Host -ForegroundColor Yellow "AppId: " $item.AppId
				Write-Host -ForegroundColor Yellow "Oauth2PermissionScope: " $item.Oauth2PermissionScope.value
			}#>
		}#outer foreach
	} #else

	return $RequiredPermissions
}#AddAPIPermissions