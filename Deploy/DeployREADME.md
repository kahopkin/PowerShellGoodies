The PowerShell and the Bicep script creates all the necessary resources in Azure for the application.

**Pre-requesites**:
* Azure subscription with privileges to create resources
* Latest version of **PowerShell, Azure PowerShell and Microsoft Graph PowerShell**:

```powershell
#Set execution policy in PowerShell to remote signed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

* Make sure you have the latest version of PowerShellGet. For more info on installing the latest version: [INstalling PowerShell on Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
* Run:
```powershell
#Check which version of PowerShell you have installed.
$PSVersionTable.PSVersion
#Install latest version
Install-Module -Name PowerShellGet -Force
```
* Azure PowerShell modules installed (NOT AzureRM)
```powershell
#check Az module:
Get-InstalledModule Az
#If not present, run below to install
Install-Module -Name Az.Resources -Repository PSGallery -Scope CurrentUser
```

* Install the Microsoft Graph Module:
```powershell
# Installing the Module

# Installing the Graph PowerShell module with no previous versions installed
Install-module Microsoft.Graph

# If upgrading from our preview modules, run install-module with AllowClobber and Force parameter to avoid command name conflicts
Install-Module Microsoft.Graph -AllowClobber -Force

# Updating from an earlier version of MS Graph PowerShell installed from PS Gallery
Update-module Microsoft.Graph
```

* Import the Graph.Applications Module:
```powershell
Import-Module -name Microsoft.Graph.Applications
```

* Bicep installed
In order to successfully create all the necessary Azure resources for the application,
you need Bicep installed.
If not installed, please see [https://aka.ms/bicep-install](https://aka.ms/bicep-install) to install. `Note: Your environment path may need to be updated manually with the locaon of your Bicep installation and may also require you to reboot your PC before continuing.`

**Deployment**: This method does 100% automated creation and configuration
of all the resources needed by the application.
It creates and configures both App Registrations and creates all the Azure Resources in the
Resource Group.
Navigate to the **dtp\Deploy\powershell** folder and run:
```powershell
 .\InitiateDeploymentProcess.ps1

#i.e.:
PS C:\GitHub\dtp\Deploy\powershell> .\InitiateDeploymentProcess.ps1
```

# Deploy Client Web App and Azure Function App
## Zip Client Deployment Files
1. Open a local branch of the code in [Visual Studio Code](https://code.visualstudio.com/).
2. Ensure you're working with the latest code base.
3. Run the following commands in the terminal or your preferred CLI

	```powershell
	# Install latest dependencies
	npm install

	# Fix vulnerabilities
	npm audit fix

	# Build client application
	npm run-script build

	# Navigate to build folder
	cd build

	<# Zip deployment files.
	# Replace <..> in the following command, without any quotes:
	# $DeploymentPath: The full deployment path and file name,
	# for example
	# $DeploymentPath = "C:\Deploy\ClientDeployment.zip"
	#>
	Compress-Archive -Path * -DestinationPath $DeploymentPath
	```
4. Verify zip file was created in the deployment folder specified.

## Deploy Client Deployment Files to Azure

	1. Open your preferred PowerShell  CLI
	2. Log into Azure
	```powershell
	# A web browser will open prompting you to authenticate your Azure account.
	Connect-AzAccount -Environment AzureUSGovernment
	```
	3. Publish deployment files to Azure.
	```powershell
	<# Publish deployment files to Azure. Replace <..> in the following command, without any quotes:
	# - $RG: this is the Resource Group Name
	# - $SiteName: this is the site name, which can be found in Azure and is also specified in your deployment output file from the scripts you ran earlier.
	# - $Path: this is the physical path to your zip file and must include the full file name
	#>
	Publish-AzWebApp -ResourceGroupName $RG -Name $SiteName -ArchivePath $Path
	```
	4. Successfull deployment returns a fair amount of output, followed by a command prompt. It will be obvious if you get an error - also some red text.
	5. In Azure, you can verify deployment by:
		1. Open the App Service in your Resource Group.
		2. Under Deployment, select Deployment Center.
		3. Select Logs from the tabbed menu.
 
## Zip Server-Side Function Application
1. Open Visual Studio Code.
2. Navigate to the local `../API/dtpapi folder`

	```powershell
	# Build the project. It will inform you if it succeeded.
	dotnet build

	<# Publish the application and its dependencies to a folder for deployment to Azure.
	# $DeploymentFolderName: The name of the deployment folder within the same folder scructure. Not a full path and no extention.
	dotnet publish -c Release -o $DeploymentFolderName
	# Change to the folder you published to in the previous step.
	# cd $DeploymentFolderName
	#>
	cd build


	<# Zip deployment files.
	# $DeploymentPath: The full deployment path and file name,
	for example $DeploymentPath = "C:\Deploy\ClientDeployment.zip"
	#>
	Compress-Archive -Path * -DestinationPath $DeploymentPath
	```
3. Verify zip file was created in the deployment folder specified.

## Deploy Server-Side Function Application to Azure
	1. Open your preferred PowerShell CLI:
	2. Log into Azure
	```powershell
	# A web browser will open prompting you to authenticate your Azure account.
	Connect-AzAccount -Environment AzureUSGovernment
	```
	3. Publish deployment files to Azure. There are currently two options:
		Using `Publish-AzWebApp`. Currently, this option does not remove objects previously removed from the application.
	```powershell
	<# Publish deployment files to Azure. Replace <..> in the following command, without any quotes:
	# $RG: this is the Resource Group Name
	# $SiteName: this is the site name, which can be found in Azure and is also specified in your deployment output file from the scripts you ran earlier.
	# $Path: this is the physical path to your zip file and must include the full file name
	#>
	Publish-AzWebApp -ResourceGroupName $RG -Name $SiteName -ArchivePath $Path
	```
		Using `az functionapp`
	```powershell
	<# Publish deployment files to Azure. Replace <..> in the following command, without any quotes:
	# $RG: this is the Resource Group Name
	# $AppName: this is the Function</u></b> name - not the site name, which can be found in Azure and is also specified in your deployment output file from the scripts you ran earlier.
	# $Path: this is the physical path to your zip file and must include the full file name
	#>
	az functionapp deployment source config-zip -g $RG -n $AppName --src $Path
	```
	4. Successfull deployment returns a fair amount of output, followed by a command prompt. It will be obvious if you get an error - also some red text.
	5. In Azure, you can verify deployment by:
		1. Open the Function App in your Resource Group.
		2. Under Deployment, select Deployment Center.
		3. Select Logs from the tabbed menu.


