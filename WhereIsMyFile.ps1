<#
C:\GitHub\PowerShellGoodies\WhereIsMyFile.ps1
#>
$currDir = Get-Item (Get-Location)
$correctPath = ("Deploy\powershell").ToLower()
Write-host -ForegroundColor Yellow "[6] currDir" $currDir
Write-host -ForegroundColor Yellow "[7] correctPath:" $correctPath

$DeployPath = "Deploy\logs"

If(($currDir.FullName).ToLower().Contains($correctPath))
{
   $Caller='InitiateDeploymentProcess[31]'        
    #PrintHash -object $currDirHash -Caller $Caller
    
    #Check if logs folder exists in the Deploy folder to save the output log file and the output json files. 
    #if doesn't exist: create the logs folder    
    $DeployPath = "Deploy\logs"
    $LogsFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item (Get-Location)).FullName -Parent) | select FullName).FullName)
    $global:LogsFolder = Get-ChildItem -Path  $LogsFolderParentPath | `
                    Where-Object { `
                        ($_.PSIsContainer -eq $true) -and `
                        $_.FullName.Contains($DeployPath)}
    #Write-Host -ForegroundColor Green "[69]LogsFolder.Length=" $LogsFolder.FullName.Length
    #Write-Host -ForegroundColor Green  "[43]" ($LogsFolder -eq $null)
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    If($LogsFolder -eq $null)
    {
        $folderName ="logs"
        $LogsFolder = New-Item -Path $LogsFolderParentPath -Name $folderName -ItemType Directory
        $LogsFolderPath = (Get-ItemProperty  $LogsFolder | select FullName).FullName
        $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
        Write-Host -ForegroundColor Yellow "===================================================================================================="
        Write-Host -ForegroundColor Yellow "[$today] CREATED LOGS FOLDER:" $LogsFolderPath        
        Write-Host -ForegroundColor Yellow "===================================================================================================="
        
    } 
    Else
    {
        $LogsFolderPath = $LogsFolder.FullName
        #Write-Host -ForegroundColor Yellow "`n"
        Write-Host -ForegroundColor Yellow "===================================================================================================="
        Write-Host -ForegroundColor Yellow "[$today] LOGS FOLDER:" $LogsFolderPath        
        Write-Host -ForegroundColor Yellow "===================================================================================================="
        #Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[54] LogsFolderPath: $LogsFolderPath" 
    }   

    #Output file and the json file needed for the Bicep deployment
    #$todayLong = Get-Date -Format "MM-dd-yyyy-HH-mm"    
    $todayShort = Get-Date -Format 'MM-dd-yyyy'
    $global:OutFile = "$LogsFolderPath\DeployLog_$todayShort.txt"
    #$global:OutFile = "$LogsFolderPath\DeployLog.txt"
    <#
    If (Test-Path $OutFile) 
    {
        Write-host "InitiateDeploymentProcess[63] EXISTING" $OutFile    
    }
    Else
    {
        #Write-host "InitiateDeploymentProcess[67] NO EXISTING" $OutFile " CREATE IT..."   
    }
    #>
    
    $RoleDefinitionFile = "C:\GitHub\dtp\Deploy\DTPStorageBlobDataReadWrite.json"
    #$jsonFileName = "DeploymentOutput-" + $todayShort + ".json"    
    $jsonFileName = "DeploymentOutput.json"
    
    $global:OutFileJSON = "$LogsFolderPath\$jsonFileName"
    <#
    If (Test-Path $OutFileJSON) 
    {
        Write-host $OutFileJSON " EXISTS"    
    }
    Else
    {
        #Write-host "InitiateDeploymentProcess[80] NO EXISTING" $OutFileJSON " CREATE IT..."   
    }
    #Write-Host -ForegroundColor Yellow "OutFileJSON: " $OutFileJSON       
    #Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[68] OutPut Log File: " $OutFile            
    #>
}
else
{    
 
    Write-Host -ForegroundColor Red -BackgroundColor White "The successful deployment requires that you execute this script from the 'Deploy\powershell' folder."
    Write-Host -ForegroundColor Red -BackgroundColor White "Please change directory to the 'dtp\Deploy' folder and run this script again..."
}