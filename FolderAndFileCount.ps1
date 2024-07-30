$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts\CapitalOne Visa\CapitalOne Visa"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal"
$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Azure Stuff"
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""

$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts\CapitalOne Visa"
$Destination = "D:\"
$Destination = "D:\Azure Stuff"
#$Destination = ""
#$Destination = ""


$SourceFolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
$SourceFileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count

$DestinationFolderCount = (Get-ChildItem -Path $Destination -Recurse -Directory | Measure-Object).Count
$DestinationFileCount = (Get-ChildItem -Path $Destination -Recurse -File | Measure-Object).Count

#
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow -BackgroundColor Black "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow -BackgroundColor Black "*"}
}#>

Write-Host -ForegroundColor Green "`$Source=" -NoNewline
Write-Host -ForegroundColor White "`"$Source`""

Write-Host -ForegroundColor Cyan "`$SourceFolderCount= "  -NoNewline
Write-Host -ForegroundColor White $SourceFolderCount

Write-Host -ForegroundColor Cyan "`$SourceFileCount= "  -NoNewline
Write-Host -ForegroundColor White $SourceFileCount

If(Test-Path $Destination)
{
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
}#If(Test-Path)
Else
{
	Write-Host -ForegroundColor Red "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""
	Write-Host -ForegroundColor Red " DOES NOT EXIST YET!"
}