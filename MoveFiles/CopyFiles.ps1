<#
C:\GitHub\PowerShellGoodies\MoveFiles\CopyFiles.ps1
#$Source = Folder what you want to copy 
#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!

#>

using namespace System.Collections.Generic

$FileName = ""

& "$PSScriptRoot\1_GetFiles.ps1"
& "$PSScriptRoot\1A_FolderAndFileCount.ps1"
& "$PSScriptRoot\2_CreateExcelTable.ps1"
& "$PSScriptRoot\3_PopulateExcelTable.ps1"
& "$PSScriptRoot\5_RobocopyCopyFiles.ps1"

$debugFlag = $true

# Import the required modules
#Import-Module -Name ImportExcel
$global:Excel = 
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


#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Chief Architect Catalogs"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Chief Architect Installers"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Chief Architect Premier X11 Data"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Home Designer Architectural 10 Data"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\ARAG Legal"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect"
#$Source = "C:\Kat\SnagItBackUps"
#$Source = "C:\Kat\Flankspeed Exports"
#$Source = "C:\Users\kahopkin"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\GitHub"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\AzureStackDevelopmentKit"
#$Source = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\Chief Architect"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\PhoneBackUps"
$Source = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\PhoneBackUps\Music"
#$Source = ""
#$Source = ""
#$Source = ""


#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!

#$Destination = "C:\Users\kahopkin\OneDrive"
$Destination = "D:\MS-Surface-E6F1US5"
$Destination = "D:\SurfaceBook3-E6F1US5\Kat"
#$Destination = "C:\"
$Destination = "D:\MS-Surface-E6F1US5"
$Destination = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Music"
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""




$CopyOnlyFLag = $true
#$CopyOnlyFLag = $false
$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "#"}
}#>

Write-Host -ForegroundColor Magenta -BackgroundColor Black "*************[$today] STARTING CopyFiles *****************"
<#For($j=0;$j -cle 120;$j++)
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
#$ExcelFileName = $Destination + "\" + $today + "_" + $SourceFolder.Name + ".xlsx"
$ExcelFileName = $Source + "\" + $SourceFolder.Name + "_" + $today + ".xlsx"


#
If($debugFlag){	
	Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`$Source=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$Source`""	
	Write-Host -ForegroundColor Cyan -BackgroundColor Black  "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$Destination`""
	Write-Host -ForegroundColor Green -BackgroundColor Black  "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$DestinationFolder`""
	Write-Host -ForegroundColor Yellow -BackgroundColor Black  "`$ExcelFileName= "  -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black  "`"$ExcelFileName`""
	
	#Print out the folder and filecount for the source and destination
	#CountChildItems -Source $Source -Destination $DestinationFolder
}#If($debugFlag) #> 

#If $DestinationFolder does not exist, clone the dir structure 
If( (Test-Path $DestinationFolder) -eq $false)
{
	$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy-HH-mm-ss')
	$SourceFolder = Get-Item -Path $Source
	$LogFile = $Destination + "\" + $SourceFolder.Name + "_" + $TodayFolder + ".log"
	Write-Host -ForegroundColor Red -BackgroundColor Black "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White -BackgroundColor Black "`"$DestinationFolder`"" -NoNewline
	Write-Host -ForegroundColor Red -BackgroundColor Black " DOES NOT EXIST, CLONING DIRECTORY STRUCTURE"
	
	Write-Host -ForegroundColor Green "`$SourceFolder=" -NoNewline
	Write-Host -ForegroundColor Yellow "`"$SourceFolder`""

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
	#robocopy "C:\Users\kahopkin\OneDrive - Microsoft" "C:\Kat" /DCOPY:DAT /E /XF * 
	$psCommand =  "`n robocopy " + "`"" + $SourceParentFolderPath + "`" " + "`"" + $Destination + "`"" + " /DCOPY:DAT /E /XF * " #"/LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor Cyan -BackgroundColor Darkblue $psCommand
	robocopy $SourceParentFolderPath $Destination /DCOPY:DAT /E /XF * /LOG:$LogFile
	<#
	$psCommand =  "`n robocopy " + "`"" + $SourceParentFolderPath + "`" " + "`"" + $DestinationParentFolderPath + "`"" + " /DCOPY:DAT /E /XF * " #"/LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor Cyan -BackgroundColor Darkblue $psCommand
	robocopy $SourceParentFolderPath DestinationParentFolderPath /DCOPY:DAT /E /XF * /LOG:$LogFile
	#>
	#robocopy $SourceFolder $DestinationParentFolderPath /DCOPY:DAT /E /XF *  /LOG:$LogFile
	 
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



$psCommand =  "`RobocopyCopyFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $DestinationFolder + "`"" 
Write-Host -ForegroundColor Cyan  -BackgroundColor Black  "`n[184]Calling:"
Write-Host -ForegroundColor White -BackgroundColor Black $psCommand

#
# Call Robocopy to copy/move folder and its contents!
RobocopyMoveFiles -Source $Source -Destination $Destination
#RobocopyCopyFiles -Source $Source -Destination $DestinationFolder 
#>

<#
If($debugFlag){			
}#If($debugFlag) #> 


$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
<#
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta -BackgroundColor Black "*"}
}#>

<#
If($debugFlag){	
	Write-Host -ForegroundColor Green "`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	
	Write-Host -ForegroundColor Cyan "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""
}#If($debugFlag) #> 

Write-Host -ForegroundColor Magenta -BackgroundColor Black "*************[$today] FINISHED CopyFiles *****************"

For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "#"}
}#>
