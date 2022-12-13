Function DeleteMyResourceGroups
{
    $today = Get-Date -Format "MM/dd/yyyy"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "[$today] START Removing ResourceGroups "
        
    #$myResourceGroups = Get-AzResourceGroup | Where-Object {$_.Tags.DeployDate -eq $today -and $_.Tags.DeployedBy -eq 'Kat Hopkins'}
    $myResourceGroups = Get-AzResourceGroup | Where-Object {$_.Tags.DeployedBy -eq 'Kat Hopkins'}
        
    Write-Host -ForegroundColor Cyan "myResourceGroups.Count=" $myResourceGroups.Count
    $i=0
    $j=0
    Foreach ($item In $myResourceGroups) 
    {
        $StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"            
        $ResourceGroupName = $item.ResourceGroupName
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName | Where-Object {$_.Tags.DeployedBy -eq 'Kat Hopkins'}
        Write-Host -ForegroundColor Cyan "`tresources.Count=" $resources.Count
        Write-Host -ForegroundColor Yellow "`t$StartTime Removing Resources from RG=" $ResourceGroupName
        $i=0
        Foreach($resource in $resources)
        {
            $resourceName = $resource.Name
            Write-Host -ForegroundColor Cyan "`t`t[$i] resource" $resourceName
            If( ($resource.Name).StartsWith('kv') )
            {

                Write-Host -ForegroundColor Red "`t`t`t[$i] Removing KEYVAULT :" $resourceName
                Remove-AzKeyVault -VaultName $resourceName -PassThru -Force
            }
            else
            {
                Write-Host -ForegroundColor Red "`t`t`t[$i] Removing :" $resourceName
                Remove-AzResource -ResourceName $resourceName -Force
            }
            $i++
                
        } #for each resource         

        Write-Host -ForegroundColor Green "`t[$j] REMOVING: " $ResourceGroupName
        Remove-AzResourceGroup -Name $ResourceGroupName -Force
        $EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
        $Duration = New-TimeSpan -Start $StartTime -End $EndTime
        Write-Host -ForegroundColor Red "`t[$j] DELETED ResourceGroup=" $ResourceGroupName
        Write-Host -ForegroundColor Magenta "`tDuration:" $Duration
        $j++
    }#foreach resource group
    
}#DeleteMyResourceGroups

DeleteMyResourceGroups