$DebugPreference='Continue'

$name = "foobar"

$appReg = New-AzADApplication -DisplayName $name
$sp = New-AzADServicePrincipal -ApplicationId $appReg.AppId
 
$preGeneratedApiConfig = @{
  "requestedAccessTokenVersion" = 2
}

Update-AzADApplication -ObjectId (Get-AzADApplication -DisplayName $name).Id -Api $preGeneratedApiConfig



Update-AzADApplication -ObjectId $AppObjectId -AppRole $AppRoles
Write-Host -f Green "UpdateAppRoles[64] ##[section] App role '$($AppRole)' added successfully"