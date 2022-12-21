#https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/hide-application-from-user-portal?pivots=ms-powershell
#Hide an application from the end user

Connect-MgGraph

$servicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $objectId
$tags = $servicePrincipal.tags
$tags += "HideApp"
Update-MgServicePrincipal -ServicePrincipalID  $objectId -Tags $tags