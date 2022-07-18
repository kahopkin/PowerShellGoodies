
#UninstallAllModules
<#
    ## – Example using -WhatIf parameter:

Uninstall-AllModules -TargetModule AzureAD -Force
#>

Function Uninstall-AllModules
{
    [CmdletBinding(SupportsShouldProcess)] 
    param (
             [Parameter(Mandatory = $true)][string] $TargetModule
            ,[Parameter(Mandatory = $false)][string] $Version
            ,[switch] $Force
)

    $AllModules = @()

    Write-Host -ForegroundColor Yellow "Creating list of dependencies…"
    $target = Find-Module $TargetModule
    $target.Dependencies | ForEach-Object 
    {
        $AllModules += New-Object -TypeName psobject -Property @{ name = $_.name}
       # Write-Host -ForegroundColor Cyan $_.name
    }
    $AllModules += New-Object -TypeName psobject -Property @{ name = $TargetModule}

    $cnt = 1;
    foreach ($module in $AllModules)
    {
        Write-Host (“[$cnt] – ” + ‘Uninstalling {0} version’ -f $module.name);
        $cnt++;
        try
        {
            if ($PSCmdlet.ShouldProcess($module.name, ‘Uninstall’))
            {
                Uninstall-Module -Name $module.name -Force:$Force -ErrorAction Stop;
            };
        }
        catch
        {
            Write-Host (“`t” + $_.Exception.Message)
        }
    }
}

$targetModule = "PackageManagement"
$version ="1.4.7"
Uninstall-AllModules -TargetModule $targetModule -Force





$target.Dependencies | ForEach-Object 
{     
    Write-Host -ForegroundColor Cyan 
}