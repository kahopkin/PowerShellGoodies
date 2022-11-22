#GetJsonProps

Function GetJsonProps
{
    Param(
        #[Parameter(Mandatory = $true)] [object] $object        
        [Parameter(Mandatory = $false)] [string] $JsonFilePath
       ,[Parameter(Mandatory = $true)] [string] $PropsFilePath
       ,[Parameter(Mandatory = $true)] [string] $PropsFileName

    )

    Write-Host -ForegroundColor Magenta "`$JsonFilePath=`"$JsonFilePath`""   
    Write-Host -ForegroundColor Green "`$PropsFilePath=`"$PropsFilePath`""
    Write-Host -ForegroundColor Green "`$PropsFileName=`"$PropsFileName`""
    <#
    $dtpResources = "C:\GitHub\dtpResources"
    $currMonth =  Get-Date -Format 'MM'
    $MonthFolderPath = $dtpResources + "\" +  $currMonth
    #Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[251] MonthFolderPath="  $MonthFolderPath
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    $PropsFilePath = $MonthFolderPath + "\" +  $TodayFolder
    $JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"
    #>
    $TestFilePath = $PropsFilePath + $PropsFileName
    Write-Host -ForegroundColor Green "`$TestFilePath=`"$TestFilePath`""
    if ((Test-Path $TestFilePath) -eq $false)  
    {
        $PropsFile = New-Item -Path $PropsFilePath -Name $PropsFileName -ItemType File
        Write-Host "[27] Created new PropsFile:" $PropsFile.FullName 
        #$PropsFilePath = 
    } #env file does not exist
    else    
    {
        #Write-Host -ForegroundColor yellow "[150] Removed and re-created env file:" $EnvFile.FullName 
        Remove-Item -Path $TestFilePath 
        $PropsFile = New-Item -Path $PropsFilePath -Name $PropsFileName -ItemType File
        Write-Host -ForegroundColor GREEN "[34] Delete and create:" $PropsFile.FullName 
    }
    $json =@()

    #$json = Get-Content $FilePath | ConvertFrom-Json
    $json = Get-Content $JsonFilePath | Out-String | ConvertFrom-Json
    $Props = ($json.Values  | Get-Member -Type NoteProperty).Name 
    $Values = ($json.Values  | Get-Member -Type NoteProperty).Definition
    Write-Host "Props.Count="$Props.Count
    
    foreach($item in $Props)
    {
        Write-Host $item
        $item >>  $PropsFile.FullName
        
        #values
        #Write-Host $json.Values.$item
        #$json.Values.$item >>  $PropsFilePath

    }

}#GetJsonProps

$dtpResources = "C:\GitHub\dtpResources"
$currMonth =  Get-Date -Format 'MM'
$MonthFolderPath = $dtpResources + "\" +  $currMonth
#Write-Host -ForegroundColor Cyan "CreateEnvironmentFiles[251] MonthFolderPath="  $MonthFolderPath
$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
$PropsFileName = "JsonProps.txt"
$PropsFilePath = $MonthFolderPath + "\" +  $TodayFolder + "\"
$JsonFilePath = "C:\GitHub\dtp\Deploy\LocalSetUp\DTP\local.settings.json"

GetJsonProps -JsonFilePath $JsonFilePath -PropsFilePath $PropsFilePath  -PropsFileName $PropsFileName



<#
if ((Test-Path $EnvFilePath) -eq $false)  
        {
            $item >  $PropsFilePath
        }
        else
        {
            $item >>  $PropsFilePath
        }
       
#>