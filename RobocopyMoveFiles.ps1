<#
#>



Function global:RobocopyMoveFiles
{
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n *************[$today] START RobocopyMoveFiles *****************"
	<#Write-Host -ForegroundColor White -BackgroundColor Black "Source= " $Source 	
	#Write-Host -ForegroundColor Magenta -BackgroundColor Black 
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "to $Destination *****************"
	#>

	Write-Host -ForegroundColor Yellow "`$Source=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Source`""

	Write-Host -ForegroundColor Yellow "`$FolderCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FolderCount`""

	Write-Host -ForegroundColor Yellow "`$FileCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FileCount`""

	Write-Host -ForegroundColor Yellow "`$Destination=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Destination`""	
 
	$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy-HH-mm-ss')
	$LogFile = $TodayFolderPath = $Destination + "\" + $TodayFolder + ".log"

	#get # of folders and files:
	$FolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
	$FileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count
	
	


	<# To move all files and folders, including empty ones, with all attributes. 
	 #Note that the source folder will also be deleted.
	 robocopy c:\temp\source c:\temp\destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3
	 #>

	robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3 /LOG:$LogFile
	#robocopy $Source $Destination /E /COPYALL /COPY:DAT /MOVE /R:100 /W:3 /LOG:$LogFile
	#robocopy $Source $Destination /COPYALL /COPY:DAT /MOVE /R:100 /W:3
	#robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /MOVE /W:3

	$psCommand =  "`n robocopy """ + 
			$Source + "`" """ + 
			$Destination + """ " +
			"/E /COPYALL /DCOPY:DAT  /MOVE /R:100 /W:3 "+ 
			"/LOG:""" +
			$LogFile + "`""     

	#Write-Host -ForegroundColor Cyan $psCommand
	
	#explorer $Destination
	explorer $LogFile

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED RobocopyMoveFiles from $Source to $Destination *****************"
}#Function global:RobocopyMoveFiles

<#
$Source = ""

$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ChiefArchitect"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"

MoveFiles -ParentFolder $Source -BicepFolder $Destination
#>