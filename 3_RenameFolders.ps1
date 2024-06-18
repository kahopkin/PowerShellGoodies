#RenameFiles
<#
$todayShort = Get-Date -Format 'MM-dd-yyyy'

$ParentFolder = '..\dtpResources\'
$ParentFolder = $todayShort

RenameFiles -ParentFolder $ParentFolder
#>

Function global:RenameFiles
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder    
    )

    $debugFlag = $true
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START RenameFiles FOR $ParentFolder *****************"
    
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "[17] EXISTING **** $ParentFolder *** ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Cyan "[20] ParentFolder: $ParentFolder"
        Write-Host -ForegroundColor Cyan "[21] FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object | Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Green "`nFolderCount: $FolderCount "      
        Write-Host -ForegroundColor Green "FileCount: $FileCount `n"
        $i = 0  
        $j = 0  
    
        Foreach ($dir In $dirs) 
        {  
            $FullPath =  $dir.FullName
            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name 
            $Size = $subFolder.sum             
           
            if($isDir)
            {
                
                $FileName = $dir.BaseName        
                $ParentFolder = Split-Path (Split-Path $dir.FullName -Parent) -Leaf
                $DirectoryPath = $dir.DirectoryName
                $Extension = $dir.Extension       
                $LastWriteTime = $dir.LastWriteTime
                $LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
                #$FullFileName = Split-Path $dir.FullName -Leaf -Resolve

                $DirName = $FileName
                #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[$i] DIRECTORY DirName: $DirName "
                
                #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] DIRECTORY FullPath: $FullPath "
                $FileCount = (Get-ChildItem -Path $FullPath -Recurse -File | Measure-Object).Count
                #Write-Host -ForegroundColor Yellow "[$i] FileCount=$FileCount"
                if( $FileCount -eq 0)
                {
                    Write-Host -ForegroundColor Blue -BackgroundColor White  "`n[$i] DIRECTORY FullFileName: $FullFileName "                
                    #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] DIRECTORY FullPath: $FullPath "
                    #Remove-Item -Path $FullPath
                }#if( $FileCount -eq 0)

                if($DirName.length -eq 4 -and $DirName -match "^[\d\.]+$")
                {
                    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[$i] DIRECTORY DirName: $DirName "
                    $NewName = "Turbotax " + $DirName
                    $NewFilePath = $ParentFolderPath+"\"+$NewName
                    #Write-Host -ForegroundColor Green "[88] NewFilePath= " $NewFilePath
                    
                    Write-Host -ForegroundColor Yellow "`$ParentFolderPath=`"$ParentFolderPath`""
                    Write-Host -ForegroundColor Cyan "`$NewName=`"$NewName`""
                    

                    if (Test-Path $NewFilePath)
                    {
                        $Source = $FullPath
                        $Destination = $NewFilePath

                        Write-Host -ForegroundColor Yellow "EXISTING `$NewFilePath=`"$NewFilePath`""
                        <#
                        To copy all files and subdirectories 
                        from the "Source" folder 
                        to the "Destination" folder 
                        retaining the file and folder
                        data, 
                        attributes, 
                        and timestamps 
                        with 16 multi-threaded copy operation
                        robocopy C:\Users\Admin\Records D:\Backup /S /DCOPY:DAT /MT:16 /LOG:C:\Logs\Backup.log
                        #>
                        $psCommand =  "`n robocopy """ + 
                                    $Source + "`" """ + 
                                    $Destination + """ " +
                                    "/S /E /ETA /DCOPY:DAT  /MT:16 """ 

                        #
                        If($debugFlag){
                            # Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
                            Write-Host -ForegroundColor Cyan $psCommand
                        }#If($debugFlag) #> 

                        robocopy  $Source $Destination /S /E /ETA /DCOPY:DAT  /MT:16

                        Write-Host -ForegroundColor Red "Removing source folder and its files: "
                        Write-Host -ForegroundColor Cyan "`$Source=`"$Source`""
                        Remove-Item -Path $FullPath -Recurse

                    }#if (Test-Path $NewFilePath)
                    else
                    {
                        Write-Host -ForegroundColor Cyan -BackgroundColor Black  "Renaming $FullPath to $NewName"
                        Rename-Item -Path "$FullPath" -NewName $NewFilePath
                    }
                    
                }#if($DirName.length -eq 4)

            }#if($isDir)
        $i++
        }#Foreach ($dir In $dirs)
    }
    
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED RenameFiles FOR $ParentFolder *****************"
}#RenameFiles


$RootFolder = "C:\GitHub"
#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$month = Get-Date -Format 'MM'

$ParentFolder = "$RootFolder\$month\$todayShort"
$ParentFolder = "C:\GitHub\TurboTax"

Write-Host "ParentFolderPath:" $ParentFolderPath

RenameFiles -ParentFolder $ParentFolder

#$Value -match "^[\d\.]+$"