#To check your PowerShell version
$PSVersionTable.PSVersion

#Check version:

pwsh --version

#$PSVersionTable.PSVersion to determine the engine version
$PSVersionTable.PSVersion

#update module version
Update-Module -Name PSVersion 



#If you already have the .NET Core SDK installed, you can install PowerShell as a .NET Global tool.
dotnet tool install --global PowerShell

#Make sure you have the latest version of PowerShellGet. Run 
Install-Module -Name PowerShellGet -Force


#Install the Az module for the current user only. This is the recommended installation scope.
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force



#Update PowerShellGet to the latest version using 
Install-Module PowerShellGet -Force

#The PowerShell script execution policy must be set to remote signed or less restrictive. 
#Use 
Get-ExecutionPolicy 
#to determine the current execution policy. 

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#https://learn.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-8.3.0
#https://learn.microsoft.com/en-us/powershell/azure/install-az-ps-msi?view=azps-8.3.0
Install-Module -Name Az.Resources -Repository PSGallery -Scope CurrentUser


Install-Module Microsoft.Graph -Scope CurrentUser

Install-Module Microsoft.Graph -Scope AllUsers

#verify the installed version
Get-InstalledModule Microsoft.Graph

#Get-InstalledModule Microsoft.Graph
Get-InstalledModule

#update the SDK and all of its dependencies using the following command.
Update-Module Microsoft.Graph

# to uninstall the main module.
Uninstall-Module Microsoft.Graph

#Then, remove all of the dependency modules by running the following commands.
Get-InstalledModule Microsoft.Graph.* | %{ if($_.Name -ne "Microsoft.Graph.Authentication"){ Uninstall-Module $_.Name } }
Uninstall-Module Microsoft.Graph.Authentication