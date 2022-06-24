#CreateFolders
<#

$ParentFolder = '..\dtpResources\'
$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'

$FolderListParamsFile = '..\dtpResources\FolderNames.txt'
$FolderListParamsFile = '..\dtpResources\commits.txt'

CreateFolders -ParentFolder $ParentFolder -FolderListParamsFile $FolderListParamsFile
#>

Function global:CreateFolders
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder
    , [Parameter(Mandatory = $false)] [String]$FolderListParamsFile
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $ParentDirPath *****************"
    
    $ParamsFile = Get-Content -Path $FolderListParamsFile
	foreach($line in $ParamsFile) 
	{
		$Name = $line
		$folder = New-Item -ItemType Directory -Path $ParentFolder -Name $Name 
        $FullName = $folder.FullName
        Write-Host -ForegroundColor Yellow "$FullName created " 
	} 
       
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateFolders FOR $ParentDirPath *****************"

}#CreateFolders

#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'

$ParentFolder = '..\dtpResources\'
$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'

$FolderListParamsFile = '..\dtpResources\FolderNames.txt'
$FolderListParamsFile = '..\dtpResources\commits.txt'

CreateFolders -ParentFolder $ParentFolder -FolderListParamsFile $FolderListParamsFile
