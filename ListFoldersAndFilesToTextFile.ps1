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
    $path = 'C:\GitHub\dtp'
		
    $OutFile = $path + '\Resources.txt'
    $OutFileShort = $path + 'Resources.txt'
   # $OutFileShort = "'" + $OutFileShort + "'"
    $i = 0  
    $j = 0  
    Write-Host -ForegroundColor Yellow "OutFile:" $OutFile

    "LastWriteTime | FullFileName | ParentFolder | Notes | FileCount | ItemType | FileName | Extension | FullPath | SizeKB | SizeMB | SizeGB" > $OutFile
    "LastWriteTime | FullFileName | ParentFolder | Notes | FileCount | ItemType | FileName | Extension | FullPath | SizeKB | SizeMB | SizeGB" > $OutFileShort

    # Loop through all directories 
    $dirs = Get-ChildItem -Path $path -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 

    #get # of folders and files:
    $FolderCount = (Get-ChildItem -Path $path -Recurse -Directory | Measure-Object).Count
    $FileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count
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
            
        }#else
             
        $LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $Notes  + " | " + $FileCount + " | " + $ItemType + " | " + "$FileName" + " | " + $Extension + " | " + $FullPath + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB >> $OutFile
        $LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $Notes  + " | "  + "$FileName" + " | " + $Extension  + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB >> $OutFileShort
                   
    $i++
  } #Foreach ($dir In $dirs)
} # Function renameFiles  
# RUN SCRIPT 
GetFiles  

