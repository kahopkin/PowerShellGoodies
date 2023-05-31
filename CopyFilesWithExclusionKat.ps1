
$SourceFolder="C:\GitHub\dtp\Deploy"
$DestinationFolder="C:\GitHub\dtpResources\2023\05\05-03-2023\ModularizeAutomation_Deploy_11-57"
#$SourceFolder = "C:\GitHub\dtp\Deploy\*"
#$SourceFolder = 'c:\sources'
#$Destination = 'c:\build'


Write-host -ForegroundColor Cyan  "`$SourceFolder=`"$SourceFolder`""
$SourceFolderLength = $SourceFolder.length
Write-host -ForegroundColor Cyan  "`$SourceFolderLength=`"$SourceFolderLength`""   
Write-host -ForegroundColor Cyan  "`$Destination=`"$Destination`""

$exclude = @("*.pdf","*.md", "*.docx")
$excludeMatch = @("SQL", "TestData", "Migrations", "LocalSetUp")

[regex] $excludeMatchRegEx = ‘(?i)‘ + (($excludeMatch |foreach {[regex]::escape($_)}) –join “|”) + ‘’
#$excludeMatchRegEx.ToString():
#$excludeMatchRegEx = (?i)SQL|TestData|Migrations|LocalSetUp

$i=0

$ChildItems = Get-ChildItem -Path $SourceFolder -Recurse -Exclude $exclude | 
 where { $excludeMatch -eq $null -or $_.FullName.Replace($SourceFolder, "") -notmatch $excludeMatchRegEx}


foreach ($item in $ChildItems) 
{    
    #Write-Host "`n[$i]=" $item.Name

    if ($item.PSIsContainer) 
    {
        Write-Host -ForegroundColor Cyan "`n[$i] - Folder: " $item.Name
        $PSIsContainerName = $item.FullName
        $ParentFullName = $item.Parent.FullName
        $currItemFullName = $item.FullName
        $Source = $currItemFullName

        Write-Host -ForegroundColor White "`$PSIsContainerName=`"$PSIsContainerName`""    
        Write-Host -ForegroundColor White "`$ParentFullName=`"$ParentFullName`""
        Write-Host -ForegroundColor White "`$currItemFullName=`"$currItemFullName`""

        $Destination = Join-Path $Destination $item.Parent.FullName.Substring($SourceFolder.length)  
        
        Write-Host -ForegroundColor Green "`$Source=`"$Source`""
        Write-Host -ForegroundColor Cyan "`$Destination=`"$Destination`""
          
        Copy-Item -Path $Source -Destination $Destination -Recurse
    } 
    else 
    {
        Write-Host -ForegroundColor Yellow "`n[$i] - File:" $item.Name
    
        $PSIsContainerName = $item.FullName
        $PSParentPath = $item.PSParentPath.Substring(38)
        $currItemFullName = $item.FullName
        $parentDirPath = $item.DirectoryName
        $parentDir = (Get-Item -Path $parentDirPath).Name
        $Source = $currItemFullName

        Write-Host -ForegroundColor White "`$PSIsContainerName=`"$PSIsContainerName`""
        Write-Host -ForegroundColor Cyan  "`$PSParentPath=`"$PSParentPath`""
        Write-Host -ForegroundColor Green  "`$parentDirPath=`"$parentDirPath`""
        Write-Host -ForegroundColor Cyan  "`$parentDir=`"$parentDir`""
        Write-Host -ForegroundColor White "`$currItemFullName=`"$currItemFullName`""
               

        $ParentDestination = Join-Path $DestinationFolder $parentDir
        Write-Host -ForegroundColor Green "`$ParentDestination=`"$ParentDestination`""
        $Destination = Join-Path $DestinationFolder $item.FullName.Substring($SourceFolder.length)
        
        if ((Test-Path $ParentDestination) -eq $false) 
        {            
            Write-Host -ForegroundColor Red "ParentDestination=$ParentDestination folder doesn't exist"
            $ParentFolder = New-Item -Path $DestinationFolder -Name $parentDir -ItemType Directory        
            $Destination = (Get-ItemProperty  $ParentFolder | select FullName).FullName + "\"        

        }

        Write-Host -ForegroundColor Yellow "`$Source=`"$Source`""
        Write-Host -ForegroundColor Magenta "`$Destination=`"$Destination`""
        #Copy-Item -Path $Source -Destination $Destination
    }
    
    #Write-Host -ForegroundColor Cyan "`$Destination=`"$Destination`""
    #Copy-Item $currItemFullName $Destination
    $i++
}#foreach