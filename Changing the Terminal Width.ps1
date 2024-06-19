<#
https://www.nsoftware.com/kb/articles/powershell-server-changing-terminal-width.rst
Changing the Terminal Width
#>

#####################################################
#from getNessusInfo

$PSConsole = $HOST.UI.RawUI
$Width = 250
$Height = 52


$BufferSize = $PSConsole.BufferSize
$WindowSize = $PSConsole.WindowSize

Write-Host -ForegroundColor White "`$BufferSize=" -NoNewline
Write-Host -ForegroundColor Green "`"$BufferSize`""

Write-Host -ForegroundColor White "`$WindowSize=" -NoNewline
Write-Host -ForegroundColor Green "`"$WindowSize`""

$BufferSize.Width = $Width
#$WindowSize.Width = $Width
$BufferSize.Height = "3000"
$PSConsole.Buffersize = $BufferSize
$WindowSize = $PSConsole.WindowSize
$WindowSize.Width = $Width
$WindowSize.Height = $Height
$PSConsole.Windowsize = $WindowSize
##############################################################




$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (500, 25)


if( $Host -and $Host.UI -and $Host.UI.RawUI ) {
 $rawUI = $Host.UI.RawUI
 $oldSize = $rawUI.BufferSize
 $typeName = $oldSize.GetType( ).FullName
 $newSize = New-Object $typeName (500, $oldSize.Height)
 $rawUI.BufferSize = $newSize
}



# Update output buffer size to prevent clipping in Visual Studio output window.
if( $Host -and $Host.UI -and $Host.UI.RawUI ) {
  $rawUI = $Host.UI.RawUI
  $oldSize = $rawUI.BufferSize
  $typeName = $oldSize.GetType( ).FullName
  $newSize = New-Object $typeName (500, $oldSize.Height)
  $rawUI.BufferSize = $newSize
}


$Width = $host.UI.RawUI.MaxPhysicalWindowSize.Width
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size($Width,2000)



################################

# Get the PowerShell Host.
$pshost = Get-Host
$phost

# Get the PowerShell Host's UI.
$pswindow = $pshost.UI.RawUI
$pswindow 
#Write-Host -ForegroundColor Cyan "`$pshost=`"$pshost`""
#Write-Host -ForegroundColor Cyan "`$pswindow=`"$pswindow`""

# Get the UI's current Buffer Size.
$newsize = $pswindow.BufferSize 
$newsize

# Set the new buffer's width to 150 columns.
$newsize.width = 200
$newsize

# Set the new Buffer Size as active.
$pswindow.buffersize = $newsize
$pswindow
#Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""

# Get the UI's current Window Size.
$newsize = $pswindow.WindowSize 
$newsize

# Set the new Window Width to 150 columns.
$newsize.width = 250
$newsize

$pswindow.windowsize = $newsize # Set the new Window Size as active.
$pswindow