#CreateServicePrincipal

# Create a Service Principal Name (SPN) for the application created earlier
Function global:CreateServicePrincipal{
 Param(            
      [Parameter(Mandatory = $true)] [String]$AppId    
    , [Parameter(Mandatory = $true)]  $AppRegObj    
 )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START CreateServicePrincipal FOR $AppName "        
    
    $PublicAzureRole = "Owner"
    $SPN = Get-AzADServicePrincipal -ApplicationId $AppId
    
    if($SPN.DisplayName -eq $null)
    {
        $SPN = New-AzADServicePrincipal -ApplicationId $AppId    
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[17] Waiting for the SPN to be created...30 seconds"
        Start-Sleep -Seconds 30
        Write-Host -ForegroundColor Cyan -BackgroundColor Black "CreateServicePrincipal[19] Created Service Principal Name (SPN):" $SPN.AppDisplayName
        Write-Host -ForegroundColor Cyan -BackgroundColor Black "CreateServicePrincipal[20] SPN.ID:" $SPN.Id
        if( $AppName.Contains("api"))
        {   
            $AppRegObj.ApiServicePrincipalId= $SPN.Id
        }
        else
        {
            $AppRegObj.WebClientServicePrincipalId= $SPN.Id
        }
        $json = ConvertTo-Json $AppRegObj

        $json > $OutFileJSON 
        
        $Caller='CreateServicePrincipal'
        #Write-Host  -ForegroundColor Cyan "CreateServicePrincipal[32] AppRegObj:"
        #PrintHashTable -object $AppRegObj -Caller $Caller
        
        # Assign the Service Principal Name a role
        New-AzRoleAssignment -RoleDefinitionName $PublicAzureRole -ServicePrincipalName $AppId | Out-Null

        Write-Host -ForegroundColor Cyan -BackgroundColor Black "CreateServicePrincipal[34] Wait for the AzRoleAssignment for $PublicAzureRole to be created...30 seconds"
        Start-Sleep -Seconds 30
        Write-Host -ForegroundColor Cyan -BackgroundColor Black "CreateServicePrincipal[36] Time is up....AzRoleAssignment CREATED"
        $RoleAssignnemt = Get-AzRoleAssignment -ObjectId $SPN.Id
    }
    else
    {
        Write-Host -ForegroundColor Green "CreateServicePrincipal[48] EXISTING SPN.Name:" $SPN.AppDisplayName
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[33] SPN.Id:" $SPN.Id
        $RoleAssignnemt = Get-AzRoleAssignment -ObjectId $SPN.Id        
    }
    <#
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[53] AzRoleAssignment.ObjectType:" $RoleAssignnemt.ObjectType
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[54] AzRoleAssignment.RoleDefinitionName:" $RoleAssignnemt.RoleDefinitionName
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[55] AzRoleAssignment.Scope:" $RoleAssignnemt.Scope
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[56] AzRoleAssignment.RoleAssignmentName:" $RoleAssignnemt.RoleAssignmentName   
    #>
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  " [$today] EXITING CreateServicePrincipal for $AppName `n"
    
    
    return $SPN
}