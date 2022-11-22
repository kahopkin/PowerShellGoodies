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

    
    Write-Host -ForegroundColor Cyan "[25] RootFolder:"  $RootFolder
    $currMonth =  Get-Date -Format 'MM'
    #Write-Host -ForegroundColor Cyan "[27] currMonth:"  $currMonth
    $MonthFolderPath = $RootFolder + "\" +  $currMonth
    Write-Host -ForegroundColor Cyan "[29] MonthFolderPath="  $MonthFolderPath
    
    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder  = $RootFolder + "\" + (Get-Date -Format 'MM-dd-yyyy')
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    #Write-Host -ForegroundColor Cyan "[29] RootFolder:"  $RootFolder
    
   
    
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
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $TodayFolder *****************"
    Write-Host -ForegroundColor Green "[52] `$TodayFolderPath=`"$TodayFolderPath`""
    
    Write-Host -ForegroundColor Magenta "CreateFolders"  $TodayFolderPath

    Write-Host -ForegroundColor Cyan "[35] TodayFolder:"  $TodayFolder
    #$ParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    #Write-Host -ForegroundColor Cyan "[35] ParentFolderPath="  $ParentFolderPath
        
    if ((Test-Path $TodayFolderPath) -eq $false)  
    {        
        $TodayFolder = New-Item -Path $MonthFolderPath -Name $todayShort -ItemType Directory
        #$DeployFolder = New-Item -Path $TodayFolder.FullName -Name 'Deploy' -ItemType Directory
        Write-Host -ForegroundColor Yellow "[62]NEW TodayFolder path: $TodayFolderPath" 
        $TodayFolderPath = (Get-ItemProperty  $TodayFolder | select FullName).FullName
        $Destination = $TodayFolder.FullName

        $SourceFolderDeploy = "C:\GitHub\dtp\Deploy"
        Write-Host -ForegroundColor Yellow "[66]Copying: $SourceFolderDeploy" 
        Copy-Item $SourceFolderDeploy $Destination -Recurse

        $SourceFolderWiki = "C:\GitHub\dtp\wiki"                
        Write-Host -ForegroundColor Yellow "[70]Copying: $SourceFolderDeploy" 
        Copy-Item $SourceFolderWiki $Destination -Recurse
        Write-Host -ForegroundColor Yellow "[68] Copied wiki and Deploy to: $TodayFolderPath" 
        if((Test-Path $TodayFolderPath) -eq $false)
        {
            #delete logs folder:
            Write-Host -ForegroundColor Yellow "[75]DELETING: $LogFolder" 
            $LogFolder = $Destination + "\Logs"        
            Remove-Item -Path $LogFolder -Recurse
        }
        
    }
    else
    {
        $TodayFolderPath = (Get-ItemProperty  $TodayFolderPath | select FullName).FullName
        Write-Host -ForegroundColor Yellow "[75]EXISTING TodayFolderPath FullPath:"  $TodayFolderPath        
        <#$Destination = $TodayFolderPath.FullName
        $SourceFolderDeploy = "C:\GitHub\dtp\Deploy"
        Write-Host -ForegroundColor Yellow "[78]EXISTING SourceFolderDeploy :$SourceFolderDeploy"
        Write-Host -ForegroundColor Yellow "[79]EXISTING Destination :$Destination"
        Copy-Item $SourceFolderDeploy $Destination -Recurse -Force

        $SourceFolderWiki = "C:\GitHub\dtp\wiki"                
        Copy-Item $SourceFolderWiki $Destination -Recurse -Force
        Write-Host -ForegroundColor Yellow "[68] Copied wiki and Deploy to: $TodayFolderPath" 
        #>
    }

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
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateFolders FOR $ParentDirPath *****************"

}#CreateFolders

#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$RootFolder = "C:\GitHub\dtpResources"
#$RootFolder = "C:\GitHub\dtpResources\rg-dts-prod-lt"
$ParentFolderPath = (Get-Item $RootFolder).FullName
#$ParentFolder = 'C:\GitHub\dtpResources\bmtn\rg-dtp-prod'
Write-Host "ParentFolderPath:" $ParentFolderPath

$FolderListParamsFile = '$RootFolder\FolderNames.txt'
#$FolderListParamsFile = 'C:\GitHub\dtpResources\FolderNames.txt'
#$FolderListParamsFile = '..\dtpResources\commits.txt'
$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNames.txt'
$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNamesShort.txt'

$SubfoldersFlag = $false
#$SubfoldersFlag = $true

CreateFolders -RootFolder $RootFolder ` -FolderListParamsFile $FolderListParamsFile

<#
CreateFolders -RootFolder $RootFolder `
    -FolderListParamsFile $FolderListParamsFile `
    -SubfoldersFlag $SubfoldersFlag
#>
