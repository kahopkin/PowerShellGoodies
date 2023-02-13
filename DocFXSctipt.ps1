$dir = "C:\Users\atparach\Documents\projects\BlueMountain\ABS\abs"
$output = "C:\Users\atparach\Documents\projects\BlueMountain\ABS\docfx_project\articles"
$outputYML = "C:\Users\atparach\Documents\projects\BlueMountain\ABS\docfx_project\articles\toc.yml"

$Folders = get-childitem $dir -Attributes d

ForEach($Folder in $Folders) 
{
    $Files = get-childitem -path "$($dir)\$($Folder)" -name "*.md" -Recurse

    ForEach($File in $Files)
    {
        md "$($output)\$($Folder)" -ea 0
        Copy-Item "$($dir)\$($Folder)\$($File)" -Destination "$($output)\$($Folder)\$(split-path $file -leaf)" -force
    }

    $AssetImages = get-childitem -path "$($dir)\$($Folder)" -Include @('*.png','*.jpg') -Recurse | `
        Select-Object -Property Name, @{l='Path';e={Join-Path -Path ($_.Directory) -ChildPath $_.Name }}
    if($AssetImages)
    {
        $OutputImagePath = New-Item -Path "$($output)\$($Folder)\" -Name "assets" -ItemType "directory" -Force
        #md "$($output)\$($Folder)\assets" -ea 0
        ForEach($AssetImage in $AssetImages)
        {
            copy-item -path "$($AssetImage.Path)" -Destination "$($OutputImagePath.FullName)" -force
        }
    }
}

$files = Get-ChildItem -Path $output -File -Recurse | Select-Object -Property  @{l='Parent';e={$_.Directory | split-Path -Leaf}}, BaseName, @{l='RelativePath';e={Join-Path -Path ($_.Directory | split-Path -Leaf) -ChildPath $_.Name }}
$groups = $files | Group-Object Parent
$outputYMLValue  = foreach ($group in $groups)
{
    if ($group.Name -ne "articles")
    {
        "- name: $($group.name)" #gives you the directory name of the parent folder
        "  items:"
        foreach ($path in $group.Group)
        {
            "  - name: $($path.basename)"
            "    href: $($path.RelativePath)"
        }
    }
}

Set-Content -Path $outputYML -Value $outputYMLValue 