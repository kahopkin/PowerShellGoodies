#https://codingfreaks.de/aad-stale-role-assignments/
#need to install the module Az.ResourceGraph which is not part of the module collection Az in PowerShell.
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]
	$TenantId
)
$containers = Search-AzGraph -Query "ResourceContainers | where tenantId == '$TenantId'"
$containerCount = $containers.Count
$current = 0
$removed = 0
$notRemoved = 0
$notRemovedIds = New-Object System.Collections.Generic.List[string]
foreach($container in $containers) {
	$current = $current + 1	
	Write-Host "Removing stale role assignments from [$($container.name)] ($current of $containerCount)..."
	$stales = Get-AzRoleAssignment -Scope $container.Id | Where-Object { $_.ObjectType -eq 'Unknown' }
	$amount = $stales.Count
	if ($amount -gt 0) {
		$deleteLocks = Get-AzResourceLock -Scope $container.Id | Where-Object { $_.Properties.level -eq 'CanNotDelete' }
		if ($deleteLocks.Count -gt 0) {
			Write-Host "Cannot remove $($amount) stale role assignments for [$($container.name)] because of existing no-delete-lock." -ForegroundColor Yellow
			$notRemoved = $notRemoved + $amount	
			$notRemovedIds.Add($container.Id)
			continue
		}
		$stales | Remove-AzRoleAssignment
		$removed = $removed + $amount				
		Write-Host "Removed $($amount)" -ForegroundColor Green
		continue
	}	
	Write-Host "Done"
}
Write-Host "Finished. Removed $removed stale role assignemnts." -ForegroundColor Green
if ($notRemovedIds.Count -gt 0) {
	Write-Host "Skipped removal of $notRemoved stale assignments for following resources:" -ForegroundColor Yellow
	foreach($id in $notRemovedIds) {
		Write-Host "- $id" -ForegroundColor Yellow
	}
}