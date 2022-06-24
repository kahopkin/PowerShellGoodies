#CreateFolders

Function global:CreateFolders
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder
    , [Parameter(Mandatory = $false)] [String]$FolderListParamsFile
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $ParentDirPath *****************"
    
    <#
    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    $ParentFolder = Get-Date -Format 'MM-dd-yyyy'
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Yellow "EXISTING $ParentFolder ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Yellow "$ParentFolder FullPath:"  $ParentFolderPath
    }
    else
    {
        $TodayFolder = New-Item -ItemType Directory -Name $todayShort   
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "$ParentFolder ParentFolder" 
    }
    #>

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



 #>   
 	<#
  $todayLong > $OutFile
    $ParentDirPath >> $OutFile
  Write-Host -ForegroundColor Cyan "OutFile: $OutFile"

    $today = Get-Date -Format 'MM-dd-yyyy'
    $BeforeFile= '..\logs\' +  $today + '-' + $ParentDirPath + '-BeforeRemoveDeployments.txt'
    Write-Host -ForegroundColor Cyan "BeforeFile: $BeforeFile"

    $AfterFile= '..\logs\' +  $today + '-' + $ParentDirPath + '-AfterFileRemoveDeployments.txt'
    Write-Host -ForegroundColor Cyan "AfterFile: $AfterFile"
    
    
    Write-Host "deployments.length= " $deployments.Length
 


    $i=0
    foreach ($item in $deployments) {    
    
	
        $DeploymentName = $item.DeploymentName
        $TimeStamp =  $item.Timestamp.ToShortDateString()
        Write-Host $TimeStamp

        
        if($DeploymentName.StartsWith($Filter) -or $Filter -eq 'All' )
        {
            Write-Host -ForegroundColor Cyan "[$i] REMOVING: " $TimeStamp - $DeploymentName
            Remove-AzResourceGroupDeployment -ParentDirPath $ParentDirPath -Name $DeploymentName
            Write-Host -ForegroundColor Green "[$i] $DeploymentName Remove-AzResourceGroupDeployment SUCCESS" 
        }
        else
        {
            #Write-Host -ForegroundColor Yellow "[$i]=" $item.DeploymentName
           $item.TimeStamp.ToString() + " | " + $item.DeploymentName + " | " + $item.ProvisioningState >> $OutFile
        }
        
       <# 
        if($TimeStamp -ne $today.ToString() )
        {
            Write-Host -ForegroundColor Cyan "[$i] REMOVING: " $item.DeploymentName
            Remove-AzResourceGroupDeployment -ParentDirPath $ParentDirPath -Name $DeploymentName
            Write-Host -ForegroundColor Green "[$i] $DeploymentName Remove-AzResourceGroupDeployment SUCCESS" 
        }
        else
        {
            #Write-Host -ForegroundColor Yellow "[$i]=" $item.DeploymentName
           $item.TimeStamp.ToString() + " | " + $item.DeploymentName + " | " + $item.ProvisioningState >> $OutFile
        }
     
        $i++
    }    
   #>
