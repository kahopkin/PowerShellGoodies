#C:\GitHub\PowerShellGoodies\RemoveStaleRoleAssignments.ps1

Function global:RemoveOrphanRoleAssignments
{
    Param(
        [Parameter(Mandatory = $false)] [string] $ResourceGroupName
    )
    
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
    
    $CurrUser = Get-AzADUser -SignedIn
    $CurrUserName = $CurrUser.DisplayName
    $CurrUserPrincipalName = $CurrUser.UserPrincipalName
    $CurrUserId = $CurrUser.Id       
    $ResourceGroup = $ResourceGroupName
    Write-Host "ResourceGroup.Length:" $ResourceGroup.Length
    if($ResourceGroup.Length -ne 0)
    {
        $myResourceGroup = Get-AzResourceGroup -Name $ResourceGroup
        $ResourceId = $myResourceGroup.ResourceId
        $AzRoleAssignments = Get-AzRoleAssignment -ResourceGroupName $ResourceGroup | Where-Object { $_.ObjectType -eq 'Unknown' } 
    }
    else
    {
        $AzRoleAssignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'Unknown' } 
    }
    #
    
    $RoleCount = ($AzRoleAssignments | Measure-Object | Select Count).Count
    <#The scope of the assignment MAY be specified and if not specified, 
        defaults to the subscription scope 
        i.e. it will try to delete an assignment to the specified principal and role at the subscription scope.
    #>

    $UserRoleAssignments = Get-AzRoleAssignment -SignInName $CurrUserPrincipalName | Where-Object {$_.Scope -eq $Scope }
    $RoleCount = ($UserRoleAssignments | Measure-Object | Select Count).Count
    Write-Host -ForegroundColor Cyan "There are" $AzRoleAssignments.Count "Identity not found roles "
    <#debug
    foreach($role in $AzRoleAssignments)
    {
        Write-Host  "RoleAssignmentName:"$role.RoleAssignmentName ", ObjectType: " $role.ObjectType ",DisplayName:" $role.DisplayName         
    }
    #>

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