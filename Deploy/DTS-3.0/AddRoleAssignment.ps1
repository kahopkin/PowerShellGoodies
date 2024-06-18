<#
#>
#AddRoleAssignment
Function global:AddRoleAssignment
{
	Param(
		[Parameter(Mandatory = $false)] [String] $AzRoleName
		,[Parameter(Mandatory = $false)] [Object] $User
		,[Parameter(Mandatory = $false)] [String] $ResourceGroupName
		,[Parameter(Mandatory = $false)] [String] $Scope
		,[Parameter(Mandatory = $true)]  [Object] $DeployObject 
	)

	$scopeLength = $Scope.Length
	If($scopeLength -eq 0)
	{
		 $Scope = "/subscriptions/" + $DeployObject.SubscriptionId + "/resourceGroups/$ResourceGroupName" 
	}
	Else
	{
		 Write-Host -ForegroundColor Magenta -BackgroundColor White "AddRoleAssignment.AddRoleAssignment[21] `n`$Scope=`"$Scope`""
	}

	$Message = "ADDING ROLE ASSIGNMENT: " + $AzRoleName
	#
	If($debugFlag){
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "AddRoleAssignment.AddRoleAssignment[25]"
		Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
		Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
		If($scopeLength -ne 0) { Write-Host -ForegroundColor Yellow "`$Scope=`"$Scope`"" }
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Magenta "*" }Else{Write-Host -ForegroundColor Magenta "*" -NoNewline}}
	}#If($debugFlag)#>
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$userType = ($User.GetType()).Name
	$UserName = $null
	<#
	If($debugFlag){
		 Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[35] User.GetType()"
		 Write-Host -ForegroundColor Yellow "`$userType=`"$userType`""
	}#If(-not $debugFlag) #>

	If($userType -eq "MicrosoftGraphUser")
	{ 
		 $UserId = $User.Id
		 $CurrUserPrincipalName = $User.UserPrincipalName
		 $UserName = $User.DisplayName
		 $UserRoleAssignments = Get-AzRoleAssignment -SignInName $CurrUserPrincipalName | Where-Object {$_.Scope -eq $Scope -and $_.RoleDefinitionName -eq $AzRoleName}

			$psCommand = "`$UserRoleAssignments = `n`tGet-AzRoleAssignment  ```n`t`t" +
								 "-SignInName `"" + $CurrUserPrincipalName + "`"```n`t`t" +
								 "| Where-Object {`$_.Scope -eq `"" + $Scope +  "`"```n`t`t" +
								 " -and `$_.RoleDefinitionName -eq " + $AzRoleName  + "`" `n" 
			#
			If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[61]:"  $userType
			 Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		 }#If($PrintPSCommands) #>
	}#If($userType -eq "MicrosoftGraphUser")
	#MicrosoftGraphGroup
	ElseIf($userType -eq "MicrosoftGraphGroup")
	{
		 $UserId = $User.Id
		 $UserName = $User.DisplayName
			$UserRoleAssignments = Get-AzRoleAssignment -ObjectId $UserId | Where-Object {$_.Scope -eq $Scope -and $_.RoleDefinitionName -eq $AzRoleName}

			$psCommand = "`$UserRoleAssignments = `n`tGet-AzRoleAssignment  ```n`t`t" +
								 "-ObjectId `"" + $UserId + "`"```n`t`t" +
								 "-| Where-Object {`$_.Scope -eq `"" + $Scope +  "`"```n`t`t" +
								 " -and `$_.RoleDefinitionName -eq " + $AzRoleName  + "`" `n" 
			#
			If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[81]:" $userType
			 Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
		 }#If($PrintPSCommands) #>
	}#ElseIf($userType -eq "MicrosoftGraphGroup")
	#MicrosoftGraphServicePrincipal
	ElseIf($userType -eq "MicrosoftGraphApplication" -or $userType -eq "MicrosoftGraphServicePrincipal")
	{
		 #PSResource
		 $UserId = $User.Id
		 $UserName = $User.DisplayName
			$UserRoleAssignments = Get-AzRoleAssignment `
									 -ObjectId $UserId `
									 | Where-Object {$_.Scope -eq $Scope -and $_.RoleDefinitionName -eq $AzRoleName}

		 $psCommand = "`$UserRoleAssignments = `n`tGet-AzRoleAssignment  ```n`t`t" +
								 "-SignInName `"" + $UserId + "`"```n`t`t" +
								 "| Where-Object {`$_.Scope -eq `"" + $Scope + "`"```n`t`t" +
								 " -and `$_.RoleDefinitionName -eq " + $AzRoleName  + "`" `n" 
			#
			If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[102]:" $userType
			 Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			}#If($PrintPSCommands) #>
	}#ElseIf($userType -eq "MicrosoftGraphApplication" -or $userType -eq "MicrosoftGraphServicePrincipal")
	#String (this will be a GUID If it is string)
	<#
	Else
	{
		 $UserId = $User
		 $UserName = $User
		 $UserRoleAssignments = Get-AzRoleAssignment `
									 -ObjectId $UserId `
									 | Where-Object {$_.Scope -eq $Scope -and $_.RoleDefinitionName -eq $AzRoleName}

			$psCommand = "`$UserRoleAssignments = `n`tGet-AzRoleAssignment  ```n`t`t" +
								 "-ObjectId `"" + $UserId + "`"```n`t`t" +
								 "-| Where-Object {`$_.Scope -eq `"" + $Scope + "`"```n`t`t" +
								 " -and `$_.RoleDefinitionName -eq " + $AzRoleName  + "`" `n" 
			#
			If($PrintPSCommands){
			 Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[116]:" $userType
			 Write-Host -ForegroundColor Green $psCommand
			 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Yellow "=" }Else{Write-Host -ForegroundColor Yellow "=" -NoNewline}}
			}#If($PrintPSCommands) #
	}#Else
	#>
	$Message += " to " + $UserName
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$AssignmentCount = ($UserRoleAssignments | Measure-Object | Select Count).Count
	Write-Host -ForegroundColor Cyan "AddRoleAssignment[110] User has:" $AssignmentCount "Role Assignments on the Resource Group:" $ResourceGroupName
	#
	If($debugFlag){
		 Write-Host -ForegroundColor Magenta "`n AddRoleAssignment.AddRoleAssignment[133]"
		 Write-Host -ForegroundColor Yellow "`$UserName=`"$UserName`""
		 Write-Host -ForegroundColor Cyan "`$UserId=`"$UserId`""
		 Write-Host -ForegroundColor Cyan "`$AzRoleName=`"$AzRoleName`""
		 Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
		 Write-Host -ForegroundColor Cyan "`$AssignmentCount=`"$AssignmentCount`""
		 Write-Host -ForegroundColor Green "`$userType=`"$userType`""
			Write-Host -ForegroundColor Yellow "`$Scope=`"$Scope`""
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green "*" }Else{Write-Host -ForegroundColor Green "*" -NoNewline}}
	}#If($debugFlag)#>

	If($AssignmentCount -eq 0)
	{
			If($ResourceGroupName.Length -gt 0)
		 {
				 If($scopeLength -eq 0)
			 {
				 $RoleAssignment = New-AzRoleAssignment `
					 -ObjectId $UserId `
					 -RoleDefinitionName $AzRoleName `
					 -ResourceGroupName $ResourceGroupName

					$psCommand = "`$RoleAssignment = `n`tNew-AzRoleAssignment  ```n`t`t" +
						 "-ObjectId `"" + $UserId + "`"```n`t`t" +
						 "-RoleDefinitionName `"" + $AzRoleName + "`"```n`t`t" +
						 "-ResourceGroupName `"" + $ResourceGroupName + "`" `n"
					 #
					 If($PrintPSCommands){
					 Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[163]:" $ResourceGroupName
						 Write-Host -ForegroundColor Green $psCommand
					 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
					 }#If($PrintPSCommands) #>
			 }
			 Else
			 {
				 $RoleAssignment = New-AzRoleAssignment `
					 -ObjectId $UserId `
					 -RoleDefinitionName $AzRoleName `
					 -ResourceGroupName $ResourceGroupName `
					 -Scope $Scope

				 $psCommand = "`$RoleAssignment = `n`tNew-AzRoleAssignment  ```n`t`t" +
						 "-ObjectId `"" + $UserId + "`"```n`t`t" +
						 "-RoleDefinitionName `"" + $AzRoleName + "`"```n`t`t" +
						 "-ResourceGroupName `"" + $ResourceGroupName + "`"```n`t`t" +
						 "-Scope `"" + $Scope + "`" `n"
					 #
					 If($PrintPSCommands){
					 Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[183]:" 
					 Write-Host -ForegroundColor Green $psCommand
					 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
				 }#If($PrintPSCommands) #>
			 }
			}#If($ResourceGroupName.Length -gt 0)
		 Else
		 {
			$RoleAssignment = New-AzRoleAssignment `
					-ObjectId $UserId `
					-RoleDefinitionName $AzRoleName `
					-Scope $Scope

			$psCommand = "`$RoleAssignment = `n`tNew-AzRoleAssignment  ```n`t`t" +
						 "-ObjectId `"" + $UserId + "`"```n`t`t" +
						 "-RoleDefinitionName `"" + $AzRoleName + "`"```n`t`t" +
							 "-Scope `"" + $Scope + "`" `n"
			#
			If($PrintPSCommands){
				Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[202]:" 
				Write-Host -ForegroundColor Green $psCommand
				For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
			}#If($PrintPSCommands) #>
		 }#ElseIf($ResourceGroupName.Length -gt 0) 
	}#If($AssignmentCount -eq 0)
	Else
	{
		 Write-Host -ForegroundColor Red $UserName "already has $AzRoleName Role. No action has been taken"
	}#ElseIf($AssignmentCount -eq 0)

	$Message = "Resource Group Name: " + $DeployObject.ResourceGroupName
	Write-Host -ForegroundColor Green -BackgroundColor Black $Message
	#$Message = "Resource Group's ResourceId: " + $ResourceId
	#Write-Host -ForegroundColor Green -BackgroundColor Black $Message 
	$Message = "ADDED " + $AzRoleName + "ROLE FOR " + $UserName
	Write-Host -ForegroundColor Green -BackgroundColor Black $Message
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Yellow "=" }Else{Write-Host -ForegroundColor Yellow "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan "COMPLETED ADDING ROLE ASSIGNMENT:" $AzRoleName
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Yellow "=" }Else{Write-Host -ForegroundColor Yellow "=" -NoNewline}}
	#To list all the roles that are assigned to a specified user and the roles that are assigned to the groups to which the user belongs
	#$UserRoleAssignment = Get-AzRoleAssignment -SignInName $DeployObject.CurrUserPrincipalName -ExpandPrincipalGroups
}#AddRoleAssignment

Function global:CreateAzGroup
{
	Param(
			[Parameter(Mandatory = $true)]  [String] $GroupName
		 ,[Parameter(Mandatory = $false)] [String] $MailNickname
		 ,[Parameter(Mandatory = $false)] [Object] $DeployObject
	)

	$Message = "CREATE AD GROUP:" + $GroupName
	#
	If($debugFlag){
		 Write-Host -ForegroundColor DarkBlue -BackgroundColor White "AddRoleAssignment.CreateAzGroup[233]"
		 Write-Host -ForegroundColor Cyan "`$GroupName= `"$GroupName`""
		 #Write-Host -ForegroundColor Cyan "`$MailNickname= `"$MailNickname`""
	}#If($debugFlag)#>

	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	$MailNickname = $GroupName.replace(' ' , '')
	$UserGroup = Get-AzADGroup -DisplayName $GroupName
	$psCommand = "`$UserGroup = `n`t`Get-AzADGroup  ```n`t`t" +
								 "-DisplayName `"" + $GroupName + "`" `n"
	# 
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "AddRoleAssignment.CreateAzGroup[250]:" 
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #>
	$MailNickname = $UserGroup.MailNickname

	If($debugFlag){
		 Write-Host -ForegroundColor Magenta "AddRoleAssignment.CreateAzGroup[257]"
		 Write-Host -ForegroundColor Cyan "`$GroupName=`"$GroupName`""
		 Write-Host -ForegroundColor Cyan "`$MailNickname=`"$MailNickname`""
			#Write-Host -ForegroundColor Cyan "`$UserGroup=`"$UserGroup`""
	}#If($debugFlag)#> 

	If($UserGroup -eq $null)
	{
			$UserGroup = New-AzADGroup -DisplayName $GroupName -MailNickname $MailNickname
		 $Message = "CREATED AD GROUP:" + $GroupName
	}
	Else
	{
		 $Message = "AD GROUP:'" + $GroupName + "' EXISTS, NO FURTHER ACTION TAKEN..."
	}

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black $Message
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}

	"================================================================================">> $DeployObject.LogFile
	$Message		>> $DeployObject.LogFile
	"================================================================================">> $DeployObject.LogFile

	return $UserGroup

}#CreateAzGroup

#
Function global:AddCustomRole
{
	Param(
		 [Parameter(Mandatory = $true)] [string] $RoleAssignmentName
		)
	#
	If($debugFlag){
		 Write-Host -ForegroundColor DarkBlue -BackgroundColor White "AddRoleAssignment.AddCustomRole[288]"
		 $DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
			#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		 Write-Host -ForegroundColor Cyan "`$RoleAssignmentName= `"$RoleAssignmentName`""
	}#If($debugFlag)#>
	Else
	{
		$Message = ":"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}
	$role = [Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition]::new()
	$role.Name = 'Virtual Machine Operator 2'
	$role.Description = 'Can monitor and restart virtual machines.'
	$role.IsCustom = $true
	$perms = 'Microsoft.Storage/*/read','Microsoft.Network/*/read','Microsoft.Compute/*/read'
	$perms += 'Microsoft.Compute/virtualMachines/start/action','Microsoft.Compute/virtualMachines/restart/action'
	$perms += 'Microsoft.Authorization/*/read'
	$perms += 'Microsoft.ResourceHealth/availabilityStatuses/read'
	$perms += 'Microsoft.Resources/subscriptions/resourceGroups/read'
	$perms += 'Microsoft.Insights/alertRules/*','Microsoft.Support/*'
	$role.Actions = $perms
	$role.NotActions = (Get-AzRoleDefinition -Name 'Virtual Machine Contributor').NotActions
	$subs = '/subscriptions/355e427a-6396-4164-bd2e-d0f24719ea04'
	$role.AssignableScopes = $subs

	$CustomRoles = Get-AzRoleDefinition | ? {$_.IsCustom -eq $true -and $_.Name -eq $RoleAssignmentName}
	$CustomRoleCount = ($CustomRoles | Measure-Object | Select Count).Count
	$CustomRoleCount

	If($CustomRoleCount -eq 0)
	{
			New-AzRoleDefinition -Role $role
		 Write-Host -ForegroundColor Green -BackgroundColor White "Added custom role assignment: $RoleAssignmentName, continuing deployment...."
	}
	Else
	{
		 Write-Host -ForegroundColor Red -BackgroundColor White "Custom role assignment: $RoleAssignmentName EXISTS"
	}

}#AddCustomRole


# BELOW FUNCTIONS ARE NOT BEING REFERENCED IN ANY CURRENT MODULES, BUT NOT READY TO DELETE THEM YET.
Function global:AddUsersToUserGroup
{
	Param(
			[Parameter(Mandatory = $false)] [string] $UserGroup 
	)

	$Message = "ADD INTERNAL TENANT USERS TO : " + $UserGroup
	#
	If($debugFlag){
		 $DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		 #PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		 Write-Host -ForegroundColor DarkBlue -BackgroundColor White "AddRoleAssignment.AddUsersToUserGroup[343]"
		 Write-Host -ForegroundColor Cyan "`$UserGroup= `"$UserGroup`""
	}#If($debugFlag)#>
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}

	$groupid = (Get-AzADGroup -DisplayName $UserGroup).Id
	$members = @()
	# Get all licensedUsers
	$allUsers = Get-AzADUser 

	$inGroupCount = 0
	$outGroupCount = 0

	Foreach ($user In $allUsers)
	{
		 $UserId = $user.Id
		 $CurrUserPrincipalName = $user.UserPrincipalName
		 $UserName = $user.DisplayName

			$userPrin = $CurrUserPrincipalName.Split("@")[0]
		 $userDomain = $CurrUserPrincipalName.Split("@")[1]

			If( ( $userPrin.Contains("#EXT#"))  )
		 {
			 Write-Host -ForegroundColor Red "External user: $UserName  - SKIPPING"
		 }#If ext user
		 Else
		 {
				 If( (Get-AzADGroupMember -GroupDisplayName $UserGroup | Where-Object {$_.DisplayName -eq $UserName} -WarningAction:SilentlyContinue) -eq $null)
			 {
				 #Write-Host -ForegroundColor Cyan "`$UserName=`"$UserName`""
					 $members += $UserId
				 $outGroupCount++
			 }
			 Else
			 {
				 #Write-Host -ForegroundColor Green "$UserName is already a member of the $UserGroup"
				 $inGroupCount++
			 }
				 For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Yellow "=" }Else{Write-Host -ForegroundColor Yellow "=" -NoNewline}}
		 }#Else 
	}#ForEach

	<#If($debugFlag){
		 Write-host -ForegroundColor Yellow  "`$UserGroup=`"$UserGroup`""
		 Write-host -ForegroundColor Yellow  "`$groupid=`"$groupid`""
		 Write-Host -ForegroundColor Yellow "# of Users: " $allUsers.Count
		 Write-Host -ForegroundColor Yellow "# members.Count: " $members.Count
		 Write-Host -ForegroundColor Yellow "# of Users NOT in the Group: " $outGroupCount
		 Write-Host -ForegroundColor Yellow "# of Users IN the Group: " $inGroupCount
	}#>

	If($outGroupCount -ne 0)
	{
		 Add-AzADGroupMember -TargetGroupObjectId $groupid -MemberObjectId $members -WarningAction:SilentlyContinue
	}
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan "$inGroupCount users were already members of the group"
	Write-Host -ForegroundColor Cyan "Added $outGroupCount users to $UserGroup"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}} 

}#AddUsersToUserGroup


Function global:AssignUsersToResGroup
{
	Param(
			[Parameter(Mandatory = $false)] [string] $AzRole
		 ,[Parameter(Mandatory = $true)] [string] $ResourceGroupName
	)

	$Message = "ADD USER ROLE ASSIGNMENT: " + $AzRole + " FOR:" + $DeployObject.ResourceGroupName
	#
	If($debugFlag){
		 Write-Host -ForegroundColor DarkBlue -BackgroundColor White "AddRoleAssignment.[]"
		 $DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
			#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		 Write-Host -ForegroundColor Cyan "`$AzRole= `"$AzRole`""
		 Write-Host -ForegroundColor Green "`$ResourceGroupName= `"$ResourceGroupName`""
	}#If($debugFlag)#>
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}

	$AzRole = "Contributor"
	# Get all licensedUsers
	$allUsers = Get-AzADUser
	#Write-Host -ForegroundColor Yellow "# of Users: " $allUsers.Count

	Foreach ($user In $allUsers)
	{
		 $UserId = $user.Id
		 $CurrUserPrincipalName = $user.UserPrincipalName
		 $UserName = $user.DisplayName

			$userPrin = $CurrUserPrincipalName.Split("@")[0]
		 $userDomain = $CurrUserPrincipalName.Split("@")[1]

			If( ( $userPrin.Contains("#EXT#"))  )
		 {
			 Write-Host -ForegroundColor Red "External user: $UserName  - SKIPPING"
		 }#If
		 Else
		 {
			 <#
			 Write-Host -ForegroundColor Green "`$userPrin=`"$userPrin`"" 

			 Write-Host -ForegroundColor Green "`$UserName=`"$UserName`""
			 Write-Host -ForegroundColor Cyan "`$UserPrincipalName=`"$UserPrincipalName`""
			 Write-Host -ForegroundColor Cyan "`$UserId=`"$UserId`""

			#>

			AddRoleAssignment -AzRole $AzRole `
				-ResourceGroupName  $DeployObject.ResourceGroupName `
				-User $user `
				 -WarningPreference:SilentlyContinue
			 #-UserPrincipalName  $CurrUserPrincipalName `
			 #-UserId $UserId
			 #>
		 #For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Yellow "=" -NoNewline}
		 #Write-Host "`n"

			}
	}
}#AssignUsersToResGroup
