#Connect-AzAccount -Environment AzureUSGovernment

#AddRoleAssignment
Function global:AddRoleAssignment
{
    Param(
         [Parameter(Mandatory = $true)] [string] $AzRole
        ,[Parameter(Mandatory = $true)] [string] $ResGroupName
        ,[Parameter(Mandatory = $true)] [object] $User
        #,[Parameter(Mandatory = $true)] [string] $CurrUserId
      )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    $StartTime = $today
     
    $UserId = $User.Id
    $UserPrincipalName = $User.UserPrincipalName
    $UserName = $User.DisplayName

    $subscription = Get-AzSubscription
    $subscriptionName=$subscription.Name
    $SubscriptionId =$subscription.Id
    $tenant = Get-AzTenant -TenantId $subscription.TenantId
      
    #$AzRole = "Contributor"
    $Scope = "/subscriptions/" + $SubscriptionId + "/resourceGroups/$ResGroupName"
    
    $UserRoleAssignments = Get-AzRoleAssignment -SignInName $UserPrincipalName | Where-Object {$_.Scope -eq $Scope }

    $AssignmentCount = ($UserRoleAssignments | Measure-Object | Select Count).Count
    Write-Host -ForegroundColor White "AddRoleAssignment[26] User has:" $AssignmentCount "Role Assignments on the Resource Group:" $ResGroupName

    If($AssignmentCount -eq 0)
    {
        $RoleAssignment = New-AzRoleAssignment -ObjectId $UserId `
            -RoleDefinitionName $AzRole `
            -ResourceGroupName $ResGroupName
        Write-Host -ForegroundColor Green "Added $AzRole Role to" $UserPrincipalName
    }
    Else
    {
        Write-Host -ForegroundColor Green $UserPrincipalName "already has the Role: $AzRole"
    }
        
   
    #To list all the roles that are assigned to a specified user and the roles that are assigned to the groups to which the user belongs
    #$UserRoleAssignment = Get-AzRoleAssignment -SignInName $DeployInfo.UserPrincipalName -ExpandPrincipalGroups
    #Write-Host -ForegroundColor Yellow "===================================================================================================="
	#Write-Host -ForegroundColor Cyan " [$today] COMPLETED ADDING ROLE ASSIGNMENT:" $AzRole    
    #Write-Host -ForegroundColor Yellow "===================================================================================================="

}#AddRoleAssignment


Function global:AssignUsersToResGroup
{
    Param(
         [Parameter(Mandatory = $false)] [string] $AzRole
        ,[Parameter(Mandatory = $true)] [string] $ResGroupName
        )   

    $AzRole = "Contributor"
    # Get all licensedUsers
    $allUsers = Get-AzADUser 
    Write-Host -ForegroundColor Yellow "# of Users: " $allUsers.Count
    Foreach ($user In $allUsers) 
    {
        $UserId = $user.Id
        $UserPrincipalName = $user.UserPrincipalName
        $UserName = $user.DisplayName
        
        $userPrin = $UserPrincipalName.Split("@")[0]     
        $userDomain = $UserPrincipalName.Split("@")[1]
        #Write-Host "userPrin=$userPrin"
        If( ( $userPrin.Contains("#EXT#"))  )
        {
            Write-Host -ForegroundColor Red "does not contain #EXT# -" not( $userDomain.Contains("#EXT#"))
        }#if
        else
        {
            <#
            Write-Host -ForegroundColor Green "`$userPrin=`"$userPrin`""        
            #>
            Write-Host -ForegroundColor Green "`$UserName=`"$UserName`""
            #Write-Host -ForegroundColor Cyan "`$UserPrincipalName=`"$UserPrincipalName`""
#            Write-Host -ForegroundColor Cyan "`$UserId=`"$UserId`""            
            #>
           #>
       
        AddRoleAssignment -AzRole $AzRole `
            -ResGroupName  $ResGroupName `
            -User $user
            #-UserPrincipalName  $UserPrincipalName `
            #-UserId $UserId
            #>
        Write-Host -ForegroundColor Yellow "================================================================================"            
            
        }
    }

}#AssignUsersToResGroup


$ResGroupName = "rg-dtp-prod"
$ResGroupName = "rg-dtp-prod"
#Get-AzResourceGroup | Where-Object {$_.ResourceGroupName.StartsWith("rg-dp") -or $_.ResourceGroupName.StartsWith("rg-dt") }

$myResourceGroups = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName.StartsWith("rg-dp") -or $_.ResourceGroupName.StartsWith("rg-dt") } | Select -Property ResourceGroupName

Foreach($ResGroup in $myResourceGroups)
{
    $ResGroupName = $ResGroup.ResourceGroupName
    Write-Host "`$ResGroupName=`"$ResGroupName`""
    AssignUsersToResGroup -ResGroupName $ResGroupName
}

