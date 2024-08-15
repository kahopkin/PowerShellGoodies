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
    Param(
         [Parameter(Mandatory = $true)] [String]$Source
        ,[Parameter(Mandatory = $true)] [String]$Destination
        
    )

    $debugFlag = $true    
    $path = $Source
    $OutFile = $Destination + '\ResourcesLong.txt'
    $OutFileShort = $Destination + 'ResourcesShort.txt'   	
    
    # Loop through all directories 
    $dirs = Get-ChildItem -Path $path -Recurse | Sort-Object | Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object  
    
    #$dirs = Get-ChildItem -Path $path | Where-Object { $_.PSIsContainer -eq $true } | Sort-Object  

    #$dirs = Get-ChildItem -Path $path -Recurse | Where-Object {$_.DirectoryName -notin $excludeMatch} | Sort-Object 
    

    #$psCommand =  "`nGet-AzResource  ```n`t`t" + 
    $psCommand =  "`n`$dirs = `n`tGet-ChildItem  ```n`t`t" +     
                          "-Path `"" + $path + "`" ```n`t`t" +
                          "-Recurse  | Sort-Object " + 
                          "```n`t`t" + " | " + 
                          "Where-Object{ " + "`$_.PSIsContainer -eq `$true }" + "`n`t`t" 
    #
    If($debugFlag){
        Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[41]:"         
        Write-Host -ForegroundColor Green $psCommand
    }#If($debugFlag) #> 

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
        
        #
        Write-Host -ForegroundColor White "`$FullPath=" -NoNewline
        Write-Host -ForegroundColor Cyan "`"$FullPath`""
        #>
        $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]

        $path = $dir.FullName
        $subFolder = Get-ChildItem -Path $path -Recurse -Force `
                        | Where-Object { $_.PSIsContainer -eq $false } `
                        | Measure-Object -property Length -sum | Select-Object Sum    

        $psCommand =  "`n`$subFolder = `n`tGet-ChildItem  ```n`t`t" +     
                          "-Path `"" + $path + "`" -Recurse -Force ```n`t`t" +                          
                          "| Where-Object { $_.PSIsContainer -eq $false } `n`t`t" +                            
                          "| Measure-Object { $_.PSIsContainer -eq $false } ```n" 
        <#
        If($debugFlag){
            Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
            Write-Host -ForegroundColor Green $psCommand
        }#If($debugFlag) #> 

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
         
            #
            Write-Host -ForegroundColor Yellow "`$FullPath=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$FullPath`""
            #>

            $Extension = $dir.Extension
            $startIndex = ($dir.Extension.length)-3
            Write-Host -ForegroundColor White "`$Extension=" -NoNewline
            Write-Host -ForegroundColor Cyan "`"$Extension`""
            #Copy-Item -Path $FullPath -Destination $ParentFullPath
            #
            if($Extension.length -gt 0)
            {
               # '[69]Extension: ' + $dir.Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $startIndex = ($dir.Extension.length)-3
                #'Extension: ' + $Extension + ' Ext Length: ' + $dir.Extension.length + ', startIndex: ' + $startIndex
                $Extension = $dir.Extension.substring($startIndex,3)
               # $Extension
            }            
            #>
            $ItemType = "File"
            #$FileCount = 0
            #debugline:
            "File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime    
            #Copy-Item -Path $FullPath -Destination $Destination       
            
        }#else
           
        $LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $Notes  + " | " + $FileCount + " | " + $ItemType + " | " + "$FileName" + " | " + $Extension + " | " + $FullPath + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB >> $OutFile
        $LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $FullPath  + " | "  + "$FileName" + " | " + $Extension  + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB >> $OutFileShort

        $lineOut = $LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $Notes  + " | " + $FileCount + " | " + $ItemType + " | " + "$FileName" + " | " + $Extension + " | " + $FullPath + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB 
        $lineOut = $LastWriteTime  + " | " + $FullFileName + " | " + $ParentFolder + " | " + $FullPath  + " | "  + "$FileName" + " | " + $Extension  + " | " + $SizeKB   + " | " + $SizeMB    + " | " + $SizeGB + " | " + $FullFileName >> $OutFileShort
                   
    $i++
  } #Foreach ($dir In $dirs)

  explorer $OutFile

} # Function renameFiles  

# RUN SCRIPT

$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ACAS Excel Exports - Copy\ACAS SCANS"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"


GetFiles -Source $Source -Destination $Destination




<#
$path = $Source= "D:\video"
$Source= "D:\"
$Destination= "C:\Users\kahopkin\OneDrive - Microsoft\Videos\Camera Footage\Garage"
#
    #$OutFile = $path + '\PowershellScripts.txt'
    #$OutFile = "C:\GitHub\dtpResources\FilesLong_Bicep.txt"
    #$OutFile = "C:\GitHub\dtpResources\FilesLong.txt"
    #$OutFile = "C:\GitHub\dtpResources\2023\03\03-01-2023\BicepScripts.txt"
    $OutFile = $path + 'ResourcesLong.txt'
    $OutFileShort = $path + 'Resources.txt'
    #$OutFileShort = "C:\\GitHub\dtpResources\OutFileShort_Bicep.txt"
    #$OutFileShort = "C:\\GitHub\dtpResources\OutFileShort.txt"
    #$OutFileShort = "C:\GitHub\dtpResources\2023\03\03-01-2023\BicepScripts.txt"
   # $OutFileShort = "'" + $OutFileShort + "'"
    $i = 0  
    $j = 0  
    Write-Host -ForegroundColor Yellow "OutFile:" $OutFile
    Write-Host -ForegroundColor Yellow "OutFileShort:" $OutFileShort

    "LastWriteTime | FullFileName | ParentFolder | Notes | FileCount | ItemType | FileName | Extension | FullPath | SizeKB | SizeMB | SizeGB" > $OutFile   
    "LastWriteTime | FullFileName | ParentFolder | FullPath | FileName | Extension | SizeKB | SizeMB | SizeGB" > $OutFileShort
    
    <#
    $exclude = @("*.pdf","*.md", "*.docx")
    $excludeMatch = @("SQL", "TestData", "Migrations","LocalSetUp")
    [regex] $excludeMatchRegEx = ‘(?i)‘ + (($excludeMatch |foreach {[regex]::escape($_)}) –join “|”) + ‘’
    #>
    