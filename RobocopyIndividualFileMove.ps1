$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Excel"
#$Source = ""
#$Source = ""
#$Source = ""
#$Source = ""

$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Accounts\CapitalOne Visa"
$Destination = "D:\Personal"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft"
$Destination = "C:\Users\kahopkin\"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Music"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Miscellaneous"
#$Destination = ""
#$Destination = ""
#$Destination = ""

$FileName = "2024-07-30_Account.xlsx"
#$FileName = ""
#$FileName = ""
#$FileName = ""



$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy-HH-mm-ss')
$SourceFolder = Get-Item -Path $Source
$LogFile = $Destination + "\" + $SourceFolder.Name + "_" + $TodayFolder + ".log"

Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`$Source=" -NoNewline
Write-Host -ForegroundColor White -BackgroundColor Black  "`"$Source`""	
Write-Host -ForegroundColor Cyan -BackgroundColor Black  "`$Destination=" -NoNewline
Write-Host -ForegroundColor White -BackgroundColor Black  "`"$Destination`""

$psCommand =  "`nrobocopy """ + 
		$Source + "`" """ + 
		$Destination + """ " +        
		#"*.xlsx /COPYALL /COPY:DAT /MOVE /R:10 /W:3 "
        "/xf *.xlsx *xltx *xlxm"
Write-Host -ForegroundColor Cyan $psCommand

robocopy $Source $Destination *.xlsx /COPYALL /COPY:DAT 

#robocopy $Source $Destination /S /COPYALL /DCOPY:DAT /MOVE /R:10 /W:3

#Move all files with .EXT to Destination folder
robocopy $Source $Destination *.xlsx /COPYALL /COPY:DAT /MOVE /R:10 /W:3

#robocopy $Source $Destination /COPYALL /COPY:DAT /MOVE /R:10 /W:3

#The example below copies all files, except log and txt files:
#robocopy d:\testfiles c:\temp\dst /xf *.log *.txt
robocopy  $Source $Destination  /COPYALL /COPY:DAT /XF *.xlsx *xltx *xlxm *csv *txt
