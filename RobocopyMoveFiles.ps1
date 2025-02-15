﻿<#
#>



Function global:RobocopyMoveFiles
{
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n *************[$today] START RobocopyMoveFiles *****************"
	<#Write-Host -ForegroundColor White -BackgroundColor Black "Source= " $Source 	
	#Write-Host -ForegroundColor Magenta -BackgroundColor Black 
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "to $Destination *****************"
	#>

	Write-Host -ForegroundColor Yellow "`$Source=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Source`""
	#get # of folders and files:
	$FolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
	$FileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count
	
	Write-Host -ForegroundColor Yellow "`$FolderCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FolderCount`""

	Write-Host -ForegroundColor Yellow "`$FileCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FileCount`""

	Write-Host -ForegroundColor Yellow "`$Destination=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Destination`""	
 
	$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy-HH-mm-ss')
	$SourceFolder = Get-Item -Path $Source
	$LogFile = $TodayFolderPath = $Destination + "\" + $TodayFolder + "_" + $SourceFolder.Name + ".log"


	$SourceFolderNameArr = $Source.split("\")
	$SourceFiolderName = $SourceFolderNameArr[$SourceFolderNameArr.Count-1]
	$DestinationFolder = $Destination + "\" + $SourceFiolderName

	If( (Test-Path $DestinationFolder) -eq $false)
	{
		$DestinationFolder = (New-Item -Path $Destination -Name $SourceFiolderName -ItemType Directory).FullName
		#$Destination = New-Item -Path $Destination -Name $SourceFiolderName -ItemType Directory
		$Destination = $DestinationPath = $MonthFolder.FullName
		Write-Host -ForegroundColor Green "CREATED DESTINATION FOLDER:"
		Write-Host -ForegroundColor White "`$DestinationFolder=" -NoNewline
		Write-Host -ForegroundColor Yellow "`"$DestinationFolder`""

		Write-Host -ForegroundColor Cyan "`$DestinationPath=" -NoNewline
		Write-Host -ForegroundColor Yellow "`"$DestinationPath`""
	}



	<# To move all files and folders, including empty ones, with all attributes. 
	 #Note that the source folder will also be deleted.
	 robocopy c:\temp\source c:\temp\destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3
	 #>

	robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3 /LOG:$LogFile
	#robocopy $Source $Destination /E /COPYALL /COPY:DAT /MOVE /R:100 /W:3 /LOG:$LogFile
	#robocopy $Source $Destination /COPYALL /COPY:DAT /MOVE /R:100 /W:3
	#robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /MOVE /W:3

	$psCommand =  "`n robocopy """ + 
			$Source + "`" """ + 
			$Destination + """ " +
			"/E /COPYALL /DCOPY:DAT  /MOVE /R:100 /W:3 "+ 
			"/LOG:""" +
			$LogFile + "`""     

	#Write-Host -ForegroundColor Cyan $psCommand
	
	#explorer $Destination
	#explorer $LogFile

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n *************[$today] FINISHED RobocopyMoveFiles from $Source to $Destination *****************"
}#Function global:RobocopyMoveFiles

<#
$Source = ""

$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ChiefArchitect"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"

MoveFiles -ParentFolder $Source -BicepFolder $Destination
#>