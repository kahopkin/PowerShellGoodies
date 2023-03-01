<#
https://adamtheautomator.com/arm-output/
to run:
$(System.DefaultWorkingDirectory)\parse_arm_deployment_output.ps1 -ArmOutputString '$armOutput' -MakeOutput -ErrorAction Stop
$(System.DefaultWorkingDirectory)\parse_arm_deployment_output.ps1 -ArmOutputString '$(armOutput)' -MakeOutput -ErrorAction Stop
.\parse_arm_deployment_output.ps1 -ArmOutputString $armOutput -MakeOutput -ErrorAction Stop
#>

#parse_arm_deployment_output.ps1
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ArmOutputString,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [switch]$MakeOutput
)

Write-Output "Retrieved input: $ArmOutputString"
$armOutputObj = $ArmOutputString | ConvertFrom-Json

$armOutputObj.PSObject.Properties | ForEach-Object {
    $type = ($_.value.type).ToLower()
    $keyname = $_.Name
    #$vsoAttribs = @("task.setvariable variable=$keyName")

    if ($type -eq "array") 
    {
        $value = $_.Value.value.name -join ',' 
        ## All array variables will come out as comma-separated strings
        Write-host -ForegroundColor Cyan $value
    } 
    elseif ($type -eq "object")
    {
        Write-Host -ForegroundColor Red 
    }
    elseif ($type -eq "securestring") 
    {
        $vsoAttribs += 'isSecret=true'
    } 
    elseif ($type -ne "string") 
    {
        throw "Type '$type' is not supported for '$keyname'"
    } 

    else {
        $value = $_.Value.value
    }
        
    <#if ($MakeOutput.IsPresent) {
        $vsoAttribs += 'isOutput=true'
    }
    #>
    #$attribString = $vsoAttribs -join ';'
    #$var = "##vso[$attribString]$value"
    #Write-Output -InputObject $var
    Write-Host $value
}


