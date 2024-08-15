<#
#C:\GitHub\PowerShellGoodies\FoldersAndFiles\DeleteEmptyFolders.ps1
#>

$FileName = ""

Function global:DeleteEmptyFolders 
{ 
	Param(
		 [Parameter(Mandatory = $true)] [String] $Source
	)
	
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n`t *************[$today] STARTING DeleteEmptyFolders *****************"
		
	#
	If($debugFlag){			
		Write-Host -ForegroundColor Yellow "`tINCOMING PARAMS:"
		Write-Host -ForegroundColor White "`$Source=" -NoNewline
		Write-Host -ForegroundColor Green "`"$Source`""			
	}#If($debugFlag) #> 

	$SourceFolder = Get-Item -Path $Source
	$SourceFolderName = $SourceFolder.Name
	#
	If($debugFlag){	
		Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`$Source=" -NoNewline
		Write-Host -ForegroundColor White -BackgroundColor Black  "`"$Source`""	
		Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`$SourceFolderName=" -NoNewline
		Write-Host -ForegroundColor White -BackgroundColor Black  "`"$SourceFolderName`""			
	}#If($debugFlag) #> 



	$tailRecursion = {
	param(
		$Path
	)
	foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
		& $tailRecursion -Path $childDirectory.FullName
	}
	$currentChildren = Get-ChildItem -Force -LiteralPath $Path
	$isEmpty = $currentChildren -eq $null
	if ($isEmpty) {
		Write-Verbose "Removing empty folder at path '${Path}'." -Verbose
		Remove-Item -Force -LiteralPath $Path
	}
}

	#invoke
	& $tailRecursion -Path $Source

	exit(1)
			
	$DirectoryObjects = Get-ChildItem -Path $Source -Recurse | Where-Object { $_.PSIsContainer -eq $true } | Sort-Object  
			
	$psCommand =  "`n`$DirectoryObjects = `n`tGet-ChildItem  ```n`t`t" +     
						  "-Path `"" + $Source + "`" ```n`t`t" +
						  "-Recurse " + "```n`t`t" + " | " + 
						  "Where-Object{ " + "`$_.PSIsContainer -eq `$true }" + " | Sort-Object" 
	#
	If($debugFlag){
		Write-Host -ForegroundColor Magenta "[42]:"         
		Write-Host -ForegroundColor Green $psCommand
		Write-Host -ForegroundColor Magenta  "`$DirectoryObjects.Count=" -NoNewline
		Write-Host -ForegroundColor White $DirectoryObjects.Count
	}#If($debugFlag) #>
	
	$i = 0
	$DeleteCount = 0
	Foreach ($item In $DirectoryObjects) 
	{ 		
		$FullPath =  $item.FullName
		$FileName = $item.BaseName        
		$FullFileName = Split-Path $item.FullName -Leaf -Resolve
	

		$FolderCount = (Get-ChildItem -Path $FullPath -Recurse -Directory | Measure-Object).Count
		$FileCount = (Get-ChildItem -Path $FullPath -Recurse -File | Measure-Object).Count
		$ItemCount = (Get-ChildItem -Path $FullPath -Recurse | Measure-Object).Count

		
		<#
			If($debugFlag){
				Write-Host -ForegroundColor Magenta "[121]:"         
				Write-Host -ForegroundColor Green $psCommand
		}#If($debugFlag) #> 
			
		#If folder is empty: DELETE it!
		If($FolderCount -eq 0)
		{
			$DeleteCount++
			Write-Host -ForegroundColor Red "[$i]="
			Write-Host -ForegroundColor Red "DELETING EMPTY FOLDER: " -NoNewline			
			Write-Host -ForegroundColor White "`$FullPath=" -NoNewline
			Write-Host -ForegroundColor Cyan "`"$FullPath`""

			Write-Host -ForegroundColor Green "`$FolderCount=" -NoNewline
			Write-Host -ForegroundColor White "`"$FolderCount`""

			Write-Host -ForegroundColor Cyan "`$FileCount= "  -NoNewline
			Write-Host -ForegroundColor White $FileCount

			Write-Host -ForegroundColor Cyan "`$ItemCount= "  -NoNewline
			Write-Host -ForegroundColor White $ItemCount
			#
			For($j=0;$j -cle 120;$j++)
			{ 
				Write-Host -ForegroundColor Red "-" -NoNewline
				If($j -eq 120) {Write-Host -ForegroundColor Red "-"}
			}#>
			
			#Remove-Item -Path $FullPath	-Recurse -Confirm:$false		
			Remove-Item -Path $FullPath	-Confirm:$false		
		}#If($Size -eq "0")
		$i++
	}# Foreach ($item In $DirectoryObjects) 

	Write-Host -ForegroundColor Red "DELETED `$DeleteCount= "  -NoNewline
	Write-Host -ForegroundColor White $DeleteCount -NoNewline
	Write-Host -ForegroundColor Red "Folders"

	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n`t *************[$today] FINISHED DeleteEmptyFolders *****************"

}#DeleteEmptyFolders