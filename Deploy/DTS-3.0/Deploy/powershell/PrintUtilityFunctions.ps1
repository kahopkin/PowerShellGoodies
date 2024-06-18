  
Function global:PrintWelcomeMessage
{
	Param
	(
		[Parameter(Mandatory = $false)] [string] $LogFile
	)

	#
	If($env:username -eq "kahopkin"){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintWelcomeMessage[10]"
	}#>

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$StartTime = $today
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	$Message = "[" + $today + "] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!"
	Write-Host -ForegroundColor Green -BackgroundColor Black $Message
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}

	If($LogFile -ne $null)
	{
		$Message > $LogFile
	}
}#PrintWelcomeMessage


Function global:PrintCurrentContext
{
	Param(
			[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintCurrentContext[36]"
	}#If($debugFlag)#>

	$TenantName = "'" + $DeployObject.TenantName + "'"
	$TenantId = "'" + $DeployObject.TenantId + "'"
	$SubscriptionName = "'" + $DeployObject.SubscriptionName  + "'"
	$SubscriptionId = "'" + $DeployObject.SubscriptionId + "'"

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green "`t`t`tCURRENT AZURE CONTEXT:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor White -NoNewline "Tenant Name: "
	#Write-Host -ForegroundColor Green $TenantName
	Write-Host -ForegroundColor Green $DeployObject.TenantName
	Write-Host -ForegroundColor White -NoNewline "Tenant Id: "
	#Write-Host -ForegroundColor Green $TenantId
	Write-Host -ForegroundColor Green $DeployObject.TenantId
	Write-Host -ForegroundColor White -NoNewline "Subscription Name: "
	#Write-Host -ForegroundColor Green $SubscriptionName
	Write-Host -ForegroundColor Green $DeployObject.SubscriptionName
	Write-Host -ForegroundColor White -NoNewline "Subscription Id: "
	#Write-Host -ForegroundColor Green $SubscriptionId
	Write-Host -ForegroundColor Green $DeployObject.SubscriptionId
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
}#PrintCurrentContext


Function global:PrintLogInfo
{
	Param(
			[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

	If($debugFlag){
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintLogInfo[73]"
	}

	$Dashes = "="
	For($i=0;$i -le 80;$i++){ If($i -eq 80){ $Dashes = $Dashes + "=`n" } Else{$Dashes = $Dashes + "="} }
	$Dashes > $DeployObject.LogFile

	$Message = "[" + $today + "] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!`n"
	$Message = $Message + $Dashes
	$Message = $Message + "`t FILES CREATED AND USED (PARAMETER FILES, ETC):`n"
	$Message = $Message + "JSON output file:`n"
	$Message = $Message + $DeployObject.OutFileJSON + "`n"
	$Message = $Message + "Log file:`n"
	$Message = $Message + $DeployObject.LogFile + "`n"
	$Message = $Message + "BICEP Parameter file:`n"
	$Message = $Message + $DeployObject.BicepFile + "`n"
	$Message = $Message + "DTP Custom Role Definition file:`n"
	$Message = $Message + $DeployObject.RoleDefinitionFile + "`n"

	$Message = $Message + $Dashes
	$Message = $Message + "You are currently logged in below subscription:`n"
	$Message = $Message + "Tenant Name: " + $DeployObject.TenantName + "`n"
	$Message = $Message + "Tenant Id: " + $DeployObject.TenantId + "`n"
	$Message = $Message + "Subscription: " + $DeployObject.SubscriptionName + "`n"
	$Message = $Message + "Subscription Id: " + $DeployObject.SubscriptionId + "`n"
	$Message = $Message + $Dashes
	$Message = $Message + "Azure Cloud: " + $DeployObject.CloudEnvironment + "`n"
	$Message = $Message + "Azure Location: " + $DeployObject.Location + "`n"
	$Message = $Message + "App Name: " + $DeployObject.AppName + "`n"
	$Message = $Message + "Resource Group: "+ $DeployObject.ResourceGroupName + "`n"

	$Message = $Message + $Dashes
	<#
	$Message = $Message +
	+ "`n"
	$Message = $Message + $Dashes
	#>
	$Message >> $DeployObject.LogFile
}#PrintLogInfo


#Helper function to output a message to the console
Function global:PrintMessage
{
	Param(
		[Parameter(Mandatory = $true)] [string] $Message
		,[Parameter(Mandatory = $true)] [Int32]  $StepCount
	)
	<#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintMessage[133]"

	}#If($debugFlag)#>

	$MessageOut = "Step " + $StepCount + ": " + $Message
	<#
	Write-Host -ForegroundColor White  "`$MessageOut= " -NoNewline
	Write-Host -ForegroundColor Cyan "`"$MessageOut`""
	Write-Host -ForegroundColor Yellow  "MessageOut.length= " $MessageOut.length
	#>
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Magenta -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Magenta -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Magenta -BackgroundColor Black $MessageOut
	<#
	If($MessageOut.length -gt 80)
	{
	$numberOfLines =  [int][Math]::Ceiling($MessageOut.length / 80)

	Write-Host -ForegroundColor White "`$numberOfLines= " -NoNewline
	Write-Host -ForegroundColor Cyan "`"$numberOfLines`""

	For($i=0; $i -lt $numberOfLines; $i++)
	{
		For($($i= 0; $start=0; $end=0;); $j -lt $MessageOut.length; $j=$j+80); $j -lt $MessageOut.length; $j+)
		{
		$start = $end;
		$end = $start + 80
		#Write-Host -ForegroundColor Gre -BackgroundColor Black $MessageOut.Substring($j, $j+80)
		Write-Host -ForegroundColor Cyan "`$start= `"$XYZ`""
		Write-Host -ForegroundColor Cyan "`$start= `"$XYZ`""

		Write-Host -ForegroundColor Yellow "`$end= `"$XYZ`""
		Write-Host -ForegroundColor Yellow "`$end= `"$XYZ`""
		}#inner for
	}#outer for
	}
	Else
	{
	Write-Host -ForegroundColor Magenta -BackgroundColor Black $MessageOut
	}
	#>
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Magenta -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Magenta -BackgroundColor Black "=" -NoNewline}}
	$StepCount++

	return $StepCount
}#PrintMessage


#Helper function to write output to log file
Function global:PrintMessageToFile
{
	Param
	(
	 [Parameter(Mandatory = $true)] [string] $Message
	,[Parameter(Mandatory = $true)] [Int32]  $StepCount
	,[Parameter(Mandatory = $true)] [string] $LogFile
	)
	<#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintMessageToFile[193]"
		#Write-Host -ForegroundColor Green "`$StepCount= `"$StepCount`""
		Write-Host -ForegroundColor Yellow "`$Message= `"$Message`""
	}#If($debugFlag)#>

	$Dashes = "="
	For($i=0;$i -le 80;$i++){ If($i -eq 80){ $Dashes = $Dashes + "=`n" } Else{ $Dashes = $Dashes + "=" } }
	$MessageOut = "Step " + $StepCount + ": " + $Message
	$MessageOut = $MessageOut + $Dashes
	$MessageOut >> $LogFile
}#PrintMessageToFile


Function global:PrintCustomObject{
	Param(
		[Parameter(Mandatory = $true)] [object] $Object
		,[Parameter(Mandatory = $false)] [string] $Caller
		,[Parameter(Mandatory = $false)] [string] $ObjectName
	)
	<#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintCustomObject[199]"
	}#If($debugFlag)#>

	<#
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "START UtilityFunctions.PrintCustomObject[1518]::"
	#>
	Write-Host -ForegroundColor Cyan -BackgroundColor Black $Caller
	#For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta -BackgroundColor Black "=" -NoNewline} Write-Host "`n"


	#Write-Host -ForegroundColor Yellow -BackgroundColor Black "Object.GetType=" $Object.GetType().Name
	Write-Host -ForegroundColor Magenta "$ObjectName {"
	$i=0
	ForEach ($item in $Object.GetEnumerator())
	{
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] `$name="$item.name -NoNewline
		#Write-Host -ForegroundColor Cyan -BackgroundColor Black "; `$value="$item.value
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] `$item.name="$item.name -NoNewline
		#Write-Host -ForegroundColor Cyan -BackgroundColor Black "; `$item.value="$item.value
		If($item.value -ne $null)
		{
			$itemName = $item.name
			$itemValue = $item.value
			$itemType = ($itemValue).GetType().Name
			$debugMsg = "[" + $itemName + "].Type() = " + $itemType

			Switch($itemType)
			{
				OrderedDictionary
				{
					#$objName = "`t" + $item.name + "`n`t{"
					$dictionaryObjName = "`t" + $itemName + "`n`t{"
					Write-Host -ForegroundColor Magenta $dictionaryObjName
					ForEach ($dictionaryItem in $itemValue.GetEnumerator())
					{
						If($dictionaryItem.value -ne $null)
						{
							$dictionaryKey = $dictionaryItem.name
							$itemType = ($itemValue).GetType().Name
							$debugMsg = "[" + $dictionaryKey + "].Type() = " + $itemType
							#Write-Host -ForegroundColor Yellow -BackgroundColor Black $debugMsg
							$dictionaryKey = "`t`t" + $dictionaryItem.name + " = "
							$value = "`"" + $dictionaryItem.value + "`""
							Write-Host -ForegroundColor Green $dictionaryKey -NoNewline
							Write-Host -ForegroundColor Cyan $value
						}
						Else
						{
							$dictionaryKey = $dictionaryItem.name
							#$debugMsg = "`t`t[" + $dictionaryKey + "]"
							$debugMsg = "`t`t" + $dictionaryKey + " = `$null"
							Write-Host -ForegroundColor Red $debugMsg
						}
					}#ForEach
					$dictionaryObjName = "`t}#" + $itemName #+ "`n"
					Write-Host -ForegroundColor Magenta $dictionaryObjName
				}#OrderedDictionary
				PSCustomObject
				{
					Write-Host -ForegroundColor Red "item.name="$item.name
					#Write-Host -ForegroundColor Red "[][$i] `$item.GetType=" $item.GetType()
					#Write-Host -ForegroundColor Red "[][$i] `$item.value.GetType()=" $item.value.GetType()
					#Write-Host -ForegroundColor Red "[][$i] `$item.value=" $item.value

					$itemValue.PSObject.Properties | ForEach-Object
					{
						Write-Host -ForegroundColor Cyan "`t`t"$_.Name "=" $_.Value
					}
				}#PSCustomObject
				Default
				{
					#$message = "`t" + $item.name + "=`"" + $item.value + "`""
					$key = "`t" + $item.name + " = "
					$value = "`"" + $item.value + "`""
					Write-Host -ForegroundColor Green $key -NoNewline
					Write-Host -ForegroundColor Cyan $value
				}#Default
			}#Switch
		}#If item.value -ne null
		Else
		{
			$key = $item.name
			$debugMsg = "`t[" + $key + "]"
			$debugMsg = "`t" + $key + " = `$null"
			Write-Host -ForegroundColor Red $debugMsg

			#value has not been set yet
			#Write-Host -ForegroundColor Red "`t"$item.name #-NoNewline
			#Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "=null"
		}
		#$item.name +"=" + $item.value >> $FilePath
		$i++
	} #ForEach ($item in $Object)

	Write-Host -ForegroundColor Magenta "}#$ObjectName"  
}#PrintCustomObject


Function global:PrintCustomObjectAsObject{
	Param(
			[Parameter(Mandatory = $false)] [String] $ObjectName
		,[Parameter(Mandatory = $false)] [String] $Caller
		,[Parameter(Mandatory = $true)]  [Object] $Object
	)
	<#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintCustomObjectAsObject[324]"
		#Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`$Caller = `"$Caller`""
		#Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "`$ObjectName= `"$ObjectName`""
		#Write-Host -ForegroundColor Yellow "$ObjectName.Count= " $rootObjCount
	}#If($debugFlag)#>

		$objectType = $Object.GetType()
		$objectTypeName = ($Object).GetType().Name
		$objectBaseType = $Object.GetType().BaseType
		$rootObjCount = $Object.Count
		<#
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$objectType=`"$objectType`""
		Write-Host -ForegroundColor Cyan -BackgroundColor Black "`$objectTypeName=`"$objectTypeName`""
		Write-Host  -ForegroundColor Green -BackgroundColor Black "`$objectBaseType=`"$objectBaseType`""
		#>
		$i = 0
		$k = 1
		Write-Host -ForegroundColor Green  "`$$ObjectName = [ordered]@{"
		ForEach ($item in $Object.GetEnumerator())
		{
			If($item.value -ne $null)
			{
				$itemName = $item.name
				$itemValue = $item.value
				$itemType = ($itemValue).GetType().Name
				$itemBaseType = ($itemValue).GetType().BaseType
				$debugMsg = "`$" + $itemName + ".Type() = " + $itemType
				<#
				Write-Host -ForegroundColor Cyan "`$itemName= `"$itemName`""
				Write-Host -ForegroundColor Cyan "`$itemType= `"$itemType`""
				Write-Host -ForegroundColor Yellow -BackgroundColor Black $debugMsg
				#Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$itemType="$itemType
				#>

				If($itemType -contains "System.ValueType"){ $itemType = "DeploymentVariable"}

				Switch($itemType)
				{
					Boolean
					{
						$key = "`t" + $item.name + " = "
						$value = "`$" + $item.value + ";"
						Write-Host -ForegroundColor White $key -NoNewline
						Write-Host -ForegroundColor Cyan $value
					}#Boolean

					{$_ -in "OrderedDictionary","Dictionary"}
					{
					$item = $itemValue
					$dictionaryObjName = "`t" + $itemName + " = [ordered]@{"
					Write-Host -ForegroundColor Green $dictionaryObjName
					ForEach ($dictionaryItem in $itemValue.GetEnumerator())
					{
						If($dictionaryItem.value -ne $null)
						{
							$dictionaryKey = $dictionaryItem.name
							$itemType = ($itemValue).GetType().Name
							$dictionaryKey = "`t`t" + $dictionaryItem.name + " = "
							$value = "`"" + $dictionaryItem.value + "`";"
							Write-Host -ForegroundColor White $dictionaryKey -NoNewline
							Write-Host -ForegroundColor Cyan $value
						}
						Else
						{
							$dictionaryKey = $dictionaryItem.name
						}
					}#ForEach
					$dictionaryObjName = "`t};#" + $itemName #+ "`n"
					Write-Host -ForegroundColor Green $dictionaryObjName
					}#OrderedDictionary

					PSCustomObject
					{
						Write-Host -ForegroundColor Red "item.name="$item.name
						$itemValue.PSObject.Properties | ForEach-Object
						{
							Write-Host -ForegroundColor Cyan "`t`t"$_.Name "=" $_.Value ";"
						}
					}#PSCustomObject

					Object[]
					{
						$arrayName = "`t" + $itemName + "=`n`t"
						Write-Host -ForegroundColor DarkYellow $arrayName
						$p = 1
						ForEach ($piece in $itemValue.GetEnumerator())
						{
							If($p -eq $itemValue.Count)
							{
								$value = "`t  `"" + $piece + "`""
							}
							Else
							{
								$value = "`t  `"" + $piece + "`","
							}
							$p++
							Write-Host -ForegroundColor Magenta $value
						}
						Write-Host  -ForegroundColor DarkYellow "`t;"
					}#Object[]

					DeploymentVariable
					{
					$key = $item.Key
					$value = $item.Value
					$valueType = $item.Value.Type

					If($valueType -eq "Object")
					{
						$itemvalue = ($item.Value.Value).ToString()
						$itemValueType = $itemValue.GetType()

						$obj =  ConvertFrom-Json $itemvalue.ToString()
						$propCount = $obj.keys.Count

						$j = 0
						$obj.PSObject.Properties | ForEach-Object {
							$property = $_.Name
							$value = $_.Value
							$valueType = $value.GetType()
							$valueTypeName = $value.GetType().Name
							$valueBaseType = $value.GetType().BaseType
							If($property -eq "name")
							{
							$customObjectName = $value
							Write-Host -ForegroundColor Green  "`t$customObjectName = @{"
							}#If($property -eq "name")
							Else
							{
							If($valueTypeName -eq "Object[]")
							{
								If($value.Count -eq 0)
								{
								Write-Host -ForegroundColor Yellow "`t$property = @();"
								}#If($value.Count -eq 0)
								Else
								{
								Write-Host -ForegroundColor Yellow "`t$property ="
								Write-Host -ForegroundColor Yellow "`t@("
								ForEach ($piece in $value.GetEnumerator())
								{
									If($i -eq 0)
									{
									Write-Host -ForegroundColor Yellow "`t["
									Write-Host -ForegroundColor Yellow "`t@("
									$piece = "`t`t`"" + $piece + "`""
									}#ElseIf($i -eq 0)>
									ElseIf($i -eq $value.Count)
									{
									$piece = "`t`t`"" + $piece + "`""
									}
									Else
									{
										$piece = "`t`t`"" + $piece + "`","
									}#Else If($i -eq $value.Count)
									$i++
									Write-Host -ForegroundColor Magenta $piece
								}#ForEach ($piece in $value.GetEnumerator())
								If($j -eq $propCount)
								{
									Write-Host -ForegroundColor Yellow "`t)}"
								}# If($j -eq $propCount)
								Else
								{
									Write-Host -ForegroundColor Yellow "`t);"
								}#Else If($j -eq $propCount)
								}#ElseIf($value.Count -eq 0)		
							}#If($valueTypeName -eq "Object[]")
							Else
							{
								$key = "`t" + $property + " = "
								Write-Host -ForegroundColor Yellow $key -NoNewline
							}#ElseIf($valueTypeName -eq "Object[]")
							}#Else If($property -eq "name")
							$j++
						}#$obj.PSObject.Properties | ForEach-Object {
						If($k -eq $rootObjCount)
						{
						Write-Host -ForegroundColor Green "`t}#$customObjectName"
						}
						Else
						{
						Write-Host -ForegroundColor Green "`t};#$customObjectName"
						}

					}#If($valueType -eq "Object")
					Else
					{
						#
						$key = "`t" + $item.Key + " = "
						$value = "`"" + $item.Value.Value + "`";"
						Write-Host -ForegroundColor White $key -NoNewline
						Write-Host -ForegroundColor Cyan $value
					}#ElseIf($valueType -eq "Object")
					}#DeploymentVariable
					Default
					{
						$key = "`t" + $item.name + " = "
						$value = "`"" + $item.value + "`";"

						Write-Host -ForegroundColor White $key -NoNewline
						Write-Host -ForegroundColor Cyan $value

					}#Default
				}#Switch
			}#If item.value -ne null
			Else
			{
				$key = $item.name
				$debugMsg = "`t[" + $key + "]"
				#value has not been set yet
				Write-Host -ForegroundColor Red "`t"$item.name -NoNewline
				Write-Host -ForegroundColor Red " = `$null;"
			}
			$i++
			$k++
		} #ForEach ($item in $Object)
		Write-Host -ForegroundColor Green "}#$ObjectName"			
}#PrintCustomObjectAsObject

#send in $DeploymentOutput.Outputs
Function global:PrintDeploymentOutput{
	Param(
			[Parameter(Mandatory = $false)] [string] $ObjectName
		,[Parameter(Mandatory = $true)] [Object] $Object
		,[Parameter(Mandatory = $false)] [string] $Caller
		)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintDeploymentOutput[582]"
	}

	$objectType = $Object.GetType()
	$objectTypeName = ($Object).GetType().Name
	$objectBaseType = $Object.GetType().BaseType

	<#
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$objectType=`"$objectType`""
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`$objectTypeName=`"$objectTypeName`""
	Write-Host  -ForegroundColor Green -BackgroundColor Black "`$objectBaseType=`"$objectBaseType`""
	#>
	$i=0
	ForEach ($item in $Object.Keys)
	{
		$key = $item
		$value = $Object.$key.value
		$valueOut = "`"" + $value + "`""
		$keyOut = "`$" + $item

		$itemType = $value.GetType().Name
		Write-Host -ForegroundColor Yellow -NoNewline "`$itemType="
		$itemTypeOut = "`"" + $itemType + "`""
		Write-Host -ForegroundColor Green $itemTypeOut

		Switch( $itemType )
		{
			Object[]{
				<#
				Write-Host -ForegroundColor Yellow -NoNewline "`$itemType="
				$itemTypeOut = "`"" + $itemType + "`""
				Write-Host -ForegroundColor Green $itemTypeOut

				Write-Host -ForegroundColor Yellow  "`$key = " -NoNewline
				Write-Host -ForegroundColor Green $key

				Write-Host -ForegroundColor White "`$item=`"" -NoNewline
				Write-Host -ForegroundColor Green "`"$item`""
			#>
				Write-Host -ForegroundColor Yellow "`$key = "
				Write-Host -ForegroundColor Green $valueOut

			}#Object[]
			{$_ -in "String","Int64"}
			{
				<#
				Write-Host -ForegroundColor White -NoNewline "`$itemType="
				$itemTypeOut = "`"" + $itemType + "`""
				Write-Host -ForegroundColor Cyan $itemTypeOut
				#>

				Write-Host -ForegroundColor White -NoNewline "$keyOut = "
				Write-Host -ForegroundColor Cyan $valueOut

				$i++ 
				#For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
				#Write-Host "`n"
			}
			Default
			{
				#
				Write-Host -ForegroundColor White -NoNewline "$keyOut = "
				Write-Host -ForegroundColor Cyan $valueOut
				#>
			}#Default
		}#Switch( $itemType )

	}
}#PrintDeploymentOutput


Function global:PrintObject
{
	Param(
		[Parameter(Mandatory = $true)]  [Object] $Object
		, [Parameter(Mandatory = $false)] [string] $Caller
		, [Parameter(Mandatory = $false)] [string] $ObjectName
		, [Parameter(Mandatory = $false)] [string] $FilePath
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintObject[509]"
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$today] START $Caller.PrintObject: $ObjectName"
		Write-Host -ForegroundColor Yellow "`$ObjectName= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ObjectName`""
		#If($FilePath -ne $null){Write-Host -ForegroundColor Cyan "`$FilePath= `"$FilePath`""}
	}#If($debugFlag)#>
	Write-Host -ForegroundColor Yellow "ObjectName= " -NoNewline
	Write-Host -ForegroundColor Cyan "`"$ObjectName`""

	$i = 1
	ForEach ($item in $Object.GetEnumerator())
	{
		Write-Host -ForegroundColor White -BackgroundColor Black "[$i]" $item.name "=" $item.value #"`n"
		<#
		If($FilePath -ne $null){
			$item.name +"=" + $item.value >> $FilePath
		}		#>
		$i++
	}
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
}#PrintObject


Function global:PrintHash
{
	Param(
		[Parameter(Mandatory = $true)]  [Object] $Object
		, [Parameter(Mandatory = $false)] [string] $Caller
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintHash[463]"
	}

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
	$i=0
	Write-Host -ForegroundColor Cyan  "@{"
	ForEach ($item in $Object)
	{
		Write-Host -ForegroundColor Cyan $item.name "="""$item.value""";"
		$i++
	}
	Write-Host -ForegroundColor Cyan "}"
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHash


Function global:PrintSubscription
{
	Param(
		[Parameter(Mandatory = $true)] [object] $Object
	)
	<#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintSubscription[563]"
	}#If($debugFlag)#>

	$i=0
	ForEach ($item in $Object.GetEnumerator())
	{
		Write-Host -ForegroundColor White -BackgroundColor Black $item.name "= " -NoNewline
		Write-Host -ForegroundColor Green -BackgroundColor Black $item.value
		$i++
	}
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "-" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "-" -NoNewline}}
}#PrintSubscription


Function global:PrintDeployDuration
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintDeployDuration[630]"
	}

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$DeployObject.EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$DeployObject.Duration = New-TimeSpan -Start $DeployObject.StartTime -End $DeployObject.EndTime
	#$SolutionObjName = $DeployObject.SolutionObjName
	#$DeployObject.$SolutionObjName.EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#$DeployObject.$SolutionObjName.Duration = New-TimeSpan -Start $DeployObject.StartTime -End $DeployObject.EndTime
	$DeployObject.EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	$DeployObject.Duration = New-TimeSpan -Start $DeployObject.StartTime -End $DeployObject.EndTime

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan "[$today] COMPLETED DEPLOYMENT:" $DeployObject.AppName
	Write-Host -ForegroundColor Cyan "[$today] COMPLETED Environment:" $DeployObject.Environment
	Write-Host -ForegroundColor Cyan "DEPLOYMENT DURATION [HH:MM:SS]:" $DeployObject.Duration
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}

	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile

	"DEPLOYMENT DURATION [HH:MM:SS]:" + $DeployObject.Duration		>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile
}#PrintDeployDuration


Function global:WriteJsonFile{
	Param(
		[Parameter(Mandatory = $true)] [String] $FilePath
		, [Parameter(Mandatory = $true)] [Object] $CustomObject
	)

	<#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.WriteJsonFile[750]"
	}#If($debugFlag)#>

	<#If($debugFlag){
		$Caller ='UtilityFunctions.WriteJsonFile[627]'
		Write-Host -ForegroundColor Magenta "UtilityFunctions.WriteJsonFile[628]:"
		Write-host -ForegroundColor Yellow  "`$FilePath=`"$FilePath`""
		#PrintObject -Object $CustomObject -Caller $Caller
		#PrintHash -Object $CustomObject -Caller $Caller
	}#>

	<#
	$i=0
	ForEach ($item in $CustomObject.GetEnumerator())
	{
		Write-Host $item
	}#ForEach
	#>

	$json = ConvertTo-Json $CustomObject
	$json > $FilePath
}#WriteJsonFile



#### CURRENTLY NOT REFERENCED ANYWHERE
Function global:WriteLogFile
{
	Param(
			[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.WriteLogFile[2120]"
	}#If($debugFlag)#>

	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	"[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!" 		>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile

	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	"`t`t`t FILES CREATED AND USED (PARAMETER FILES, ETC):"			>> $DeployObject.LogFile
	"`nJSON output file:"											>> $DeployObject.LogFile
	$DeployObject.OutFileJSON										>> $DeployObject.LogFile
	"`nLog file:"													>> $DeployObject.LogFile
	$DeployObject.LogFile											>> $DeployObject.LogFile
	"`nCustom Role Definition files:"
	$DeployObject.RoleDefinitionFile					>> $DeployObject.LogFile
	#$DeployObject.TransferAppObj.RoleDefinitionFile					>> $DeployObject.LogFile
	#$DeployObject.PickupAppObj.RoleDefinitionFile					>> $DeployObject.LogFile
	"`nBICEP Parameter file:">> $DeployObject.LogFile
	$DeployObject.TemplateParameterFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile

	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	"[$today] CONNECTED TO AZURE CLOUD..." 							>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	"Selected Cloud:" + $AzCloud  + " Cloud" 						>> $DeployObject.LogFile

	#"`nSelected Cloud:" + $AzCloud  + " Cloud" 					>> $DeployObject.LogFile
	"`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] 			>> $DeployObject.LogFile
	"`nYour Selection:" + $LocationArr[$LocationIndex].DisplayName + "Region" 	>> $DeployObject.LogFile
	"`nSelected Application Environment:" + $DeployObject.Environment >> $DeployObject.LogFile
	"`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] 			>> $DeployObject.LogFile
	#"`nSelected Application Environment:" + $DeployObject.Environment >> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile
	"You are currently logged in context:"							>> $DeployObject.LogFile
	"Tenant Name:" + $DeployObject.TenantName						>> $DeployObject.LogFile
	"Tenant Id:" + $DeployObject.TenantId							>> $DeployObject.LogFile
	"Subscription:" + $DeployObject.SubscriptionName				>> $DeployObject.LogFile
	"Subscription Id:" + $DeployObject.SubscriptionId				>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile

	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile
	"`t`t`t`tCURRENT CONTEXT:"								>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile
	"Tenant:" + $DeployObject.TenantName							>> $DeployObject.LogFile
	"TenantId:" + $DeployObject.TenantId							>> $DeployObject.LogFile
	"Subscription:" + $DeployObject.SubscriptionName				>> $DeployObject.LogFile
	"SubscriptionId:" + $DeployObject.SubscriptionId				>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile

	"`nSelected Region:" + $Location.DisplayName + "Region" 		>> $DeployObject.LogFile
	"`nSelected Application Environment:" + $DeployObject.Environment >> $DeployObject.LogFile
	"`nApp Name:" + $DeployObject.AppName 							>> $DeployObject.LogFile
	"`Sql Admin Name:" + $DeployObject.SqlAdmin 					>> $DeployObject.LogFile
	"`Sql Admin PwdP lainText:" + $DeployObject.SqlAdminPwdPlainText >> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile
	"[$today] COMPLETED DEPLOYMENT "								>> $DeployObject.LogFile
	"DEPLOYMENT DURATION [HH:MM:SS]:" + $Duration					>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"	>> $DeployObject.LogFile

	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": ADD API PERMISSION: " + $PermissionParentName	>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	$DeployObject.StepCount++
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": ADDING SUBSCRIPTION SCOPE CUSTOM ROLE DEFINITION:" + $RoleAssignmentName	>> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	$DeployObject.StepCount++
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	"Step" + $DeployObject.StepCount + ": CREATE RESOURCE GROUP: $DeployObject.ResourceGroupName" >> $DeployObject.LogFile
	For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n"  >> $DeployObject.LogFile
	$DeployObject.StepCount++
}#WriteLogFile


Function global:PrintObjectAsVars
{
	Param(
			[Parameter(Mandatory = $true)] [object] $Object
		, [Parameter(Mandatory = $false)] [string] $ObjectName
		, [Parameter(Mandatory = $false)] [string] $Caller
		, [Parameter(Mandatory = $false)] [string] $FilePath
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING PrintUtitlityFunctions.PrintObjectAsVars[249]"
	}

	$i = 0
	#Write-Host -ForegroundColor Red "ObjectName="$ObjectName
	ForEach ($item in $Object.GetEnumerator())
	{
		If($item.value -ne $null)
		{
			$itemValue = $item.value
			$itemType = (($item.value).GetType()).Name
			#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] itemType="$itemType

			If($ObjectName.length -ne 0)
			{
				$varOut = "`$" + $ObjectName + "." + $item.name + "=`"" + $item.value + "`""
				$property = "`$" + $item.name + "=`""
				Switch($itemType)
				{
					String
					{
						$value = ($item.value) + "`""
					}
					Boolean
					{

						$value = ($item.value).ToString() + "`""
					}
					OrderedDictionary
					{
						#Write-Host -ForegroundColor Red "item.name="$item.name
						#PrintObjectAsVars -Object $item.value -ObjectName $item.name -FilePath $FilePath
						PrintObjectAsVars -Object $item.value -FilePath $FilePath
					}
					PSCustomObject
					{

						Write-Host -ForegroundColor Red "item.name="$item.name
						$itemValue.PSObject.Properties | ForEach-Object {
							Write-Host -ForegroundColor Cyan $_.Name "=" $_.Value
						}
					}
					Default
					{
						$value = ($item.value).ToString() + "`""
					}
				}#switch
				<#
				Write-Host -ForegroundColor Cyan -BackgroundColor Black -NoNewline "[$i] "
				Write-Host -ForegroundColor Cyan -BackgroundColor Black -NoNewline $property
				Write-Host -ForegroundColor White -BackgroundColor Black $value
				#>
			}
			Else
			{#>
				$varOut = "`$" + $item.name + "=`"" + $item.value + "`""
				$property = "`$" + $item.name + "=`""

				Switch($itemType)
				{
					String
					{
						$value = ($item.value) + "`""
					}
					Boolean
					{

						$value = ($item.value).ToString() + "`""
					}
					Int32
					{
						$value = ($item.value).ToString() + "`""
					}
					OrderedDictionary
					{
						#Write-Host -ForegroundColor Yellow "[1577]property="$item.name
						#PrintObjectAsVars -Object $item.value -ObjectName $item.name -FilePath $FilePath
						PrintObjectAsVars -Object $item.value -FilePath $FilePath
					}
					PSCustomObject
					{

						Write-Host -ForegroundColor Red "item.name="$item.name
						$itemValue.PSObject.Properties | ForEach-Object {
							Write-Host -ForegroundColor Cyan $_.Name "=" $_.Value
						}
					}
					Default
					{
						$value = ($item.value) + "`""
					}
				}#switch
				<#
				Write-Host -ForegroundColor Cyan -BackgroundColor Black -NoNewline "[$i] "
				Write-Host -ForegroundColor Green -BackgroundColor Black -NoNewline $property
				Write-Host -ForegroundColor White -BackgroundColor Black $value
				#>
			}

			#Write-Host -ForegroundColor White -BackgroundColor Black $varOut

			#Write-Host -ForegroundColor Cyan -BackgroundColor Black -NoNewline "[$i] "
			Write-Host -ForegroundColor Green -BackgroundColor Black -NoNewline $property
			Write-Host -ForegroundColor White -BackgroundColor Black $value
			#>
			$varOut >> $FilePath
			$i++
		}#$item.value -ne $null
	}#ForEach

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] FINISHED $Caller.PrintObjectAsVars`n "
	#For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Cyan "=" -NoNewline} Write-Host "`n"
}#PrintObjectAsVars


