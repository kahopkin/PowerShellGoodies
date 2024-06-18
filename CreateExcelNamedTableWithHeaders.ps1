



Function CreateExcelTable
{
	Param(
		  [Parameter(Mandatory = $false)] [Object] $ExcelWorkBook
		, [Parameter(Mandatory = $false)] [String] $WorksheetName
		, [Parameter(Mandatory = $false)] [String] $TableName
		, [Parameter(Mandatory = $false)] [String[]] $Headers		
	)
	

	# Open New Excel Workbook / WorkSheet


	#If ($ExcelWorkBook -eq $null) {
		$Excel = New-Object -ComObject Excel.Application
		$Excel.Visible = $true
		$ExcelWorkBook = $Excel.Workbooks.Add()
		$ExcelWorkSheet = $ExcelWorkBook.Worksheets[1]
		$ExcelWorkSheet.Name = $WorksheetName
		$ExcelWorkSheet.Rows.RowHeight = 15

	<#}#If ($ExcelWorkBook -eq $null)
	Else
	{
		Write-Host -ForegroundColor Green "Excel is NOT NULL"
		$ExcelWorkBookCount = $Excel.Workbooks.Count
		Write-Host -ForegroundColor White "`$ExcelWorkBookCount= "  -NoNewline
		Write-Host -ForegroundColor Cyan "`"$ExcelWorkBookCount`""

		$ExcelWorkSheet = $ExcelWorkBook.Worksheets
		#adds new worksheet to excel workbook
		$ExcelWorkSheet = $ExcelWorkBook.Worksheets.Add()
		$ExcelWorkSheet.name = $WorksheetName

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
	$Table.HeaderRowRange[2].Columns.Cells.DisplayFormat.Style.VerticalAlignment

}#Function CreateExcelTable

<#

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


$ExcelWorkSheet = CreateExcelTable `
					-WorksheetName $WorksheetName `
					-TableName $TableName `
					-Headers $Headers
					#>