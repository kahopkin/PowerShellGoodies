#DeleteLogFiles.ps1

Function global:DeleteLogFiles
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder    
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START DeleteLogFiles FOR $ParentDirPath *****************"
    
    #$todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder = Get-Date -Format 'MM-dd-yyyy'
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "[17] EXISTING $ParentFolder ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Cyan "[20] ParentFolder: $ParentFolder"
        Write-Host -ForegroundColor Cyan "[21] FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
        Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
        $i = 0  
        $j = 0  
    
        Foreach ($file In $dirs) 
        { 
        
            $FullPath =  $file.FullName
            $FileName = $file.BaseName        
            $ParentFolder = Split-Path (Split-Path $file.FullName -Parent) -Leaf
            $DirectoryPath = $file.DirectoryName
            $Extension = $file.Extension            
            $LastWriteTime = $file.LastWriteTime
            $LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            $FullFileName = Split-Path $file.FullName -Leaf -Resolve
            
            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $file.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name            
         
            Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[$i] FILE FullFileName: $FullFileName "                
            Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] FILE FullPath: $FullPath "
                
            Remove-Item -Path $FullPath
            $i++
         
           }#foreach
    }#if
}

$todayShort = Get-Date -Format 'MM-dd-yyyy'

$ParentFolder = 'C:\GitHub\dtp\Deploy\logs'
#$ParentFolder = $todayShort

DeleteLogFiles -ParentFolder $ParentFolder

