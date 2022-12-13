Function RemoveDeletedWebApps
{
$DeletedApps = Get-AzDeletedWebApp

 $i=0
    foreach ($item in $DeletedApps.GetEnumerator()) 
    {         
        $appName = $item.name
        Write-Host -ForegroundColor Cyan "[$i] Name= " $item.name
        $id = "`$id=`"" + $item.id + "`""
        $ResourceGroupName = $item.ResourceGroupName
        Write-Host -ForegroundColor Yellow $id
        Remove-AzWebApp -Name $item.name -ResourceGroupName $ResourceGroupName
        #Remove-AzureADdeletedApp
        #Write-Host -ForegroundColor Red "REMOVED: " $appName
        $i++       
    }
}

RemoveDeletedWebApps

#Remove-AzADApplication -ObjectId 861a16ec-765a-48bd-bb0c-be610471dc37