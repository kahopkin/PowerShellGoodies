$ExcelCells.Item($row,$col)

$column = [char]($col-1 + 65)


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


	Function global:CalculateWorkbookCell
	{
		Param(
			  [Parameter(Mandatory = $false)] [Object] $ExcelWorkSheet
			, [Parameter(Mandatory = $false)] [String] $Cell
			, [Parameter(Mandatory = $false)] [String] $Value
		)
		
		$ExcelCells = $ExcelWorkSheet.Cells
		$ExcelCells.item($Cell) = $Value


		# Get the letter in the alphabet at the specified index.
		$RangeLimit = [char]($index + 65)
	}#CalculateWorkbookCell
<#
		-4131 = Left Justified
		-4107 = Center
		-4152 = Right Justified
		#>
		

	


	<#
	# Save the Excel workbook to the specified file path
	$workbook | Save-ExcelWorkbook -Path $excelFilePath
	#>





Function global:CreateExcelTable
{
	Param(
		  [Parameter(Mandatory = $false)] [Object] $ExcelWorkBook
		, [Parameter(Mandatory = $false)] [String] $WorksheetName
		, [Parameter(Mandatory = $false)] [String] $TableName
		, [Parameter(Mandatory = $false)] [String[]] $Headers		
	)
	
	
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

	return $ExcelWorkSheet
}#Function CreateExcelTable


# Returns the application: Microsoft Excel
$ExcelWorkSheet.ListObjects.Application.Name

#Returns the Active worksheet's name
#:FolderContents
$ExcelWorkSheet.ListObjects.Application.ActiveSheet.Name



$ExcelWorkSheet = $ExcelWorkBook.Worksheets  | Where-Object {$_.Name -eq $WorksheetName}

$Table = $ExcelWorkBook.Worksheets  | Where-Object {$_.Name -eq $WorksheetName}


$Table = $ExcelWorkSheet.ListObjects()

#Align Left
	#$Table.HeaderRowRange[2].Columns.Cells.DisplayFormat.Style.HorizontalAlignment = 2
	#displays the text in the Cells
	#$Table.HeaderRowRange[2].Columns.Cells.Text

	

<#
# to format an Excel table header row:
#>
# Import the Excel module
Import-Module Excel

# Get the Excel application object
$excel = New-Object -ComObject Excel.Application

# Open the Excel workbook
$workbook = $excel.Workbooks.Open("C:\path\to\workbook.xlsx")

# Get the worksheet
$worksheet = $workbook.Worksheets.Item("Sheet1")

# Get the table
$table = $worksheet.Tables.Item("Table1")

# Format the header row
$table.Rows(1).Font.Bold = $true
$table.Rows(1).Font.Size = 12
$table.Rows(1).Font.Color = "Blue"

# Save the workbook
$workbook.Save()

# Close the workbook
$workbook.Close()

# Quit Excel
$excel.Quit()





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
		#Center Aligned
		$ExcelCells.Item($row,$col).HorizontalAlignment = -4108
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
		#$col++		
	}#ForEach($object in $FileObjectList)



$Object = $FileObjectList[0]

foreach ($item in $Object.Keys)    
{   

	$key = $item                
	$value = $Object.$key.value        
	$valueOut = "`"" + $value + "`""
	$keyOut = "`$" + $item 
	Write-Host -ForegroundColor White -NoNewline "$keyOut = "
	Write-Host -ForegroundColor Cyan $valueOut
	<#
	Write-Host -ForegroundColor White -NoNewline "`$key=`""
	Write-Host -ForegroundColor Cyan "`"$item`""

	Write-Host -ForegroundColor White -NoNewline "`$value=`""
	Write-Host -ForegroundColor Cyan "`"$value`""
	#>
	$i++       
		
	For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
	Write-Host "`n"
}


$i=0
ForEach ($item in $object.GetEnumerator())
{
	$key = $item.Name                
	$value = $item.Value  

	Write-Host -ForegroundColor White -NoNewline "`$key=`""
	Write-Host -ForegroundColor Cyan "`"$key`""

	Write-Host -ForegroundColor White -NoNewline "`$value=`""
	Write-Host -ForegroundColor Green "`"$value`""

	$i++       
		
	For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
	Write-Host "`n"
}




$row = 1
$col = 1	   
ForEach($object in $FileObjectList)
{	
	$col = 1	
	$i=0
	ForEach ($item in $object.GetEnumerator())
`	{
		If($row -eq "1")
		{
			$ExcelCells.Item($row,$col).HorizontalAlignment = -4108
			$ExcelCells.Item($row,$col).VerticalAlignment = -4108
		}
		Else
		{
			$key = $item.Name                
			$value = $item.Value  
			Write-Host -ForegroundColor Yellow "Row=$row Col=$col - [$i]="
			Write-Host -ForegroundColor White -NoNewline "`$key=`""
			Write-Host -ForegroundColor Cyan "`"$key`"`t" -NoNewline

			Write-Host -ForegroundColor White -NoNewline "`$value=`""
			Write-Host -ForegroundColor Green "`"$value`""
			For($j=0;$j -lt 120;$j++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}

			Write-Host "`n"
			$ExcelCells.Item($row,$col) = $value 
			If($col -eq "6" -or $col -eq "7" -or $col -eq "9")
			{
				$ExcelCells.Item($row,$col).HorizontalAlignment = -4108
			}
		}#$row is not 1
		$i++       
		$col++
	}#ForEach ($item in $object.GetEnumerator())
	$row++		
}#ForEach($object in $FileObjectList)
		

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
	#Center Aligned
	$ExcelCells.Item($row,$col).HorizontalAlignment = -4108
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
	#$col++		
}#ForEach($object in $FileObjectList)

































foreach ($item in $Object)    
{
	$item.key
}

$i=0
ForEach ($item in $Object.GetEnumerator())
{
	$key = $item.Name                
	$value = $item.value  
	#$value = $Object.$key.value  
	
	Write-Host -ForegroundColor White -NoNewline "`$key=`""
	Write-Host -ForegroundColor Cyan "`"$key`""

	Write-Host -ForegroundColor White -NoNewline "`$value=`""
	Write-Host -ForegroundColor Green "`"$value`""

	#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] `$name="$item.name -NoNewline
	#Write-Host -ForegroundColor Cyan -BackgroundColor Black "; `$value="$item.value
	#Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] `$item.name="$item.name -NoNewline
	#Write-Host -ForegroundColor Cyan -BackgroundColor Black "; `$item.value="$item.value
}



	<#
	$Table = $ExcelWorkSheet.ListObjects()
	$i = 0
	ForEach($column in $Table.ListColumns)
	{
		
		#$column.TotalsCalculation = 1		
		$i++
		# 4108 = Middle Align
		$Table.HeaderRowRange[$i].Columns.Cells.VerticalAlignment = -4108
		#
		#-4131 = Left Justified
		#-4107 = Center
		#-4152 = Right Justified
		>
		$Table.HeaderRowRange[$i].Columns.Cells.HorizontalAlignment = -4128		
	}
	#>