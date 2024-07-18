﻿#& "$PSScriptRoot\CreateExcelTable.ps1"
using namespace System.Collections.Generic
# Import the required modules
Import-Module -Name ImportExcel

Function global:GetFiles 
{ 
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)
	
	$debugFlag = $true

	$global:ExcelWorkBook = 
	$global:ExcelWorkSheet = 
	$global:Table = $null
	$global:FileObjectList =
	$global:FileObjList = 	$null
	$global:DirectoryObjects = $null

	$FileObjectList = New-Object System.Collections.Generic.List[System.String]
	# Loop through all directories 
	$DirectoryObjects = Get-ChildItem -Path $Source -Recurse | Sort-Object
		
	#$DirectoryObjects = Get-ChildItem -Path $Source | Where-Object { $_.PSIsContainer -eq $true } | Sort-Object  

	#$DirectoryObjects = Get-ChildItem -Path $Source -Recurse | Where-Object {$_.DirectoryName -notin $excludeMatch} | Sort-Object 
		
	$psCommand =  "`n`$DirectoryObjects = `n`tGet-ChildItem  ```n`t`t" +     
						  "-Path `"" + $Source + "`" ```n`t`t" +
						  "-Recurse  | Sort-Object " #+ 
						  #"```n`t`t" + " | " + 
						  #"Where-Object{ " + "`$_.PSIsContainer -eq `$true }" + "`n`t`t" 
	<#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[41]:"         
		Write-Host -ForegroundColor Green $psCommand
	}#If($debugFlag) #> 

	#get # of folders and files:
	$FolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
	$FileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count
	
	Write-Host -ForegroundColor White "`$FolderCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FolderCount`""

	Write-Host -ForegroundColor White "`$FileCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FileCount`""

	
	Foreach ($item In $DirectoryObjects) 
	{ 
		
		$FullPath =  $item.FullName
		$FileName = $item.BaseName        
		$ParentFolder = Split-Path (Split-Path $item.FullName -Parent) -Leaf
		$Extension = $item.Extension
		
		$CreationTime = $item.CreationTime.ToString("MM/dd/yyyy HH:mm:ss")

		$LastWriteTime = $item.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
		
		$FullFileName = Split-Path $item.FullName -Leaf -Resolve
		<#
		Write-Host -ForegroundColor White "`$FullFileName=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$FullFileName`""
		#>
		<#
		Write-Host -ForegroundColor White "`$CreationTime=" -NoNewline
		Write-Host -ForegroundColor Yellow "`"$CreationTime`""

		Write-Host -ForegroundColor White "`$LastWriteTime=" -NoNewline
		Write-Host -ForegroundColor Green "`"$LastWriteTime`""

		#>
		
				
		$isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
		<#
		Write-Host -ForegroundColor White "`$isDir=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$isDir`""
		#>
		$path = $item.FullName
		<#
		Write-Host -ForegroundColor Yellow "`$Source=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$Source`""
		#>

		$file = Get-ChildItem -Path $path -Recurse -Force `
						| Where-Object { $_.PSIsContainer -eq $false } `
						| Measure-Object -property Length -sum | Select-Object Sum    

		$psCommand =  "`n`$file = `n`tGet-ChildItem  ```n`t`t" +     
							"-Path `"" + $path + "`" -Recurse -Force ```n`t`t" +                          
							"| Where-Object { $_.PSIsContainer -eq $false } `n`t`t" +                            
							"| Measure-Object { $_.PSIsContainer -eq $false } ```n" 
		#>
		<#
		If($debugFlag){
			Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
			Write-Host -ForegroundColor Green $psCommand
		}#If($debugFlag) #> 

		$Size = $file.sum 
		$SizeKB =  "{0:N2}"-f ($Size / 1KB) + " KB"
		$SizeMB =  "{0:N2}"-f ($Size / 1MB) + " MB"
		$SizeGB =  "{0:N2}"-f ($Size / 1GB) + " GB"


		if($isDir)  
		{
			$Extension="Folder"
			$ItemType = "Folder"
			$FileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count
			#
			Write-Host -ForegroundColor Yellow "Folder:`n`t`$FullFileName=" -NoNewline
			Write-Host -ForegroundColor Cyan "`"$FullFileName`""

			Write-Host -ForegroundColor Yellow "`t`$FileCount= "  -NoNewline
			Write-Host -ForegroundColor Cyan "`"$FileCount`""
			#>

		}#if($isDir)  
		else
		{
		 
			#
			Write-Host -ForegroundColor White "`$FullFileName=" -NoNewline
			Write-Host -ForegroundColor Green "`"$FullFileName`""
			#>
			$ItemType = "File"
			$FileCount = 0
			
		}#else
		#>
		
		$FileObj = @{
			CreationTime = $CreationTime
			LastWriteTime = $LastWriteTime
			FullFileName = $FullFileName
			ParentFolder = $ParentFolder
			Notes = $Notes
			FileCount = $FileCount
			ItemType = $ItemType
			FileName = $FileName
			Extension = $Extension
			FullPath = $FullPath
			SizeKB = $SizeKB
			SizeMB = $SizeMB
			SizeGB = $SizeGB
		}# PSCustomObject
		 #>
		 $FileObjectList += $FileObj
	}# Foreach ($item In $DirectoryObjects) 
	

	$ExcelWorkBook = $null

	$Headers = "CreationTime" ,
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

	

	<#$ExcelWorkSheet = CreateExcelTable `
					-ExcelWorkBook $ExcelWorkBook `
					-WorksheetName $WorksheetName `
					-TableName $TableName `
					-Headers $Headers 
	$ExcelWorkSheet = $ExcelWorkBook.Worksheets  | Where-Object {$_.Name -eq $WorksheetName}
	#$ExcelWorkSheet = $ExcelWorkBook.Worksheets
	$Table = $ExcelWorkSheet.ListObjects
	#>

	
	If ($ExcelWorkBook -eq $null) {
		$Excel = New-Object -ComObject Excel.Application
		$Excel.Visible = $true
		$ExcelWorkBook = $Excel.Workbooks.Add()
		$ExcelWorkSheet = $ExcelWorkBook.Worksheets[1]
		$ExcelWorkSheet.Name = $WorksheetName
		$ExcelWorkSheet.Rows.RowHeight = 15

	}#If ($ExcelWorkBook -eq $null)
	Else
	{
		Write-Host -ForegroundColor Green "Excel is NOT NULL"
		$ExcelWorkBookCount = $Excel.Workbooks.Count
		Write-Host -ForegroundColor White "`$ExcelWorkBookCount= "  -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ExcelWorkBookCount`""

		$ExcelWorkSheet = $ExcelWorkBook.Worksheets
		#adds new worksheet to excel workbook
		$ExcelWorkSheet = $ExcelWorkBook.Worksheets.Add()
		$ExcelWorkSheet.Name = $WorksheetName

	}#Else
	#>



	# Calculate the index of the letter in the alphabet.
	$index = $Headers.Count - 1
	Write-Host -ForegroundColor White "`$index= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$index`""
	
	# Get the letter in the alphabet at the specified index.
	$RangeLimit = [char]($index + 65)

	# Display the letter in the alphabet at the specified position. 
	Write-Host -ForegroundColor White "The letter in the alphabet at position "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$index`"" -NoNewline 
	Write-Host -ForegroundColor White " is "  -NoNewline
	Write-Host -ForegroundColor Green "`"$RangeLimit`""

	
	
	$UpperRange = "A1:" + $RangeLimit + "1"

	Write-Host -ForegroundColor White "`$UpperRange= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$UpperRange`""

	$Range = $ExcelWorkSheet.Range($UpperRange)

	$Table = $ExcelWorkSheet.ListObjects.Add(
						[Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange, 
						$Range, 
						$null,
						[Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes,
						$null)



	$Table.Name = $TableName
	#Checks Total Row
	#$Table.ShowTotals = $true
	$Table.TableStyle = "TableStyleLight16"
	#Unchecks Banded Ros
	$Table.ShowTableStyleRowStripes = $false
	$ExcelWorkSheet.Columns.ColumnWidth = 15

	#$Table.ListColumns.Count

	$i = 0
	ForEach($column in $Table.ListColumns)
	{
		$column.Name = $Headers[$i]
		#$Table.ListColumns.Item(4).TotalsCalculation = 1
		#$column.TotalsCalculation = 1		
		$i++
		# 4108 = Middle Align
		$Table.HeaderRowRange[$i].Columns.Cells.VerticalAlignment = -4108
		<#
		-4131 = Left Justified
		-4107 = Center
		-4152 = Right Justified
		#>
		$Table.HeaderRowRange[$i].Columns.Cells.HorizontalAlignment = -4108
		
	}

	
	#Align Left
	#$Table.HeaderRowRange[2].Columns.Cells.DisplayFormat.Style.HorizontalAlignment = 2
	#displays the text in the Cells
	#$Table.HeaderRowRange[2].Columns.Cells.Text

	$ExcelCells = $ExcelWorkSheet.Cells
	$row = 1
	$col = 1	   
	$InitialRow = $row


	$ExcelCells.Cells.VerticalAlignment = -4108
	#$ExcelCells.Cells.HorizontalAlignment = -4108

	ForEach($object in $FileObjectList)
	{
		
		$row++
		$col = 1
		
		$ExcelCells.Item($row,$col) = $object.CreationTime
		$col++		
		$ExcelCells.Item($row,$col) = $object.LastWriteTime
		$col++
		$ExcelCells.Item($row,$col) = $object.FullFileName	
		Write-Host -ForegroundColor White "Row[$row]Col[$col] `$object.FullFileName= "  -NoNewline
		Write-Host -ForegroundColor Cyan $object.FullFileName
		$col++
		$ExcelCells.Item($row,$col) = $object.ParentFolder
		$col++
		$ExcelCells.Item($row,$col) = $object.Notes
		$col++
		$ExcelCells.Item($row,$col) = $object.FileCount
		$col++
		$ExcelCells.Item($row,$col) = $object.ItemType
		$col++
		$ExcelCells.Item($row,$col) = $object.FileName
		#Write-Host -ForegroundColor White "Row[$row]Col[$col] `$object.FileName= "  -NoNewline
		#Write-Host -ForegroundColor Cyan $object.FileName
		$col++
		$ExcelCells.Item($row,$col) = $object.Extension
		$col++
		$ExcelCells.Item($row,$col) = $object.FullPath
		$col++
		$ExcelCells.Item($row,$col) = $object.SizeKB
		$col++
		$ExcelCells.Item($row,$col) = $object.SizeMB
		$col++
		$ExcelCells.Item($row,$col) = $object.SizeGB
		$col++		
	}#ForEach($object in $FileObjectList)
	
	$ExcelWorkBook | Save-ExcelWorkbook -Path $Destination + "\FolderContents.xlsx"
}#GetFiles




Function global:CreateExcelTable
{
	Param(
		  [Parameter(Mandatory = $false)] [Object] $ExcelWorkBook
		, [Parameter(Mandatory = $false)] [String] $WorksheetName
		, [Parameter(Mandatory = $false)] [String] $TableName
		, [Parameter(Mandatory = $false)] [String[]] $Headers		
	)
	

	# Open New Excel Workbook / WorkSheet


	If ($ExcelWorkBook -eq $null) {
		$Excel = New-Object -ComObject Excel.Application
		$Excel.Visible = $true
		$ExcelWorkBook = $Excel.Workbooks.Add()
		$ExcelWorkSheet = $ExcelWorkBook.Worksheets[1]
		$ExcelWorkSheet.Name = $WorksheetName
		$ExcelWorkSheet.Rows.RowHeight = 15

	}#If ($ExcelWorkBook -eq $null)
	Else
	{
		Write-Host -ForegroundColor Green "Excel is NOT NULL"
		$ExcelWorkBookCount = $Excel.Workbooks.Count
		Write-Host -ForegroundColor White "`$ExcelWorkBookCount= "  -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ExcelWorkBookCount`""

		$ExcelWorkSheet = $ExcelWorkBook.Worksheets
		#adds new worksheet to excel workbook
		$ExcelWorkSheet = $ExcelWorkBook.Worksheets.Add()
		$ExcelWorkSheet.Name = $WorksheetName

	}#Else
	#>



	# Calculate the index of the letter in the alphabet.
	$index = $Headers.Count - 1
	Write-Host -ForegroundColor White "`$index= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$index`""
	
	# Get the letter in the alphabet at the specified index.
	$RangeLimit = [char]($index + 65)

	# Display the letter in the alphabet at the specified position. 
	Write-Host "The letter in the alphabet at position $position is $RangeLimit."	
	
	$UpperRange = "A1:" + $RangeLimit + "1"

	Write-Host -ForegroundColor White "`$UpperRange= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$UpperRange`""

	$Range = $ExcelWorkSheet.Range($UpperRange)

	$Table = $ExcelWorkSheet.ListObjects.Add(
						[Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange, 
						$Range, 
						$null,
						[Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes,
						$null)



	$Table.Name = $TableName
	#Checks Total Row
	$Table.ShowTotals = $true
	$Table.TableStyle = "TableStyleLight16"
	#Unchecks Banded Ros
	$Table.ShowTableStyleRowStripes = $false
	$ExcelWorkSheet.Columns.ColumnWidth = 12



	$Table.ListColumns

	$i = 0
	ForEach($column in $Table.ListColumns)
	{
		$column.Name = $Headers[$i]
		#$Table.ListColumns.Item(4).TotalsCalculation = 1
		$column.TotalsCalculation = 1
		#Write-Host $column.Name
		$i++
	}


	ForEach($column in $Table.ListColumns)
	{
		$column.TotalsCalculation = 1
	}


	#Align Left
	$Table.HeaderRowRange[2].Columns.Cells.DisplayFormat.Style.HorizontalAlignment = 2
	#displays the text in the Cells
	$Table.HeaderRowRange[2].Columns.Cells.Text

	#-4160= Middle
	#
	#$Table.HeaderRowRange[2].Columns.Cells.DisplayFormat.Style.VerticalAlignment


	<#
	# Save the Excel workbook to the specified file path
	$workbook | Save-ExcelWorkbook -Path $excelFilePath
	#>

	return $ExcelWorkSheet
}#Function CreateExcelTable


$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_DataVerse"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"


GetFiles -Source $Source -Destination $Destination
