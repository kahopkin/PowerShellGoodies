$SourceFolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
$SourceFileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count
#
Write-Host -ForegroundColor Green "`$Source=" -NoNewline
Write-Host -ForegroundColor White "`"$Source`""

Write-Host -ForegroundColor Green "`$Destination=" -NoNewline
Write-Host -ForegroundColor White "`"$Destination`""

Write-Host -ForegroundColor Green "`$SourceFolderCount= "  -NoNewline
Write-Host -ForegroundColor White $SourceFolderCount

Write-Host -ForegroundColor Green "`$SourceFileCount= "  -NoNewline
Write-Host -ForegroundColor White $SourceFileCount

$DestinationFolderCount = (Get-ChildItem -Path $Destination -Recurse -Directory | Measure-Object).Count
$DestinationFileCount = (Get-ChildItem -Path $Destination -Recurse -File | Measure-Object).Count


Write-Host -ForegroundColor Green "`$DestinationFolderCount= "  -NoNewline
Write-Host -ForegroundColor White $DestinationFolderCount

Write-Host -ForegroundColor Green "`$DestinationFileCount= "  -NoNewline
Write-Host -ForegroundColor White $DestinationFileCount