<#
#>



Function global:RobocopyMoveFiles
{
    Param(
         [Parameter(Mandatory = $true)] [String]$Source
        ,[Parameter(Mandatory = $true)] [String]$Destination
        
    )

    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm:ss'
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START MoveFiles from $Source to $Destination *****************"

    Write-Host -ForegroundColor White "`$Source=" -NoNewline
    Write-Host -ForegroundColor Cyan "`"$Source`""

    Write-Host -ForegroundColor White "`$Destination=" -NoNewline
    Write-Host -ForegroundColor Cyan "`"$Destination`""


    $currYear =  Get-Date -Format 'yyyy'    
    $YearFolderPath = $Destination + "\" + $currYear
    $currMonth =  Get-Date -Format 'MM'
    $MonthFolderPath = $YearFolderPath + "\" +  $currMonth    
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$MonthFolderPath=`"$MonthFolderPath`""
    $todayShort = Get-Date -Format 'MM-dd-yyyy'    
    $TodayFolder  = (Get-Date -Format 'MM-dd-yyyy')
    $LogFile = $TodayFolderPath = $Destination + "\" + $TodayFolder + ".log"


    <# To move all files and folders, including empty ones, with all attributes. 
     #Note that the source folder will also be deleted.
     robocopy c:\temp\source c:\temp\destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3
     #>

    #robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3
    robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /MOVE /W:3

    $psCommand =  "`n robocopy """ + 
            $Source + "`" """ + 
            $Destination + """ " +
            "/E /COPYALL /DCOPY:DAT  /MOVE /R:100 /W:3 "+ 
            "/LOG:""" +
            $LogFile + "`""     

    Write-Host -ForegroundColor Cyan $psCommand

}#Function global:RobocopyMoveFiles


$Source = ""

$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ChiefArchitect"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"

MoveFiles -ParentFolder $Source -BicepFolder $Destination