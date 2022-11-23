#CopyZipsToNewFolder

<#

$todayShort = Get-Date -Format 'MM-dd-yyyy'

$ParentFolder = $todayShort + "\Zips" 

$ParentFolder = $todayShort

CopyZipsToNewFolder -ParentFolder $ParentFolder 
#>


Function global:CopyZipsToNewFolder
{
    Param(
        [Parameter(Mandatory = $true)] [String] $ParentFolder    
      , [Parameter(Mandatory = $true)] [String] $DestinationFolder
    )
      $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CopyZipsToNewFolder FOR $ParentFolder *****************"
    
    #$todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder = Get-Date -Format 'MM-dd-yyyy'
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan " $ParentFolder ParentFolder EXISTS" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Green "[31] $ParentFolder FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Cyan "`nFolderCount: $FolderCount "      
        Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
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

            if($isDir)
           {
                #Write-Host -ForegroundColor Green "[$i] FOLDER: $FullPath "
            }
           else
           {
            if($Extension -eq ".zip")
            {
                
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                    
                Write-Host -ForegroundColor Yellow "`n[$i] FileName: $FileName "                
                Write-Host -ForegroundColor Yellow "[$i] FullFileName: $FullFileName "                
                Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "
                Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor Cyan "`[$i] ParentFolder: $ParentFolder "    
                Write-Host -ForegroundColor Cyan "[$i] ParentPath: $ParentPath "            
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                #Write-Host "[$i] FullPath: $FullPath "                      

                #Expand-Archive -LiteralPath $FullPath -DestinationPath $ParentFullPath -Force
                #Expand-Archive -LiteralPath $FullPath -DestinationPath $DirectoryPath -Force
                
                $NewPath = $ParentFullPath + "\Zips"
                #Write-Host -ForegroundColor Green "`nMoving $FullFileName to NewPath: $NewPath "
                #Move-Item -Path $FullPath -Destination $NewPath
            }               
                

                $ItemType = "File"
                #$FileCount = 0
                #debugline:
                #"File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime                    
                }
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
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CopyZipsToNewFolder FOR $ParentFolder *****************"
}#ExtractZips

$todayShort = Get-Date -Format 'MM-dd-yyyy'
#$ParentFolder = $todayShort + "\Zips" 
#$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'

$ParentFolder = "C:\GitHub\dtpResources\$todayShort"
$ParentFolder = "C:\GitHub\dtpResources\07-03-2022"

$DestinationFolder = "C:\GitHub\dtpResources\$todayShort"


CopyZipsToNewFolder -ParentFolder $ParentFolder -DestinationFolder $DestinationFolder