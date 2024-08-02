<#
#C:\GitHub\PowerShellGoodies\MoveFiles\1A_FolderAndFileCount.ps1
#>

$FileName = ""

Function global:CountChildItems
{
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)
	#
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Magenta "#" -NoNewline
		If($j -eq 120) {Write-Host -ForegroundColor Magenta "#"}
	}#>
	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Yellow "`n`t *************[$today] STARTING 1A_FolderAndFileCount *****************"
		
	#
	If($debugFlag){			
		Write-Host -ForegroundColor Magenta "`tINCOMING PARAMS:"
		Write-Host -ForegroundColor White "`$Source=" -NoNewline
		Write-Host -ForegroundColor Green "`"$Source`""	
		Write-Host -ForegroundColor White "`$Destination=" -NoNewline
		Write-Host -ForegroundColor Cyan "`"$Destination`""
		#
		For($j=0;$j -cle 120;$j++)
		{ 
			Write-Host -ForegroundColor Yellow "=" -NoNewline
			If($j -eq 120) {Write-Host -ForegroundColor Yellow "="}
		}#>	
	}#If($debugFlag) #> 

	#Print Source and Destination Folder/File Counts:
		
	$SourceFolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
	$SourceFileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count
	Write-Host -ForegroundColor Green "`t`tSource Folder and File Count:".ToUpper()0
	Write-Host -ForegroundColor Green "`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""

	Write-Host -ForegroundColor Cyan "`$SourceFolderCount= "  -NoNewline
	Write-Host -ForegroundColor White $SourceFolderCount

	Write-Host -ForegroundColor Cyan "`$SourceFileCount= "  -NoNewline
	Write-Host -ForegroundColor White $SourceFileCount
	#
	For($j=0;$j -cle 120;$j++)
	{ 
		Write-Host -ForegroundColor Green "*" -NoNewline
		If($j -eq 120) {Write-Host -ForegroundColor Green "*"}
	}#>
	
	$DestinationFolderCount = 
	$DestinationFileCount = 0
	Write-Host -ForegroundColor Green "`t`tDestination Folder and File Count:".ToUpper()
	If(Test-Path $Destination)
	{	
		$DestinationFolderCount = (Get-ChildItem -Path $Destination -Recurse -Directory | Measure-Object).Count
		$DestinationFileCount = (Get-ChildItem -Path $Destination -Recurse -File | Measure-Object).Count
				
		Write-Host -ForegroundColor Green "`$Destination=" -NoNewline
		Write-Host -ForegroundColor White "`"$Destination`""

		Write-Host -ForegroundColor Cyan "`$DestinationFolderCount= "  -NoNewline
		Write-Host -ForegroundColor White $DestinationFolderCount

		Write-Host -ForegroundColor Cyan "`$DestinationFileCount= "  -NoNewline
		Write-Host -ForegroundColor White $DestinationFileCount
		#
		For($j=0;$j -cle 120;$j++)
		{ 
			Write-Host -ForegroundColor Green "*" -NoNewline
			If($j -eq 120) {Write-Host -ForegroundColor Green "*"}
		}#>

	}#If(Test-Path)
	Else
	{
		Write-Host -ForegroundColor Red -BackgroundColor Black "`$DestinationFolder=" -NoNewline
		Write-Host -ForegroundColor White -BackgroundColor Black "`"$DestinationFolder`"" -NoNewline
		Write-Host -ForegroundColor Red -BackgroundColor Black " DOES NOT EXIST YET!"
		Write-Host -ForegroundColor Red -BackgroundColor Black "`$DestinationFolderCount= "  -NoNewline
		Write-Host -ForegroundColor White -BackgroundColor Black $DestinationFolderCount
		Write-Host -ForegroundColor Red -BackgroundColor Black "`$DestinationFileCount= "  -NoNewline
		Write-Host -ForegroundColor White -BackgroundColor Black $DestinationFileCount
		#
		For($j=0;$j -cle 120;$j++)
		{ 
			Write-Host -ForegroundColor Green "*" -NoNewline
			If($j -eq 120) {Write-Host -ForegroundColor Green "*"}
		}#>
	}#Else

	$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
	Write-Host -ForegroundColor Yellow "`n`t *************[$today] FINISHED 1A_FolderAndFileCount *****************"
}#Function CountChildItems