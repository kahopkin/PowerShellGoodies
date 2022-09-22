Clear-Host
Write-Host ""
Write-Host "========================================"
Write-Host "       CREATE NEW USER ACCOUNT"
Write-Host "========================================"
Write-Host ""
Write-Host "This script is for creating a new AD"
Write-Host "account that represents a human being."
Write-Host ""
Write-Host "It should NOT be used for the creation"
Write-Host "of (e.g.) Service Accounts, nor Admin"
Write-Host "level accounts"
Write-Host ""
Write-Host "Press"
Write-Host "X : to cancel and quit"
Write-Host "or"
Write-Host "C : to continue"
Write-Host ""
write-host ""

function Get-Choice
{
	$count=$count+1
	$choice = Read-Host "Enter Selection"
	Switch ($choice)
	{
			C {"OK, let's make a user."} 
			X {"Quitting..."}
			Default {Get-Choice}
	}
	Write-Host "aa"
}

function Get-Site
{
	$site=Read-Host "Choose a site code"
	Switch ($site)
	{
		L {$Chosensite="London"}
		H {$Chosensite="Hong Kong"}
		N {$Chosensite="New York"}
		}
    return $Chosensite
}

Get-Choice


$script:ChosenSite=Get-Site
write-host "Chosen site is $Chosensite"

Write-Host ""
write-host "Try again..."
$site=Read-Host "Choose a site code"
	Switch ($site)
	{
		L {$Chosensite="London"}
		H {$Chosensite="Hong Kong"}
		N {$Chosensite="New York"}
		}
write-host "Site chosen is now $Chosensite"


function Get-Site
{
	$site=Read-Host "Choose a site code"
	Switch ($site)
	{
		L {$Chosensite="London"}
		H {$Chosensite="Hong Kong"}
		N {$Chosensite="New York"}
		}
    return $Chosensite
}

usgovvirginia
usgovtexas
usgovarizona
usdodeast
usdodcentral
