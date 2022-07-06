#Decompile
<#

$todayShort = Get-Date -Format 'MM-dd-yyyy'

$ParentFolder = $todayShort + "\Zips" 

$ParentFolder = $todayShort

ExtractZips -ParentFolder $ParentFolder 
#>


Function global:Decompile
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder    
    )
      $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START Decompile FOR $ParentDirPath *****************"
    
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

            if($isDir)
           {
                Write-Host -ForegroundColor Green "[$i] FOLDER: $FullPath "
            }
           else
           {
            if($Extension -eq ".json" -and (! $FileName.Contains('Parameters') ))
            {
                
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                    
                Write-Host -ForegroundColor Yellow "`n[$i] FileName: $FileName "                
                Write-Host -ForegroundColor Yellow "[$i] FullFileName: $FullFileName "                
                Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "
                Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor Cyan "[$i] ParentFolder: $ParentFolder "                
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                #Write-Host "[$i] FullPath: $FullPath "                      

                #Expand-Archive -LiteralPath $FullPath -DestinationPath $ParentFullPath -Force
                #Expand-Archive -LiteralPath $FullPath -DestinationPath $DirectoryPath -Force
                bicep decompile $FullPath 

               # $BicepFolder = "C:\GitHub\dtpResources\$todayShort\Bicep"
                #$NewPath = $ParentFullPath + "\Zips"
                #Write-Host -ForegroundColor Green "`nMoving $FullFileName to: $NewPath "
                #Write-Host -ForegroundColor Green "`nMoving $FullFileName to: $BicepFolder "
                #Move-Item -Path $FullPath -Destination $BicepFolder -Force                       
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
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED Decompile FOR $ParentDirPath *****************"
}#ExtractZips

$todayShort = Get-Date -Format 'MM-dd-yyyy'
#$ParentFolder = $todayShort + "\Zips" 
#$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'
$todayShort="07-03-2022"
$ParentFolder = "C:\GitHub\dtpResources\$todayShort\JSON"
$ParentFolder = "C:\GitHub\dtpResources\$todayShort"
#$ParentFolder = "C:\GitHub\dtpResources\allFunctionRes"

$ParentFolder = "C:\GitHub\dtpResources\06-29-2022-Copy"
$ParentFolder = "C:\GitHub\dtpResources\07-03-2022 - Copy"
Decompile -ParentFolder $ParentFolder 