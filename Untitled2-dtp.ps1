$RootFolder = "C:\GitHub\dtp"
$DeployFolder = "C:\GitHub\dtpResources\11\11-03-2022\Deploy"
$DestinationPath = $DeployFolder + "deployDTS.Zip"
$CompressList = ConvertTo-Json (Get-ChildItem -Path $DeployFolder | Select FullName).FullName
#C:\GitHub\dtp\Deploy\powershell\CreateOfflineDeployZipPackage.ps1 `
    -DestinationPath $DestinationPath `
    -RootFolder $RootFolder `
    -CompressList $CompressList






| Where-Object { $_.PSIsContainer -eq $false } 
#Get all zip folders in RootFolder
#Get all zip folders in RootFolder
$CompressListJson = ConvertTo-Json `
    (Get-ChildItem -Path $RootFolder | Where-Object { $_.Extension -eq '.zip' } `
    | Select FullName).FullName
$CompressList = $CompressListJson | Out-String | ConvertFrom-Json








    
$RootFolder = "C:\GitHub\dtp"
$DestinationPath = "$RootFolder" + "\deployDTS_Clients.Zip"
$compressList = @(  
    "$RootFolder" + "\build"
    "$RootFolder" + "\Deploy"
    "$RootFolder" + "\Docs" 
    "$RootFolder" + "\Sites"
    "$RootFolder" + "\wiki"
    "$RootFolder" + "\.gitignore"
    "$RootFolder" + "\.gitmodules"
    "$RootFolder" + "\CODEOWNERS"   
    "$RootFolder" + "\README.md"
    "$RootFolder" + "\SECURITY.md"    
)
    
$compressList = @(       
"$RootFolder" + "\Deploy"
"$RootFolder" + "\README.md"
"$RootFolder" + "\SECURITY.md"    
)

$DestinationPath = "C:\GitHub\dtp\deployDTS_Clients.Zip"
    
foreach($item in $compressList.GetEnumerator()) 
{
    Write-Host -ForegroundColor Green -BackgroundColor Black "`n[26]" $item  
    $Path = (Get-ItemProperty  $item | select FullName).FullName
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "[28] Path:" $Path  
    $isDir = (Get-Item $Path) -is [System.IO.DirectoryInfo]
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "[30] isDir:" $isDir  
   
        
    if($isDir)  
    {   
        Write-Host -ForegroundColor Magenta "[$33] Path: $Path "                
        #Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
        if(Test-Path $DestinationPath)
        {
            Write-Host -ForegroundColor Yellow -BackgroundColor Black "[40] zip exists:"
            Get-ChildItem -Path $Path | Compress-Archive -Update  -DestinationPath $DestinationPath
        }
        else
        {
            Write-Host -ForegroundColor Yellow -BackgroundColor Black "[45] zip does not exist:"   
            Get-ChildItem -Path $Path | Compress-Archive -DestinationPath $DestinationPath
        }
        

                
    }
    else
    {
        Write-Host -ForegroundColor Cyan "[$i] FILE Path: $Path "                
        if(Test-Path $DestinationPath)
        {
            Write-Host -ForegroundColor Yellow -BackgroundColor Black "[57] zip exists:"
            Get-ChildItem -Path $Path | Compress-Archive -Update  -DestinationPath $DestinationPath
        }
        else
        {
            Write-Host -ForegroundColor Yellow -BackgroundColor Black "[63] zip does not exist:"   
            Get-ChildItem -Path $Path | Compress-Archive  -DestinationPath $DestinationPath
        }
        #Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
    } 
}







foreach($item in $compressList.GetEnumerator()) 
{
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n[26]" $item  
    $ParentFolder = $item
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "EXISTING : $ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
        
        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
        Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
        $isDir = (Get-Item $ParentFolderPath) -is [System.IO.DirectoryInfo]
        if($isDir)  
        {   
            Write-Host -ForegroundColor Yellow "`n[$i] FOLDER FullFileName: $FullFileName "
            Write-Host -ForegroundColor Yellow "`[$i] FileName: $FileName "
            Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "                
            Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                
        }
        else
        {
            Write-Host -ForegroundColor Cyan "[$i] FILE ParentFolder: $ParentFolder "                
            Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
        }          


        Write-Host -ForegroundColor Green "[32] ParentFolder FullPath:"  $ParentFolderPath
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Magenta "[35] ParentFolder FullPath:"  $ParentFolderPath
    }#if
}#foreach

    $i=0
    foreach($item in $compressList.GetEnumerator()) 
    {         
        Write-Host -ForegroundColor Green -BackgroundColor Black "[26]" $item
        $ParentFolder = $item
        if (Test-Path $ParentFolder) 
        {
            Write-Host -ForegroundColor Cyan "EXISTING $ParentFolder ParentFolder" 
            $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

            Write-Host -ForegroundColor Green "[33] ParentFolder FullPath:"  $ParentFolderPath

            $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
            $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
            $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
            #Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
            #Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
            $i = 0  
            $j = 0  
            Foreach ($dir In $dirs) 
            { 
                $FullPath =  $dir.FullName
                $FileName = $dir.BaseName        
                $ParentFolder = Split-Path (Split-Path $dir.FullName -Parent) -Leaf
                $DirectoryPath = $dir.DirectoryName
                $FullFileName = Split-Path $dir.FullName -Leaf -Resolve
                $Extension = $dir.Extension
                #'Extension: ' + $Extension
                $LastWriteTime = $dir.LastWriteTime
                $LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
                $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
                $subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                if($isDir)  
                {   
                    Write-Host -ForegroundColor Yellow "`n[$i] FOLDER FullFileName: $FullFileName "
                    Write-Host -ForegroundColor Yellow "`[$i] FileName: $FileName "
                    Write-Host -ForegroundColor Yellow "[$i] FullPath: $FullPath "                
                    Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
                
                }
                else
                {
                    Write-Host -ForegroundColor Cyan "[$i] FILE ParentFolder: $ParentFolder "                
                    Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
                }                                                
                
            
            }#foreach


        }
        $i++       
    }#foreach