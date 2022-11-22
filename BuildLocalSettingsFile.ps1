#BuildLocalSettingsFile
Function BuildLocalSettingsFile
{
    Param(
        #[Parameter(Mandatory = $true)] [object] $object        
        [Parameter(Mandatory = $false)] [string] $JsonFilePath
       ,[Parameter(Mandatory = $true)] [string] $LocalSettingsFilePath
       ,[Parameter(Mandatory = $true)] [string] $LocalSettingsFileName

    )

    Write-Host -ForegroundColor Magenta "`$JsonFilePath=`"$JsonFilePath`""   
    Write-Host -ForegroundColor Green "`$LocalSettingsFilePath=`"$LocalSettingsFilePath`""
    Write-Host -ForegroundColor Green "`$LocalSettingsFileName=`"$LocalSettingsFileName`""
   
    $TestFilePath = $LocalSettingsFilePath + $LocalSettingsFileName
    Write-Host -ForegroundColor Green "`$TestFilePath=`"$TestFilePath`""
    if ((Test-Path $TestFilePath) -eq $false)  
    {
        $LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
        Write-Host "[27] Created new LocalSettingsFile:" $LocalSettingsFile.FullName 
        #$LocalSettingsFilePath = 
    } #env file does not exist
    else    
    {
        #Write-Host -ForegroundColor yellow "[150] Removed and re-created env file:" $EnvFile.FullName 
        Remove-Item -Path $TestFilePath 
        $LocalSettingsFile = New-Item -Path $LocalSettingsFilePath -Name $LocalSettingsFileName -ItemType File
        Write-Host -ForegroundColor GREEN "[34] Delete and create:" $LocalSettingsFile.FullName 
    }

    $LocalSettingsHash = @{
        IsEncrypted = $false;
        Host = @{};
        Values = @{};
    }

    $localSettingsJson = @()
    
    #read json into a hash
    $hash = @{}    
    $jsonObj = Get-Content $JsonFilePath | Out-String | ConvertFrom-Json
 #   $json = Get-Content $JsonFilePath
 #   $jsonObj = $json | ConvertFrom-Json
    foreach ($property in $jsonObj.PSObject.Properties) 
    {        
        $hash[$property.Name] = $property.Value      
        $propType = $property.Value.GetType().BaseType.FullName       
        if($propType -eq "System.Object")        
        {          
           #Write-Host -ForegroundColor Green $propType 
            Write-Host -ForegroundColor Yellow "Property=" $property.Name
            $LocalSettingsHash.($property.Name)
            # $LocalSettingsHash.Values.Keys
            foreach ($prop in $property.Value.PSObject.Properties) 
            {
                #Write-Host -ForegroundColor Cyan $prop.Name"="$prop.Value
                Write-Host -ForegroundColor Cyan "Value="$prop.Value 

                $LocalSettingsHash.($property.Name).Add($prop.Name, $prop.Value)
                
            }#foreach($prop in $property.Value.PSObject.Properties) 
           #Write-Host -ForegroundColor Yellow "Value=" $property.Value.PSObject.Properties
        }
        else{
            #Write-Host -ForegroundColor Green $property.Name"="$property.Value
           #Write-Host -ForegroundColor Green "Property=" $property.Name
           #Write-Host -ForegroundColor Green "Value="$property.Value           
        }

    }#foreach(($prop in $property.Value.PSObject.Properties)
  
  <#
    $json = ConvertTo-Json $LocalSettingsHash
    $json > $LocalSettingsFile	
  #>
}#BuildLocalSettingsFile

$dtpResources = "C:\GitHub\dtpResources"
$currMonth =  Get-Date -Format 'MM'
$MonthFolderPath = $dtpResources + "\" +  $currMonth
#Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[251] MonthFolderPath="  $MonthFolderPath
$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')

$JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"
$LocalSettingsFileName = "JsonProps.txt"
$LocalSettingsFilePath = $MonthFolderPath + "\" +  $TodayFolder + "\"




BuildLocalSettingsFile -JsonFilePath $JsonFilePath `
    -LocalSettingsFilePath $LocalSettingsFilePath `
    -LocalSettingsFileName $LocalSettingsFileName