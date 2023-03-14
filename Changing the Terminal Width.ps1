<#
https://www.nsoftware.com/kb/articles/powershell-server-changing-terminal-width.rst
Changing the Terminal Width
#>

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
$newsize.width = 150
$newsize

# Set the new Buffer Size as active.
$pswindow.buffersize = $newsize
$pswindow
#Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""

# Get the UI's current Window Size.
$newsize = $pswindow.WindowSize 
$newsize

# Set the new Window Width to 150 columns.
$newsize.width = 150
$newsize

$pswindow.windowsize = $newsize # Set the new Window Size as active.
$pswindow




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