$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"  
Write-Host -ForegroundColor Green "`$StartTime=" -NoNewline
Write-Host -ForegroundColor White "`"$StartTime`""

#
robocopy `
"C:\Users\kahopkin\OneDrive - Microsoft\Training" `
"C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\Training" `
/S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
#>

<#
 robocopy `
 "C:\Users\kahopkin\OneDrive - Microsoft\Training" `
 "D:\MS-Surface-E6F1US5\Training" `
 /S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
 #>


$EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
$Duration = New-TimeSpan -Start $StartTime -End $EndTime


Write-Host -ForegroundColor White "`$StartTime=" -NoNewline
Write-Host -ForegroundColor Green "`"$StartTime`""
Write-Host -ForegroundColor White "`$EndTime=" -NoNewline
Write-Host -ForegroundColor Cyan "`"$EndTime`""
Write-Host -ForegroundColor White "DURATION [HH:MM:SS]:"-Nonewline
Write-Host -ForegroundColor Yellow $Duration
