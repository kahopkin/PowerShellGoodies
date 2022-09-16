#CreateFolders
<#

$RootFolder = '..\dtpResources\'
$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'

$FolderListParamsFile = '..\dtpResources\FolderNames.txt'
$FolderListParamsFile = '..\dtpResources\commits.txt'

CreateFolders -RootFolder $RootFolder -FolderListParamsFile $FolderListParamsFile


#>
Function global:CreateFolders
{
    Param(
      [Parameter(Mandatory = $true)] [String]$RootFolder
    , [Parameter(Mandatory = $false)] [String]$FolderListParamsFile
    , [Parameter(Mandatory = $true)] $SubfoldersFlag
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $RootFolder *****************"
    
    Write-Host -ForegroundColor Cyan "[25] RootFolder:"  $RootFolder
    $currMonth =  Get-Date -Format 'MM'
    #Write-Host -ForegroundColor Cyan "[27] currMonth:"  $currMonth
    $MonthFolderPath = $RootFolder + "\" +  $currMonth
    Write-Host -ForegroundColor Cyan "[29] MonthFolderPath="  $MonthFolderPath
    
    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder  = $RootFolder + "\" + (Get-Date -Format 'MM-dd-yyyy')
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    #Write-Host -ForegroundColor Cyan "[29] RootFolder:"  $RootFolder
    Write-Host -ForegroundColor Cyan "[35] TodayFolder:"  $TodayFolder
    
    #Check for Month Folder, if doesn't exist, create it
    if ((Test-Path $MonthFolderPath) -eq $false) 
    {
        $MonthFolder = New-Item -Path $RootFolder -Name $currMonth -ItemType Directory
        Write-Host -ForegroundColor Cyan "[41] MonthFolder="  $MonthFolder.FullName
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Cyan "[43] MonthFolder.Path="  $MonthFolder.FullName
    }
    else
    {
        $MonthFolder = Get-Item $MonthFolderPath
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Green "[48] MonthFolderPath:"  $MonthFolderPath
    }
    
    $TodayFolderPath = $MonthFolderPath + "\" +  $TodayFolder
    Write-Host -ForegroundColor Green "[52] TodayFolderPath="  $TodayFolderPath
    
    #$ParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    #Write-Host -ForegroundColor Cyan "[35] ParentFolderPath="  $ParentFolderPath
        
    if ((Test-Path $TodayFolderPath) -eq $false)  
    {        
        $TodayFolder = New-Item -Path $MonthFolderPath -Name $todayShort -ItemType Directory
        #$DeployFolder = New-Item -Path $TodayFolder.FullName -Name 'Deploy' -ItemType Directory
        $SourceFolder = "C:\GitHub\dtp\Deploy"
        $Destination = $TodayFolder.FullName
        Copy-Item $SourceFolder $Destination -Recurse
        $TodayFolderPath = (Get-ItemProperty  $TodayFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "[65]NEW TodayFolder path: $TodayFolderPath" 
    }
    else
    {
        $TodayFolderPath = (Get-ItemProperty  $TodayFolderPath | select FullName).FullName
        Write-Host -ForegroundColor Cyan "[70]EXISTING TodayFolderPath FullPath:"  $TodayFolderPath
    }

    Write-Host -ForegroundColor Magenta "[73]: SubfoldersFlag=" $SubfoldersFlag
    Write-Host -ForegroundColor Green "[74] TodayFolderPath="  $TodayFolderPath
    
    if($SubfoldersFlag)
    {
        $i=0
        $ParamsFile = Get-Content -Path $FolderListParamsFile
	    foreach($line in $ParamsFile) 
	    {
		    $Name = $line
            $NewFolderPath = "$TodayFolderPath\$Name"
            Write-Host -ForegroundColor Yellow "[$i] NewFolderPath = "$NewFolderPath 
            
            if ((Test-Path $NewFolderPath) -ne $true) 
		    {
                $folder = New-Item -ItemType Directory -Path $NewFolderPath -Name $Name 
                $FullName = $folder.FullName
                Write-Host -ForegroundColor Green "[$i] $FullName created " 
            }
            
            $i++
	    } 
    }
  #>     
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateFolders FOR $ParentDirPath *****************"

}#CreateFolders

#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$RootFolder = "C:\GitHub\dtpResources"
#$RootFolder = "C:\GitHub\dtpResources\rg-dts-prod-lt"

#$ParentFolder = 'D:\Users\Kat\GitHub\$todayShort'

$FolderListParamsFile = 'C:\GitHub\dtpResources\FolderNames.txt'
#$FolderListParamsFile = 'C:\GitHub\dtpResources\FolderNames.txt'
#$FolderListParamsFile = '..\dtpResources\commits.txt'
$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNames.txt'
$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNamesShort.txt'

$SubfoldersFlag = $false
$SubfoldersFlag = $true

CreateFolders -RootFolder $RootFolder ` -FolderListParamsFile $FolderListParamsFile

<#
CreateFolders -RootFolder $RootFolder `
    -FolderListParamsFile $FolderListParamsFile `
    -SubfoldersFlag $SubfoldersFlag
#>
