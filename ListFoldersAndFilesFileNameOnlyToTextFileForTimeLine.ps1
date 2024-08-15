#ListFoldersAndFilesToTextFile
#The script will list all folders and files in the given folder ($path). 
#Output format:
#"ItemType|FullFileName|Extension |FileName|ParentFolder|FileCount| FullPath|Size Kb|Size MB|Size GB|LastWriteTime"
#File 	 Teams.zip 	 zip 	 Teams 	 TeamworkSolutionsDemoAssets 	0	 C:\Users\kahopkin\Documents\ISV Teams Project\Tenants\HR Talent - O365 Enterprise - M365x794031\TeamworkSolutionsDemoAssets\Teams.zip 	 16.86 KB 	 0.02 MB 	 0.00 GB 	05/10/20 11:07

#$path = Folder to query
#$OutFile = Path|name to write
#$OutFileShort = Path|name to write w/ minimum columns



Function GetFiles 
{ 
    $Source = $path = ""
    $Source = $path = ""
    $path = ""
    $path = ""

    #$path = 'C:\GitHub\_dtpExports\rg-dev-dtp\06-16-2022'
    #$path = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost"	
    $path = $Source= "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA\To Print"
    #$path = $Source= "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA"
    
    
    $Destination = ""
    $Destination = ""
    #$Destination= "C:\Users\kahopkin\OneDrive - Microsoft\Videos\Camera Footage\Garage"	
    $Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA"
    
    #$Destination = "C:\Kat\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA"


    #$OutFile = $Destination + '\ResourcesLong.txt'
    $OutFile = $Destination + '\FileNames.txt'
    $OutFileShort = $Destination + 'ResourcesShort.txt'
    #$OutFileShort = "'" + $OutFileShort + "'"
    $i = 0  
    $j = 0  
    
    #"RegDate|Date|Type|LastWriteTime|FullFileName|ParentFolder|Notes|FileCount|ItemType|FileName|Extension|FullPath|SizeKB|SizeMB|SizeGB" > $OutFile
    #"RegDate|Date|Type|LastWriteTime|FullFileName|ParentFolder|Notes|FileCount|ItemType|FileName|Extension|FullPath|SizeKB|SizeMB|SizeGB" > $OutFileShort


    #"RegDate|Date|Type|FileName|Extension|FullFileName|ParentFolder|FullPath" > $OutFile
    #"RegDate|FullFileName|ParentFolder|FullPath" > $OutFile
    "FullFileName" > $OutFile
    
    #"RegDate|Date|Type|FileName|FullFileName|FileCount|ItemType|FileName|Extension|FullPath|ParentFolder|" > $OutFileShort

    # Loop through all directories 
    $dirs = Get-ChildItem -Path $path -Recurse|Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } #|Sort-Object 

    #get # of folders and files:
    $FolderCount = (Get-ChildItem -Path $path -Recurse -Directory|Measure-Object).Count
    $FileCount = (Get-ChildItem -Path $path -Recurse -File|Measure-Object).Count
    "# of folders= "+ $FolderCount
    "# of FileCount= "+ $FileCount

       
      Foreach ($dir In $dirs) 
      { 
        
        $FullPath =  $dir.FullName
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
        $subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force|Where-Object { $_.PSIsContainer -eq $false } |Measure-Object -property Length -sum|Select-Object Sum    
        # Set default value for addition to file name 
        $Size = $subFolder.sum 
        $SizeKB =  "{0:N2}"-f ($Size / 1KB) + " KB"
        $SizeMB =  "{0:N2}"-f ($Size / 1MB) + " MB"
        $SizeGB =  "{0:N2}"-f ($Size / 1GB) + " GB"
        
        if($isDir)  
        {
            $Extension="Folder"
            $ItemType = "Folder"
            $FileCount = (Get-ChildItem -Path $path -Recurse -File|Measure-Object).Count
            #debugline:
           # "Folder["+$i+"]"+$FileName + " count: " + $FileCount           
        }
        else
        {

            $startIndex = ($dir.Extension.length)-3            
            
            if($Extension.length -eq 3)
            {
               # '[69]Extension: ' + $dir.Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $startIndex = ($dir.Extension.length)-3
                #'Extension: ' + $Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $Extension = $dir.Extension.substring($startIndex,3)
               # $Extension
            }
            if($Extension.length -eq 4)
            {
               # '[69]Extension: ' + $dir.Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $startIndex = ($dir.Extension.length)-4
                #'Extension: ' + $Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $Extension = $dir.Extension.substring($startIndex,4)
               # $Extension
            }            
            
            $ItemType = "File"
            $FileNameWithExtension = $FileName + "." + $Extension
            #$FileCount = 0
            #debugline:
            #"File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime
            <#
            Write-Host -ForegroundColor Yellow "`$FullPath=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$FullPath`""
            #>

            Write-Host -ForegroundColor Green "#####################################"
            Write-Host -ForegroundColor Yellow "`$FileName=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$FileName`""
            
            Write-Host -ForegroundColor Yellow "`$Extension=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$Extension`""

            Write-Host -ForegroundColor Yellow "`$FileNameWithExtension=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$FileNameWithExtension`""
            #>
            
            #Copy-Item -Path $FullPath -Destination $Destination       
            
        }#else
        
       <#
        Write-Host -ForegroundColor Green "#####################################"
        Write-Host -ForegroundColor Yellow "`$FileName=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$FileName`""
            
        Write-Host -ForegroundColor Yellow "`$Extension=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$Extension`""

        Write-Host -ForegroundColor Yellow "`$FileNameWithExtension=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$FileNameWithExtension`""
        #>

        $charCount = $FileName.Length
        Write-Host -ForegroundColor White "FileName `$=charCount" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$charCount`""
        #$charCount
        
        #$Date=LEFT([@[ FullFi$sourleName ]],10)  
        $DateCol = $FileName.Substring(0,10)  
        Write-Host -ForegroundColor White "`$DateCol=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$DateCol`""
        $RegDate = $DateCol.split("-")[1] + "/" + $DateCol.split("-")[2] + "/" + $DateCol.split("-")[0]
        Write-Host -ForegroundColor White "`$RegDate=" -NoNewline
        Write-Host -ForegroundColor Green "`"$RegDate`""

        #MID([@[ FullFileName ]],12,LEN([@[ FullFileName ]])-11)
        $charCount = $FileName.Length -11
        #Write-Host -ForegroundColor White "`$charCount=" -NoNewline
        #Write-Host -ForegroundColor Cyan "`"$charCount`""
        #$charCount

        $ExcelFileName = $FileName.Substring(11, $charCount)
        Write-Host -ForegroundColor White "`$ExcelFileName=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$ExcelFileName`""
        #$ExcelFileName

        #$Name=LEFT([@FileName],LEN([@FileName])-4)
        
        <#
        $charCount = $ExcelFileName.Length - 4
        Write-Host -ForegroundColor White "ExcelFileName `$charCount=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$charCount`""   
        #$charCount
        #>   

        

        $Type = ""
        <#
        Write-Host -ForegroundColor White "`$=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$`""
        Write-Host -ForegroundColor White "`$=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$`""
        #>
        #Reg Date|Date|Type|
        #"RegDate|Date|Type|FileName||Extension|FullFileName|ParentFolder|FullPath" > $OutFile
        
        #$RegDate + "|" + $DateCol + "|" + $Type + "|" + $ExcelFileName  + "|" + $FullFileName + "|" + $ParentFolder + "|" + $FullPath>> $OutFile

        $FullFileName >> $OutFile


        #+ "|" + $FileName + "|" + $Extension + "|" + $FullFileName + "|" + $ParentFolder + "|" + $FullPath  + "|" + $ParentFolder  >> $OutFile
        #$ParentFolder + "|" + $ParentFolder + "|" + $ParentFolder + "|" + $DateCol + "|" + $FullFileName + "|" + $ParentFolder + "|" + $LastWriteTime  + "|" + $FullFileName + "|" + $ParentFolder + "|" + $Notes  + "|"  + "$FileName" + "|" + $Extension  + "|" + $SizeKB   + "|" + $SizeMB    + "|" + $SizeGB >> $OutFileShort
                   
    $i++
  } #Foreach ($dir In $dirs)

  #explorer $Destination

} # Function renameFiles  
# RUN SCRIPT 
GetFiles  

