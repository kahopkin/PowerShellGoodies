#####################################################
#from getNessusInfo

$PSConsole = $HOST.UI.RawUI
$Width = 300
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
$WindowSize = $PSConsole.WindowSize
$WindowSize.Width = $Width
$WindowSize.Height = $Height
$PSConsole.Windowsize = $WindowSize
##############################################################
