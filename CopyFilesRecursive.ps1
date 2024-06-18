#ListFoldersAndFilesToTextFile
#The script will list all folders and files in the given folder ($path). 
#Output format:
#"ItemType | FullFileName | Extension |FileName | ParentFolder | FileCount |  FullPath | Size Kb | Size MB | Size GB | LastWriteTime"
#File 	 Teams.zip 	 zip 	 Teams 	 TeamworkSolutionsDemoAssets 	0	 C:\Users\kahopkin\Documents\ISV Teams Project\Tenants\HR Talent - O365 Enterprise - M365x794031\TeamworkSolutionsDemoAssets\Teams.zip 	 16.86 KB 	 0.02 MB 	 0.00 GB 	05/10/20 11:07

#$path = Folder to query
#$OutFile = Path|name to write
#$OutFileShort = Path|name to write w/ minimum columns



Function GetFiles 
{ 
    $debugFlag = $true
    
    $path = ""
    $Source = $path = ""
    #$path = 'C:\GitHub\_dtpExports\rg-dev-dtp\06-16-2022'
    #$Source = $path = "D:\video"
    #$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Videos\Camera Footage\Garage"	


    #IMPORTANT:
    #ROBOCOPY DO NOT PUT \ AT THE END OF SOURCE OR DESTINATION!
    $Source = $path = ""
    $Source = $path = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\"
    #$path = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA\"	
    #$Source = $path = "C:\Kat\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA"
    
    $Destination = ""
    #$Destination = "C:\Kat\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA"

    $Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost\2024-02-11_KatHopkins-Ghost-PGCase50-23VA"
    $Destination = "F:\Pets"
    

    #$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Videos\Camera Footage\FrontYard"    
    #$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost\To Print"
    
    #$Destination = "C:\Kat\CopyTest"
    
    $OutFile = $path + '\ResourcesLong.txt'
    $OutFileShort = $path + 'ResourcesShort.txt'

    $currYear =  Get-Date -Format 'yyyy'    
    $YearFolderPath = $Destination + "\" + $currYear
    $currMonth =  Get-Date -Format 'MM'
    $MonthFolderPath = $YearFolderPath + "\" +  $currMonth    
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$MonthFolderPath=`"$MonthFolderPath`""
    $todayShort = Get-Date -Format 'MM-dd-yyyy'    
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    $LogFile = $TodayFolderPath = $Destination + "\" + $TodayFolder + ".log"
    #$LogFile = $Destination + "\.log"
    #

    
    Write-host -ForegroundColor Cyan  "`$Source=`"$Source`""    
    Write-host -ForegroundColor Green  "`$Destination=`"$Destination`""    
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$LogFile=`"$LogFile`""


    Write-Host -ForegroundColor Yellow "[" $i + "]"
    Write-Host -ForegroundColor Red "`nCopying files" 
    Write-Host -ForegroundColor White "from Source Folder:`n`$Source=" -NoNewline
    Write-Host -ForegroundColor Green "`"$FullPath`""
    Write-Host -ForegroundColor White "To Destination Folder:`n`$Destination=" -NoNewline
    Write-Host -ForegroundColor Cyan "`"$Destination`""
            #>
            
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
           #
           robocopy  $Source $Destination /S /E /ETA /DCOPY:DAT  /MT:16 /LOG:$LogFile
             
           $psCommand =  "`n robocopy """ + 
                        $Source + "`" """ + 
                        $Destination + """ " +
                        "/S /E /ETA /DCOPY:DAT  /MT:16 /LOG:""" +
                        $LogFile + "`""      

            #
            If($debugFlag){
               # Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
                Write-Host -ForegroundColor Cyan $psCommand
            }#If($debugFlag) #> 



   # $OutFileShort = "'" + $OutFileShort + "'"
    $i = 0  
    $j = 0  
    
    #"LastWriteTime | FullFileName | ParentFolder | Notes | FileCount | ItemType | FileName | Extension | FullPath | SizeKB | SizeMB | SizeGB" > $OutFile
    #"LastWriteTime | FullFileName | ParentFolder | Notes | FileCount | ItemType | FileName | Extension | FullPath | SizeKB | SizeMB | SizeGB" > $OutFileShort

    # Loop through all directories 
    $dirs = Get-ChildItem -Path $path -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 

    #get # of folders and files:
    $FolderCount = (Get-ChildItem -Path $path -Recurse -Directory | Measure-Object).Count
    $FileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count
    "# of folders= "+ $FolderCount
    "# of FileCount= "+ $FileCount

       
      Foreach ($dir In $dirs) 
      { 
        
        $Source = $FullPath =  $dir.FullName
        $FileName = $dir.BaseName        
        $ParentFolder = Split-Path (Split-Path $dir.FullName -Parent) -Leaf
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
            $Extension="Folder"
            $ItemType = "Folder"
            $FileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count
            #debugline:
           # "Folder["+$i+"]"+$FileName + " count: " + $FileCount        
            #
            Write-Host -ForegroundColor Yellow "[" $i + "]"
            Write-Host -ForegroundColor Red "`nCopying files" 
            Write-Host -ForegroundColor White "from Source Folder:`n`$Source=" -NoNewline
            Write-Host -ForegroundColor Green "`"$FullPath`""
            Write-Host -ForegroundColor White "To Destination Folder:`n`$Destination=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$Destination`""
            #>
            
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
           #
           robocopy  $Source $Destination /S /E /ETA /DCOPY:DAT  /MT:16 /LOG:$LogFile
             
           $psCommand =  "`n robocopy """ + 
                        $Source + "`" """ + 
                        $Destination + """ " +
                        "/S /E /ETA /DCOPY:DAT  /MT:16 /LOG:""" +
                        $LogFile + "`""      

            #
            If($debugFlag){
               # Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
                Write-Host -ForegroundColor Cyan $psCommand
            }#If($debugFlag) #> 
        }
        else
        {

            $startIndex = ($dir.Extension.length)-3            
            
            if($Extension.length -gt 0)
            {
               # '[69]Extension: ' + $dir.Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $startIndex = ($dir.Extension.length)-3
                #'Extension: ' + $Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $Extension = $dir.Extension.substring($startIndex,3)
               # $Extension
            }            
            
            $ItemType = "File"
            #$FileCount = 0
            #debugline:
            #"File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime
            <#
            Write-Host -ForegroundColor Yellow "File`n `$FullPath=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$FullPath`""
            #>

            #Copy-Item -Path $FullPath -Destination $Destination      
            <#
            Write-Host -ForegroundColor Yellow "[" $i + "]"
            Write-Host -ForegroundColor Red "`nCopying files" 
            Write-Host -ForegroundColor White "from Source Folder:`n`$Source=" -NoNewline
            Write-Host -ForegroundColor Green "`"$FullPath`""
            Write-Host -ForegroundColor White "To Destination Folder:`n`$Destination=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$Destination`""
            #>
            <#        
                $psCommand =  "`n`$dirs = `n`tGet-ChildItem  ```n`t`t" +
                        "-Path `"" + $path + "`" ```n`t`t" +
                        "-Recurse  | Sort-Object  `n"                          
            #>

           #robocopy $FullPath $Destination /S /copyall /MT:16 /LOG:$LogFile   

           #this only copies the files WITHOUT the enclosing directories!!!
           #robocopy $FullPath $Destination /S /copy:DAT /MT:16 /LOG:$LogFile   

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
           #
            #robocopy  $Source $Destination /S /E /ETA /DCOPY:DAT  /MT:16 /LOG:$LogFile
             
            $psCommand =  "`n robocopy """ + 
                        $Source + "`" """ + 
                        $Destination + """ " +
                        "/S /E /ETA /DCOPY:DAT  /MT:16 /LOG:""" +
                        $LogFile + "`""      
            <#
            If($debugFlag){
               # Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
                Write-Host -ForegroundColor Cyan $psCommand
            }#If($debugFlag) #>             
            
        }#else It is FILE
             
            <#
            Write-Host -ForegroundColor Yellow "[" $i + "]"
            Write-Host -ForegroundColor Red "`nCopying files" 
            Write-Host -ForegroundColor White "from Source Folder:`n`$Source=" -NoNewline
            Write-Host -ForegroundColor Green "`"$FullPath`""
            Write-Host -ForegroundColor White "To Destination Folder:`n`$Destination=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$Destination`""
          
            robocopy  $Source $Destination /S /E /ETA /DCOPY:DAT  /MT:16 /LOG:$LogFile
             
            $psCommand =  "`n robocopy """ + 
                        $Source + "`" """ + 
                        $Destination + """ " +
                        "/S /E /ETA /DCOPY:DAT  /MT:16 /LOG:""" +
                        $LogFile + "`""      
            #
            If($debugFlag){
               # Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
                Write-Host -ForegroundColor Cyan $psCommand
            }#If($debugFlag) #>             
           #robocopy $FullPath $Destination /S /copyall /MT:16 /LOG:$LogFile   

           #this only copies the files WITHOUT the enclosing directories!!!
           #robocopy $FullPath $Destination /S /copy:DAT /MT:16 /LOG:$LogFile   
           #>
        
        
        #$LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $Notes  + " | " + $FileCount + " | " + $ItemType + " | " + "$FileName" + " | " + $Extension + " | " + $FullPath + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB >> $OutFile
        #$LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $Notes  + " | "  + "$FileName" + " | " + $Extension  + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB >> $OutFileShort
                   
    $i++
  } #Foreach ($dir In $dirs)
} # Function renameFiles  
# RUN SCRIPT 
GetFiles  

