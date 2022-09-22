#RemoveAppRegistration.ps1
#C:\GitHub\PowerShellGoodies\CleanUpResources.ps1

<#
This script removes app registrations, 
either Owned ones or specified by name
#>
Function global:CleanUpResources{
 Param(     
     [Parameter(Mandatory = $true)] [String] $OwnedApplication
    ,[Parameter(Mandatory = $true)] [String] $LogFilesOnly
    ,[Parameter(Mandatory = $true)] [String] $ParentFolder
    ,[Parameter(Mandatory = $true)] [String] $ResourceGroup
 )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START CleanUpResources "    
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START RemoveAppRegistrations: "                    
    Write-Host -ForegroundColor Yellow "[18] OwnedApplication: " $OwnedApplication
    Write-Host -ForegroundColor Yellow "[19] LogFilesOnly: " $LogFilesOnly
    
    #Connect-AzAccount -EnvironmentName AzureUSGovernment

    $i = 0
    if($OwnedApplication -eq $true -and $LogFilesOnly -eq $false)
    {
        $AdApplications = Get-AzADApplication -OwnedApplication
        Write-Host -ForegroundColor Yellow "[27] AppReg count: " $AdApplications.Count
        foreach($appreg in $AdApplications) 
        {      
            $i++      
            if($appreg.DisplayName -like 'Data*' -or $appreg.DisplayName -like 'depguide*') 
            {
                  #Write-Host -ForegroundColor Red "[$i]" $appreg.DisplayName " starts with 'Data'"
                  Write-Host -ForegroundColor Green -BackgroundColor Black "[$i]" $appreg.DisplayName"; AppId=" $appreg.AppId 
            } 
            else 
            {
                #Write-Host 'RemoveAppRegistration[$i] $appreg.DisplayName does not start with Data"'
                 Remove-AzADApplication -ObjectId $appreg.id
                 #Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id 
                 
                 Write-Host -ForegroundColor Red  -BackgroundColor White "[$i] Deleted " $appreg.DisplayName"; ObjectId=" $appreg.AppId 
            }	       
        }
    }

    $i=0
    Write-Host -ForegroundColor Green "`n[47]AppName.length=" $AppName.Length    

    if($AppName.Length -ne 0 )
    {
        Write-Host -ForegroundColor Green "AppName= $AppName"
        
        $AdApplications = Get-AzADApplication -DisplayName $AppName   
        Write-Host -ForegroundColor Yellow "CleanUpResources[50] AppReg count:" $AdApplications.Count
        
        foreach($appreg in $AdApplications) 
        {
            $i++
	        #Remove-AzADApplication -ObjectId $appreg.id
            Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id 
        }
    }
     else
    {
        Write-Host 'CleanUpResources[61] AppName is null' 
    }
    
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"    
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED RemoveAppRegistration "        

    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START DeleteLogFiles FOR $ParentDirPath "
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "[17] EXISTING $ParentFolder ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Cyan "[20] ParentFolder: $ParentFolder"
        Write-Host -ForegroundColor Cyan "[21] FullPath:"  $ParentFolderPath

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
        Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
        $i = 0  
        $j = 0  
    
        Foreach ($file In $dirs) 
        { 
        
            $FullPath =  $file.FullName
            $FileName = $file.BaseName        
            $ParentFolder = Split-Path (Split-Path $file.FullName -Parent) -Leaf
            $DirectoryPath = $file.DirectoryName
            $Extension = $file.Extension            
            $LastWriteTime = $file.LastWriteTime
            $LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            $FullFileName = Split-Path $file.FullName -Leaf -Resolve
            
            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $file.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name            
         
            Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`n[$i] FILE FullFileName: $FullFileName "                
            Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "[$i] FILE FullPath: $FullPath "
                
            Remove-Item -Path $FullPath
            $i++
         
           }#foreach
    }#if

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED DeleteLogFiles FOR $ParentDirPath "

    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START Removing ResourceGroup $ResourceGroup "
    #Remove-AzResourceGroup -Name $ResourceGroup -Force
    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED Removing ResourceGroup $ResourceGroup "
    
    Write-Host -ForegroundColor Green -BackgroundColor Black "`n [$today] FINISHED CleanUpResources "        
} #CleanUpResources

$today = Get-Date -Format 'ddd'   
$Environment = "test"
$Location = "usgovvirginia"
$AppName = $today + "Site"
$ResourceGroup += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment)

$ParentFolder = 'C:\GitHub\dtp\Deploy\logs'
#CleanUpResources -OwnedApplication $true -ParentFolder $ParentFolder -ResourceGroup $ResourceGroup
CleanUpResources `
    -OwnedApplication 'true' `
    -ParentFolder $ParentFolder `
    -ResourceGroup $ResourceGroup 
    #-LogFilesOnly $LogFilesOnly