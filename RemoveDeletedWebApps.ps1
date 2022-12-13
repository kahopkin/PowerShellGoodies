Function RemoveDeletedWebApps
{
    $DeletedApps = Get-AzDeletedWebApp
    Write-Host "Get-AzDeletedWebApp.Count" $DeletedApps.Count
    $i=0
    foreach ($item in $DeletedApps.GetEnumerator()) 
    {         
        $appName = $item.name
        Write-Host -ForegroundColor Cyan "`$appName=`"$appName`""
        $id = "`$id=`"" + $item.id + "`""
        $ResourceGroupName = $item.ResourceGroupName
        Write-Host -ForegroundColor Cyan "`$ResourceGroupName=`"$ResourceGroupName`""
        Write-Host -ForegroundColor Yellow $id
        #Remove-AzWebApp -Name $appName -ResourceGroupName $ResourceGroupName  -Force #-Confirm:$false
        #Remove-AzureADdeletedApp
        Write-Host -ForegroundColor Red "REMOVED: " $appName
        $i++       
    }

    $PostRemove = Get-AzDeletedWebApp
    Write-Host "Get-AzDeletedWebApp.Count" $PostRemove.Count
}

RemoveDeletedWebApps

#Remove-AzADApplication -ObjectId 861a16ec-765a-48bd-bb0c-be610471dc37
$ResourceGroupName = "rg-scan-dev-lt-001"
$appName = "func-scan-dev-lt-001"
$AppServicePlanName = "asp-scanfuncapp-dev-lt-001"


Restore-AzDeletedWebApp -TargetResourceGroupName $ResourceGroupName `
    -Name $appName `
    -TargetAppServicePlanName $AppServicePlanName



$deletedSite = Get-AzDeletedWebApp -ResourceGroupName rg-scan-dev-lt-001 -Name func-scan-dev-lt-001
Restore-AzDeletedWebApp -TargetResourceGroupName rg-scan-dev-lt-001 -TargetName func-scan-dev-lt-001Restore -TargetAppServicePlanName asp-scanfuncapp-dev-lt-001 -InputObject $deletedSite[1]


Restore-AzDeletedWebApp -ResourceGroupName rg-scan-dev-lt-001 -Name func-scan-dev-lt-001 -DeletedId /subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/providers/Microsoft.Web/deletedSites/128184 -TargetAppServicePlanName asp-scanfuncapp-dev-lt-001

Get-AzDeletedWebApp -ResourceGroupName rg-scan-dev-lt-001 -Name func-scan-dev-lt-001 > GlensFuncApp

appi-scanfuncapp-dev-lt-001
$deletedSite = Get-AzDeletedWebApp -ResourceGroupName $ResourceGroupName -Name $appName
Restore-AzDeletedWebApp -TargetResourceGroupName $ResourceGroupName -TargetName $appName -TargetAppServicePlanName $AppServicePlanName -InputObject $deletedSite[1]


Restore-AzDeletedWebApp -ResourceGroupName <RGofnewapp> -Name <newApp> -deletedId "/subscriptions/xxxx/providers/Microsoft.Web/locations/xxxx/deletedSites/xxxx"

Restore-AzDeletedWebApp -ResourceGroupName <original_rg> -Name <original_app> -DeletedId /subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Web/locations/location/deletedSites/1234 -TargetAppServicePlanName <my_asp>