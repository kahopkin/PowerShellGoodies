#ExtractZips
<#

$todayShort = Get-Date -Format 'MM-dd-yyyy'

$ParentFolder = $todayShort + "\Zips" 

$ParentFolder = $todayShort

ExtractZips -ParentFolder $ParentFolder 
#>


Function global:ExtractZips
{
    Param(
      [Parameter(Mandatory = $true)] [String]$ParentFolder    
    )
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START ExtractZips FOR $ParentFolder *****************"
    
    #$todayShort = Get-Date -Format 'MM-dd-yyyy'
    #$ParentFolder = Get-Date -Format 'MM-dd-yyyy'
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "EXISTING `$ParentFolder=`"$ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Green "ParentFolder FullPath: `$ParentFolderPath=`"$ParentFolderPath"

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
            
            #Write-Host -ForegroundColor White "`n[$i] `$FullPath=`"$FullPath`""

            #debugline:
            #$FullFileName +" - "+$LastWriteTime

            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $dir.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name            

            if($Extension -eq ".zip")
            {
                
                $ParentPath = (Get-Item($dir.DirectoryName)).Parent
                $ParentFullPath = ((Get-Item($dir.DirectoryName)).Parent).FullName
                    
                Write-Host -ForegroundColor Yellow "`n[67][$i] `$FullPath=`"$FullPath`""
                #Write-Host -ForegroundColor Yellow "`n[$i] `$FullFileName=`"$FullFileName`""
                Write-Host -ForegroundColor Yellow "`[69][$i] `$FileName=`"$FileName`""
                #Write-Host -ForegroundColor Yellow "[$i] `$FullPath=`"$FullPath`""                
                Write-Host -ForegroundColor Yellow "[71][$i] `$DirectoryPath=`"$DirectoryPath`""                                                
                Write-Host -ForegroundColor Cyan "[72][$i] `$ParentFolder=`"$ParentFolder`""           
                Write-Host -ForegroundColor Cyan "[73][$i] `$ParentFullPath=`"$ParentFullPath`""
                
                #$NewFolderPath=$DirectoryPath+"\"+$FileName
                $ExtractPath=$DirectoryPath+"\"
                #Write-Host "[77] NewFolderPath=$NewFolderPath"
                #$NewFolderPath = $DirectoryPath + ((Get-ItemProperty  $FullPath | select Name).Name).Split(".")[0]
                $ExtractPath =  $DirectoryPath + "\" + $FileName 
                Write-Host -ForegroundColor Green "[80][$i] ExtractPath=$ExtractPath"
                Write-Host -ForegroundColor Cyan "===================================================================================================="
                <#if ((Test-Path $ExtractPath) -ne $true)
                {
                    $folder = New-Item -ItemType Directory -Path $ExtractPath -Name $FileName 
                    $FullName = $folder.FullName
                    Write-Host -ForegroundColor Magenta "[86][$i] Created NEW FOLDER `$FullName=`"$FullName`"" 
                }
                else
                {
                    Write-Host -ForegroundColor Yellow "[90][$i]EXISTING FOLDER `$FullFileName=`"$FullFileName`""
                }
                #>
               
                #Expand-Archive -LiteralPath $FullPath -DestinationPath $ParentFullPath -Force
                $ParamFile = $ExtractPath + "\" + "parameters.json"
                Write-Host -ForegroundColor Cyan "[96][$i] `$ParamFile=`"$ParamFile`""
                if ( (Test-Path $ParamFile) -ne $true )
                {
                    Expand-Archive -LiteralPath $FullPath -DestinationPath $ExtractPath -Force
                    Write-Host "[98][$i] Expand SUCCESS: NewFolderPath: $ExtractPath "                                       
                }                               
                 
                $TemplateFile = $ExtractPath+"\"+ "template.json"
                Write-Host -ForegroundColor Yellow "[104][$i] `$TemplateFile=`"$TemplateFile`""
                if ( (Test-Path $TemplateFile) -ne $true )
                {
                    Expand-Archive -LiteralPath $FullPath -DestinationPath $ExtractPath -Force
                    Write-Host "[106][$i] Expand SUCCESS: `$ExtractPath=`"$ExtractPath`""                                       
                }

                #$NewPath = $ParentFullPath + "\Zips"
                #Write-Host -ForegroundColor Green "`nMoving $FullFileName to NewPath: $NewPath "
                #Move-Item -Path $FullPath -Destination $NewPath
                #>
            }               
                
                $ItemType = "File"
                #$FileCount = 0
                #debugline:
                #"File: "+ $FileName+"."+ $Extension #+ "-"+$LastWriteTime                    
        $i++
        } #Foreach ($dir In $dirs)
    }
    else
    {
        $TodayFolder = New-Item -ItemType Directory -Name $todayShort   
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
        Write-Host -ForegroundColor Yellow "[122] ParentFolder=$ParentFolder" 
    }  
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED ExtractZips FOR $ParentDirPath *****************"
}#ExtractZips

$RootFolder = "C:\GitHub\dtpResources"
$todayShort = Get-Date -Format 'MM-dd-yyyy'

#$ParentFolder = $RootFolder + "|" + $todayShort + "\Zips" 
#$ParentFolder = 'D:\Users\Kat\GitHub\dtpMess'

$ParentFolder = "$\$todayShort"
$month = Get-Date -Format 'MM'
$ParentFolder = "$RootFolder\$month\$todayShort"
#$ParentFolder = 'C:\GitHub\dtpResources\rg-dts-prod-lt'
$ParentFolder = 'C:\GitHub\dtpResources\bmtn\rg-dtp-prod'
$ParentFolder = 'C:\GitHub\dtpResources\jaifairfax\rg-dts-prod-lt'
$ParentFolder = 'C:\GitHub\dtpResources\jaifairfax\rg-dts-prod-ht'
$ParentFolder = 'C:\dtpResources\AZ-Exports'
#$ParentFolder = 'C:\GitHub\dtpResources\rg-datadrop-prod'
#$ParentFolder = "C:\GitHub\dtpOfflineDeploy"
ExtractZips -ParentFolder $ParentFolder 