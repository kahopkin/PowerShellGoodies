
Function global:SetApplicationIdURI
{
    Param(
     [Parameter(Mandatory = $true)] [String]$AppId
    )
    
    "================================================================================"	>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": ADD APPLICATION ID URI" 	                    >> $DeployInfo.LogFile
    "================================================================================"	>> $DeployInfo.LogFile
    
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "Step" $DeployInfo.StepCount": ADD APPLICATION ID URI"
    Write-Host -ForegroundColor Cyan "================================================================================"
    $DeployInfo.StepCount++
    
	<#
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START SetApplicationIdURI "
    Write-Host -ForegroundColor Magenta "[$today] Setting Application ID URI: $AppId"
	#>
    "[" + $today + "] Setting Application ID URI:" + $appIDUri >> $DeployInfo.LogFile
    $appIDUri = "api://" + $AppId
        
    Update-AzADApplication -ApplicationId $appId -IdentifierUris $appIDUri
    #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[47] Updated API URI:"  $appIDUri
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green  -BackgroundColor Black "[$today] FINISHED SetApplicationIdURI"
}#SetApplicationIdURI