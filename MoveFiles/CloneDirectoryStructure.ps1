<#
C:\GitHub\PowerShellGoodies\FoldersAndFiles\CloneDirectoryStructure.ps1

#$Source = Folder what you want to copy 
#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!

#>
$FileName = "CloneDirectoryStructure"
#& "$PSScriptRoot\DeleteEmptyFolders.ps1"

$debugFlag = $true


$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\ARAG Legal"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect"
$Source = "C:\Kat\SnagItBackUps"
#$Source = "D:\SurfaceBook3-E6F1US5\Kat\CloneTestDestination"
$Source = "C:\Kat\Flankspeed Exports"
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""


#$Destination = "C:\Users\kahopkin\OneDrive"
$Destination = "C:\Users\kahopkin\OneDrive\Chief Architect"
$Destination = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5"
$Destination = "D:\MS-Surface-E6F1US5"
$Destination = "D:\SurfaceBook3-E6F1US5\Kat"
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""

$CopyOnlyFLag = $true
$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "#"}
}#>

Write-Host -ForegroundColor Magenta -BackgroundColor Black "*************[$today] STARTING CloneDirectoryStructure *****************"

$SourceFolder = Get-Item -Path $Source
#$SourceFolderNameArr = $Source.split("\")
#$SourceFolderName = $SourceFolderNameArr[$SourceFolderNameArr.Count-1]
$SourceFolderName = $SourceFolder.Name
$DestinationFolder = $Destination + "\" + $SourceFolderName
#$DestinationFolder = Get-Item -Path ($Destination + "\" + $SourceFolderName)


$today = Get-Date -Format 'yyyy-MM-dd-HH-mm-ss'
$ExcelFileName = $Source + "\" + $SourceFolder.Name + "_" + $today + ".xlsx"

$SourceFolder = Get-Item -Path $Source
$LogFile = $Destination + "\" + $SourceFolder.Name + "_" + $today + ".log"
#
If($debugFlag){	
	Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`$Source=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$Source`""	
	Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`$SourceFolderName=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$SourceFolderName`""	

	Write-Host -ForegroundColor Cyan -BackgroundColor Black  "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$Destination`""
	Write-Host -ForegroundColor Green -BackgroundColor Black  "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$DestinationFolder`""	
	
	Write-Host -ForegroundColor Yellow -BackgroundColor Black  "`$ExcelFileName= "  -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$ExcelFileName`""
	
	Write-Host -ForegroundColor Green "`$LogFile=" -NoNewline
	Write-Host -ForegroundColor White "`"$LogFile`""	

	#Print out the folder and filecount for the source and destination
	#CountChildItems -Source $Source -Destination $DestinationFolder
}#If($debugFlag) #> 

#If $DestinationFolder does not exist, clone the dir structure 
If( (Test-Path $DestinationFolder) -eq $false)
{	
	Write-Host -ForegroundColor Red -BackgroundColor Black "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black "`"$DestinationFolder`"" -NoNewline
	Write-Host -ForegroundColor Red -BackgroundColor Black " DOES NOT EXIST, CLONING DIRECTORY STRUCTURE"	
	Write-Host -ForegroundColor Green "CLONING DESTINATION DIRECTORY STRUCTURE..."	

	
	#$DestinationParentFolderPath = $Destination.Substring(0, $Destination.LastIndexOf("\"))
	$DestinationParentFolderPath = $DestinationFolder.Substring(0, $DestinationFolder.LastIndexOf("\"))
	$SourceParentFolderPath = $Source.Substring(0, $Source.LastIndexOf("\"))

	Write-Host -ForegroundColor Cyan -BackgroundColor Black  "`$DestinationParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$DestinationParentFolderPath`""
	Write-Host -ForegroundColor Green -BackgroundColor Black  "`$SourceParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$SourceParentFolderPath`""

	# clone a directory without files
	#If SourceFolder does not exist, run with $SourceParentFolderPath, but this will create the dir structure for every folder from the parent	
	$psCommand =  "`n robocopy " + "`"" + $SourceParentFolderPath + "`" " + "`"" + $DestinationParentFolderPath + "`"" + " /DCOPY:DAT /E /XF * /LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor White $psCommand
	robocopy $SourceParentFolderPath $DestinationParentFolderPath /DCOPY:DAT /E /XF * /LOG:$LogFile

	#run with $SourceFolder if the folder already is present on destination
	<#
	robocopy $SourceFolder $DestinationParentFolderPath /DCOPY:DAT /E /XF * /LOG:$LogFile
	$psCommand =  "`n robocopy " + "`"" + $SourceFolder + "`" " + "`"" + $DestinationParentFolderPath + "`"" + " /DCOPY:DAT /E /XF * /LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor White $psCommand
	#>

}#If( (Test-Path $Destination) -eq $false)
Else
{	
	$tailRecursion = {
		param(
			$Path
		)
		foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
			& $tailRecursion -Path $childDirectory.FullName
		}
		$currentChildren = Get-ChildItem -Force -LiteralPath $Path
		$isEmpty = $currentChildren -eq $null
		if ($isEmpty) {
			Write-Verbose "Removing empty folder at path '${Path}'." -Verbose
			Remove-Item -Force -LiteralPath $Path
		}
	}
	#invoke Delete Empty Directories
	& $tailRecursion -Path $Destination
}




Write-Host -ForegroundColor Magenta -BackgroundColor Black "*************[$today] FINISHED CloneDirectoryStructure *****************"

For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "#"}
}#>
