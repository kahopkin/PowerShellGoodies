<#
	AddCustomRoleFromFile.ps1
#>
Function global:AddCustomRoleFromFile
{
	Param(
		 [Parameter(Mandatory = $false)] [string] $FilePath
			,[Parameter(Mandatory = $false)] [Object] $DeployObject
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING AddCustomRoleFromFile.AddCustomRoleFromFile[13]" 
	}

	$Message = "ADDING CUSTOM ROLE ASSIGNMENT:" $RoleAssignmentName
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	If($DeployObject -ne $null)
	{
		If( ($DeployObject.Solution -eq "Transfer") -or ($DeployObject.Solution -eq "All") )
		{
			$RoleDefinitionFile = $DeployObject.TransferAppObj.RoleDefinitionFile
			Write-Host "RoleDefinitionFile=" $RoleDefinitionFile
		}
		If( ($DeployObject.Solution -eq "Pickup") -or ($DeployObject.Solution -eq "All") )
		{
			$RoleDefinitionFile = $DeployObject.PickupAppObj.RoleDefinitionFile
		}

		If($debugFlag){
			$SubscriptionId = $DeployObject.SubscriptionId
			$Caller ='AddCustomRoleFromFile[34]'
			PrintDeployObject -Object $DeployObject -Caller $Caller
			Write-Host -ForegroundColor White -NoNewline "`$DeployObject.Solution=`""
			Write-Host -ForegroundColor Cyan $DeployObject.Solution
			Write-Host -ForegroundColor White -NoNewline "`SubscriptionId=`""
			Write-Host -ForegroundColor Cyan $SubscriptionId
			Write-Host -ForegroundColor Magenta "AddCustomRoleFromFile.[40]" 

			#Write-Host -ForegroundColor White -NoNewline "`$ObjectName=`""
			#Write-Host -ForegroundColor Cyan "`"$ObjectName`""
			Write-Host -ForegroundColor White -NoNewline "`$RoleDefinitionFile=`""
			Write-Host -ForegroundColor Cyan "`"$RoleDefinitionFile`""
		}#If($debugFlag)#> 


		$ParentFolderPath = ((Get-ItemProperty (Split-Path (Get-Item ($RoleDefinitionFile)).FullName -Parent) | select FullName).FullName)
		$RoleDefinitionFileOut = $ParentFolderPath + "\" + $(Get-Item ($RoleDefinitionFile)).BaseName + "Out.json"
		$MyJsonObject = Get-Content $RoleDefinitionFile -Raw | ConvertFrom-Json
		$MyJsonObject.assignableScopes[0] = "/subscriptions/" + $SubscriptionId
	}
	Else
	{
		$SubscriptionId = (Get-AzSubscription | Select Id).Id
		$MyJsonObject.assignableScopes[0] = "/subscriptions/" + $SubscriptionId
	}

	<#
	If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "AddRoleAssignment.AddRoleAssignment[63] IN Params:"
			Write-Host -ForegroundColor Yellow "`$RoleDefinitionFile=`"$RoleDefinitionFile`""
		Write-Host -ForegroundColor Cyan "`$ParentFolderPath=`"$ParentFolderPath`""
		Write-Host -ForegroundColor Green "`$RoleDefinitionFileOut=`"$RoleDefinitionFileOut`""
		Write-Host -ForegroundColor Magenta "**********************************************************"

	}#If($debugFlag)#> 

	$RoleDefinition = GetRoleDefinition -FilePath $RoleDefinitionFile
	$RoleDefinitionId = $RoleDefinition.Id
	$RoleAssignmentName = $RoleDefinition.Name 

	If($CustomRoleCount -eq 0)
	{
			$Message = "ADDING CUSTOM ROLE ASSIGNMENT:" + $RoleAssignmentName
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

		Write-Host -ForegroundColor Cyan "================================================================================" 
		Write-Host -ForegroundColor Cyan "Step" $DeployObject.StepCount ": ADDING SUBSCRIPTION SCOPE CUSTOM ROLE DEFINITION:"
			Write-Host -ForegroundColor Green "`t`t" $RoleAssignmentName
		Write-Host -ForegroundColor Cyan "================================================================================"

			$RoleDefinition = New-AzRoleDefinition -InputFile $RoleDefinitionFileOut
		$RoleDefinitionId = $RoleDefinition.Id
		Start-Sleep -Seconds 30
		Write-Host -ForegroundColor Green "Added Custom Role Assignment:" $RoleAssignmentName
		Write-Host -ForegroundColor Green "RoleDefinitionId="$RoleDefinitionId
			Write-Host -ForegroundColor Green "================================================================================`n"

	}
	Else
	{
		$Message = "`t`tRole:" + $RoleAssignmentName + "EXISTS... `
		`t`tRoleDefinitionId=" + $RoleDefinitionId + "`
		`t`tRoleDefinitionId=" + $RoleDefinitionId
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

		Write-Host -ForegroundColor White "`t`tContinuing deployment...."
			Write-Host -ForegroundColor Yellow "================================================================================`n"
	}

	If($DeployObject.Solution -eq "Transfer")
	{
		$DeployObject.TransferAppObj.RoleDefinitionId = $RoleDefinitionId
		#Write-Host -ForegroundColor Yellow "AddCustomRoleFromFile[109] RoleAssignmentName= `"$RoleAssignmentName`" : TransferAppObj.RoleDefinitionId=`"" $TransferAppObj.RoleDefinitionId"`""
	}
	Else #PickUp
	{
		$DeployObject.PickupAppObj.RoleDefinitionId = $RoleDefinitionId
		#Write-Host -ForegroundColor Yellow "AddCustomRoleFromFile[114] RoleAssignmentName= `"$RoleAssignmentName`" : PickupAppObj.RoleDefinitionId=`"" $PickupAppObj.RoleDefinitionId "`""
	}

	#$Caller ='AddCustomRoleFromFile[117]'
	#PrintHash -Object $DeployObject -Caller $Caller
	return $RoleDefinition
}#AddCustomRoleFromFile


Function global:GetRoleDefinition
{
	Param(
		 [Parameter(Mandatory = $false)] [string] $FilePath
		,[Parameter(Mandatory = $false)] [Object] $DeployObject
		)
	$Message = "GET ROLE DEFINITION FROM FILE:" $FilePath
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING AddCustomRoleFromFile.GetRoleDefinition[132]"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		Write-Host -ForegroundColor White -NoNewline "`$FilePath=`""
		Write-Host -ForegroundColor Cyan "`"$FilePath`""
		Write-Host "FilePath -eq null = " ($FilePath -eq $null)
		Write-Host "DeployObject -eq null = " ($DeployObject -eq $null)
	}
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}

	If (Test-Path ($FilePath))
	{
		$json = Get-Content $FilePath | Out-String | ConvertFrom-Json
		$RoleAssignmentName = $json.Name
		#Write-Host "AddCustomRoleFromFile.GetRoleDefinition[151] RoleAssignmentName= $RoleAssignmentName"
		$RoleDefinition = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.IsCustom -eq $true -and $_.Name -eq $RoleAssignmentName}
		$CustomRoleCount = ($RoleDefinition | Measure-Object | Select Count).Count 
			#Write-Host "AddCustomRoleFromFile.GetRoleDefinition[154] CustomRoleCount= $CustomRoleCount"

		If($CustomRoleCount -eq 0)
		{
			 $RoleDefinition = $null 
			}
		<#Else
		{
			$RoleDefinitionId = $RoleDefinition.Id
			#Write-Host -ForegroundColor Yellow "`t`tRoleDefinitionId="$RoleDefinitionId
			}#>

	}#Test-Path
	return $RoleDefinition
}#GetRoleDefinition

Function global:SetObjRoleDefinitionId
{
	Param(
		 [Parameter(Mandatory = $false)] [string] $FilePath
		,[Parameter(Mandatory = $false)] [Object] $DeployObject
		)

	#
	$Message = ":"
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING AddCustomRoleFromFile.SetObjRoleDefinitionId[182]"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

		Write-Host -ForegroundColor White -NoNewline "`$FilePath=`""
		Write-Host -ForegroundColor Cyan "`"$FilePath`""
		Write-Host "FilePath -eq null = " ($FilePath -eq $null)
		Write-Host "DeployObject -eq null = " ($DeployObject -eq $null)
	}
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}

	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"


	}#If($debugFlag)#>
	$Message = ":"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$RoleDefinition = GetRoleDefinition -FilePath $FilePath

	If($DeployObject -ne $null)
	{
		$DeployObject.RoleDefinitionId = $RoleDefinition.Id
	}
	Else
	{
		Write-Error "Target Object is not specified"
	}
}#SetObjRoleDefinitionId
