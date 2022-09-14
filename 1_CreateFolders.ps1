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
    
    
    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder  = $RootFolder + "\" + (Get-Date -Format 'MM-dd-yyyy')
    $ParentFolder  = (Get-Date -Format 'MM-dd-yyyy')
    Write-Host -ForegroundColor White "[29] ParentFolder:"  $ParentFolder
    $ParentFolderPath = $RootFolder + $ParentFolder
    Write-Host -ForegroundColor White "[31] ParentFolderPath="  $ParentFolderPath
    #Test-Path $ParentFolderPath
    if (Test-Path $ParentFolderPath) 
    {
        Write-Host -ForegroundColor Cyan "[35] EXISTING $ParentFolder ParentFolder" 
        $ExistingParentFolderPath = (Get-ItemProperty  $ParentFolderPath | select FullName).FullName
        Write-Host -ForegroundColor Cyan "[37] ExistingParentFolderPath FullPath:"  $ExistingParentFolderPath
    }
    else
    {
        $TodayFolder = New-Item -Path $RootFolder -Name $ParentFolder -ItemType Directory
        #$DeployFolder = New-Item -Path $TodayFolder.FullName -Name 'Deploy' -ItemType Directory
        $SourceFolder = "C:\GitHub\dtp\Deploy"
        $Destination = $TodayFolder.FullName
        Copy-Item $SourceFolder $Destination -Recurse
        $ParentFolderPath = (Get-ItemProperty  $TodayFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "[47] $TodayFolder  path: $ParentFolderPath" 
    }

    Write-Host -ForegroundColor Magenta "[50]: SubfoldersFlag=" $SubfoldersFlag
    if($SubfoldersFlag)
    {
        $i=0
        $ParamsFile = Get-Content -Path $FolderListParamsFile
	    foreach($line in $ParamsFile) 
	    {
		    $Name = $line
            $NewFolderPath = "$ParentFolderPath\$Name"
            Write-Host -ForegroundColor Yellow "[$i] NewFolderPath = "$NewFolderPath 
            
            if ((Test-Path $NewFolderPath) -ne $true) 
		    {
                $folder = New-Item -ItemType Directory -Path $ParentFolderPath -Name $Name 
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

CreateFolders -RootFolder $RootFolder `
-FolderListParamsFile $FolderListParamsFile
#-SubfoldersFlag $SubfoldersFlag

