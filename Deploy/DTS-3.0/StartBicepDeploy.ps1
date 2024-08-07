

<#
StartBicepDeploy
 # , [Parameter(Mandatory = $true)] [String]$ResourceId
#>
Function global:StartBicepDeploy {
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$Message = "[" + $today + "] STARTING AZURE RESOURCE DEPLOYMENT... "
	#
	If($debugFlag){
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING StartBicepDeploy.StartBicepDeploy[16]"
	}#If($debugFlag)#>

	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	#$website = $DeployObject.$SolutionObjName.ClientAppRegName + ".azurewebsites.us"
	#$functionapp = $DeployObject.$SolutionObjName.APIAppRegName + ".azurewebsites.us"
	$website = $DeployObject.ClientAppRegName + "." + $DeployObject.WebDomain
	$functionapp = $DeployObject.APIAppRegName + "." + $DeployObject.WebDomain

	Write-Host -ForegroundColor Yellow "Deploying the following resources:"
	Write-Host -ForegroundColor Yellow "*** Resource Group:" $DeployObject.ResourceGroupName
	Write-Host -ForegroundColor Yellow "*** Website:" $website
	Write-Host -ForegroundColor Yellow "*** Function App:" $functionapp
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}

	$APIAppRegAppId = $DeployObject.APIAppRegAppId

	$ClientAppRegAppId = $DeployObject.ClientAppRegAppId

	#
	If($debugFlag){
		$Caller ='StartBicepDeploy[84] ::'
		$ObjectName = "DeployObject"
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		#PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
		$WarningAction = "Continue"
	}#>


	$ApiClientId = $DeployObject.APIAppRegAppId
	$SecureApiClientId = ConvertTo-SecureString $DeployObject.APIAppRegAppId -AsPlainText -Force

	$SecureSqlServerAdministratorLogin = $DeployObject.SqlAdmin
	$SecureSqlServerAdministratorPassword = $DeployObject.SqlAdminPwd

	If ($DeployObject.APIAppRegSecret.Length -gt 0)
	{
		$out =  "`$DeployObject.APIAppRegClientSecret=`"" + $DeployObject.APIAppRegClientSecret + "`""
		$APIAppRegSecret = $DeployObject.APIAppRegSecret
		$SecureApiClientSecret = ConvertTo-SecureString $APIAppRegSecret -AsPlainText -Force
		$SecureApiClientSecretAsPlainText =
		$DeployObject.APIAppRegSecret = $SecureApiClientSecret
	}
	Else
	{
		#create a client secret key which will expire in two years.
		$appPassword = New-AzADAppCredential -ObjectId $DeployObject.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
		$DeployObject.APIAppRegSecret = ConvertTo-SecureString $appPassword.SecretText -AsPlainText -Force
	}

	<#
	If($debugFlag)
	{
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan "=" }Else{Write-Host -ForegroundColor Cyan "=" -NoNewline}}
		$Caller ='StartBicepDeploy[90]'
		$ObjectName = "DeployObject"
		#PrintCustomObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
		PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
		#$WarningAction = "Continue"
	}#If($debugFlag)#>

	$TimeStamp = (Get-Date).tostring("MM/dd/yyyy HH:mm")
	$deploystring = "`nNew-AzSubscriptionDeployment ```n`t`t" +
					"-Name " + $DeployObject.DeploymentName + " ```n`t`t" +
					"-AppName " + $DeployObject.AppName + " ```n`t`t" +
					"-Environment " + $DeployObject.Environment + " ```n`t`t" +
					"-Location " + $DeployObject.Location + " ```n`t`t" +
					"-APIAppRegSecret `"" + $DeployObject.APIAppRegSecretAsPlainText + "`"```n`t`t" +
					"-SqlAdminPwd `"" + $DeployObject.SqlAdminPwdAsPlainText + "`"```n`t`t" +
					"-TimeStamp `"" + $TimeStamp + "`"```n`t`t" +
					"-TemplateFile " + $DeployObject.BicepFile + " ```n`t`t" +
					"-TemplateParameterFile " + $DeployObject.TemplateParameterFile + " ```n`t`t" +
					"-DeployObject `$DeployObject ```n`t`t" +
					"-WarningAction " + $WarningAction + "`n"
	
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black $deploystring
	$TimeStamp = (Get-Date).tostring("MM/dd/yyyy HH:mm")
	Write-Host -ForegroundColor Yellow "Deploying the following resources:"
	Write-Host -ForegroundColor Yellow "*** Resource Group:" $DeployObject.ResourceGroupName
	Write-Host -ForegroundColor Yellow "*** Website:" $website
	Write-Host -ForegroundColor Yellow "*** Function App:" $functionapp

	$deploySuccessFlag = $false
	try
	{
		$DeploymentOutput =
			New-AzSubscriptionDeployment `
				-Name $DeployObject.DeploymentName `
				-AppName $DeployObject.AppName `
				-Environment $DeployObject.Environment `
				-Location $DeployObject.Location `
				-APIAppRegSecret $SecureApiClientSecret `
				-SqlAdminPwd $DeployObject.SqlAdminPwd `
				-TimeStamp $TimeStamp `
				-TemplateFile $DeployObject.BicepFile `
				-TemplateParameterFile $DeployObject.TemplateParameterFile `
				-DeployObject $DeployObject `
				-WarningAction $WarningAction

		$deploySuccessFlag = $true
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Message = "[" + $today + "] FINISHED AZURE RESOURCE DEPLOYMENT... "
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		return $DeploymentOutput
	}
	catch
	{
		Write-Output  "Ran into an issue: $($PSItem.ToString())"
		$deploySuccessFlag = $false
	} 
}#StartBicepDeploy

