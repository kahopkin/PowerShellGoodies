#Set execution policy in PowerShell to remote signed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#Check which version of PowerShell you have installed.
$PSVersionTable.PSVersion

#Install latest version of PowerShellGet
Install-Module -Name PowerShellGet -Force


#Detect .NET Framework 4.5 and later versions
<#
The version of .NET Framework (4.5 and later) installed on a machine is listed in the registry at 
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full
If the Full subkey is missing, then .NET Framework 4.5 or above isn't installed.
#>

# check the value of the Release entry to determine whether .NET Framework 4.6.2 or later is installed. 
#This code returns True if it's installed and False otherwise.
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802


#https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-8.0.0
#Install the Azure Az PowerShell module
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Update-Module -Name Az

#To install Az from the PowerShell Gallery, run the following command:
Install-Module -Name Az -Repository PSGallery -Force

#Run the following command to install the SDK in PowerShell Core or Windows PowerShell.
Install-Module Microsoft.Graph -Scope CurrentUser

#Optionally, you can change the scope of the installation using the -Scope parameter. This requires admin permissions.
Install-Module Microsoft.Graph -Scope AllUsers

#verify the installed version with the following command.
Get-InstalledModule Microsoft.Graph
#update the SDK and all of its dependencies using the following command.
Update-Module Microsoft.Graph

#uninstall the main module.

Uninstall-Module Microsoft.Graph
#Then, remove all of the dependency modules by running the following commands.
Get-InstalledModule Microsoft.Graph.* | %{ if($_.Name -ne "Microsoft.Graph.Authentication"){ Uninstall-Module $_.Name } }
Uninstall-Module Microsoft.Graph.Authentication



#check Az module:
Get-InstalledModule Az

#installation method for the Az PowerShell module.
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

#If not present, run below to install
Install-Module -Name Az.Resources -Repository PSGallery -Scope CurrentUser

#BICEP
#To manually start the Bicep CLI installation, use:
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