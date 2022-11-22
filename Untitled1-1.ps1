$StartTime= "09/28/2022 15:12:15"
$EndTime= "09/28/2022 15:20:52"

$Duration= New-TimeSpan -Start $StartTime -End $EndTime
Write-Output "Time difference is: $Duration"

$GeographyGroupArr = Get-AzLocation | select GeographyGroup | Sort-Object -Property  GeographyGroup 
$geoGroupArr = $( foreach ($geoGroup in $GeographyGroupArr) {
            $geoGroup.GeographyGroup}) | Sort-Object | Get-Unique
$i=0
foreach($group in $geoGroupArr){
    Write-Host "[ $i ] : $group "
    $i++
}

 Write-Host "[ X ] : Cancel and Quit"  

$geoGroupArr[$geoGroup]

 $GeographyGroupArr | Where-Object -Property Name -Contains '$geoGroupArr[$geoGroup]'
 $GeographyGroupArr | Where-Object { $_.GeographyGroup -eq '$geoGroupArr[$geoGroup]' } 


 Get-AzLocation | select Location, DisplayName, GeographyGroup| Where-Object { $_.GeographyGroup -eq 'US' } | Sort-Object -Property DisplayName