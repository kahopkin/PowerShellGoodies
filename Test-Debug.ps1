<#
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-debug?view=powershell-7.3
use the Debug parameter to override the $DebugPreference value.

The Test-Debug function writes the value of the $DebugPreference variable to the PowerShell host and to the Debug stream. 

#>
function Test-Debug {
    [CmdletBinding()]
    param()

    Write-Debug  ('$DebugPreference is ' + $DebugPreference)
    If($DebugPreference -eq "SilentlyContinue")
    {
        Write-Host -ForegroundColor Green ("Write-Debug messages will NOT display")
    }
    Else
    {
        Write-Host -ForegroundColor Cyan ("Write-Debug messages WILL display")
        Write-Debug ("Write-Debug messages WILL display")
    }
    Write-Host -ForegroundColor Yellow ('$DebugPreference is ' + $DebugPreference)
}

Test-Debug
#$DebugPreference is SilentlyContinue

#Test-Debug -Debug
<#
DEBUG: $DebugPreference is Inquire
$DebugPreference is Inquire

#>
#DEBUG: $DebugPreference is Continue
#$DebugPreference is Continue
#$DebugPreference
#SilentlyContinue


$DebugPreference = "SilentlyContinue"
#SilentlyContinue
Write-Debug "Cannot open file."

$DebugPreference = "Continue"
Write-Debug "Cannot open file."
#DEBUG: Cannot open file.