<#
C:\GitHub\PowerShellGoodies\MoveFiles\MoveFiles.ps1

#>

#$FileName = ""
using namespace System.Collections.Generic

& "$PSScriptRoot\1_GetFiles.ps1"
& "$PSScriptRoot\2_CreateExcelTable.ps1"
& "$PSScriptRoot\3_PopulateExcelTable.ps1"
& "$PSScriptRoot\4_RobocopyMoveFiles.ps1"


# Import the required modules
#Import-Module -Name ImportExcel
$global:ExcelWorkBook = 
$global:ExcelWorkSheet = 
$global:Table =
$global:FileObjectList =
$global:FileObjList = 
$global:DirectoryObjects = $null	

$Headers =  "CreationTime" ,
				"LastWriteTime" ,
				"FullFileName" ,
				"ParentFolder" ,
				"Notes" ,
				"FileCount" ,
				"ItemType" ,
				"FileName" ,
				"Extension" ,
				"FullPath" ,
				"SizeKB" ,
				"SizeMB" ,
				"SizeGB" 

$WorksheetName = 'FolderContents'
$TableName = 'FilesTable'


$Source = "C:\Kat\Flankspeed Exports"
$Source = "C:\Kat"
$Source = "C:\PhoneBackUps"
#$Source = "C:\PhoneBackUps\Samsung A70"
$Source = "C:\Users\kahopkin\OneDrive\PhoneBackUps"
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""


#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!

#$Destination = "C:\Users\kahopkin\OneDrive"
$Destination = "C:\Users\kahopkin\OneDrive\Chief Architect"
$Destination = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5"
$Destination = "D:\MS-Surface-E6F1US5"
$Destination = "D:\SurfaceBook3-E6F1US5"
#$Destination = ""
#$Destination = ""
#$Destination = ""


$CopyOnlyFLag = $true
$debugFlag = $true


$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "*"}
}#>
Write-Host -ForegroundColor Magenta -BackgroundColor Black "*************[$today] STARTING MoveFiles *****************"
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta -BackgroundColor Black "*"}
}#>



$SourceFolderNameArr = $Source.split("\")
$SourceFolderName = $SourceFolderNameArr[$SourceFolderNameArr.Count-1]
$DestinationFolder = $Destination + "\" + $SourceFolderName
#$Destination = $DestinationFolder

$SourceFolder = Get-Item -Path $Source

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
	$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy-HH-mm-ss')
	$SourceFolder = Get-Item -Path $Source
	$LogFile = $TodayFolderPath = $Destination + "\" + $SourceFolder.Name + "_" + $TodayFolder + ".log"
	Write-Host -ForegroundColor Red -BackgroundColor Black "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black "`"$DestinationFolder`"" -NoNewline
	Write-Host -ForegroundColor Red -BackgroundColor Black " DOES NOT EXIST, CLONING DIRECTORY STRUCTURE"
	
	Write-Host -ForegroundColor Green "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor Yellow "`"$DestinationFolder`""
	Write-Host -ForegroundColor Green "CLONED DESTINATION DIRECTORY STRUCTURE:"
		


	#$DestinationParentFolderPath = $Destination.Substring(0, $Destination.LastIndexOf("\"))
	$DestinationParentFolderPath = $DestinationFolder.Substring(0, $DestinationFolder.LastIndexOf("\"))
	$SourceParentFolderPath = $Source.Substring(0, $Source.LastIndexOf("\"))

	Write-Host -ForegroundColor Cyan -BackgroundColor Black  "`$DestinationParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$DestinationParentFolderPath`""
	Write-Host -ForegroundColor Green -BackgroundColor Black  "`$SourceParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$SourceParentFolderPath`""

	# clone a directory without files
	#robocopy $SourceParentFolderPath $DestinationParentFolderPath /DCOPY:DAT  /E /XF *  /LOG:$LogFile
	robocopy $SourceFolder $DestinationParentFolderPath /DCOPY:DAT  /E /XF *  /LOG:$LogFile
	$psCommand =  "`n robocopy " + "`"" + $SourceFolder + "`" " + "`"" + $DestinationParentFolderPath + "`"" + " /DCOPY:DAT /E /XF  /LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor White $psCommand

	
}#If( (Test-Path $Destination) -eq $false)




If(-not $CopyOnlyFLag)
{
	#
	# Query and store Source folder's subfulders and files in $FileObjectList

	$psCommand =  "`$FileObjectList =  GetFiles `` `n`t" + 
			"-Source `"" + $Source + "`" `` `n`t" + 
			"-Destination `"" + $Destination + "`"" 
	Write-Host -ForegroundColor Cyan  -BackgroundColor Black  "`n[145]Calling:"
	Write-Host -ForegroundColor White -BackgroundColor Black $psCommand

	$FileObjectList = New-Object System.Collections.Generic.List[System.String]
	#
	$FileObjectList = GetFiles -Source $Source -Destination $Destination
	#>

	#
	#Create excel worksheet and table
	$ExcelWorkSheet = CreateExcelTable `
								-ExcelWorkBook $ExcelWorkBook `
								-WorksheetName $WorksheetName `
								-TableName $TableName `
								-Headers $Headers `
								-ExcelFileName $ExcelFileName
	#>

	#
	#Populate the excel table with the file/folder information
	$ExcelWorkSheet = PopulateExcelTable `
						-ExcelWorkSheet $ExcelWorkSheet `
						-FileObjectList $FileObjectList `
						-ExcelFileName $ExcelFileName

	#Sleep for 30 seconds so can look at excel
	Write-Host -ForegroundColor Green "Waiting for 30 seconds...." 
	$Now = Get-Date
	Write-Host -ForegroundColor Yellow "Starting at: " $Now
 
	Start-Sleep -Seconds 30; 
	$Now = Get-Date
	Write-Host -ForegroundColor Yellow "Resuming at: " $Now
	$ExcelWorkSheet.Parent.Parent.Quit()
	#>
}#If(-not $CopyOnlyFLag)



$psCommand =  "`RobocopyMoveFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $DestinationFolder + "`"" 
Write-Host -ForegroundColor Cyan  -BackgroundColor Black  "`n[240]Calling:"
Write-Host -ForegroundColor White -BackgroundColor Black $psCommand

#
# Call Robocopy to copy/move folder and its contents!
#RobocopyMoveFiles -Source $Source -Destination $DestinationFolder
#RobocopyMoveFiles -Source $Source -Destination $Destination
#RobocopyCopyFiles -Source $Source -Destination $DestinationFolder 
#>

$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta -BackgroundColor Black "*"}
}#>
Write-Host -ForegroundColor Magenta -BackgroundColor Black "*************[$today] FINISHED MoveFiles *****************"
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "*"}
}#>