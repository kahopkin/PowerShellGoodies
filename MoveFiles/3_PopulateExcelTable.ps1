<#
C:\GitHub\PowerShellGoodies\MoveFiles\3_PopulateExcelTable.ps1
PopulateExcelTable
#>
$FileName = ""
Function global:PopulateExcelTable
{
	Param(		 
		 [Parameter(Mandatory = $true)] [Object] $ExcelWorkSheet
		,[Parameter(Mandatory = $true)] [Object] $FileObjectList
		,[Parameter(Mandatory = $false)] [String] $ExcelFileName

		
	)
	
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n`t *************[$today] STARTING 3_PopulateExcelTable *****************"

	$ExcelCells = $ExcelWorkSheet.Cells

	$row = 1
	$col = 1	   

	$InitialRow = $row

	ForEach($object in $FileObjectList)
	{	
		$col = 1	
		$i = 0
		<#
		If($row -eq "1")
		{
			Write-Host -ForegroundColor Yellow "Row[$row]=HeaderRow"			
		}
		#
		Else
		{
			Write-Host -ForegroundColor Yellow "Row[$row]="
		}#>

		$row++
		Write-Host -ForegroundColor Yellow "Row[$row]="
		ForEach ($item in $object.GetEnumerator())
	`	{
			$key = $item.Name                
			$value = $item.Value

			If($row -eq "1")
			{
				$ExcelCells.Item($row,$col).HorizontalAlignment = -4108
				$ExcelCells.Item($row,$col).VerticalAlignment = -4108
			}
			Else
			{	
			<#
				Write-Host -ForegroundColor Yellow "Row=$row Col=$col - [$i]="
				Write-Host -ForegroundColor White -NoNewline "`$key=`""
				Write-Host -ForegroundColor Cyan "`"$key`"`t" -NoNewline

				Write-Host -ForegroundColor White -NoNewline "`$value=`""
				Write-Host -ForegroundColor Green "`"$value`""
				For($j=0;$j -cle 120;$j++){ 
					Write-Host -ForegroundColor Magenta "-" -NoNewline
					If($j -eq 120) {Write-Host -ForegroundColor Magenta "-"}
				}

				
			#>
				$ExcelCells.Item($row,$col) = $value 
				
				Switch($key)
				{	
					{$key -in	"FullFileName","ParentFolder","Notes", "FileName" }
					{
						$ExcelCells.Item($row,$col).HorizontalAlignment = -4131
						$ExcelCells.Item($row,$col).ColumnWidth = 50
					}
					"ParentFolder"
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 20
					}
					"FullPath"
					{
						$ExcelCells.Item($row,$col).ColumnWidth = 60
						#
						Write-Host -ForegroundColor Cyan -NoNewline "`$key=" 
						Write-Host -ForegroundColor Green "`"$value`""	
						#>
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
		#
		For($j=0;$j -cle 120;$j++)
		{ 
			Write-Host -ForegroundColor Magenta "-" -NoNewline
			If($j -eq 120) {Write-Host -ForegroundColor Magenta "-"}
		}#>
		#$row++		
	}#ForEach($object in $FileObjectList)
	
	$row = $row-1
	$col = $col-1
	
	Write-Host -ForegroundColor White "Inserted `$row= "  -NoNewline
	Write-Host -ForegroundColor Cyan $row
	<#
	Write-Host -ForegroundColor White "`$col-1= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$col`""
	#>
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
	
	<#

	Write-Host -ForegroundColor White "`$ExcelFileName= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$ExcelFileName`""
	
	
	#>
	$ExcelWorkSheet.Parent.Save()
	#$ExcelWorkSheet.Parent.Close()
	
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n`t *************[$today] FINISHED 3_PopulateExcelTable *****************"
	return $ExcelWorkSheet
}#Function PopulateExcelTable
