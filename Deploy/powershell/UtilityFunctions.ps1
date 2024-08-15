#UtilityFunctions
Function global:AnswerYesOrNo
{
	Param(
			[Parameter(Mandatory = $true)] [String] $Question
	)
	<#
	If($debugFlag ){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.AnswerYesOrNo[10]"
	}#If($debugFlag)#> 

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t"$Question
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black "Make a selection by entering the character in the bracket, then press Enter:"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ 1 | Y ] = Yes"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ 0 | N ] = No"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ X ] = Cancel and Quit `n"

	$answer = Read-Host "Enter your answer"
	Switch ($answer)
	{
		{$_ -in "1","y", "yes"}
		{
			$answerOut = $true
		}
		{$_ -in "0","n", "no"}
		{
			$answerOut = $false
		} 
		X { "Quitting..."
			Exit(1)
		}
		Default {
			$answerOut = AnswerYesOrNo -Question $Question
		}
	}#Switch
	return $answerOut
}#AnswerYesOrNo


Function global:ConvertFrom-SecureString-AsPlainText
{
	[CmdletBinding()]
	param (
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $true
		)]
		[System.Security.SecureString]
		$SecureString
	)
	If($debugFlag){
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "STARTING UtilityFunctions.ConvertFrom-SecureString-AsPlainText[55]"
	}#If($debugFlag)#>

	$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
	$PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
	$PlainTextString;
}


Function global:PickDebugMode
{
	#
	If($debugFlag -or ($CurrUser -eq "kahopkin")){
	#If($debugFlag ){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickDebugMode[68]"
	}#If($debugFlag)#> 

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`t SELECT DEBUG TYPE:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black "Make a selection by entering the character in the bracket to choose DEBUG, then press Enter:"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ 1 | Debug] = Use this If you want to see detailed debugging outputs throughout the deployment."
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ 0 | Live] = Use this for to only show informational outputs during deployment"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ X ] = Cancel and Quit `n"

	$DebugMode = Read-Host "Enter DEBUG output choice"
	Switch ($DebugMode)
	{
		{$_ -in "1","debug"}{$debugFlag = $true}
		{$_ -in "0","live"}{$debugFlag = $false} 
		X { "Quitting..."
			Exit(1)
		}
		Default {
			$debugFlag = PickDebugMode
		}
	}#Switch
	Write-Host -ForegroundColor Green -BackgroundColor Black "You chose:" $DebugMode
	return $debugFlag
}#Pick_DebugMode


<#
Ask user If they want to use the interface or a file for deployment
#>
Function global:PickDeployMethod
{
	Param( 
			[Parameter(Mandatory = $true)] [Object] $DeployObject
	) 
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickDeployMethod[106]"
	}#If($debugFlag)#> 


	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`t SELECT DEPLOY METHOD:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black  "Make a selection by entering the character in the bracket then press Enter:"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ 1 | UI ]   = User Interface: Use this If you want to answer questions."
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ 2 | File ] = Deploy with parameter file: Use this for to run the deployment script by providing minimum parameters in a file"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[ 0 | X ]	= Cancel and Quit] = Terminate Deployment`n"

	$deployMethodHash = @{
		1 = "UserInput";
		2 = "ParamFile";
	}

	$deployMethod = Read-Host "Enter DEPLOY METHOD choice"

	Switch ($deployMethod)
	{
		{$_ -in "1","ui"}{
			If($_.length -eq 1 )
			{
				$deployMethod = [int]$deployMethod
			}
			$uiDeployFlag = $true
		}#
		{$_ -in "2","file"}
		{
			If($_.length -eq 1 )
			{
				$deployMethod = [int]$deployMethod
			}
			$uiDeployFlag = $false
		}#
		{$_ -in "0","X"}
		{ 
			"Quitting..."
			Exit(1)
		}
		Default 
		{
			$uiDeployFlag = PickDeployMethod -DeployObject $DeployObject
		}
	}#Switch
	Write-Host -ForegroundColor Green -BackgroundColor Black "You chose:" $deployMethodHash.$deployMethod
	return $uiDeployFlag
}#PickDeployMethod


Function global:PickCreateParamFile
{
	Param( 
			[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickCreateParamFile[164]"
	}#If($debugFlag)#>

	$ParamFilePath = $DeployObject.DeployParameterFile
	<#
	If($debugFlag){
		$Caller = "UtilityFunctions.PickCreateParamFile[170]"
		Write-Host -ForegroundColor Yellow -BackgroundColor Black $Caller
		Write-Host -ForegroundColor White "`$ParamFilePath=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ParamFilePath`""
	}#If($debugFlag)#> 

	If (Test-Path ($ParamFilePath))
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "`nYou already have a deploy parameter input file at:" $ParamFilePath
		Write-Host -ForegroundColor Green -BackgroundColor Black "We opened the file in your default editor.  Please review it and " -NoNewline
		Write-Host -ForegroundColor Green -BackgroundColor Black "make any changes, then save and press any key to continue"
		Invoke-Item $ParamFilePath
		Read-Host -Prompt "Press any key to continue. . ."
		$Question = "Would you like to use this file for the deployment? [ 1|Y / 0|N ]"
		$createFileFlag = AnswerYesOrNo -Question $Question

		Switch($createFileFlag)
		{
			{$_ -in "1","y", "yes", $true}
			{
				$createFileFlag = $true
				Write-Host -ForegroundColor Green -BackgroundColor Black "Continuing deployment with your existing file...."
			}
			{$_ -in "0","n", "no", $false}
			{
				$createFileFlag = CreateParamFile -DeployObject $DeployObject
			}
			Default
			{
				$createFileFlag = PickCreateParamFile -DeployObject $DeployObject
			}#Default
		}#Switch($createFileFlag) 
	}#If (Test-Path ($ParamFilePath))
	Else
	{ 
		$createFileFlag = CreateParamFile -DeployObject $DeployObject
	} 
	return $createFileFlag
}#PickCreateParamFile


Function global:CreateParamFile
{
	Param( 
			[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.CreateParamFile[215]"
	}#If($debugFlag)#>
	$Question = "Would you like me to create a new deploy parameter file for you? [ 1|Y / 0|N ]"
	$createFileFlag = AnswerYesOrNo -Question $Question

	Switch($createFileFlag)
	{
		{$_ -in "1","y", "yes", $true}
		{
			Write-Host -ForegroundColor Green -BackgroundColor Black  "You chose: YES" 			
			$createFileFlag = $true			
			WriteJsonFile -FilePath $ParamFilePath -CustomObject $ParamFileObj
			Write-Host -ForegroundColor Cyan -BackgroundColor Black "We have created the imput file template:" -NoNewline
			Write-Host -ForegroundColor Green -BackgroundColor Black $ParamFileName -NoNewline
			Write-Host -ForegroundColor Cyan -BackgroundColor Black " and opened it in your default application.`n"
			Write-Host -ForegroundColor Cyan -BackgroundColor Black "The path to the file:"
			Write-Host -ForegroundColor Green -BackgroundColor Black $ParamFilePath
			Write-Host -ForegroundColor Red -BackgroundColor Black "Please substitute the parameter values to your desired values, `nSave the file"
			Write-Host -ForegroundColor Red -BackgroundColor Black "Make sure that each parameter has a valid entry."
			Write-Host -ForegroundColor Red -BackgroundColor Black "Parameters with a `"|`" character indicates that only one value is accepted."
			Write-Host -ForegroundColor Red -BackgroundColor Black "Pick your desired value and delete the rest inlcuding the separator character."
			Invoke-Item $ParamFilePath
			Read-Host -Prompt "Press any key to continue. . ."
			
		}#YES
		{$_ -in "0","n", "no", $false}
		{
			Write-Host -ForegroundColor Cyan "[244] `$createFileFlag= `"$createFileFlag`""
			Write-Host -ForegroundColor Yellow "`$uiDeployFlag= `"$uiDeployFlag`""

			$Question = "Would you like to enter the path to an existing parameter file?"
			$Answer = AnswerYesOrNo -Question $Question

			If($Answer)
			{
				$DeployObject.DeployParameterFile = $ParamFilePath = Read-Host "Enter the full filepath to your existing input parameter file"
				Write-Host -ForegroundColor White "Your input file is: " -NoNewline
				Write-Host -ForegroundColor Cyan $ParamFilePath
				$createFileFlag = $true
			}
			Else
			{
				Write-Host -ForegroundColor Green -BackgroundColor Black "Continuing with Interactive User Input method..."
				$createFileFlag = $false
			}
		}#NO
		Default
		{
			$createFileFlag = CreateParamFile -DeployObject $DeployObject
		}#Default
	}#switch(createFileFlag) 
	return $createFileFlag
}#CreateParamFile


Function global:ParseInputFile
{
	Param(
		 [Parameter(Mandatory = $true)] [String] $FilePath
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	$Message = "PARSING DEPLOYMENT PARAMETER FILE:"
	#
	If($debugFlag){
			$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.ParseInputFile[271]"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		Write-Host -ForegroundColor White "`$FilePath=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$FilePath`""
	}#If($debugFlag)#>
	Else{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		Write-Host -ForegroundColor White "FilePath=" -NoNewline
		Write-Host -ForegroundColor Green -BackgroundColor Black "`"$FilePath`""
	}

	If (Test-Path ($FilePath))
	{
		$FullPath = (Get-ChildItem -Path ($FilePath) | select FullName).FullName
		$json = Get-Content $FullPath | Out-String | ConvertFrom-Json

		If($DeployObject.DebugFlag -eq $null){$DeployObject.DebugFlag = $json.DebugFlag;}
		$DeployObject.DeployMode = $json.DeployMode;
		$DeployObject.DeployComponents = $json.DeployComponents;
		$DeployObject.AzureResources = $json.AzureResources;

		$DeployObject.CloudEnvironment= $json.CloudEnvironment;
		$DeployObject.Location = $json.Location;
		$DeployObject.Environment = $json.Environment;
		$DeployObject.AppName = $json.AppName;
		#$DeployObject.Solution = $json.Solution;

		$DeployObject.SqlAdmin = $json.SqlAdmin;
		$SqlAdminPwd = $json.SqlAdminPwd;		
		$DeployObject.SqlAdminPwd = $SecureSqlAdminPwd
		If($SqlAdminPwd -ne $null)
		{
			$SqlAdminPwdSecure = ConvertTo-SecureString $SqlAdminPwd -AsPlainText -Force
			$DeployObject.SqlAdminPwd = $SqlAdminPwdSecure

			$SqlAdminPwdPlainText =
			$DeployObject.SqlAdminPwdAsPlainText = ConvertFrom-SecureString-AsPlainText -SecureString $SqlAdminPwdSecure
		}
		#
		If($debugFlag)
		{
			$Caller = "UtilityFunctions.ParseInputFile[310]"
			Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
			Write-Host -ForegroundColor Cyan "`$SqlAdminPwdSecure= `"$SqlAdminPwdSecure`""
			Write-Host -ForegroundColor Cyan "`$SqlAdminPwdPlainText= `"$SqlAdminPwdPlainText`""
		}#If($debugFlag)#>

		$DeployObject.BuildFlag = $json.BuildFlag;
		$DeployObject.PublishFlag = $json.PublishFlag;
		$DeployObject.OpenIdIssuer = "https://" + $json.OpenIdIssuer ;
		$DeployObject.WebDomain = $json.WebDomain;
		$DeployObject.DnsSuffix = $json.DnsSuffix;
		$DeployObject.GraphEndPoint= "https://" + $json.GraphEndPoint + "/";
		$DeployObject.GraphVersion= $json.GraphVersion;
		$DeployObject.AddressPrefix = $json.AddressPrefix;
		$DeployObject.AddressSpace = $json.AddressSpace;
	}#Test-Path ($FilePath)
	Else{
		#
		If($debugFlag){
			$Caller ="UtilityFunctions.ParseInputFile[312]::param file" + $FilePath + " does not exists, continuing deployment" 
			Write-Host -ForegroundColor Yellow -BackgroundColor Black $Caller
			$ObjectName = "DeployObject"
			#PrintCustomObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
		}#If($debugFlag)#> 
	}
	<#
	If($DeployObject.DebugFlag){
			$Caller ='UtilityFunctions.ParseInputFile[255]:: After parsing deploy param file'
		$ObjectName = "DeployObject"
		PrintCustomObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
	}#If($debugFlag)#> 
}#ParseInputFile

Function global:PickAZCloud
{ 
	Param(
		[Parameter(Mandatory = $true)] [Int32] $StepCount
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickAZCloud[348]"
	}#If($debugFlag)#>
	$Message = "CONNECT TO AZURE CLOUD..."
	$StepCount = PrintMessage -Message $Message -StepCount $StepCount
	#PrintMessageToFile -Message $Message -StepCount $StepCount -LogFile $DeployObject.LogFile

	$CloudArr= [System.Collections.ArrayList]::new()
	$CloudArr = Get-AzEnvironment
	$psCommand = "`$CloudArr = Get-AzEnvironment"
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.PickAZCloud[359]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #> 

	$CloudStringArr = [System.Collections.ArrayList]::new()
	$i = 1 
	ForEach($item in $CloudArr)
	{ 
		$item = $item.Name -csplit '(?<!^)(?=[A-Z])' -join ' '
		$item = $item.Replace("U S","US")
		Write-Host -ForegroundColor Yellow "[ $i ] : $item"
		[void]$CloudStringArr.Add($i)
		$i++
	}
	Write-Host -ForegroundColor Yellow "[ C ] : Provide Custom Environment String"
	[void]$CloudStringArr.Add("C")
	Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
	[void]$CloudStringArr.Add("X")

	$AzCloud = GetAZCloud -CloudArr $CloudArr -CloudStringArr $CloudStringArr
	Write-Host -ForegroundColor Green -BackgroundColor Black "`nYour Selection:`"$AzCloud`" Cloud`n"

	return $AzCloud
}#PickAZCloud

Function global:GetAZCloud
{
	Param(
		[Parameter(Mandatory = $true)] [object[]] $CloudArr
		,[Parameter(Mandatory = $true)] [string[]] $CloudStringArr
	)

	Write-Debug "UtilityFunctions.GetAZCloud[190]"
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetAZCloud[398]"
	}#If($debugFlag)#> 

	$cloudIndex = Read-Host "Enter Az Cloud Selection"
	$cloudIndex = $cloudIndex.ToUpper()

	If( ($cloudIndex -lt $CloudStringArr.Count) -or ($cloudIndex -eq "X") -or ($cloudIndex -eq "C") )
	{
		Switch ($cloudIndex)
		{
			X
			{
				Write-Host -ForegroundColor Red "You chose to Quit... Try again later ...."
				exit(1)
			}#X
			C
			{
				$cloud = Read-Host "Enter Custom Azure Cloud Environment String"
			}#C
			Default
			{
				$cloud = $CloudArr[$cloudIndex-1]
				#Write-Host -ForegroundColor Cyan "GetAZCloud[91] Cloud=" $cloud
			}
		}#Switch ($cloudIndex)
	}
	Else
	{
		Write-Host -ForegroundColor Red "INPUT NOT VALID, TRY AGAIN..."
		$cloud = GetAZCloud
	}
	return $cloud
}


Function global:SelectDeploymentContext
{
	Param(
		 [Parameter(Mandatory = $false)] [Object] $DeployObject
		, [Parameter(Mandatory = $true)] [Object] $AllContexts
	)
	$Message = "SELECT DEPLOYMENT CONTEXT:"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	#
	If($CurrUser -eq "kahopkin")
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING UtilityFunctions.SelectDeploymentContext[448]"
		$Caller = "UtilityFunctions.SelectDeploymentContext[2334]"
		$ObjectName = "DeployObject" 
		$contextIndex = 0
		#PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#>
	Else
	{
		#$message = "You are logged into the following subscriptions.`n" +
		#"Please enter the number for the context you want to use for this deployment:"

		#Write-Host -ForegroundColor Green -BackgroundColor Black $message
		$i = 0
		ForEach($context in $AllContexts)
		{
			$contextSubscription = $context.Subscription.Name
			Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] : $contextSubscription "
			$i++
		}#ForEach($context in $AllContexts)
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"

		$contextIndex = Read-Host "Enter Selection"
		Switch($contextIndex)
		{
			X {
				"Quitting..."
				Exit(1)
			}
				Default
			{
				$contextName = $AllContexts[$contextIndex].Name
			}
		}#switch

		Write-Host -ForegroundColor Green -BackgroundColor Black "`nYou Selected:"  $AllContexts[$contextIndex].Subscription.Name "`n"
	}#ElseIf($CurrUser -eq "kahopkin")

	$SubscriptionName = $AllContexts[$contextIndex].Subscription.Name
	$SubscriptionId = $AllContexts[$contextIndex].Subscription.Id
	$TenantId = $AllContexts[$contextIndex].Tenant.Id
	$TenantName = $AllContexts[$contextIndex].Tenant.Name

	Write-Host -ForegroundColor Green -BackgroundColor Black "Setting deployment context...."

	$context = Set-AzContext -Subscription $SubscriptionId
	$psCommand = "`$context = `Set-AzContext -Subscription `"" + $SubscriptionId + "`n"

	<#
	$context = Select-AzContext -Name $contextName
	$psCommand = "`$context = `n`tSelect-AzContext ```n`t`t" + 
						"-Name `$contextName `n"
	#>
	If($PrintPSCommands){ Write-Host -ForegroundColor Green $psCommand }
	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.SelectDeploymentContext[503]:"
		Write-Host -ForegroundColor Cyan "`$SubscriptionId= `"$SubscriptionId`""
		Write-Host -ForegroundColor White "`$contextName= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$contextName`""		
	}#If($debugFlag)#>

	$HomeTenantId = $context.Subscription.HomeTenantId
	$SubscriptionName = $context.Subscription.Name
	$SubscriptionId = $context.Subscription.Id
	$TenantId = $context.Tenant.Id
	$tenant = Get-AzTenant -TenantId $HomeTenantId
	$psCommand = "`$tenant = `n`Get-AzTenant ```n`t`t" + 
						"-TenantId `$HomeTenantId `n"
	If($PrintPSCommands){ Write-Host -ForegroundColor Green $psCommand }
	<#
	If($debugFlag){
		#Write-Host -ForegroundColor Magenta "UtilityFunctions.SelectDeploymentContext[2386]:"
		Write-Host -ForegroundColor White "`$HomeTenantId= "
		Write-Host -ForegroundColor Cyan "`"$HomeTenantId`""		
	}#If($debugFlag)#> 

	$TenantName = $tenant.Name
	$TenantId = $tenant.Id

	$DeployObject.CloudEnvironment = $context.Environment.Name
	$DeployObject.TenantName = $TenantName
	$DeployObject.TenantId = $TenantId

	$DeployObject.SubscriptionName = $SubscriptionName
	$DeployObject.SubscriptionId = $SubscriptionId

	return $context
}#SelectDeploymentContext


Function global:PickSubscription  
{
	Param(
		[Parameter(Mandatory = $false)] [Object] $CurrContext
		,[Parameter(Mandatory = $true)]  [Object] $DeployObject
		,[Parameter(Mandatory = $false)] [String] $PickSubscriptionFlag
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickSubscription[430]"
		#Write-Host -ForegroundColor Cyan "`$PickSubscriptionFlag= `"$PickSubscriptionFlag`""
		#Write-Host -ForegroundColor Cyan "`$PickSubscriptionFlag==null => " ($PickSubscriptionFlag -eq $null)
		#Write-Host -ForegroundColor Yellow "`$CurrContext==null =>" ($CurrContext -eq $null)
	}#If($debugFlag)#>


	$SubscriptionArr = @()
	$j=0
	$subscriptions = Get-AzSubscription
	ForEach($subscription in $subscriptions)
	{
		$subscriptionName = $subscription.Name
		$subscriptionId = $subscription.Id
		$tenant = Get-AzTenant -TenantId $subscription.TenantId
		$psCommand = "`$tenant = Get-AzTenant -TenantId `"" + $subscription.TenantId + "`" `n"
		#
		If($PrintPSCommands){
			Write-Host -ForegroundColor Magenta "ConnectToMSGraph.ConnectToAzure[90]:"
			Write-Host -ForegroundColor Green $psCommand
		}#If($PrintPSCommands) #>
		$Hashtable = [ordered]@{
			Tenant = $tenant.Name
			TenantId = $subscription.TenantId;
			SubscriptionName = """$subscriptionName""";
			SubscriptionId = $subscription.Id;
		}#$Hashtable
			$SubscriptionArr += $Hashtable
		#PrintSubscription -Object $Hashtable
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $j ] :" $Hashtable.SubscriptionName
		$i=0
		ForEach ($item in $Hashtable.GetEnumerator())
		{ 
			Write-Host -ForegroundColor White $item.name "= " -NoNewline
			Write-Host -ForegroundColor Green $item.value
			$i++
		}
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "-" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "-" -NoNewline}}
		$j++
	}#ForEach($subscription in $subscriptions) 

	$i=0
	ForEach ($subscription in $SubscriptionArr)
	{ 
		$subscription = $subscription.Name
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] : $subscription "
		Write-Host -ForegroundColor White $item.name "= " -NoNewline
		Write-Host -ForegroundColor Green $item.value
		$i++
	}

	$choice = Read-Host "Enter Selection" 
	Write-Host -ForegroundColor DarkBlue -BackgroundColor White "You chose:" $choice

	If($PickSubscriptionFlag -eq $null -or $PickSubscriptionFlag.length -eq 0)
	{
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
		Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`t CHOOSE SUBSCRIPTION TO LOG IN..."
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
		Write-Host -ForegroundColor White -BackgroundColor Black "If this is the context you want to proceed, press Y, then press Enter"
		Write-Host -ForegroundColor White -BackgroundColor Black "If you need to select a different context, press C, then press Enter"
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 1 | Y ] : Proceed with current subscription:" $CurrContext.SubscriptionName
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 0 | N ] : Change subscription"
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"
		$choice = Read-Host "Enter Selection" 
	}
	Else
	{
		$choice = $PickSubscriptionFlag
	}

	Switch($choice)
	{
		{$_ -in "1","y", "yes"}
		{
			#get current logged in context
			#$AzureContext = Get-AzContext
			$currContextTenantId = $AzureContext.Subscription.TenantId
			$DeployObject.CloudEnvironment = $AzureContext.Environment.Name
			$DeployObject.REACT_APP_GRAPH_ENDPOINT = $AzureContext.Environment.ExtendedProperties.MicrosoftGraphEndpointResourceId + "v1.0/me"

			$SubscriptionId = $DeployObject.SubscriptionId = $AzureContext.Subscription.Id
			$DeployObject.SubscriptionName = $AzureContext.Subscription.Name

			$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
			$DeployObject.TenantName = $SubscriptionTenant.Name
			$DeployObject.TenantId = $SubscriptionTenant.Id

			$CurrContext = Set-AzContext -Subscription $SubscriptionId
		}#yes
		{$_ -in "0","n", "no"}
		{
			ConnectToSpecSubsc -Environment $AzCloud -DeployObject $DeployObject
		}#no
		X
		{
			"Quitting..."
			Exit(1)
		}#quit
	}#Switch($choice)
}#PickSubscription


Function global:ConnectToSpecSubsc
{
	Param(
		[Parameter(Mandatory = $true)] [String]$Environment
		, [Parameter(Mandatory = $true)] [String]$TenantId
		, [Parameter(Mandatory = $true)] [String]$SubscriptionId
	)
		
	$AzConnection = Connect-AzAccount -Tenant $DeployObject.TenantId -Environment $DeployObject.Environment -SubscriptionId $DeployObject.SubscriptionId
	$AzureContext = Get-AzContext
	#Write-Host -ForegroundColor Green "Context=" $AzureContext.Environment
	$DeployObject.Environment = $AzureContext.Environment.Name
	$DeployObject.ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority
	$DeployObject.SubscriptionId = $AzureContext.Subscription.Id
	$DeployObject.SubscriptionName = $AzureContext.Subscription.Name
	$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId 
	$DeployObject.TenantName = $SubscriptionTenant.Name
	$DeployObject.TenantId = $SubscriptionTenant.Id

	#Connect-MgGraph -Environment $DeployObject.MgEnvironment -ErrorAction Stop

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green "[$today] CONNECTED to $AzureContext.Environment.Name `n"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: ConnectToMSGraph.ConnectToSpecSubsc`n"
}#ConnectToSpecSubsc

Function global:PickAzRegion
{
	$Message = "SELECT AZURE REGION:"
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickAzRegion[554]"
		#$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}
	<#Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}#>

	#Get all az regions for the cloud chosen
	$GeographyGroupArr = Get-AzLocation `
						| Select Location, DisplayName, GeographyGroup `
						| Sort-Object -Property  Location
	Switch($AzCloud)
	{
		#Commercial Cloud:
		AzureCloud
		{
			#$GeoGroup = PickGeoGroup -GeographyGroupArr $GeographyGroupArr
			#Select all the unique georgaphy groups:
			$UniqueGeoGroups = $(
			ForEach ($geoGroup in $GeographyGroupArr)
			{
				$geoGroup.GeographyGroup
			}) | Sort-Object | Get-Unique

			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT AZURE GEOGRAPHY GROUP:"
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host -ForegroundColor White -BackgroundColor Black "Press the number in the bracket to choose GEOGRAPHY GROUP, then press Enter:" 

			$i=0
			ForEach($group in $UniqueGeoGroups)
			{
				Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] : $group "
				$i++
			}
			Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"  

			$GeoGroup = Read-Host "Enter Selection"
			If($GeoGroup -match "x") {
					"Quitting..."
					Exit(1)
			}

			Write-Host -ForegroundColor Green -BackgroundColor Black "`nYour Selection: " $UniqueGeoGroups[$GeoGroup] "`n" 
			$LocationArr = $GeographyGroupArr `
						| select Location, DisplayName, GeographyGroup `
						| Where-Object -Property GeographyGroup -eq $UniqueGeoGroups[$GeoGroup] `
						| Sort-Object -Property  GeographyGroup 

			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT AZURE REGION:"
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host -BackgroundColor Black "Press the number in the bracket to choose REGION:"

			$i=0
			ForEach ($location in $LocationArr)
			{
				Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] :" $location.DisplayName
				$i++
			}
			Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"

			$LocationIndex =  Read-Host "Enter Selection"
			If($LocationIndex -le $LocationArr.Length)
			{
				$Location = $LocationArr[$LocationIndex].toLower()
			}
			Switch($locationIndex)
			{
				X {
					"Quitting..."
					Exit(1)
				}
					Default
				{
					$Location = $LocationArr[$LocationIndex].toLower()
				}
			}
			Write-Host -ForegroundColor Green -BackgroundColor Black "`nYour Selection:" $LocationArr[$LocationIndex].DisplayName "Region`n"
		}#AzureCloud
		AzureUSGovernment
		{
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT AZURE REGION:"
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host "Press the number in the bracket to choose REGION:"
			$i=0
			ForEach ($location in $GeographyGroupArr)
			{
				Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] :" $location.DisplayName
				$i++
			}
			Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"

			$Location = GetAzRegion -GeographyGroupArr $GeographyGroupArr
			Write-Host -ForegroundColor Green -BackgroundColor Black "`nYour Selection:" ($Location.DisplayName).ToUpper() "Region`n"
		}#AzureUSGovernment
		Default
		{
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT AZURE REGION:"
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			Write-Host "Press the number in the bracket to choose REGION:"
			$i=0
			ForEach ($location in $GeographyGroupArr)
			{
				Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] :" $location.DisplayName
				$i++
			}
			Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"

			#$Location = GetAzRegion
			$Location = GetAzRegion -GeographyGroupArr $GeographyGroupArr
			Write-Host -ForegroundColor Green -BackgroundColor Black "`nYour Selection:" ($Location.DisplayName).ToUpper() "Region`n"
		}#default
	}#switch
	return $Location.Location
}#PickAzRegion


Function global:GetAzRegion 
{
	Param(
		[Parameter(Mandatory = $false)] [Object] $GeographyGroupArr
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetAzRegion[575]"
		#Write-Host -ForegroundColor Cyan -BackgroundColor Black "GeographyGroupArr.Count=" $GeographyGroupArr.Count
	}#If($debugFlag)#> 

	$LocationIndex = Read-Host "Enter Selection"
 
	If($LocationIndex -lt $GeographyGroupArr.Count -or $LocationIndex -eq "X")
	{
		Switch ($LocationIndex)
		{
			X
			{
				"Quitting..."
				Exit(1)
			}
			Default
			{
				$region = $GeographyGroupArr[$LocationIndex]
			}
		}
	}
	Else
	{
		Write-Host -ForegroundColor Red "INPUT NOT VALID, TRY AGAIN..."
		#$region = GetAzRegion
		$region = GetAzRegion -GeographyGroupArr $GeographyGroupArr
	}
	return $region
}#GetAzRegion


Function global:PickGeoGroup 
{
	Param(
		 [Parameter(Mandatory = $true)] [object]$GeographyGroupArr
	)

	Write-Debug "UtilityFunctions.PickGeoGroup[468]"
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickGeoGroup"

	#Select all the unique georgaphy groups:
	$UniqueGeoGroups = $(
			foreach ($geoGroup in $GeographyGroupArr)
			{
				$geoGroup.GeographyGroup
			}) | Sort-Object | Get-Unique

	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE GEOGRAPHY GROUP:"
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor White "Press the number in the bracket to choose GEOGRAPHY GROUP, then press Enter:" 

	$i=0
	#list options in UniqueGeoGroups:
	foreach($group in $UniqueGeoGroups)
	{
			Write-Host -ForegroundColor Yellow "[ $i ] : $group "
		$i++
	}
	Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"

	$LocationArr = GetGeoGroup -GeographyGroupArr $GeographyGroupArr -UniqueGeoGroups $UniqueGeoGroups
	<#
		$i=0
		foreach ($location in $GeographyGroupArr)
		{
		 Write-Host -ForegroundColor Yellow "GeographyGroupArr[$i] :" $location.Location
		 $i++
		}
	#>
	#PickLocation -LocationArr $LocationArr
	$Location = Get_Region -LocationArr $LocationArr
	#Write-Host "UtilityFunctions.PickGeoGroup[863] Location:" $Location

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.PickGeoGroup`n"
	return $LocationIndex
}#PickGeoGroup


Function global:GetGeoGroup
{
	Param(
		 [Parameter(Mandatory = $true)] [object]$GeographyGroupArr,
		 [Parameter(Mandatory = $true)] [object]$UniqueGeoGroups
	)

	Write-Debug "UtilityFunctions.GetGeoGroup[518]"
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.GetGeoGroup"

	$GeoGroup = Read-Host "Enter Selection for GEOGRAPHY GROUP"
	#Write-Host "UtilityFunctions.GetGeoGroup[881] you selected: " $GeographyGroupArr[$GeoGroup].DisplayName
	Switch ($GeoGroup)
	{
		X { 
			"Quitting..."
			exit(1)
		}

		Default 
		{
			$LocationArr = $GeographyGroupArr `
						| select Location, DisplayName, GeographyGroup `
						| Where-Object -Property GeographyGroup -eq $UniqueGeoGroups[$GeoGroup] `
						| Sort-Object -Property  GeographyGroup

		}
	}
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.GetGeoGroup`n"
	return $LocationArr
}#GetGeoGroup


Function global:PickLocation
{
	Param(
		[Parameter(Mandatory = $false)] [object]$LocationArr
	)

	Write-Debug "UtilityFunctions.PickLocation[549]"

	$i = 0
	foreach ($location in $LocationArr)
	{
		Write-Host -ForegroundColor Yellow "[ $i ] :" $location.DisplayName
		$i++
	}
	Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"

	$LocationIndex =  Read-Host "Enter Selection"
	Switch($locationIndex)	
	{
		X 
		{
			"Quitting..."
			exit(1)
		}
		Default
		{
			$Location = $LocationArr[$LocationIndex].Location
		}
	}

	#Write-Host -ForegroundColor White "UtilityFunctions.PickAzRegion[926] Location:" $Location
}#PickLocation


Function global:PickCodeEnvironment
{
	<#
	Param(
			[Parameter(Mandatory = $false)] [Object] $DeployObject
	)
	#>
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickCodeEnvironment[1081]"
	}#If($debugFlag)#>

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT ENVIRONMENT:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "Enter value (case insensitive) to choose ENVIRONMENT, then press Enter:"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 0 | TEST ]"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 1 | DEV  ]"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 2 | PROD ]"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"

	$Environment = GetCodeEnvironment
	Write-Host -ForegroundColor Green -BackgroundColor Black "`nYour Selection:" $Environment "Environment`n"
	return $Environment
}#PickCodeEnvironment


Function global:GetCodeEnvironment
{
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetCodeEnvironment[848]"
	}#If($debugFlag)#>

	$environment = Read-Host "Enter Selection for CODE ENVIRONMENT"
	Switch ($environment)
	{

		{$_ -in "0","test"}{$environment="Test"}
		{$_ -in "1","dev"} {$environment="Dev"}
		{$_ -in "2","prod"}{$environment="Prod"}
		X { "Quitting..."
				exit(1)
		}
		Default {
			$environment = GetCodeEnvironment
		}
	}	
	$environment = (Get-Culture).TextInfo.ToTitleCase($environment)
	return $environment
}#GetCodeEnvironment


Function global:Pick_Solution
{

	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT SOLUTION TYPE:"
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor White "Press the letter in the bracket to choose ENVIRONMENT, then press Enter:" 
	Write-Host -ForegroundColor Yellow "[ 1 ] : Transfer"
	Write-Host -ForegroundColor Yellow "[ 2 ] : Pickup"
	Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
	$DeployObject.Solution = Get_Solution
}#Pick_Solution


Function global:Get_Solution
{
	Write-Debug "UtilityFunctions.Get_Solution[690]"
	$Solution = Read-Host "Enter Transfer OR PickUp"
	Switch ($Solution)
	{
			1{$Solution="Transfer"}
		2{$Solution="Pickup"} 
			X { "Quitting..."
			exit(1)
		}
		Default {
			$Solution = Get_Solution
		}
	}#Switch
	return $Solution
}#Get_Solution



Function global:GetAppName
{
	Param(
		[Parameter(Mandatory = $false)] [Object] $DeployObject
	)

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetAppName[764]"
	}#If($debugFlag)#>

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`t`t`t`NAME THE APP (WEBSITE PREFIX):"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter a BASE name for your solution."
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "For example, If your desired website name is:"
	Write-Host -ForegroundColor Green -BackgroundColor Black "datatransfer.azurewebsites.us "
	Write-Host -ForegroundColor Green -BackgroundColor Black "and datapickup.azurewebsites.us:"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter: " -NoNewline
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "data"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "The program will create the website and function app with names:"
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "datatransfer.azurewebsites.us" -NoNewline
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black " and "
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "datapickup.azurewebsites.us"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "respectively`n"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "The name should be short [3-10 chars] and will serve as the prefix for the website and"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "is one of the main building blocks for the resource names that will be created on Azure"

	$AppName = Read-Host "Enter AppName"
	$AppName = (Get-Culture).TextInfo.ToTitleCase($AppName)
	$DeployObject.AppName = $AppName

	return $AppName
}#GetAppName


Function global:AssembleAppName
{
	Param(
		[Parameter(Mandatory = $false)] [Object] $DeployObject
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.AssembleAppName[1157]"
		Write-Host -ForegroundColor Cyan "`$DeployObject.AppName= " $DeployObject.AppName
	}#If($debugFlag)#>

	$Message = "ASSEMBLING FINAL SOLUTION NAME:"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

	If($DeployObject.AppName.Length -eq 0)
	{
		$DeployObject.AppName = GetAppName -DeployObject $DeployObject
	}

	If( $DeployObject.Environment.ToLower() -ieq 'prod')
	{
		#$AppName = $DeployObject.AppName + $DeployObject.Environment
		$AzResourcesComplexObj.WebSite.ResourceName = (Get-Culture).TextInfo.ToTitleCase($AppName)

		$DeployObject.APIAppRegName =
		$DeployObject.FunctionAppName =
		$AzResourcesComplexObj.FunctionApp.ResourceName = $DeployObject.AppName + 'API'
		$DeployObject.ClientAppRegName =
		$DeployObject.WebSiteName =
		$AzResourcesComplexObj.WebSite.ResourceName = $DeployObject.AppName  

	}#Else If Environment != prod
	Else{
		$AzResourcesComplexObj.WebSite.ResourceName = (Get-Culture).TextInfo.ToTitleCase($DeployObject.AppName)

		$DeployObject.APIAppRegName =
		$DeployObject.FunctionAppName =
		$AzResourcesComplexObj.FunctionApp.ResourceName = $DeployObject.AppName + 'API'
		$DeployObject.ClientAppRegName =
		$DeployObject.WebSiteName =
		$AzResourcesComplexObj.WebSite.ResourceName = $DeployObject.AppName
	}

	#Write-Host -ForegroundColor Magenta -BackgroundColor White "UtilityFunctions.AssembleAppName[1125]"

	#Write-Host -ForegroundColor Cyan "`$APIAppRegName=" $DeployObject.APIAppRegName
	#Write-Host -ForegroundColor Cyan "`$ClientAppRegName=" $DeployObject.ClientAppRegName
}#AssembleAppName


Function global:GetSqlPassword
{
	Param(
		[Parameter(Mandatory = $false)] [Object] $DeployObject
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetSqlPassword[1193]"
	}#If($debugFlag)#>
	$Message = "GETTING SQL SERVER ADMINISTRATOR PASSWORD:"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount

	If($DeployObject.SqlAdminPwd.Length -eq 0)
	{
		$SqlAdminPwdSecure =
		$DeployObject.SqlAdminPwd = Read-Host "Enter SQL Server Admin Password" -AsSecureString
		#[regex]::escape('1qaz2wsx#EDC$RFV')


		$SqlAdminPwdPlainText = ConvertFrom-SecureString-AsPlainText -SecureString $SqlAdminPwdSecure

		$SqlAdminPwdPlainText =
		$DeployObject.SqlAdminPwdAsPlainText = [regex]::escape($SqlAdminPwdPlainText)

		#
		If($debugFlag)
		{
			$Caller = "UtilityFunctions.GetSqlPassword[1219]"
			Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
			Write-Host -ForegroundColor Cyan "`$SqlAdminPwdSecure= `"$SqlAdminPwdSecure`""
			Write-Host -ForegroundColor Cyan "`$SqlAdminPwdPlainText= `"$SqlAdminPwdPlainText`""
		}#If($debugFlag)#>
	}#If($DeployObject.SqlAdminPwd.Length -eq 0)
}#GetSqlPassword

Function global:GetDeployParameterValues
{
	Param(
		[Parameter(Mandatory = $false)] [Object] $DeployObject
	)

	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.GetDeployParameterValues[2063]"
	}#If($debugFlag)#>

	$Message = "SUPPLY ADDITIONAL DEPLOYMENT SPECIFIC PARAMETERS:"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	
	If($DeployObject.Location.Length -eq 0){
		$DeployObject.Location = PickAzRegion
	}

	If($DeployObject.Environment.Length -eq 0)
	{
		$DeployObject.Environment = PickCodeEnvironment
	}

	$DeployObject.Environment = (Get-Culture).TextInfo.ToTitleCase($DeployObject.Environment)

	AssembleAppName -DeployObject $DeployObject

	SetOutputFileNames -StepCount $DeployObject.StepCount -DeployObject $DeployObject
	
	If($DeployObject.DeployMode -eq $null)
	{
		$DeployObject.DeployMode = PickDeployMode 
	}

	Switch($DeployObject.DeployMode)
	{
		Default
		{
			$DeployObject.DeployMode = PickDeployMode			
		}#Default#>
		"Partial"
		{
			$ComponentsChosen = $DeployObject.DeployComponents

			If($ComponentsChosen -eq $null)
			{
				$ComponentsChosen = $DeployObject.DeployComponents = PickComponents
			}#If($DeployObject.DeployComponents -eq $null) 
			
			$ObjectName = "DeployConfigObj"
			$DeployConfigObj =
			$DeployObject.DeployComponents =
											SetConfigObj `
												-ComponentsChosen $ComponentsChosen `
												-ConfigObject $DeployConfigObj `
												-ObjectName $ObjectName

			$ObjectName = "AzResourcesComplexObj" 
			If($DeployObject.AzureResources -eq $null -and $DeployConfigObj.AzureInfrastructure)
			{
				$AzureResourcesNull = ($DeployObject.AzureResources -eq $null)
				#Write-Host -ForegroundColor Magenta -BackgroundColor White "`nInitiateDeploymentProcess[257] BEFORE SelectAzResourceToDeploy"

				$ComponentsChosen =
				$AzureResources =
				$DeployObject.AzureResources = SelectAzResourceToDeploy -AzResourcesComplexObj $AzResourcesComplexObj
			}#If($DeployObject.AzureResources -eq $null)
			Else
			{
				$ComponentsChosen = $AzureResources = $DeployObject.AzureResources
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
		}#Partial
		"Full"
		{
			#$DeployConfigObj.DeployMode = "Full"
			For ($i = 0; $i -lt $DeployConfigObj.Count; $i++)
			{
				$DeployConfigObj[$i] = $true
			}
			ForEach ($item in $AzResourcesComplexObj.Keys)
			{
				 $AzResourcesObj[$item] = $true;
			}#foreach
			$DeployObject.DeployComponents = $DeployConfigObj
			$DeployObject.AzureResources = $AzureResourcesObj = $ComponentsChosen =  $AzResourcesObj
		}#Full
	}#Switch($DeployObject.DeployMode)

	If($DeployObject.SqlAdmin.Length -eq 0)
	{
		$DeployObject.SqlAdmin = Read-Host "Enter SQL Server Admin Login"
	}

	GetSqlPassword -DeployObject $DeployObject

	If($DeployObject.AddressPrefix -eq $null)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter the first 3 digits for the IP address scheme in this format: 10.10.0"
		$DeployObject.AddressPrefix = Read-Host "-- OR -- press ENTER to accept default: 10.10.0"
				
		If($DeployObject.AddressPrefix.Length -eq 0)
		{
			$DeployObject.AddressPrefix = "10.10.0"
			Write-Host "AddressPrefix = " $DeployObject.AddressPrefix
		}		
	}

	If($DeployObject.AddressSpace -eq $null)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "The address space is the number behind the slash in networking IP address space, f.e. 22 `n-- OR -- press ENTER to accept default: 22"
		$DeployObject.AddressSpace = Read-Host "Enter the Address Space: "
		If($DeployObject.AddressSpace.Length -eq 0)
		{
			$DeployObject.AddressSpace = "22"			
		}
	}

	If($DeployObject.WebDomain -eq $null)
	{
		Write-Host -ForegroundColor Red -BackgroundColor Black "PLEASE DO NOT ENTER PROTOCOL, OR ANYTHING EXTRA"
		$DeployObject.WebDomain = Read-Host "Enter the WebDomain host in the form: azurewebsites.us`n -- OR -- press ENTER to accept default: azurewebsites.us"
		If($DeployObject.WebDomain.Length -eq 0)
		{
			$DeployObject.WebDomain = "azurewebsites.us"			
		}
	}

	If($DeployObject.DnsSuffix -eq $null)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter the DNS Suffix in the format:usgovcloudapi.net"
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "This is where most endpoints are hosted on"
		Write-Host -ForegroundColor Red -BackgroundColor Black "PLEASE DO NOT ENTER PROTOCOL, OR ANYTHING EXTRA"
		$DeployObject.DnsSuffix = Read-Host "Enter the DNS Suffix in the form: usgovcloudapi.net`n -- OR -- press ENTER to accept default: usgovcloudapi.net"
		If($DeployObject.DnsSuffix.Length -eq 0)
		{
			$DeployObject.DnsSuffix = "usgovcloudapi.net"			
		}
	}

	If($DeployObject.OpenIdIssuer -eq $null)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter the OpenIdIssuer url, in the format:sts.windows.net"
		Write-Host -ForegroundColor Red -BackgroundColor Black "PLEASE DO NOT ENTER PROTOCOL, OR ANYTHING EXTRA"
		$DeployObject.OpenIdIssuer = Read-Host "Enter the OpenId Issuer address prefix in the form: sts.windows.net`n -- OR -- press ENTER to accept default: sts.windows.net"
		If($DeployObject.OpenIdIssuer.Length -eq 0)
		{
			$DeployObject.OpenIdIssuer = "sts.windows.net0"			
		}
	}

	If($DeployObject.GraphEndPoint -eq $null)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter Graph endpoint url, in the format:graph.microsoft.us"
		Write-Host -ForegroundColor Red -BackgroundColor Black "PLEASE DO NOT ENTER PROTOCOL, OR ANYTHING EXTRA"
		$DeployObject.GraphEndPoint = Read-Host "Enter the Graph endpoint url in the form: graph.microsoft.us`n -- OR -- press ENTER to accept default: graph.microsoft.us"
		If($DeployObject.GraphEndPoint.Length -eq 0)
		{
			$DeployObject.GraphEndPoint = "graph.microsoft.us"			
		}
	}

	If($DeployObject.GraphVersion -eq $null)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter Graph version info, in the format: 1.0"
		$DeployObject.GraphVersion = Read-Host "Enter the Graph version in the form: 1.0`n -- OR -- press ENTER to accept default: 1.0"
		If($DeployObject.GraphVersion.Length -eq 0)
		{
			$DeployObject.GraphVersion = "1.0"			
		}
	}  

	
	<#
	If($debugFlag){
		$Caller = "UtilityFunctions.GetDeployParameterValues[1295] AFTER PickDeployMode"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
		Write-Host -ForegroundColor Cyan "`$DeployObject.DeployMode= "$DeployObject.DeployMode
		$ObjectName = "DeployObject"
		$Caller = "UtilityFunctions.GetDeployParameterValues[1299] " + $ObjectName + "BEFORE SetConfigObj"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
		PrintCustomObjectAsObject -Object $DeployObject -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#>	
}#GetDeployParameterValues


Function global:PickDeployMode
{
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickDeployMode[853]"
	}#If($debugFlag)#> 

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT DEPLOY MODE:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black "Make a selection by entering your choice in the bracket (case insensitive) to choose DEPLOY MODE, then press Enter:"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[1|Full] = Use this If you want to do a full deployment, including:"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "`t* Create and configure app registrations"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "`t* Deploy Azure resources (Resource group with all resources needed)"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "`t* Configure Resource Group Access Control"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "`t* Create the .env files for deployment"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "`t* Add Custom Roles defined in role definiton json file [Deploy folder]"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "`t* Build necessary zip archives needed to publish to Azure"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "`t* Publish website and function app"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[2|Partial] = Use this for to only show informational outputs during deployment"
	Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "[Cancel and Quit] = Terminate Deployment`n" 

	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 1 | Full ] : Full"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 2 | Partial] : Partial"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"

	$DeployModeChoice = Read-Host "Enter Deploy Mode"
	Switch ($DeployModeChoice)
	{
		{$_ -in "1","full"}
		{
			$DeployMode = "Full"
			Write-Host -ForegroundColor Green -BackgroundColor Black "`nYou selected: FULL Deployment" 
		}
		{$_ -in "2","partial"}
		{
			$DeployMode = "Partial"
			Write-Host -ForegroundColor Green -BackgroundColor Black "`nYou selected: PARTIAL Deployment" 
		}
		X {
			"Quitting..."
			Exit(1)
		}
		Default 
		{
			$DeployMode = PickDeployMode
		}
	}#Switch
	return $DeployMode
}#PickDeploymentMode

Function global:PickComponents
{
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.PickComponents[924]"
	}#If($debugFlag)#> 

	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT COMPONENTS TO DEPLOY:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black "Provide your selections using a comma delimited list using the properties below:" 
	Write-Host -ForegroundColor Green -BackgroundColor Black "You may enter your choices using the numbers of the words separated by commas"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 1 | AppRegistration ]	 : Create and configure App Registrations"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 2 | AzureInfrastructure]  : Specify main components: Website, Function App, Key Vault, Storage Accounts, SQL Server"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 3 | EnvFile]			: Create .env files"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 4 | BuildArchives]		: Build app publish package archives"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 5 | PublishApps]		: Publish apps into current subscription"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ 6 | RoleAssignments]	  : Assign Resource Group Access Control Roles"
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] Cancel and Quit"

	$ComponentsChosen = Read-Host "Enter Components to deploy separated with comma"
	return $ComponentsChosen
}#PickComponents


Function global:SelectAzResourceToDeploy
{
	Param(
		[Parameter(Mandatory = $false)] [Object]$AzResourcesComplexObj
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.SelectAzResourceToDeploy[1032]"
	}#If($debugFlag)#>
	
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "`t`tSELECT AZURE RESOURCES TO DEPLOY:"
	For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" }Else{Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
	Write-Host -ForegroundColor Green -BackgroundColor Black "Provide your selections using a comma delimited list using the properties below:" 
	Write-Host -ForegroundColor Green -BackgroundColor Black "You may enter your choices using the numbers of the words separated by commas"

	$i = 1
	ForEach ($item in $AzResourcesComplexObj.Keys)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ $i ] :" $AzResourcesComplexObj.$item.Name ":" $AzResourcesComplexObj.$item.Description
		$i++
	}
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "[ X ] : Cancel and Quit"
	

	$ComponentsChosen = Read-Host "Enter Components to deploy separated with comma" 
	Switch ($ComponentsChosen)
	{ 
		X
		{
			"Quitting..."
			Exit(1)
		}
		Default 
		{
			return $ComponentsChosen
		}
	}#Switch
}#SelectAzResourceToDeploy


Function global:SetConfigObj
{
	Param(
	 [Parameter(Mandatory = $true)]  [String[]] $ComponentsChosen
	,[Parameter(Mandatory = $true)]  [Object] $ConfigObject
	,[Parameter(Mandatory = $false)] [String] $ObjectName
	)
	#
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.SetConfigObj[1311]"
		<#
		Write-Host -ForegroundColor White "`$ObjectName= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ObjectName`""
		Write-Host -ForegroundColor White "`$ComponentsChosen= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ComponentsChosen"`"
		Write-Host -ForegroundColor Cyan "ComponentsChosen.Count=" $ComponentsChosen.Count
		Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "ComponentsChosen.GetType()=" $ComponentsChosen.GetType()
		Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "ComponentsChosen.GetType().Name=" $ComponentsChosen.GetType().Name
		Write-Host -ForegroundColor Magenta -BackgroundColor DarkBlue "[1319]ComponentsChosen.GetType().BaseType=" $ComponentsChosen.GetType().BaseType
		$Caller = "UtilityFunctions.SetConfigObj[1320] with " + $ObjectName
		PrintCustomObjectAsObject -Object $ConfigObject -Caller $Caller -ObjectName $ObjectName
		#>
	}#If($debugFlag)#> 

	$ComponentHash = CreateComponentHash -ConfigObject $ConfigObject `
										-ObjectName $ObjectName

	Write-Host -ForegroundColor Green -BackgroundColor Black "`nYou selected the following resources:"

	$i = 1
	$DeployComponents = @()
	If($ComponentsChosen -ne $null)
	{
		$afterReplaceNormalized = $DeployComponents = $ComponentsChosen -replace '\s+', ''
		If($afterReplaceNormalized -match ',')
		{
			$DeployComponents = $afterReplaceNormalized.Split(',')
		}#if match comma

		Foreach($item in $DeployComponents)
		{
			If($item.length -eq 1) {$item = [int]$item}

			 $itemType = ($item.GetType()).Name
			 #Write-Host -ForegroundColor White "`$itemType=`"$itemType`""
	
			 Switch($itemType)
			 {
				String
				{ 
					Foreach($value in $ComponentHash.Values.GetEnumerator())
					{
						If($item -eq $value)
						{
							$ConfigObject.$value = $true 
							Write-Host -ForegroundColor Green -BackgroundColor Black "`t" $value
						}
					}#Foreach($key in $ComponentHash.Keys)
				}
				Int32
				{
					Foreach($key in $ComponentHash.Keys)
					{
						If($item -eq $key)
						{
							$value = $ComponentHash.$key 
							$ConfigObject.$value = $true
							Write-Host -ForegroundColor Green -BackgroundColor Black "`t" $value
						}
						#>
					}#Foreach($key in $ComponentHash.Keys)
				}
				<#Default{
					$ConfigObject.DeployMode = "Full"
				}#Default#>
			 }#Switch($itemType) 
			$i++
		}#ForEach(DeployComponents)
	}#If ComponentsChosen ne null

	Write-Host -ForegroundColor Green -BackgroundColor Black "to deploy. `n"

	return $ConfigObject
}#SetConfigObj


Function global:CreateComponentHash
{
	Param(
		[Parameter(Mandatory = $true)]  [object] $ConfigObject
		,[Parameter(Mandatory = $false)] [string] $ObjectName
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Caller = "`n[" + $today + "] STARTING UtilityFunctions.CreateComponentHash[1157]"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
		Write-Host -ForegroundColor White "`$ObjectName= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ObjectName`""
			#PrintCustomObjectAsObject -Object $ConfigObject -Caller $Caller -ObjectName $ObjectName
	}#If($debugFlag)#> 

	$ComponentHash = [ordered]@{}
	$i = $j = 1
	Foreach($item in $ConfigObject)
	{
		ForEach ($dictionaryItem in $item.GetEnumerator())
		{
			$dictionaryKey = $dictionaryItem.name
			#Write-Host -ForegroundColor Yellow "[$i]="$dictionaryKey
			$ComponentHash.Add($i, $dictionaryKey)
			$i++
		}#ForEach ($dictionaryItem in $item.GetEnumerator())
	}#Foreach($item in $ConfigObject)
	return $ComponentHash
}#CreateComponentHash


Function global:GetPreviousDeployment
{
	Param(
		[Parameter(Mandatory = $false)] [Object] $DeployObject
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Caller = "`n[" + $today + "] STARTING UtilityFunctions.GetPreviousDeployment[2119]"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
	}#If($debugFlag)#>
	$Message = "GET THE LAST DEPLOYMENT FROM AZURE:"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	#Check Azure If deployment with name exists, and If yes, parse DeploymentOutput:
	#$DeploymentName = $DeployObject.TransferAppObj.DeploymentName
	$DeploymentName = $DeployObject.DeploymentName

	$PrevDeployment = Get-AzDeployment -Name $DeploymentName -ErrorAction SilentlyContinue
	$psCommand = "`$PrevDeployment = `n`tGet-AzDeployment  ```n`t`t" +
										"-Name `"" + $DeploymentName + "`"```n`t`t" +
										"-ErrorAction SilentlyContinue"

	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.GetPreviousDeployment[2136]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>

	If($PrevDeployment -ne $null)
	{
		$PrevDepOutput = $PrevDeployment.Outputs
		$ProvisioningState = $PrevDeployment.ProvisioningState
		#
		If($debugFlag){
		 Write-Host -ForegroundColor Magenta "`UtilityFunctions.GetPreviousDeployment[2146]::"
		 Write-Host -ForegroundColor Green "`$DeploymentName=`"$DeploymentName`""
		 Write-Host -ForegroundColor Cyan "`$ProvisioningState=`"$ProvisioningState`""
		 #$PrevDeployment
		 $ObjectName = "PrevDepOutput"
		 $Caller = "UtilityFunctions.GetPreviousDeployment[2151] after PrevDeployment::" + $ObjectName
		 #PrintCustomObjectAsObject -ObjectName $ObjectName -Object $PrevDepOutput -Caller $Caller
		 #PrintDeploymentOutput -ObjectName $ObjectName -Object $PrevDepOutput -Caller $Caller
		 $ObjectName = "DeployObject"
		 $Caller = "UtilityFunctions.GetPreviousDeployment[2155] after Get-AzDeployment::" + $ObjectName
		 #PrintCustomObjectAsObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller 
		}#If($debugFlag)#>
	
		#IF successful deployment, parse the outputs and fill in any blanks in the DeployObject
		If(-not( $ProvisioningState -in "Running","Failed"))
		{
			ParseDeploymentOutput -DeployObject $DeployObject -DeploymentOutput $PrevDeployment
		}#If(-not( $ProvisioningState -in "Running","Failed"))
		Else
		{
			 $message = "Previous deployment has a " + $ProvisioningState + " state...."
			 Write-Host -ForegroundColor Red -BackgroundColor White $message
			 $PrevDepOutput
		}
	}#If($PrevDeployment -ne $null)
}#GetPreviousDeployment


Function global:ParseDeploymentOutput
{
	Param(
			[Parameter(Mandatory = $true)] [Object] $DeployObject
		,[Parameter(Mandatory = $true)] [Object] $DeploymentOutput
	)

	$Message = "Step " + $DeployObject.StepCount + ": " + "PARSING THE DEPLOYMENT OUTPUTS"

	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Caller = "`n[$today] STARTING UtilityFunctions.ParseDeploymentOutput[1193]"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
	}#If($debugFlag)#>

	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile 

	<#
	If($debugFlag){
		$ObjectName = "DeploymentOutput"
		$Caller = "`n UtilityFunctions.ParseDeploymentOutput[1202] ::" + $ObjectName
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
		PrintCustomObjectAsObject -ObjectName $ObjectName -Object $DeploymentOutput.Outputs -Caller $Caller
		$ObjectName = "DeployObject"
		$Caller = "`n UtilityFunctions.ParseDeploymentOutput[1205] ::" + $ObjectName
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White $Caller
		PrintCustomObjectAsObject -ObjectName $ObjectName -Object $DeploymentOutput.Outputs -Caller $Caller
	}#If($debugFlag)#> 

	If($DeployObject.ManagedUserName -eq $null -and $DeploymentOutput.Outputs.managedUserName.Value -ne $null)
	{
		$DeployObject.ManagedUserName = $DeploymentOutput.Outputs.managedUserName.Value
	}

	If($DeployObject.ManagedUserPrincipalId -eq $null -and $DeploymentOutput.Outputs.managedUserPrincipalId.Value -ne $null)
	{
		$DeployObject.ManagedUserPrincipalId = $DeploymentOutput.Outputs.managedUserPrincipalId.Value
	}

	If($DeployObject.ManagedUserResourceId -eq $null -and $DeploymentOutput.Outputs.ManagedUserResourceId.Value -ne $null)
	{
		$DeployObject.ManagedUserResourceId = $DeploymentOutput.Outputs.ManagedUserResourceId.Value
	}

	If($DeployObject.KeyVaultName -eq $null -and $DeploymentOutput.Outputs.keyVaultName.Value -ne $null)
	{
		$DeployObject.KeyVaultName = $DeploymentOutput.Outputs.keyVaultName.Value
		$DeployObject.KeyVaultExists = $true
	}

	If($DeployObject.KeyVaultResourceId -eq $null -and $DeploymentOutput.Outputs.keyVaultResourceId.Value -ne $null)
	{
		$DeployObject.KeyVaultResourceId = $DeploymentOutput.Outputs.keyVaultResourceId.Value
	}

	If($DeployObject.KeyVaultUri -eq $null -and $DeploymentOutput.Outputs.keyVaultURI.Value -ne $null)
	{
		$DeployObject.KeyVaultUri = $DeploymentOutput.Outputs.keyVaultURI.Value
	}

	If($DeployObject.AuditStorageName -eq $null -and $DeploymentOutput.Outputs.auditStorageName.Value -ne $null)
	{
		$DeployObject.AuditStorageName = $DeploymentOutput.Outputs.auditStorageName.Value
		$DeployObject.AuditStorageExists = $true
	}

	If($DeploymentOutput.Outputs.auditStorageKeyName.Value -ne $null)
	{
		$DeployObject.AuditStorageKeyName = $DeploymentOutput.Outputs.auditStorageKeyName.Value
	}

	If($DeployObject.AuditStorageSystemPrincipalId -eq $null -and $DeploymentOutput.Outputs.auditStorageSystemPrincipalId.Value -ne $null)
	{
		$DeployObject.AuditStorageSystemPrincipalId = $DeploymentOutput.Outputs.auditStorageSystemPrincipalId.Value
	}

	If($DeployObject.MainStorageName -eq $null -and $DeploymentOutput.Outputs.mainStorageName.Value -ne $null)
	{
		$DeployObject.MainStorageName = $DeploymentOutput.Outputs.mainStorageName.Value
		$DeployObject.MainStorageExists = $true
	}
	If($DeploymentOutput.Outputs.mainStorageSystemPrincipalId.Value -ne $null)
	{
		$DeployObject.MainStorageSystemPrincipalId = $DeploymentOutput.Outputs.mainStorageSystemPrincipalId.Value
	}

	If($DeployObject.MainStorageKeyName -eq $null -and $DeploymentOutput.Outputs.mainStorageKeyName.Value -ne $null)
	{
		$DeployObject.MainStorageKeyName = $DeploymentOutput.Outputs.mainStorageKeyName.Value
	}

	If($DeployObject.SqlKeyName -eq $null -and $DeploymentOutput.Outputs.cmkSqlKeyName.Value -ne $null )
	{
		#$DeployObject.TransferAppObj.SqlKeyName =
		$DeployObject.SqlKeyName = 
			$DeploymentOutput.Outputs.cmkSqlKeyName.Value
	}
	If($DeploymentOutput.Outputs.sqlSystemPrincipalId.Value -ne $null )
	{
		#$DeployObject.TransferAppObj.SqlSystemPrincipalId =
		$DeployObject.SqlSystemPrincipalId = 
			$DeploymentOutput.Outputs.sqlSystemPrincipalId.Value
	}
	If($DeploymentOutput.Outputs.sqlServerName.Value -ne $null)
	{
		#$DeployObject.TransferAppObj.SqlServerName =
		$DeployObject.SqlServerName = 
			$DeploymentOutput.Outputs.sqlServerName.Value
		$DeployObject.SqlExists = $true 
	} 
	If(
		$DeployObject.REACT_APP_DTS_AZ_STORAGE_URL -eq $null -and
		$DeploymentOutput.Outputs.mainStorageBlobEndpoint -ne $null)
	{
		#$DeployObject.TransferAppObj.REACT_APP_DTS_AZ_STORAGE_URL =
		$DeployObject.REACT_APP_DTS_AZ_STORAGE_URL = 
			$DeploymentOutput.Outputs.mainStorageBlobEndpoint.Value
	}
	$functionAppDefaultHostName = $DeploymentOutput.Outputs.functionAppDefaultHostName.Value
}#ParseDeploymentOutput


Function global:ConfigureStorageEncryption
{
	Param(
			[Parameter(Mandatory = $true)] [Object] $DeployObject
			,[Parameter(Mandatory = $true)] [String] $StorageAccount 
	)
 
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.ConfigureStorageEncryption[1313]"
	}#If($debugFlag)#> 

	$ResourceGroupName = $DeployObject.ResourceGroupName
	$AzRoleName = "Key Vault Crypto Service Encryption User"
	$Scope = $DeployObject.KeyVaultResourceId
	$KeyVaultUri = $DeployObject.KeyVaultUri
	$KeyVaultName = $DeployObject.KeyVaultName

	#
	If($debugFlag)
	{
		$Solution = $DeployObject.Solution
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n UtilityFunctions.ConfigureStorageEncryption[1326]"
		Write-Host -ForegroundColor Green "`$Solution=`"$Solution`""
		Write-Host -ForegroundColor Cyan "`$StorageAccount=`"$StorageAccount`""
		Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
		Write-Host -ForegroundColor Cyan "`$ResourceGroupName=`"$ResourceGroupName`""
		Write-Host -ForegroundColor White "`$Scope=`"$Scope`""
		Write-Host -ForegroundColor Green "`$KeyVaultName=`"$KeyVaultName`""
		Write-Host -ForegroundColor Yellow "`$KeyVaultUri=`"$KeyVaultUri`""
		#Write-Host -ForegroundColor Yellow "`$KeyName=`"$KeyName`""
	}#debugFlag #>


	If($StorageAccount -match 'audit')
	{
		$SystemPrincipalName = $DeployObject.AuditStorageName
		$KeyName = $DeployObject.AuditStorageKeyName
		#
		If($debugFlag){
		 Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1344]:"
		 Write-Host -ForegroundColor Cyan "AUDIT"
		 Write-Host -ForegroundColor White "`$SystemPrincipalName=`"$SystemPrincipalName`""
		 Write-Host -ForegroundColor Cyan "`$KeyName=`"$KeyName`""
		}#If($debugFlag)#>
	}
	Else
	{
		$SystemPrincipalName = $DeployObject.MainStorageName
		$KeyName = $DeployObject.MainStorageKeyName
		#
		If($debugFlag){
		 Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1356]:"
		 Write-Host -ForegroundColor Green "MAIN"
		 Write-Host -ForegroundColor Green "`$SystemPrincipalName=`"$SystemPrincipalName`""
		 Write-Host -ForegroundColor Green "`$KeyName=`"$KeyName`""
		}#If($debugFlag)#>
	} 

	$stAccount = Set-AzStorageAccount `
					-ResourceGroupName $ResourceGroupName `
					-Name $SystemPrincipalName `
					-AssignIdentity

	$psCommand = "`$stAccount = `n`tSet-AzStorageAccount  ```n`t`t" +
						"-ResourceGroupName `"" + $ResourceGroupName + "`"```n`t`t" +
						"-Name `"" +  $SystemPrincipalName + "`"```n`t`t" +
						"-AssignIdentity`n"
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1373]:"
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #>
	########################################################################################


	$azResource = Get-AzStorageAccount `
					-ResourceGroupName $ResourceGroupName `
					-Name $SystemPrincipalName

	$psCommand = "`$stAccount = `n`tGet-AzStorageAccount  ```n`t`t" +
						"-ResourceGroupName `"" + $ResourceGroupName + "`"```n`t`t" +
						"-Name `"" +  $SystemPrincipalName + "`" `n" 
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1387]:" 
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #> 
	########################################################################################

	$PrincipalId = $azResource.Identity.PrincipalId
	# 
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1396]:"
		Write-Host -ForegroundColor White "`$PrincipalId = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$PrincipalId`""
	}#If($debugFlag)#> 

	If($StorageAccount -match 'audit')
	{
		$DeployObject.AuditStorageSystemPrincipalId = $PrincipalId
	}
	Else
	{
		$DeployObject.MainStorageSystemPrincipalId = $PrincipalId
	}#Else(StorageAccount -match 'audit')

	########################################################################################
	#assign keyvault access policy for the system assigned identity
	$AzKeyVaultAccessPolicy = Set-AzKeyVaultAccessPolicy `
								-VaultName $KeyVaultName `
								-ObjectId $PrincipalId `
								-PermissionsToKeys get,wrapkey,unwrapkey `
								-BypassObjectIdValidation

	$psCommand = "`$AzKeyVaultAccessPolicy = `n`t`tSet-AzKeyVaultAccessPolicy  ```n`t`t" +
								"-VaultName `"" + $KeyVaultName + "`"```n`t`t" +
								"-ObjectId `"" + $PrincipalId + "`"```n`t`t" +
								"-PermissionsToKeys get,wrapkey,unwrapkey`"" + "```n`t`t" +
								"-BypassObjectIdValidation `n"
	# 
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1425]:" 
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #>
	########################################################################################

	$SystemPrincipal = Get-AzADServicePrincipal -DisplayName $SystemPrincipalName
	$psCommand = "`$SystemPrincipal = `n`t`Get-AzADServicePrincipal  ```n`t`t" +
								"-DisplayName `"" + $SystemPrincipalName + "`" `n"
	# 
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1436]:" 
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #> 

	#$SystemPrincipalName = $SystemPrincipal.DisplayName
	#Write-Host -ForegroundColor Cyan "`$SystemPrincipalName=`"$SystemPrincipalName`""
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1444]" 
		Write-Host -ForegroundColor Green "Assign the KV Crypto Service Encryption User role to :"$SystemPrincipalName 
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "UtilityFunctions.ConfigureStorageEncryption[1447]:: Calling AddRoleAssignment..."
		Write-Host -ForegroundColor Cyan "`$SystemPrincipal=`"$SystemPrincipalName`""
	}#If($debugFlag)#>
	########################################################################################

	AddRoleAssignment `
		-AzRoleName $AzRoleName `
		-User $SystemPrincipal `
		-Scope $Scope `
		-DeployObject $DeployObject

	$psCommand = "`nAddRoleAssignment  ```n`t`t" +
						"-AzRoleName `"" + $AzRoleName + "`"```n`t`t" +
						"-User `"" + $SystemPrincipalName + "`"```n`t`t" +
						"-Scope `"" + $Scope + "`"```n`t`t" +
						"-DeployObject `"" + $DeployObject + "`" `n"
	# 
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1465]:" 
		Write-Host -ForegroundColor Cyan "assign the system-assigned managed identity to storage account: " -NoNewline
		Write-Host -ForegroundColor Yellow $SystemPrincipalName
		If($PrintPSCommands){ Write-Host -ForegroundColor Green $psCommand }
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($debugFlag)#>
	######################################################################################## 
	$storageAccount = Set-AzStorageAccount `
		-ResourceGroupName $ResourceGroupName `
		-Name $SystemPrincipalName `
		-AssignIdentity

	$psCommand = "`$storageAccount = `n`tSet-AzStorageAccount ```n`t`t" +
						"-ResourceGroupName `"" + $ResourceGroupName + "`"```n`t`t" +
						"-Name `"" + $SystemPrincipalName + "`"```n`t`t" +
						"-AssignIdentity `n"
	#
	If($debugFlag){
			Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1483]"
		Write-Host -ForegroundColor Cyan "Configure Encryption for storage:" $SystemPrincipalName
			Write-Host -ForegroundColor Yellow "`$SystemPrincipalName=`"$SystemPrincipalName`""
		Write-Host -ForegroundColor Cyan "`$KeyName=`"$KeyName`""
		Write-Host -ForegroundColor Cyan "`$ResourceGroupName=`"$ResourceGroupName`""
		Write-Host -ForegroundColor Cyan "`$KeyVaultUri=`"$KeyVaultUri`""
		If($PrintPSCommands){ Write-Host -ForegroundColor Green $psCommand }
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($debugFlag)#>
	######################################################################################## 
	$storageAccount = Set-AzStorageAccount `
		-ResourceGroupName $ResourceGroupName `
		-AccountName $SystemPrincipalName `
		-KeyvaultEncryption `
		-KeyName $KeyName `
		-KeyVersion "" `
		-KeyVaultUri $KeyVaultUri

	$psCommand = "`$storageAccount = `n`t`tSet-AzStorageAccount  ```n`t`t" +
								"-ResourceGroupName `"" + $ResourceGroupName + "`"```n`t`t" +
								"-AccountName `"" + $SystemPrincipalName + "`"```n`t`t" +
								"-KeyvaultEncryption ```n`t`t" +
								"-KeyName `"" + $KeyName + "`"```n`t`t" +
								"-KeyVersion `"`"```n`t`t" +
								"-KeyVaultUri `"" + $KeyVaultUri + "`" `n"
	# 
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.ConfigureStorageEncryption[1511]:" 
		Write-Host -ForegroundColor Green $psCommand
		For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Green -BackgroundColor Black "=" -NoNewline}}
	}#If($PrintPSCommands) #>
	########################################################################################
}#ConfigureStorageEncryption


Function global:AddKeyVaultAccessPolicy
{
	Param(
		[Parameter(Mandatory = $true)] [String]   $KeyVaultName
		, [Parameter(Mandatory = $true)] [String]   $PrincipalId 
	)
	If($debugFlag){
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.AddKeyVaultAccessPolicy[1515]"

		Write-Host -ForegroundColor White "`$KeyVaultName = " -NoNewline
		Write-Host -ForegroundColor Green "`"$KeyVaultName`""

		Write-Host -ForegroundColor White "`$PrincipalId = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$PrincipalId`""
	}#If($debugFlag)#>

	#$psCommand = "`$AzKeyVaultAccessPolicy = `n`tSet-AzKeyVaultAccessPolicy  ```n`t`t" +
	$psCommand =
		"`nSet-AzKeyVaultAccessPolicy  ```n`t`t" +
			"-VaultName `"" + $KeyVaultName + "`"```n`t`t" +
			"-ObjectId `"" +  $PrincipalId + "`"```n`t`t" +
			"-PermissionsToKeys wrapkey,unwrapkey,get" + " ```n`t`t" +
			"-ErrorAction SilentlyContinue `n"
		If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions.AddKeyVaultAccessPolicy[1532] - azRequestString:" 
			Write-Host -ForegroundColor Green $psCommand
		}#If($PrintPSCommands) #> 

		#assign keyvault access policy for the system assigned identity
	$AzKeyVaultAccessPolicy = Set-AzKeyVaultAccessPolicy `
								-VaultName $KeyVaultName `
								-ObjectId $PrincipalId `
								-PermissionsToKeys wrapkey,unwrapkey,get `
								-PermissionsToSecrets get `
								-ErrorAction SilentlyContinue
}#AddKeyVaultAccessPolicy


Function global:CheckAllAzResources
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $AzResourcesComplexObj
	)
	 If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Caller = "`n[" + $today + "] STARTING UtilityFunctions.CheckAllAzResources[1512]"
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
	}#If($debugFlag)#>

	$ResourceGroupName = $DeployObject.ResourceGroupName
	$KeyVaultName = $DeployObject.KeyVaultName
	ForEach ($resource in $AzResourcesComplexObj.GetEnumerator())
	{ 
		$key = $resource.Name
		$value = $resource.Value

		$Name = $AzResourcesComplexObj.$key.Name
		$Description = $AzResourcesComplexObj.$key.Description
		$ResourceName = $AzResourcesComplexObj.$key.ResourceName
		$ResourceType = $AzResourcesComplexObj.$key.ResourceType
		$PropertyName = $AzResourcesComplexObj.$key.PropertyName

		#
		If($debugFlag)
		{
		#
		Write-Host -ForegroundColor Magenta -BackgroundColor White  "`n[$i]"
		Write-Host -ForegroundColor Cyan "`$key= `"$key`""
		#Write-Host -ForegroundColor Cyan "`$value= `"$value`""
		#Write-Host -ForegroundColor Yellow "`$itemType=`"$itemType`""
		#
		$ObjectName = "chosenResource"
		$Caller = "UtilityFunctions.CheckAllAzResources[1539] :: " + $ObjectName
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		#PrintCustomObjectAsObject -Object $chosenResource -Caller $Caller -ObjectName $ObjectName
		#
		Write-Host -ForegroundColor Yellow "`$Name= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$Name`""

		Write-Host -ForegroundColor Yellow "`$Description= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$Description`""

		Write-Host -ForegroundColor Yellow "`$ResourceName= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ResourceName`""

		Write-Host -ForegroundColor Yellow "`$ResourceType= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ResourceType`""
		
			Write-Host -ForegroundColor Yellow "`$PropertyName= " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$PropertyName`""

			#
		}#If($debugFlag)#>
		#
		$DeployInfoPropExists = $key + "Exists"
		$ObjectResourceId = $key + "ResourceId"
		Write-Host -ForegroundColor Yellow "`$DeployInfoPropExists= " -NoNewline
		Write-Host -ForegroundColor Green "`"$DeployInfoPropExists`""

		$DeployObject.$DeployInfoPropExists =
		 CheckForExistingResource `
			-ResourceGroupName $ResourceGroupName `
			-ResourceType  $ResourceType `
			-ResourceName $ResourceName `
			-PropertyName $PropertyName `
			-ObjectResourceId $ObjectResourceId `
			-DeployObject $DeployObject
		#>
		$i++
		#}
	}#Foreach($resource in $AzureResourcesObj
}#CheckAllAzResources


Function global:CheckForExistingResource
{
	Param(
		[Parameter(Mandatory = $true)] [String]   $ResourceGroupName
		, [Parameter(Mandatory = $true)] [String]   $ResourceName
		, [Parameter(Mandatory = $true)] [String]   $ResourceType
		, [Parameter(Mandatory = $true)] [String]   $PropertyName
		, [Parameter(Mandatory = $true)] [String]   $ObjectResourceId
		, [Parameter(Mandatory = $true)] [Object]   $DeployObject
	)

	$KeyVaultName = $DeployObject.KeyVaultName
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		$Caller = "`n[" + $today + "] STARTING UtilityFunctions.CheckForExistingResource[1650]"
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller

		Write-Host -ForegroundColor White "`$ResourceName = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ResourceName`""

		Write-Host -ForegroundColor White "`$ResourceType = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ResourceType`""

		Write-Host -ForegroundColor White "`$PropertyName = " -NoNewline
		Write-Host -ForegroundColor Yellow "`"$PropertyName`""

		Write-Host -ForegroundColor White "`$ResourceGroupName = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ResourceGroupName`""

		Write-Host -ForegroundColor White "`$ObjectResourceId = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ObjectResourceId`""

		Write-Host -ForegroundColor White "`$KeyVaultName = " -NoNewline
		Write-Host -ForegroundColor Cyan "`"$KeyVaultName`""
	}#If($debugFlag)#> 

	If($ResourceName.length -eq 0)
	{
		$resourceExists = $false
		Write-Host -ForegroundColor Yellow "UtilityFunctions.CheckForExistingResource[1677] $ResourceName.length=0"
	}#If($ResourceName.length -eq 0)
	Else
	{
		$Caller = "`n UtilityFunctions.CheckForExistingResource[1681]" + "`$ResourceName= `"" + $ResourceName+ "`""
		#Write-Host -ForegroundColor DarkCyan -BackgroundColor White  $Caller
		$azResource = Get-AzResource  -ResourceGroupName $ResourceGroupName `
									-ResourceType $ResourceType `
									-Name $ResourceName `
									-ErrorAction SilentlyContinue

		$psCommand = "`$azResource = `n`tGet-AzResource  ```n`t`t" +
							"-ResourceGroupName `"" + $ResourceGroupName + "`"```n`t`t" +
						"-ResourceType `"" +  $ResourceType + "`"```n`t`t" +
						"-Name `"" +  $ResourceName + "`"```n`t`t" +
						"-ErrorAction SilentlyContinue `n"
		#
		If($PrintPSCommands){
		#Write-Host -ForegroundColor Magenta "UtilityFunctions.CheckForExistingResource[1693]:"
		Write-Host -ForegroundColor Green $psCommand
		}#If($PrintPSCommands) #> 

		If($azResource -eq $null)
		{
		$resourceExists = $false
		}#If($azResource -eq $null)
		Else
		{
			$resourceExists = $true
		$myResourceType = $ResourceType.split('/').Get(0).split('.').Get(1)
		$Caller = "`n UtilityFunctions.CheckForExistingResource[1705] resourceExists=TRUE"
		Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
		Write-Host -ForegroundColor Cyan "`$myResourceType= `"$myResourceType`""
		#{$_ -in "1","y", "yes"}
		Switch($myResourceType)
		{
		 "Network"
		 {
			$Caller = "UtilityFunctions.CheckForExistingResource[1713] myResourceType -eq " + $myResourceType
			Write-Host -ForegroundColor Magenta -BackgroundColor White $Caller
			Write-Host -ForegroundColor Magenta "Network `n`$myResourceType= `"$myResourceType`""
		 }#Network
		 "ManagedIdentity"
		 {
			$Caller = "UtilityFunctions.CheckForExistingResource[1719] myResourceType -eq " + $myResourceType
			Write-Host -ForegroundColor Red -BackgroundColor White $Caller
			$PrincipalId =  $DeployObject.$PropertyName = $azResource.Properties.PrincipalId
			Write-Host -ForegroundColor Red -BackgroundColor White "`$PrincipalId= `"$PrincipalId`""
		 }#ManagedIdentity
		 "KeyVault"
		 {
			$Caller = "UtilityFunctions.CheckForExistingResource[1726] myResourceType -eq " + $myResourceType
			Write-Host -ForegroundColor DarkCyan -BackgroundColor White $Caller
				Write-Host -ForegroundColor Cyan "KeyVault `n`$myResourceType= `"$myResourceType`""
			$KeyVaultResourceId =
			$DeployObject.KeyVaultResourceId = $azResource.ResourceId
			$DeployObject.KeyVaultUri = $azResource.Properties.vaultUri
			#
			If($debugFlag)
			{
				$Caller = "UtilityFunctions.CheckForExistingResource[1735] myResourceType -eq " + $myResourceType
				Write-Host -ForegroundColor DarkCyan -BackgroundColor White $Caller
				Write-Host -ForegroundColor Magenta -BackgroundColor White "UtilityFunctions.CheckForExistingResource[1738]"
				Write-Host -ForegroundColor Yellow "`$KeyVaultResourceId= `"$KeyVaultResourceId`""
				Write-Host -ForegroundColor Cyan "`$ResourceName= `"$ResourceName`""
			}#If($debugFlag)#>
		 }#KeyVault
		 "Web"
		 {
			$Caller = "UtilityFunctions.CheckForExistingResource[1744] myResourceType -eq " + $myResourceType
			Write-Host -ForegroundColor DarkCyan -BackgroundColor White $Caller
			Write-Host -ForegroundColor DarkCyan "`$myResourceType= `"$myResourceType`""
			$PrincipalId = $DeployObject.$PropertyName = $azResource.Identity.PrincipalId
			#
			If($debugFlag){
				$Caller = "UtilityFunctions.CheckForExistingResource[1750] myResourceType -eq " + $myResourceType
				Write-Host -ForegroundColor DarkCyan -BackgroundColor White $Caller
					Write-Host -ForegroundColor DarkCyan "`$ResourceName= `"$ResourceName`""
			}#If($debugFlag)#>
		 }#Web
		 "Storage"
		 {
			$Caller = "UtilityFunctions.CheckForExistingResource[1758] myResourceType -eq " + $myResourceType
			Write-Host -ForegroundColor Yellow $Caller
			Write-Host -ForegroundColor Yellow "Storage `n`$myResourceType= `"$myResourceType`""
			$PrincipalId = $DeployObject.$PropertyName = $azResource.Identity.PrincipalId
			#
			If($debugFlag){
				$Caller = "UtilityFunctions.CheckForExistingResource[1764] myResourceType -eq " + $myResourceType + "`n Calling ConfigureStorageEncryption"
				Write-Host -ForegroundColor DarkCyan -BackgroundColor White $Caller
				Write-Host -ForegroundColor DarkCyan -BackgroundColor White "`$ResourceName= `"$ResourceName`""
			}#If($debugFlag)#> 

			#ConfigureStorageEncryption -DeployObject $DeployObject -StorageAccount $ResourceName
			Write-Host -ForegroundColor DarkCyan -BackgroundColor White "Returning: `n`$resourceExists= `"$resourceExists`""
		 }#Storage
		"Sql"
		{
			$Caller = "UtilityFunctions.CheckForExistingResource[1773] myResourceType -eq " + $myResourceType
			Write-Host -ForegroundColor DarkGreen -BackgroundColor White $Caller
			Write-Host -ForegroundColor DarkGreen -BackgroundColor White "`$myResourceType= `"$myResourceType`""
			$PrincipalId =
			$DeployObject.$PropertyName = $azResource.identity.PrincipalId
		}#Sql
		 Default
		 {
			$Caller = "UtilityFunctions.CheckForExistingResource[1779] myResourceType -eq " + $myResourceType
			Write-Host -ForegroundColor Cyan -BackgroundColor White $Caller
			Write-Host -ForegroundColor Red "Default `n`$myResourceType= `"$myResourceType`""
			Write-Host -ForegroundColor Green "`$myResourceType= `"$myResourceType`""
		 }#Default
		}#Switch($myResourceType)

		$DeployObject.$ObjectResourceId = $azResource.ResourceId
		}#ElseIf($azResource -eq $null)
	}
	return $resourceExists
}#CheckForExistingResource

Function global:CryptoRoleAssignments
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.CryptoRoleAssignments[1789]"
	}#If($debugFlag)#>
	$Message = "Assign the KV Crypto Serv Encryption User Role Assignment"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	$ManagedUserName = $DeployObject.ManagedUserName
	$CryptoEncryptRoleId = $DeployObject.CryptoEncryptRoleId
	$AzRoleName = "Key Vault Crypto Service Encryption User"
	$CurrUser = Get-AzADUser -DisplayName $DeployObject.CurrUserName
	$CurrUserName = $DeployObject.CurrUserName
	$Scope = $DeployObject.KeyVaultResourceId
	$KeyVaultUri = $DeployObject.KeyVaultUri
	$KeyVaultName = $DeployObject.KeyVaultName
	$ResourceGroupName = $DeployObject.ResourceGroupName
	#assign Key Vault Crypto Service Encryption User to the managed id
	#retrieve the user-assigned managed identity and assign to it the required RBAC role, scoped to the key vault.
	#Add Key Vault Crypto Service Encryption User role for: CurrUser

	#
	If($debugFlag){
			Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n UtilityFunctions.CryptoRoleAssignments[1810] :: BEFORE AddRoleAssignment =>"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "Assign KV Crypto Serv Encryption User to the CURRENT USER"
			Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
		Write-Host -ForegroundColor Green "`$Scope=`"$Scope`""
		Write-Host -ForegroundColor Cyan "`$CurrUserName=`"$CurrUserName`""
		Write-Host -ForegroundColor Cyan "`$ManagedUserName=`"$ManagedUserName`""
	}#>

	AddRoleAssignment `
		-AzRoleName $AzRoleName `
		-User $CurrUser `
		-Scope $Scope `
		-DeployObject $DeployObject
	<############################################################> 
	#Add Key Vault Crypto Service Encryption User role for: ManagedUserName

	$ManagedUser = Get-AzADServicePrincipal -DisplayName $ManagedUserName

	$psCommand = "`$ManagedUser = `n`tGet-AzADServicePrincipal  ```n`t`t" + 
						"-DisplayName `"" + $ManagedUserName + "`" `n"
									
	#
	If($PrintPSCommands){
		Write-Host -ForegroundColor Magenta "UtilityFunctions..CryptoRoleAssignments[1833]:" 
		Write-Host -ForegroundColor Green $psCommand
	}#If($PrintPSCommands) #> 

	$ManagedUserName = $ManagedUser.DisplayName
	#
	If($debugFlag){

			Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n UtilityFunctions.CryptoRoleAssignments[1846] :: BEFORE AddRoleAssignment"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "Assign the Kv Crypto Service Encryption User role to the $ManagedUserName IDENTITY"
			Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
		Write-Host -ForegroundColor Green "`$ManagedUserName=`"$ManagedUserName`""
		Write-Host -ForegroundColor Green "`$DeployObject.ManagedUserName=`"" -NoNewline
		Write-Host $DeployObject.ManagedUserName -NoNewline
		Write-Host "`""
		Write-Host -ForegroundColor Green "`$Scope=`"$Scope`""
	}#If($debugFlag)#>

		AddRoleAssignment `
		 -AzRoleName $AzRoleName `
		 -User  $ManagedUser `
		 -Scope $Scope `
		 -DeployObject $DeployObject

		$AzRoleName = "Contributor"
		#
		If($debugFlag){
			Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n UtilityFunctions.CryptoRoleAssignments[1865] :: BEFORE AddRoleAssignment"
		 Write-Host -ForegroundColor DarkBlue -BackgroundColor White "Assign Contributor role to the  $CurrUserName" 
		 Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
		 Write-Host -ForegroundColor Green "`$ManagedUserName=`"$ManagedUserName`""
		 #Write-Host -ForegroundColor Green "`$Scope=`"$Scope`""
		 Write-Host -ForegroundColor Green "`ResourceGroupName=`" $DeployObject.ResourceGroupName`""
		}#If($debugFlag)#>

		AddRoleAssignment `
			-AzRoleName $AzRoleName `
			-User  $CurrUser `
			-ResourceGroupName $DeployObject.ResourceGroupName `
			-DeployObject $DeployObject
		#
		If($debugFlag){
			Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n UtilityFunctions.CryptoRoleAssignments[1880] :: BEFORE AddRoleAssignment"
		 Write-Host -ForegroundColor DarkBlue -BackgroundColor White "Assign Contributor role to the ManagedUser IDENTITY: $ManagedUserName" 
		 Write-Host -ForegroundColor Yellow "`$AzRoleName=`"$AzRoleName`""
		 Write-Host -ForegroundColor Green "`$ManagedUserName=`"$ManagedUserName`""
		 #Write-Host -ForegroundColor Green "`$Scope=`"$Scope`""
		 Write-Host -ForegroundColor Green "`ResourceGroupName=`" $DeployObject.ResourceGroupName`""
		}#If($debugFlag)#>

		AddRoleAssignment `
			-AzRoleName $AzRoleName `
			-User $ManagedUser `
			-ResourceGroupName $DeployObject.ResourceGroupName `
			-DeployObject $DeployObject

	###############################################  
}#CryptoRoleAssignments


Function global:SetStorageEncryption
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING UtilityFunctions.SetStorageEncryption[1907]"
	}#If($debugFlag)#>
	$Message = "SET STORAGE ENCRYPTION:"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

	If($DeployObject.AuditStorageName -ne $null) 
	{ 
	$AuditStorageName = $DeployObject.AuditStorageName
	#
	If($debugFlag){
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "UtilityFunctions.SetStorageEncryption[1918]" 
			Write-Host -ForegroundColor Cyan "`$AuditStorageName= `"$AuditStorageName`"" 
	}#If($debugFlag)#>
		ConfigureStorageEncryption -DeployObject $DeployObject -StorageAccount $AuditStorageName
		
	}
	If($DeployObject.MainStorageName -ne $null) 
	{
		$MainStorageName = $DeployObject.MainStorageName
		#
		If($debugFlag){
		 Write-Host -ForegroundColor DarkBlue -BackgroundColor White "UtilityFunctions.SetStorageEncryption[1929]"
			Write-Host -ForegroundColor Cyan "`$MainStorageName= `"$MainStorageName`""
		}#If($debugFlag)#>
		ConfigureStorageEncryption -DeployObject $DeployObject -StorageAccount $MainStorageName
	}
}#SetStorageEncryption




Function global:GetBuildFlag
{
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`tWOULD YOU LIKE TO BUILD THE APPLICATIONS?:"
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor White "Press the letter in the bracket to choose then press Enter:" 
	Write-Host -ForegroundColor Yellow "[ 1 ] : Yes"
	Write-Host -ForegroundColor Yellow "[ 2 ] : No"
	Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
	$BuildFlag = Read-Host "Enter your choice"
	Switch ($BuildFlag)
	{
			1{$BuildFlag = $true}
		2{$BuildFlag = $false} 
			X { "Quitting..."
			$BuildFlag = $false
			exit(1)
		}
		Default {
			$BuildFlag = GetBuildFlag
			}
	}#Switch
	return $BuildFlag
}#GetBuildFlag

Function global:GetPublishFlag
{
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`tWOULD YOU LIKE TO PUBLISH THE APPLICATIONS?:"
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor White "Press the letter in the bracket to choose, then press Enter:" 
	Write-Host -ForegroundColor Yellow "[ 1 ] : Yes"
	Write-Host -ForegroundColor Yellow "[ 2 ] : No"
	Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
	$PublishFlag = Read-Host "Enter your choice"
	Switch ($PublishFlag)
	{
			1{$PublishFlag = $true}
		2{$PublishFlag = $false} 
			X { "Quitting..."
		$BuildFlag = $false
			exit(1)
		}
		Default {
			$PublishFlag = Pick_DebugMode
			}
	}#Switch
	return $PublishFlag
}#GetPublishFlag

Function global:BuildApps
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)
	$PSFolderPath = $RootFolder + "Deploy\powershell"
	$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName + "_" + $DeployObject.Environment
	$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

	#CLIENT WEBSITE
	$sitesDirPath = $RootFolder + "Sites"
	$BuildFlag = $DeployObject.BuildFlag
	$PublishFlag = $DeployObject.PublishFlag 

	If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[839] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
		Write-host -ForegroundColor Yellow  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
		Write-Host -ForegroundColor Cyan "`$DeployObject.BuildFlag=`"`BuildFlag`""
		Write-host -ForegroundColor Cyan  "`$DeployObject.PublishFlag=`"`PublishFlag`""
	}#If($debugFlag)
	If($BuildFlag)
	{
		#$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName  + "_" + $DeployObject.Environment
		#$DtsReleasePath = $RootFolderParentPath + "\_" + $DtsReleaseFolderName

			$ResourceGroupName = $DeployObject.ResourceGroupName
		$FunctionAppName = $DeployObject.APIAppRegName
		$ClientAppName = $DeployObject.ClientAppRegName

		$FunctionAppArchivePath = $DtsReleasePath + '\' + $DeployObject.APIAppRegName + '_FunctionApp.zip'
		$WebSiteArchivePath = $DtsReleasePath + "\" + $DeployObject.ClientAppRegName + "_WebSite.zip"

		If($debugFlag){
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[866] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."
	

			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`""

			#Write-Host -ForegroundColor Cyan "`$=" $
			}#debugFlag #>
		if (-not (Test-Path $DtsReleasePath))
		{
			$DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
			$DtsReleasePath = $DtsReleaseFolder.FullName
		}

		If($DeployObject.Solution -eq 'Pickup')
		{
			$ApiDirPath = $RootFolder + "API\DPP"
			$ApiPublishedFolder =  $RootFolder + "API\DPP\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dpp\build\*"
			$buildType = "dpp"
		}#$DeployObject.Solution -eq 'Pickup'
		ElseIf($DeployObject.Solution -eq 'Transfer') #TRANSFER
		{
			$ApiDirPath = $RootFolder + "API\dtpapi" 
			$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dtp\build\*"
			$buildType = "dtp"
		}#ElseIf($DeployObject.Solution -eq 'Transfer') #TRANSFER #>

		$ApiOutputFolder = $ApiDirPath + "\bin\Release\net6.0\publish"  

		If($debugFlag){
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[913] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."
			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""

			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`"" 
			}#debugFlag #>

			cd $APIdirPath

		dotnet build --configuration Release
		dotnet publish --configuration Release

		#cd $ApiPublishedFolder
			Compress-Archive -Path $ApiPublishedFolder -DestinationPath $FunctionAppArchivePath -Force 

		#CLIENT
		cd $sitesDirPath
		#explorer $sitesDirPath
		npm run hydrateNodeModules

		#before running npm run build: make sure .env files are up to date
		npm run build:$buildType

			Compress-Archive -Path $SitePublishFolder -DestinationPath $WebSiteArchivePath -Force
		Write-Host -ForegroundColor Green "Opening folder with the zip files....."
		explorer $DtsReleasePath 
	}#BuildFlag

	cd $PSFolderPath  
}#BuildApps

Function global:PublishApps
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	$PSFolderPath = $RootFolder + "Deploy\powershell"
	$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName + "_" + $DeployObject.Environment
	$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

	#CLIENT WEBSITE
	$sitesDirPath = $RootFolder + "Sites"
	$BuildFlag = $DeployObject.BuildFlag
	$PublishFlag = $DeployObject.PublishFlag 

	If($DeployObject.Solution -eq 'Pickup')
	{
		$ApiDirPath = $RootFolder + "API\DPP"
		$ApiPublishedFolder =  $RootFolder + "API\DPP\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dpp\build\*"
			$buildType = "dpp"
	}#$DeployObject.Solution -eq 'Pickup'
	ElseIf($DeployObject.Solution -eq 'Transfer') #TRANSFER
	{
		$ApiDirPath = $RootFolder + "API\dtpapi" 
			$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dtp\build\*"
		$buildType = "dtp"
	}#ElseIf($DeployObject.Solution -eq 'Transfer') #TRANSFER #>

	If($debugFlag){
		Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PublishApps[977] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
		Write-host -ForegroundColor Yellow  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
		Write-Host -ForegroundColor Cyan "`$DeployObject.BuildFlag=`"`$BuildFlag`""
		Write-host -ForegroundColor Cyan  "`$DeployObject.PublishFlag=`"`$PublishFlag`""
	}#If($debugFlag)#>

	If($PublishFlag)
	{
		If($debugFlag){
			Write-Host -ForegroundColor Magenta "UtilityFunctions.PublishApps[996] PUBLISHING CLIENT SITE ...."
		}#debugFlag #>

		$functionApp = Get-AzWebApp `
					-Name $FunctionAppName `
					-ResourceGroupName $ResourceGroupName
		#verify
		If($debugFlag){
			Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $functionApp.DefaultHostName
		}

		#Publish:
		$functionApp = Publish-AzWebApp -Force -WebApp $functionApp -ArchivePath $FunctionAppArchivePath
		Write-Host -ForegroundColor Cyan "SUCCESS! Published functionApp: DefaultHostName=" $functionApp.DefaultHostName

		#Publish  WEBSITE to Azure
		$myApp = Get-AzWebApp `
					-Name $ClientAppName `
					-ResourceGroupName $ResourceGroupName
		#verify
		Write-Host -ForegroundColor Green "checking ClientApp Get-AzWebApp: " $myApp.DefaultHostName
		$mySite = Publish-AzWebApp -Force -WebApp $myApp -ArchivePath $WebSiteArchivePath
		Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName
	}#PublishFlag
	#
	If($debugFlag){
		explorer $DtsReleasePath
	}#>

	cd $PSFolderPath	
}#PublishApps

Function global:PickBuildAndPublish
{
	Param(
		[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	$PSFolderPath = $RootFolder + "Deploy\powershell"
	$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName + "_" + $DeployObject.Environment
	$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

	#CLIENT WEBSITE
	$sitesDirPath = $RootFolder + "Sites"
	$BuildFlag = $DeployObject.BuildFlag
	$PublishFlag = $DeployObject.PublishFlag
	

	If($debugFlag)
	{
		Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[839] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
		Write-host -ForegroundColor Yellow  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
		Write-Host -ForegroundColor Cyan "`$DeployObject.BuildFlag=`"`$BuildFlag`""
		Write-host -ForegroundColor Cyan  "`$DeployObject.PublishFlag=`"`$PublishFlag`""
	}#If($debugFlag)

	If($BuildFlag)
	{
		#$DtsReleaseFolderName = "DtsRelease_" + $DeployObject.AppName  + "_" + $DeployObject.Environment
		#$DtsReleasePath = $RootFolderParentPath + "\_" + $DtsReleaseFolderName

			$ResourceGroupName = $DeployObject.ResourceGroupName
		$FunctionAppName = $DeployObject.APIAppRegName
		$ClientAppName = $DeployObject.ClientAppRegName

		$FunctionAppArchivePath = $DtsReleasePath + '\' + $DeployObject.APIAppRegName + '_FunctionApp.zip'
		$WebSiteArchivePath = $DtsReleasePath + "\" + $DeployObject.ClientAppRegName + "_WebSite.zip"

		If($debugFlag)
		{
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[866] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."

			<#Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
			#>
			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`""
		}#debugFlag #>
		if (-not (Test-Path $DtsReleasePath))
		{
			$DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
			$DtsReleasePath = $DtsReleaseFolder.FullName
		}

		If($DeployObject.Solution -eq 'Pickup')
		{
			$ApiDirPath = $RootFolder + "API\DPP"
			$ApiPublishedFolder =  $RootFolder + "API\DPP\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dpp\build\*"
			$buildType = "dpp"
		}#$DeployObject.Solution -eq 'Pickup'
		ElseIf($DeployObject.Solution -eq 'Transfer') #TRANSFER
		{
			$ApiDirPath = $RootFolder + "API\dtpapi" 
			$ApiPublishedFolder =  $RootFolder + "API\dtpapi\bin\Release\net6.0\publish\*"
			$SitePublishFolder = $RootFolder + "Sites\packages\dtp\build\*"
			$buildType = "dtp"
		}#ElseIf($DeployObject.Solution -eq 'Transfer') #TRANSFER #>

		$ApiOutputFolder = $ApiDirPath + "\bin\Release\net6.0\publish"  

		If($debugFlag){
			Write-Host -ForegroundColor Magenta "`n`UtilityFunctions.PickBuildAndPublish[913] CLIENT WEBSITE BUILD-ZIP-PUBLISH...."
			Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
			Write-host -ForegroundColor Green  "`$PSFolderPath=`"$PSFolderPath`""

			Write-Host -ForegroundColor Cyan "`$sitesDirPath=`"$sitesDirPath`""
			Write-Host -ForegroundColor Yellow "`$RootFolderParentPath=`"$RootFolderParentPath`""
			Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""

			Write-Host -ForegroundColor Cyan "`$ApiDirPath=`"$ApiDirPath`""
			Write-Host -ForegroundColor Cyan "`$ApiPublishedFolder=`"$ApiPublishedFolder`""
			Write-Host -ForegroundColor Cyan "`$SitePublishFolder=`"$SitePublishFolder`""

			Write-host -ForegroundColor Green  "`$FunctionAppArchivePath=`"$FunctionAppArchivePath`""
			Write-host -ForegroundColor Green  "`$WebSiteArchivePath=`"$WebSiteArchivePath`""  

			Write-Host -ForegroundColor Cyan "`$buildType=`"$buildType`""

			Write-Host -ForegroundColor Yellow "`$ResourceGroupName=`"$ResourceGroupName`""
			Write-Host -ForegroundColor Yellow "`$FunctionAppName=`"$FunctionAppName`""
			Write-Host -ForegroundColor Yellow "`$ClientAppName=`"$ClientAppName`""
		}#debugFlag #>

			cd $APIdirPath

		dotnet build --configuration Release
		dotnet publish --configuration Release

		#cd $ApiPublishedFolder
			Compress-Archive -Path $ApiPublishedFolder -DestinationPath $FunctionAppArchivePath -Force 

		#CLIENT
		cd $sitesDirPath
		#explorer $sitesDirPath
		npm run hydrateNodeModules
		#npm install -g svgo
		#npx update-browserslist-db@latest
		#before running npm run build: make sure .env files are up to date
		npm run build:$buildType

			Compress-Archive -Path $SitePublishFolder -DestinationPath $WebSiteArchivePath -Force
		Write-Host -ForegroundColor Green "Opening folder with the zip files....."
		explorer $DtsReleasePath 
	}#BuildFlag


	#$PublishFlag = GetPublishFlag
	If($PublishFlag)
	{
		If($debugFlag){
			#
			Write-Host -ForegroundColor Magenta "UtilityFunctions.PickBuildAndPublish[848] PUBLISHING CLIENT SITE ...."
		}#debugFlag #>

		$functionApp = Get-AzWebApp `
					-Name $FunctionAppName `
					-ResourceGroupName $ResourceGroupName
		#verify
		If($debugFlag){
			Write-Host -ForegroundColor Green "checking Get-AzWebApp: " $functionApp.DefaultHostName
		}

		#Publish:
		$functionApp = Publish-AzWebApp -Force -WebApp $functionApp -ArchivePath $FunctionAppArchivePath
		Write-Host -ForegroundColor Cyan "SUCCESS! Published functionApp: DefaultHostName=" $functionApp.DefaultHostName

		#Publish  WEBSITE to Azure
		$myApp = Get-AzWebApp `
					-Name $ClientAppName `
					-ResourceGroupName $ResourceGroupName
		#verify
		Write-Host -ForegroundColor Green "checking ClientApp Get-AzWebApp: " $myApp.DefaultHostName
		$mySite = Publish-AzWebApp -Force -WebApp $myApp -ArchivePath $WebSiteArchivePath
		Write-Host -ForegroundColor Cyan "SUCCESS! Published: DefaultHostName=" $mySite.DefaultHostName
	}#PublishFlag

	#
	If($debugFlag){
		explorer $DtsReleasePath
	}#>

	cd $PSFolderPath	
}#PickBuildAndPublish

Function global:PrintDeployObject{
	Param(
		[Parameter(Mandatory = $true)] [object] $object
		, [Parameter(Mandatory = $false)] [string] $Caller
	)

	Write-Debug "UtilityFunctions.PrintDeployObject[792]"

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Cyan "================================================================================`n"
	Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] START $Caller.PrintDeployObject"

	$i=0
	foreach ($item in $object.GetEnumerator())
	#foreach ($item in $object)
	{ 
			#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] `$item.name="$item.name
		$currItem = $item.value
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] item.value.GetType=" ($item.value).GetType()
			#Write-Host -ForegroundColor Green -BackgroundColor Black "[$i] currItem.GetType=" $currItem.GetType()
		#Write-Host -ForegroundColor Green -BackgroundColor Black "[$i] currItem.GetType.Name=" $currItem.GetType().Name
		#Write-Host -ForegroundColor Green -BackgroundColor Black "[$i] currItem.GetType.BaseType=" $currItem.GetType().BaseType
		#Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$i] currItem.GetType.BaseType.FullName=" $currItem.GetType().BaseType.FullName
		#Write-Host "[1136] itemType -eq OrderedDictionary:" ($currItem.GetType() -eq "System.Collections.Specialized.OrderedDictionary")

		If( $currItem.GetType() -match "System.Collections.Specialized.OrderedDictionary")
		{
			Write-Host -ForegroundColor Magenta "item.name="$item.name
			foreach($key in $currItem.keys)
			{
				$message = '{0} = {1} ' -f $key, $currItem[$key]
				Write-Host -ForegroundColor Yellow $message
			}
			}
			ElseIf($currItem.GetType() -match "System.Management.Automation.PSCustomObject")
		{
			Write-Host -ForegroundColor Red "item.name="$item.name
			#Write-Host -ForegroundColor Red "[1246][$i] `$item.GetType=" $item.GetType()
			#Write-Host -ForegroundColor Red "[1246][$i] `$item.value.GetType()=" $item.value.GetType()
			#Write-Host -ForegroundColor Red "[1246][$i] `$item.value=" $item.value
			$currItem.PSObject.Properties | ForEach-Object {
				#$_.Name
				#$_.Value
				Write-Host -ForegroundColor Cyan $_.Name "=" $_.Value
			}
		}
		Else
		{
			Write-Host -ForegroundColor Green  $item.name "=" $item.value
		}
		#>
		#$item.name +"=" + $item.value >> $FilePath
		$i++
	}

	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
	Write-Host -ForegroundColor Cyan "================================================================================`n"
}#PrintDeployObject


Function global:PrintHashKeyValue
{
	Param(
		[Parameter(Mandatory = $true)] [object] $object
		, [Parameter(Mandatory = $false)] [string] $Caller

	)

	Write-Debug "UtilityFunctions.PrintHashKeyValue[878]"

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
	$i=0
	Write-Host -ForegroundColor Cyan  "@{"
	foreach ($item in $object.GetEnumerator())
	{ 
		write-host -ForegroundColor Cyan $item.key "="""$item.value""";"
		$i++
	}
	Write-Host -ForegroundColor Cyan "}"
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHashKeyValue

Function global:PrintCloudOptionsStrArr
{
	Param(
		[Parameter(Mandatory = $true)] [string[]] $ValueArr
	)

	Write-Debug "UtilityFunctions.PrintCloudOptionsStrArr[921]"

	$i=0
	foreach($item in $ValueArr)
	{ 
		#$camelString = $item
		$item = $item -csplit '(?<!^)(?=[A-Z])' -join ' '
		Write-Host -ForegroundColor Yellow "[ $i ] : $item"
		$item['ProperName', $item]
		$i++
	}
	Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
	#return $ValueArr
}#PrintCloudOptionsStrArr


Function global:ConvertFrom-SecureString-AsPlainText
{
	[CmdletBinding()]
	param (
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $true
		)]
		[System.Security.SecureString]
		$SecureString
	)

	Write-Debug "UtilityFunctions.ConvertFrom-SecureString-AsPlainText[949]"

	$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
	$PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
	$PlainTextString;
}

function ConvertPSObjectToHashtable
{
	param (
		[Parameter(ValueFromPipeline)]
		$InputObject
	)

	Write-Debug "UtilityFunctions.ConvertPSObjectToHashtable[1037]"

	process
	{
		if ($null -eq $InputObject) { return $null }

		if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
		{
			$collection = @(
				foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
			)

			Write-Output -NoEnumerate $collection
		}
		elseif ($InputObject -is [psobject])
		{
			$hash = @{}

			foreach ($property in $InputObject.PSObject.Properties)
			{
				$hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
			}

			$hash
		}
		else
		{
			$InputObject
		}
	}
}




######################################################
# OBSOLETE
######################################################
Function global:Get_Region 
{
	Param(
		[Parameter(Mandatory = $false)] [object]$LocationArr
	)

	Write-Debug "UtilityFunctions.Get_Region[580]"
	#>
	#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_Region"
	$LocationIndex = Read-Host "Enter Selection"
 
	If($LocationIndex -lt $GeographyGroupArr.Count -or $LocationIndex -eq "X")
	{
		Switch ($LocationIndex)
			{
			X
			{
				"Quitting..."
				exit(1)
			}
				Default
			{
				$region = $GeographyGroupArr[$LocationIndex]
			}
			}
	}
	Else
	{
		Write-Host -ForegroundColor Red "INPUT NOT VALID, TRY AGAIN..."
		$region = Get_Region
	}


	<#
		Write-Host "UtilityFunctions.Get_Region[962] LocationIndex:" $LocationIndex
		Write-Host "UtilityFunctions.Get_Region[963] region:" $region.DisplayName
		#Write-Host "UtilityFunctions.Get_Region[964] LocationIndex.Type:" $LocationIndex.GetType()
		#Write-Host "UtilityFunctions.Get_Region[320] GeographyGroupArr.Count:" $GeographyGroupArr.Count
		Write-Host "UtilityFunctions.Get_Region[966] GeographyGroupArr.Length:" $GeographyGroupArr.Length
		Write-Host "UtilityFunctions.Get_Region[967] GeographyGroupArr.Count:" $GeographyGroupArr.Count
		Write-Host "UtilityFunctions.Get_Region[968] LocationIndex:" $LocationIndex

		#Write-Host -ForegroundColor White -BackgroundColor Black  " UtilityFunctions.Get_Region[970] region: " $region
		#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_Region`n"
	#>
	return $region
}
<#
	Function global:Get_DeployMode
	{
		Write-Debug "UtilityFunctions.Get_DeployMode[735]"
		#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		#Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.GetCodeEnvironment"

		$deployMode = Read-Host "Enter Selection for DEPLOY MODE"
			Switch ($deployMode)
			{

			0{$deployMode="All"}
			1{$deployMode="Transfer"}
			2{$deployMode="Pickup"}
			X { "Quitting..."
					exit(1)
			}
			Default {
				$deployMode = Get_DeployMode
			}
		}
		#Write-Host -ForegroundColor Green -BackgroundColor Black  "You Selected: " $environment
		#$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		#Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_DeployMode`n"
		return $deployMode
	}#Get_DeployMode
#>