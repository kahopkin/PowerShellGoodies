#C:\GitHub\PowerShellGoodies\RemoveStaleRoleAssignments.ps1

Function global:RemoveOrphanRoleAssignments
{
	Param(
		[Parameter(Mandatory = $false)] [string] $ResourceGroupName
	)
	$PrintPSCommands = $debugFlag = $true
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$StartTime = $today
	Write-Host -ForegroundColor Yellow "===================================================================================="
	Write-Host -ForegroundColor Yellow " [$today] REMOVING UNIDENTIFIED ROLE ASSIGNMENTS FROM:" $ResourceGroupName 
	Write-Host -ForegroundColor Yellow "===================================================================================="
	<#
	try
	{
		$var = Get-AzureADTenantDetail
	}
	catch
	{

		Write-Host "You're not connected.";
		$AzConnection = Connect-AzAccount -Environment AzureUSGovernment
	}
	#>
	$AzureContext = Get-AzContext
	$SubscriptionName = $AzureContext.Subscription.Name

	$CurrUser = Get-AzADUser -SignedIn
	$CurrUserName = $CurrUser.DisplayName
	$CurrUserPrincipalName = $CurrUser.UserPrincipalName
	$CurrUserId = $CurrUser.Id
	Write-Host -ForegroundColor Cyan "`$SubscriptionName=`"$SubscriptionName`""
	Write-Host -ForegroundColor Cyan "`$CurrUserName=`"$CurrUserName`""
	Write-Host -ForegroundColor Cyan "`$CurrUserId=`"$CurrUserId`""
	Write-Host -ForegroundColor Cyan "`$CurrUserPrincipalName=`"$CurrUserPrincipalName`""

	#Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""

	#Write-Host "ResourceGroup.Length:" $ResourceGroupName.Length
	If($ResourceGroupName.Length -ne 0)
	{
		$myResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
		$ResourceId = $myResourceGroup.ResourceId
		$AzRoleAssignments = Get-AzRoleAssignment -ResourceGroupName $ResourceGroupName | Where-Object { $_.ObjectType -eq 'Unknown' }
		$psCommand = "`$AzRoleAssignments = `n`tGet-AzRoleAssignment  ```n`t`t" + 
								"-ResourceGroupName `"" + $ResourceGroupName + "`"```n`t`t" +
								"| Where-Object {`$_.ObjectType -eq `"Unknown`"} `n"
		#
			If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "RemoveOrphanRoleAssignments[53]:"
			Write-Host -ForegroundColor Green $psCommand
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		}#If($PrintPSCommands) #>
	}#If($ResourceGroupName.Length -ne 0)
	Else
	{
		Write-Host -ForegroundColor Magenta "[50]:: ResourceGroup NOT GIVEN"
		$AzRoleAssignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'Unknown' }
		$psCommand = "`$AzRoleAssignments = `n`tGet-AzRoleAssignment | Where-Object {`$_.ObjectType -eq `"Unknown`"}"
		#
			If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "RemoveOrphanRoleAssignments[64]:"
			Write-Host -ForegroundColor Green $psCommand
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		}#If($PrintPSCommands) #>
	}#ElseIf($ResourceGroupName.Length -ne 0)
 

	$RoleCount = ($AzRoleAssignments | Measure-Object | Select Count).Count
	Write-Host -ForegroundColor Green "There are" $AzRoleAssignments.Count "Identity not found roles "

	ForEach($role in $AzRoleAssignments)
	{
		$RoleAssignmentName = $role.RoleAssignmentName
		$RoleDefinitionName = $role.RoleDefinitionName
		$RoleDefinitionId = $role.RoleDefinitionId
		$ObjectId = $role.ObjectId
		$ObjectType = $role.ObjectType
		$DisplayName = $role.DisplayName

		Write-Host -ForegroundColor White -NoNewline "`$RoleAssignmentName=`""
		Write-Host -ForegroundColor DarkYellow "`"$RoleAssignmentName`""

		Write-Host -ForegroundColor White -NoNewline "`$RoleDefinitionName=`""
		Write-Host -ForegroundColor Cyan "`"$RoleDefinitionName`""

			Write-Host -ForegroundColor White -NoNewline "`$ObjectId=`""
		Write-Host -ForegroundColor DarkCyan "`"$ObjectId`""

		#Remove-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $RoleDefinitionName

		For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
		Write-Host "`n"
	}

	$Output =  $AzRoleAssignments | Remove-AzRoleAssignment

	Write-Host -ForegroundColor Green $Output
	

	<#The scope of the assignment MAY be specified and If not specified,
		defaults to the subscription scope
		i.e. it will try to delete an assignment to the specified principal and role at the subscription scope.
	#>
	#
	$UserRoleAssignments = Get-AzRoleAssignment -SignInName $CurrUserPrincipalName | Where-Object {$_.Scope -eq $Scope }
	$RoleCount = ($UserRoleAssignments | Measure-Object | Select Count).Count
	Write-Host -ForegroundColor Yellow "There are" $AzRoleAssignments.Count "Identity not found roles SUBSCRIPTION Scope"
	<#debug
	ForEach($role in $AzRoleAssignments)
	{
		Write-Host  "RoleAssignmentName:"$role.RoleAssignmentName ", ObjectType: " $role.ObjectType ",DisplayName:" $role.DisplayName
	}
	#>

	#$UserRoleAssignments | Remove-AzRoleAssignment
	#Remove Identity not found role assignments on the Resource Group level:
	<# Get-AzRoleAssignment -Scope $ResourceId | `
	 Where-Object { $_.ObjectType -eq 'Unknown' } | `
		Remove-AzRoleAssignment
		#>


	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$EndTime = $today
	$Duration= New-TimeSpan -Start $StartTime -End $EndTime
	Write-Host -ForegroundColor Yellow "===================================================================================="
	Write-Host -ForegroundColor Cyan " [$today] COMPLETED OPERATION "
	Write-Host -ForegroundColor Cyan " DURATION [HH:MM:SS]:" $Duration
	Write-Host -ForegroundColor Yellow "===================================================================================="
}#RemoveOrphanRoleAssignment

#$ResourceGroupName = "rg-dts-transfer-prod"
RemoveOrphanRoleAssignments #-ResourceGroupName $ResourceGroupName