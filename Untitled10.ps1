$AppRegObj=@{}
$ApiAppRegObj=@{}

$AppName ="FriDTPapi"

 $AdApplication = Get-AzADApplication -DisplayName $AppName 
 $AppId = $AdApplication.Id
 $SPN = Get-AzADServicePrincipal -ApplicationId $AppId

$AppRoleAssignmentRequired=@{
    appRoleAssignmentRequired = "true"
} | ConvertTo-Json

 Update-AzADServicePrincipal -ObjectId $SPN.Id -AppRoleAssignmentRequired $AppRoleAssignmentRequired

$ApiAppRegObj = CreateAppRegistration -AppName $AppName -AppRegObj $AppRegObj

$AppId = $ApiAppRegObj.ApiClientId
$AppObjectId = $ApiAppRegObj.ApiAppObjectId
$AppName = $ApiAppRegObj.ApiAppRegName

$SPN = CreateServicePrincipal -AppId $AppId -AppRegObj $ApiAppRegObj

$ExposeScope = CreateScope `
            -AppName "$AppName" `
            -Value "DTP.Standard.Use" `
            -UserConsentDisplayName "Permits use of $AppName via front-end app" `
            -UserConsentDescription "Permits use of $AppName via front-end app" `
            -AdminConsentDisplayName "Permits use of $AppName via front-end app" `
            -AdminConsentDescription "Permits use of $AppName via front-end app" `
            -IsEnabled $true `
            -Type "User"


#Azure Storage:
$PermissionParentId = "e406a681-f3d4-42a8-90b6-c2b029497af1"
$PermissionParentName = "Azure Storage"
$RequiredDelegatedPermissionNames =
@(
    "user_impersonation"
)

<#
$RequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParentName $PermissionParentName `
            -PermissionParentId $PermissionParentId `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames
#>
$ApiObj = Get-AzADServicePrincipal -DisplayName $PermissionParentName
$type = $ApiObj.GetType() 
 If( $type.BaseType.FullName -eq "System.Object" )
    {
        #System.Object
        Write-Host -ForegroundColor Yellow "AddAPIPermissions[48] type.BaseType.FullName:" $type.BaseType.FullName
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
            $RequiredResourcesAccessList.Add($RequiredPermissions)
            Update-AzADApplication `
                -ObjectId $AppObjectId `
                -RequiredResourceAccess $RequiredResourcesAccessList
            Write-Host "[$i]" $NewDelegatedPermission.Id        
            $i++
        }

    }
    else #System.Array
    {
        #System.Array
        Write-Host -ForegroundColor Green "AddAPIPermissions[68] type.BaseType.FullName:" $type.BaseType.FullName
        $i=0
        foreach ($item in $ApiObj) 
        {
            $AllDelegatedPermissions = $item.Oauth2PermissionScope
            #Write-Host "[$i] AllDelegatedPermissions=" $AllDelegatedPermissions
            If($PermissionParentId -ne $null -and $item.AppId -eq $PermissionParentId)
            {
                Write-Host -ForegroundColor Cyan "AppId: " $item.AppId
                Write-Host -ForegroundColor Cyan "Oauth2PermissionScope: " $item.Oauth2PermissionScope.value
                $RequiredDelegatedPermissions = $AllDelegatedPermissions | Where-Object -FilterScript { $_.Value -in $RequiredDelegatedPermissionNames }
                Write-Host "AddAPIPermissions[75] RequiredDelegatedPermissions.Count: "$RequiredDelegatedPermissions.Count
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
                    $RequiredResourcesAccessList.Add($RequiredPermissions)
                    Update-AzADApplication `
                        -ObjectId $AppObjectId `
                        -RequiredResourceAccess $RequiredResourcesAccessList
                    #Write-Host "[$j]" $NewDelegatedPermission.Id        
                    $j++
                }

                $i++
            }
            Else
            {
                Write-Host -ForegroundColor Yellow "AppId: " $item.AppId
                Write-Host -ForegroundColor Yellow "Oauth2PermissionScope: " $item.Oauth2PermissionScope.value
            }
        }#outer foreach
    } #else




#MS Graph Delegated Permissions:
        $GraphSP = Get-AzADServicePrincipal  | ? { $_.DisplayName -eq "Microsoft Graph" }
        $PermissionParentId = $GraphSP.AppId
        $PermissionParentName = "Microsoft Graph"
        $RequiredDelegatedPermissionNames =
        @(
            "User.Read"
        )
