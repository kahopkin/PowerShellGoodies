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
		,[Parameter(Mandatory = $false)]  [Object] $CurrContext
		,[Parameter(Mandatory = $false)]  [Object] $DeployObject
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING ConnectToMSGraph.ConnectToAzure[30]"
	}#If($debugFlag)#>
	$Message = "LOG IN TO YOUR AZURE SUBSCRIPTION..."
	#$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

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
			$global:AzCloud = PickAZCloud -StepCount $DeployObject.StepCount
			$DeployObject.Cloud = $AzCloud
			$DeployObject.CloudEnvironment = $DeployObject.Cloud.Name
			#Write-Host -ForegroundColor Yellow "ConnectToMSGraph.ConnectToAzure[51] CloudEnvironment `"" $DeployObject.CloudEnvironment "`""

			$AzConnection = Connect-AzAccount -Environment $DeployObject.CloudEnvironment
			$psCommand = "`$AzConnection = `n`tConnect-AzAccount  ```n`t`t" +
									"-Environment " + $DeployObject.CloudEnvironment		
			#
			If($PrintPSCommands){
				Write-Host -ForegroundColor Magenta "ConnectToMSGraph.ConnectToAzure[73]:"
				Write-Host -ForegroundColor Green $psCommand
			}#If($PrintPSCommands) #>
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
		}#foreach($subscription in $subscriptions)

		#get current logged in context
		$AzureContext = Get-AzContext
		$DeployObject.Environment = $AzureContext.Environment.Name
		$currContextTenantId = $AzureContext.Subscription.TenantId

		$DeployObject.SubscriptionId = $AzureContext.Subscription.Id
		$DeployObject.SubscriptionName = $AzureContext.Subscription.Name
		$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
		$DeployObject.TenantName = $SubscriptionTenant.Name
		$DeployObject.TenantId = $SubscriptionTenant.Id

		Write-Host -ForegroundColor Green -BackgroundColor Black "================================================================================"
		Write-Host -ForegroundColor Green -BackgroundColor Black "`t`t`t`t`t`tAZURE LOGIN INFO:"
		Write-Host -ForegroundColor Green -BackgroundColor Black "================================================================================"
		Write-Host -ForegroundColor Green -BackgroundColor Black "Tenant Name:" $DeployObject.TenantName
		Write-Host -ForegroundColor Green -BackgroundColor Black "Tenant Id:" $DeployObject.TenantId
		Write-Host -ForegroundColor Green -BackgroundColor Black "Subscription:" $DeployObject.SubscriptionName
		Write-Host -ForegroundColor Green -BackgroundColor Black "Subscription Id:" $DeployObject.SubscriptionId
		Write-Host -ForegroundColor Green -BackgroundColor Black "================================================================================"

		PickSubscription
		#, Application.ReadWrite.All
		#$AzMgConnection = Connect-MgGraph -Environment $DeployObject.MgEnvironment #-Scopes "Directory.AccessAsUser.All, Application.Read.All"
	}#if subscriptions.Count -gt 1
	Else
	{
		#ELSEIf($subscriptions.Count -gt 1)
		#get current logged in context
		$AzureContext = Get-AzContext
		$EnvironmentObj = $AzureContext.Environment
		$EnvironmentExtendedProps = $AzureContext.Environment.ExtendedProperties #| ConvertTo-Json

		$DeployObject.Environment = $AzureContext.Environment.Name
		$currContextTenantId = $AzureContext.Subscription.TenantId
		$DeployObject.SubscriptionId = $AzureContext.Subscription.Id
		$DeployObject.SubscriptionName = $AzureContext.Subscription.Name
		#$DeployObject.StorageEndpointSuffix = $AzureContext.Environment.StorageEndpointSuffix

		$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
		$DeployObject.TenantName = $SubscriptionTenant.Name
		$DeployObject.TenantId = $SubscriptionTenant.Id
		Write-Host -ForegroundColor Green -BackgroundColor Black "================================================================================"
		Write-Host -ForegroundColor Green -BackgroundColor Black "`t`t`t`t`t`tLOGIN INFO:"
		Write-Host -ForegroundColor Green -BackgroundColor Black "================================================================================"
		Write-Host -ForegroundColor Green -BackgroundColor Black "Tenant Name:" $DeployObject.TenantName
		Write-Host -ForegroundColor Green -BackgroundColor Black "Tenant Id:" $DeployObject.TenantId
		Write-Host -ForegroundColor Green -BackgroundColor Black "Subscription Name:" $DeployObject.SubscriptionName
		Write-Host -ForegroundColor Green -BackgroundColor Black "Subscription Id:"$DeployObject.SubscriptionId
		Write-Host -ForegroundColor Green -BackgroundColor Black "================================================================================"

		<#
		"================================================================================"						>> $DeployObject.LogFile
		"You are currently logged in context:"																	>> $DeployObject.LogFile
		"Tenant Name:" + $DeployObject.TenantName																	>> $DeployObject.LogFile
		"Tenant Id:" + $DeployObject.TenantId																		>> $DeployObject.LogFile
		"Subscription:" + $DeployObject.SubscriptionName															>> $DeployObject.LogFile
		"Subscription Id:" + $DeployObject.SubscriptionId															>> $DeployObject.LogFile
		"================================================================================"						>> $DeployObject.LogFile
		#>
		#$AzMgConnection = Connect-MgGraph -Environment $DeployObject.MgEnvironment -ErrorAction Stop #-Scopes "Directory.AccessAsUser.All, Application.Read.All"
		#Connect-MgGraph -Scopes "Application.ReadWrite.All User.Read" -UseDeviceAuthentication -ErrorAction Stop
	}
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: ConnectToMSGraph.ConnectToAzure`n"
	#return $DeployObject
}#ConnectToAzure
