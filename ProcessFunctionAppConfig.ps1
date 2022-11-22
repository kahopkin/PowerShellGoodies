
$JsonFile = "C:\GitHub\dtpResources\rg-dts-prod-lt\FunctionApp\lt-datatransferapiConfigurations.json"
$ConfigProps = "C:\GitHub\dtpResources\rg-dts-prod-lt\FunctionApp\lt-datatransferapiConfigurations.txt"
$MyJsonObject = Get-Content $JsonFile -Raw | ConvertFrom-Json
$PropNameArr =@()
$mylist = [System.Collections.Generic.List[string]]::new()
$i=0
foreach ($item in $MyJsonObject)
{
    #Write-Host $item.name "=" $item.value
    $myList.Add( $item.name +","+ $item.value)
    $i++
}


$mylist | Out-File $ConfigProps