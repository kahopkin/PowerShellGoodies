Get-AzOperationalInsightsWorkspace | Select Name, ResourceId | Format-Table -AutoSize

$WorkspaceName = ""
$ResourceGroupName

Get-AzOperationalInsightsWorkspace `
    -Name $WorkspaceName `
    -ResourceGroupName $ResourceGroupName


Get-AzOperationalInsightsWorkspace | Where-Object {$_.Name -match 'Default'}

$DefaultWorkspaceId = (Get-AzOperationalInsightsWorkspace | Where-Object {$_.Name -match 'Default'} | Select ResourceId).ResourceId