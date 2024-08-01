<#
#C:\GitHub\PowerShellGoodies\MoveFiles\1A_FolderAndFileCount.ps1
#>

Function global:CountChildItems
{
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)
	#
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "#" -NoNewline
		If($j -eq 120) {Write-Host -ForegroundColor Magenta -BackgroundColor Black "#"}
	}#>
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n`t *************[$today] STARTING 1A_FolderAndFileCount *****************"
		
	#
	If($debugFlag){			
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "INCOMING PARAMS:"
		Write-Host -ForegroundColor White "`$Source=" -NoNewline
		Write-Host -ForegroundColor Green "`"$Source`""	
		Write-Host -ForegroundColor White "`$Destination=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$Destination`""
		For($j=0;$j -cle 120;$j++)
		{ 
			Write-Host -ForegroundColor Magenta "=" -NoNewline
			If($j -eq 120) {Write-Host -ForegroundColor Magenta "="}
		}	
	}#If($debugFlag) #> 


	#
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "*" -NoNewline
		If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "*"}
	}#>
	

	#Print Source and Destination Folder/File Counts:
	$SourceFolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
	$SourceFileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count

	Write-Host -ForegroundColor Green "`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""

	Write-Host -ForegroundColor Cyan "`$SourceFolderCount= "  -NoNewline
	Write-Host -ForegroundColor White $SourceFolderCount

	Write-Host -ForegroundColor Cyan "`$SourceFileCount= "  -NoNewline
	Write-Host -ForegroundColor White $SourceFileCount

	
	$DestinationFolderCount = (Get-ChildItem -Path $Destination -Recurse -Directory | Measure-Object).Count
	$DestinationFileCount = (Get-ChildItem -Path $Destination -Recurse -File | Measure-Object).Count
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "*" -NoNewline
		If($j -eq 120) {Write-Host -ForegroundColor Magenta -BackgroundColor Black "*"}
	}#>

	Write-Host -ForegroundColor Green "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""

	Write-Host -ForegroundColor Cyan "`$DestinationFolderCount= "  -NoNewline
	Write-Host -ForegroundColor White $DestinationFolderCount

	Write-Host -ForegroundColor Cyan "`$DestinationFileCount= "  -NoNewline
	Write-Host -ForegroundColor White $DestinationFileCount

	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "*" -NoNewline
		If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "*"}
	}#>
	
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n`t *************[$today] FINISHED 1A_FolderAndFileCount *****************"
}#Function CountChildItems