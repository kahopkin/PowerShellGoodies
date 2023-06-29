Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser


Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Install-Module Microsoft.Graph
Install-module Microsoft.Graph




bicep --version
#bicep:
# Create the install folder
$installPath = "$env:USERPROFILE\.bicep"
$installDir = New-Item -ItemType Directory -Path $installPath -Force
$installDir.Attributes += 'Hidden'
# Fetch the latest Bicep CLI binary
(New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
# Add bicep to your PATH
$currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
# Verify you can now access the 'bicep' command.
bicep --help
# Done!

<#
The bicep install and bicep upgrade commands don't work in an air-gapped environment.
To install Bicep CLI in an air-gapped environment, you need to download the Bicep CLI executable manually and save it to .azure/bin. 
This location is where the instance managed by Azure CLI is installed.
Download bicep-win-x64.exe from the Bicep release page in a non-air-gapped environment.
https://github.com/Azure/bicep/releases/tag/v0.6.18

#>
Install-Module Microsoft.Graph