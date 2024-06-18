<#
https://www.nsoftware.com/kb/articles/powershell-server-changing-terminal-width.rst
Changing the Terminal Width
#>


$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (500, 25)

if( $Host -and $Host.UI -and $Host.UI.RawUI ) 
{
    $rawUI = $Host.UI.RawUI
    $oldSize = $rawUI.BufferSize
    Write-Host -ForegroundColor Cyan "[13]`n `$oldSize=" -NoNewline
    Write-Host -ForegroundColor Yellow "`"$oldSize`""
    $typeName = $oldSize.GetType( ).FullName
    $newSize = New-Object $typeName (500, $oldSize.Height)
    $rawUI.BufferSize = $newSize
}



$Width = $host.UI.RawUI.MaxPhysicalWindowSize.Width
Write-Host -ForegroundColor Cyan "[23]`n `$Width=" -NoNewline
Write-Host -ForegroundColor Yellow "`"$Width`""

$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size($Width,2000)


#
# Get the PowerShell Host.
$pshost = Get-Host
$phost

# Get the PowerShell Host's UI.
$pswindow = $pshost.UI.RawUI
$pswindow 
Write-Host -ForegroundColor Cyan "`$pshost=`"$pshost`""
Write-Host -ForegroundColor Cyan "`$pswindow=`"$pswindow`""

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
#$newsize = 150


$pswindow.windowsize = $newsize # Set the new Window Size as active.
$pswindow

#>






<#

# Update output buffer size to prevent clipping in Visual Studio output window.
if( $Host -and $Host.UI -and $Host.UI.RawUI ) 
{
    $rawUI = $Host.UI.RawUI
    $oldSize = $rawUI.BufferSize
    Write-Host -ForegroundColor Cyan "[65]`n `$oldSize=" -NoNewline
    Write-Host -ForegroundColor Yellow "`"$oldSize`""
    $typeName = $oldSize.GetType( ).FullName
    $newSize = New-Object $typeName (500, $oldSize.Height)
    $rawUI.BufferSize = $newSize
}
#>