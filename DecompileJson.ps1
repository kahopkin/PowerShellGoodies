﻿#DecompileJson
<#

$todayShort = Get-Date -Format 'MM-dd-yyyy'

$JSONFolder = $todayShort + "\Zips" 

$JSONFolder = $todayShort

ExtractZips -JSONFolder $JSONFolder 
#>


Function global:DecompileJson
{
    Param(
      [Parameter(Mandatory = $true)] [String]$JSONFolder    
    )
    
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START DecompileJson FOR $JSONFolder *****************"
    
   if (Test-Path $JSONFolder) 
    {
        #Write-Host -ForegroundColor Cyan "EXISTING $JSONFolder JSONFolder" 
        $ParentFolderPath = (Get-ItemProperty  $JSONFolder | select FullName).FullName

        #Write-Host -ForegroundColor Green "$ParentFolder FullPath:"  $ParentFolderPath

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
            $JSONFolder = Split-Path (Split-Path $dir.FullName -Parent) -Leaf
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
            
            Write-Host -ForegroundColor White "`n[57] FileName: $FileName "                
            
            if($FileName -NotMatch "-Parameters")
            {
                
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                
                Write-Host -ForegroundColor Yellow "`n[$i] FullFileName: $FullFileName "                
                Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "
                Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor Cyan "[$i] ParentFolder: $JSONFolder "                
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "

                bicep decompile $FullPath

              
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
        $ParentFolderPath = (Get-ItemProperty  $JSONFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "$ParentFolder ParentFolder" 
    }  
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED DecompileJson FOR $ParentDirPath *****************"
}#DecompileJson
$todayShort = Get-Date -Format 'MM-dd-yyyy'

$JSONFolder = "C:\GitHub\dtpResources\$todayShort"
#$ParentFolder = $todayShort

#$DestinationFolder = "C:\GitHub\dtpResources\06-23-2022\Bicep" 

$BicepFolder = "C:\GitHub\dtpResources\$todayShort\Bicep"
$JSONFolder = "C:\GitHub\dtpResources\$todayShort\JSON"

DecompileJson -JSONFolder $JSONFolder 