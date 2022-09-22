# chocolatey packages Graphviz for Windows
choco install graphviz

# alternatively using windows package manager
winget install graphviz

# install from powershell gallery
Install-Module -Name AzViz -Repository PSGallery -Force

# import the module
Import-Module AzViz

# login to azure, this is required for module to work
Connect-AzAccount


#clone:
# optionally clone the project from github
git clone https://github.com/PrateekKumarSingh/AzViz.git
Set-Location .\AzViz\AzViz
   
# import the powershell module
Import-Module .\AzViz.psm1 -Verbose

# login to azure, this is required for module to work
Connect-AzAccount -EnvironmentName AzureUSGovernment

# target single resource group
Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show