#SetRedirectURI
<#
	This script sets the Single-page application Redirect URI
#>
Function global:SetRedirectURI
{
	Param(
		[Parameter(Mandatory = $true)] [String]$ObjectId
	)

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n  [$today] START SetRedirectURI ObjectID $ObjectId "
	$AdApplication = Get-AzADApplication -ObjectId $ObjectId
	$AppName = $AdApplication.DisplayName

	#Write-Host -ForegroundColor Yellow "SetRedirectURI[16] Adding redirect URIs for $AppName with $ObjectId";
	$redirectUris = @()
	$WebAppUrl = "https://$AppName.azurewebsites.us"
	if ($redirectUris -notcontains "$WebAppUrl") {
		$redirectUris += "$WebAppUrl" 
		#Write-Host "SetRedirectURI[21] Adding $WebAppUrl to redirect URIs";
	}

	$accesstoken = (Get-AzAccessToken -Resource "https://graph.microsoft.us/").Token

	$header = @{
		'Content-Type' = 'application/json'
		'Authorization' = 'Bearer ' + $accesstoken
	}

	$body = @{
		'spa' = @{
			'redirectUris' = $redirectUris
		}
	}

	$bodyJson = ConvertTo-Json $body

	Invoke-RestMethod -Method Patch -Uri "https://graph.microsoft.us/v1.0/applications/$ObjectId" -Headers $header -Body $bodyJson

	<#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Green  -BackgroundColor Black " [$today] FINISHED SetRedirectURI for $AppName"
	#>
}#SetApplicationIdURI

