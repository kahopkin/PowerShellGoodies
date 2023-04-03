#CreateFolders
<#

$CopyDestinationRootFolder = '..\dtpResources\'
$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'

$FolderListParamsFile = '..\dtpResources\FolderNames.txt'
$FolderListParamsFile = '..\dtpResources\commits.txt'

CreateFolders -CopyDestinationRootFolder $CopyDestinationRootFolder -FolderListParamsFile $FolderListParamsFile


#>

$currDir = Get-Item (Get-Location)
$currDirPath = $currDir.FullName
if($currDirPath -notmatch "PowerShellGoodies")
{
    cd C:\GitHub\PowerShellGoodies
}



Function global:CreateFolders
{
    Param(      
      [Parameter(Mandatory = $true)] [String]$CopyDestinationRootFolder
    , [Parameter(Mandatory = $true)] [String]$CopyLogFolderRoot
    , [Parameter(Mandatory = $false)] [String]$FolderListParamsFile
    , [Parameter(Mandatory = $false)] [Boolean] $SubfoldersFlag
    , [Parameter(Mandatory = $true)] [String] $BranchName
    
    )

    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $TodayFolder *****************"
    Write-host -ForegroundColor Yellow "[36]Params Coming in:"
    Write-host -ForegroundColor Cyan  "`$CopyDestinationRootFolder=`"$CopyDestinationRootFolder`""
    Write-host -ForegroundColor Cyan  "`$CopyLogFolderRoot=`"$CopyLogFolderRoot`""
    Write-host -ForegroundColor Cyan  "`$FolderListParamsFile=`"$FolderListParamsFile`""
    Write-host -ForegroundColor Cyan  "`$SubfoldersFlag=`"$SubfoldersFlag`""

    $currYear =  Get-Date -Format 'yyyy'    
    $YearFolderPath = $CopyDestinationRootFolder + "\" + $currYear
        
    Write-host -ForegroundColor Yellow "[45] currYear"
    Write-host -ForegroundColor Cyan  "`$currYear=`"$currYear`""
           
    if ((Test-Path $YearFolderPath) -eq $false) 
    {
        $YearFolder = New-Item -Path $CopyDestinationRootFolder -Name $currYear -ItemType Directory    
        $YearFolderPath = $YearFolder.FullName
        Write-Host -ForegroundColor Yellow "[52] Create New Folder for Year"
        Write-host -ForegroundColor Cyan  "`$YearFolderPath=`"$YearFolderPath`""
    }
    else
    {
        $YearFolder = Get-Item $YearFolderPath
        $YearFolderPath = $YearFolder.FullName
        Write-Host -ForegroundColor Yellow "[59] Existing Year Folder"
        Write-host -ForegroundColor Green  "`$YearFolderPath=`"$YearFolderPath`""
    }
      
    $currMonth =  Get-Date -Format 'MM'
    $MonthFolderPath = $YearFolderPath + "\" +  $currMonth    
	

    $todayShort = Get-Date -Format 'MM-dd-yyyy'    
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    $TodayFolderPath = $MonthFolderPath + "\" + $TodayFolder

    Write-host -ForegroundColor Yellow "[69] "    
    Write-host -ForegroundColor Cyan  "`$currMonth=`"$currMonth`""    
    Write-host -ForegroundColor Green  "`$YearFolderPath=`"$YearFolderPath`""    
    Write-host -ForegroundColor Green  "`$MonthFolderPath=`"$MonthFolderPath`""    
    Write-host -ForegroundColor Yellow  "`$TodayFolderPath=`"$TodayFolderPath`""
	
    if($SubfoldersFlag.Length -eq 0){$SubfoldersFlag=$false}
    
    #Check for Month Folder, if doesn't exist, create it
    if ((Test-Path $MonthFolderPath) -eq $false) 
    {
        $MonthFolder = New-Item -Path $YearFolderPath -Name $currMonth -ItemType Directory                
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Cyan "[85] NEW Month Folder"
        Write-host -ForegroundColor Green  "`$MonthFolder=`"$MonthFolder`""
        Write-host -ForegroundColor Green  "`$MonthFolderPath=`"$MonthFolderPath`""
    }
    else
    {
        $MonthFolder = Get-Item $MonthFolderPath
        $MonthFolderPath = $MonthFolder.FullName
        Write-Host -ForegroundColor Green "[93] Existing"
        Write-host -ForegroundColor Cyan  "`$MonthFolderPath=`"$MonthFolderPath`""
    }
    
		
    $TodayFolderPath = $MonthFolderPath + "\" +  $TodayFolder
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    
    Write-host -ForegroundColor Yellow "[120]"        
    Write-host -ForegroundColor Cyan  "`$TodayFolder=`"$TodayFolder`""
    #$ParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    #Write-Host -ForegroundColor Cyan "[35] ParentFolderPath="  $ParentFolderPath
        
    if ((Test-Path $TodayFolderPath) -eq $false)  
    {        
        Write-Host -ForegroundColor Magenta "[131] Create Folders at:"  $TodayFolderPath    
        $TodayFolder = New-Item -Path $MonthFolderPath -Name $todayShort -ItemType Directory
        #$DeployFolder = New-Item -Path $TodayFolder.FullName -Name 'Deploy' -ItemType Directory
        Write-Host -ForegroundColor Yellow "[134]NEW TodayFolder" 
        Write-host -ForegroundColor Cyan  "`$TodayFolderPath=`"$TodayFolderPath`""
        $TodayFolderPath = $TodayFolder.FullName        
        
    }

    $Destination = $TodayFolderPath + "\" + $BranchName + "_"+ "Deploy_" + (Get-Date -Format 'HH-mm')
        
    Write-host -ForegroundColor Magenta  "`$TodayFolderPath=`"$TodayFolderPath`""
    Write-Host -ForegroundColor Yellow "[102]Copying: $SourceFolder" 
    Write-host -ForegroundColor Cyan  "`$SourceFolder=`"$SourceFolder`""
    Write-host -ForegroundColor Cyan  "`$Destination=`"$Destination`""        
    #Copy-Item -Exclude Logs $SourceFolder $Destination -Recurse
    Copy-Item $SourceFolder $Destination -Recurse     	 
    
    $TodayFolderPath = $Destination
    #$TodayFolderPath = $Destination + "_" + $BranchName
    Write-Host -ForegroundColor Magenta "[123]SubfoldersFlag: $SubfoldersFlag" 
    Write-Host -ForegroundColor Magenta "[124]TodayFolderPath: $TodayFolderPath" 
    Write-Host -ForegroundColor Yellow "`$BranchName=`"$BranchName`""


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
                #Write-Host -ForegroundColor Green "[$i] $FullName created " 
            }
            
            $i++
	    } 
    }#$SubfoldersFlag -eq $true
    #>


    explorer $TodayFolderPath

    ##### Logs
    <#Write-host -ForegroundColor Magenta " ***************************************"
    Write-host -ForegroundColor Magenta " ****************  LOGS ****************"
    Write-host -ForegroundColor Magenta " ***************************************"
    $currYear =  Get-Date -Format 'yyyy'    
    $LogYearFolderPath = $CopyLogFolderRoot + "\" + $currYear
        
    Write-host -ForegroundColor Yellow "[135]"
    Write-host -ForegroundColor Cyan  "`$LogYearFolderPath=`"$LogYearFolderPath`""
           
    if ((Test-Path $LogYearFolderPath) -eq $false) 
    {
        $LogYearFolder = New-Item -Path $CopyLogFolderRoot -Name $currYear -ItemType Directory    
        $LogYearFolderPath = $LogYearFolder.FullName
        Write-Host -ForegroundColor Yellow "[142]"
        Write-host -ForegroundColor Cyan  "`$LogYearFolderPath=`"$LogYearFolderPath`""
    }
    else
    {
        $LogYearFolder = Get-Item $LogYearFolderPath
        $LogYearFolderPath = $LogYearFolder.FullName
        Write-Host -ForegroundColor Yellow "[149]"
        Write-host -ForegroundColor Green  "`$LogYearFolderPath=`"$LogYearFolderPath`""
    }
       
    $currMonth =  Get-Date -Format 'MM'
    $LogMonthFolderPath = $CopyLogFolderRoot + "\" + $currYear + "\" +  $currMonth    
	
    $todayShort = Get-Date -Format 'MM-dd-yyyy'    
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    
    Write-host -ForegroundColor Yellow "[159]"    
    Write-host -ForegroundColor Cyan  "`$LogMonthFolderPath=`"$LogMonthFolderPath`""    
    Write-host -ForegroundColor Cyan  "`$CopyLogFolderRoot=`"$CopyLogFolderRoot`""
    Write-host -ForegroundColor Cyan  "`$currMonth=`"$currMonth`""
    
	
    if($SubfoldersFlag.Length -eq 0){$SubfoldersFlag=$false}
    
    #Check for Month Folder, if doesn't exist, create it
    if ((Test-Path $LogMonthFolderPath) -eq $false) 
    {
        $LogMonthFolder = New-Item -Path $LogMonthFolderPath -Name $currMonth -ItemType Directory                
        $LogMonthFolderPath = $LogMonthFolder.FullName
        Write-Host -ForegroundColor Cyan "[172]"
        Write-host -ForegroundColor Green  "`$LogMonthFolder=`"$LogMonthFolder`""
        Write-host -ForegroundColor Green  "`$LogMonthFolderPath=`"$LogMonthFolderPath`""
    }
    else
    {
        $LogMonthFolder = Get-Item $LogMonthFolderPath
        $LogMonthFolderPath = $LogMonthFolder.FullName
        Write-Host -ForegroundColor Green "[180]"
        Write-host -ForegroundColor Cyan  "`$LogMonthFolderPath=`"$LogMonthFolderPath`""
    }
    
		
    $LogTodayFolderPath = $LogMonthFolderPath + "\" +  $TodayFolder
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    
    Write-host -ForegroundColor Yellow "[188]"        
    Write-host -ForegroundColor Cyan  "`$LogTodayFolderPath=`"$LogTodayFolderPath`""
    #Write-host -ForegroundColor Cyan  "`$CopyLogFolderPath=`"$CopyLogFolderPath`""
    Write-host -ForegroundColor Cyan  "`$TodayFolder=`"$TodayFolder`""
    #$ParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    #Write-Host -ForegroundColor Cyan "[35] ParentFolderPath="  $ParentFolderPath
        
    if ((Test-Path $LogTodayFolderPath) -eq $false)  
    {        
        Write-Host -ForegroundColor Magenta "[197] Create Folder at:"  $LogTodayFolderPath    
        $TodayFolder = New-Item -Path $LogMonthFolderPath -Name $todayShort -ItemType Directory
        #$DeployFolder = New-Item -Path $TodayFolder.FullName -Name 'Deploy' -ItemType Directory
        #Write-Host -ForegroundColor Yellow "[200]NEW TodayFolder" 
        #Write-host -ForegroundColor Cyan  "`$LogTodayFolderPath=`"$LogTodayFolderPath`""
        $LogTodayFolderPath = $TodayFolder.FullName        
        
    }
        $LogsSourceFolder = $SourceFolder + "\Logs"
		$Destination = $LogTodayFolderPath + "\Deploy-" + (Get-Date -Format 'HH-mm')
        
        Write-host -ForegroundColor Cyan  "`$LogTodayFolderPath=`"$LogTodayFolderPath`""
        Write-Host -ForegroundColor Yellow "[209]Copying: $LogsSourceFolder" 
        Write-host -ForegroundColor Cyan  "`$LogsSourceFolder=`"$LogsSourceFolder`""
        Write-host -ForegroundColor Cyan  "`$Destination=`"$Destination`""        
        if ((Test-Path $LogTodayFolderPath))  
        {
            Copy-Item $LogsSourceFolder $Destination -Recurse
        }

  #>     
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateFolders FOR $ParentDirPath *****************"

}#CreateFolders

#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$CopyDestinationRootFolder = "C:\GitHub\dtpResources"
$SourceFolder = "C:\GitHub\dtp\Deploy"
$CopyLogFolderRoot = "C:\GitHub\_App Registration Logs"
#$CopyDestinationRootFolder = "C:\GitHub\dtpResources\rg-dts-prod-lt"
$ParentFolderPath = (Get-Item $CopyDestinationRootFolder).FullName
#$ParentFolder = 'C:\GitHub\dtpResources\bmtn\rg-dtp-prod'
Write-Host "ParentFolderPath:" $ParentFolderPath

#$FolderListParamsFile = '$CopyDestinationRootFolder\FolderNames.txt'
$FolderListParamsFile = 'FolderNames.txt'
#$FolderListParamsFile = 'C:\GitHub\dtpResources\FolderNames.txt'
#$FolderListParamsFile = '..\dtpResources\commits.txt'
$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNames.txt'
$FolderListParamsFile = 'C:\GitHub\PowerShellGoodies\FolderNamesShort.txt'

$SubfoldersFlag = $false
#$SubfoldersFlag = $true
$BranchName ="kahopkin-Fix-Path-Match-to-Case-Insensitive"
$BranchName = "ModularizeAutomation"

CreateFolders   -CopyDestinationRootFolder $CopyDestinationRootFolder `
                -FolderListParamsFile $FolderListParamsFile `
                -CopyLogFolderRoot $CopyLogFolderRoot `
                -SubfoldersFlag $SubfoldersFlag 
                #-BranchName $BranchName