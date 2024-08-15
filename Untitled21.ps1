	$ObjectName = "AzResourcesComplexObj"
	If($DeployObject.AzureResources -eq $null -and $DeployConfigObj.AzureInfrastructure)
	{
		$AzureResourcesNull = ($DeployObject.AzureResources -eq $null)
		#Write-Host -ForegroundColor Magenta -BackgroundColor White "`nInitiateDeploymentProcess[257] BEFORE SelectAzResourceToDeploy"

		$DeployObject.AzureResources =
		$ComponentsChosen =
		$AzureResources =
						SelectAzResourceToDeploy -AzResourcesComplexObj $AzResourcesComplexObj
	}#If($DeployObject.AzureResources -eq $null)
	Else
	{
		$ComponentsChosen =
		$AzureResources =
						$DeployObject.AzureResources
	}#ElseIf($DeployObject.AzureResources -eq $null) #>
		
	If($DeployConfigObj.AzureInfrastructure)
	{
		$ObjectName = "AzResourcesObj"
		$AzureResourcesObj =
		$DeployObject.AzureResources = SetConfigObj `
										-ComponentsChosen $ComponentsChosen `
										-ConfigObject $AzResourcesObj `
										-ObjectName $ObjectName
	}

#
	If($debugFlag){
		$ObjectName = "AzResourcesObj"
		$Caller = "InitiateDeploymentProcess[363]:: " + $ObjectName
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		PrintObject -Object $AzResourcesObj -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#>


$SolutionName = 'kat26'

.\deployTest.ps1 `
    -SolutionName $SolutionName `
    -SubscriptionName 'BMA-05: DTS' `
    -Location 'UsGovVirginia' `
    -Environment GOV `
    -HubIpOctet 1 `
    -OverwriteExistingFile	

$url = "https://microsoft-my.sharepoint.com/personal/kahopkin_microsoft_com1/_layouts/15/AdminRecycleBin.aspx"
$url = "https://microsoft-my.sharepoint.com/personal/kahopkin_microsoft_com1"
Connect-PnPOnline -Url $url

#https://www.sharepointdiary.com/2021/02/how-to-install-pnp-powershell-module-for-sharepoint-online.html
Get-Module SharePointPnPPowerShellOnline -ListAvailable | Select-Object Name,Version

	
Uninstall-Module SharePointPnPPowerShellOnline -Force -AllVersions

	
Install-Module PnP.PowerShell

#verify the installation by getting a list of PnP PowerShell cmdlets
Get-Command -Module PnP.Powershell

<#
In case you are not a global admin, use: 
Register-PnPManagementShellAccess -ShowConsentUrl 
and share the URL you get from this cmdlet with the Tenant Admin, and they can complete this consent step from the URL you share.

#Read more: https://www.sharepointdiary.com/2021/02/how-to-install-pnp-powershell-module-for-sharepoint-online.html#ixzz8BPJtNvYh
#>
Register-PnPManagementShellAccess -ShowConsentUrl 


 $tags = @{
     Environment = $Environment
     DeployDate = (Get-Date).tostring("MM/dd/yyyy HH:mm")        
     DeployedBy =  (Get-AzADUser -SignedIn).DisplayName
     Environment = $Environment
     SolutionVersion = $config.solutionVersion
     Owner = $config.solutionOwner
 }