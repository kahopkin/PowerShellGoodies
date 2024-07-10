﻿<#
C:\GitHub\PowerShellGoodies\MoveFiles\4_RobocopyMoveFiles.ps1
#>



Function global:RobocopyMoveFiles
{
	Param(
		 [Parameter(Mandatory = $true)] [String]$Source
		,[Parameter(Mandatory = $true)] [String]$Destination
		
	)

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n *************[$today] START 4_RobocopyMoveFilesv *****************"
	<#Write-Host -ForegroundColor White -BackgroundColor Black "Source= " $Source 	
	#Write-Host -ForegroundColor Magenta -BackgroundColor Black 
	Write-Host -ForegroundColor Magenta -BackgroundColor Black "to $Destination *****************"
	#>

	Write-Host -ForegroundColor Yellow "`$Source=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Source`""
	#get # of folders and files:
	$FolderCount = (Get-ChildItem -Path $Source -Recurse -Directory | Measure-Object).Count
	$FileCount = (Get-ChildItem -Path $Source -Recurse -File | Measure-Object).Count
	
	Write-Host -ForegroundColor Yellow "`$FolderCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FolderCount`""

	Write-Host -ForegroundColor Yellow "`$FileCount= "  -NoNewline
	Write-Host -ForegroundColor Cyan "`"$FileCount`""

	Write-Host -ForegroundColor Yellow "`$Destination=" -NoNewline
	Write-Host -ForegroundColor Cyan "`"$Destination`""	
 
	$TodayFolder  = (Get-Date -Format 'MM-dd-yyyy-HH-mm-ss')
	$SourceFolder = Get-Item -Path $Source
	$LogFile = $TodayFolderPath = $Destination + "\" + $TodayFolder + "_" + $SourceFolder.Name + ".log"


	$SourceFileNameArr = $Source.split("\")
	$SourceFileName = $SourceFileNameArr[$SourceFileNameArr.Count-1]
	$DestinationFolder = $Destination + "\" + $SourceFileName

	If( (Test-Path $DestinationFolder) -eq $false)
	{
		#$DestinationFolder = (New-Item -Path $Destination -Name $SourceFileName -ItemType Directory).FullName
		$DestinationFolder = (New-Item -Path $Destination -Name $SourceFileName -ItemType Directory)
		#$Destination = New-Item -Path $Destination -Name $SourceFileName -ItemType Directory
		$Destination = $DestinationPath = $DestinationFolder.FullName
		Write-Host -ForegroundColor Green "CREATED DESTINATION FOLDER:"
		Write-Host -ForegroundColor White "`$DestinationFolder=" -NoNewline
		Write-Host -ForegroundColor Yellow "`"$DestinationFolder`""

		Write-Host -ForegroundColor Cyan "`$DestinationPath=" -NoNewline
		Write-Host -ForegroundColor Yellow "`"$DestinationPath`""
	}



	<# To move all files and folders, including empty ones, with all attributes. 
	 #Note that the source folder will also be deleted.
	 robocopy c:\temp\source c:\temp\destination /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3
	 #>

	 <# ROBOCOPY OPTIONS and SWITCHES:
		*** Copy options: ****

		/s	Copies subdirectories. This option automatically excludes empty directories.
		/e	Copies subdirectories. This option automatically includes empty directories.
		/z	Copies files in restartable mode. In restartable mode, should a file copy be interrupted, robocopy can pick up where it left off rather than recopying the entire file.
		/b	Copies files in backup mode. In backup mode, robocopy overrides file and folder permission settings (ACLs), which might otherwise block access.
		/zb	Copies files in restartable mode. If file access is denied, switches to backup mode.
		/j	Copies using unbuffered I/O (recommended for large files).
		/efsraw	Copies all encrypted files in EFS RAW mode.
		/copy:<copyflags>	Specifies which file properties to copy. The valid values for this option are:
			D - Data
			A - Attributes
			T - Time stamps
			X - Skip alt data streams
			S - NTFS access control list (ACL)
			O - Owner information
			U - Auditing information
		The default value for the /COPY option is DAT (data, attributes, and time stamps). The X flag is ignored if either /B or /ZB is used.
		/dcopy:<copyflags>	Specifies what to copy in directories. The valid values for this option are:
			D - Data
			A - Attributes
			T - Time stamps
			E - Extended attribute
			X - Skip alt data streams
		The default value for this option is DA (data and attributes).
		/sec	Copies files with security (equivalent to /copy:DATS).
		/copyall	Copies all file information (equivalent to /copy:DATSOU).
		/nocopy	Copies no file information (useful with /purge).
		/secfix	Fixes file security on all files, even skipped ones.
		/timfix	Fixes file times on all files, even skipped ones.
		/purge	Deletes destination files and directories that no longer exist in the source. Using this option with the /e option and a destination directory, allows the destination directory security settings to not be overwritten.
		/mir	Mirrors a directory tree (equivalent to /e plus /purge). Using this option with the /e option and a destination directory, overwrites the destination directory security settings.
		/mov	Moves files, and deletes them from the source after they're copied.
		/move	Moves files and directories, and deletes them from the source after they're copied.
		/a+:[RASHCNET]	Adds the specified attributes to copied files. The valid values for this option are:
			R - Read only
			A - Archive
			S - System
			H - Hidden
			C - Compressed
			N - Not content indexed
			E - Encrypted
			T - Temporary
		/a-:[RASHCNETO]	Removes the specified attributes from copied files. The valid values for this option are:
			R - Read only
			A - Archive
			S - System
			H - Hidden
			C - Compressed
			N - Not content indexed
			E - Encrypted
			T - Temporary
			O - Offline
		/create	Creates a directory tree and zero-length files only.
		/fat	Creates destination files by using 8.3 character-length FAT file names only.
		/256	Turns off support for paths longer than 256 characters.
		/mon:<n>	Monitors the source and runs again when more than n changes are detected.
		/mot:<m>	Monitors the source and runs again in m minutes if changes are detected.
		/rh:hhmm-hhmm	Specifies run times when new copies can be started.
		/pf	Checks run times on a per file (not per-pass) basis.
		/ipg:<n>	Specifies the inter-packet gap to free bandwidth on slow lines.
		/sj	Copies junctions (soft-links) to the destination path instead of link targets.
		/sl	Don't follow symbolic links and instead create a copy of the link.
		/mt:<n>	Creates multi-threaded copies with n threads. n must be an integer between 1 and 128. The default value for n is 8. For better performance, redirect your output using /log option.
		The /mt parameter can't be used with the /ipg and /efsraw parameters.

		/nodcopy	Copies no directory info (the default /dcopy:DA is done).
		/nooffload	Copies files without using the Windows Copy Offload mechanism.
		/compress	Requests network compression during file transfer, if applicable.
		/sparse:<y|n>	Enables or disables retaining the sparse state of files during copy process. If no option is selected, it defaults to yes (enabled).
		/noclone	Doesn't attempt block cloning as an optimization.

		
		*** File selection options: ****	
		/a	Copies only files for which the Archive attribute is set.
		/m	Copies only files for which the Archive attribute is set, and resets the Archive attribute.
		/ia:[RASHCNETO]	Includes only files for which any of the specified attributes are set. The valid values for this option are:
		R - Read only
		A - Archive
		S - System
		H - Hidden
		C - Compressed
		N - Not content indexed
		E - Encrypted
		T - Temporary
		O - Offline
		/xa:[RASHCNETO]	Excludes files for which any of the specified attributes are set. The valid values for this option are:
		R - Read only
		A - Archive
		S - System
		H - Hidden
		C - Compressed
		N - Not content indexed
		E - Encrypted
		T - Temporary
		O - Offline
		/xf <filename>[ ...]	Excludes files that match the specified names or paths. Wildcard characters (* and ?) are supported.
		/xd <directory>[ ...]	Excludes directories that match the specified names and paths.
		/xc	Excludes existing files with the same timestamp, but different file sizes.
		/xn	Source directory files newer than the destination are excluded from the copy.
		/xo	Source directory files older than the destination are excluded from the copy.
		/xx	Excludes extra files and directories present in the destination but not the source. Excluding extra files won't delete files from the destination.
		/xl	Excludes "lonely" files and directories present in the source but not the destination. Excluding lonely files prevents any new files from being added to the destination.
		/im	Include modified files (differing change times).
		/is	Includes the same files. Same files are identical in name, size, times, and all attributes.
		/it	Includes "tweaked" files. Tweaked files have the same name, size, and times, but different attributes.
		/max:<n>	Specifies the maximum file size (to exclude files bigger than n bytes).
		/min:<n>	Specifies the minimum file size (to exclude files smaller than n bytes).
		/maxage:<n>	Specifies the maximum file age (to exclude files older than n days or date).
		/minage:<n>	Specifies the minimum file age (exclude files newer than n days or date).
		/maxlad:<n>	Specifies the maximum last access date (excludes files unused since n).
		/minlad:<n>	Specifies the minimum last access date (excludes files used since n) If n is less than 1900, n specifies the number of days. Otherwise, n specifies a date in the format YYYYMMDD.
		/xj	Excludes junction points, which are normally included by default.
		/fft	Assumes FAT file times (two-second precision).
		/dst	Compensates for one-hour DST time differences.
		/xjd	Excludes junction points for directories.
		/xjf	Excludes junction points for files.

		*** Retry options ***
		/r:<n>	Specifies the number of retries on failed copies. The default value of n is 1,000,000 (one million retries).
		/w:<n>	Specifies the wait time between retries, in seconds. The default value of n is 30 (wait time 30 seconds).
		/reg	Saves the values specified in the /r and /w options as default settings in the registry.
		/tbd	Specifies that the system waits for share names to be defined (retry error 67).
		/lfsm	Operate in low free space mode that enables copy, pause, and resume (see Remarks).
		/lfsm:<n>[kmg]	Specifies the floor size in n kilobytes, megabytes, or gigabytes.

		*** Logging options ***
		/l	Specifies that files are to be listed only (and not copied, deleted, or time stamped).
		/x	Reports all extra files, not just the ones that are selected.
		/v	Produces verbose output, and shows all skipped files.
		/ts	Includes source file time stamps in the output.
		/fp	Includes the full path names of the files in the output.
		/bytes	Prints sizes as bytes.
		/ns	Specifies that file sizes aren't to be logged.
		/nc	Specifies that file classes aren't to be logged.
		/nfl	Specifies that file names aren't to be logged.
		/ndl	Specifies that directory names aren't to be logged.
		/np	Specifies that the progress of the copying operation (the number of files or directories copied so far) won't be displayed.
		/eta	Shows the estimated time of arrival (ETA) of the copied files.
		/log:<logfile>	Writes the status output to the log file (overwrites the existing log file).
		/log+:<logfile>	Writes the status output to the log file (appends the output to the existing log file).
		/unilog:<logfile>	Writes the status output to the log file as unicode text (overwrites the existing log file).
		/unilog+:<logfile>	Writes the status output to the log file as Unicode text (appends the output to the existing log file).
		/tee	Writes the status output to the console window, and to the log file.
		/njh	Specifies that there's no job header.
		/njs	Specifies that there's no job summary.
		/unicode	Displays the status output as unicode text.	

		*** Job options ***
		/job:<jobname>	Specifies that parameters are to be derived from the named job file. To run /job:jobname, you must first run the /save:jobname parameter to create the job file.
		/save:<jobname>	Specifies that parameters are to be saved to the named job file. This must be ran before running /job:jobname. All copy, retry, and logging options must be specified before this parameter.
		/quit	Quits after processing command line (to view parameters).
		/nosd	Indicates that no source directory is specified.
		/nodd	Indicates that no destination directory is specified.
		/if	Includes the specified files.

		*** Remarks ***
		Using /PURGE or /MIR on the root directory of the volume formerly caused robocopy to apply the requested operation on files inside the System Volume Information directory as well. 
		This is no longer the case as if either is specified, robocopy will skip any files or directories with that name in the top-level source and destination directories of the copy session.

		Modified files classification applies only when both source and destination filesystems support change timestamps, such as NTFS, 
		and the source and destination files have different change times but are otherwise the same. 
		These files aren't copied by default. Specify /IM to include them.

		The /DCOPY:E flag requests that extended attribute copying should be attempted for directories. 
		Robocopy will continue if a directory's EAs couldn't be copied. This flag isn't included in /COPYALL.

		If either /IoMaxSize or /IoRate are specified, robocopy will enable copy file throttling to reduce system load. 
		Both can be adjusted to optimal values and copy parameters, but the system and robocopy are allowed to adjust them to allowed values as necessary.

		If /Threshold is used, it specifies a minimum file size for engaging throttling. Files below that size won't be throttled. 
		Values for all three parameters can be followed by an optional suffix character such as [KMG] (kilobytes, megabytes, gigabytes).

		Using /LFSM requests robocopy to operate in 'low free space mode'. 
		In this mode, robocopy will pause whenever a file copy would cause the destination volume's free space to go below a 'floor' value. 
		This value can be explicitly specified using /LFSM:n[KMG] flag.

		If /LFSM is specified with no explicit floor value, the floor is set to 10% of the destination volume's size. 
		Low free space mode is incompatible with /MT and /EFSRAW.
		
	 #>
	 #To copy all files and directories (including empty ones) from the source directory to the destination directory, use the following command:
	robocopy $Source $Destination /S /E /COPYALL /DCOPY:DAT /MOVE /R:100 /W:3 /LOG:$LogFile
	#robocopy $Source $Destination /E /COPYALL /COPY:DAT /MOVE /R:100 /W:3 /LOG:$LogFile
	#robocopy $Source $Destination /COPYALL /COPY:DAT /MOVE /R:100 /W:3
	#robocopy $Source $Destination /E /COPYALL /DCOPY:DAT /MOVE /W:3
	
	#robocopy  $Source $Destination /S /E /ETA /COPY:DAT /MOVE 

	$psCommand =  "`n robocopy """ + 
			$Source + "`" """ + 
			$Destination + """ " +
			"/E /COPYALL /DCOPY:DAT  /MOVE /R:100 /W:3 "+ 
			"/LOG:""" +
			$LogFile + "`""     

	Write-Host -ForegroundColor Cyan $psCommand
	
	#explorer $Destination
	#explorer $LogFile

	$today = Get-Date -Format 'MM-dd-yyyy HH:mm:ss'
	Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED 4_RobocopyMoveFiles from $Source to $Destination *****************"
}#Function global:RobocopyMoveFiles

<#
$Source = ""

$Source = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports\ChiefArchitect"
$Destination = "C:\Users\kahopkin\OneDrive - Microsoft\Documents\Flankspeed Exports"

MoveFiles -ParentFolder $Source -BicepFolder $Destination
#>