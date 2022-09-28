#DeleteEmptyFolders

Function global:DeleteEmptyFolders
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder    
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START DeleteEmptyFolders FOR $ParentDirPath *****************"
    
    #$todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder = Get-Date -Format 'MM-dd-yyyy'
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "[17] EXISTING $ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Cyan "[20] ParentFolder: $ParentFolder"
        Write-Host -ForegroundColor Cyan "[21] FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Cyan "[25] $ParentFolderPath FolderCount: $FolderCount "      
        Write-Host -ForegroundColor Cyan "[26] $ParentFolderPath FileCount: $FileCount "
        $i = 0  
        $j = 0  
    
        Foreach ($dir In $dirs) 
        { 
        
            $FullPath =  $dir.FullName
            $FileName = $dir.BaseName        
            $ParentFolder = Split-Path (Split-Path $dir.FullName -Parent) -Leaf
            $DirectoryPath = $dir.DirectoryName
            $Extension = $dir.Extension
            #'Extension: ' + $Extension
            $LastWriteTime = $dir.LastWriteTime
            $LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            $FullFileName = Split-Path $dir.FullName -Leaf -Resolve
            
            #debugline:
            #$FullFileName +" - "+$LastWriteTime

            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name 
            $Size = $subFolder.sum 
            $SizeKB =  "{0:N2}"-f ($Size / 1KB) + " KB"
            $SizeMB =  "{0:N2}"-f ($Size / 1MB) + " MB"
            $SizeGB =  "{0:N2}"-f ($Size / 1GB) + " GB"
           
           if($isDir)
           {
                #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[$i] DIRECTORY FullFileName: $FullFileName "                
                #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] DIRECTORY FullPath: $FullPath "                
                $FileCount = (Get-ChildItem -Path $FullPath -Recurse -File | Measure-Object).Count
                $FolderCount = (Get-ChildItem -Path $FullPath -Recurse -Directory | Measure-Object).Count
                Write-Host -ForegroundColor Cyan "[61] $FullPath"
                Write-Host -ForegroundColor Yellow "FolderCount: $FolderCount "      
                Write-Host -ForegroundColor Yellow "FileCount: $FileCount "
                #Write-Host -ForegroundColor Yellow "[$i] FileCount=$FileCount"
                if( $FileCount -eq 0 -and $FileName -ne "Bicep")
                {
                    #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[65][$i] DIRECTORY FullFileName: $FullFileName "                
                    Write-Host -ForegroundColor Green -BackgroundColor DarkBlue "[66][$i] REMOVING DIRECTORY FullPath: $FullPath "
                    Remove-Item -Path $FullPath -Recurse
                }

           }#id=f folder
           }#foreach
    }#if
}




$RootFolder = "C:\GitHub\dtpResources"
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$month = Get-Date -Format 'MM'
$ParentFolder = "$RootFolder\$month\"

$ParentFolder = "$RootFolder\$month\$todayShort"

#$ParentFolderPath = (Get-Item $ParentFolder).FullName
$ParentFolder = 'C:\GitHub\dtpResources\rg-dts-prod-lt'

Write-Host "[84] ParentFolderPath:" $ParentFolder
Write-Host "[85] ParentFolderPath:" $ParentFolderPath

DeleteEmptyFolders -ParentFolder $ParentFolder

