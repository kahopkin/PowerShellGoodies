$GroupName = "CONTRIBUTOR - SUB - DEV"
$Group = Get-AzADGroup -DisplayName $GroupName      
$GroupId = $Group.Id
$User = Get-AzADUser | Where-Object {$_.DisplayName -eq $UserName}