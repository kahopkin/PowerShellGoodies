#####################################################
#from getNessusInfo

$PSConsole = $HOST.UI.RawUI
$Width = 400
$Height = 52


$BufferSize = $PSConsole.BufferSize
$WindowSize = $PSConsole.WindowSize

Write-Host -ForegroundColor White "`$BufferSize=" -NoNewline
Write-Host -ForegroundColor Green "`"$BufferSize`""

Write-Host -ForegroundColor White "`$WindowSize=" -NoNewline
Write-Host -ForegroundColor Green "`"$WindowSize`""

$BufferSize.Width = $Width
#$WindowSize.Width = $Width
$BufferSize.Height = "30000"
$PSConsole.Buffersize = $BufferSize
#$WindowSize = $PSConsole.WindowSize
#$WindowSize.Width = $Width
#$WindowSize.Height = $Height
#$PSConsole.Windowsize = $WindowSize
##############################################################



#https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-host?view=powershell-7.4&viewFallbackFrom=powershell-6&source=docs
#This command resizes the Windows PowerShell window to 10 lines by 10 characters.
$H = Get-Host
$Win = $H.UI.RawUI.WindowSize
$Win.Height = 10
$Win.Width  = 10
$H.UI.RawUI.Set_WindowSize($Win)