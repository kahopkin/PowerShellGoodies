
<#
StartBicepDeploy
 # , [Parameter(Mandatory = $true)] [String]$ResourceId
#>
Function global:StartBicepDeploy {
	Param(
		[Parameter(Mandatory = $true)]  [Object] $DeployObject
		,[Parameter(Mandatory = $false)] [string] $Solution
	)
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$Message = "[" + $today + "] STARTING AZURE RESOURCE DEPLOYMENT... " 
	#
	If($debugFlag){
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING StartBicepDeploy.StartBicepDeploy[16]"
		Write-Host -ForegroundColor White "`$Solution=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$Solution`""
		$SolutionObjName = $DeployObject.SolutionObjName
		Write-Host -ForegroundColor White "`$SolutionObjName=" -NoNewline
		Write-Host -ForegroundColor Yellow "`"$SolutionObjName`""
	}

	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$TimeStamp = (Get-Date).tostring("MM/dd/yyyy HH:mm")

	$website = $DeployObject.ClientAppRegName + "." + $DeployObject.WebDomain
	$functionapp = $DeployObject.APIAppRegName + "." + $DeployObject.WebDomain
	$APIAppRegAppId = $DeployObject.APIAppRegAppId
	#Write-Host -ForegroundColor Cyan "StartBicepDeploy[68] APIAppRegAppId:"  $APIAppRegAppId

	$ClientAppRegAppId = $DeployObject.ClientAppRegAppId
	#Write-Host -ForegroundColor Cyan "StartBicepDeploy[70] ClientAppRegAppId:"  $ClientAppRegAppId
	#
	If($debugFlag){
		$Caller ='StartBicepDeploy[84] ::'
			$ObjectName = "DeployObject"
			Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
			PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#>

	If($APIAppRegAppId -eq $null)
	{
		$AdApplication = Get-AzADApplication -DisplayName $DeployObject.APIAppRegName
		If($AdApplication -eq $null)
		{
			 Write-Host -ForegroundColor Red $DeployObject.APIAppRegName "DOES NOT EXIST..."
			 $Answer = AnswerYesOrNo -Question "Would you like to create the necessary app registrations for the application?"
			 If($Answer)
			 {
				CreateAppRegistration -AppName $DeployObject.APIAppRegName `
									 -DeployObject $DeployObject

				 CreateAppRegistration -AppName $DeployObject.ClientAppRegName `
									 -DeployObject $DeployObject
			}#If($Answer)
			Else
			{
				Write-Host -ForegroundColor Red "WHAT TO DO NOW? "
				Exit(1)
			}
		}
		Else
		{
			$DeployObject.APIAppRegAppId = $AdApplication.AppId
			$DeployObject.APIAppRegObjectId = $AdApplication.Id
			$SPN = Get-AzADServicePrincipal -ApplicationId $AdApplication.AppId
			$DeployObject.APIAppRegServicePrincipalId = $SPN.Id
			$DeployObject.APIAppRegExists = $true
			$ApiClientId = $DeployObject.APIAppRegAppId
			$SecureApiClientId = ConvertTo-SecureString $DeployObject.APIAppRegAppId -AsPlainText -Force
			#Write-Host -ForegroundColor Yellow "StartBicepDeploy[63] :: DeployObject.APIAppRegAppId:"  $DeployObject.APIAppRegAppId

			$SecureSqlServerAdministratorLogin = $DeployObject.SqlAdmin
			$SecureSqlServerAdministratorPassword = $DeployObject.SqlAdminPwd
			#$APIAppRegSecret = $DeployObject.APIAppRegSecret
			If ($DeployObject.APIAppRegSecret.Length -gt 0)
			{
			$out =  "`$DeployObject.APIAppRegSecret=`"" + $DeployObject.APIAppRegSecret + "`""
			 $APIAppRegSecret = $DeployObject.APIAppRegSecret
			$SecureApiClientSecret = ConvertTo-SecureString $APIAppRegSecret -AsPlainText -Force
			}
			Else
			{
			#create a client secret key which will expire in two years.
			$appPassword = New-AzADAppCredential -ObjectId $DeployObject.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
			$PlaintextSecretTest = $appPassword.SecretText
			$DeployObject.APIAppRegSecret = $PlaintextSecretTest
			 $SecureApiClientSecret = ConvertTo-SecureString $DeployObject.APIAppRegSecret -AsPlainText -Force
			}
		}
	}

	#
	If($debugFlag)
	{
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan "=" }Else{Write-Host -ForegroundColor Cyan "=" -NoNewline}}
		Write-Host -ForegroundColor Magenta -BackgroundColor Black  "StartBicepDeploy[89] Solution="$DeployObject.Solution
		$Caller ='StartBicepDeploy[90]'
		$ObjectName = $DeployObject.Solution + "AppObj"
		$ObjectName = "DeployObject"
		#PrintCustomObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
		#PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
		$WarningAction = "Continue"
	}#If($debugFlag)#>

	$deploystring = "`nNew-AzSubscriptionDeployment ```n`t`t" +
					"-Name " + $DeployObject.DeploymentName + " ```n`t`t" +
					"-AppName " + $DeployObject.AppName + " ```n`t`t" +
					"-Solution " + $DeployObject.Solution + " ```n`t`t" +
					"-Environment " + $DeployObject.Environment + " ```n`t`t" +
					"-Location " + $DeployObject.Location + " ```n`t`t" +
					"-TimeStamp `"" + $TimeStamp + "`"```n`t`t" +
					"-TemplateFile " + $DeployObject.BicepFile + " ```n`t`t" +
					"-TemplateParameterFile " + $DeployObject.TemplateParameterFile + " ```n`t`t" +
					"-DeployObject `$DeployObject  ```n`t`t" +
					"-WarningAction " + $WarningAction + "`n"


	Write-Host -ForegroundColor Cyan -BackgroundColor Black $deploystring
 
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
			-AppName $DeployObject.AppName`
			-Solution $DeployObject.Solution `
			-Environment $DeployObject.Environment `
			-Location $DeployObject.Location `
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
	#return $deploySuccessFlag
}#end of StartBicepDeploy

