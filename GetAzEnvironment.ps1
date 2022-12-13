$CloudArr =@{}
$CloudArr = Get-AzEnvironment
$JsonHashtable = $CloudArr | ConvertTo-Json
$Hashtable = @{}
$Hashtable = $JsonHashtable | ConvertFrom-Json
$i=0
foreach ($item in $Hashtable)
{
    $itemHash = $item
    Write-Host -ForegroundColor Yellow "Hashtable[$i] :" $item.Name 
    $ProperName = $item.Name -csplit '(?<!^)(?=[A-Z])' -join ' '
    $ProperName = @{ProperName = $ProperName}
    $itemHash += $ProperName
    $i++
}




@{
        Tenant = $Tenant;
        TenantId = $TenantId;
    $myList = New-Object -TypeName "System.Collections.Generic.List[]"
    $myList = Get-AzEnvironment

   $customCloud1 = [PSCustomObject]@{
        Name = "Azure_Custom_Cloud_1"
        Proper = "Azure Custom Cloud 1"
    }

    $myList.Add($customCloud1)
    