<#
C:\GitHub\PowerShellGoodies\MoveFiles\CopyFiles.ps1
#$Source = Folder what you want to copy 
#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!

#>
using namespace System.Collections.Generic

& "$PSScriptRoot\1_GetFiles.ps1"
& "$PSScriptRoot\2_CreateExcelTable.ps1"
& "$PSScriptRoot\3_PopulateExcelTable.ps1"
& "$PSScriptRoot\5_RobocopyCopyFiles.ps1"

$debugFlag = $true

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
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts\CapitalOne Visa\2024"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Azure Stuff"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\BICEP"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Chief Architect Catalogs"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Chief Architect Installers"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Chief Architect Premier X12 Data"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Home Designer Architectural 10 Data"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Chief Architect\Home Designer Architectural 10 Data\10222011"
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""


#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Training"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Chief Architect Premier X12 Data"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Documentations"
#$Destination = "C:\GitHub\PowerShellGoodies"
$Destination = "D:\Accounts\BGE"
$Destination = "D:\Accounts\CapOne\CapOne Checking"
$Destination = "D:\Accounts\CapOne\CapOne Venture"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts\CapitalOne Checking"
$Destination = "D:\"
#$Destination = "C:\Users\kahopkin\OneDrive"
$Destination = "C:\Users\kahopkin\OneDrive\Chief Architect\Home Designer Architectural 10 Data"
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""

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
$Destination = $DestinationFolder

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

}#If($debugFlag) #> 


$FileObjectList = New-Object System.Collections.Generic.List[System.String]

#
# Query and store Source folder's subfulders and files in $FileObjectList
#$FileObjectList = GetFiles -Source $Source -Destination $Destination
$psCommand =  "`$FileObjectList =  GetFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $Destination + "`"" 
Write-Host -ForegroundColor Yellow -BackgroundColor Black  "`n[145]Calling:"
Write-Host -ForegroundColor DarkYellow -BackgroundColor Black $psCommand
#>
#$today = Get-Date -Format "yyyy-MM-dd"

<#
#Create excel worksheet and table
$ExcelWorkSheet = CreateExcelTable `
							-ExcelWorkBook $ExcelWorkBook `
							-WorksheetName $WorksheetName `
							-TableName $TableName `
							-Headers $Headers `
							-ExcelFileName $ExcelFileName
#>

<#
#Populate the excel table with the file/folder information
PopulateExcelTable  -ExcelWorkSheet $ExcelWorkSheet `
					-FileObjectList $FileObjectList `
					-ExcelFileName $ExcelFileName

$ExcelWorkBook.Application.Quit()	
#>

<#
# Call Robocopy to copy/move folder and its contents!
#RobocopyMoveFiles -Source $Source -Destination $Destination
#RobocopyCopyFiles -Source $Source -Destination $Destination 
#>

<#
If($debugFlag){			
}#If($debugFlag) #> 


$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
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
