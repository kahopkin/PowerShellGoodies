#ExtractZips
<#

$todayShort = Get-Date -Format 'MM-dd-yyyy'

$ParentFolder = $todayShort + "\Zips" 

$ParentFolder = $todayShort

ExtractZips -ParentFolder $ParentFolder 
#>


Function global:ExtractZips
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder    
    )
      $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START ExtractZips FOR $ParentDirPath *****************"
    
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
        #Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
        $i = 0  
        $j = 0  
    
        Foreach ($dir In $dirs) 
        { 
        
            $FullPath =  $dir.FullName
            $FileName = $dir.BaseName        
            $ParentFolder = Split-Path (Split-Path $dir.FullName -Parent) -Leaf
            $DirectoryPath = $dir.DirectoryName
            $FullFileName = Split-Path $dir.FullName -Leaf -Resolve
            $Extension = $dir.Extension
            #'Extension: ' + $Extension
            $LastWriteTime = $dir.LastWriteTime
            $LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            
            
            #debugline:
            #$FullFileName +" - "+$LastWriteTime

            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name            

            if($Extension -eq ".zip")
            {
                
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                    
                Write-Host -ForegroundColor Yellow "`n[$i] FullFileName: $FullFileName "
                Write-Host -ForegroundColor Yellow "`[$i] FileName: $FileName "
                Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "                
                Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor Cyan "[$i] ParentFolder: $ParentFolder "                
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                
                $NewFolderPath=$DirectoryPath+"\"+$FileName
                Write-Host "[$i] NewFolderPath: $NewFolderPath "                      
                
                if ((Test-Path $NewFolderPath) -ne $true)
                {
                    $folder = New-Item -ItemType Directory -Path $DirectoryPath -Name $FileName 
                    $FullName = $folder.FullName
                    Write-Host -ForegroundColor Green "[$i][75] $FullName created " 
                }
                
                #Expand-Archive -LiteralPath $FullPath -DestinationPath $ParentFullPath -Force
                $ParamFile = $NewFolderPath+"\"+ "parameters.json"
                if ( (Test-Path $ParamFile) -ne $true )
                {
                    Expand-Archive -LiteralPath $FullPath -DestinationPath $NewFolderPath
                    Write-Host "[$i][87] Expand SUCCESS: FullPath: $FullPath "                                       
                }
                               
                
                $TemplateFile = $NewFolderPath+"\"+ "template.json"
                if ( (Test-Path $TemplateFile) -ne $true )
                {
                    Expand-Archive -LiteralPath $FullPath -DestinationPath $NewFolderPath
                    Write-Host "[$i][87] Expand SUCCESS: FullPath: $FullPath "                                       
                }

                $NewPath = $ParentFullPath + "\Zips"
                #Write-Host -ForegroundColor Green "`nMoving $FullFileName to NewPath: $NewPath "
                #Move-Item -Path $FullPath -Destination $NewPath
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
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED ExtractZips FOR $ParentDirPath *****************"
}#ExtractZips

$todayShort = Get-Date -Format 'MM-dd-yyyy'
#$ParentFolder = $todayShort + "\Zips" 
#$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'
#$ParentFolder = 'C:\GitHub\dtpResources\rg-dts-prod-lt'
$ParentFolder = "C:\GitHub\dtpResources\$todayShort"

ExtractZips -ParentFolder $ParentFolder 