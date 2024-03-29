﻿
$currDir= Get-Item (Get-Location)
$currDirHash = [ordered]@{
    FullPath =  $currDir.FullName;
    FileName = $currDir.BaseName;        
    ParentFolder = Split-Path (Split-Path $currDir.FullName -Parent) -Leaf;
    ParentFolderPath=(Get-ItemProperty  (Split-Path $currDir.FullName -Parent) | select FullName).FullName;            
    FullFileName = Split-Path $currDir.FullName -Leaf -Resolve;
 }
 $currDirHash = [ordered]@{
    FullPath =  $currDir.FullName;
    FileName = $currDir.BaseName;        
    ParentFolder = Split-Path (Split-Path $currDir.FullName -Parent) -Leaf;
    ParentFolderPath=(Get-ItemProperty  (Split-Path $currDir.FullName -Parent) | select FullName).FullName;            
    FullFileName = Split-Path $currDir.FullName -Leaf -Resolve;
 }

If($currDir.FullName.Contains("dtp\Deploy"))
{
    $Caller='[]'       
    #PrintObject -object $AppRegObj -Caller $Caller
    PrintHashTable -object $currDirHash -Caller $Caller

}
Else{
    Write-Host -ForegroundColor White "InitiateDeploymentProcess[46] Logs DOES NOT EXISTS"
}

$ParentFolder ="../logs"

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
                    Write-Host -ForegroundColor Blue -BackgroundColor White  "`n[$i] DIRECTORY FullFileName: $FullFileName "                
                    #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] DIRECTORY FullPath: $FullPath "
                    #Remove-Item -Path $FullPath
                }

            }
            else
            {  
                Write-Host -ForegroundColor Cyan  "`n`t i=[$i]"
                Write-Host -ForegroundColor Yellow  "`[77] FileName: $FileName "
                Write-Host -ForegroundColor Yellow  "`[78] FullFileName: $FullFileName "
                Write-Host -ForegroundColor Yellow "[79] FILE: $FullPath"
                
                #Write-Host $dir.DirectoryName
                $ParentPath = $dir.DirectoryName
                #$ParentFullPath = ((Get-Item($ParentPath)).Parent).FullName
                Write-Host "[80] ParentPath: $ParentPath "
                Write-Host "[81] ParentFolder: $ParentFolder "
                $NewName = $ParentFolder+$Extension
                $NewFilePath=$ParentPath+"\"+$NewName
                Write-Host -ForegroundColor Green "NewFilePath= " $NewFilePath

                if($FileName -eq "template")
                {   
                <#             
                    Write-Host -ForegroundColor Yellow "`n[$i] template FullFileName: $FullFileName "                
                    Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "
                    Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                                                
                    Write-Host -ForegroundColor Cyan "[$i] ParentFolder: $ParentFolder "                
                    Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                    #>
                    
                    if ( (Test-Path $NewFilePath) -ne $true )
                    {
                        Write-Host -ForegroundColor Cyan -BackgroundColor Black  "Renaming $FullFileName to $NewName"
                        Rename-Item -Path "$FullPath" -NewName $NewName
                        $ParentFullPath = $ParentFullPath + "\JSON"                
                
                        $FullPath = $DirectoryPath + "\"+ $NewName
                    }
                    #Write-Host -ForegroundColor DarkCyan -BackgroundColor White  "[102]Moving file $FullPath to: NewPath: $ParentFullPath"
                    #Move-Item -Path $FullPath -Destination $ParentFullPath
                }
                elseif( $FileName -eq "parameters")
                {
                    Write-Host -ForegroundColor White "`[107] template FullFileName: $FullFileName "                
                    Write-Host -ForegroundColor White "[108] FullPath: $FullPath "
                    Write-Host -ForegroundColor White "[109] DirectoryPath: $DirectoryPath "
                                                
                    Write-Host -ForegroundColor DarkYellow "[111] ParentFolder: $ParentFolder "                
                    Write-Host -ForegroundColor DarkYellow "[112] ParentFullPath: $ParentFullPath "

                    $NewName = "_Parameters_" + $ParentFolder +  $Extension
                    if ( (Test-Path $NewFilePath) -ne $true )
                    {
                        Write-Host -ForegroundColor DarkRed -BackgroundColor White "[115] Renaming $FullFileName to $NewName"
                        Rename-Item -Path "$FullPath" -NewName $NewName
                        $ParentFullPath = $ParentFullPath + "\JSON"                
                
                        $FullPath = $DirectoryPath + "\"+ $NewName
                    }
                    #Write-Host -ForegroundColor DarkCyan -BackgroundColor White  "[120] Moving file $FullPath to: NewPath: $ParentFullPath"
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
else
{
    
    $currDir= Get-Item (Get-Location)
    $currDirHash = [ordered]@{
    FullPath =  $currDir.FullName;
    FileName = $currDir.BaseName;        
    ParentFolder = Split-Path (Split-Path $currDir.FullName -Parent) -Leaf;
    ParentFolderPath=(Get-ItemProperty  (Split-Path $currDir.FullName -Parent) | select FullName).FullName;            
    FullFileName = Split-Path $currDir.FullName -Leaf -Resolve;
    }

    
    $ParentFolderPath= ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    $LogsFolder = Get-ChildItem -Path $ParentFolderPath | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and $_.FullName.Contains("dtp\Deploy\logs")}
    
    
   $LogsFolder = Get-ChildItem -Path ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | `
                select FullName).FullName) | Sort-Object `
                | Where-Object { ($_.PSIsContainer -eq $true) -and `
                $_.FullName.Contains("dtp\Deploy\logs")}

Write-Host -ForegroundColor Green "LogsFolder=" $LogsFolder.FullName
Write-Host -ForegroundColor Green  ($LogsFolder -eq $null)
    $Caller='InitiateDeploymentProcess[39]'       
    #PrintObject -object $AppRegObj -Caller $Caller
    PrintHashTable -object $currDirHash -Caller $Caller

    $logFolder = Get-ChildItem -Path ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName) -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and $_.FullName.Contains("dtp\Deploy\logs")}
    Get-ChildItem -Path ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName) -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and $_.FullName.Contains("dtp\Deploy\logs")}  | Sort-Object -Property FullName | select FullName
    
    
    Get-ChildItem -Path $currDirHash.ParentFolderPath -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and $_.FullName.Contains("dtp\Deploy\logs")}  | Sort-Object -Property FullName

    Get-ChildItem -Path $currDirHash.ParentFolderPath -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and $_.BaseName -eq "logs"} | select FullName | Sort-Object 
    Get-ChildItem -Path $currDirHash.ParentFolderPath -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and ($_.FullName -contains "dtp\Deploy\logs")} | select FullName | Sort-Object 
    
    Get-ChildItem -Path $currDirHash.ParentFolderPath -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) } | select FullName | Sort-Object -Property FullName
    
    #gets all folders from the parentfolderpath:
    Get-ChildItem -Path $currDirHash.ParentFolderPath -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) } | select FullName,BaseName, Parent | Sort-Object 
    Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true -and $_.FullName -contains "dtp\Deploy\logs") } | select FullName | Sort-Object 

    Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object | Where-Object {$_.PSIsContainer -eq $true -and $_.FullName -contains "dtp\Deploy\logs" } | select FullName | Sort-Object 
    Get-ChildItem -Path ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName) -Recurse | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and $_.FullName.Contains("dtp\Deploy\logs")}  | Sort-Object -Property FullName

    #Get-ChildItem -Name $currDir.FullName | Where-Object { $_.FullName -eq "logs" }
    #$TodayFolder = New-Item -ItemType Directory -Name $todayShort   
    #$ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
    #Write-Host -ForegroundColor Yellow "ParentFolderPath= $ParentFolderPath" 
    
    $LogsFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
$LogsFolder = Get-ChildItem -Path  $LogsFolderParentPath | Where-Object { `
                    ($_.PSIsContainer -eq $true) -and `
                    $_.FullName.Contains($DeployPath)}

<#$LogsFolder = Get-ChildItem -Path ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | `
                select FullName).FullName) | Sort-Object `
                | Where-Object { ($_.PSIsContainer -eq $true) -and `
                $_.FullName.Contains("dtp\Deploy\logs")}
#>

Write-Host -ForegroundColor Green "LogsFolder.Length=" $LogsFolder.FullName.Length
Write-Host -ForegroundColor Green  ($LogsFolder -eq $null)

#$ParentFolderPath= ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)

#$LogsFolder = Get-ChildItem -Path $ParentFolderPath | Sort-Object | Where-Object { ($_.PSIsContainer -eq $true) -and $_.FullName.Contains("dtp\Deploy\logs")}





}  
#>



    <#$LogsFolder = Get-ChildItem -Path ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | `
                    select FullName).FullName) | Sort-Object `
                    | Where-Object { ($_.PSIsContainer -eq $true) -and `
                    $_.FullName.Contains("dtp\Deploy\logs")}
    #>
    #Write-Host -ForegroundColor Green "[69]LogsFolder.Length=" $LogsFolder.FullName.Length
    #Write-Host -ForegroundColor Green  "[70]" ($LogsFolder -eq $null)


