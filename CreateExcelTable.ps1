<#
#CreateExcelTable
#>

Function global:CreateExcelTable
{
	Param(
		  [Parameter(Mandatory = $false)] [Object] $ExcelWorkBook
		, [Parameter(Mandatory = $false)] [String] $WorksheetName
		, [Parameter(Mandatory = $false)] [String] $TableName
		, [Parameter(Mandatory = $false)] [String[]] $Headers		
	)
	
	$today = Get-Date -Format 'MM-dd-yyyy HH-mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] STARTING CreateExcelTable *****************"

	
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
	$ExcelWorkSheet.Columns.ColumnWidth = 8

	

	$i = 0
	ForEach($column in $Table.ListColumns)
	{
		$column.Name = $Headers[$i]
		#$Table.ListColumns.Item(4).TotalsCalculation = 1
		#$column.TotalsCalculation = 1		
		$i++
		# 4108 = Middle Align
		#$Table.HeaderRowRange[$i].Columns.Cells.VerticalAlignment = -4108
		<#
		-4131 = Left Justified
		-4107 = Center
		-4152 = Right Justified
		#>
		#$Table.HeaderRowRange[$i].Columns.Cells.HorizontalAlignment = -4108
		
	}

	$ExcelCells = $ExcelWorkSheet.Cells


	<# VerticalAlignment (1st row in ribbon)
		Top = -4160
		Middle = -4108
		Bottom = -4107
	#>
	$ExcelCells.Cells.VerticalAlignment = -4108

	<# Horizontal Alignment (2nd row in ribbon)
		Left = -4131
		Center = -4128
		Right = -4152
	#>
	$ExcelCells.Cells.HorizontalAlignment = -4131
	#$ExcelCells.Cells.ShrinkToFit = $true
	#Align Left
	#$Table.HeaderRowRange[2].Columns.Cells.DisplayFormat.Style.HorizontalAlignment = 2
	#displays the text in the Cells
	#$Table.HeaderRowRange[2].Columns.Cells.Text

	$today = Get-Date -Format 'MM-dd-yyyy HH-mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINSIHED CreateExcelTable *****************"

	return $ExcelWorkSheet
}#Function CreateExcelTable

