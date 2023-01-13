#RenameFiles

Function global:RenameFiles
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder
    , [Parameter(Mandatory = $false)] [String]$FolderListParamsFile
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateFolders FOR $ParentDirPath *****************"
    
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
        #Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
        #CyanWrite-Host -ForegroundColor Cyan "FileCount: $FileCount "
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
           
            #Write-Host -ForegroundColor Yellow "[$i] FullFileName: $FullFileName "
            #Write-Host "ParentFolder: $ParentFolder "
            #Write-Host "[$i] FullPath: $FullPath "
            #Write-Host -ForegroundColor Yellow "[$i] FileName: $FullFileName , Extension: $Extension"
            
            if($FileName -eq "template")
            {
                Write-Host -ForegroundColor Yellow "`n[$i] FileName: $FullFileName"
                Write-Host -ForegroundColor Green "[$i] FullPath: $FullPath"
                #Write-Host -ForegroundColor Green "[$i] ParentFolder: $ParentFolder"
                $NewName = $ParentFolder+$Extension
                #Write-Host "NewName: $NewName"
                #Rename-Item -Path "$FullPath" -NewName $NewName
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                Write-Host -ForegroundColor DarkYellow  "[$i] ParentFullPath: $ParentFullPath "
                Write-Host "[$i] ParentPath: $ParentPath"                      
                Write-Host "[$i] FullPath: $FullPath "                      
                #$NewPath = $ParentFullPath
                #Write-Host "[68] NewPath: $NewPath "
                Move-Item -Path $FullPath -Destination $ParentFullPath
            }
            <#
            else
            {
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                Write-Host -ForegroundColor DarkYellow  "[$i] ParentFullPath: $ParentFullPath "
                Write-Host "[$i] ParentPath: $ParentPath"                      
                Write-Host "[$i] FullPath: $FullPath "                      
                #$NewPath = $ParentFullPath
                #Write-Host "[68] NewPath: $NewPath "
                Move-Item -Path $FullPath -Destination $ParentFullPath
            }
            #>
            if($FileName -eq "parameters")
            {
                Remove-Item $FullPath
            }
            $ItemType = "File"
            #$FileCount = 0
            #debugline:
            #"File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime           
           
        $i++
        } #Foreach ($dir In $dirs)
    }
    else
    {
        $TodayFolder = New-Item -ItemType Directory -Name $todayShort   
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "$ParentFolder ParentFolder" 
    }  
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateFolders FOR $ParentDirPath *****************"
}#RenameFiles


Function global:ExtractZip
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder    
    )
      $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START ExtractZip FOR $ParentDirPath *****************"
    
    #$todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder = Get-Date -Format 'MM-dd-yyyy'
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "EXISTING $ParentFolder ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Green "$ParentFolder FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        #Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
        #CyanWrite-Host -ForegroundColor Cyan "FileCount: $FileCount "
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

            if($Extension -eq ".zip")
            {
                    
                #Write-Host -ForegroundColor Yellow "[$i] FullFileName: $FullFileName "
                #Write-Host "ParentFolder: $ParentFolder "
                #Write-Host -ForegroundColor Yellow "[$i] FullFileName: $FullFileName "
                #Write-Host "ParentFolder: $ParentFolder "
                
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                Write-Host "[$i] FullPath: $FullPath "                      
                Expand-Archive -LiteralPath $FullPath -DestinationPath $ParentFullPath -Force
                
                $NewPath = $ParentFullPath + "\Zips"
                #Write-Host "NewPath: $NewPath "
                Move-Item -Path $FullPath -Destination $NewPath
            }               
                
                $ItemType = "File"
                #$FileCount = 0
                #debugline:
                #"File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime           
         
        $i++
        } #Foreach ($dir In $dirs)
    }
    else
    {
        $TodayFolder = New-Item -ItemType Directory -Name $todayShort   
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "$ParentFolder ParentFolder" 
    }  
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateFolders FOR $ParentDirPath *****************"


}#ExtractZip



#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'

$ParentFolder = $todayShort + "\Zips" 
ExtractZip -ParentFolder $ParentFolder 

$FolderListParamsFile = '..\dtpResources\FolderNames.txt'
$ParentFolder = '..\dtpResources\'
$ParentFolder = '..\dtpResources\'

#RenameFiles -ParentFolder $ParentFolder -FolderListParamsFile $FolderListParamsFile
