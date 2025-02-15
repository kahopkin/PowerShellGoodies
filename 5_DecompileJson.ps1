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
    Write-Host -ForegroundColor Cyan "`$JSONFolder=`"$JSONFolder" 

   if (Test-Path $JSONFolder) 
    {
        #Write-Host -ForegroundColor Cyan "EXISTING $JSONFolder JSONFolder" 
        $ParentFolderPath = (Get-ItemProperty  $JSONFolder | select FullName).FullName
        Write-Host -ForegroundColor Green "`$ParentFolderPath=`"$ParentFolderPath"

        #Write-Host -ForegroundColor Green "$ParentFolder FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object 
        #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        
        Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
        Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
        
        $todayShort = Get-Date -Format 'MM/dd/yyyy'
        #Write-Host -ForegroundColor Cyan "todayShort: $todayShort "

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
            $CreationTime = $dir.CreationTime
            $CreationTime = $CreationTime.ToString("MM/dd/yyyy HH:mm:ss")
            $CreationTime = $CreationTime.Split(" ")[0]
            #debugline:
            #$FullFileName +" - "+$LastWriteTime

            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name            
            Write-Host -ForegroundColor Yellow "`n[62] `$FullPath=`"$FullPath`""
            Write-Host -ForegroundColor Yellow "``$FullFileName=`"$FullFileName`""
            Write-Host -ForegroundColor Yellow "``$FileName=`"$FileName`""            
            Write-Host -ForegroundColor Yellow "`$DirectoryPath=`"$DirectoryPath`""                                                
            Write-Host -ForegroundColor Cyan "`$ParentFolder=`"$ParentFolder`""           
            Write-Host -ForegroundColor Cyan "`$ParentFullPath=`"$ParentFullPath`""
            
            if($isDir -eq $false -and $FileName -NotMatch "_Parameters" -and $Extension -ne '.zip' -and $Extension -eq '.json' )
            #-and $ParentFullPath -ne "C:\GitHub\dtpResources\$todayShort\Deploy")
            {
                    #Write-Host -ForegroundColor White "`n[79] FullFileName: $FullFileName "
                    #Write-Host -ForegroundColor White "[80] Extension: $Extension "

                    $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                    $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                    #$ParentFullPath = $ParentFullPath +"\Bicep"

                    Write-Host -ForegroundColor Yellow "`n[82][$i] FullFileName: $FullFileName "                
                    Write-Host -ForegroundColor Yellow "[83][$i] FullPath: $FullPath "
                    #Write-Host -ForegroundColor Yellow "[84][$i] DirectoryPath: $DirectoryPath "
                                                
                    #Write-Host -ForegroundColor Cyan "[86][$i] ParentFolder: $JSONFolder "                
                    #Write-Host -ForegroundColor Cyan "[87][$i] ParentFullPath: $ParentFullPath "
                    if($CreationTime -eq $todayShort)
                    {
                        bicep decompile --force $FullPath 
                    }
                    else
                    {
                        bicep decompile $FullPath 
                    }
                    
                  
                    $NewName = $DirectoryPath + "\"+ $FileName + ".bicep"
                    Write-Host -ForegroundColor Green "[96] Decompiled " $FileName ": " $NewName
                    
                    #Write-Host -ForegroundColor Green "[92] NewName = $NewName"
                    #Move-Item -Path $NewName -Destination $ParentFullPath -Force
              
            }#if FileName Notmatch   
          
            $ItemType = "File"
          
            $i++
        } #Foreach ($dir In $dirs)
    }
    else
    {
        $TodayFolder = New-Item -ItemType Directory -Name $todayShort   
        $ParentFolderPath = (Get-ItemProperty  $JSONFolder | select FullName).FullName
        #Write-Host -ForegroundColor Yellow "$ParentFolder ParentFolder" 
    }  
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED DecompileJson FOR $ParentDirPath *****************"
}#DecompileJson

$RootFolder = "C:\GitHub\dtpResources"

$todayShort = Get-Date -Format 'MM-dd-yyyy'
$month = Get-Date -Format 'MM'

$ParentFolder = "$RootFolder\$month"
$ParentFolder = 'C:\GitHub\dtpResources\jaifairfax\rg-dts-prod-lt'
#$ParentFolder = 'C:\GitHub\dtpResources\jaifairfax\rg-dts-prod-ht'

$ParentFolderPath = (Get-Item $ParentFolder).FullName
Write-Host "ParentFolderPath:" $ParentFolderPath

$JSONFolder = "$ParentFolderPath\$todayShort"

$ParentFolder = 'C:\GitHub\dtpResources\jaifairfax\rg-dts-prod-lt'
#$ParentFolder = 'C:\GitHub\dtpResources\jaifairfax\rg-dts-prod-ht'
$JSONFolder = "$RootFolder\jaifairfax\rg-dts-prod-lt"
#$JSONFolder = "$RootFolder\jaifairfax\rg-dts-prod-ht"

Write-Host -ForegroundColor Yellow "JSONFolder:" $JSONFolder
#$ParentFolder = $todayShort
#$ParentFolder = "$RootFolder\$month\$todayShort"
#$DestinationFolder = "C:\GitHub\dtpResources\06-23-2022\Bicep" 

#$BicepFolder = "$ParentFolderPath\$todayShort\Bicep"
#$JSONFolder = "C:\GitHub\dtpResources\$todayShort\JSON"
#$JSONFolder = "C:\GitHub\dtpResources"
#DecompileJson -JSONFolder $JSONFolder 
$ParentFolder = 'C:\GitHub\dtpResources\AZ-Exports'
$ParentFolder = 'C:\GitHub\dtpResources\AZ-Exports'
#$ParentFolder = 'C:\GitHub\dtpResources\AZ-Exports\jaifairfax\rg-dts-prod-lt'
#$JSONFolder = 'C:\GitHub\azure-quickstart-templates\quickstarts'
#$JSONFolder = 'C:\GitHub\dtpResources\jaifairfax\rg-dts-prod-ht\FunctionApp'
#DecompileJson -JSONFolder $JSONFolder 
DecompileJson -JSONFolder $ParentFolder