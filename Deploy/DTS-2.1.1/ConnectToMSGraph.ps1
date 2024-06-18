#ConnectToMSGraph

<#\RUN:
.\ConnectToMSGraph.ps1  -SignInAudience AzureADMyOrg

.\ConnectToMSGraph.ps1 -AppName "PowerShell Graph Tutorial" -SignInAudience AzureADMyOrg

AzureADMyOrg	Only users in your Microsoft 365 organization
AzureADMultipleOrgs	Users in any Microsoft 365 organization (work or school accounts)
AzureADandPersonalMicrosoftAccount	Users in any Microsoft 365 organization (work or school accounts) and personal Microsoft accounts
PersonalMicrosoftAccount	Only personal Microsoft accounts
#>

Function global:ConnectToAzure
{
	Param
	(
		[Parameter(Mandatory=$false, HelpMessage="The sign in audience for the app")]
		[ValidateSet("AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount", "PersonalMicrosoftAccount")]
		[String] $SignInAudience = "AzureADandPersonalMicrosoftAccount",
		[Parameter(Mandatory=$false)]
		[Switch]
		$StayConnected = $false
	)

	$authTenant = switch ($SignInAudience)
	{
		"AzureADMyOrg" { "tenantId" }
		"AzureADMultipleOrgs" { "organizations" }
		"AzureADandPersonalMicrosoftAccount" { "common" }
		"PersonalMicrosoftAccount" { "consumers" }
		default { "invalid" }
	}

	if ($authTenant -eq "invalid")
	{
		Write-Host -ForegroundColor Red "Invalid sign in audience:" $SignInAudience
		Exit(1)
	}

	$EnvFlag = $false
	Do
	{
			#Write-Host -ForegroundColor Yellow "ConnectToMSGraph.ConnectToAzure[47] Connect-AzAccount -Environment `"$AzCloud`""
		try
		{
			$global:AzCloud = PickAZCloud
			#$AzConnection = Connect-AzAccount -Environment $AzCloud
			$DeployInfo.Cloud = $AzCloud
			$DeployInfo.CloudEnvironment = $DeployInfo.Cloud.Name
			#Write-Host -ForegroundColor Yellow "ConnectToMSGraph.ConnectToAzure[51] CloudEnvironment `"" $DeployInfo.CloudEnvironment "`""
			#$AzConnection = Connect-AzAccount -Environment $DeployInfo.Cloud
			$AzConnection = Connect-AzAccount -Environment $DeployInfo.CloudEnvironment
			#>
			$EnvFlag = $true
		}
		catch{
			Write-host -ForegroundColor Red "Error:"
			Write-Host -ForegroundColor Red $_
			}

	}Until ($EnvFlag)


	$subscriptions = Get-AzSubscription

	If($subscriptions.Count -gt 1)
	{
			Write-Host -ForegroundColor Cyan "You have" $subscriptions.Count "subscriptions...."
		Write-Host -ForegroundColor Cyan "Please pick the right subscription from below list and copy/paste the requested information when prompted..."

			foreach($subscription in $subscriptions)
			{
			#Write-Host $subscription.Name ", Subscription Id:" $subscription.Id "; Tenant Id: " $subscription.TenantId
			$subscriptionName=$subscription.Name
			$subscriptionId =$subscription.Id
			$tenant = Get-AzTenant -TenantId $subscription.TenantId

			 $Hashtable = [ordered]@{
				Tenant = $tenant.Name
				TenantId = $subscription.TenantId;
				 Subscription = """$subscriptionName""";
				 SubscriptionId = $subscription.Id;
			}

			 PrintSubscription -object $Hashtable
			Write-Host -ForegroundColor Cyan "---------------------------------------------------------------------------------------------------"
		}

		#get current logged in context
		$AzureContext = Get-AzContext
			$DeployInfo.Environment = $AzureContext.Environment.Name
		$currContextTenantId = $AzureContext.Subscription.TenantId

			$DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
		$DeployInfo.SubscriptionName = $AzureContext.Subscription.Name
		$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
		$DeployInfo.TenantName = $SubscriptionTenant.Name
		$DeployInfo.TenantId = $SubscriptionTenant.Id

		Write-Host -ForegroundColor Green "================================================================================"
		Write-Host -ForegroundColor Green "`t`t`t`t`t`tAZURE LOGIN INFO:"
		Write-Host -ForegroundColor Green "================================================================================"
			Write-Host -ForegroundColor Green "Tenant Name:" $DeployInfo.TenantName
		Write-Host -ForegroundColor Green "Tenant Id:" $DeployInfo.TenantId
		Write-Host -ForegroundColor Green "Subscription:" $DeployInfo.SubscriptionName
		Write-Host -ForegroundColor Green "Subscription Id:" $DeployInfo.SubscriptionId
		Write-Host -ForegroundColor Green "================================================================================"

		PickSubscription
			#, Application.ReadWrite.All
		#$AzMgConnection = Connect-MgGraph -Environment $DeployInfo.MgEnvironment #-Scopes "Directory.AccessAsUser.All, Application.Read.All"
	}#if subscriptions.Count -gt 1
	Else
	{

		#get current logged in context
		$AzureContext = Get-AzContext
		$EnvironmentObj = $AzureContext.Environment
		$EnvironmentExtendedProps = $AzureContext.Environment.ExtendedProperties #| ConvertTo-Json

			$DeployInfo.Environment = $AzureContext.Environment.Name
		$currContextTenantId = $AzureContext.Subscription.TenantId
		#$DeployInfo.REACT_APP_GRAPH_ENDPOINT = $AzureContext.Environment.ExtendedProperties.MicrosoftGraphEndpointResourceId + "v1.0/me"
		#$DeployInfo.GraphEndpoint = ""
		#$DeployInfo.GraphEndpointResourceId = $AzureContext.Environment.GraphEndpointResourceId
		#$DeployInfo.ManagementPortalUrl = $AzureContext.Environment.ManagementPortalUrl
		#$DeployInfo.ResourceManagerUrl = $AzureContext.Environment.ResourceManagerUrl
		#$DeployInfo.StorageEndpointSuffix = $AzureContext.Environment.StorageEndpointSuffix
		#$DeployInfo.ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority
		#$DeployInfo.GraphUrl = $AzureContext.Environment.GraphUrl
		#$DeployInfo.ServiceManagementUrl = $AzureContext.Environment.ServiceManagementUrl
		#$DeployInfo.AzureKeyVaultDnsSuffix = $AzureContext.Environment.AzureKeyVaultDnsSuffix
		$DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
		$DeployInfo.SubscriptionName = $AzureContext.Subscription.Name
		#$DeployInfo.StorageEndpointSuffix = $AzureContext.Environment.StorageEndpointSuffix

		$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
			$DeployInfo.TenantName = $SubscriptionTenant.Name
		$DeployInfo.TenantId = $SubscriptionTenant.Id
		Write-Host -ForegroundColor Green "================================================================================"
		Write-Host -ForegroundColor Green "`t`t`t`t`t`tLOGIN INFO:"
		Write-Host -ForegroundColor Green "================================================================================"
			Write-Host -ForegroundColor Green "Tenant Name:" $DeployInfo.TenantName
		Write-Host -ForegroundColor Green "Tenant Id:" $DeployInfo.TenantId
		Write-Host -ForegroundColor Green "Subscription Name:" $DeployInfo.SubscriptionName
		Write-Host -ForegroundColor Green "Subscription Id:"$DeployInfo.SubscriptionId
		Write-Host -ForegroundColor Green "================================================================================"

		<#
		"================================================================================"						>> $DeployInfo.LogFile
		"You are currently logged in context:"																	>> $DeployInfo.LogFile
		"Tenant Name:" + $DeployInfo.TenantName																	>> $DeployInfo.LogFile
		"Tenant Id:" + $DeployInfo.TenantId																		>> $DeployInfo.LogFile
		"Subscription:" + $DeployInfo.SubscriptionName															>> $DeployInfo.LogFile
		"Subscription Id:" + $DeployInfo.SubscriptionId															>> $DeployInfo.LogFile
		"================================================================================"						>> $DeployInfo.LogFile
		#>
		#$AzMgConnection = Connect-MgGraph -Environment $DeployInfo.MgEnvironment -ErrorAction Stop #-Scopes "Directory.AccessAsUser.All, Application.Read.All"
		#Connect-MgGraph -Scopes "Application.ReadWrite.All User.Read" -UseDeviceAuthentication -ErrorAction Stop
	}
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: ConnectToMSGraph.ConnectToAzure`n"
	#return $DeployInfo
}#ConnectToAzure
