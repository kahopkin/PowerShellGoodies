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

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START RenameFiles FOR $ParentFolder *****************"
    
    #$todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder = Get-Date -Format 'MM-dd-yyyy'
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "[17] EXISTING **** $ParentFolder *** ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Cyan "[20] ParentFolder: $ParentFolder"
        Write-Host -ForegroundColor Cyan "[21] FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Green "`nFolderCount: $FolderCount "      
        Write-Host -ForegroundColor Green "FileCount: $FileCount `n"
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
            
           
           if($isDir)
           {
                #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[$i] DIRECTORY FullFileName: $FullFileName "                
                #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] DIRECTORY FullPath: $FullPath "
                $FileCount = (Get-ChildItem -Path $FullPath -Recurse -File | Measure-Object).Count
                #Write-Host -ForegroundColor Yellow "[$i] FileCount=$FileCount"
                if( $FileCount -eq 0)
                {
                    Write-Host -ForegroundColor White -BackgroundColor Black  "`n[$i] DIRECTORY FullFileName: $FullFileName "                
                    #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] DIRECTORY FullPath: $FullPath "
                    #Remove-Item -Path $FullPath
                }

           }
           else{  
            
            
            Write-Host -ForegroundColor Yellow "`n[$i]  FILE: FileName: $FileName"
            Write-Host  "[$i] FullFileName: $FullFileName "
            #Write-Host "[$i] ParentFolder: $ParentFolder "
            Write-Host "[$i] FullPath: $FullPath "
            

            $ParentPath = (Get-Item($dir.DirectoryName)).Parent
            $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName

            if($FileName -eq "template")
            {   
            <#             
                Write-Host -ForegroundColor Yellow "`n[$i] template FullFileName: $FullFileName "                
                Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "
                Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor Cyan "[$i] ParentFolder: $ParentFolder "                
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                #>
                $NewName = $ParentFolder+$Extension
                Write-Host -ForegroundColor Red -BackgroundColor White  "Renaming $FullFileName to $NewName"
                Rename-Item -Path "$FullPath" -NewName $NewName
                $ParentFullPath = $ParentFullPath + "\JSON"                
                
                $FullPath = $DirectoryPath + "\"+ $NewName
                Write-Host -ForegroundColor DarkCyan -BackgroundColor White  "[68]Moving file $FullPath to: NewPath: $ParentFullPath"
                #Move-Item -Path $FullPath -Destination $ParentFullPath
            }
            elseif( $FileName -eq "parameters")
            {
                Write-Host -ForegroundColor White "`n[$i] template FullFileName: $FullFileName "                
                Write-Host -ForegroundColor White "[$i] FullPath: $FullPath "
                Write-Host -ForegroundColor White "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor DarkYellow "[$i] ParentFolder: $ParentFolder "                
                Write-Host -ForegroundColor DarkYellow "[$i] ParentFullPath: $ParentFullPath "

                $NewName = "_Parameters_" + $ParentFolder +  $Extension
                Write-Host -ForegroundColor DarkRed -BackgroundColor White "[$i] Renaming $FullFileName to $NewName"
                Rename-Item -Path "$FullPath" -NewName $NewName 
                $ParentFullPath = $ParentFullPath + "\JSON"                
                
                $FullPath = $DirectoryPath + "\"+ $NewName
                Write-Host -ForegroundColor DarkCyan -BackgroundColor White  "[68]Moving file $FullPath to: NewPath: $ParentFullPath"
                #Move-Item -Path $FullPath -Destination $ParentFullPath
            }# elseif( $FileName -eq "template")
            
            #if($Extension -eq ".zip")
            #{#
            
             #   Write-Host -ForegroundColor Yellow "`n[$i] zip FullFileName: $FullFileName "                
            <#    Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "
                Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor Cyan "[$i] ParentFolder: $ParentFolder "                
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                $ParentFullPath = $ParentFullPath + "\Zips"
                Write-Host -ForegroundColor DarkCyan "[68]Moving file to: NewPath: $ParentFullPath"
                #Move-Item -Path $FullPath -Destination $ParentFullPath               
                #>
            #}
          
            <#
            else{
            
               # Write-Host -ForegroundColor Green "`n[$i] OTHER FullFileName: $FullFileName "                
                Write-Host -ForegroundColor Green "[$i] FullPath: $FullPath "
                Write-Host -ForegroundColor Green "[$i] DirectoryPath: $DirectoryPath "
                                                
                Write-Host -ForegroundColor Cyan "[$i] ParentFolder: $ParentFolder "                
                Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
              
            }
              #>
           <# 
            if($FileName -eq "parameters")
            {
                Write-Host -ForegroundColor Red "Deleting: $FullPath"
                #Remove-Item $FullPath
            }
            #>
                $ItemType = "File"
            #$FileCount = 0
            #debugline:
            #"File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime           
           }
        $i++
        } #Foreach ($dir In $dirs)
    }
    <#else
    {
        $TodayFolder = New-Item -ItemType Directory -Name $todayShort   
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "$ParentFolder ParentFolder" 
    }  
    #>
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED RenameFiles FOR $ParentFolder *****************"
}#RenameFiles



#$OutFile= '..\logs\' +  $todayLong + '-' + $ParentDirPath + '-Deployment.txt'
$todayShort = Get-Date -Format 'MM-dd-yyyy'

#$ParentFolder = 'C:\GitHub\dtpResources\'
#$ParentFolder = $todayShort
$todayShort = "07-03-2022"
$ParentFolder = "C:\GitHub\dtpResources\$todayShort"

RenameFiles -ParentFolder $ParentFolder

