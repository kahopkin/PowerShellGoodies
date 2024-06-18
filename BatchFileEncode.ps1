<#
https://superuser.com/questions/397890/convert-text-files-recursively-to-utf-8-in-powershell
#>
$source = "C:\GitHub\dtpResources-08-04-2023\2023\01\01-03-2023"
foreach($i in Get-ChildItem -Recurse) {
    if ($i.PSIsContainer) {
        continue
    }

    $dest = $i.Fullname.Replace($PWD, $source)
    if (!(Test-Path $(Split-Path $dest -Parent))) {
        New-Item $(Split-Path $dest -Parent) -type Directory
    }

    get-content $i | out-file -encoding utf8 -filepath $dest
}






#UTF8 without BOM,
foreach($i in Get-ChildItem -Recurse) {
    if ($i.PSIsContainer) {
        continue
    }

    $dest = $i.Fullname.Replace($PWD, $source)
    if (!(Test-Path $(Split-Path $dest -Parent))) {
        New-Item $(Split-Path $dest -Parent) -type Directory
    }

    $filecontents = Get-Content $i
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
    [System.IO.File]::WriteAllLines($i, $filecontents, $Utf8NoBomEncoding)
}



Param (
    [Parameter(Mandatory=$True)][String]$SourcePath
)

$SourcePath = "C:\GitHub\DTS\Deploy\DTS-3.0\Deploy\powershell"
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
#utf8BOM

Get-ChildItem $SourcePath\*  -recurse | ForEach-Object {
        if ($i.PSIsContainer) {
                continue
        }
        Else{
            $content = $_ | Get-Content

        #Set-Content -PassThru $_.Fullname $content -Encoding $Utf8NoBomEncoding -Force
        Set-Content -PassThru $_.Fullname $content -Encoding UTF8 -Force
        }
    }#Foreach



Get-ChildItem $SourcePath\*  -recurse -Include *.json,*.html,*.xml,*.js,*.txt,*.css | ForEach-Object {
$content = $_ | Get-Content

Set-Content -PassThru $_.Fullname $content -Encoding UTF8 -Force}



$files = [IO.Directory]::GetFiles($SourcePath)
foreach($file in $files) 
{     
    if ($i.PSIsContainer) 
    {
                continue
    }
    Else
    {
        $content = get-content –path $file
        $content | out-file $file –encoding utf8 -Force
    }
}


