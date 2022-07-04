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
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $RootFolder *****************"
    
    
    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder  = $RootFolder + "\" + (Get-Date -Format 'MM-dd-yyyy')
    $ParentFolder  = (Get-Date -Format 'MM-dd-yyyy')
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Yellow "EXISTING $ParentFolder ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Yellow "$ParentFolder FullPath:"  $ParentFolderPath
    }
    else
    {
        $TodayFolder = New-Item -Path $RootFolder -Name $ParentFolder -ItemType Directory
        $ParentFolderPath = (Get-ItemProperty  $TodayFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "$TodayFolder  path: $ParentFolderPath" 
    }
    #>

    $ParamsFile = Get-Content -Path $FolderListParamsFile
	foreach($line in $ParamsFile) 
	{
		$Name = $line
		$folder = New-Item -ItemType Directory -Path $ParentFolderPath -Name $Name 
        $FullName = $folder.FullName
        Write-Host -ForegroundColor Yellow "$FullName created " 
	} 
       
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateFolders FOR $ParentDirPath *****************"

}#CreateFolders

#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$RootFolder = 'C:\GitHub\dtpResources'
#$ParentFolder = 'D:\Users\Kat\GitHub\today'

$FolderListParamsFile = 'C:\GitHub\dtpResources\FolderNames.txt'
#$FolderListParamsFile = 'C:\GitHub\dtpResources\FolderNames.txt'
#$FolderListParamsFile = '..\dtpResources\commits.txt'

CreateFolders -RootFolder $RootFolder -FolderListParamsFile $FolderListParamsFile

