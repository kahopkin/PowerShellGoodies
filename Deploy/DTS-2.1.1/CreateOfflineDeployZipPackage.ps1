#CreateZip
Function global:CreateZip
{
	Param(
		[Parameter(Mandatory = $true)] [String]$DestinationPath
		,[Parameter(Mandatory = $true)] [String]$RootFolder
		,[Parameter(Mandatory = $false)] $CompressList
	)
	If($debugFlag){
	Write-host -ForegroundColor Yellow  "`$RootFolder=`"$RootFolder`""
	Write-host -ForegroundColor Yellow  "`$DeployFolder=`"$DeployFolder`""
	Write-host -ForegroundColor Yellow  "`$DestinationPath=`"$DestinationPath`""
	}#>

	$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
 
	#$DestinationPath = "C:\GitHub\dtp\deployDTS_Clients.Zip"
	#$RootFolder = "C:\GitHub\dtp"
	if($CompressList.Count -eq 0)
	{
		$CompressList = @(
		"$RootFolder" + "\build"
		"$RootFolder" + "\Deploy"
		"$RootFolder" + "\Docs"
		"$RootFolder" + "\Sites"
		"$RootFolder" + "\wiki"
		"$RootFolder" + "\.gitignore"
		"$RootFolder" + "\.gitmodules"
		"$RootFolder" + "\CODEOWNERS" 
		"$RootFolder" + "\README.md"
		"$RootFolder" + "\SECURITY.md"
		)
	}

	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Yellow "================================================================================"
	Write-Host -ForegroundColor Yellow "[$today] START CREATE ZIP:" $DestinationPath
	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Green "RootFolder: " $RootFolder
	Write-Host -ForegroundColor Green "Zip DestinationPath:" $DestinationPath
	Write-Host -ForegroundColor Green "CompressList.Count: " $CompressList.Count
	Write-Host -ForegroundColor Green "CompressList:"

	foreach($item in $compressList.GetEnumerator())
	{
		Write-Host -ForegroundColor Cyan -BackgroundColor Black $item
	}
	Write-Host -ForegroundColor Yellow "================================================================================"

	foreach($item in $compressList.GetEnumerator())
	{
		#Write-Host -ForegroundColor Green "`n[46]" $item
		$Path = (Get-ItemProperty  $item | select FullName).FullName
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[28] Path:" $Path
		$isDir = (Get-Item $Path) -is [System.IO.DirectoryInfo]
		#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[30] isDir:" $isDir 
			if($Path -ne $DestinationPath)
		{

			#$childItem = Get-ChildItem -Path $DestinationPath.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum
			# Set default value for addition to file name
			$dirs = Get-ChildItem -Path $path -Recurse | Sort-Object
			Foreach ($dir In $dirs)
			{ 
				 $FullPath =  $dir.FullName
				$FileName = $dir.BaseName
				 $ParentFolder = Split-Path (Split-Path $dir.FullName -Parent) -Leaf
				$Extension = $dir.Extension
				#'Extension: ' + $Extension
				$LastWriteTime = $dir.LastWriteTime
				$LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
				$FullFileName = Split-Path $dir.FullName -Leaf -Resolve

				 #debugline:
				#$FullFileName +" - "+$LastWriteTime

				$isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
				$subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum
				# Set default value for addition to file name
				$Size = $subFolder.sum
				$SizeKB =  "{0:N2}"-f ($Size / 1KB) + " KB"
				$SizeMB =  "{0:N2}"-f ($Size / 1MB) + " MB"
				$SizeGB =  "{0:N2}"-f ($Size / 1GB) + " GB"
				if($isDir)
				{ 
					#Write-Host -ForegroundColor Magenta "[$33] Path: $Path "
					 #Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
					 if(Test-Path $DestinationPath)
					{
						Write-Host -ForegroundColor Yellow -BackgroundColor Black "$Path; SizeKB:$SizeKB | SizeMB:$SizeMB"
						Compress-Archive -Path $Path -Update -DestinationPath $DestinationPath
						#Get-ChildItem -Path $Path -Recurse | Compress-Archive -Update -DestinationPath $DestinationPath
					}
					else
					{
						#Write-Host -ForegroundColor Magenta -BackgroundColor Black "[63] Path: " $Path
						Write-Host -ForegroundColor Yellow -BackgroundColor Black "$Path; SizeKB:$SizeKB | SizeMB:$SizeMB"
						#Get-ChildItem -Path $Path -Recurse | Compress-Archive -DestinationPath $DestinationPath
						Compress-Archive -Path $Path -DestinationPath $DestinationPath
					}
				 }
				else
				{
					#Write-Host -ForegroundColor Cyan "[$i] FILE Path: $Path "
					 if(Test-Path $DestinationPath)
					{
						#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[72]Path: " $Path
						Write-Host -ForegroundColor Yellow -BackgroundColor Black "$Path; SizeKB:$SizeKB | SizeMB:$SizeMB"
						#Get-ChildItem -Path $Path | Compress-Archive -Update  -DestinationPath $DestinationPath
						Compress-Archive -Path $Path -Update  -DestinationPath $DestinationPath
					}
					else
					{
						#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[77] Path: " $Path
						Write-Host -ForegroundColor Yellow -BackgroundColor Black "$Path; SizeKB:$SizeKB | SizeMB:$SizeMB"
						#Get-ChildItem -Path $Path | Compress-Archive  -DestinationPath $DestinationPath
						Compress-Archive -Path $Path -DestinationPath $DestinationPath
					}
					#Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
				}
		} #Foreach ($dir In $dirs)
		}#if not itself the zip being built
	}

	$EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

	$Duration = New-TimeSpan -Start $StartTime -End $EndTime
	$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
	Write-Host -ForegroundColor Yellow "================================================================================"
	Write-Host -ForegroundColor Yellow "[$today] FINISHED CREATE ZIP:" $DestinationPath 
	Write-Host -ForegroundColor Yellow "================================================================================"

	Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "[$today] COMPLETED ZIP "
	Write-Host -ForegroundColor Cyan "DURATION [HH:MM:SS]:" $Duration
	Write-Host -ForegroundColor Cyan "================================================================================"  

}#CreateZip

$RootFolder = "C:\GitHub\dtp"
#$DestinationPath = "$RootFolder" + "\deployDTS_Clients.Zip"
$DestinationPath = "C:\GitHub\dtpOfflineDeploy\deployDTS_Clients.Zip"
#CreateZip #-RootFolder $RootFolder -DestinationPath $DestinationPath -CompressList @CompressList
		



	<#
	$compressList = @(
	"$RootFolder" + "\Deploy"
	"$RootFolder" + "\README.md"
	"$RootFolder" + "\SECURITY.md"
	)
	#>