<#
C:\GitHub\PowerShellGoodies\MoveFiles\MoveFiles.ps1

#>
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

#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Excel Exports"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ODIN"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Exports"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Exports\ACAS Excel Exports\ACAS SCANS\OneDrive_2024-05-25"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Excel Exports"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Excel Exports - Copy"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Scan"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS SCANS\OneDrive_2024-05-25"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\Flankspeed"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\06-07-2024"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Documentations"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Solutions"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Scan"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Documentations\Flow Stuff"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\BICEP"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\Flow Exports\ODIN_DEV"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ExportedSettings"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data\ExportedSettings"
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
#$Source = ""
#$Source = ""



$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\Flow Exports"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS SCANS"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\Flow Stuff"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Training"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data"
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""


$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] STARTING MoveFiles *****************"

$debugFlag = $true

<#
If($debugFlag){
	Write-Host -ForegroundColor Red "`n Moving files" 
	Write-Host -ForegroundColor White "`$Source=" -NoNewline
	Write-Host -ForegroundColor Green "`"$Source`""	
	Write-Host -ForegroundColor White "`$Destination=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Destination`""
}#If($debugFlag) #> 


$FileObjectList = New-Object System.Collections.Generic.List[System.String]
$FileObjectList = GetFiles -Source $Source -Destination $Destination

$today = Get-Date -Format "yyyy-MM-dd"
$SourceFolder = Get-Item -Path $Source
$ExcelFileName = $Destination + "\" + $today + "_" + $SourceFolder.Name + ".xlsx"


#
$ExcelWorkSheet = CreateExcelTable `
							-ExcelWorkBook $ExcelWorkBook `
							-WorksheetName $WorksheetName `
							-TableName $TableName `
							-Headers $Headers ` 
							-ExcelFileName $ExcelFileName

#Populate the excel table with the file/folder information
PopulateExcelTable -ExcelWorkSheet $ExcelWorkSheet -FileObjectList $FileObjectList #-ExcelFileName $ExcelFileName
	
#RobocopyMoveFiles -Source $Source -Destination $Destination

#>

<#
If($debugFlag){			
}#If($debugFlag) #> 

	
$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED MoveFiles *****************"