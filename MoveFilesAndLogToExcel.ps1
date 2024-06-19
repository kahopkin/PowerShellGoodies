using namespace System.Collections.Generic

& "$PSScriptRoot\CreateExcelTable.ps1"
& "$PSScriptRoot\RobocopyMoveFiles.ps1"

# Import the required modules
#Import-Module -Name ImportExcel

Function global:GetFiles 
{ 
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] STARTING MoveFilesAndLogToExcel *****************"

	$debugFlag = $true

	
	Write-Host -ForegroundColor Red "`n Moving files" 
	Write-Host -ForegroundColor White "from Source Folder:`n`$Source=" -NoNewline
	Write-Host -ForegroundColor Green "`"$FullPath`""
	Write-Host -ForegroundColor White "To Destination Folder:`n`$Destination=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Destination`""

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
	

	$global:ExcelWorkBook = 
	$global:ExcelWorkSheet = 
	$global:Table =
	$global:FileObjectList =
	$global:FileObjList = 
	$global:DirectoryObjects = $null

	$FileObjectList = New-Object System.Collections.Generic.List[System.String]


	$SourceFolder = Get-Item -Path $Source

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
		
		<#
		If($debugFlag){
			Write-Host -ForegroundColor Magenta "[121]:"         
			Write-Host -ForegroundColor Green $psCommand
		}#If($debugFlag) #> 

		$Size = $file.sum 
		$SizeKB =  "{0:N2}"-f ($Size / 1KB) + " KB"
		$SizeMB =  "{0:N2}"-f ($Size / 1MB) + " MB"
		$SizeGB =  "{0:N2}"-f ($Size / 1GB) + " GB"

		$Notes = $Destination + "\" + $FullFileName
		if($isDir)  
		{
			$Extension="Folder"
			$ItemType = "Folder"
			$FileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count
			<#
			Write-Host -ForegroundColor Yellow "Folder:" -NoNewline
			Write-Host -ForegroundColor Yellow "`n`t`$FullFileName=" -NoNewline			
			Write-Host -ForegroundColor Cyan "`"$FullFileName`""
			#>

			Write-Host -ForegroundColor White "`$FullPath=" -NoNewline
			Write-Host -ForegroundColor Green "`"$FullPath`""

			Write-Host -ForegroundColor Yellow "`t`$FileCount= "  -NoNewline
			Write-Host -ForegroundColor Cyan "`"$FileCount`""
			#>

		}#if($isDir)  
		else
		{
		 
			<#
			Write-Host -ForegroundColor White "`$FullFileName=" -NoNewline
			Write-Host -ForegroundColor Green "`"$FullFileName`""
			#>
			Write-Host -ForegroundColor White "`$FullPath=" -NoNewline
			Write-Host -ForegroundColor Green "`"$FullPath`""

			$ItemType = "File"
			$FileCount = 0
			
		}#else
				
		$FileObj = [ordered]@{	
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
		
		$FileObjectList += $FileObj
		
	}# Foreach ($item In $DirectoryObjects) 
	
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Magenta "=" -NoNewline
		If($j -eq 120){Write-Host "="}
	}
	Write-Host -ForegroundColor White "`$FolderCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FolderCount`""

	Write-Host -ForegroundColor White "`$FileCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FileCount`""
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Magenta "=" -NoNewline
		If($j -eq 120){Write-Host "="}
	}
	
	
	$ExcelWorkSheet = CreateExcelTable `
								-ExcelWorkBook $ExcelWorkBook `
								-WorksheetName $WorksheetName `
								-TableName $TableName `
								-Headers $Headers 
	
	#PopulateExcelTable -ExcelWorkSheet $ExcelWorkSheet -FileObjectList $FileObjectList
	$ExcelCells = $ExcelWorkSheet.Cells

	$row = 1
	$col = 1	   

	$InitialRow = $row

	ForEach($object in $FileObjectList)
	{	
		$col = 1	
		$i=0
		If($row -eq "1")
		{
			Write-Host -ForegroundColor Yellow "HeaderRow="
		}
		Else
		{
			Write-Host -ForegroundColor Yellow "Row[$row]="
		}
		
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
				
			<#
				Write-Host -ForegroundColor Yellow "Row=$row Col=$col - [$i]="
				Write-Host -ForegroundColor White -NoNewline "`$key=`""
				Write-Host -ForegroundColor Cyan "`"$key`"`t" -NoNewline

				Write-Host -ForegroundColor White -NoNewline "`$value=`""
				Write-Host -ForegroundColor Green "`"$value`""
				For($j=0;$j -cle 120;$j++){ 
					Write-Host -ForegroundColor Magenta "-" -NoNewline
					If($j -eq 120){Write-Host "-"}
				}

				
			#>
				$ExcelCells.Item($row,$col) = $value 
				
				Switch($key)
				{	
					{$key -in	"FullFileName","ParentFolder","FileName" }
					{
						$ExcelCells.Item($row,$col).HorizontalAlignment = -4131
						$ExcelCells.Item($row,$col).ColumnWidth = 50
					}
					"ParentFolder"
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 15
					}
					"FullPath"
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 60
						Write-Host -ForegroundColor Cyan -NoNewline "$key=" 
						Write-Host -ForegroundColor Green "`"$value`""	
					}
					{$key -in	"FileCount",
								"ItemType",
								"Extension",
								"SizeKB",
								"SizeMB",
								"SizeGB"}
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 10
						$ExcelCells.Item($row,$col).HorizontalAlignment = -4108
					}
					Default
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 15
						$ExcelCells.Item($row,$col).HorizontalAlignment = -4131
						#$ExcelCells.Item($row,$col).ShrinkToFit = $true
					}
				}#Switch
			}#$row is not 1
			$i++       
			$col++
		}#ForEach ($item in $object.GetEnumerator())
		For($j=0;$j -cle 120;$j++)
		{ 
			Write-Host -ForegroundColor Magenta "-" -NoNewline
			If($j -eq 120){Write-Host "-"}
		}
		$row++		
	}#ForEach($object in $FileObjectList)
	
	$row = $row-1
	Write-Host -ForegroundColor White "`$row-1= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$row`""
	$col = $col-1
	Write-Host -ForegroundColor White "`$col-1= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$col`""

	<# VerticalAlignment (1st row in ribbon)
		Top = -4160
		Middle = -4108
		Bottom = -4107
	
		$ExcelCells.Cells.VerticalAlignment = -4108

		# Horizontal Alignment (2nd row in ribbon)
		Left = -4131
		Center = -4108
		Right = -4152
	
		$ExcelCells.Cells.HorizontalAlignment = -4131
		#$ExcelCells.Cells.ShrinkToFit = $true
	#>
	$today = Get-Date -Format "yyyy-MM-dd-HH-mm"
	$ExcelFileName = $Destination + "\" + $today + "_" + "FolderContents.xlsx"
	$ExcelWorkSheet.Parent.SaveAs($ExcelFileName)
	#$ExcelWorkSheet.Parent.Close()
	#$ExcelWorkSheet.Parent.Parent.Quit()
	

	RobocopyMoveFiles -Source $Source -Destination $Destination

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED MoveFilesAndLogToExcel *****************"
}#GetFiles




########################
<#
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
	>



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
		#
		#$Table.HeaderRowRange[$i].Columns.Cells.HorizontalAlignment = -4108
		
	}

	$ExcelCells = $ExcelWorkSheet.Cells


	<# VerticalAlignment (1st row in ribbon)
		Top = -4160
		Middle = -4108
		Bottom = -4107
	#
	$ExcelCells.Cells.VerticalAlignment = -4108

	<# Horizontal Alignment (2nd row in ribbon)
		Left = -4131
		Center = -4128
		Right = -4152
	#
	$ExcelCells.Cells.HorizontalAlignment = -4131
	#$ExcelCells.Cells.ShrinkToFit = $true
	#Align Left
	#$Table.HeaderRowRange[2].Columns.Cells.DisplayFormat.Style.HorizontalAlignment = 2
	#displays the text in the Cells
	#$Table.HeaderRowRange[2].Columns.Cells.Text

	return $ExcelWorkSheet
}#Function CreateExcelTable
#>


#######################


Function global:PopulateExcelTable
{
	Param(
		 [Parameter(Mandatory = $true)] [Object]$ExcelWorkSheet
		,[Parameter(Mandatory = $true)] [Object]$FileObjectList
		
	)
	
	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] STARTING PopulateExcelTable *****************"

	$ExcelCells = $ExcelWorkSheet.Cells

	$row = 1
	$col = 1	   

	$InitialRow = $row

	ForEach($object in $FileObjectList)
	{	
		$col = 1	
		$i=0
		If($row -eq "1")
		{
			Write-Host -ForegroundColor Yellow "HeaderRow="
		}
		Else
		{
			Write-Host -ForegroundColor Yellow "Row[$row]="
		}
		
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
				
			<#
				Write-Host -ForegroundColor Yellow "Row=$row Col=$col - [$i]="
				Write-Host -ForegroundColor White -NoNewline "`$key=`""
				Write-Host -ForegroundColor Cyan "`"$key`"`t" -NoNewline

				Write-Host -ForegroundColor White -NoNewline "`$value=`""
				Write-Host -ForegroundColor Green "`"$value`""
				For($j=0;$j -cle 120;$j++){ 
					Write-Host -ForegroundColor Magenta "-" -NoNewline
					If($j -eq 120){Write-Host "-"}
				}

				
			#>
				$ExcelCells.Item($row,$col) = $value 
				
				Switch($key)
				{	
					{$key -in	"FullFileName","ParentFolder","FileName" }
					{
						$ExcelCells.Item($row,$col).HorizontalAlignment = -4131
						$ExcelCells.Item($row,$col).ColumnWidth = 50
					}
					"ParentFolder"
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 15
					}
					"FullPath"
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 60
						Write-Host -ForegroundColor Cyan -NoNewline "$key=" 
						Write-Host -ForegroundColor Green "`"$value`""	
					}
					{$key -in	"FileCount",
								"ItemType",
								"Extension",
								"SizeKB",
								"SizeMB",
								"SizeGB"}
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 10
						$ExcelCells.Item($row,$col).HorizontalAlignment = -4108
					}
					Default
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 15
						$ExcelCells.Item($row,$col).HorizontalAlignment = -4131
						#$ExcelCells.Item($row,$col).ShrinkToFit = $true
					}
				}#Switch
			}#$row is not 1
			$i++       
			$col++
		}#ForEach ($item in $object.GetEnumerator())
		For($j=0;$j -cle 120;$j++)
		{ 
			Write-Host -ForegroundColor Magenta "-" -NoNewline
			If($j -eq 120){Write-Host "-"}
		}
		$row++		
	}#ForEach($object in $FileObjectList)
	
	$row = $row-1
	Write-Host -ForegroundColor White "`$row-1= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$row`""
	$col = $col-1
	Write-Host -ForegroundColor White "`$col-1= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$col`""

	<# VerticalAlignment (1st row in ribbon)
		Top = -4160
		Middle = -4108
		Bottom = -4107
	
		$ExcelCells.Cells.VerticalAlignment = -4108

		# Horizontal Alignment (2nd row in ribbon)
		Left = -4131
		Center = -4108
		Right = -4152
	
		$ExcelCells.Cells.HorizontalAlignment = -4131
		#$ExcelCells.Cells.ShrinkToFit = $true
	#>
	$today = Get-Date -Format "yyyy-MM-dd-HH-mm"
	$ExcelFileName = $Destination + "\" + $today + "_" + "FolderContents.xlsx"
	$ExcelWorkSheet.Parent.SaveAs($ExcelFileName)
	#$ExcelWorkSheet.Parent.Close()
	#$ExcelWorkSheet.Parent.Parent.Quit()
	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED PopulateExcelTable *****************"
}#Function PopulateExcelTable

<#

$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Exports"

$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Exports\ACAS Excel Exports - Copy"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Exports"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Exports\ACAS Excel Exports - Copy\ODIN Exports"
#>
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\05-28-2024_Solutions"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"

GetFiles -Source $Source -Destination $Destination




