<#
https://www.reddit.com/r/PowerShell/comments/mvm1u2/adding_api_permissions_to_azure_ad_apps_with/
Adding API Permissions to Azure AD Apps with Powershell
#>

#Script to setup Ad Sync with Azure AD and Datto PSA

#

# Created by Pebkac - 21.04.21

#

# This script does the AzureAD work for your clients tenant when setting up AzureAD sync

# WARNING: I am not a Powershell Expert and just butched bits of other peoples scripts together

#

#

# API Permissions butchered script: https://rajanieshkaushikk.com/2019/07/31/how-to-assign-permissions-to-azure-ad-app-by-using-powershell/





#Variables:



# Azure App name

$appName = "DattoPSASync"

# Dynamic AzureAD Group user name

$groupName = "DattoPSASync"

# Dynamic AzureAD Group description

$groupDesc = "Dynamic group used to sync users to Datto PSA. Selects users with Azure AD P1 Only"

# Dynamic AzureAD Group query (User has AzureAD P1 as part of their subscription

$groupQuery = "user.assignedPlans -any (assignedPlan.servicePlanId -eq ""41781fb2-bc02-4b7c-bd55-b576c07bb09d"" -and assignedPlan.capabilityStatus -eq ""Enabled"")"

# Dynamic AzureAD Group Mail NickName - This is required for some reason even through it's not a mail enabled group

$groupMailNickName = $groupName





#Checking correct PowerShell Modules are installed

if (Get-Module -ListAvailable -Name AzureADPreview) {

cls

Write-Host "AzureAD Preview Module - Installed" -ForegroundColor Yellow

} else {

cls

Write-Host "Installing Azure AD Preview Module" -ForegroundColor Yellow

Install-Module AzureADPreview -Force

}



#Connect to AzureAD

try {

$var = Get-AzureADTenantDetail

}

catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {

Connect-AzureAD

}

Write-Host "Connected to AzureAD" -ForegroundColor Yellow





#Create App Registration:

if(!($myApp = Get-AzureADApplication -Filter "DisplayName eq '$($appName)'" -ErrorAction SilentlyContinue))

{

$myApp = New-AzureADApplication -DisplayName $appName

}



Write-Host "App Created" -ForegroundColor Yellow



$myAppObjectID = Get-AzureADApplication -Filter "DisplayName eq '$appName'"



Write-Host "Waiting for Azure to do it's thing" -ForegroundColor Yellow

#Sleep cycle to wait for app to be created

Start-Sleep -Seconds 10



#Create Client Secret

$startDate = Get-Date

$endDate = $startDate.AddYears(3)

$aadAppsecret01 = New-AzureADApplicationPasswordCredential -ObjectId $myAppObjectID.ObjectID -CustomKeyIdentifier "DattoPSASyncSecret01" -StartDate $startDate -EndDate $endDate



Write-Host "Client secret created" -ForegroundColor Yellow



#Add Permissions - Info from: https://rajanieshkaushikk.com/2019/07/31/how-to-assign-permissions-to-azure-ad-app-by-using-powershell/

$svcprincipalGraph = Get-AzureADServicePrincipal -All $true | ? { $_.DisplayName -eq "Microsoft Graph" }

$svcprincipalGraph.AppRoles | FT ID, DisplayName

$svcprincipalGraph.Oauth2Permissions | FT ID, UserConsentDisplayName

$Graph = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"

$Graph.ResourceAppId = $svcprincipalGraph.AppId

$AppPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "06da0dbc-49e2-44d2-8312-53f166ab848a","Scope" ## Allows app to read all directory data

$AppPermission2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "c5366453-9fb0-48a5-a156-24f0c49a4b84","Scope" ## Allows app to read and write data but not delete



#Assign the delegated permissions to the resource access objects

$Graph.ResourceAccess = $AppPermission1, $AppPermission2



#Set the Required resource access object to the application ID so permissions can be assigned

$ADApplication = Get-AzureADApplication -All $true | ? { $_.AppId -match $myAppObjectID.AppID }



Set-AzureADApplication -ObjectId $ADApplication.ObjectId -RequiredResourceAccess $Graph



Write-Host "App permissions assigned" -ForegroundColor Yellow



#Get Azure Tenant ID

$AzTenantID = (Get-AzureADTenantDetail).ObjectId



#Create Dynamic User Group

$DynamicGroup = New-AzureADMSGroup -Description "$($groupDesc)" -DisplayName "$($groupName)" -MailEnabled $false -MailNickname "$($groupMailNickName)" -SecurityEnabled $true -GroupTypes "DynamicMembership" -MembershipRule "$($groupQuery)" -MembershipRuleProcessingState "On"



#Wait for 5 seconds for group to be created

Start-Sleep -Seconds 5



Write-Host "Dynamic user group created" -ForegroundColor Yellow



#Get Group ID

$groupID = Get-AzureADGroup -Filter "DisplayName eq '$groupName'"



#Close connection to AzureAD



Disconnect-AzureAD



Write-Host "Disconnected from Azure" -ForegroundColor Yellow



Write-Host ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::"



#Output to screen of important info for Datto

Write-Host "Please keep the following information safe, you will need it in Datto PSA:" -ForegroundColor Red -BackgroundColor Yellow

Write-Host "Application (Client) ID: " -ForegroundColor Yellow -NoNewline; Write-Host $myAppObjectID.AppID

Write-Host "App Object ID: " -ForegroundColor Yellow -NoNewline; Write-Host $myAppObjectID.ObjectID

Write-Host "App (Client) Secret: " -ForegroundColor Yellow -NoNewline; Write-Host $aadAppsecret01.Value

Write-Host "App Expiry Date: " -ForegroundColor Yellow -NoNewline; Write-Host $aadAppsecret01.EndDate

Write-Host "Tenant ID: " -ForegroundColor Yellow -NoNewline; Write-Host $AzTenantID

Write-Host "Group ID: " -ForegroundColor Yellow -NoNewline; Write-Host $groupID.ObjectID

