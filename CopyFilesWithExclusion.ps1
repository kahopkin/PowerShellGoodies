<#

From:
How to recursively copy a folder structure excluding some child folders and files

https://techblog.dorogin.com/powershell-how-to-recursively-copy-a-folder-structure-excluding-some-child-folders-and-files-a1de7e70f1b
http://blogs.technet.com/b/heyscriptingguy/archive/2011/02/18/speed-up-array-comparisons-in-powershell-with-a-runtime-regex.aspx
#>

$SourceFolder="C:\GitHub\dtp\Deploy"
$Destination="C:\GitHub\dtpResources\2023\05\05-03-2023\ModularizeAutomation_Deploy_11-57"
#$SourceFolder = "C:\GitHub\dtp\Deploy\*"
#$from = 'c:\sources'
#$to = 'c:\build'
$from = $SourceFolder
$to = $Destination

Write-host -ForegroundColor Cyan  "`$from=`"$from`""
$fromLength = $from.length
Write-host -ForegroundColor Cyan  "`$fromLength=`"$fromLength`""   
Write-host -ForegroundColor Cyan  "`$to=`"$to`""

$exclude = @("*.pdf","*.md")
$excludeMatch = @("SQL", "TestData", "Migrations", "LocalSetUp")

[regex] $excludeMatchRegEx = ‘(?i)‘ + (($excludeMatch |foreach {[regex]::escape($_)}) –join “|”) + ‘’
#$excludeMatchRegEx.ToString():
#$excludeMatchRegEx = (?i)SQL|TestData|Migrations|LocalSetUp

$i=0

Get-ChildItem -Path $from -Recurse -Exclude $exclude | 
 where { $excludeMatch -eq $null -or $_.FullName.Replace($from, "") -notmatch $excludeMatchRegEx} |

 Copy-Item -Destination {
  if ($_.PSIsContainer) 
  {
    Write-Host -ForegroundColor Cyan "[$i] - Folder: " -NoNewline
    $PSIsContainerName = $_.FullName
    $ParentFullName = $_.Parent.FullName
    $currItemFullName = $_.FullName
    Write-Host -ForegroundColor White -NoNewline "`$PSIsContainerName=`""
    Write-Host -ForegroundColor Cyan "`"$PSIsContainerName`""
    
    Write-Host -ForegroundColor White -NoNewline "`$ParentFullName=`""
    Write-Host -ForegroundColor Green "`"$ParentFullName`""

    Write-Host -ForegroundColor White -NoNewline "`$currItemFullName=`""
    Write-Host -ForegroundColor Green "`"$currItemFullName`""

    Join-Path $to $_.Parent.FullName.Substring($from.length)
    $i++
  } 
  else 
  {
    Write-Host -ForegroundColor Magenta "[$i] - File: " -NoNewline
    
    $PSIsContainerName = $_.FullName
    $PSParentPath = $_.PSParentPath.Substring(38)
    $currItemFullName = $_.FullName
    $parentDir = $_.DirectoryName

    Write-Host -ForegroundColor Magenta "`$PSIsContainerName=`"" -NoNewline
    Write-Host -ForegroundColor Magenta "`"$PSIsContainerName`""
    
    Write-Host -ForegroundColor Yellow  "`$PSParentPath=`"" -NoNewline
    Write-Host -ForegroundColor Yellow "`"$PSParentPath`""

    Write-Host -ForegroundColor Green "`$currItemFullName=`"" -NoNewline
    Write-Host -ForegroundColor Green "`"$currItemFullName`""

    #Write-Host -ForegroundColor White -NoNewline "`$XYZ=`""
    #Write-Host -ForegroundColor Cyan "`"$XYZ`""
    if ((Test-Path $PSParentPath) -eq $false) 
    {
        #$ParentFolder = New-Item -Path $PSParentPath -Name $parentDir -ItemType Directory
        New-Item -Path $PSParentPath -Name $parentDir -ItemType Directory
    }

    Join-Path $to $_.FullName.Substring($from.length)

    $i++
  }
 } -Force -Exclude $exclude



#Write-Host -ForegroundColor White -NoNewline "`$XYZ=`""
#Write-Host -ForegroundColor Cyan "`"$XYZ`""