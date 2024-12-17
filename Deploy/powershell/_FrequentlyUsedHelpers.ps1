	If($debugFlag){exit(1)}
	####################################################################################################
	#
	If($debugFlag){
	}#If($debugFlag)#>

	Write-Host -ForegroundColor Magenta -BackgroundColor White ".[]"
	Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
	####################################################################################################
	#
	If($debugFlag){
		$Caller = ""
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		Write-Host -ForegroundColor Cyan "`$XYZ= `"$XYZ`""
	}#If($debugFlag)#> 

	####################################################################################################
	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta -BackgroundColor White ".[]"
		Write-Host -ForegroundColor Cyan "`$XYZ= `"$XYZ`""
	}#If($debugFlag)#> 

	####################################################################################################
	#
	If($debugFlag){
		Write-Host -ForegroundColor White "`$XYZ= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$XYZ`""
	}#If($debugFlag)#> 


	#
	If($debugFlag){
		Write-Host -ForegroundColor Yellow "`$XYZ= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$XYZ`""
	}#If($debugFlag)#>
	####################################################################################################

	$APIAppRegAppId = $DeployObject.APIAppRegAppId 
	$APIAppRegName = $DeployObject.APIAppRegName 
	$ClientAppRegAppId = $DeployObject.ClientAppRegAppId
	$ClientAppRegName = $DeployObject.ClientAppRegName



	#
	If($debugFlag){
		$ObjectName = "AzureResourcesObj"
		$Caller = "`nInitiateDeploymentProcess[294]:: after InitializeAzResourcesComplexObj:" + $ObjectName
		PrintCustomObjectAsObject -Object $AzureResourcesObj -Caller $Caller -ObjectName $ObjectName
		If($debugFlag){Exit(1)}
	}#If($debugFlag)#> 

	 #
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "[]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>
	####################################################################################################
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Caller = "`n[" + $today + "] STARTING FileName.FunctionName[]"
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
	}#If($debugFlag)#>
	$Message = ":"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	####################################################################################################

	$Message = ""
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING FileName.FunctionName[]"
	}
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	####################################################################################################

	$i = 0
				 ForEach ($resource in $AzureResourcesObj.GetEnumerator())
				 { 
					 If($resource -ne $null)
					{		
						$key = $resource.Name
					 $value = $resource.Value
					 $itemType = $value.GetType().Name
						<#
					 Write-Host -ForegroundColor Magenta -BackgroundColor White  "[$i]"
					 Write-Host -ForegroundColor Cyan "`$key= `"$key`""
					 Write-Host -ForegroundColor Cyan "`$value= `"$value`""
					 Write-Host -ForegroundColor Yellow "`$itemType=`"$itemType`""
					 #>
					 #
					 If($value -eq $true)
					 {
						 Write-Host -ForegroundColor Magenta -BackgroundColor White  "[$i] = " -NoNewline
						 Write-Host -ForegroundColor Cyan "`$key= `"$key`"" " :: " -NoNewline
						 Write-Host -ForegroundColor Yellow "`$value= `"$value`""
					 }#>
					 $i++
					 }
				}#Foreach($resource in $AzureResourcesObj)
####################################################################################################

	$ObjectName = $DeployObject.Solution + "AppObj"

	$Message = ":"
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta"`n[$today] STARTING FileName.FunctionName[]"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}

	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	####################################################################################################
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green"=" } Else{ Write-Host -ForegroundColor Green"=" -NoNewline}}
	####################################################################################################
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan"=" } Else{ Write-Host -ForegroundColor Cyan"=" -NoNewline}}
	####################################################################################################
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan"=" } Else{ Write-Host -ForegroundColor Cyan"=" -NoNewline}}
	####################################################################################################
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green"=" } Else{ Write-Host -ForegroundColor Green"=" -NoNewline}}
	####################################################################################################
	For($i=1;$i -le 80;$i++){ "=" >> $DeployObject.LogFile} "`n" >> $DeployObject.LogFile
	####################################################################################################


	$psCommand = "`$azResource = `n`tGet-AzResource  ```n`t`t" +
	$psCommand = "`nAddKeyVaultAccessPolicy  ```n`t`t" +
						"-KeyVaultName `"" + $KeyVaultName + "`"```n`t`t" +
						"-$PrincipalId `"" +  $PrincipalId + "`" ``n"   
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.CheckForExistingResource[2084]:" 
		Write-Host -ForegroundColor Green $psCommand
	}#If($debugFlag)#> 

	####################################################################################################
	$psCommand = "`$azResource = `n`tGet-AzResource  ```n`t`t" +
	$psCommand = "`nAddKeyVaultAccessPolicy  ```n`t`t" +
						"-KeyVaultName `"" + $KeyVaultName + "`"```n`t`t" +
						"-$PrincipalId `"" +  $PrincipalId + "`" ``n"   
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.CheckForExistingResource[2084]:" 
		If($PrintPSCommands){ Write-Host -ForegroundColor Green $psCommand }
	}#If($debugFlag)#> 

	####################################################################################################
	

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta"`n[$today] STARTING FileName.FunctionName"
	}#If($debugFlag)#> 

	Write-Host -ForegroundColor Magenta"`n[$today] STARTING FileName.FunctionName[Line]"  


	For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline} Write-Host "`n"


	For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "*" -NoNewline} Write-Host "`n"

	For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Cyan "=" -NoNewline} Write-Host "`n"

	For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta"=" -NoNewline} Write-Host "`n"

	For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Cyan"=" -NoNewline} Write-Host "`n"

####################################################################################################
	$Dashes = "="
	For($i=0;$i -le 80;$i++){ If($i -eq 80){ $Dashes = $Dashes + "=`n" } Else{$Dashes = $Dashes + "="} }
	#
	$Message = $Message +
	+ "`n"
	$Message = $Message + $Dashes

	$Message >> $DeployObject.LogFile 

####################################################################################################
	Write-Host -ForegroundColor Magenta ".[]"
	Write-Host -ForegroundColor Magenta "[]" 


	 Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""
####################################################################################################

	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta ".[]"
		Write-Host -ForegroundColor White "`$XYZ=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$XYZ`""
	}#If($debugFlag)#> 

####################################################################################################
	# For Complex Objects:
	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta ".[]"
		Write-Host -ForegroundColor White "`$XYZ=" -NoNewline
		Write-Host -ForegroundColor Cyan "`$"$XYZ
	}#If($debugFlag)#> 

####################################################################################################
	#ise:
	If($debugFlag){
		Write-Host -ForegroundColor Magenta ".[]"
		Write-Host -ForegroundColor Cyan "`$ = `"$`""
	}#If($debugFlag)#> 

	#vs
	If($debugFlag){
		Write-Host -ForegroundColor Magenta ".[]"
		Write-Host -ForegroundColor Cyan "` = `"`" "
	}#If($debugFlag)#> 

	Write-Host -ForegroundColor Cyan "`=`"`""
	#Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""

	If($debugFlag){exit(1)}

	Write-Host -ForegroundColor White -NoNewline
	Write-Host -ForegroundColor White -NoNewline ": "

	{$_ -in "1","y", "yes"}
	{$_ -in "0","n", "no"} 

	 For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
	Write-Host "`n"

	$ObjectName = ""
	$Caller = '`n .[]::'
	$ObjectName = $DeployObject.Solution + "AppObj"
	PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller

	If($debugFlag){
	$Caller = '`n .[]::'
	$ObjectName = ""
	PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
	}#If($debugFlag)#> 

	$FilePath = $LogsFolderPath + $ObjectName + ".ps1"
	PrintObjectAsVars -Object $DeployObject -Caller $Caller -ObjectName $ObjectName -FilePath $FilePath
	PrintObjectAsVars -Object $DeployObject -ObjectName $ObjectName -Caller $Caller 


	If($DeployObject.DebugFlag)
	{
		$Caller ='`n .[]::'
		$ObjectName = ""
		PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
	}#If($debugFlag)#>


	$Message = "Step " + $DeployObject.StepCount + ": " + ""
	Write-Host -ForegroundColor Cyan "================================================================================" 
	Write-Host -ForegroundColor Cyan $Message
	Write-Host -ForegroundColor Cyan "================================================================================"
	$DeployObject.StepCount++

	$Message = ""
	Write-Host -ForegroundColor Magenta"================================================================================" 
	Write-Host -ForegroundColor Magenta -BackgroundColor Black	 $Message
	Write-Host -ForegroundColor Magenta"================================================================================"
	$DeployObject.StepCount++
	-NoNewline
	"================================================================================"								>> $DeployObject.LogFile
	$Message																										>> $DeployObject.LogFile
	"================================================================================"								>> $DeployObject.LogFile


	"================================================================================"	>> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": ADD API PERMISSION: " + $PermissionParentName	>> $DeployObject.LogFile
	"================================================================================"	>> $DeployObject.LogFile
	#>
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "Step" $DeployObject.StepCount": ADD API PERMISSION:"$PermissionParentName
	Write-Host -ForegroundColor Cyan "================================================================================"
	$DeployObject.StepCount++

	Switch($DeployObject.Solution)
	{
		Transfer
		{
		}
		Pickup
		{
		}
		All
		{
		}
		Default
		{
			exit(1)
		}
	}#switch(Solution)


	#Write DeployObject to stdout
	Write-Host -ForegroundColor Cyan "`$DeployObject=@'`n[" 
	$json = ConvertTo-Json $DeployObject
	Write-Host -ForegroundColor Cyan $json
	Write-Host -ForegroundColor Cyan "]`n'@"




	<#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "[]"
	}#If($debugFlag)#> 

	<#If(-not $debugFlag){
	#}#If(-not $debugFlag) #>  

	#If($debugFlag){exit(1)}

	If($debugFlag){
			 $Caller ='`nInitiateScripts.ConfigureTransferAppObj[851] ::'
			$ObjectName = $DeployObject.Solution + "AppObj"
			 PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
			}#>
	



	#PRINT INDIV PROPERTIES:
	Write-Host -ForegroundColor Cyan "`$DeployObject.CloudEnvironment="$DeployObject.CloudEnvironment
	Write-Host -ForegroundColor Cyan "CurrUserName= " $DeployObject.CurrUserName
	Write-Host -ForegroundColor Yellow "Space index= " $firstSpace
	Write-Host -ForegroundColor Cyan "CurrUserFirst= " $DeployObject.CurrUserFirst
	Write-Host -ForegroundColor Cyan "CurrUserPrincipalName= " $DeployObject.CurrUserPrincipalName
		

	#
	If($debugFlag)
	{
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Magenta "=" }Else{Write-Host -ForegroundColor Magenta "=" -NoNewline}}
		Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureTransferAppObj[879]:"
		#Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.ResourceGroupName="$DeployObject.TransferAppObj.ResourceGroupName

		Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.Solution="$DeployObject.TransferAppObj.Solution
		Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.AppName="$DeployObject.TransferAppObj.AppName 

		Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegName="$DeployObject.TransferAppObj.APIAppRegName
		Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegAppId="$DeployObject.TransferAppObj.APIAppRegAppId
		Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegObjectId="$DeployObject.TransferAppObj.APIAppRegObjectId
		Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegExists="$DeployObject.TransferAppObj.APIAppRegExists

			Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegName="$DeployObject.TransferAppObj.ClientAppRegName
		Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegAppId="$DeployObject.TransferAppObj.ClientAppRegAppId
		Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegObjectId="$DeployObject.TransferAppObj.ClientAppRegObjectId
		Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegExists="$DeployObject.TransferAppObj.ClientAppRegExists
			Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.BuildFlag="$DeployObject.TransferAppObj.BuildFlag
		Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.PublishFlag="$DeployObject.TransferAppObj.PublishFlag

			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Magenta "=" }Else{Write-Host -ForegroundColor Magenta "=" -NoNewline}}
	}#If($debugFlag)#> 

	#
	If($debugFlag){
			$Caller ='`nInitiateScripts.ConfigureTransferAppObj[861] ::'
		$ObjectName = "TransferAppObj"
			PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
		#PrintDeployObject -ObjectName "DeployObject" -Object $DeployObject -Caller $Caller
	}#>

	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta ".[]"
		Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""
	}#If($debugFlag)#> 

	#
	If(-not $debugFlag){
	}#If(-not $debugFlag) #>

	If($debugFlag){exit(1)}


 
		#
		If($debugFlag){
			Write-Host -ForegroundColor Magenta "STARTING InitiateScripts.ConfigureDeployInfo[453]"

			 #$Caller ='nInitiateScripts.ConfigureDeployInfo[575]::'
			#$ObjectName = $DeployObject.Solution + "AppObj"
			#PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller 

			$TenantId = $DeployObject.TenantId
			Write-Host -ForegroundColor White -NoNewline "`$Environment=`""
			Write-Host -ForegroundColor Cyan $Environment"`""
			Write-Host -ForegroundColor White -NoNewline "`$Location=`""
			Write-Host -ForegroundColor Cyan $Location"`""
			Write-Host -ForegroundColor White -NoNewline "`$AppName=`""
			Write-Host -ForegroundColor Cyan $AppName"`""
			Write-Host -ForegroundColor White -NoNewline "`$DeployObject.TenantId=`""
			Write-Host -ForegroundColor Cyan $TenantId"`""
			Write-Host -ForegroundColor White -NoNewline "`$Solution=`""
			Write-Host -ForegroundColor Cyan $Solution"`""

			 #Write-Host -ForegroundColor White -NoNewline "`$BuildFlag=`""
			#Write-Host -ForegroundColor Cyan $BuildFlag"`""
			#Write-Host -ForegroundColor White -NoNewline "`$PublishFlag=`""
			#Write-Host -ForegroundColor Cyan $PublishFlag"`""
			}#If($debugFlag)#>
	

		#
		If($debugFlag){
			Write-host -ForegroundColor Magenta "`nInitiateScripts.SetLogFolderPath[920]::"
			Write-host -ForegroundColor Green  "`$currDir=`"$currDir`""
			Write-host -ForegroundColor Green  "`$currDirPath=`"$currDirPath`""

			 Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""

			Write-host -ForegroundColor Green  "`$DeployFolder=`"$DeployFolder`""

			Write-host -ForegroundColor Cyan  "`$TemplateDir=`"$TemplateDir`""

			$LogsFolderFullName = $LogsFolder.FullName
			Write-Host -ForegroundColor Yellow "`$LogsFolderFullName=`"$LogsFolderFullName`""
			Write-host -ForegroundColor Yellow "`$LogsFolderParentPath=`"$LogsFolderParentPath`""
			Write-Host -ForegroundColor Yellow "`$LogsFolderPath=`"$LogsFolderPath`""
			Write-Host ""
		}#debugFlag #>


	#
	If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "InitiateScripts.SetOutputFileNames[131]"
			Write-Host -ForegroundColor Cyan "`$DeployObject.TenantName=`""$DeployObject.TenantName
		Write-Host -ForegroundColor Cyan "`$DeployObject.Environment=`""$DeployObject.Environment	
			Write-Host -ForegroundColor Yellow "`$DeployObject.AppName=`""$DeployObject.AppName
		Write-Host -ForegroundColor Yellow "`$DeployObject.Solution=`""$DeployObject.Solution
	}#If($debugFlag)#> 


	 #
		If($debugFlag){
			Write-Host -ForegroundColor Magenta  "`n CreateAppRegistration.ConfigureWebApp[549] CreateAppRegistration.ConfigureWebApp"
			Write-Host -ForegroundColor Yellow "`$uri=`"$uri`""

			Write-Host -ForegroundColor Green "DeployObject.Solution=" $DeployObject.Solution
			Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
			 Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegAppId=" $DeployObject.ClientAppRegAppId
			 Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegObjectId=" $DeployObject.ClientAppRegObjectId
			Write-Host -ForegroundColor Cyan  "DeployObject.ClientAppRegSecret=" $DeployObject.ClientAppRegSecret
			Write-Host -ForegroundColor Green  "DeployObject.ClientAppRegServicePrincipalId=" $DeployObject.ClientAppRegServicePrincipalId

			$Caller ='CreateAppRegistration.ConfigureWebApp[556] DeployObject AFTER Create' 
			 $ObjectName = $DeployObject.Solution + "AppObj"
			$FilePath = $LogsFolderPath + $ObjectName + ".ps1"

			 #PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
			#PrintObjectAsVars -Object $DeployObject -ObjectName $ObjectName -Caller $Caller
			#PrintObjectAsVars -Object $DeployObject -Caller $Caller -FilePath $FilePath
		} #If($debugFlag) #>

		<#
		DEBUG
		$i=0
		Write-Host -ForegroundColor Yellow "RequiredDelegatedPermissionNames:"
		ForEach ($item in $RequiredDelegatedPermissionNames)
		{
			$item = $item.Trim()
			Write-Host "[$i]=" $item
			$i++
		}
		#>

#
	If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "`n================================================================================"
		Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigurePickupAppObj[1006]:"
			Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.DeploymentName=" $DeployObject.PickupAppObj.DeploymentName
		Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.ResourceGroupName=" $DeployObject.PickupAppObj.ResourceGroupName
		Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.AppName=" $DeployObject.PickupAppObj.AppName
		Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.APIAppRegName=" $DeployObject.PickupAppObj.APIAppRegName

		Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.ClientAppRegName=" $DeployObject.PickupAppObj.ClientAppRegName
		Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.ClientAppRegAppId=" $DeployObject.PickupAppObj.ClientAppRegAppId
		#Write-Host -ForegroundColor Green "`$PickupAppObj.ClientAppRegObjectId=" $PickupAppObj.ClientAppRegObjectId

		Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.BuildFlag=" $DeployObject.PickupAppObj.BuildFlag
		Write-Host -ForegroundColor Green "`$DeployObject.PickupAppObj.PublishFlag=" $DeployObject.PickupAppObj.PublishFlag

		Write-Host -ForegroundColor Magenta "================================================================================"
			$Caller ='InitiateScripts.ConfigurePickupAppObj[959]::'
		$ObjectName = "DeployObject"
		PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
	}#If($debugFlag)#>



#
Write-Host -ForegroundColor Green"`$itemKey= `"$itemKey`""
Write-Host -ForegroundColor Green"`$item= `"$item`""
Write-Host -ForegroundColor Yellow"`$item.GetType()=" $item.GetType()
Write-Host -ForegroundColor Cyan"`$item.GetType().Name=" $item.GetType().Name
Write-Host -ForegroundColor Magenta"`$item.GetType().BaseType=" $item.GetType().BaseType
Write-Host -ForegroundColor Green"item.Count= " $item.Count
#>


#
If($debugFlag){
	Write-Host -ForegroundColor Yellow "After Get-AzTenant...."
	Write-Host -ForegroundColor White "`$SubscriptionName= " -NoNewline
	Write-Host -ForegroundColor Green "`"$SubscriptionName`""
	Write-Host -ForegroundColor White "`$SubscriptionId= " -NoNewline
	Write-Host -ForegroundColor Green "`"$SubscriptionId`""
	Write-Host -ForegroundColor White "`$TenantName= " -NoNewline
	Write-Host -ForegroundColor Green "`"$TenantName`""
	Write-Host -ForegroundColor White "`$TenantId= " -NoNewline
	Write-Host -ForegroundColor Green "`"$TenantId`""	
}#If($debugFlag)#> 
