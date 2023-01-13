#CreateServicePrincipal
<#This creates the Enterprise app.

!!!!! 
One frustrating thing about creating Service Principals with PowerShell 
is they’re NOT visible under the Enterprise Apps filter.
Instead, we need to select “All Apps” and then filter by name.
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
    #, [Switch]
           # $AppRoleAssignmentRequired = $true    	
 )

    "================================================================================"					>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": CREATE SERVICE PRINCIPAL (ENTERPRISE APPLICATION): " + $AppId	>> $DeployInfo.LogFile
    "================================================================================"					>> $DeployInfo.LogFile
    
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "Step" $DeployInfo.StepCount": CREATE SERVICE PRINCIPAL (ENTERPRISE APPLICATION):"
	Write-Host -ForegroundColor Yellow "`t`t" $AppId
    Write-Host -ForegroundColor Cyan "================================================================================"
    $DeployInfo.StepCount++
	
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START CreateServicePrincipal FOR $AppName "
    #Write-Host -ForegroundColor Magenta "CreateServicePrincipal[35] Creating Service Principal for `$AppId=`"$AppId`""
    #"[" + $today + "] Creating Service Principal for" + $AppName >> $DeployInfo.LogFile
    
    #$Caller='CreateServicePrincipal[38]'    
    #PrintObject -object $DeployObject -Caller $Caller

    #Write-Host -ForegroundColor Magenta "[$today] AppRegObj.AppRoleAssignmentRequired:" $AppRoleAssignmentRequired
    $SPN = Get-AzADServicePrincipal -ApplicationId $AppId
    #Write-Host -ForegroundColor Cyan "CreateServicePrincipal[29] Get-AzADServicePrincipal (SPN):" $SPN.AppDisplayName
    #Write-Host -ForegroundColor Cyan "CreateServicePrincipal[30] SPN.ID:" $SPN.Id   
	#$SPN.Oauth2PermissionScope.AdminConsentDescription
	#$SPN.Oauth2PermissionScope.AdminConsentDisplayName
    if($SPN.DisplayName -eq $null)
    {
        $SPN = New-AzADServicePrincipal -ApplicationId $AppId 
        #https://learn.microsoft.com/en-us/powershell/module/az.resources/new-azadserviceprincipal?view=azps-9.1.0
        #-AppRoleAssignmentRequired ($DeployInfo.AppRoleAssignmentRequired).ToBoolean()    
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[17] Waiting for the SPN to be created...30 seconds"
        Start-Sleep -Seconds 10
        #Write-Host -ForegroundColor Green -BackgroundColor Black "CreateServicePrincipal[40] Created Service Principal Name (SPN):" $SPN.AppDisplayName
        #Write-Host -ForegroundColor Green -BackgroundColor Black "CreateServicePrincipal[41] SPN.ID:" $SPN.Id
        #>
        if( $SPN.AppDisplayName.Contains("api"))
        {   
            #Write-Host -ForegroundColor Yellow "CreateServicePrincipal[56] setting APIAppRegServicePrincipalId=" $SPN.Id
            #Write-Host -ForegroundColor Green -BackgroundColor Black "CreateServicePrincipal[57] SPN.AppDisplayName.Contains(api):" $SPN.AppDisplayName
            $DeployObject.APIAppRegServicePrincipalId = $SPN.Id
            #$DeployInfo.ApiServicePrincipalAppId = $SPN.AppId            
        }
        else
        {
            #Write-Host  -ForegroundColor Green  "CreateServicePrincipal[63] CLIENT ClientAppRegServicePrincipalId=" $SPN.Id
            $DeployObject.ClientAppRegServicePrincipalId = $SPN.Id
            #$DeployInfo.ClientAppServicePrincipalAppId= $SPN.Id            
        }

        #$json = ConvertTo-Json $DeployInfo

        #$json > $DeployInfo.OutFileJSON 
        
        #$Caller='CreateServicePrincipal'
        #Write-Host  -ForegroundColor Cyan "CreateServicePrincipal[32] AppRegObj:"
        #PrintHash -object $DeployInfo -Caller $Caller
        
        # Assign the Service Principal Name a role
        #Commented next 2 lines on 11/17/2022 -- need to get verification from Jason on this!
        #$PublicAzureRole = "Owner"
        #New-AzRoleAssignment -RoleDefinitionName $PublicAzureRole -ServicePrincipalName $AppId | Out-Null

        #Write-Host -ForegroundColor Cyan -BackgroundColor Black "CreateServicePrincipal[34] Wait for the AzRoleAssignment for $PublicAzureRole to be created...30 seconds"
        #Start-Sleep -Seconds 30
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black "CreateServicePrincipal[36] Time is up....AzRoleAssignment CREATED"
        $RoleAssignment = Get-AzRoleAssignment -ObjectId $SPN.Id
    }
    else
    {
        #Write-Host -ForegroundColor Green "CreateServicePrincipal[48] EXISTING SPN.Name:" $SPN.AppDisplayName
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[33] SPN.Id:" $SPN.Id
        $RoleAssignment = Get-AzRoleAssignment -ObjectId $SPN.Id        
    }
    <#
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[53] AzRoleAssignment.ObjectType:" $RoleAssignment.ObjectType
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[54] AzRoleAssignment.RoleDefinitionName:" $RoleAssignment.RoleDefinitionName
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[55] AzRoleAssignment.Scope:" $RoleAssignment.Scope
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[56] AzRoleAssignment.RoleAssignmentName:" $RoleAssignment.RoleAssignmentName   
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  " [$today] EXITING CreateServicePrincipal for $AppName"
    #>
      
    return $SPN
}#CreateServicePrincipal