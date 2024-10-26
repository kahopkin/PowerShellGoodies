#
robocopy `
"C:\Users\kahopkin\OneDrive - Microsoft\Nintex" `
"C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\Nintex" `
/S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
#>
           Total    Copied   Skipped  Mismatch    FAILED    Extras
    Dirs :        30        30        30         0         0         0
   Files :       477       477         0         0         0         0
   Bytes :   96.16 m   96.16 m         0         0         0         0
   Times :   0:00:36   0:00:02                       0:00:00   0:00:00


   Speed :           34,543,494 Bytes/sec.
   Speed :            1,976.595 MegaBytes/min.
   Ended : August 22, 2024 17:04:07

$StartTime="08/22/2024 17:04:04"
$EndTime="08/22/2024 17:04:07"
DURATION [HH:MM:SS]:00:00:03


#
 robocopy `
 "C:\Users\kahopkin\OneDrive - Microsoft\Nintex" `
 "D:\MS-Surface-E6F1US5\Nintex" `
 /S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
                Total    Copied   Skipped  Mismatch    FAILED    Extras
    Dirs :        30        30        30         0         0         0
   Files :       477       477         0         0         0         0
   Bytes :   96.16 m   96.16 m         0         0         0         0
   Times :   0:06:03   0:00:21                       0:00:00   0:00:01


   Speed :           4,688,137 Bytes/sec.
   Speed :             268.257 MegaBytes/min.
   Ended : August 22, 2024 16:38:41

$StartTime="08/22/2024 16:38:18"
$EndTime="08/22/2024 16:38:41"
DURATION [HH:MM:SS]:00:00:23




#
robocopy `
"C:\Users\kahopkin\OneDrive - Microsoft\Documents" `
"C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\Documents" `
/S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
#>

               Total    Copied   Skipped  Mismatch    FAILED    Extras
    Dirs :     38596     38596     38578         0         0         1
   Files :     43928     43928         0         0         0         0
   Bytes :  49.538 g  49.538 g         0         0         0         0
   Times :   3:29:34   0:16:46                       0:00:00   0:01:36


   Speed :           52,867,134 Bytes/sec.
   Speed :            3,025.082 MegaBytes/min.
   Ended : August 22, 2024 16:25:59

$StartTime="08/22/2024 16:07:36"
$EndTime="08/22/2024 16:25:59"
DURATION [HH:MM:SS]:00:18:23




#
 robocopy `
 "C:\Users\kahopkin\OneDrive - Microsoft\Downloads" `
 "D:\MS-Surface-E6F1US5\Downloads" `
 /S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
 #>
-----------------------------------------------------------------------------

               Total    Copied   Skipped  Mismatch    FAILED    Extras
    Dirs :      3370      3370      3367         0         0         1
   Files :     22773     22773         0         0         0         0
   Bytes :  50.260 g  50.260 g         0         0         0         0
   Times :  15:14:30   0:52:28                       0:00:00   0:03:24


   Speed :           17,139,486 Bytes/sec.
   Speed :              980.729 MegaBytes/min.
   Ended : August 22, 2024 14:38:21

$StartTime="08/22/2024 13:42:27"
$EndTime="08/22/2024 14:38:22"
DURATION [HH:MM:SS]: 00:55:55

PS C:\GitHub\PowerShellGoodies\MoveFiles> 





PS C:\GitHub\PowerShellGoodies\MoveFiles> 
  #
 robocopy `
 "C:\Users\kahopkin\OneDrive - Microsoft\Videos" `
 "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5\Videos" `
 /S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
 #>
 
 <#
 robocopy `
 $Source `
 $Destination `
 /S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
 #>




               Total    Copied   Skipped  Mismatch    FAILED    Extras
    Dirs :       250       250       250         0         0         1
   Files :     25562     25562         0         0         0         0
   Bytes :  75.766 g  75.766 g         0         0         0         0
   Times :   1:33:20   0:05:32                       0:00:00   0:00:22


   Speed :           244,960,762 Bytes/sec.
   Speed :            14,016.768 MegaBytes/min.
   Ended : August 22, 2024 11:42:31




  robocopy `
 "C:\Users\kahopkin\OneDrive - Microsoft\Documents" `
 "D:\MS-Surface-E6F1US5\Documents" `
 /S /ETA /COPYALL /DCOPY:DAT /R:1 /W:1 /MT:16
 #>

               Total    Copied   Skipped  Mismatch    FAILED    Extras
    Dirs :     38596     38596     38579         0         0         0
   Files :     43928     43928         0         0         0         0
   Bytes :  49.538 g  49.538 g         0         0         0         0
   Times :  13:27:37   0:46:59                       0:00:00   0:03:06


   Speed :           18,868,306 Bytes/sec.
   Speed :            1,079.653 MegaBytes/min.
   Ended : August 22, 2024 13:05:46


PS C:\GitHub\PowerShellGoodies\MoveFiles> 
$EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
$Duration = New-TimeSpan -Start $StartTime -End $EndTime


Write-Host -ForegroundColor Green "`$StartTime=" -NoNewline
Write-Host -ForegroundColor White "`"$StartTime`""
Write-Host -ForegroundColor Cyan "`$EndTime=" -NoNewline
Write-Host -ForegroundColor White "`"$EndTime`""
Write-Host -ForegroundColor Cyan "DURATION [HH:MM:SS]:" $Duration

$StartTime="08/22/2024 12:15:41"
$EndTime="08/22/2024 13:11:40"
DURATION [HH:MM:SS]: 00:55:59

PS C:\GitHub\PowerShellGoodies\MoveFiles>     