#$GroupName = "CONTRIBUTOR - SUB - DEV"
$GroupName = "DTS Developers"
$Group = Get-AzADGroup -DisplayName $GroupName
$GroupId = $Group.Id

$GroupMembers = Get-AzADGroupMember -GroupDisplayName $GroupName

$GroupMembers.PSObject.Properties


$i=0
$GroupMembers.PSObject.Properties | ForEach-Object {
    $keyname = $_.Name
    $value = $_.Value.value
    $type = ($_.value.type).ToLower()
    
    #$vsoAttribs = @("task.setvariable variable=$keyName")
    #Write-Host "The value of [$keyName] is [$value]"
    #Write-Host "$keyName=$value"
    if ($type -eq "array") 
    {
        Write-Host -ForegroundColor Red "Array"
        Write-Host -ForegroundColor Cyan  "`$keyName=`"$keyName`""
        Write-Host -ForegroundColor Yellow "[$i]"

        Write-Host -ForegroundColor Green  "`$value=`"$value`""
        #Write-Host $_.Value.value.name
        Write-Host -ForegroundColor Gray ($_.Value.value).GetType()
        $value = $_.Value.value.name -join ',' 
        ## All array variables will come out as comma-separated strings
    }
   
    Else
    {
        Write-Host -ForegroundColor Cyan  "$keyName"
        Write-Host -ForegroundColor Yellow "$value"
    }
}#foreach

Get-AzADUser
$CurrUser = Get-AzADUser -SignedIn

$User = Get-AzADUser | Where-Object {$_.DisplayName -eq $UserName}

$GroupMembers = Get-AzADGroupMember -GroupDisplayName $GroupName -Select Id, DisplayName

Get-AzADGroupMember -GroupDisplayName $GroupName -Select Id, DisplayName | ConvertTo-Json > "GroupMembers.json"
$User = Get-AzADUser -DisplayName 'Jason Ingram (CA)'


Get-AzADGroupMember -GroupDisplayName $GroupName | ConvertTo-Json > GroupMembers.json