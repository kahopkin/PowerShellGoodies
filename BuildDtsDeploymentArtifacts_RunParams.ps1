$debugFlag = $true
$currDir = Get-Item (Get-Location)    
$currDirPath = ($currDir.FullName).ToLower()
$ParentFolderPath = ((Get-ItemProperty (Split-Path (Get-Item ($currDir)).FullName -Parent) | select FullName).FullName)
$index = $currDirPath.IndexOf("deploy")    
$RootFolder = $currDirPath.Substring(0,$index)
$DTSSourceRoot = $RootFolder
$DtsRelease = "..\..\..\DtsReleases"
$DtsReleasePath = (Get-Item $DtsRelease).FullName
#$DTSSourceRoot = "..\..\..\DtsReleases"
$DTSSourceRootPath = (Get-Item $DTSSourceRoot).FullName
$ArtifactsPath = "..\..\..\DtsReleases\Artifacts"
if (-not (Test-Path $ArtifactsPath)) {
    Write-host -ForegroundColor Red  "DOES NOT EXIST:`$ArtifactsPath=`"$ArtifactsPath`""
    #$folderName = $CompressedOutputPath.split("\")        
    #Write-host -ForegroundColor Yellow  "`$CompressedOutputPath=`"$CompressedOutputPath`""
    #$ArtifactsPath = New-Item -Path $DtsReleasePath -Name "Artifacts" -ItemType Directory
    #$ArtifactsPathFullName = (Get-Item $ArtifactsPath).FullName
}
else
{
    $ArtifactsPathFullName = (Get-Item $ArtifactsPath).FullName
}
$DestinationPath = $DtsReleasePath + "\Artifacts"
$CompressedOutputPath = $DtsReleasePath
$CompressArchiveName = "DisconnectedTransfer"


#$DestinationPath = (Get-Item $DestinationPath).FullName

If($debugFlag){
    Write-host -ForegroundColor Cyan "BuildDtsDeploymentArtifacts.BuildArchive[]::"
    Write-host -ForegroundColor Green  "`$currDirPath=`"$currDirPath`""
    Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
    Write-host -ForegroundColor Green  "`$DTSSourceRoot=`"$DTSSourceRoot`""
    Write-host -ForegroundColor Green  "`$DTSSourceRootPath=`"$DTSSourceRootPath`""
    Write-host -ForegroundColor Green  "`$DtsRelease=`"$DtsRelease`""
    Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""
    Write-host -ForegroundColor Green  "`$DestinationPath=`"$DestinationPath`""
    Write-host -ForegroundColor Green  "`$CleanDestination=`"$CleanDestination`""
    Write-host -ForegroundColor Green  "`$ArtifactsPath=`"$ArtifactsPath`""
    Write-host -ForegroundColor Green  "`$ArtifactsPathFullName=`"$ArtifactsPathFullName`""
    Write-host -ForegroundColor Green  "`$ForDisconnectedEnvironmentTransfer=`"$ForDisconnectedEnvironmentTransfer`""
    Write-host -ForegroundColor Green  "`$CompressOutput=`"$CompressOutput`""
    Write-host -ForegroundColor Green  "`$CompressedOutputPath=`"$CompressedOutputPath`""
    Write-host -ForegroundColor Green  "`$CompressArchiveName=`"$CompressArchiveName`""
}#>


.\BuildDtsDeploymentArtifacts.ps1 `
    -DTSSourceRoot $DTSSourceRoot `
    -DestinationPath $DestinationPath `
    -CleanDestination `
    -ForDisconnectedEnvironmentTransfer `
    -CompressOutput `
    -CompressedOutputPath $CompressedOutputPath `
    -CompressArchiveName $CompressArchiveName `
    -Artifacts OfflineFiles,DocumentationUI
#>

.\BuildDtsDeploymentArtifacts.ps1 `
    -DTSSourceRoot $DTSSourceRoot `
    -DestinationPath $DestinationPath `
    -CleanDestination `
    -ForDisconnectedEnvironmentTransfer `
    -CompressOutput `
    -CompressedOutputPath $CompressedOutputPath `
    -CompressArchiveName $CompressArchiveName `
    -Artifacts OfflineFiles,DocumentationUI,TransferApi,PickupApi,TransferUI,PickupUI

.\BuildDtsDeploymentArtifacts.ps1 ../ ..\Artifacts -Artifacts TransferUI

#$DTSSourceRoot = $RootFolder + "DtsReleases"
#$CleanDestination = $false
#$ForDisconnectedEnvironmentTransfer = $true
#$CompressOutput = $true
#$CompressedOutputPath = $RootFolder + "DtsReleases\2.0.0"



.\BuildDtsDeploymentArtifacts.ps1 `
    -DTSSourceRoot $DTSSourceRoot `
    -DestinationPath $DestinationPath `
    -CleanDestination `
    -ForDisconnectedEnvironmentTransfer `
    -CompressOutput `
    -CompressedOutputPath $CompressedOutputPath `
    -CompressArchiveName $CompressArchiveName `
    -Artifacts OfflineFiles `
              ,DocumentationUI `
              ,TransferApi `
              ,PickupApi `
              ,TransferUI `
              ,PickupUI



OfflineFiles, DocumentationUI, TransferApi, PickupApi, TransferUI, PickupUI