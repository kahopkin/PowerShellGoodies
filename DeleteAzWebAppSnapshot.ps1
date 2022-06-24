#DeleteAzWebAppSnapshot

Function global:DeleteAzWebAppSnapshot
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ResourceGroupName
    , [Parameter(Mandatory = $false)] [String]$AppName
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START DeleteAzWebAppSnapshot FOR $ResourceGroupName *****************"
    
    $todayLong = Get-Date -Format "'MM-dd-yyyy-HH-mm"

    $OutFile= '..\logs\' +  $todayLong + '-' + $ResourceGroupName + "-SnapShots.txt"
    Write-Host -ForegroundColor Cyan "OutFile: $OutFile"

    $BeforeFile= '..\logs\' +  $todayLong + '-' + $ResourceGroupName + "-BeforeRemoveSnapshots.txt"
    Write-Host -ForegroundColor Cyan "BeforeFile: $BeforeFile"

    $snapshots = Get-AzWebAppSnapshot -ResourceGroupName $ResourceGroupName -Name $AppName
    Write-Host "snapshots.length= " $snapshots.Length

    #$todayLong = Get-Date -Format "'MM-dd-yyyy-HH-mm"
    $todayLong = Get-Date -Format 'MM-dd-yyyy'

    $todayLong >> $OutFile
    $ResourceGroupName >> $OutFile
    "snapshots.Length=" +   $snapshots.Length >> $OutFile
 
    Get-AzWebAppSnapshot -ResourceGroupName $ResourceGroupName -Name $AppName | 
        Sort-Object SnapshotTime | 
        Format-Table SnapshotTime, ResourceGroupName, Name, Slot  >> $BeforeFile

    Write-Host -ForegroundColor Yellow "$ResourceGroupName .snapshots.length: " $snapshots.Length   

    $i=0
    foreach ($item in $snapshots) {    
    
    $DeploymentName = $item.DeploymentName
    
        Write-Host -ForegroundColor Cyan "[$i] REMOVING: " $item.DeploymentName
        Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -Name $AppName
        
        #Get-AzWebAppSnapshot -ResourceGroupName $ResourceGroupName -Name $AppName 
        Write-Host -ForegroundColor Green "[$i] $DeploymentName Remove-AzWebAppSnapshot SUCCESS" 
        #Write-Host -ForegroundColor Yellow "[$i]=" $item.DeploymentName
        $item.TimeStamp.ToString() + " | " + $item.DeploymentName + " | " + $item.ProvisioningState >> $OutFile
        
        Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $AppName -Force;
        $i++
    }    


    $snapshots = Get-AzWebAppSnapshot -ResourceGroupName $ResourceGroupName 
    Write-Host -ForegroundColor Yellow "snapshots.length= " $snapshots.Length

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED DeleteAzWebAppSnapshot FOR $ResourceGroupName *****************"

}#DeleteAzWebAppSnapshot


$ResourceGroupName = 'dtp10'
$ResourceGroupName = 'rg-dev-dtp'

$AppName = 'dtp10'
$AppName = 'dtpdev'

DeleteAzWebAppSnapshot `
    -ResourceGroupName $ResourceGroupName `
    -AppName $AppName

#Get-AzWebAppSnapshot -ResourceGroupName $ResourceGroupName -Name $AppName
#Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName 'Snapshot01' -Force;



$snapshot = (Get-AzWebAppSnapshot -ResourceGroupName $ResourceGroupName -Name $AppName -Slot "Production")[0]
Restore-AzWebAppSnapshot -ResourceGroupName "Default-Web-WestUS" -Name "ContosoApp" -Slot "Restore" -InputObject $snapshot -RecoverConfiguration