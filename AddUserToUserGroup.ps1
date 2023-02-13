# AddUserToUserGroup
$groupid=(Get-AzADGroup -DisplayName $UserGroup).Id
$members=@()
$members+=(Get-AzADUser -DisplayName $UserGroup).Id
$members+=(Get-AzADServicePrincipal -ApplicationId $appid).Id
Add-AzADGroupMember -TargetGroupObjectId $groupid -MemberObjectId $members