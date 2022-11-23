 $json =@()
   $jsonObj = $json | ConvertFrom-Json
   $hash = @{}
    foreach ($property in $jsonObj.PSObject.Properties) {
        $hash[$property.Name] = $property.Value
        $property
    }
#>
    #$json = Get-Content $FilePath | ConvertFrom-Json
    $json = Get-Content $JsonFilePath | Out-String | ConvertFrom-Json
    #Write-Host -ForegroundColor Yellow "`$json="$json
    ($json  | Get-Member -Type NoteProperty).Name
    ForEach($item in $json)
    {
        $property = ($item | Get-Member -Type NoteProperty).Name
        Write-Host -ForegroundColor Yellow $property
        Write-Host ""
    }
    #>
    $Props = ($json | Get-Member -Type NoteProperty).Name   
    Write-Host "Props.Count="$Props.Count
    foreach($item in $Props)
    {
        Write-Host -ForegroundColor Yellow $item 
        #$item
        $property = ($item | Get-Member -Type NoteProperty).Name
        $property
        #$json.$item
        #Write-Host $json.$item
    }


    $Props = ($json.Values | Get-Member -Type NoteProperty).Name     
    Write-Host "Props.Count="$Props.Count
    
    foreach($item in $Props)
    {
        #Write-Host $item
        $item >>  $LocalSettingsFile.FullName
        
        #values
        #Write-Host $json.Values.$item
        #$json.Values.$item >>  $LocalSettingsFilePath

    }