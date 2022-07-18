#
$env:PSModulePath


Get-InstalledModule

# list of all the Az PowerShell module versions installed on your system.
Get-InstalledModule -Name Az -AllVersions -OutVariable AzVersions

#generate a list of all the Az PowerShell modules that need to be uninstalled in addition to the Az module.
($AzVersions |
  ForEach-Object {
    Import-Clixml -Path (Join-Path -Path $_.InstalledLocation -ChildPath PSGetModuleInfo.xml)
  }).Dependencies.Name | Sort-Object -Descending -Unique -OutVariable AzModules

  #Remove the Az modules from memory and then uninstall them.
  $AzModules |
  ForEach-Object {
    Remove-Module -Name $_ -ErrorAction SilentlyContinue
    Write-Output "Attempting to uninstall module: $_"
    Uninstall-Module -Name $_ -AllVersions
  }

  #remove the Az PowerShell module.
Remove-Module -Name Az -Verbose -Force
Remove-Module -Name Az -ErrorAction SilentlyContinue
Uninstall-Module -Name Az -AllVersions -Verbose -Force





$AzModules |
  ForEach-Object {
    Remove-Module -Name $_ -ErrorAction SilentlyContinue -Verbose -Force
    Write-Output "Attempting to uninstall module: $_"
    Uninstall-Module -Name $_ -AllVersions -Verbose
  }




function Uninstall-AzureModules
{
    $Modules = (Get-Module -ListAvailable Az*).Name |Get-Unique
    Foreach ($Module in $Modules)
    { 
        Write-Output ("Uninstalling: $Module")
        Uninstall-Module $Module -Force -Verbose
    }
}
Uninstall-AzureModules



function Uninstall-AzureModules
{
    $Modules = (Get-Module -ListAvailable Microsoft.Graph.*).Name |Get-Unique
    Foreach ($Module in $Modules)
    { 
        Write-Output ("Uninstalling: $Module")
        Uninstall-Module $Module -Force -Verbose
    }
}
Uninstall-AzureModules

PS C:\windows\system32> Uninstall-Module -Name Az -AllVersions -Verbose -Force

Uninstall-Module -Name PackageManagement -AllVersions -Verbose -Force
Remove-Module -Name PackageManagement -Force -Verbose

Uninstall-Module -Name PowerShellGet -AllVersions -Verbose -Force
Remove-Module -Name PowerShellGet -Force -Verbose



Get-PackageProvider
Get-Package -Name PowerShellGet | Uninstall-Package

 Uninstall-Package -Name PackageManagement -Force -Verbose

Get-Package -Name NuGet | Uninstall-Package


Uninstall-Module -Name PackageManagement -AllVersions -Force -Verbose

#cmd admin mode:
powershell -NoProfile -Command "Uninstall-Module PackageManagement"

Get-InstalledModule -Name "PackageManagement" -RequiredVersion 1.4.7 | Uninstall-Module