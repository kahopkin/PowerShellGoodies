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
    , [Parameter(Mandatory = $false)] [Boolean] $SubfoldersFlag
    )

    
    #Write-Host -ForegroundColor Cyan "[23] RootFolder:"  $RootFolder
    $currYear =  Get-Date -Format 'yyyy'
    #Write-Host -ForegroundColor Yellow "[25] currYear:"  $currYear
    $YearFolderPath = $RootFolder + "\" + $currYear
    #Write-Host -ForegroundColor Cyan "[27] YearFolderPath:"  $YearFolderPath
    if ((Test-Path $YearFolderPath) -eq $false) 
    {
        $YearFolder = New-Item -Path $RootFolder -Name $currYear -ItemType Directory
        #Write-Host -ForegroundColor Cyan "[31] YearFolder="  $YearFolder.FullName
        $YearFolderPath = $YearFolder.FullName
        #Write-Host -ForegroundColor Cyan "[33] YearFolder.Path="  $YearFolder.FullName
    }
    else
    {
        $YearFolder = Get-Item $YearFolderPath
        $YearFolderPath = $YearFolder.FullName
        #Write-Host -ForegroundColor Green "[38] YearFolderPath:"  $YearFolderPath
    }
    $RootFolder = $RootFolder 
    Write-Host -ForegroundColor Cyan "[41] RootFolder:"  $RootFolder
    $currMonth =  Get-Date -Format 'MM'
    #Write-Host -ForegroundColor Yellow "[27] currMonth:"  $currMonth
    $MonthFolderPath = $RootFolder + "\" + $currYear + "\" +  $currMonth
    Write-Host -ForegroundColor Cyan "`$MonthFolderPath=`"$MonthFolderPath`""
    
    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder  = $RootFolder + "\" + (Get-Date -Format 'MM-dd-yyyy')
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    #Write-Host -ForegroundColor Cyan "[29] RootFolder:"  $RootFolder
    
    if($SubfoldersFlag.Length -eq 0){$SubfoldersFlag=$false}
    
    #Check for Month Folder, if doesn't exist, create it
    if ((Test-Path $MonthFolderPath) -eq $false) 
    {
        $MonthFolder = New-Item -Path $RootFolder -Name $currMonth -ItemType Directory
        Write-Host -ForegroundColor Cyan "[59] MonthFolder="  $MonthFolder.FullName
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Cyan "[61] MonthFolder.Path="  $MonthFolder.FullName
    }
    else
    {
        $MonthFolder = Get-Item $MonthFolderPath
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Green "[48] MonthFolderPath:"  $MonthFolderPath
    }
    
    $TodayFolderPath = $MonthFolderPath + "\" +  $TodayFolder
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $TodayFolder *****************"
    Write-Host -ForegroundColor Green "[72] `$TodayFolderPath=`"$TodayFolderPath`""
    
    Write-Host -ForegroundColor Magenta "CreateFolders"  $TodayFolderPath
    Write-Host -ForegroundColor Cyan "[77] TodayFolder:"  $TodayFolder
    #$ParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    #Write-Host -ForegroundColor Cyan "[35] ParentFolderPath="  $ParentFolderPath
        
    if ((Test-Path $TodayFolderPath) -eq $false)  
    {        
        $TodayFolder = New-Item -Path $MonthFolderPath -Name $todayShort -ItemType Directory
        #$DeployFolder = New-Item -Path $TodayFolder.FullName -Name 'Deploy' -ItemType Directory
        Write-Host -ForegroundColor Yellow "[85]NEW TodayFolder path: $TodayFolderPath" 
        $TodayFolderPath = (Get-ItemProperty  $TodayFolder | select FullName).FullName
        #$Destination = $TodayFolder.FullName
        $Destination = $TodayFolderPath + "\Deploy-" + (Get-Date -Format 'HH-mm')
        $SourceFolderDeploy = "C:\GitHub\dtp\Deploy"#+ (Get-Date -Format 'HH-mm')
        Write-Host -ForegroundColor Yellow "[90]Copying: $SourceFolderDeploy" 
        Write-host -ForegroundColor Cyan  "`$Destination=`"$Destination`""
        Copy-Item $SourceFolderDeploy $Destination -Recurse
        <#
        $SourceFolderWiki = "C:\GitHub\dtp\wiki"                
        Write-Host -ForegroundColor Yellow "[70]Copying: $SourceFolderWiki" 
        Copy-Item $SourceFolderWiki $Destination -Recurse
        
        Write-Host -ForegroundColor Yellow "[68] Copied wiki and Deploy to: $TodayFolderPath" 
        #>
        if((Test-Path $TodayFolderPath) -eq $false)
        {
            #delete logs folder:
            Write-Host -ForegroundColor Yellow "[102]DELETING: $LogFolder" 
            $LogFolder = $Destination + "\Logs"        
            Remove-Item -Path $LogFolder -Recurse
        }
        
    }
    else
    {
        $TodayFolderPath = (Get-ItemProperty  $TodayFolderPath | select FullName).FullName
        Write-Host -ForegroundColor Yellow "[111] EXISTING TodayFolderPath FullPath:"  $TodayFolderPath    
        $TodayFolder = (Get-Item -Path $MonthFolderPath).FullName
        $SourceFolderDeploy = "C:\GitHub\dtp\Deploy"
        $Destination = $TodayFolderPath + "\Deploy-" + (Get-Date -Format 'HH-mm')
        Write-host -ForegroundColor Green  "`$TodayFolder=`"$TodayFolder`""
        Write-Host -ForegroundColor Yellow "[114] Copying: $SourceFolderDeploy" 
        Write-host -ForegroundColor Green  "`$SourceFolderDeploy=`"$SourceFolderDeploy`""
        Write-host -ForegroundColor Green  "`$Destination=`"$Destination`""
        Copy-Item $SourceFolderDeploy $Destination -Recurse
            
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

    Write-Host -ForegroundColor Green "[129]: SubfoldersFlag=" $SubfoldersFlag
    Write-Host -ForegroundColor Green "[130] TodayFolderPath="  $TodayFolderPath
    
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
