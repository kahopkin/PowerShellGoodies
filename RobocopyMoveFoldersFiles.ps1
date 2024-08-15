<#
# RobocopyMoveFoldersFiles
#>

<# To move all files and folders, including empty ones, with all attributes. 
 #Note that the source folder will also be deleted.
 #>

robocopy c:\temp\source c:\temp\destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3


robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /R:10 /W:3