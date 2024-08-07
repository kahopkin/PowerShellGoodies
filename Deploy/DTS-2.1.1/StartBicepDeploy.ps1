﻿

<#
StartBicepDeploy
 # , [Parameter(Mandatory = $true)] [String]$ResourceId
#>
Function global:StartBicepDeploy {
	Param(
			[Parameter(Mandatory = $true)] [Object] $DeployObject
			,[Parameter(Mandatory = $false)] [string] $Solution
	)

	Write-Debug "StartBicepDeploy.StartBicepDeploy[12]"
	If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "StartBicepDeploy[15] "

			#Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START StartBicepDeploy "
		Write-Host -ForegroundColor Magenta -BackgroundColor Black  "BicepFile="$DeployInfo.BicepFile
		#Write-Host -ForegroundColor Magenta -BackgroundColor Black  "StartBicepDeploy[19] Solution="$Solution
		#Write-Host -ForegroundColor Magenta -BackgroundColor Black  "StartBicepDeploy[19] TemplateParameterFile="$DeployObject.TemplateParameterFile

	}#>

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	<#
	$Caller='StartBicepDeploy[25] DeployObject::'
	PrintDeployObject -object $DeployObject -Caller $Caller
	#>
	#PrintObject -object $DeployObject -Caller $Caller
	#>

	"================================================================================"	>> $DeployInfo.LogFile
	"Step" + $DeployInfo.StepCount + ": STARTING AZURE RESOURCE DEPLOYMENT... " 		>> $DeployInfo.LogFile
	"================================================================================"	>> $DeployInfo.LogFile

	Write-Host -ForegroundColor Green "================================================================================"
	Write-Host -ForegroundColor Green "Step" $DeployInfo.StepCount": STARTING AZURE RESOURCE DEPLOYMENT... "
	Write-Host -ForegroundColor Green "================================================================================"
	$DeployInfo.StepCount++

	"================================================================================"						>> $DeployInfo.LogFile
	"[" + $today + "] STARTING AZURE RESOURCE DEPLOYMENT..."												>> $DeployInfo.LogFile
	"================================================================================"						>> $DeployInfo.LogFile
	"Deploying the following resources:"																	>> $DeployInfo.LogFile
	"*** App Service Plan "																					>> $DeployInfo.LogFile
	"*** App Service "																						>> $DeployInfo.LogFile
	"*** Function App "																						>> $DeployInfo.LogFile
	"*** Key Vault "																						>> $DeployInfo.LogFile
	"***	 - Customer Managed Keys for the Storage Accounts "												>> $DeployInfo.LogFile
	"***	 - Customer Managed Keys for the SQL Database "													>> $DeployInfo.LogFile
	"***	 - Secrets: FunctionApp AppId and secret "														>> $DeployInfo.LogFile
	"*** Managed Identity "																					>> $DeployInfo.LogFile
	"*** Application Insights "																				>> $DeployInfo.LogFile
	"*** Log Analytics workspace "																			>> $DeployInfo.LogFile
	"*** Virtual Network and SubNets "																		>> $DeployInfo.LogFile
	"*** Network Security Group "																			>> $DeployInfo.LogFile
	"*** Private DNS zones "																				>> $DeployInfo.LogFile
	"*** Private Endpoints "																				>> $DeployInfo.LogFile
	"*** Network Interfaces "																				>> $DeployInfo.LogFile
	"*** Main and Audit Storage Accounts "																	>> $DeployInfo.LogFile
	"*** SQL Server "																						>> $DeployInfo.LogFile
	"*** SQL Database "																						>> $DeployInfo.LogFile

	$website = $DeployObject.ClientAppRegName + ".azurewebsites.us"
	$functionapp = $DeployObject.APIAppRegName + ".azurewebsites.us"
	$TimeStamp = (Get-Date).tostring("MM/dd/yyyy HH:mm")
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan " [$today] STARTING AZURE RESOURCE DEPLOYMENT..."
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Yellow "Deploying the following resources:"
	Write-Host -ForegroundColor Yellow "*** Resource Group:" $DeployObject.ResourceGroupName
	Write-Host -ForegroundColor Yellow "*** Website:" $website
	Write-Host -ForegroundColor Yellow "*** Function App:" $functionapp
 
	Write-Host -ForegroundColor Cyan "================================================================================"

	<#
	If($debugFlag){
		Write-Host -ForegroundColor Red "StartBicepDeploy[97] DeployObject.Solution=" $DeployObject.Solution
		$Caller='StartBicepDeploy[98] DeployObject::'
		PrintObject -object $DeployObject -Caller $Caller
	#>
	$APIAppRegAppId = $DeployObject.APIAppRegAppId
	#Write-Host -ForegroundColor Cyan "StartBicepDeploy[68] APIAppRegAppId:"  $APIAppRegAppId

	$ClientAppRegAppId = $DeployObject.ClientAppRegAppId
	#Write-Host -ForegroundColor Cyan "StartBicepDeploy[70] ClientAppRegAppId:"  $ClientAppRegAppId
	if($DeployObject.Solution -eq "All")
	{
		#$DeploymentName = $DeployObject.DeploymentName
		$ApiClientId = $DeployObject.TransferAppObj.APIAppRegAppId
		$SecureApiClientId = ConvertTo-SecureString $DeployObject.TransferAppObj.APIAppRegAppId -AsPlainText -Force
		#Write-Host -ForegroundColor Magenta "StartBicepDeploy[77] All:: DeployObject.TransferAppObj.APIAppRegAppId:"  $DeployObject.TransferAppObj.ClientAppRegAppId
		if ($DeployObject.TransferAppObj.APIAppRegClientSecret.Length -gt 0)
		{
			$out =  "`$DeployObject.TransferAppObj.APIAppRegClientSecret=`"" + $DeployObject.TransferAppObj.APIAppRegClientSecret + "`""
			#Write-Host -ForegroundColor Green "StartBicepDeploy[82] " $out
			$APIAppRegClientSecret = $DeployObject.TransferAppObj.APIAppRegClientSecret
			$SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
			#$SecureSqlServerAdministratorLogin = ConvertTo-SecureString $DeployObject.SqlAdmin -AsPlainText -Force
			#$SecureSqlServerAdministratorPassword = ConvertTo-SecureString $DeployObject.SqlAdminPwd -AsPlainText -Force

		}
		else
		{
			#create a client secret key which will expire in two years.
				$appPassword = New-AzADAppCredential -ObjectId $DeployObject.TransferAppObj.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
				$PlaintextSecretTest = $appPassword.SecretText
			$DeployObject.TransferAppObj.APIAppRegClientSecret = $PlaintextSecretTest
			 $SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
			#$SecureSqlServerAdministratorLogin = ConvertTo-SecureString $DeployObject.SqlAdmin -AsPlainText -Force
			#$SecureSqlServerAdministratorPassword = ConvertTo-SecureString $DeployObject.SqlAdminPwd -AsPlainText -Force
			}


	}#if($DeployObject.Solution -eq "All")

	elseif($DeployObject.Solution -eq "Transfer")
	{
		<#
		If($debugFlag){
		$Caller='StartBicepDeploy[110] TransferAppObj::'
		PrintDeployObject -object $DeployObject -Caller $Caller
		}#>
		#$DeploymentName = $DeployObject.TransferAppObj.DeploymentName
		#$ApiClientId = $DeployObject.TransferAppObj.APIAppRegAppId
		$ApiClientId = $DeployObject.APIAppRegAppId
		$SecureApiClientId = ConvertTo-SecureString $DeployObject.APIAppRegAppId -AsPlainText -Force
		#$SecureApiClientId = ConvertTo-SecureString $DeployObject.TransferAppObj.APIAppRegAppId -AsPlainText -Force
		#Write-Host -ForegroundColor Yellow "StartBicepDeploy[110] Transfer:: DeployObject.TransferAppObj.APIAppRegAppId:"  $DeployObject.TransferAppObj.APIAppRegAppId

			#$SecureSqlServerAdministratorLogin = ConvertTo-SecureString $DeployObject.SqlAdmin -AsPlainText -Force
		#$SecureSqlServerAdministratorPassword = ConvertTo-SecureString $DeployObject.SqlAdminPwd -AsPlainText -Force

		$SecureSqlServerAdministratorLogin = $DeployObject.SqlAdmin
		$SecureSqlServerAdministratorPassword = $DeployObject.SqlAdminPwd

		if ($DeployObject.APIAppRegClientSecret.Length -gt 0)
		{
			$out =  "`$DeployObject.TransferAppObj.APIAppRegClientSecret=`"" + $DeployObject.APIAppRegClientSecret + "`""
			 $APIAppRegClientSecret = $DeployObject.APIAppRegClientSecret
			$SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
			}
		else
		{
			#create a client secret key which will expire in two years.
				$appPassword = New-AzADAppCredential -ObjectId $DeployObject.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
				$PlaintextSecretTest = $appPassword.SecretText
			$DeployObject.APIAppRegClientSecret = $PlaintextSecretTest
			 $SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
		}

		$deploystring = "`nNew-AzSubscriptionDeployment ```n`t`t" +
						"-Name " + $DeployObject.DeploymentName + " ```n`t`t" +
						"-AppName " + $DeployInfo.AppName + " ```n`t`t" +
						"-Solution " + $DeployObject.Solution + " ```n`t`t" +
						"-Environment " + $DeployObject.Environment + " ```n`t`t" +
						"-Location " + $DeployObject.Location + " ```n`t`t" +
						"-TimeStamp ``" + $TimeStamp + "`` ```n`t`t" +
						"-TemplateFile " + $DeployInfo.BicepFile + " ```n`t`t" +
						"-TemplateParameterFile " + $DeployInfo.TemplateParameterFile + " ```n`t`t" + 
						 "-DeployObject `$DeployInfo"


		Write-Host -ForegroundColor Cyan $deploystring
	}#elseif($DeployObject.Solution -eq "Transfer")

	elseif($DeployObject.Solution -eq "Pickup")
	{


		#$DeploymentName = $DeployObject.DeploymentName
		$ApiClientId = $DeployObject.APIAppRegAppId
		$SecureApiClientId = ConvertTo-SecureString $DeployObject.APIAppRegAppId -AsPlainText -Force

			<#If($debugFlag){
			Write-Host -ForegroundColor Magenta "StartBicepDeploy[83] Pickup:: "
			Write-Host -ForegroundColor Yellow "DeployObject.APIAppRegAppId:"  $DeployObject.APIAppRegAppId
			$Caller='StartBicepDeploy[170] PickupAppObj::'
			PrintDeployObject -object $DeployObject -Caller $Caller
		}#If($debugFlag) #>


		if ($DeployObject.APIAppRegClientSecret.Length -gt 0)
		{
			$out =  "`$DeployObject.PickupAppObj.APIAppRegClientSecret=`"" + $DeployObject.APIAppRegClientSecret + "`""
			#Write-Host -ForegroundColor Green "StartBicepDeploy[82] " $out
			$APIAppRegClientSecret = $DeployObject.APIAppRegClientSecret
			$SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
			}
		else
		{
			#create a client secret key which will expire in two years.
				$appPassword = New-AzADAppCredential -ObjectId $DeployObject.APIAppRegObjectId -EndDate (Get-Date).AddYears(2)
				$PlaintextSecretTest = $appPassword.SecretText
			$DeployObject.APIAppRegClientSecret = $PlaintextSecretTest
			 $SecureApiClientSecret = ConvertTo-SecureString $APIAppRegClientSecret -AsPlainText -Force
		}
		$deploystring = "`nNew-AzSubscriptionDeployment ```n`t`t" +
					"-Name " + $DeployObject.DeploymentName + " ```n`t`t" +
					"-AppName " + $DeployInfo.AppName + " ```n`t`t" +
					"-Solution " + $DeployObject.Solution + " ```n`t`t" +
					"-Environment " + $DeployObject.Environment + " ```n`t`t" +
					"-Location " + $DeployObject.Location + " ```n`t`t" +
					"-TimeStamp ``" + $TimeStamp + "`` ```n`t`t" +
					"-TemplateFile " + $DeployInfo.BicepFile + " ```n`t`t" +
					"-TemplateParameterFile " + $DeployInfo.TemplateParameterFile + " ```n`t`t" + 
					"-DeployObject `$DeployInfo"

		Write-Host -ForegroundColor Cyan $deploystring 

	}#elseif($DeployObject.Solution -eq "Pickup")

	else
	{
		Write-Host -ForegroundColor Red "StartBicepDeploy[92] NO CLUE:: DeployObject.Solution:"  $DeployObject.Solution
		exit(1)
	}

	$deploySuccessFlag = $false 
	try
	{
		$DeploymentOutput =
		New-AzSubscriptionDeployment `
			-Name $DeployObject.DeploymentName `
			-AppName $DeployInfo.AppName`
			-Solution $DeployObject.Solution `
			-Environment $DeployObject.Environment `
			-Location $DeployObject.Location `
			-TimeStamp $TimeStamp `
			-TemplateFile $DeployInfo.BicepFile `
			-TemplateParameterFile $DeployInfo.TemplateParameterFile `
			-DeployObject $DeployInfo
		
		$deploySuccessFlag = $true
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Cyan "================================================================================"
			Write-Host -ForegroundColor Cyan " [$today] FINISHED AZURE RESOURCE DEPLOYMENT..."
			Write-Host -ForegroundColor Cyan "================================================================================"
		"================================================================================"						>> $DeployInfo.LogFile
		"[" + $today + "] FINISHED AZURE RESOURCE DEPLOYMENT..."												>> $DeployInfo.LogFile
		"================================================================================"						>> $DeployInfo.LogFile
		$DeployObject.EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$DeployObject.Duration = New-TimeSpan -Start $DeployObject.StartTime -End $DeployObject.EndTime
		if($DeployObject.Solution -eq "Transfer")
		{
			$TransferAppObj.EndTime = $DeployObject.EndTime
			$TransferAppObj.Duration = $DeployObject.Duration
		}
		else
		{
			$PickupAppObj.EndTime = $DeployObject.EndTime
			$PickupAppObj.Duration = $DeployObject.Duration
		}

	}
	catch
	{
			Write-Output  "Ran into an issue: $($PSItem.ToString())"
		$deploySuccessFlag = $false

	}
	#return $deploySuccessFlag
	return $DeploymentOutput
}#end of StartBicepDeploy




<#If(($DeployInfo.Environment).ToLower() -eq 'prod')
{
	$DeployObject.DeploymentName = "Deployment-" + $DeployObject.AppName + "-" + $DeployObject.Solution + "-" + $DeployObject.Environment + "-" + $todayShort
}
Else
{
	$DeployObject.DeploymentName = "Deployment-" + $DeployObject.AppName + "-" + $DeployObject.Solution + "-" + $DeployObject.Environment + "-" + $todayShort
} #>	   

#PrintDeployDuration -DeployObject $DeployObject
<#
$Caller='StartBicepDeploy[231] After Bicep::'	
PrintDeployObject -object $DeployObject 
#>
		
<#
$managedUserName = 'id-'+ $DeployObject.AppName + '-' + $DeployObject.Environment
#Write-Host -ForegroundColor Green "StartBicepDeploy[185] `$managedUserName=`"$managedUserName`""
$userIdentity = Get-AzUserAssignedIdentity -Name $managedUserName -ResourceGroupName $DeployObject.ResourceGroupName
$principalId = $userIdentity.PrincipalId
#Write-Host -ForegroundColor Green "StartBicepDeploy[188] `$principalId=`"$principalId`""
	
$keyvaultName = 'kv-'+ $DeployObject.AppName + '-' + $DeployObject.Environment
#Write-Host -ForegroundColor Green "StartBicepDeploy[192] `$keyvaultName=`"$keyvaultName`""

$keyvault = Get-AzKeyVault -Name $keyvaultName 
#>
<#
New-AzRoleAssignment -ObjectId $principalId `
	-RoleDefinitionName "Key Vault Crypto Service Encryption User" `
	-Scope $keyVault.ResourceId

####>
<#
New-AzSubscriptionDeployment `
	-Name $DeployObject.DeploymentName `
	-AppName $DeployObject.AppName`
	-Solution $DeployObject.Solution `
	-EnvironmentType $DeployObject.Environment `
	-Location $DeployObject.Location `
	-CurrUserName $DeployObject.CurrUserName `
	-CurrUserId $DeployObject.CurrUserId `
	-TimeStamp $TimeStamp `
	-TemplateFile $DeployObject.BicepFile `
	-TemplateParameterFile $DeployObject.TemplateParameterFile `
	-ApiClientId $SecureApiClientId `
	-ApiClientSecret $SecureApiClientSecret `
	-SqlServerAdministratorLogin $SecureSqlServerAdministratorLogin `
	-SqlServerAdministratorPassword $SecureSqlServerAdministratorPassword `
	-DeployObject $DeployObject
	#>
<#

 #-WhatIf ```
			#-WhatIfResultFormat FullResourcePayloads ```
			#-Confirm ```

	#Write-Host -ForegroundColor Yellow "***  ***"
	#Write-Host -ForegroundColor Yellow "***  ***"

	#$Caller = 'StartBicepDeploy'
	#PrintObject -object $DeployInfo -Caller $Caller
	#PrintHash -object $DeployInfo -Caller $Caller
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[27] debugFlag:  $debugFlag"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] Subscription:  $subscriptionName"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] ResourceGroupName: $DeployInfo.ResourceGroupName"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] ResourceId: $ResourceId"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] EnvType:  $DeployInfo.Environment"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] Location:  $DeployInfo.Location"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] AppName:  $AppName"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] DeploymentName:  $DeploymentName"
	#>

