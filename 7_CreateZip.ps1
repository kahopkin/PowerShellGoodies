#CreateZip
Function global:CreateZip
{
    Param(
       [Parameter(Mandatory = $true)] [String]$DestinationPath    
      ,[Parameter(Mandatory = $true)] [String]$RootFolder 
    )
    
    Write-Host -ForegroundColor Green -BackgroundColor Black "RootFolder: " $RootFolder  
    Write-Host -ForegroundColor Green -BackgroundColor Black "Zip DestinationPath:" $DestinationPath  
    #$DestinationPath = "C:\GitHub\dtp\deployDTS_Clients.Zip"
    #$RootFolder = "C:\GitHub\dtp"

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

    Write-Host -ForegroundColor Cyan "compressList.Count: " $compressList.Count
    foreach($item in $compressList.GetEnumerator()) 
    {
        Write-Host -ForegroundColor Green -BackgroundColor Black "`n[26]" $item  
        $Path = (Get-ItemProperty  $item | select FullName).FullName
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "[28] Path:" $Path  
        $isDir = (Get-Item $Path) -is [System.IO.DirectoryInfo]
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "[30] isDir:" $isDir     
        
        if($isDir)  
        {   
            #Write-Host -ForegroundColor Magenta "[$33] Path: $Path "                
            #Write-Host -ForegroundColor Yellow "[$i] DirectoryPath: $DirectoryPath "
            if(Test-Path $DestinationPath)
            {
                Write-Host -ForegroundColor Yellow -BackgroundColor Black "[40] Adding to zip: " $Path 
                Get-ChildItem -Path $Path | Compress-Archive -Update  -DestinationPath $DestinationPath
            }
            else
            {
                Write-Host -ForegroundColor Magenta -BackgroundColor Black "[45] Creating zip and adding: " $Path 
                Get-ChildItem -Path $Path | Compress-Archive -DestinationPath $DestinationPath
            }                
        }
        else
        {
            #Write-Host -ForegroundColor Cyan "[$i] FILE Path: $Path "                
            if(Test-Path $DestinationPath)
            {
                Write-Host -ForegroundColor Yellow -BackgroundColor Black "[54] Adding to zip: " $Path 
                Get-ChildItem -Path $Path | Compress-Archive -Update  -DestinationPath $DestinationPath
            }
            else
            {
                Write-Host -ForegroundColor Yellow -BackgroundColor Black "[59] Creating zip and adding: " $Path 
                Get-ChildItem -Path $Path | Compress-Archive  -DestinationPath $DestinationPath
            }
            #Write-Host -ForegroundColor Cyan "[$i] ParentFullPath: $ParentFullPath "
        } 
    }


}#CreateZip

$RootFolder = "C:\GitHub\dtp"
#$DestinationPath = "$RootFolder" + "\deployDTS_Clients.Zip"
$DestinationPath = "C:\GitHub\dtpOfflineDeploy\deployDTS_Clients.Zip"
CreateZip -RootFolder $RootFolder -DestinationPath $DestinationPath
            



   <# $compressList = @(       
    "$RootFolder" + "\Deploy"
    "$RootFolder" + "\README.md"
    "$RootFolder" + "\SECURITY.md"    
    )
    #>