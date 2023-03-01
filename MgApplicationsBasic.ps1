<#
https://learn.microsoft.com/en-us/graph/tutorial-applications-basics?tabs=powershell%2Cphp
#>
Import-Module Microsoft.Graph.Applications

<#
Configure other basic properties for your app
Least privilege delegated permission: Application.ReadWrite.All

You'll configure the following basic properties for the app.

Add tags for categorization in the organization. 
Also, use the HideApp tag to hide the app from My Apps and the Microsoft 365 Launcher.
Add basic information including the logo, terms of service, and privacy statement.
Store contact information about the application
#>

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


<#
Limit app sign-in to only assigned identities
Least privilege delegated permission: Application.ReadWrite.All
PATCH https://graph.microsoft.com/v1.0/servicePrincipals/89473e09-0737-41a1-a0c3-1418d6908bcd

{
    "appRoleAssignmentRequired": true
}

#>

<#
Assign permissions to an app
While you can assign permissions to an app through the Azure portal, 
you also assign permissions through Microsoft Graph by updating the requiredResourceAccess property of the app object. 
You must pass in both existing and new permissions. 
Passing in only new permissions overwrites and removes the existing permissions that haven't yet been consented to.

Assigning permissions doesn't automatically grant them to the app. 
You must still grant admin consent using the Azure portal. 
To grant permissions without interactive consent, see Grant or revoke API permissions programmatically.

Least privilege delegated permission: Application.ReadWrite.All
#>
<#
PATCH https://graph.microsoft.com/v1.0/applications/581088ba-83c5-4975-b8af-11d2d7a76e98
Content-Type: application/json

{
    "requiredResourceAccess": [
        {
            "resourceAppId": "00000002-0000-0000-c000-000000000000",
            "resourceAccess": [
                {
                    "id": "311a71cc-e848-46a1-bdf8-97ff7156d8e6",
                    "type": "Scope"
                },
                {
                    "id": "3afa6a7d-9b1a-42eb-948e-1650a849e176",
                    "type": "Role"
                }
            ]
        }
    ]
}
#>


<#
Create app roles on an application object
PATCH https://graph.microsoft.com/v1.0/applications/bbd46130-e957-4c38-a116-d4d02afd1057
Content-Type: application/json

{
    "appRoles": [
        {
            "allowedMemberTypes": [
                "User",
                "Application"
            ],
            "description": "Survey.Read",
            "displayName": "Survey.Read",
            "id": "7a9ddfc4-cc8a-48ea-8275-8ecbffffd5a0",
            "isEnabled": false,
            "origin": "Application",
            "value": "Survey.Read"
        }
    ]
}
#>

Import-Module Microsoft.Graph.Applications

$params = @{
	AppRoles = @(
		@{
			AllowedMemberTypes = @(
				"User"
			)
			Description = "Survey.ReadWrite.All"
			DisplayName = "Survey.ReadWrite.All"
			Id = "3ce57053-0ebf-42d8-bf7c-74161a450e4b"
			IsEnabled = $true
			Value = "Survey.ReadWrite.All"
		}
		@{
			AllowedMemberTypes = @(
				"User"
				"Application"
			)
			Description = "Survey.Read"
			DisplayName = "Survey.Read"
			Id = "7a9ddfc4-cc8a-48ea-8275-8ecbffffd5a0"
			IsEnabled = $false
			Origin = "Application"
			Value = "Survey.Read"
		}
	)
}

Update-MgServicePrincipal -ServicePrincipalId $servicePrincipalId -BodyParameter $params

<#
Identify ownerless service principals and service principals with one owner
Least privilege delegated permission: Application.ReadWrite.All

This request requires the ConsistencyLevel header set to eventual because $count is in the request. 
For more information about the use of ConsistencyLevel and $count, 
see Advanced query capabilities on Azure AD directory objects
[https://learn.microsoft.com/en-us/graph/aad-advanced-queries].

This request also returns the count of the apps that match the filter condition.
#>
Import-Module Microsoft.Graph.Applications

Get-MgServicePrincipal `
    -Filter "owners/`$count eq 0 or owners/`$count eq 1" `
    -CountVariable CountVar `
    -ConsistencyLevel eventual

<#
Assign an owner to an app
Least privilege delegated permission: Application.ReadWrite.All

In the following request, 8afc02cb-4d62-4dba-b536-9f6d73e9be26 is the object ID for 
a user or service principal.
#>

Import-Module Microsoft.Graph.Applications

$params = @{
	"@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/8afc02cb-4d62-4dba-b536-9f6d73e9be26"
}

New-MgApplicationOwnerByRef -ApplicationId $applicationId -BodyParameter $params


<#
Assign an owner to a service principal
Least privilege delegated permission: Application.ReadWrite.All

The following request references the service principal using its appId. 
8afc02cb-4d62-4dba-b536-9f6d73e9be26 is the object ID for a user or service principal.
#>

POST https://graph.microsoft.com/v1.0/servicePrincipals(appId='46e6adf4-a9cf-4b60-9390-0ba6fb00bf6b')/owners/$ref
Content-Type: application/json

{
    "@odata.id": "https://graph.microsoft.com/v1.0/directoryObjects/8afc02cb-4d62-4dba-b536-9f6d73e9be26"
}
