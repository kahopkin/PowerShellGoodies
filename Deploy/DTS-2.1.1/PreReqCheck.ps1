#PreReqCheck
#Check which version of PowerShell you have installed.
$psVersion = $PSVersionTable.PSVersion
Write-Host "`$psVersion=`"$psVersion`""
#Install latest version
#Install-Module -Name PowerShellGet -Force

#check Az module:
$azInstalledModule = Get-InstalledModule Az
$azInstalledModuleVersion = $azInstalledModule.Version
Write-Host -ForegroundColor Green  "PreReqCheck[11] `$azInstalledModule.Version=`"$azInstalledModuleVersion`""
$majorV = $azInstalledModuleVersion.Split(".")[0]
$minorV = $azInstalledModuleVersion.Split(".")[1]

#Write-Host "[15] azInstalledModuleVersion `$majorV=`"$majorV`""
#Write-Host "[16] azInstalledModuleVersion `$minorV=`"$minorV`""

If($majorV -lt 8)
{
	Write-Host -ForegroundColor Green "PreReqCheck[20] Az Ps azInstalledModule `$majorV=`"$majorV`""
}
else
{
	Write-Host -ForegroundColor Green "PreReqCheck[24] Az Ps azInstalledModule `$majorV=`"$majorV`""
	If($minorV -lt 1)
	{

			Write-Host "PreReqCheck[28] azInstalledModule `$minorV=`"$minorV`""
		#If not present, run below to install
		Write-Host -ForegroundColor Yellow "Az Ps Minor version is:"
		Write-Host -ForegroundColor Yellow "Installing an update...."
		Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
		try{
		Install-Module -Name Az.Resources -Repository PSGallery -Scope CurrentUser
		}
		catch{
			Write-host -ForegroundColor Red "Error:"
			Write-Host -ForegroundColor Red $_
			}
	}
	else
	{
		Write-Host -ForegroundColor Green "Az Ps Minor version is:"
		Write-Host -ForegroundColor Green "`$minorV=`"$minorV`""
	}
}

$graphModule = Get-InstalledModule Microsoft.Graph
If($graphModule -eq $null)
{
	Write-Host -ForegroundColor Yellow "Need to install Microsoft.Graph...."
	try
	{
		Install-Module Microsoft.Graph -Scope CurrentUser
	}
	catch
	{
		Write-host -ForegroundColor Red "Error:"
		Write-Host -ForegroundColor Red $_
	}
}
Else
{
	$graphModuleVersion = $graphModule.Version
	Write-Host -ForegroundColor Yellow "[57] graphModuleVersion `$graphModuleVersion=`"$graphModuleVersion`""
	$majorVgraph = $graphModuleVersion.Split(".")[0]
	$minorVgraph = $graphModuleVersion.Split(".")[1]
	Write-Host -ForegroundColor Yellow "[57] graphModule `$majorVgraph=`"$majorVgraph`""
	Write-Host -ForegroundColor Yellow "[58] graphModule `$minorVgraph=`"$minorVgraph`""
}

$graphApplicationsMod = Get-InstalledModule Microsoft.Graph.* | Where-Object {$_.Name -eq "Microsoft.Graph.Applications"}
If($graphApplicationsMod -eq $null)
{
	try
	{
		Install-Module -name Microsoft.Graph.Applications
	}
	catch
	{
		Write-host -ForegroundColor Red "Error:"
		Write-Host -ForegroundColor Red $_
	}
}
<#Else
{

}
#>


$graphAuthenticationsMod = Get-InstalledModule Microsoft.Graph.* | Where-Object {$_.Name -eq "Microsoft.Graph.Authentication"}
If($graphAuthenticationsMod -eq $null)
{
	try
	{
		Install-Module -name Microsoft.Graph.Authentication
	}
	catch
	{
		Write-host -ForegroundColor Red "Error:"
		Write-Host -ForegroundColor Red $_
	}
}


<#
Get-InstalledModule Microsoft.Graph.* | %{ if($_.Name -ne "Microsoft.Graph.Authentication"){ Uninstall-Module $_.Name } }
Uninstall-Module Microsoft.Graph.Authentication
#>
#
