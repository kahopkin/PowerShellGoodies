<#
https://stackoverflow.com/questions/18684793/powershell-batch-change-files-encoding-to-utf-8
#>

$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
$source = "C:\GitHub\DTS\Deploy\DTS-3.0\Deploy\powershell"
$destination = "C:\GitHub\dtpResources-08-04-2023\2023\01UTF"

foreach ($i in Get-ChildItem -Recurse -Force) {
    if ($i.PSIsContainer) {
        continue
    }

    $path = $i.DirectoryName -replace $source, $destination
    $name = $i.Fullname -replace $source, $destination

    if ( !(Test-Path $path) ) {
        New-Item -Path $path -ItemType directory
    }

    $content = get-content $i.Fullname

    if ( $content -ne $null ) {

        [System.IO.File]::WriteAllLines($name, $content, $Utf8NoBomEncoding)
    } else {
        Write-Host "No content from: $i"   
    }
}