#C:\GitHub\PowerShellGoodies\RemoveStaleRoleAssignments.ps1

Function global:RemoveOrphanRoleAssignments
{
    Param(
        [Parameter(Mandatory = $true)] [string] $ResGroupName
    )
     try 
    { 
       $CurrUser = Get-AzADUser -SignedIn
       Write-Host "Current User=" $CurrUser.UserPrincipalName
    } 
    catch
    { 
    
        Write-Host "You're not connected.";
        $AzConnection = Connect-AzAccount -Environment AzureUSGovernment
    }
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    $StartTime = $today
    Write-Host -ForegroundColor Yellow "===================================================================================="
    Write-Host -ForegroundColor Yellow " [$today] REMOVING UNIDENTIFIED ROLE ASSIGNMENTS FROM:" $ResGroupName        
    Write-Host -ForegroundColor Yellow "===================================================================================="

    #$ResGroupName = "rg-depguide-prod"
    $ResGroupName = "rg-Automation"
    
    $myResourceGroup = Get-AzResourceGroup -Name $ResGroupName
    $ResourceId = $myResourceGroup.ResourceId

    $AzRoleAssignments = Get-AzRoleAssignment -ResourceGroupName $ResGroupName | Where-Object { $_.ObjectType -eq 'Unknown' } 
    $RoleCount = ($AzRoleAssignments | Measure-Object | Select Count).Count
    Write-Host -ForegroundColor Cyan "There are" $AzRoleAssignments.Count "Identity not found roles "
    <#The scope of the assignment MAY be specified and if not specified, 
        defaults to the subscription scope 
        i.e. it will try to delete an assignment to the specified principal and role at the subscription scope.
    #>
    $CurrUser = Get-AzADUser -SignedIn
    $UserPrincipalName = $CurrUser.UserPrincipalName
    Write-Host -ForegroundColor Cyan "`$UserPrincipalName=`"$UserPrincipalName`""
    $UserRoleAssignments = Get-AzRoleAssignment -SignInName $UserPrincipalName | Where-Object {$_.Scope -eq $Scope }
    $RoleCount = ($UserRoleAssignments | Measure-Object | Select Count).Count
    Write-Host -ForegroundColor Cyan "There are" $AzRoleAssignments.Count "Identity not found roles "
    <#debug
    foreach($role in $AzRoleAssignments)
    {
        Write-Host  "RoleAssignmentName:"$role.RoleAssignmentName ", ObjectType: " $role.ObjectType ",DisplayName:" $role.DisplayName         
    }
    #>

    #$UserRoleAssignments | Remove-AzRoleAssignment
    $AzRoleAssignments | Remove-AzRoleAssignment

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

RemoveOrphanRoleAssignments