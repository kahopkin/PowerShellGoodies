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
& "$PSScriptRoot\4_RobocopyMoveFiles.ps1"
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


$Source = "C:\Users\kahopkin\OneDrive - Microsoft"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\ARAG Legal"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\GitHub"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\AzureStackDevelopmentKit"
#$Source = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\Chief Architect"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\PhoneBackUps"
$Source = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\PhoneBackUps\Music"
$Source = "D:\MS-Surface-E6F1US5\PhoneBackUps\Music"

$Source = "C:\Users\kahopkin\Music"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\GitHub"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Downloads\FlowExport"
$Source = "C:\GitHub\FlowStuff\FlowExport"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flow"
$Source = "C:\GitHub\PowerShellGoodies"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Billy Miller Team"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Canon Scanner"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Clearance"
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
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
#$Destination = "C:\Users\kahopkin\OneDrive"
$Destination = "D:\MS-Surface-E6F1US5"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft"
$Destination = "C:\GitHub\FlowStuff"
$Destination = "\\DS224\MS-Surface-E6F1US5"
#$Destination = ""
#$Destination = ""




$CopyOnlyFLag = $true
#$CopyOnlyFLag = $false
$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow "#"}
}#>

Write-Host -ForegroundColor Magenta "*************[$today] STARTING CopyFiles *****************"
<#For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta "*"}
}#>


#$Destination = $DestinationFolder

$SourceFolder = Get-Item -Path $Source
$SourceFolderName = $SourceFolder.Name
$DestinationFolder = $Destination + "\" + $SourceFolderName
$today = Get-Date -Format 'yyyy-MM-dd-HH-mm-ss'
#$ExcelFileName = $Destination + "\" + $today + "_" + $SourceFolder.Name + ".xlsx"
$ExcelFileName = $Source + "\" + $SourceFolder.Name + "_" + $today + ".xlsx"
$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy-HH-mm-ss')
$SourceFolder = Get-Item -Path $Source
$LogFile = $Destination + "\" + $SourceFolder.Name + "_" + $TodayFolder + ".log"

#
#If($debugFlag){	
	Write-Host -ForegroundColor Magenta "`n`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	

	Write-Host -ForegroundColor Magenta "`$SourceFolder=" -NoNewline
	Write-Host -ForegroundColor White "`"$SourceFolder`""

	Write-Host -ForegroundColor Green "`n`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""

	Write-Host -ForegroundColor Green "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White "`"$DestinationFolder`""

	Write-Host -ForegroundColor Yellow "`n`$ExcelFileName= "  -NoNewline
	Write-Host -ForegroundColor White "`"$ExcelFileName`""
		
	Write-Host -ForegroundColor Cyan "`$LogFile=" -NoNewline
	Write-Host -ForegroundColor White "`"$LogFile`""

	#Print out the folder and filecount for the source and destination
	#CountChildItems -Source $Source -Destination $DestinationFolder
#}#If($debugFlag) #> 

#If $DestinationFolder does not exist, clone the dir structure 
If( (Test-Path $DestinationFolder) -eq $false)
{

	Write-Host -ForegroundColor Red"`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White"`"$DestinationFolder`"" -NoNewline
	Write-Host -ForegroundColor Gray"`n #DOES NOT EXIST, CLONING DIRECTORY STRUCTURE"
	
	
	#Write-Host -ForegroundColor Gray "`n#CLONED DESTINATION DIRECTORY STRUCTURE:"
		


	#$DestinationParentFolderPath = $Destination.Substring(0, $Destination.LastIndexOf("\"))
	$DestinationParentFolderPath = $DestinationFolder.Substring(0, $DestinationFolder.LastIndexOf("\"))
	$SourceParentFolderPath = $Source.Substring(0, $Source.LastIndexOf("\"))

	Write-Host -ForegroundColor Cyan "`$DestinationParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White "`"$DestinationParentFolderPath`""
	Write-Host -ForegroundColor Green "`$SourceParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White "`"$SourceParentFolderPath`""

	# clone a directory without files
	#robocopy "C:\Users\kahopkin\OneDrive - Microsoft" "C:\Kat" /DCOPY:DAT /E /XF * 
	$psCommand =  "`n robocopy " + "`"" + $SourceParentFolderPath + "`" " + "`"" + $Destination + "`"" + " /DCOPY:DAT /E /XF * " # + "/LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor Cyan -BackgroundColor Darkblue $psCommand
	robocopy $SourceParentFolderPath $Destination /DCOPY:DAT /E /XF * /LOG:$LogFile
	<#
	$psCommand =  "`n robocopy " + "`"" + $SourceParentFolderPath + "`" " + "`"" + $DestinationParentFolderPath + "`"" + " /DCOPY:DAT /E /XF * " #"/LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor Cyan -BackgroundColor Darkblue $psCommand
	robocopy $SourceParentFolderPath DestinationParentFolderPath /DCOPY:DAT /E /XF * /LOG:$LogFile
	#>
	#robocopy $SourceFolder $DestinationParentFolderPath /DCOPY:DAT /E /XF *  /LOG:$LogFile
	 
}#If( (Test-Path $Destination) -eq $false)


#exit(1)

If(-not $CopyOnlyFLag)
{
	#
	# Query and store Source folder's subfulders and files in $FileObjectList

	$psCommand =  "`$FileObjectList =  GetFiles `` `n`t" + 
			"-Source `"" + $Source + "`" `` `n`t" + 
			"-Destination `"" + $Destination + "`"" 
	Write-Host -ForegroundColor Cyan  "`n[207]Calling:"
	Write-Host -ForegroundColor White $psCommand

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
Write-Host -ForegroundColor Cyan  "`n[184]Calling:"
Write-Host -ForegroundColor White $psCommand

#
# Call Robocopy to copy/move folder and its contents!
#RobocopyMoveFiles -Source $Source -Destination $DestinationFolder
RobocopyCopyFiles -Source $Source -Destination $DestinationFolder 
#>

<#
If($debugFlag){			
}#If($debugFlag) #> 


$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
<#
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta "*"}
}#>

<#
If($debugFlag){	
	Write-Host -ForegroundColor Green "`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	
	Write-Host -ForegroundColor Cyan "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""
}#If($debugFlag) #> 

Write-Host -ForegroundColor Magenta "*************[$today] FINISHED CopyFiles *****************"

For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow "#"}
}#>
