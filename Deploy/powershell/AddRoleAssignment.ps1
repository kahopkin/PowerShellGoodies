
Function global:AddCustomRoleFromFile
{
    Param(
        #[Parameter(Mandatory = $true)] [string] $FilePath
        [Parameter(Mandatory = $true)] [Object] $DeployObject
      )                

    #$RoleDefinitionFile = $DeployFolder + $DeployObject.RoleDefinitionFile
    $RoleDefinitionFile = $DeployObject.RoleDefinitionFile
    If($debugFlag)
    {
        Write-Host "AddCustomRoleFromFile[10] RoleDefinitionFile = $RoleDefinitionFile"
    }

    $ParentFolderPath = ((Get-ItemProperty (Split-Path (Get-Item ($RoleDefinitionFile)).FullName -Parent) | select FullName).FullName)
    $RoleDefinitionFileOut = $ParentFolderPath + "\" + $(Get-Item ($RoleDefinitionFile)).BaseName + "Out.json"
    
    $MyJsonObject = Get-Content $RoleDefinitionFile -Raw | ConvertFrom-Json    
    $MyJsonObject.assignableScopes[0] = "/subscriptions/" + $DeployInfo.SubscriptionId
    $RoleAssignmentName = $MyJsonObject.Name

    $MyJsonObject | ConvertTo-Json | Out-File $RoleDefinitionFileOut
        
    "================================================================================"								>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": ADDING SUBSCRIPTION SCOPE CUSTOM ROLE DEFINITION:" + $RoleAssignmentName	>> $DeployInfo.LogFile
    "================================================================================"								>> $DeployInfo.LogFile

    Write-Host -ForegroundColor Cyan "================================================================================"    	
    Write-Host -ForegroundColor Cyan "Step" $DeployInfo.StepCount ": ADDING SUBSCRIPTION SCOPE CUSTOM ROLE DEFINITION:" 
	Write-Host -ForegroundColor Green "`t`t" $RoleAssignmentName
    Write-Host -ForegroundColor Cyan "================================================================================"
    $DeployInfo.StepCount++
            
    $RoleDefinition = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.IsCustom -eq $true -and $_.Name -eq $RoleAssignmentName}
    $CustomRoleCount = ($RoleDefinition | Measure-Object | Select Count).Count         
    #Write-Host "AddCustomRoleFromFile[30] CustomRoleCount= $CustomRoleCount"

    if($CustomRoleCount -eq 0)
    {        
        $RoleDefinition = New-AzRoleDefinition -InputFile $RoleDefinitionFileOut
        $RoleDefinitionId = $RoleDefinition.Id
        Start-Sleep -Seconds 30
        Write-Host -ForegroundColor Green "Added Custom Role Assignment:" $RoleAssignmentName
		Write-Host -ForegroundColor Green "RoleDefinitionId="$RoleDefinitionId        
        Write-Host -ForegroundColor Green "================================================================================`n"    
        
    }
    else
    {
        $RoleDefinitionId = $RoleDefinition.Id        
        Write-Host -ForegroundColor Yellow "`t`tRole:" $RoleAssignmentName "EXISTS... "		
        Write-Host -ForegroundColor Yellow "`t`tRoleDefinitionId="$RoleDefinitionId
		Write-Host -ForegroundColor White "`t`tContinuing deployment...."        
        Write-Host -ForegroundColor Yellow "================================================================================`n"
    }
    
    #if( $RoleAssignmentName -contains "DTP")
    if($DeployObject.Solution -eq "Transfer")
    {        
		#$DeployInfo.RoleDefinitionIdTransfer = $RoleDefinitionId
		$TransferAppObj.RoleDefinitionId = $RoleDefinitionId
        #Write-Host -ForegroundColor Yellow "AddCustomRoleFromFile[55] RoleAssignmentName= `"$RoleAssignmentName`" : TransferAppObj.RoleDefinitionId=`"" $TransferAppObj.RoleDefinitionId"`""
    }
    else #PickUp
    {
        #$DeployInfo.RoleDefinitionIdPickup = $RoleDefinitionId
		$PickupAppObj.RoleDefinitionId = $RoleDefinitionId		
        #Write-Host -ForegroundColor Yellow "AddCustomRoleFromFile[60] RoleAssignmentName= `"$RoleAssignmentName`" : PickupAppObj.RoleDefinitionId=`"" $PickupAppObj.RoleDefinitionId "`""
    }
    
    #Write-Host -ForegroundColor Yellow "AddCustomRoleFromFile[58] RoleAssignmentName= `"$RoleAssignmentName`" : RoleDefinitionIdDPP=`"" $DeployInfo.RoleDefinitionIdDPP "`""
    #Write-Host -ForegroundColor Yellow "AddCustomRoleFromFile[59] RoleAssignmentName= `"$RoleAssignmentName`" : RoleDefinitionIdTPP=`"" $DeployInfo.RoleDefinitionIdDTP"`""

    #$Caller='AddCustomRoleFromFile[61]' 
    #PrintHash -object $DeployInfo -Caller $Caller
    #return $RoleDefinitionId
    return $RoleDefinition
}#AddCustomRoleFromFile

#AddRoleAssignment
Function global:AddRoleAssignment
{
    Param(
         [Parameter(Mandatory = $false)] [string] $AzRoleName
       #,[Parameter(Mandatory = $true)] [string] $RoleDefinitionId
        ,[Parameter(Mandatory = $true)]  [string] $ResourceGroupName
        ,[Parameter(Mandatory = $false)] [Object] $User   
        ,[Parameter(Mandatory = $true)]  [Object] $DeployObject     
    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Debug "AddRoleAssignment.AddRoleAssignment[92]"
    <#If($debugFlag)
    {
		Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[92] "
        Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
        Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
        Write-Host -ForegroundColor Yellow "`$User=`""$User.Id"`""
    }#>
	
    $Scope = "/subscriptions/" + $DeployObject.SubscriptionId + "/resourceGroups/$ResourceGroupName"
    #Write-Host -ForegroundColor Cyan "`$Scope=`"$Scope`""
    #$UserRoleAssignment = Get-AzRoleAssignment -SignInName $CurrUserPrincipalName -Scope $Scope
    
    $userType = ($User.GetType()).Name
    #Write-Host -ForegroundColor Yellow "AddRoleAssignment[105] User.GetType()=" $userType
    
    If($userType -eq "MicrosoftGraphUser")
    {   
        $UserId = $User.Id
        $CurrUserPrincipalName = $User.UserPrincipalName
        $UserName = $User.DisplayName
        $UserRoleAssignments = Get-AzRoleAssignment -SignInName $CurrUserPrincipalName | Where-Object {$_.Scope -eq $Scope }
    }
     #MicrosoftGraphGroup
    ElseIf($userType -eq "MicrosoftGraphGroup")
    {
        $UserId = $User.Id
        $UserName = $User.DisplayName
        #Write-Host -ForegroundColor Green "AddRoleAssignment[90] `$UserName=`"$UserName`""
        $UserRoleAssignments = Get-AzRoleAssignment -ObjectId $UserId | Where-Object {$_.Scope -eq $Scope }
    }
    ElseIf($userType -eq "MicrosoftGraphApplication" -or $userType -eq "MicrosoftGraphServicePrincipal")
    {
        #PSResource
        $UserId = $User.Id
        $UserName = $User.DisplayName
        #Write-Host -ForegroundColor Green "`$UserName=`"$UserName`""
        #Write-Host -ForegroundColor Green "`$UserId=`"$UserId`""
        $UserRoleAssignments = Get-AzRoleAssignment -ObjectId $UserId | Where-Object {$_.Scope -eq $Scope }
        #New-AzRoleAssignment -ApplicationId $UserId -ResourceGroupName $ResourceGroupName -RoleDefinitionName $AzRoleName
    }
    
    $AssignmentCount = ($UserRoleAssignments | Measure-Object | Select Count).Count
    #Write-Host -ForegroundColor Cyan "AddRoleAssignment[113] User has:" $AssignmentCount "Role Assignments on the Resource Group:" $ResourceGroupName

    If($AssignmentCount -eq 0)
    {
        $RoleAssignment = New-AzRoleAssignment `
            -ObjectId $UserId `
            -RoleDefinitionName $AzRoleName `
            -ResourceGroupName $ResourceGroupName
        Write-Host -ForegroundColor Green "Added $AzRoleName Role to" $UserName
    }
    Else
    {
        Write-Host -ForegroundColor Yellow $UserName "already has $AzRoleName Role"
    }
        
    "Resource Group Name: " + $DeployObject.ResourceGroupName >> $DeployObject.LogFile
    "Resource Group's ResourceId: " + $ResourceId >> $DeployObject.LogFile

    #To list all the roles that are assigned to a specified user and the roles that are assigned to the groups to which the user belongs
    #$UserRoleAssignment = Get-AzRoleAssignment -SignInName $DeployInfo.CurrUserPrincipalName -ExpandPrincipalGroups
    Write-Host -ForegroundColor Yellow "================================================================================"
	Write-Host -ForegroundColor Cyan " [$today] COMPLETED ADDING ROLE ASSIGNMENT:" $AzRoleName    
    Write-Host -ForegroundColor Yellow "================================================================================"

}#AddRoleAssignment



Function global:AssignUsersToResGroup
{
    Param(
         [Parameter(Mandatory = $false)] [string] $AzRole
        ,[Parameter(Mandatory = $true)] [string] $ResourceGroupName
    )

    Write-Debug "AddRoleAssignment.AssignUsersToResGroup[139]"
    If($debugFlag)
    {
		Write-Host -ForegroundColor Magenta "AddRoleAssignment.AssignUsersToResGroup[142] "
    }	

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    #$StartTime = $today
	
	"================================================================================"									>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": ADD USER ROLE ASSIGNMENT: " + $AzRole + " FOR:" + $DeployInfo.ResourceGroupName	>> $DeployInfo.LogFile
    "================================================================================"									>> $DeployInfo.LogFile
    
	Write-Host -ForegroundColor Yellow "================================================================================"	
    Write-Host -ForegroundColor Yellow "Step" $DeployInfo.StepCount": ADD USER ROLE ASSIGNMENT:"$AzRole "FOR:" $DeployInfo.ResourceGroupName 
    Write-Host -ForegroundColor Yellow "================================================================================"
    $DeployInfo.StepCount++
    
    #Write-Host -ForegroundColor Cyan "`$ResourceGroupName=`"$ResourceGroupName`""            
    
    $AzRole = "Contributor"
    # Get all licensedUsers
    $allUsers = Get-AzADUser 
    Write-Host -ForegroundColor Yellow "# of Users: " $allUsers.Count
	
    Foreach ($user In $allUsers) 
    {
        $UserId = $user.Id
        $CurrUserPrincipalName = $user.UserPrincipalName
        $UserName = $user.DisplayName
        
        $userPrin = $CurrUserPrincipalName.Split("@")[0]     
        $userDomain = $CurrUserPrincipalName.Split("@")[1]
        #Write-Host "userPrin=$userPrin"
        If( ( $userPrin.Contains("#EXT#"))  )
        {
            Write-Host -ForegroundColor Red "External user: $UserName  - SKIPPING"
        }#if
        else
        {
            <#
            Write-Host -ForegroundColor Green "`$userPrin=`"$userPrin`""        
            
            Write-Host -ForegroundColor Green "`$UserName=`"$UserName`""
            Write-Host -ForegroundColor Cyan "`$UserPrincipalName=`"$UserPrincipalName`""
            Write-Host -ForegroundColor Cyan "`$UserId=`"$UserId`""            
            
           #>
       
			AddRoleAssignment -AzRole $AzRole `
				-ResourceGroupName  $DeployInfo.ResourceGroupName `
				-User $user
            #-UserPrincipalName  $CurrUserPrincipalName `
            #-UserId $UserId
            #>
        Write-Host -ForegroundColor Yellow "================================================================================"            
            
        }
    }

}#AssignUsersToResGroup


Function global:CreateAzGroup
{
    Param(
         [Parameter(Mandatory = $true)] [string] $GroupName
        ,[Parameter(Mandatory = $false)] [string] $MailNickname
       )
    
    Write-Debug "AddRoleAssignment.CreateAzGroup[235]"
    <#If($debugFlag)
    {
		Write-Host -ForegroundColor Magenta "AddRoleAssignment.CreateAzGroup[238] "
    }#>

    "================================================================================"								>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": CREATE AD GROUP:" + $GroupName	>> $DeployInfo.LogFile
    "================================================================================"								>> $DeployInfo.LogFile

    Write-Host -ForegroundColor Cyan "================================================================================"    	
    Write-Host -ForegroundColor Cyan "Step" $DeployInfo.StepCount ": CREATE AD GROUP:" $GroupName 	
    Write-Host -ForegroundColor Cyan "================================================================================"
    $DeployInfo.StepCount++

    $MailNickname = $GroupName.replace(' ' , '')
    $UserGroup = Get-AzADGroup -DisplayName $GroupName                
    #Write-Host $MailNickname
    If($UserGroup -eq $null)
    {                
        $UserGroup = New-AzADGroup -DisplayName $GroupName -MailNickname $MailNickname
    }
    
    return $UserGroup

}#CreateAzGroup
<#
Function global:AddCustomRole
{
    Param(
        [Parameter(Mandatory = $true)] [string] $RoleAssignmentName
      )
    Write-Debug "XXX.XXX[]"
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

    if($CustomRoleCount -eq 0)
    {        
        New-AzRoleDefinition -Role $role
        Write-Host -ForegroundColor Green -BackgroundColor White "Added custom role assignment: $RoleAssignmentName, continuing deployment...."
    }
    else
    {
        Write-Host -ForegroundColor Red -BackgroundColor White "Custom role assignment: $RoleAssignmentName EXISTS"
    }    

}#AddCustomRole
#>