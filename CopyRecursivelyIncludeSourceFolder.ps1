$Source = $path = ""
#$path = 'C:\GitHub\_dtpExports\rg-dev-dtp\06-16-2022'
#$Source = $path = "D:\video"
#$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Videos\Camera Footage\Garage"	


#IMPORTANT:
#ROBOCOPY DO NOT PUT \ AT THE END OF SOURCE OR DESTINATION!
#>
$Source = $path = "C:\Kat\Flankspeed Exports\05-28-2024_ODIN\05-28-2024_Exports\ACAS Excel Exports\ACAS SCANS"



#$Source = $path = ""
#>
$CopyDestinationRootFolder= "C:\"
$Destination = ""
<#


#$Destination = "E:\"
#$Destination = "F:\"
#$Destination = "C:\"

#$Destination = ""
#>
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"
#>    

$OutFile = $path + '\ResourcesLong.txt'
$OutFileShort = $path + 'ResourcesShort.txt'

$currYear =  Get-Date -Format 'yyyy'    
$YearFolderPath = $Destination + "\" + $currYear
$currMonth =  Get-Date -Format 'MM'
$MonthFolderPath = $YearFolderPath + "\" +  $currMonth    
#Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$MonthFolderPath=`"$MonthFolderPath`""
$todayShort = Get-Date -Format 'MM-dd-yyyy'    
$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
$LogFile = $TodayFolderPath = $Destination + "\" + $TodayFolder + ".log"
#$LogFile = $Destination + "\.log"
#


   
Write-host -ForegroundColor Cyan  "`$Source=`"$Source`""    
Write-host -ForegroundColor Green  "`$Destination=`"$Destination`""    

$SourceFileNameArr = $Source.split("\")
$SourceFileName = $SourceFileNameArr[$SourceFileNameArr.Count-1]
$DestinationFolder = $Destination + "\" + $SourceFileName
    
Write-host -ForegroundColor Cyan  "`$Source=`"$Source`""    
Write-host -ForegroundColor Yellow  "`$SourceFileName=`"$SourceFileName`""    
Write-host -ForegroundColor Green  "`$Destination=`"$Destination`""    
Write-host -ForegroundColor Cyan  "`$DestinationFolder=`"$DestinationFolder`""    

Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$LogFile=`"$LogFile`""




#Write-Host -ForegroundColor Yellow "[" $i + "]"
Write-Host -ForegroundColor Red "`nCopying files" 
Write-Host -ForegroundColor White "`$Source=" -NoNewline
Write-Host -ForegroundColor Green "`"$Source`""
Write-Host -ForegroundColor White "`$Destination=" -NoNewline
Write-Host -ForegroundColor Cyan "`"$Destination`""

If( (Test-Path $DestinationFolder) -eq $false)
{
    $DestinationFolder = (New-Item -Path $Destination -Name $SourceFileName -ItemType Directory).FullName
    #$Destination = New-Item -Path $Destination -Name $SourceFileName -ItemType Directory
    $DestinationPath = $MonthFolder.FullName
    Write-Host -ForegroundColor Green "CREATED DESTINATION FOLDER:"
    Write-Host -ForegroundColor White "`$DestinationFolder=" -NoNewline
    Write-Host -ForegroundColor Yellow "`"$DestinationFolder`""

    Write-Host -ForegroundColor Cyan "`$DestinationPath=" -NoNewline
    Write-Host -ForegroundColor Yellow "`"$DestinationPath`""
}

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
#
#folders and files:
robocopy  $Source $DestinationFolder /S /E /ETA /DCOPY:DAT  /MT:16 /LOG:$LogFile
#files only:
#robocopy  $Source $Destination /S /E /ETA /COPY:DAT  /MT:16 /LOG:$LogFile
             
$psCommand =  "`n robocopy """ + 
            $Source + "`" """ + 
            $Destination + """ " +
            "/S /E /ETA /DCOPY:DAT  /MT:16 /LOG:""" +
            $LogFile + "`""      

#
If($debugFlag){
    # Write-Host -ForegroundColor Magenta "ListFoldersAndFilesToTextFile.GetFiles[112]:"         
    Write-Host -ForegroundColor Cyan $psCommand
}#If($debugFlag) #> 
