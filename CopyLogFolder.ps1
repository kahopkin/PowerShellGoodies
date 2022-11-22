#C:\GitHub\PowerShellGoodies\CopyLogFolder.ps1
#CopyLogFolder
#CreateFolders
<#

$RootFolder = '..\dtpResources\'
$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'

$FolderListParamsFile = '..\dtpResources\FolderNames.txt'
$FolderListParamsFile = '..\dtpResources\commits.txt'

CreateFolders -RootFolder $RootFolder -FolderListParamsFile $FolderListParamsFile


#>
Function global:CopyLogFolder
{
    Param(
      [Parameter(Mandatory = $true)] [String]$RootFolder    
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CopyLogFolder FOR $RootFolder *****************"
    
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
        Write-Host -ForegroundColor Cyan "[41] exist MonthFolder="  $MonthFolder.FullName
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Cyan "[43] exist MonthFolder.Path="  $MonthFolder.FullName
    }
    else
    {
        $MonthFolder = Get-Item $MonthFolderPath
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Green "[49] MonthFolderPath:"  $MonthFolderPath
    }
    
    $TodayFolderPath = $MonthFolderPath + "\" +  $TodayFolder
    Write-Host -ForegroundColor Green "[53] TodayFolderPath="  $TodayFolderPath
    $SourceFolderDeploy = "C:\GitHub\dtp\DeployLogs"
    #$ParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    #Write-Host -ForegroundColor Cyan "[35] ParentFolderPath="  $ParentFolderPath
        
    if ((Test-Path $TodayFolderPath) -eq $false)  
    {        
        $TodayFolder = New-Item -Path $MonthFolderPath -Name $todayShort -ItemType Directory
        #$DeployFolder = New-Item -Path $TodayFolder.FullName -Name 'Deploy' -ItemType Directory
        Write-Host -ForegroundColor Yellow "[65]NEW TodayFolder path: $TodayFolderPath" 
        $TodayFolderPath = (Get-ItemProperty  $TodayFolder | select FullName).FullName
        $Destination = $TodayFolder.FullName
        #$SourceFolderDeploy = "C:\GitHub\dtp\DeployLogs"
        #Copy-Item $SourceFolderDeploy $Destination -Recurse

    }
    else
    {
        $Destination = $SourceFolderDeploy #+ '\'
        $TodayFolderPath = (Get-ItemProperty  $TodayFolderPath | select FullName).FullName
        Write-Host -ForegroundColor Cyan "[70]EXISTING TodayFolderPath FullPath:"  $TodayFolderPath
        Write-Host -ForegroundColor Cyan "[70]EXISTING SourceFolderDeploy :"  $SourceFolderDeploy
        Write-Host -ForegroundColor Cyan "[70]EXISTING Destination :"  $Destination
        #Copy-Item $SourceFolderDeploy $Destination -Recurse
    }
<#
    Write-Host -ForegroundColor Green "[73]: SubfoldersFlag=" $SubfoldersFlag
    Write-Host -ForegroundColor Green "[74] TodayFolderPath="  $TodayFolderPath
    
    if($SubfoldersFlag -eq $true)
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
                $folder = New-Item -ItemType Directory -Path $TodayFolderPath -Name $Name 
                $FullName = $folder.FullName
                Write-Host -ForegroundColor Green "[$i] $FullName created " 
            }
            
            $i++
	    } 
    }
  #>     
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CopyLogFolder FOR $ParentDirPath *****************"

}#CopyLogFolder

#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$RootFolder = "C:\GitHub\dtpResources"
#$RootFolder = "C:\GitHub\dtpResources\rg-dts-prod-lt"
$ParentFolderPath = (Get-Item $RootFolder).FullName
#$ParentFolder = 'D:\Users\Kat\GitHub\$todayShort'
Write-Host "ParentFolderPath:" $ParentFolderPath

$FolderListParamsFile = '$RootFolder\FolderNames.txt'
#$FolderListParamsFile = 'C:\GitHub\dtpResources\FolderNames.txt'
#$FolderListParamsFile = '..\dtpResources\commits.txt'
$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNames.txt'
#$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNamesShort.txt'

$SubfoldersFlag = $false
#$SubfoldersFlag = $true

CopyLogFolder -RootFolder $RootFolder 
