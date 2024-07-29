<#
C:\GitHub\PowerShellGoodies\MoveFiles\CopyFiles.ps1

#>
using namespace System.Collections.Generic

& "$PSScriptRoot\1_GetFiles.ps1"
& "$PSScriptRoot\2_CreateExcelTable.ps1"
& "$PSScriptRoot\3_PopulateExcelTable.ps1"
& "$PSScriptRoot\5_RobocopyCopyFiles.ps1"


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
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ExportedSettings"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data\ExportedSettings"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Documentations\Docs"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\OneDrive"
$Source = "C:\GitHub\PowerShellGoodies - Copy"
$Source = "C:\GitHub\PowerShellGoodies-Orig"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts\BGE"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts\CapitalOne Checking\2024-CapitalOne Checking"
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
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Training"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Documentations"

#$Destination = "C:\GitHub\PowerShellGoodies"
$Destination = "D:\Accounts\BGE"
$Destination = "D:\Accounts\CapOne\CapOne Checking"
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
Write-Host -ForegroundColor Cyan "`$ExcelFileName= "  -NoNewline
Write-Host -ForegroundColor Green "`"$ExcelFileName`""

#
$ExcelWorkSheet = CreateExcelTable `
							-ExcelWorkBook $ExcelWorkBook `
							-WorksheetName $WorksheetName `
							-TableName $TableName `
							-Headers $Headers `
							-ExcelFileName $ExcelFileName
#>

#Populate the excel table with the file/folder information
PopulateExcelTable  -ExcelWorkSheet $ExcelWorkSheet ` -FileObjectList $FileObjectList ` -ExcelFileName $ExcelFileName
	
#RobocopyMoveFiles -Source $Source -Destination $Destination
#RobocopyCopyFiles -Source $Source -Destination $Destination 
#>

<#
If($debugFlag){			
}#If($debugFlag) #> 

If($debugFlag){	
	Write-Host -ForegroundColor Green "`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	
	Write-Host -ForegroundColor Cyan "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""
}#If($debugFlag) #> 

$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED MoveFiles *****************"