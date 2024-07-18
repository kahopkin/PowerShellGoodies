
Function global:SetApplicationIdURI
{
	Param(
	 [Parameter(Mandatory = $true)] [String]$AppId
	)


	"[" + $today + "] Setting Application ID URI:" + $appIDUri >> $DeployObject.LogFile
	$appIDUri = "api://" + $AppId

	$Message = "ADD APPLICATION ID URI:" + $appIDUri
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING SetApplicationIdURI.SetApplicationIdURI[13]"
		Write-Host -ForegroundColor Cyan "`$appIDUri= `"$appIDUri`""
	}

	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	Update-AzADApplication -ApplicationId $appId -IdentifierUris $appIDUri
}#SetApplicationIdURI

Function global:SetApplicationIdURI_Original
{
	Param(
	 [Parameter(Mandatory = $true)] [String]$AppId
	)

	"================================================================================"	>> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": ADD APPLICATION ID URI" 						 >> $DeployObject.LogFile
	"================================================================================"	>> $DeployObject.LogFile

	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "Step" $DeployObject.StepCount": ADD APPLICATION ID URI"
	Write-Host -ForegroundColor Cyan "================================================================================"
	$DeployObject.StepCount++

	<#
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START SetApplicationIdURI "
	Write-Host -ForegroundColor Magenta "[$today] Setting Application ID URI: $AppId"
	#>
	"[" + $today + "] Setting Application ID URI:" + $appIDUri >> $DeployObject.LogFile
	$appIDUri = "api://" + $AppId

	Update-AzADApplication -ApplicationId $appId -IdentifierUris $appIDUri
	#Write-Host  -ForegroundColor Cyan "CreateAppRegistration[47] Updated API URI:"  $appIDUri
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green  -BackgroundColor Black "[$today] FINISHED SetApplicationIdURI"
}#_Original