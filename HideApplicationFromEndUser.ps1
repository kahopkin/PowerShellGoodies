<#
https://learn.microsoft.com/en-us/graph/api/serviceprincipal-post-serviceprincipals?view=graph-rest-1.0&tabs=powershell
#>
#Import-Module Microsoft.Graph.Applications
$AppId = "094cc3b3-b546-419f-98fc-bffb5a038cbb"
$params = @{
	AppId = "094cc3b3-b546-419f-98fc-bffb5a038cbb"
}

New-MgServicePrincipal -BodyParameter $params

#Least privilege delegated permission: Application.ReadWrite.All
$AzMgConnection = Connect-MgGraph -Environment USGov -Scopes "Application.ReadWrite.All, Directory.AccessAsUser.All, Application.Read.All" 

#https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/hide-application-from-user-portal?pivots=ms-powershell
#Hide an application from the end user

$context = Get-MgContext -ErrorAction Stop

#Get-MgEnvironment 
#Get-MgEnvironment | Select Name | Format-table
    #USGovDoD,Germany,USGov,China,Global
#Connect-MgGraph -Environment USGov


$APIAppRegName="DtsTransferAPI"
$APIAppRegAppId="ed4f4b20-2742-4b90-9675-3ab01fd4e785"
$APIAppRegObjectId="94bcb02c-d634-4467-9066-d94ec3f4e2ef"
$APIAppRegSecret="dk3T5Pk0a56V-M.P4ccP0N37.p5O~T8.qV"
$APIAppRegServicePrincipalId="e9c305cd-af9b-4eb5-80e1-638969773838"
$objectId = "8837dabd-583a-4b64-8e72-572c8538dda5"
$APIAppRegServicePrincipalId="66d7a8e4-c6be-4f2d-ba7a-c40f4bf3af37"
$CurrUserId="1f1f0e38-6e1c-4875-b7ea-80a526039896"
$CurrUserPrincipalName="kahopkins.ca@bmtndev.onmicrosoft.us"
$SPN = Get-MgServicePrincipal -ServicePrincipalId $APIAppRegServicePrincipalId
$SPN = Get-AzADApplication -ObjectId $APIAppRegObjectId
$AzADSpCredential = Get-AzADSpCredential
$AppRoles = $SPN.AppRoles

$SPN.AppRoles[0].DisplayName

$params = @{
    "PrincipalId" =$userId
    "ResourceId" =$sp.Id
    "AppRoleId" =($sp.AppRoles | Where-Object { $_.DisplayName -eq $app_role_name }).Id
    }

# Assign the user to the app role
$AppRoleAssignment = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRoleAssignment
$AppRoleAssignmentList = New-Object 'System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRoleAssignment]'
$AppRoleAssignment.PrincipalId = $CurrUserId
$AppRoleAssignment.ResourceId = $SPN.Id


New-MgUserAppRoleAssignment -UserId $userId -BodyParameter $params |
    Format-List Id, AppRoleId, CreationTime, PrincipalDisplayName,
    PrincipalId, PrincipalType, ResourceDisplayName, ResourceId

IMicrosoftGraphAppRoleAssignment

$tags = $SPN.tags
$tags += "HideApp"
$tags += "ShowApp"

Update-MgServicePrincipal -ServicePrincipalID  $APIAppRegServicePrincipalId -Tags $tags
Update-AzADServicePrincipal -ObjectId $SPN.Id -AppRoleAssignedTo $AppRoleAssignmentList

$tenantId = $DeployObject.TenantId
#BMTN
$tenantId =  "f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0"
$AppName = "Graph"

#Connect-MgGraph -Environment USGov -ClientId $AppId -TenantId $tenantId -Scopes 'https://graph.microsoft.us/.default'

#https://learn.microsoft.com/en-us/graph/migrate-azure-ad-graph-configure-permissions?view=graph-rest-1.0&tabs=powershell%2Cupdatepermissions-azureadgraph-powershell
Import-Module Microsoft.Graph.Applications

$GraphUrl="https://graph.windows.net/"

$APIAppRegName="DtsTransferAPI"
$APIAppRegAppId="b8181973-6382-4e47-b92c-850827f83dd9"
$APIAppRegObjectId="d5b256f5-5fc5-4477-935a-2567d623ae21"
$APIAppRegSecret="3Sc4TB--c1.sYM5MI0O4P77ZY~gzb2MzO6"
$APIAppRegServicePrincipalId="567d4a93-c9d6-4b63-8ade-6548d0dbab7a"

$ClientAppRegName="DtsTransfer"
$ClientAppRegAppId="061394b0-68a7-41b1-9abb-e8fb5cbd3df8"
$ClientAppRegObjectId="728898bd-63fb-4b53-bfe4-f587daf49ffc"
$ClientAppRegSecret="D_Lm1S~e.O42B6A3.Waa2ULlRGLEjUaL4Y"
$ClientAppRegServicePrincipalId="bd900a4d-bbcc-45a0-9270-ca6b4ae75e60"



$AppId = $APIAppRegAppId
$AdApplication = Get-AzADServicePrincipal -ApplicationId $AppId
Update-AzADServicePrincipal -AppRoleAssignmentRequired
#$AdApplication = Get-AzADApplication -ObjectId $ObjectId
$AppName = $AdApplication.DisplayName    
    
#Write-Host -ForegroundColor Yellow "SetRedirectURI[16] Adding redirect URIs for $AppName with $ObjectId";
$redirectUris = @()
$WebAppUrl = "https://$AppName.azurewebsites.us"
if ($redirectUris -notcontains "$WebAppUrl") {
    $redirectUris += "$WebAppUrl"   
    #Write-Host "SetRedirectURI[21] Adding $WebAppUrl to redirect URIs";
}
      
$accesstoken = (Get-AzAccessToken -Resource $GraphUrl).Token


ServiceManagementReference = "Owners aliases:" + $CurrUserPrincipalName + ";"
    
$header = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'Bearer ' + $accesstoken
}

$tags += "ShowApp"

<#
$body = @{
    'spa' = @{
        'redirectUris' = $redirectUris
    }
} 
#>
$body = @{
    ServiceManagementReference = "Owners aliases:" + $CurrUserPrincipalName + ";"
} 
        
$bodyJson = ConvertTo-Json $body

$GraphUrl = "https://graph.microsoft.us/v1.0/applications/$ObjectId"

Invoke-RestMethod -Method Patch -Uri $GraphUrl -Headers $header -Body $bodyJson
  


<#from
https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/add-application-portal-configure?pivots=ms-powershell
#>
Import-Module Microsoft.Graph.Applications

$params = @{
	Tags = @(
		"HR"
		"Payroll"
		"HideApp"
	)
	Info = @{
		LogoUrl = "https://cdn.pixabay.com/photo/2016/03/21/23/25/link-1271843_1280.png"
		MarketingUrl = "https://www.contoso.com/app/marketing"
		PrivacyStatementUrl = "https://www.contoso.com/app/privacy"
		SupportUrl = "https://www.contoso.com/app/support"
		TermsOfServiceUrl = "https://www.contoso.com/app/termsofservice"
	}
	Web = @{
		HomePageUrl = "https://www.contoso.com/"
		LogoutUrl = "https://www.contoso.com/frontchannel_logout"
		RedirectUris = @(
			"https://localhost"
		)
	}
	ServiceManagementReference = "Owners aliases: Finance @ contosofinance@contoso.com; The Phone Company HR consulting @ hronsite@thephone-company.com;"
}

Update-MgApplication -ApplicationId $applicationId -BodyParameter $params



ForEach($AppRole in $AppRoles)
{
    $AppRoleDisplayName = $AppRole.DisplayName
    $AppRoleId = $AppRole.Id
    Write-Host -ForegroundColor Green "`$AppRoleDisplayName=`"$AppRoleDisplayName`""
    Write-Host -ForegroundColor Yellow "`$AppRoleId=`"$AppRoleId`""
    $PrincipalId = $CurrUserId
    Write-Host "`$PrincipalId=`"$PrincipalId`""

    $AppRoleAssignment = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRoleAssignment            
    $AppRoleAssignment.PrincipalId = $PrincipalId
    $AppRoleAssignment.AppRoleId = $AppRole.Id
    $AppRoleAssignment.ResourceId = $SPN.Id
    $AppRoleAssignmentList.Add($AppRoleAssignment)
}#foreach