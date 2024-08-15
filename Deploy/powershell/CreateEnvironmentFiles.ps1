Function global:CreateEnvironmentFiles
{
	Param(
		[Parameter(Mandatory = $false)] [String] $RootFolder
		,[Parameter(Mandatory = $true)]  [String] $TemplateDir
		,[Parameter(Mandatory = $true)]  [Object] $DeployObject
	)

	$Message = "CREATE .ENV FILES:"
	#
	If($debugFlag)
	{
		$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
		Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateEnvironmentFiles.CreateEnvironmentFiles"
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
		Write-Host -ForegroundColor Yellow "`$RootFolder=`"$RootFolder`""
		Write-Host -ForegroundColor Yellow "`$TemplateDir=`"$TemplateDir`""

		Write-Host -ForegroundColor Green "`$DeployObject.AppName=" $DeployObject.AppName
		Write-Host -ForegroundColor Green "`$DeployObject.APIAppRegName=" $DeployObject.APIAppRegName
		Write-Host -ForegroundColor Green "`$DeployObject.ClientAppRegName=" $DeployObject.ClientAppRegName
		Write-Host -ForegroundColor Green "`$DeployObject.ResourceGroupName=" $DeployObject.ResourceGroupName
		Write-Host -ForegroundColor Green "`$DeployObject.DeploymentName=" $DeployObject.DeploymentName 
		$Caller ='CreateEnvironmentFiles[33] DeployObject::'
		#PrintCustomObject -Object $DeployObject -Caller $Caller
	}
	Else
	{
		$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
		#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
	}
 
	$DeploymentName = $DeployObject.DeploymentName

	$EnvFolder = $null
	$EnvFilePath = $null

	$DPPEnvObject = [ordered]@{
		GENERATE_SOURCEMAP = "$false";
		REACT_APP_AAD_CLIENT_ID = $DeployObject.ClientAppRegAppId;
		REACT_APP_AAD_AUTHORITY = $DeployObject.ActiveDirectoryAuthority + $DeployObject.TenantId;
		REACT_APP_AAD_REDIRECT_URI = "https://" + $DeployObject.ClientAppRegName + ".azurewebsites.us";
		REACT_APP_LOGIN_SCOPES = "array:User.Read";
		REACT_APP_GRAPH_ENDPOINT = $DeployObject.GraphUrl + "v1.0/me";
			REACT_APP_GRAPH_SCOPES = "array:User.Read"
		REACT_APP_DPP_API_ENDPOINT = "https://" + $DeployObject.APIAppRegName + ".azurewebsites.us/api";
		REACT_APP_DPP_API_SCOPES = "array:api://" + $DeployObject.APIAppRegAppId + "/.default" ;
		REACT_APP_COMPLETED_TRANFERS_POLLING_INTERVAL_MS=10000
		REACT_APP_HELP_URL="https://app-docfx.azurewebsites.us"
		REACT_APP_VALIDATION_CHECK_INTERVAL=60000
	}#DPPEnvObject

	$DPPLocalEnvObject = [ordered]@{
		REACT_APP_DPP_API_ENDPOINT = "http://localhost:7047/api";
		REACT_APP_AAD_REDIRECT_URI = "http://localhost:3000";
	}#DPPLocalEnvObject

	$DTPEnvObject = [ordered]@{
		GENERATE_SOURCEMAP = "$false";
		REACT_APP_AAD_CLIENT_ID = $DeployObject.ClientAppRegAppId;
		REACT_APP_AAD_AUTHORITY = $DeployObject.ActiveDirectoryAuthority + $DeployObject.TenantId;
		REACT_APP_AAD_REDIRECT_URI = "https://" + $DeployObject.ClientAppRegName + ".azurewebsites.us";
		REACT_APP_LOGIN_SCOPES = "array:User.Read";
		REACT_APP_GRAPH_ENDPOINT = $DeployObject.GraphUrl + "v1.0/me";
			REACT_APP_GRAPH_SCOPES = "array:User.Read";
		REACT_APP_DTP_API_ENDPOINT = "https://" + $DeployObject.APIAppRegName + ".azurewebsites.us/api" ;
		REACT_APP_DTP_API_SCOPES = "array:api://" + $DeployObject.APIAppRegAppId + "/.default" ;
		REACT_APP_TRANSFER_HISTORY_POLLING_INTERVAL_MS = 10000
		REACT_APP_DEFAULT_DATE_FORMAT = "MM/DD/YYYY HH:mm:ss"
		#REACT_APP_DTS_AZ_STORAGE_URL = "https://" + $DeploymentOutput.Outputs.storageAccountNameMain.Value + ".blob." + $DeployObject.Cloud.StorageEndpointSuffix + "/"
		REACT_APP_DTS_AZ_STORAGE_URL = $DeployObject.REACT_APP_DTS_AZ_STORAGE_URL
		REACT_APP_HELP_URL="https://app-docfx.azurewebsites.us"
	}#DTPEnvObject

	$DTPLocalEnvObject = [ordered]@{
		#REACT_APP_DTP_API_ENDPOINT=http://localhost:7071/api
		# REACT_APP_AAD_REDIRECT_URI: Redirect Uri for Azure AD
		REACT_APP_AAD_REDIRECT_URI = "http://localhost:3000"

	}#DTPLocalEnvObject

	If (Test-Path $TemplateDir)
	{
			$FileListJson = ConvertTo-Json (Get-ChildItem -Path $TemplateDir | Select FullName).FullName
		$FileList = $FileListJson | Out-String | ConvertFrom-Json
		#Write-Host -ForegroundColor Magenta "[65] Directory=$TemplateDir"
		#Write-Host -ForegroundColor Green "[66] Folder/FileList:"
		$type = $FileList.GetType()
		#System.Object
		If( $type.BaseType.FullName -eq "System.Object" )
		{
			#Write-Host -ForegroundColor Yellow "[71] type.BaseType.FullName:" $type.BaseType.FullName
			#Write-Host -ForegroundColor Yellow "[72] FileList:" $FileList
			$Path = (Get-ItemProperty  $FileList | select FullName).FullName
			#Write-Host -ForegroundColor Green "[74]Processing:" $Path 
			 #ProcessFile -Path $Path
			}
		Else  #System.Array
		{
			#System.Array
			#Write-Host -ForegroundColor Green "[33] type.BaseType.FullName:" $type.BaseType.FullName
			<#
			ForEach($item in $FileList.GetEnumerator())
			{
				Write-Host -ForegroundColor Cyan -BackgroundColor Black "[83] FOLDER $item"
			}
			For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" } Else{ Write-Host -ForegroundColor Cyan -BackgroundColor Black "=" -NoNewline}}
			#>
			#get # of folders and files:
			 #$FolderCount = (Get-ChildItem -Path $TemplateDir -Recurse -Directory | Measure-Object).Count
			#$FileCount = (Get-ChildItem -Path $TemplateDir -Recurse -File | Measure-Object).Count
			#Write-Host -ForegroundColor Cyan "[91] $TemplateDir FolderCount = $FolderCount"
			#Write-Host -ForegroundColor Cyan "[92] $TemplateDir FileCount = $FileCount"
			#debug
			#$RootFolder
			#$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')

			$i = 0
			ForEach($item in $FileList.GetEnumerator())
			 {
				 #Write-Host -ForegroundColor Yellow "`n================================================================================"
				#Write-Host -ForegroundColor Yellow "[$i] ForEach(item in FileList):" (Get-ItemProperty  $item).FullName
				$Path = (Get-ItemProperty  $item | select FullName).FullName
				#Write-Host -ForegroundColor Cyan "`$Path=`"$Path`""

				 #$childItem = Get-ChildItem -Path $Path.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum
				$isDir = (Get-Item $Path) -is [System.IO.DirectoryInfo]
				If($isDir)
				{
					$dirs = Get-ChildItem -Path $Path -Recurse | Sort-Object
					#Write-Host -ForegroundColor DarkBlue -BackgroundColor White "[105] Processing file $Path"

					Foreach ($File In $dirs)
					{
						$FilePath =  $File.FullName
						 $FileName = $File.Name
						$FileNameBase = $File.BaseName
						$Extension = $File.Extension
						$BackUpFolder = ""
						$DirectoryName = $File.Directory.BaseName
						$FilePath = $File.FullName
						$EnvFileBackUp = $DirectoryName + $FileName
						$EnvFolder = $EnvFilePath = $null

		
	
						 <#If($debugFlag)
						{
							Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`""
							Write-Host -ForegroundColor Cyan "`$DeployObject.Solution=`"$DeployObject.Solution`""
							Write-Host -ForegroundColor Cyan "`$DirectoryName=`"$DirectoryName`""
							Write-Host -ForegroundColor Cyan "`$FileName=`"$FileName`""
							Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`"" 
							 Write-Host -ForegroundColor Cyan "`$DirectoryName=`"$DirectoryName`""
							Write-Host -ForegroundColor Cyan "`$DeployObject.Solution=" $DeployObject.Solution
							Write-Host -ForegroundColor Cyan "`$DirectoryName=`"$DirectoryName`""
							Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`""
							Write-Host -ForegroundColor Green "`$FileName=`"$FileName`""
							Write-Host -ForegroundColor Green "`$FileNameBase=`"$FileNameBase`""
							Write-Host -ForegroundColor Green "`$Extension=`"$Extension`""
							Write-Host -ForegroundColor Green "`$EnvFileBackUp=`"$EnvFileBackUp`""
						}
						 #>
						<#
						$File = Get-Item $FilePath

						$File = ((Get-ItemProperty  $Path | select FullName).FullName).Split("\")
						$File = ((Get-ItemProperty  $FilePath | select FullName).FullName).Split("\")
						$FileNameSplit = $File.Split("\")
						$File = $FileNameSplit.Get($FileNameSplit.Count-1)
						$DirectoryName = (Get-ItemProperty  $FilePath).Directory.Name
						#>
						 If($DirectoryName -eq "DTP")
						{
							#C:\GitHub\dtp\Sites\packages\DTP
							#Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[218]DTP: `$FileName=`"$FileName`""
		
							 Switch($FileName)
							{
								.env
								{
									 $EnvFolder = $RootFolder + "Sites\packages\DTP"
									$EnvFilePath = $EnvFolder + "\" +  $FileName
									If($debugFlag)
									{
										Write-Host -ForegroundColor Green "CreateEnvironmentFiles[248]; DirectoryName -eq DTP "
										Write-Host -ForegroundColor Green "`$EnvFolder=`"$EnvFolder`"" 
										Write-Host -ForegroundColor Green "`$EnvFilePath=`"$EnvFilePath`""
									}
									#>
								}
								<#
								.env.development.local
								{
									$EnvFolder = $RootFolder + "Sites\packages\DTP"
									$EnvFilePath = $EnvFolder + "\" +  $FileName
									#Write-Host -ForegroundColor White "`$EnvFolder=`"$EnvFolder`""
									#Write-Host -ForegroundColor Yellow "[139] `$EnvFilePath=`"$EnvFilePath`""
		
								 }
								.env.local
								{
									$EnvFolder = $RootFolder + "Sites\packages\DTP"
									$EnvFilePath = $EnvFolder + "\" +  $FileName
									#Write-Host -ForegroundColor White "`$EnvFolder=`"$EnvFolder`""
									#Write-Host -ForegroundColor Yellow "[139] `$EnvFilePath=`"$EnvFilePath`""
		
								 }#>
								local.settings.json
								{
									$EnvFolder = $RootFolder + "API\dtpapi" 
									$EnvFilePath = $EnvFolder + "\" + $FileName 
									 $EnvFileBackUp = $DirectoryName + "." + $FileName
									 <#
									Write-Host -ForegroundColor Yellow "[255] local.settings.json"
									Write-Host -ForegroundColor Yellow "`$EnvFolder=`"$EnvFolder`""
									Write-Host -ForegroundColor Yellow "`$EnvFilePath=`"$EnvFilePath`""
									#>
								}
								Default {
									break
									#Write-Host -ForegroundColor white "[254]DTP: `$FileName=`"$FileName`""
								}
							}#switch FileName
						 }#If($DirectoryName -eq "DTP")
						#>
						<#Else
						{
							Write-Host -ForegroundColor Red "`$DirectoryName=`"$DirectoryName`""
							Write-Host -ForegroundColor Red "DeployObject.Solution=" $DeployObject.Solution
							Write-Host -ForegroundColor Red "EnvFilePath -ne null=" ($EnvFilePath -ne $null)
		
						 }#>
		
						 If ( $EnvFilePath -ne $null )
						{
							#Write-Host -ForegroundColor Yellow "`nCreateEnvironmentFiles[302] "
							#Write-Host -ForegroundColor Cyan "`$EnvFilePath=`"$EnvFilePath`""
							#Write-Host -ForegroundColor Cyan "`$EnvFolder=`"$EnvFolder`""
					
							 If( (Test-Path $EnvFilePath) -eq $false)
							{
								$EnvFile = New-Item -Path $EnvFolder -Name $FileName -ItemType File
							}
							Else
							{
								<#
								Write-Host -ForegroundColor Magenta "`$EnvFolder=`"$EnvFolder`"" 
								Write-Host -ForegroundColor Magenta "`$EnvFilePath=`"$EnvFilePath`""
								Write-Host -ForegroundColor Magenta "`$FileName=`"$FileName`""
								Write-Host -ForegroundColor Magenta "[272] Removing and re-creating env file:" $EnvFilePath
								#>
								Remove-Item -Path $EnvFilePath
								$EnvFile = New-Item -Path $EnvFolder -Name $FileName -ItemType File
								#Write-Host -ForegroundColor GREEN "[279] CREATED NEW env file:" $EnvFile.FullName
							}
		
							 #Write-Host "[144] Created new env file:" $EnvFile.FullName
							#Write-Host "`$EnvFile=`"$EnvFile`""
							<#
							$json = ConvertTo-Json $DeployObject
							Write-Host -ForegroundColor Green "`$DeployObject =@'"
							Write-Host -ForegroundColor Green "["
							$json
							Write-Host -ForegroundColor Green "]"
							Write-Host -ForegroundColor Green "'@"
		
							 Write-Host -ForegroundColor Yellow "`n================================================================================"
							$cloudjson = ConvertTo-Json $Cloud 
							 Write-Host -ForegroundColor Cyan "`$Cloud =@'"
							Write-Host -ForegroundColor Cyan "["
							$cloudjson
							Write-Host -ForegroundColor Cyan "]"
							Write-Host -ForegroundColor Cyan "'@"

							#Write-Host "}"
		
							 #PrintHash -Object $cloudjson
							#Write-Host -ForegroundColor Yellow "`n================================================================================"
							#>
							$envObject = ProcessFile `
											-Path $FilePath `
											-EnvFile $EnvFilePath `
											-DeployObject $DeployObject
											#-Cloud $Cloud
											#-DeploymentOutput $DeploymentOutput

						} #env file not null
		
	
						 #debug:
						<#If($debugFlag)
						{
							$dtpResources = "C:\GitHub\dtpResources"
							$currMonth =  Get-Date -Format 'MM'
							$MonthFolderPath = $dtpResources + "\" +  $currMonth
							#Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[251] MonthFolderPath="  $MonthFolderPath
							$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
							$TodayFolderPath = $MonthFolderPath + "\" +  $TodayFolder
							$EnvFilePathBackUp = $TodayFolderPath + "\" + $EnvFileBackUp
							#Write-Host -ForegroundColor Magenta "[250] `$EnvFilePath=`"$EnvFilePath`"" 
							#Write-Host -ForegroundColor Green "[251] `$EnvFilePathBackUp=`"$EnvFilePathBackUp`""
							#Write-Host "CreateEnvironmentFiles[254] Copying $EnvFilePath to $EnvFilePathBackUp"
							Copy-Item $EnvFilePath $EnvFilePathBackUp
							#WriteJsonFile -FilePath $Path -CustomObject $envObject
						}#>
					}#Foreach

				}#isDir
				<#Else
				{
					Write-Host -ForegroundColor Yellow "[117] $Path"
					#$envObject = ProcessFile -Path $Path
				}#Else file
				#>

				 #Write-Host -ForegroundColor Green "Processing:" $Path
				#Write-Host -ForegroundColor Cyan "$Path"
				#$Content = Get-Content $Path | Out-String
				#Write-Host -ForegroundColor Yellow "================================================================================`n"


			 }# ForEach($item in $FileList

		}#Else  #System.Array

			#PrintObject -Object $DeployObject -Caller $EnvFilePath
		#PrintObject -Object $envObject -Caller $EnvFilePath 
		#$FullPath = Get-ChildItem -Path $TemplateDir | select FullName
		#Write-Host -ForegroundColor Yellow "CreateEnvironmentFiles[10] FullPath: " $FullPath.FullName 
		#$Content = Get-Content $DeployObject.OutFileJSON | Out-String
		#Write-Host $Content

	}
}#CreateEnvironmentFiles


Function global:ProcessFile
{
	Param(
		[Parameter(Mandatory = $true)] [String] $Path
		,[Parameter(Mandatory = $true)] [String] $EnvFile
		,[Parameter(Mandatory = $true)] [Object] $DeployObject
	)

	$Message = "START Writing the .env file at:" + $EnvFile
#
If($debugFlag)
{
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor DarkBlue -BackgroundColor White "`n[$today] STARTING CreateEnvironmentFiles.ProcessFile[410]"
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount 
	#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
}
Else
{
	$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
	#PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
}

	<#
	$json = ConvertTo-Json $DeployObject
	Write-Host -ForegroundColor Green "`$DeployObject =@'"
	Write-Host -ForegroundColor Green "["
	$json
	Write-Host -ForegroundColor Green "]"
	Write-Host -ForegroundColor Green "'@"
		
	Write-Host -ForegroundColor Yellow "`n================================================================================"
	$cloudjson = ConvertTo-Json $Cloud  
	Write-Host -ForegroundColor Cyan "`$Cloud =@'"
	Write-Host -ForegroundColor Cyan "["
	$cloudjson
	Write-Host -ForegroundColor Cyan "]"
	Write-Host -ForegroundColor Cyan "'@"
	#>

	$i = 0
	$File = ((Get-ItemProperty  $Path | select FullName).FullName).Split("\")
	$FileNameSplit = $File.Split("\")
	$File = $FileNameSplit.Get($FileNameSplit.Count-1)
	$DirectoryName = (Get-ItemProperty $Path).Directory.Name
	$FilePath = (Get-ItemProperty $Path).FullName
	$Extension = (Get-ItemProperty  $Path).Extension

	<#
	Write-Host -ForegroundColor Magenta "CreateEnvironmentFiles.ProcessFile[415] `$File=`"$File`""
	Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[416] `$DirectoryName=`"$DirectoryName`""
	Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[417] `$FilePath=`"$FilePath`""
	Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[418] `$Extension=`"$Extension`""
	#Write-Host -ForegroundColor Magenta "[112] FileGetType="$File.GetType()
	#>
	#C:\GitHub\dtpResources\rg-dts-prod-lt\DeployedEnvironments\Prod\LocalSetup
	

	If($Extension.Contains('env'))
	{
		ForEach($line in Get-Content $FilePath)
		{
			 If ($line)
			{

				 #Write-Host "[39][$i] line.length: " $line.Length
				$firstChar = $line.substring(0, 1)
				If($firstChar -ne "#")
				{
					#Write-Host -ForegroundColor White $line
					$envVar = $line.Split("=")[0]
					$envValue = $line.Split("=")[1]
					 $lineOut = $envVar + "=" + $envValue
					#Write-Host -ForegroundColor White $envVar "=`$DeployObject."
					#Write-Host -ForegroundColor White $envVar
					#Write-Host -ForegroundColor Yellow $envValue
					#Write-Host -ForegroundColor Yellow $lineOut
					If($DirectoryName -eq "DPP")
					{
						Switch($File)
						{
							.env
							{
								#Write-Host -ForegroundColor Cyan $envVar" = " + $DPPEnvObject.$envVar
								#$lineOut = "$envVar=" + $DPPEnvObject.$envVar + "`n"
		
								#[System.IO.File]::AppendAllText($EnvFile, "$envVar=" + $DPPEnvObject.$envVar + "`r`n", [System.Text.Encoding]::UTF8)
								#[System.IO.File]::AppendAllText($EnvFile, "`r`n", [System.Text.Encoding]::UTF8)
								#$lineOut = "$envVar=" + $DPPEnvObject.$envVar + "`r`n"
								#$lineOut = "$envVar=" + $DPPEnvObject.$envVar + [Char]10 + [Char]13
								#$lineOut >> $EnvFile
								"$envVar=" + $DPPEnvObject.$envVar  +"`r`n" | Out-File -FilePath $EnvFile -Append -Encoding default
								#WriteJsonFile -FilePath $Path -CustomObject $envObject
							 }
							<#.env.development.local
							{
								#Write-Host -ForegroundColor White $line
								$line  + "`n" >> $EnvFile
								#Write-Host -ForegroundColor Yellow $line 
								 #Write-Host -ForegroundColor White $envVar
								#Write-Host -ForegroundColor Yellow $envValue
		
							 }#>
							local.settings.json
							{
								#Write-Host -ForegroundColor Green $line
								#$line  >> $EnvFile
							}
							<#Default {
							}#>
						}#switch

					 }#If($DirectoryName -eq "DPP")

					elseif($DirectoryName -eq "DTP")
					{
						Switch($File)
						{
							.env
							{
								 #Write-Host -ForegroundColor White  $envVar" = " + $DTPEnvObject.$envVar
								#$lineOut = $envVar + "=" + $DTPEnvObject.$envVar  + "`n"
								#$lineOut = $envVar + "=" + $DTPEnvObject.$envVar  + "`r`n"
								#$lineOut = "$envVar=" + $DTPEnvObject.$envVar + [Char]10 + [Char]13
								#"$envVar=" + $DTPEnvObject.$envVar + "`r`n" | Out-File -FilePath $EnvFile -Append
		
								#[System.IO.File]::AppendAllText($EnvFile, "$envVar=" + $DTPEnvObject.$envVar + "`r`n", [System.Text.Encoding]::UTF8)
								#[System.IO.File]::AppendAllText($EnvFile, "`r`n", [System.Text.Encoding]::UTF8)
								"$envVar=" + $DTPEnvObject.$envVar  +"`r`n"  | Out-File -FilePath $EnvFile -Append -Encoding default
								#$lineOut >> $EnvFile
							}
							 <#.env.local
							{ 
								 #Write-Host -ForegroundColor Yellow $line 
								 #Write-Host -ForegroundColor White $envVar
								#Write-Host -ForegroundColor Yellow $envValue
								$line  + "`n" >> $EnvFile

							}#>
							local.settings.json
							{
								#$line  >> $EnvFile
								#Write-Host -ForegroundColor Yellow $line 
								 #Write-Host -ForegroundColor White $envVar
								#Write-Host -ForegroundColor Yellow $envValue
							}
		
							 Default {
							}
						}#switch

					 } #If($DirectoryName -eq "DTP")

				 }
				Else
				{
					#Write-Host -ForegroundColor Green $line
					#$line  >> $EnvFile
					#[System.IO.File]::AppendAllText($EnvFile, "$line" +"`r`n", [System.Text.Encoding]::UTF8)
					"$line"| Out-File -FilePath $EnvFile -Append -Encoding default
				}#>
				#Write-Host "[41][$i] firstChar: "$firstChar
				#>
			 }#If(line)

			$i++
		}#ForEach($line in Get-Content $Path)

	}#If extension is .env

	<#ElseIf($Extension.Contains('json')) #Json
	{
		If($debugFlag)
		{
			Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles.ProcessFile[554] Process JSON "
			Write-Host -ForegroundColor Cyan "`$FilePath=`"$FilePath`""
		}
		$json = Get-Content $FilePath | Out-String | ConvertFrom-Json

			If($debugFlag)
		{
			$dtpResources = "C:\GitHub\dtpResources"
			$currMonth =  Get-Date -Format 'MM'
			$MonthFolderPath = $dtpResources + "\" +  $currMonth
 
			 Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[446]"
			Write-Host -ForegroundColor Cyan "`$MonthFolderPath=`"$MonthFolderPath`""
 
			 $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')

			$JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"
			$LocalSettingsFileName = "JsonProps.txt"
			$LocalSettingsFilePath = $MonthFolderPath + "\" +  $TodayFolder + "\"
			 BuildLocalSettingsFile `
				-JsonFilePath $JsonFilePath `
				-LocalSettingsFilePath $LocalSettingsFilePath `
				-LocalSettingsFileName $LocalSettingsFileName `
				-DeployObject $DeployObject
				# -Cloud $Cloud 
			 #PrintObject -Object $json
			#$json
		}#debugFlag

		

	}#extension is .json
	#>

	return $envObject
}#ProcessFile

