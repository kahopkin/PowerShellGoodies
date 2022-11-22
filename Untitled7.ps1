#https://sid-500.com/2021/10/26/powershell-zip-multiple-folder-or-files-at-once-with-compress-archive/

<# This script uses Compress archives (ZIP) to compress multiple (sub)folders 
and saves them individually in separate zip files.
#>
 
# Specify source folder
$source = 'C:\temp'
 
# Specify zip file location folder (destination folder, make sure it exists)
$destination = 'C:\ZipFiles'
 
# Action
$subfolders = Get-ChildItem $source -Directory -Recurse
foreach ($s in $subfolders)
{
 
$folderpath = $s.FullName
$foldername = $s.Name
 
Compress-Archive `
-Path $folderpath `
-DestinationPath $destination\$foldername
 
}


