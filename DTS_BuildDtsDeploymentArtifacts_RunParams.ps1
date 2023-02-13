cd C:\GitHub\dtp\Deploy\powershell
#builds site zips
$debugFlag = $true

$RootFolder="c:\github\dtp\"
$RootFolderParentPath = ((Get-ItemProperty  (Split-Path (Get-Item $RootFolder).FullName -Parent) | select FullName).FullName)


#DTSSourceRoot = dtp code folder
$DTSSourceRoot = $RootFolder
$DTSSourceRootPath = (Get-Item $DTSSourceRoot).FullName

$AppName = "DTS"
$AppName = "DTP"

$Solution = "Dev"
#$Solution = "Prod"

$DtsReleaseFolderName = "DtsRelease_" + $AppName + "_" + $Solution
$DtsReleasePath = $RootFolderParentPath + "\" + $DtsReleaseFolderName

if (-not (Test-Path $DtsReleasePath)) 
{
    $DtsReleaseFolder = New-Item -Path $RootFolderParentPath -Name $DtsReleaseFolderName -ItemType Directory
    $DtsReleasePath = $DtsReleaseFolder.FullName
}

$ArtifactsPath = $DtsReleasePath +  "\Artifacts"

if (-not (Test-Path $ArtifactsPath)) 
{
    Write-host -ForegroundColor Red  "DOES NOT EXIST:`$ArtifactsPath=`"$ArtifactsPath`""
    $ArtifactsFolder = New-Item -Path $DtsReleasePath -Name "Artifacts" -ItemType Directory
    $ArtifactsPath = (Get-Item $ArtifactsPath).FullName
}
else
{
    $ArtifactsPath = (Get-Item $ArtifactsPath).FullName
}


$DestinationPath = $DtsReleasePath + "\Artifacts"
$CompressedOutputPath = $DtsReleasePath

$CompressArchiveName = "ConnectedTransfer"
$CompressArchiveName = "DisconnectedTransfer"

#$DestinationPath = (Get-Item $DestinationPath).FullName

If($debugFlag){
    Write-host -ForegroundColor Cyan "BuildDtsDeploymentArtifacts.BuildArchive[]::"
    #Write-host -ForegroundColor Green  "`$currDirPath=`"$currDirPath`""
    Write-host -ForegroundColor Green  "`$RootFolder=`"$RootFolder`""
    Write-host -ForegroundColor Green  "`$RootFolderParentPath=`"$RootFolderParentPath`""

    Write-host -ForegroundColor Green  "`$DTSSourceRoot=`"$DTSSourceRoot`""
    Write-host -ForegroundColor Green  "`$DTSSourceRootPath=`"$DTSSourceRootPath`""    

    Write-host -ForegroundColor Green  "`$DtsReleaseFolderName=`"$DtsReleaseFolderName`""    
    Write-host -ForegroundColor Green  "`$DtsReleasePath=`"$DtsReleasePath`""

    Write-host -ForegroundColor Green  "`$DestinationPath=`"$DestinationPath`""
    #Write-host -ForegroundColor Green  "`$CleanDestination=`"$CleanDestination`""
    Write-host -ForegroundColor Green  "`$ArtifactsPath=`"$ArtifactsPath`""
    #Write-host -ForegroundColor Green  "`$ArtifactsPathFullName=`"$ArtifactsPathFullName`""
    #Write-host -ForegroundColor Green  "`$ForDisconnectedEnvironmentTransfer=`"$ForDisconnectedEnvironmentTransfer`""
    #Write-host -ForegroundColor Green  "`$CompressOutput=`"$CompressOutput`""
    Write-host -ForegroundColor Green  "`$CompressedOutputPath=`"$CompressedOutputPath`""
    Write-host -ForegroundColor Green  "`$CompressArchiveName=`"$CompressArchiveName`""
}#>
<#
Compile DTP/DPP client side applications: 
      .\BuildDtsDeploymentArtifacts.ps1 `
            -DTSSourceRoot '..\..\DtsReleases\2.0.0\SourceCode' `
            -DestinationPath '..\..\DtsReleases\2.0.0\Artifacts' `
            -Artifacts TransferUI,PickupUI
#>

#DPP
.\BuildDtsDeploymentArtifacts.ps1 `
    -DTSSourceRoot $DTSSourceRoot `
    -DestinationPath $DestinationPath `
    -CleanDestination `
    -CompressOutput `
    -CompressedOutputPath $CompressedOutputPath `
    -CompressArchiveName $CompressArchiveName `
    -Artifacts   PickupApi `
                ,PickupUI 


#DTP
.\BuildDtsDeploymentArtifacts.ps1 `
    -DTSSourceRoot $DTSSourceRoot `
    -DestinationPath $DestinationPath `
    -CleanDestination `
    -CompressOutput `
    -CompressedOutputPath $CompressedOutputPath `
    -CompressArchiveName $CompressArchiveName `
    -Artifacts TransferApi `
              ,TransferUI `              


<#

.\BuildDtsDeploymentArtifacts.ps1 `
            -DTSSourceRoot 'c:\github\dtp\' `
            -DestinationPath '..\..\github\DtsRelease_DTS_Dev\Artifacts' `
            -CleanDestination `
    -CompressOutput `
    -CompressedOutputPath $CompressedOutputPath `
    -CompressArchiveName $CompressArchiveName `
    -Artifacts   PickupApi `
                ,PickupUI 
                #>