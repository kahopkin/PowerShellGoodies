#DeleteDeployments

Function global:DeleteDeployments
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ResourceGroupName
    , [Parameter(Mandatory = $false)] [String]$Filter
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START DeleteDeployments FOR $ResourceGroupName *****************"
    
    $todayLong = Get-Date -Format "'MM-dd-yyyy-HH-mm"

    $OutFile= '..\logs\' +  $todayLong + '-' + $ResourceGroupName + '-Deployment.txt'
    Write-Host -ForegroundColor Cyan "OutFile: $OutFile"

    $today = Get-Date -Format 'MM-dd-yyyy'
    $BeforeFile= '..\logs\' +  $today + '-' + $ResourceGroupName + '-BeforeRemoveDeployments.txt'
    Write-Host -ForegroundColor Cyan "BeforeFile: $BeforeFile"

    $AfterFile= '..\logs\' +  $today + '-' + $ResourceGroupName + '-AfterFileRemoveDeployments.txt'
    Write-Host -ForegroundColor Cyan "AfterFile: $AfterFile"
    
    $deployments = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName 
    Write-Host "deployments.length= " $deployments.Length
 

    $todayLong > $OutFile
    $ResourceGroupName >> $OutFile
    "Deployments.Length=" +   $deployments.Length >> $OutFile
 
    Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName | 
        Sort-Object TimeStamp, ProvisioningState | 
        Format-Table DeploymentName, TimeStamp, ProvisioningState >> $BeforeFile

    Write-Host -ForegroundColor Yellow "$ResourceGroupName .deployments.length: " $deployments.Length   

   
    $i=0
    foreach ($item in $deployments) {    
    
        $DeploymentName = $item.DeploymentName
        $TimeStamp =  $item.Timestamp.ToShortDateString()
        Write-Host $TimeStamp

        
        if($DeploymentName.StartsWith($Filter) -or $Filter -eq 'All' )
        {
            Write-Host -ForegroundColor Cyan "[$i] REMOVING: " $TimeStamp - $DeploymentName
            Remove-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName
            Write-Host -ForegroundColor Green "[$i] $DeploymentName Remove-AzResourceGroupDeployment SUCCESS" 
        }
        else
        {
            #Write-Host -ForegroundColor Yellow "[$i]=" $item.DeploymentName
           $item.TimeStamp.ToString() + " | " + $item.DeploymentName + " | " + $item.ProvisioningState >> $OutFile
        }
        
       <# 
        if($TimeStamp -ne $today.ToString() )
        {
            Write-Host -ForegroundColor Cyan "[$i] REMOVING: " $item.DeploymentName
            Remove-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName
            Write-Host -ForegroundColor Green "[$i] $DeploymentName Remove-AzResourceGroupDeployment SUCCESS" 
        }
        else
        {
            #Write-Host -ForegroundColor Yellow "[$i]=" $item.DeploymentName
           $item.TimeStamp.ToString() + " | " + $item.DeploymentName + " | " + $item.ProvisioningState >> $OutFile
        }
        #>
        $i++
    }    


    $deployments = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName 
    Write-Host -ForegroundColor Yellow "Remaining deployments.length= " $deployments.Length
    Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName | 
        Sort-Object TimeStamp, ProvisioningState | 
        Format-Table DeploymentName, TimeStamp, ProvisioningState >> $AfterFile

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green  -BackgroundColor Black "`n *************[$today] FINISHED DeleteDeployments FOR $ResourceGroupName *****************"

}#DeleteDeployments


$ResourceGroupName = 'dtp10'
#$ResourceGroupName = 'rg-dev-dtp'

$Filter = 'All'

DeleteDeployments `
    -ResourceGroupName $ResourceGroupName `
    -Filter $Filter

#Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName 'Snapshot01' -Force;