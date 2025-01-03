﻿<#
C:\GitHub\PowerShellGoodies\MoveFiles\1_GetFiles.ps1

$Source = The folder that is being copied/moved
$Destination = Parent folder where the Source folder and its contents will be copied/moved ToString
#>
using namespace System.Collections.Generic
$FileName = ""
Function global:GetFiles 
{ 
	Param(
		 [Parameter(Mandatory = $true)] [String] $Source
		,[Parameter(Mandatory = $true)] [String] $Destination
		
	)
	<#
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Yellow "#" -NoNewline
		If($j -eq 120) {Write-Host -ForegroundColor Yellow "#"}
	}#>
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Yellow "`n`t *************[$today] STARTING 1_GetFiles *****************"
		
	#
	If($debugFlag){			
		Write-Host -ForegroundColor Yellow "`tINCOMING PARAMS:"
		Write-Host -ForegroundColor White "`$Source=" -NoNewline
		Write-Host -ForegroundColor Green "`"$Source`""	
		Write-Host -ForegroundColor White "`$Destination=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$Destination`""
	}#If($debugFlag) #> 


	$SourceFolder = Get-Item -Path $Source
	$SourceFolderName = $SourceFolder.Name
	$DestinationFolder = $Destination + "\" + $SourceFolderName
		
	#Print out the folder and filecount for the source and destination
	#CountChildItems -Source $Source -Destination $DestinationFolder

	$FileObjectList = New-Object System.Collections.Generic.List[System.String]		

	# Loop through all directories 
	#If($Source.Length -lte 260)
	$DirectoryObjects = Get-ChildItem -Path $Source -Recurse | Sort-Object
		
	#$DirectoryObjects = Get-ChildItem -Path $Source -Recurse | Where-Object  { $_.PSIsContainer -eq $true } | Sort-Object  
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
	
	Foreach ($item In $DirectoryObjects) 
	{ 
		
		$FullPath =  $item.FullName
		$FileName = $item.BaseName        
		$ParentFolder = Split-Path (Split-Path $item.FullName -Parent) -Leaf
		$ParentFolderPath = $item.Parent.FullName
		$Extension = $item.Extension
		
		$CreationTime = $item.CreationTime.ToString("MM/dd/yyyy HH:mm:ss")
		$LastWriteTime = $item.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")		
		If(Test-Path $FullPath)
		{
			$FullFileName = Split-Path $item.FullName -Leaf -Resolve
		}
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
		$DirPath = $item.FullName
		<#
			Write-Host -ForegroundColor Yellow "`$Source=" -NoNewline
			Write-Host -ForegroundColor Cyan "`"$Source`""
		#>

		$file = Get-ChildItem -Path $DirPath -Recurse -Force `
						| Where-Object { $_.PSIsContainer -eq $false } `
						| Measure-Object -property Length -sum | Select-Object Sum    

		$psCommand =  "`n`$file = `n`tGet-ChildItem  ```n`t`t" +     
							"-Path `"" + $DirPath + "`" -Recurse -Force ```n`t`t" +                          
							"| Where-Object { $_.PSIsContainer -eq $false } `n`t`t" +                            
							"| Measure-Object { $_.PSIsContainer -eq $false } ```n" 
		
		<#
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "[121]:"         
				Write-Host -ForegroundColor Green $psCommand
		}#If($debugFlag) #> 

		$Notes = $Destination + "\" + $FullFileName

		$Size = $file.sum 
		$SizeKB =  "{0:N2}"-f ($Size / 1KB) + " KB"
		$SizeMB =  "{0:N2}"-f ($Size / 1MB) + " MB"
		$SizeGB =  "{0:N2}"-f ($Size / 1GB) + " GB"
		
		$Size =  "{0:N0}"-f ($Size / 1KB)
				
		if($isDir)  
		{
			$Extension="Folder"
			$ItemType = "Folder"	
			#If folder is empty: DELETE it!
			If($SizeKB -eq "0.00 KB")
			{                
				Write-Host -ForegroundColor Red "DELETING EMPTY FOLDER: " -NoNewline			    
				Write-Host -ForegroundColor Yellow "`n`t`$FullFileName=" -NoNewline			
				Write-Host -ForegroundColor Cyan "`"$FullFileName`""
			
				Write-Host -ForegroundColor Green "`$SizeKB=" -NoNewline
				Write-Host -ForegroundColor White $SizeKB

				Write-Host -ForegroundColor Green "`$Size=" -NoNewline
				Write-Host -ForegroundColor White $Size
				Remove-Item -Path $DirPath			
			}#If($Size -eq "0")
			else
			{
				#get # of folders and files:
				$FolderCount = (Get-ChildItem -Path $DirPath -Recurse -Directory | Measure-Object).Count
				$FileCount = (Get-ChildItem -Path $DirPath -Recurse -File | Measure-Object).Count
				If($FolderCount -ne 0)
				{
					#
					Write-Host -ForegroundColor Cyan "`$DirPath=" -NoNewline
					Write-Host -ForegroundColor White "`"$DirPath`""

					Write-Host -ForegroundColor Yellow "`$ParentFolder=" -NoNewline
					Write-Host -ForegroundColor White "`"$ParentFolder`""
					Write-Host -ForegroundColor Yellow "`$ParentFolderPath=" -NoNewline
					Write-Host -ForegroundColor White "`"$ParentFolderPath`""

					Write-Host -ForegroundColor Cyan "`$FolderCount= "  -NoNewline
					Write-Host -ForegroundColor White $FolderCount

					Write-Host -ForegroundColor Cyan "`$FileCount= "  -NoNewline
					Write-Host -ForegroundColor White $FileCount				
					
					For($j=0;$j -cle 120;$j++)
					{ 
						Write-Host -ForegroundColor Cyan "-" -NoNewline
						If($j -eq 120){Write-Host -ForegroundColor Cyan "-"}
					}#For
				}#If($FolderCount -eq 0)
				else
				{
					Write-Host -ForegroundColor Green "`$DirPath=" -NoNewline
					Write-Host -ForegroundColor White "`"$DirPath`""
					Write-Host -ForegroundColor Cyan "`$FileCount= "  -NoNewline
					Write-Host -ForegroundColor White $FileCount				
					
					For($j=0;$j -cle 120;$j++)
					{ 
						Write-Host -ForegroundColor Cyan "-" -NoNewline
						If($j -eq 120){Write-Host -ForegroundColor Cyan "-"}
					}#For
				}
				
			}#else	
		}#if($isDir)  
		else
		{		 
			<#
			Write-Host -ForegroundColor White "`$FullFileName=" -NoNewline
			Write-Host -ForegroundColor Green "`"$FullFileName`""

			Write-Host -ForegroundColor White "`$FullPath=" -NoNewline
			Write-Host -ForegroundColor Green "`"$FullPath`""
			#>
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
	
	
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Yellow"`n`t *************[$today] FINISHED 1_GetFiles *****************"

	return $FileObjectList
}#GetFiles


Function GetItemSize{
	Param(
		 [Parameter(Mandatory = $true)] [String]$DirPath
	)
		$file = Get-ChildItem -Path $DirPath -Recurse -Force `
						| Where-Object { $_.PSIsContainer -eq $false } `
						| Measure-Object -property Length -sum | Select-Object Sum    

		$psCommand =  "`n`$file = `n`tGet-ChildItem  ```n`t`t" +     
							"-Path `"" + $DirPath + "`" -Recurse -Force ```n`t`t" +                          
							"| Where-Object { $_.PSIsContainer -eq $false } `n`t`t" +                            
							"| Measure-Object { $_.PSIsContainer -eq $false } ```n" 
		
		<#
		If($debugFlag){
			Write-Host -ForegroundColor Magenta "[121]:"         
			Write-Host -ForegroundColor Green $psCommand
		}#If($debugFlag) #> 

		$Notes = $Destination + "\" + $FullFileName

		$Size = $file.sum 
		$SizeKB =  "{0:N2}"-f ($Size / 1KB) + " KB"
		$SizeMB =  "{0:N2}"-f ($Size / 1MB) + " MB"
		$SizeGB =  "{0:N2}"-f ($Size / 1GB) + " GB"
		
		$Size =  "{0:N0}"-f ($Size / 1KB)				
}#GetItemSize