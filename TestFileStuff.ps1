& "$PSScriptRoot\CreateExcelNamedTableWithHeaders.ps1"


Function GetFiles 
{ 
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)


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

	$debugFlag = $true    
	$path = $Source
	$OutFile = $Destination + '\ResourcesLong.txt'
	$OutFileShort = $Destination + 'ResourcesShort.txt'   	
	
	$Excel = New-Object -ComObject Excel.Application
	#$ExcelWorkBook = $Excel.Workbooks.Open($path)
	$ExcelWorkBook = $Excel.Workbooks.Add()
	
	

	$ExcelWorkSheet = CreateExcelTable `
							-WorksheetName $WorksheetName `
							-TableName $TableName `
							-Headers $RARTableHeaders

	# Loop through all directories 
	$dirs = Get-ChildItem -Path $path -Recurse | Sort-Object | Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object  
	
	#$dirs = Get-ChildItem -Path $path | Where-Object { $_.PSIsContainer -eq $true } | Sort-Object  

	#$dirs = Get-ChildItem -Path $path -Recurse | Where-Object {$_.DirectoryName -notin $excludeMatch} | Sort-Object 
	

	#$psCommand =  "`nGet-AzResource  ```n`t`t" + 
	$psCommand =  "`n`$dirs = `n`tGet-ChildItem  ```n`t`t" +     
						  "-Path `"" + $path + "`" ```n`t`t" +
						  "-Recurse  | Sort-Object " + 
						  "```n`t`t" + " | " + 
						  "Where-Object{ " + "`$_.PSIsContainer -eq `$true }" + "`n`t`t" 
	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[41]:"         
		Write-Host -ForegroundColor Green $psCommand
	}#If($debugFlag) #> 

	#get # of folders and files:
	$FolderCount = (Get-ChildItem -Path $path -Recurse -Directory | Measure-Object).Count
	$FileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count
	"# of folders= "+ $FolderCount
	"# of FileCount= "+ $FileCount

}#GetFiles