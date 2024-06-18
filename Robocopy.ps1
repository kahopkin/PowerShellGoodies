<#
#>


$Source = ""
$Destination = ""
$LogFile = ""


<# To move all files and folders, including empty ones, with all attributes. 
 #Note that the source folder will also be deleted.
 #>

robocopy c:\temp\source c:\temp\destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3



<#
To copy all files and subdirectories, including empty directories, 
from the "Records" folder 
to the "Backup" folder on drive "D", 
type the following:
robocopy C:\Users\Admin\Records D:\Backup /E /ZB /LOG:C:\Logs\Backup.log
#>
$Source = "C:\Users\Admin\Records"
$Destination = "D:\Backup"
$LogFile = "C:\Logs\Backup.log"

robocopy  $Source $Destination  /E /ZB /LOG:$LogFile


<#
To copy all files and subdirectories that aren't empty 
from the "Records" folder 
to the "Backup" folder on drive "D", 
retaining the file data, attributes, 
and timestamps with 16 multi-threaded copy operation, 
type the following:
robocopy C:\Users\Admin\Records D:\Backup /S /E /COPY:DAT /MT:16 /LOG:C:\Logs\Backup.log
#>

$Source= "C:\Users\kahopkin\OneDrive - Microsoft\ARAG Legal"	
$Destination= "F:\DESKTOP-E6F1US5_04-2023"

$Source= "C:\GitHub"	
$Destination= "F:\DESKTOP-E6F1US5_04-2023"

$Source= "C:\GitHub\PowerShellGoodies"	
$Destination= "F:\DESKTOP-E6F1US5_04-2023\GitHub"


robocopy C:\Users\Admin\Records D:\Backup /S /E /COPY:DAT /MT:16 /LOG:C:\Logs\Backup.log

<#
To copy all files and subdirectories, 
including empty directories, 
from the "Records" folder 
to the "Backup" folder on drive "D"
#>

robocopy C:\Users\Admin\Records D:\Backup /E /ZB /LOG:C:\Logs\Backup.log

<#
To mirror the contents of 
the "Records" folder 
to the "Backup" folder on drive "D", 
delete any files in the destination that don't exist in the source 
with 2 retries 
and waiting 5 seconds between each retry,
#>

robocopy C:\Users\Admin\Records D:\Backup /MIR /R:2 /W:5 /LOG:C:\Logs\Backup.log

<#
To copy all files and subdirectories that aren't empty 
from the "Records" folder 
to the "Backup" folder on drive "D", 
retaining the file data, attributes, 
and timestamps 
with 16 multi-threaded copy operation
robocopy C:\Users\Admin\Records D:\Backup /S /E /COPY:DAT /MT:16 /LOG:C:\Logs\Backup.log
#>

robocopy C:\Users\Admin\Records D:\Backup /S /E /COPY:DAT /MT:16 /LOG:$LogFile
robocopy  $Source $Destination /S /E /COPY:DAT /MT:16 /LOG:$LogFile

robocopy $Source $Destination /s /copy:DAT /dcopy:DAT



$Source= "D:\video"
$Source= "D:\"
$Destination= "C:\Users\kahopkin\OneDrive - Microsoft\Videos\Camera Footage\Garage"

$currYear =  Get-Date -Format 'yyyy'    
$YearFolderPath = $Destination + "\" + $currYear
$currMonth =  Get-Date -Format 'MM'
$MonthFolderPath = $YearFolderPath + "\" +  $currMonth    
Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$MonthFolderPath=`"$MonthFolderPath`""
$todayShort = Get-Date -Format 'MM-dd-yyyy'    
$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
$LogFile = $TodayFolderPath = $Destination + "\" + $TodayFolder + ".log"
#$LogFile = $Destination + "\.log"
#

Write-host -ForegroundColor Cyan  "`$currMonth=`"$currMonth`""    
Write-host -ForegroundColor Green  "`$YearFolderPath=`"$YearFolderPath`""    
Write-host -ForegroundColor Green  "`$MonthFolderPath=`"$MonthFolderPath`""    
Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$TodayFolderPath=`"$TodayFolderPath`""

$Source="C:\Users\kahopkin\OneDrive - Microsoft\Documents\Personal\Pets\Ghost\KatHopkins-Ghost-PGCase50-23VA\To Print\"

<#
To copy all files and subdirectories 
from the "Source" folder 
to the "Destination" folder 
retaining the file and folder
data, 
attributes, 
and timestamps 
with 16 multi-threaded copy operation
robocopy C:\Users\Admin\Records D:\Backup /S /DCOPY:DAT /MT:16 /LOG:C:\Logs\Backup.log
#>
robocopy  $Source $Destination /S /COPY:DAT /DCOPY:DAT  /MT:16 /LOG:$LogFile

#>
<#
To copy all files and subdirectories 
that aren't empty 
from the "Records" folder 
to the "Backup" folder on drive "D", 
retaining the file and folder
data, 
attributes, 
and timestamps 
with 16 multi-threaded copy operation
robocopy C:\Users\Admin\Records D:\Backup /S /E /COPY:DAT /MT:16 /LOG:C:\Logs\Backup.log
#>
robocopy  $Source $Destination /S /E /DCOPY:DAT  /MT:16 /LOG:$LogFile


<#
To copy all files and subdirectories 
from the "Source" folder 
to the "Destination" folder 
retaining the file and folder
data, 
attributes, 
and timestamps 
with 16 multi-threaded copy operation
robocopy C:\Users\Admin\Records D:\Backup /S /DCOPY:DAT /MT:16 /LOG:C:\Logs\Backup.log
#>

robocopy  $Source $Destination /S /E /DCOPY:DAT /ETA /MT:16 /LOG:$LogFile

xcopy $Source $Destination /s /e /h

# Copy all file and folder information
robocopy d:\testfiles c:\temp\dst /copyall /dcopy:dat

robocopy  $Source $Destination  /copyall /dcopy:dat /LOG:$LogFile


robocopy  $Source $Destination /COPYALL /LOG:$LogFile 
<#
showing the estimated time for each file 
#>

<#
To move files and subdirectories, 
excluding empty directories, 
from the "Records" folder 
to the "Backup" folder on drive "D", 
and exclude files older than 7 days
#>

robocopy C:\Users\Admin\Records D:\Backup /S /MAXAGE:7 /MOV /LOG:C:\Logs\Backup.log

<#
To copy all files and subdirectories, including empty directories, 
from the "Records" folder 
to the "Backup" folder on drive "D" 
showing the estimated time for each file 
and delete any files and directories in the destination that don't exist from the source
#>

robocopy C:\Users\Admin\Records D:\Backup /ETA /PURGE /LOG:C:\Logs\Backup.log