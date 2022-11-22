#Get Service Principal of Microsoft Graph Resource API 
#$graphSP =  Get-AzureADServicePrincipal -All $true | Where-Object {$_.DisplayName -eq "Microsoft Graph"}


$AppName="depguideprod"
$AppId = "cf0423d0-2405-4058-be04-3f1fa4232686"
$AppObjectId = "18c80e69-1536-4b68-ac19-3ef395287f17"

Write-Host -ForegroundColor Yellow "AppId=""$AppId"""
Write-Host -ForegroundColor Yellow "AppObjectId=""$AppObjectId"""
Write-Host -ForegroundColor Yellow "AppName=""$AppName"""

if($PermissionParent -eq "Microsoft Graph" )
{
    Write-Host -ForegroundColor Yellow "PermissionParent=""$PermissionParent"""
    $GraphId = (Get-AzADServicePrincipal -DisplayName "$PermissionParent").AppId
    Write-Host -ForegroundColor Cyan "GraphId=""$GraphId """
        
    $GraphSPN = Get-MgServicePrincipal -Filter "AppId eq '$GraphId'"
    $GraphSPNId = $GraphSPN.Id
    Write-Host -ForegroundColor Yellow "GraphSPN.Id=""$GraphSPNId"""
        
    # Get all available Delegated permissions (Scope) for Microsoft Graph
    $AllDelegatedPermissions = $GraphSPN.Oauth2PermissionScopes        
}
else
    {
        $GraphSPN = Get-MgServicePrincipal -Filter "AppId eq '$PermissionParent'"
        Write-Host -ForegroundColor Cyan "GraphSPN.Id=""$GraphSPN.Id"""
        $AllDelegatedPermissions = $GraphSPN.Oauth2PermissionScopes    
        Write-Host -ForegroundColor Green "AllDelegatedPermissions=""$PermissionParent"""        
        #Write-Host -ForegroundColor Green "Other Permission[47] PermissionParent:" $PermissionParent        
    }
$RequiredDelegatedPermissions = $AllDelegatedPermissions | Where-Object -FilterScript { $_.Value -in $RequiredDelegatedPermissionNames }

$RequiredPermissions = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess"
    $RequiredPermissions.ResourceAppId = $GraphSPN.AppId
    




$graphSP =  Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "Microsoft Graph"} 
$GraphId=  Get-AzADServicePrincipal | Where-Object {$_.DisplayName -eq "Data Transfer Portal 1.0 API's"} 
#Initialize RequiredResourceAccess for Microsoft Graph Resource API 
$requiredGraphAccess = New-Object Microsoft.Open.AzureAD.Model.RequiredResourceAccess
$requiredGraphAccess.ResourceAppId = $graphSP.AppId
$requiredGraphAccess.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]
 
#Set Application Permissions
$ApplicationPermissions = @('User.Read.All','Reports.Read.All')
 
#Add app permissions
ForEach ($permission in $ApplicationPermissions) 
{
    $reqPermission = $null
    #Get required app permission
    $reqPermission = $graphSP.AppRoles | Where-Object {$_.Value -eq $permission}
    if($reqPermission)
    {
        $resourceAccess = New-Object Microsoft.Open.AzureAD.Model.ResourceAccess
        $resourceAccess.Type = "Role"
        $resourceAccess.Id = $reqPermission.Id    
        #Add required app permission
        $requiredGraphAccess.ResourceAccess.Add($resourceAccess)
    }
    else
    {
        Write-Host "App permission $permission not found in the Graph Resource API" -ForegroundColor Red
    }
}
 
#Set Delegated Permissions
$DelegatedPermissions = @('Directory.Read.All', 'Group.ReadWrite.All') #Leave it as empty array if not required
 
#Add delegated permissions
ForEach ($permission in $DelegatedPermissions) {
$reqPermission = $null
#Get required delegated permission
$reqPermission = $graphSP.Oauth2Permissions | Where-Object {$_.Value -eq $permission}
if($reqPermission)
{
$resourceAccess = New-Object Microsoft.Open.AzureAD.Model.ResourceAccess
$resourceAccess.Type = "Scope"
$resourceAccess.Id = $reqPermission.Id    
#Add required delegated permission
$requiredGraphAccess.ResourceAccess.Add($resourceAccess)
}
else
{
Write-Host "Delegated permission $permission not found in the Graph Resource API" -ForegroundColor Red
}
}
 
#Add required resource accesses
$requiredResourcesAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.RequiredResourceAccess]
$requiredResourcesAccess.Add($requiredGraphAccess)
 
#Set permissions in existing Azure AD App
$appObjectId=$aadApplication.ObjectId
#$appObjectId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
Set-AzureADApplication -ObjectId $appObjectId -RequiredResourceAccess $requiredResourcesAccess




$AppRegObj=@{}
$ApiAppRegObj=@{}


 #Azure Storage:
$PermissionParent = "e406a681-f3d4-42a8-90b6-c2b029497af1"
$PermissionParentName = "Azure Storage"
$RequiredDelegatedPermissionNames =
@(
    "user_impersonation"
)

#Write-Host -ForegroundColor Yellow "RunDeployment.ConfigureAPI[177] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

$RequiredPermissions = AddAPIPermissions `
    -AppName $AppName `
    -AppId $AppId `
    -AppObjectId $AppObjectId `
    -PermissionParent $PermissionParent `
    -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames




$svcprincipalPbi = Get-AzADServicePrincipal  | ? { $_.DisplayName -match "Power BI Service" }
 
$svcprincipalAAD = Get-AzADServicePrincipal  | ? { $_.DisplayName -match "Windows Azure Active Directory" }


$PermissionParent = "e406a681-f3d4-42a8-90b6-c2b029497af1"
 #Get-AzADServicePrincipal  | ? { $_.AppId -eq 

$AzureStorageSP = Get-AzADServicePrincipal  | ? { $_.DisplayName -eq "Azure Storage" }
$GraphSP = Get-AzADServicePrincipal  | ? { $_.DisplayName -eq "Microsoft Graph" }
$SpnId = $GraphSP.AppId
$PermissionId
Add-AzADAppPermission `
    -ObjectId $AppObjectId `
    -ApiId $SpnId `
    -PermissionId 5f8c59db-677d-491f-a6b8-5f174b11ec1d



$i=0
foreach ($item in $AzureStorageSP) {
    $item
    #Write-Host "AddAPIPermissions[$i]=" $item
    $i++
}    