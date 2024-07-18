
#RemoveAppRegistration.ps1
#C:\GitHub\PowerShellGoodies\CleanUpResources.ps1
<#
This script removes app registrations, 
either Owned ones or specified by name
#>



Function global:CleanUpResources{
 Param(
	 [Parameter(Mandatory = $true)] [String] $OwnedApplication
	,[Parameter(Mandatory = $false)] [Boolean] $LogFilesOnly
	,[Parameter(Mandatory = $true)] [String] $ParentFolder
	,[Parameter(Mandatory = $false)] [Boolean] $RemoveRG
	,[Parameter(Mandatory = $false)] [String] $ResourceGroup
 )
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	#Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START CleanUpResources "
	Write-Host -ForegroundColor Cyan "`n================================================================================"
	Write-Host -ForegroundColor Cyan "[$today] STARTING CleanUpResources ... Remove Owned App Registrations and Log files..."
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`PARAMETERS: " 
	Write-Host -ForegroundColor Yellow "[18] `$OwnedApplication=`""$OwnedApplication "`""
	Write-Host -ForegroundColor Yellow "[18] `$LogFilesOnly=`""$LogFilesOnly "`""
	Write-Host -ForegroundColor Yellow "[19] LogFilesOnly.Length=" $LogFilesOnly.Length

	If($LogFilesOnly.Length -eq 0){$LogFilesOnly=$false}

	Connect-AzAccount -Environment AzureUSGovernment

	$AzureContext = Get-AzContext
	$Subscription = $AzureContext.Subscription.Name
	$SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId 
	$TenantName = $SubscriptionTenant.Name
	$TenantId = $SubscriptionTenant.Id

	Write-Host -ForegroundColor Yellow "[29] Subscription : " $Subscription
	Write-Host -ForegroundColor Yellow "[29] SubscriptionTenant : " $SubscriptionTenant
	Write-Host -ForegroundColor Yellow "[29] SubscriptionTenant : " $TenantName
	Write-Host -ForegroundColor Yellow "[29] SubscriptionTenant.Id : " $TenantId

	$i = 0
	if($OwnedApplication -eq $true -and $LogFilesOnly -eq $false)
	{
		$AdApplications = Get-AzADApplication -OwnedApplication
		Write-Host -ForegroundColor Magenta "[] AppReg count: " $AdApplications.Count
		Write-Host -ForegroundColor Magenta "[] Subscription: " $Subscription
		foreach($appreg in $AdApplications)
		{
			$i++
			if ($Subscription -eq "BMA-05")
			{
				#If( $appreg.DisplayName -like 'kat*')
				#{
				#Write-Host 'RemoveAppRegistration[$i] $appreg.DisplayName does not start with Data"'
				#Remove-AzADApplication -ObjectId $appreg.Id
				if( -not (
					#$appreg.DisplayName -like '*dtp*' -or `
					#$appreg.DisplayName -like '*dts*' -or `
					#$appreg.DisplayName -like '*dpp*' -or `
					$appreg.DisplayName -eq "DtsPickupDev"  -or `
					$appreg.DisplayName -eq "DtsPickupDevAPI"  -or `
					$appreg.DisplayName -eq "DtsPickupTest"  -or ` 
					 $appreg.DisplayName -eq "DtsPickupTestAPI"  -or `

					$appreg.DisplayName -eq "DtsTransferDev"  -or `
					$appreg.DisplayName -eq "DtsTransferDevAPI"  -or `
					$appreg.DisplayName -eq "DtsTransferTest"  -or ` 
					 $appreg.DisplayName -eq "DtsTransferTestAPI"  -or `
		
					 $appreg.DisplayName -eq "Graph"
					) #-eq $false
				)
				{
					Remove-AzADApplication -ObjectId $appreg.Id
					Write-Host -ForegroundColor Red "[$i] Deleted:"$appreg.DisplayName"; ObjectId="$appreg.AppId
				}
				else
				{
					Write-Host -ForegroundColor Green "[$i] KEEPING:"$appreg.DisplayName"; ObjectId="$appreg.AppId
				}
				#Remove-AzADServicePrincipal -DisplayName $appreg.DisplayName
				#Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id
				 #Write-Host -ForegroundColor Red  -BackgroundColor White "[$i] Deleted AzADServicePrincipal:" $appreg.DisplayName"; ObjectId=" $appreg.AppId
				#}
			}

			 elseif($Subscription -eq "jaiFairfax")
			{
				#if($appreg.DisplayName -like '*Data*' )# -or $appreg.DisplayName -like 'depguide*')
				#$appreg.DisplayName -like '*Data*' -or
				if( ($appreg.DisplayName).StartsWith('Data') )
				{
					 #Write-Host -ForegroundColor Red "[$i]" $appreg.DisplayName " starts with 'Data'"
					 Write-Host -ForegroundColor Cyan -BackgroundColor Black "[78][$i]" $appreg.DisplayName"; AppId=" $appreg.AppId
				}
				else
				{
					#If( $appreg.DisplayName -like 'kat*')
					#{
					#Write-Host 'RemoveAppRegistration[84][$i] $appreg.DisplayName does not start with Data"'
					Remove-AzADApplication -ObjectId $appreg.Id
					Write-Host -ForegroundColor Red "[86][$i] Deleted AzADApplication: " $appreg.DisplayName"; ObjectId=" $appreg.AppId
					#Remove-AzADServicePrincipal -DisplayName $appreg.DisplayName
					#Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id
					 #Write-Host -ForegroundColor Red  -BackgroundColor White "[$i] Deleted AzADServicePrincipal:" $appreg.DisplayName"; ObjectId=" $appreg.AppId
					#}
				}	
			}#elseif			

			<#
			if($appreg.DisplayName -like '*Data*' )# -or $appreg.DisplayName -like 'depguide*')
			{
				 #Write-Host -ForegroundColor Red "[$i]" $appreg.DisplayName " starts with 'Data'"
				 Write-Host -ForegroundColor Green -BackgroundColor Black "[97][$i]" $appreg.DisplayName"; AppId=" $appreg.AppId
			}
			#if ($Subscription -ne "jaiFairfax")
			#{
				#If( $appreg.DisplayName -like 'kat*')
				#{

				 #}
			#}

			 else
			{
				Write-Host -ForegroundColor Yellow -BackgroundColor Black "[109][$i]" $appreg.DisplayName"; AppId=" $appreg.AppId
				#Write-Host 'RemoveAppRegistration[$i] $appreg.DisplayName does not start with Data"'
				#Remove-AzADApplication -ObjectId $appreg.Id
				#Write-Host -ForegroundColor Red "[$i] Deleted AzADApplication: " $appreg.DisplayName"; ObjectId=" $appreg.AppId
				#Remove-AzADServicePrincipal -DisplayName $appreg.DisplayName
				#Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id
				 #Write-Host -ForegroundColor Red  -BackgroundColor White "[$i] Deleted AzADServicePrincipal:" $appreg.DisplayName"; ObjectId=" $appreg.AppId
			}	
			#>
		}
	}

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED RemoveAppRegistration " 
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "[$today] FINISHED RemoveAppRegistration ..."
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "[$today] STARTING DeleteLogFiles ..."
	Write-Host -ForegroundColor Cyan "================================================================================"
	#Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START DeleteLogFiles FOR $ParentDirPath "

	if (Test-Path $ParentFolder)
	{
		Write-Host -ForegroundColor Cyan "[17] EXISTING $ParentFolder ParentFolder"
		$ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

		Write-Host -ForegroundColor Cyan "[20] ParentFolder: $ParentFolder"
		Write-Host -ForegroundColor Cyan "[21] FullPath:"  $ParentFolderPath

		$dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object
		$FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
		$FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
		Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "
		Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
		$i = 0
		$j = 0

		Foreach ($file In $dirs)
		{ 

			 $FullPath =  $file.FullName
			$FileName = $file.BaseName
			 $ParentFolder = Split-Path (Split-Path $file.FullName -Parent) -Leaf
			$DirectoryPath = $file.DirectoryName
			$Extension = $file.Extension
			 $LastWriteTime = $file.LastWriteTime
			$LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
			$FullFileName = Split-Path $file.FullName -Leaf -Resolve

			 $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
			$subFolder = Get-ChildItem -Path $file.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum
			# Set default value for addition to file name

			Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[$i] FILE FullFileName: $FullFileName "
			 Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] FILE FullPath: $FullPath "

			 Remove-Item -Path $FullPath
			$i++
 
			}#foreach
		Write-Host -ForegroundColor Cyan "================================================================================"
			Write-Host -ForegroundColor Cyan "[$today] FINISHED DeleteLogFiles ..."
			Write-Host -ForegroundColor Cyan "================================================================================"
	}#if

	#>

	<#if($removeRG)
	{
		$today = Get-Date -Format "MM/dd/yyyy"
		#Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED DeleteLogFiles FOR $ParentDirPath "

		Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START Removing ResourceGroups "
		#Remove-AzResourceGroup -Name $ResourceGroup -Force

		#$myResourceGroups = Get-AzResourceGroup | Where-Object {$_.Tags.DeployDate -eq $today -and $_.Tags.DeployedBy -eq 'Kat Hopkins'}
		$myResourceGroups = Get-AzResourceGroup | Where-Object {$_.Tags.DeployedBy -eq 'Kat Hopkins'}

			Write-Host -ForegroundColor Cyan "myResourceGroups.Count=" $myResourceGroups.Count
		Foreach ($item In $myResourceGroups)
		{
			$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
			 $ResourceGroupName = $item.ResourceGroupName
			$resources = Get-AzResource -ResourceGroupName $ResourceGroupName | Where-Object {$_.Tags.DeployedBy -eq 'Kat Hopkins'}
			Write-Host -ForegroundColor Cyan $resources.Count
			Write-Host -ForegroundColor Yellow "$StartTime Removing Resources from RG=" $ResourceGroupName
			Foreach($resource in $resources)
			{
				If( -not ($resource.Name).StartsWith('kv') )
				{
					Write-Host "[199] resource" $resource.Name
					Remove-AzResource -ResourceName $resource.Name -Force
				}
				else
				{
					Write-Host -ForegroundColor Red "[204] KEYVAULT :" $resource.Name
				}

			 }
			 #Remove-AzResourceGroup -Name $ResourceGroupName -Force
			$EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
			$Duration = New-TimeSpan -Start $StartTime -End $EndTime
			#Write-Host -ForegroundColor Red "$EndTime DELETED ResourceGroup="$ResourceGroupName "Duration:" $Duration
		}
	}#if removeRG
	#>
	#Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED Removing ResourceGroup $ResourceGroup "

	#Write-Host -ForegroundColor Green -BackgroundColor Black "`n [$today] FINISHED CleanUpResources " 
	#$DisconnectState = $Disconnect = Disconnect-AzAccount
	
} #CleanUpResources

$today = Get-Date -Format 'ddd'   
$Environment = "test"
$Location = "usgovvirginia"
#$AppName = $today + "Site"
$ResourceGroup += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment)
$LogFilesOnly = $true
$LogFilesOnly = $false

$RemoveRG = $true
$RemoveRG = $false

$ParentFolder = 'C:\GitHub\dtp\Deploy\logs'
#$ParentFolder = 'C:\Users\kahopkin\source\repos\MainBranch\Deploy\logs'
#CleanUpResources -OwnedApplication $true -ParentFolder $ParentFolder -ResourceGroup $ResourceGroup
CleanUpResources `
	-OwnedApplication 'true' `
	-ParentFolder $ParentFolder `
	-LogFilesOnly $LogFilesOnly `
	-RemoveRG $RemoveRG `
	-ResourceGroup $ResourceGroup
	
#& "$PSScriptRoot\RemoveOrphanRoleAssignments.ps1"
#RemoveOrphanRoleAssignments


	<#$i=0
	Write-Host -ForegroundColor Green "`n[53] AppName.length=" $AppName.Length
	if($AppName.Length -ne 0 )
	{
		Write-Host -ForegroundColor Green "[56] AppName= $AppName"

			$AdApplications = Get-AzADApplication -DisplayName $AppName 
		Write-Host -ForegroundColor Yellow "[60] CleanUpResources[50] AppReg count:" $AdApplications.Count

			foreach($appreg in $AdApplications)
		{
			$i++
			 #Remove-AzADApplication -ObjectId $appreg.id
			Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id
		}
	}
	else
	{
		Write-Host 'CleanUpResources[71] AppName is null'
	}
	#>
	