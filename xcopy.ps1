<#
xcopy
https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/xcopy
#>

# To copy all the files and subdirectories (including any empty subdirectories) from drive A to drive B, type:
xcopy a: b: /s /e

#To include any system or hidden files in the previous example, add the /h command-line option as follows:
xcopy a: b: /s /e /h

#To update files in the \Reports directory with the files in the \Rawdata directory that have changed since December 29, 1993, type:
xcopy \rawdata \reports /d:12-29-1993



#To update all the files that exist in \Reports in the previous example, regardless of date, type:
xcopy \rawdata \reports /u


#To obtain a list of the files to be copied by the previous command (that is, without actually copying the files), type:
xcopy \rawdata \reports /d:12-29-1993 /l > xcopy.out

#To copy the \Customer directory and all subdirectories to the directory \\Public\Address on network drive H:, retain the read-only attribute, and be prompted when a new file is created on H:, type:
xcopy \customer h:\public\address /s /e /k /p


# To issue the previous command, ensure that xcopy creates the \Address directory if it doesn't exist, and suppress the message that appears when you create a new directory, add the /i command-line option as follows:
xcopy \customer h:\public\address /s /e /k /p /i



<#
#You can create a batch program to perform xcopy operations 
#and use the batch if command to process the exit code if an error occurs. 
#For example, the following batch program uses replaceable parameters for the xcopy 
#source and destination parameters:
#>
@echo off
rem COPYIT.BAT transfers all files in all subdirectories of
rem the source drive or directory (%1) to the destination
rem drive or directory (%2)
xcopy %1 %2 /s /e
if errorlevel 4 goto lowmemory
if errorlevel 2 goto abort
if errorlevel 0 goto exit
:lowmemory
echo Insufficient memory to copy files or
echo invalid drive or command-line syntax.
goto exit
:abort
echo You pressed CTRL+C to end the copy operation.
goto exit
:exit

#


#


