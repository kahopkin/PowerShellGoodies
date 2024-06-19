
[CmdletBinding()]
Param(
 [switch]$rar,
 [switch]$bulk,
 [switch]$vi,
 [switch]$ncea,
 [switch]$mib, 
 [switch]$bb,
 [switch]$nib
   )

<############################################################################################################
.SYNOPSIS
Get Nessus Information

.DESCRIPTION
This script extracts software/port/vulnerability/scan information from .nessus file and exports to existing Excel spreadsheet.

.EXAMPLE
	.\getnessusinfo.ps1
	This runs the full script

	.\getnessusinfo.ps1 -rar
	This generates RAR report and Scan validation information.

	.\getnessusinfo.ps1 -bulk -rar
	This generates reports for bulk scans (single nessus containing multiple scans)
	
.NOTES
	File Name  : .\getnessusinfo.ps1
	Author     : Justin Manibusan
		
	[CHANGELOG]
	v1.0 - Initial Release
	v1.1 - Added progress bar and support for Windows 10 software verification.  Also added mitigation statements for known vulnerabilities.
	v1.2 - Fixed issue related to vulnerabilites not reporting due to plugins with no Plugin_Results data.
	v1.3 - Fixed issue with ports not enumerating properly.
	v1.4 - updated mitigation statements/approved ports.
	v1.5 - updated Windows 10 Software list.
	v1.6 - Added Operating System and Model information to Nessus Info tab
	v1.7 - Added support for parsing single nessus with multiple scans.  Added ability to generate RAR only report via -rar switch.
		   Added logic for windows/non-windows software/ports. Added new logic for determining valid scans per latest ACAS Best Practice Guide.
	v1.8 - Added ability to generate report for bulk scans via -bulk switch.  Updated Port array to include latest additions from SIB PPSM.
	v1.12 - Fixed parsing of client software.
	v1.14 - Fixed Null errors
	v1.15 - 
	v1.16 - Added support for creating named tables in the output excel file for all worksheets
	v1.17 - IP masking in nessusinfo worksheet and fixed empty rows from being added to nessusinfo table

#>

#	
#set execution policy
#################This changes the PS Console Settings #########################
#$HOST.UI.RawUI.BackgroundColor = "Black"
#$HOST.UI.RawUI.ForegroundColor = "Yellow"
$PSConsole = $HOST.UI.RawUI
$Width = 180
$Height = 52
$BufferSize = $PSConsole.BufferSize
$WindowSize = $PSConsole.WindowSize
$BufferSize.Width = $Width
$WindowSize.Width = $Width
$BufferSize.Height = "3000"
$PSConsole.Buffersize = $BufferSize
$WindowSize = $PSConsole.WindowSize
$WindowSize.Width = $Width
$WindowSize.Height = $Height
$PSConsole.Windowsize = $WindowSize

cls
#########################END PS Console Settings ##############################>

#>

Function check-nessusdates
{
	if ($pluginfeedversiondate -gt $vulnerabilityinfoscanstartdate.AddDays(-5))
	{
		$true
	}
	else 
	{
		$false
	}
}#check-nessusdates


Function get-mitigation
{
	$pluginid = $openfinding.pluginID
	$pubdate = $openfinding.plugin_publication_date
	if ([datetime]$pubdate -gt $vulnerabilityscanstartdate.AddDays(-30)) 
	{
		"Plugin Published within 30 days of Scan Start Date"
	}

	if($openfinding.pluginID -in $mitigatedpluginids) 
	{
		$mitigationstatements.$pluginid
	}
	else
	{
		'Can this be remediated/mitigated?'
	}
}#get-mitigation


Function Get-FileNamenessus($env:userprofile)
{
	
	 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |  Out-Null

	 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{Multiselect = $true}

	 $OpenFileDialog.initialDirectory = $env:userprofile
	 $OpenFileDialog.filter = "$Filter"
	 $OpenFileDialog.ShowHelp = $true
	 $OpenFileDialog.ShowDialog() | Out-Null
	 $OpenFileDialog.filenames
}#Get-FileNamenessus


Function Get-FileNameExcel($env:userprofile)
{    
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |  Out-Null

	$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$OpenFileDialog.initialDirectory = $env:userprofile
	$OpenFileDialog.filter = "$Filterexcel"
	$OpenFileDialog.ShowHelp = $true
	$OpenFileDialog.ShowDialog() | Out-Null
	$OpenFileDialog.filename
}#Get-FileNameExcel


Function check-port 
{
	if ($ncea) 
	{
		check-nceaport
	}
	elseif ($scanportos -match "Microsoft Windows 10 Enterprise") 
	{
		check-win10port
	}
	elseif ($vi) 
	{
		check-viport
	}
	elseif ($mib) 
	{
		check-mibport
	}
	elseif ($bb) 
	{
		check-bbport
	}
	elseif ($nib) 
	{
		check-nibport
	}
	else 
	{
		check-serverport
	}
}#check-port


Function get-service
{
	$service = $scanport.results | where-object {$_.port -match $openport}#

	$serviceoutput = $service | where-object {$_.pluginid -match "34252"} | Select-Object -ExpandProperty plugin_output | Out-String -ErrorAction SilentlyContinue
	$runningservice = $serviceoutput
	$runningservice.Trim() -replace "The Win32 process '",""
}#get-service


Function get-model
{
	if ($modelplugin) 
	{
		$scaninfo.model.plugin_output.split("`r,`n") | select-string Manufacturer,Model | Out-String             
	}
	else {
		$scaninfomodel = "N/A"  
	}
}#get-model


Function check-software
{    
	if ($ncea) 
	{
		check-nceasoft
	}
	elseif ($hostsoftos -match "Microsoft Windows 10 Enterprise") 
	{ 
		check-win10soft
	}
	elseif ($vi) 
	{
		check-visoft
	}
	elseif ($mib) 
	{
		check-mibsoft
	}
	elseif ($bb) 
	{
		check-bbsoft
	}
	else 
	{
		check-serversoft
	}
}#check-software

Function check-win10soft
{
	 if ($software -in $approvedwin10software) 
	 {
		 $portexists
	 }
	 else 
	 {
		 $portnotexists
	 }
 }#check-win10soft


Function check-win10port
{
	if ($openport -in $approvedwin10portarray) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-win10port


Function check-serverport
{
	if ($openport -in $approvedportarray) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-serverport


Function check-serversoft
{
	if ($software -in $approvedsoftware) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-serversoft


Function check-visoft
{
	if ($software -in $approvedvisoft) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-visoft


Function check-viport
{
	if ($openport -in $approvedbbport) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-viport


Function check-bbsoft
{
	if ($software -in $approvedbbsoft) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-bbsoft


Function check-bbport
{
	if ($openport -in $approvedbbport) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-bbport


Function check-mibsoft
{
	if ($software -in $approvedmibsoft) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-mibsoft


Function check-mibport
{
	if ($openport -in $approvedmibport) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-mibport


Function check-nibport
{
	if ($openport -in $approvednibport) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-nibport


Function check-nceasoft
{
	if ($software -in $approvednceasoft) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-nceasoft


Function check-nceaport
{
	if ($openport -in $approvednceaport) 
	{
		$portexists
	}
	else 
	{
		$portnotexists
	}
}#check-nceaport


Function check-authsuccess
{
	if ($scaninfo.authsuccess -eq $null) 
	{
		$noauthsuccess
	}
	else 
	{
		$scaninfo.authsuccess.plugin_output.trim()
	}
}#check-authsuccess


Function check-plugins
{
	if ($pluginlist -contains "117887" -and 
		$pluginlist -contains "19506" -and 
		$pluginlist -notcontains "10919" -and 
		$pluginlist -notcontains "21745" -and 
		$pluginlist -notcontains "110385" -and 
		$pluginlist -notcontains "117885" )
	{
		$ScanGoodLocalChecksEnabled
	}
	else 
	{
		$ScanInvalid
	}
}#check-plugins


Function null-pluginoutput
{
	if ($openfinding.plugin_output -eq $null) 
	{
		$nopluginoutput
	}
	else 
	{
		$openfinding.plugin_output.trim() -replace "10.10","x.x"
	}
}#null-pluginoutput


Function get-vulninfo
{
	#Gathering Critical/High/Medium/Low Open finding information#
	$reports = foreach ($ness in $nessus)
	{
		$scan = New-Object psobject
		$scan | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "hostname"})
		$scan | Add-Member -Type NoteProperty -name "IP" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "host-ip"})
		$scan | Add-Member -Type NoteProperty -name "results" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem)
		$scan | Add-Member -Type NoteProperty -name "severity" -value ($ness.NessusClientData_v2.Report.ReportHost.ReportItem.severity)
		$scan | Add-Member -Type NoteProperty -name "name" -Value ($ness.NessusClientData_v2.report.name)
		$scan | Add-Member -Type NoteProperty -Name "nessus" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "19506"} | Select-Object plugin_output)
		#$scan | Add-Member -Type NoteProperty -name "PluginID" -value ($ness.nessusclientdata_V2.report.reporthost.reportitem.pluginid)
		#$scan | Add-Member -Type NoteProperty -name "riskfactor" -value ($ness.nessusclientdata_V2.report.reporthost.reportitem.risk_factor)
		#$scan | Add-Member -Type NoteProperty -name "pluginname" -value ($ness.NessusClientData_v2.Report.ReportHost.ReportItem.pluginname)
		$vulstartdate = $scan.nessus.plugin_output.split("`r,`n") | Select-String "scan start date"
		$vuldate = $vulstartdate.ToString()
		$vulndate = $vuldate.Split(":")[1].trim().substring(0,10).split(" ")[0]
		$vulnerabilityscanstartdate = [datetime]$vulndate

		$openfindings = $scan.results
		foreach ($openfinding in $openfindings)
		{
			if($openfinding.severity -notmatch "0")
			{
				[PSCustomObject]
				@{
					ScanName = $scan.name
					PluginID = $openfinding.pluginID
					PluginName = $openfinding.pluginname
					Risk = $openfinding.risk_factor
					Hostname = $scan.hostname.'#text' -replace ".dsdev.oconusdev.navy.mil",""
					IP = $scan.ip.'#text' -replace "10.10","x.x"
					#IP = $scan.ip -replace "10.10","x.x"
					Synopsis = $openfinding.synopsis
					Description = $openfinding.description
					Port = $openfinding.port
					PluginOutput = null-pluginoutput
					Solution = $openfinding.solution
					STIGSeverity = $openfinding.stig_severity
					PluginPublicationDate = $openfinding.plugin_publication_date
					MitigationStatement = get-mitigation
				}#[PSCustomObject]
			}#if($openfinding.severity -notmatch "0")
		}#foreach ($openfinding in $openfindings)
	}#$reports = foreach ($ness in $nessus)

	#Create RAR tab in Excel spreadsheet if it does not already exist
	$WorksheetName = 'RAR'
	$TableName = 'RARTable'
	
	$ws = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $RARTableHeaders
   
	$Cells = ExcelWorkSheet.Cells
	$Row = 1
	$Col = 1
	 
	
	#Add the results from the nessus files to RAR tab
	$initalrow = $row
	foreach ($report in $reports)
	{   
		$row++
		$col = 1
		$Cells.Item($Row,$Col) = $report.ScanName
		$col++
		$cells.Item($row,$col) = $report.pluginid
		$col++
		$cells.Item($row,$col) = $report.pluginname
		$col++
		$cells.Item($row,$col) = $report.risk
		$col++
		$cells.Item($row,$col) = $report.hostname
		$col++
		$cells.Item($row,$col) = $report.ip
		$col++
		$cells.Item($row,$col) = $report.synopsis
		$col++
		$cells.Item($row,$col) = $report.Description
		$col++
		$cells.Item($row,$col) = $report.port
		$col++
		$cells.Item($row,$col) = $report.pluginoutput
		$col++
		$cells.Item($row,$col) = $report.solution
		$col++
		$cells.Item($row,$col) = $report.STIGSeverity
		$col++
		$cells.Item($row,$col) = $report.pluginPublicationDate
		$col++
		$cells.Item($row,$col) = $report.mitigationstatement
   

		#Check to see if space is near empty and use appropriate background colors
		$range = $ws.Range(("A{0}"  -f $row),("N{0}"  -f $row))
		#$range.Select() | Out-Null

		#Determine if disk needs to be flagged for warning or critical alert
		If ($report.risk -match "Critical") 
		{
			#Critical threshold 
			$range.Interior.ColorIndex = 7
		}
		ElseIf ($report.risk -match "High") 
		{
			#Warning threshold 
			$range.Interior.ColorIndex = 45
		}
		ElseIf ($report.risk -match "Medium")
		{
			#Medium threshold
			$range.Interior.ColorIndex = 44
		}
		ElseIf ($report.risk -match "Low")
		{
			#Low threshold
			$range.Interior.ColorIndex = 34
		}
  
		If ($report.mitigationstatement -notmatch "Can this be remediated/mitigated?")
		{
			$range.Interior.ColorIndex = 15
		}
	}#foreach ($report in $reports)

	#Formatting Excel
	$ws.Rows.RowHeight = 30
	$ws.Rows("1").RowHeight = 35
	$wsheaderrange = $ws.range("A1:N1")
	#$wsheaderrange.AutoFilter() | Out-Null
	$ws.columns.Item("A:N").EntireColumn.AutoFit() | out-null
	$ws.columns.Item(3).columnWidth = 50
	$ws.columns.Item(3).wrapText = $true
	$ws.columns.Item(4).columnWidth = 15
	$ws.columns.Item(4).Font.Bold = $true
	#$ws.columns.Item(5).columnWidth = 60
	#$ws.columns.Item(5).wrapText = $true
	$ws.columns.Item(7).columnWidth = 60
	$ws.columns.Item(7).wrapText = $true
	$ws.columns.Item(8).columnWidth = 60
	$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(11).columnWidth = 60
	$ws.columns.Item(11).wrapText = $true
	$ws.columns.Item(14).columnWidth = 60
	$ws.columns.Item(14).wrapText = $true
	#$ws.columns.Item(8).columnWidth = 50
	#$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(10).columnWidth = 50
	$ws.columns.Item(10).wrapText = $true
	#$ws.columns.Item(11).columnWidth = 40
	#$ws.columns.Item(11).Font.Bold= $true
	#Add Border to RAR tab
	$dataRange = $ws.Range(("A{0}" -f $initalRow),("N{0}" -f $row))
	7..12 | ForEach{
		$dataRange.Borders.Item($_).LineStyle = 1
		$dataRange.Borders.Item($_).Weight = 2
	}#7..12 ForEach
}#get-vulninfo


Function get-portinfo
{
	$portsummary = foreach ($ness in $nessus)
	{
		$portoper = $ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "operating-system"}

		$portos = $portoper.'#text'

		if ($portos -like "*Microsoft Windows*")
		{
			$scanport = New-Object psobject
			$scanport | Add-Member -Type NoteProperty -name "results" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem)
			$scanport | Add-Member -Type NoteProperty -Name "Ports" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "34220"} | Select-Object Port) -Force
			$scanport | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "host-fqdn"})
			$scanport | Add-Member -Type NoteProperty -name "name" -Value ($ness.NessusClientData_v2.report.name)
			$scanport | Add-Member -Type NoteProperty -name "OS" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "operating-system"})

			$scanportos = $scanport.os.'#text'
			$openports = $scanport.ports.port
			foreach ($openport in $openports)
			{
				if($openport -ne "0")
				{
					[PSCustomObject]@{
						ScanName = $scanport.name
						OpenPorts = $openport
						Approved = check-port
						Service = get-service
					}
				}#if ($openport -ne "0")
			}#foreach ($openport in $openports)
		}#if ($portos -like "*Microsoft Windows*")
		elseif ($portos -like "*Ubuntu*")
		{
			$scanport = New-Object psobject
			$scanport | Add-Member -Type NoteProperty -name "results" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem)
			$scanport | Add-Member -Type NoteProperty -Name "Ports" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "14272"}| Select-Object Port) -Force
			$scanport | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "host-fqdn"})
			$scanport | Add-Member -Type NoteProperty -name "name" -Value ($ness.NessusClientData_v2.report.name)
			$scanport | Add-Member -Type NoteProperty -name "OS" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "operating-system"})

			$scanportos = $scanport.os.'#text'
			$openports = $scanport.ports.port
			foreach ($openport in $openports)
			{
				if ($openport -ne "0")
				{
					[PSCustomObject]@{
						ScanName = $scanport.name
						OpenPorts = $openport
						Approved = check-port
						Service = get-service
					}
				}#if ($openport -ne "0")
			}#foreach ($openport in $openports)
		}#elseif ($portos -like "*Ubuntu*")
		else 
		{
			$scanport = New-Object psobject
			$scanport | Add-Member -Type NoteProperty -name "results" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem)
			$scanport | Add-Member -Type NoteProperty -Name "Ports" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "11219"} | Select-Object Port) -Force
			$scanport | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "host-fqdn"})
			$scanport | Add-Member -Type NoteProperty -name "name" -Value ($ness.NessusClientData_v2.report.name)
			$scanport | Add-Member -Type NoteProperty -name "OS" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "operating-system"})

			$scanportos = $scanport.os.'#text'
			$openports = $scanport.ports.port
			foreach ($openport in $openports)
			{
				if ($openport -ne "0")
				{
					[PSCustomObject]@{
						ScanName = $scanport.name
						OpenPorts = $openport
						Approved = check-port
						Service = get-service
					}#[PSCustomObject]
				}#if ($openport -ne "0")
			}#foreach ($openport in $openports)
		}#else
	}#$portsummary = foreach ($ness in $nessus)

	#Check to see if Ports tab exist, if it does not, create a Ports tab
	$WorksheetName = 'Ports'
	$TableName = 'PortsTable'
	
	$wsports = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $PortsTableHeaders
 
	$cells = $cellsp = $wsports.Cells
	$row = $rowp = 1
	$col = $colp = 1

	$initialrowp = $rowp
	foreach ($portsum in $portsummary)
	{
		$rowp++
		$colp = 1
		$cellsp.Item($rowp,$colp) = $portsum.ScanName
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.openports
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.approved
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.service

		$rangep = $wsports.Range(("A{0}"  -f $rowp),("D{0}"  -f $rowp))
		#  $rangep.Select() | Out-Null

		#Determine if disk needs to be flagged for warning or critical alert
		If ($portsum.Approved -eq "Approved") 
		{
			#Approved 
			$rangep.Interior.ColorIndex = 35
		}
		Elseif ($portsum.Approved -eq "Not Approved") 
		{
			#Warning threshold 
			$rangep.Interior.ColorIndex = 6
		}
	}#foreach ($portsum in $portsummary)

	#Formatting Excel
	$wsports.columns.Item(1).wrapText = $false
	$wsports.Columns.Item(2).wrapText = $false
	$wsports.Columns.Item(4).wrapText = $true
	$wsports.Rows.RowHeight = 15
	$wsports.rows("1").RowHeight = 25
	$wsportsrange = $wsports.Range("A1:D1")
	#$wsportsrange.autofilter() | Out-Null
	$wsports.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null
	#Add Borders to spreadsheet
	$datarangeport = $wsports.Range(("A{0}" -f $initialrowp),("D{0}" -f $rowp))
	7..12 | foreach{
		$datarangeport.Borders.Item($_).LineStyle = 1
		$datarangeport.Borders.Item($_).Weight = 2 
	}#7..12 | foreach
}#get-portinfo


Function get-softinfo
{
	$softwaresummary = foreach ($ness in $nessus)
	{
		$softoper = $ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "operating-system"}

		$softos = $softoper.'#text'

		if ($softos -like "*Microsoft Windows*")
		{
			$scansoft = New-Object psobject
			$scansoft | Add-Member -Type NoteProperty -name "software" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "20811"} | Select-Object -ExpandProperty plugin_output) -Force
			$scansoft | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "host-fqdn"})
			$scansoft | Add-Member -Type NoteProperty -name "OS" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "operating-system"})
			$scansoft | Add-Member -Type NoteProperty -name "name" -Value ($ness.NessusClientData_v2.report.name)

			$hostsoftos = $scansoft.os.'#text'
			$hostnamesofts = $scansoft.hostname.'#text' -replace ".dsdev.oconusdev.navy.mil",""
			$softwarelist = $scansoft.software -replace "\[installed.*\]","" -replace "the following updates are installed :","" -replace "The following software are installed on the remote host :","" -replace ":",""
			$softwarelist2 = $softwarelist
			$softwarelist3 = $softwarelist2.Trim()
			$softwarelist4 = $softwarelist3.split("`r,`n") | ForEach-Object {$_.trim()}
			$softwarelist5 = $softwarelist4 | where-object {$_ -ne ""}

			foreach ($software in $softwarelist5)
			{                
				[PSCustomObject]@{
					ScanName = $scansoft.name
					Software = $software
					Approved = check-software
				}#PSCustomObject
			}#foreach ($software in $softwarelist5)
		}#if ($softos -like "*Microsoft Windows*")
		else 
		{
			$scansoftname = $ness.NessusClientData_v2.report.name
			[PSCustomObject]@{
				ScanName = $scansoftname
				Software = "None"
				Approved = "NA"
			}#PSCustomObject
		}#else
	}#$softwaresummary = foreach ($ness in $nessus)

	
	$WorksheetName = 'SoftwareList'
	$TableName = 'SoftwareListTable'
	#Create Headers for SoftwareList tab
	
	$wssoft = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $SoftwareListTable 

	$cellss = $cells = $wssoft.Cells
	$row = $rowso = 1
	$col = $colso = 1

	#Populate softwarelist tab
	$initialrowso = $rowso
	foreach ($softsum in $softwaresummary)
	{
		$rowso++
		$colso = 1
		$cellss.Item($rowso,$colso) = $softsum.ScanName
		$colso++
		$cellss.Item($rowso,$colso) = $softsum.software
		$colso++
		$cellss.Item($rowso,$colso) = $softsum.approved
		#$colso++
		#$cellss.Item($rowp,$colp) = $softsum.missing
		$rangesoft = $wssoft.Range(("A{0}"  -f $rowso),("C{0}"  -f $rowso))
		If ($softsum.Approved -eq "Approved") 
		{
			#Approved 
			$rangesoft.Interior.ColorIndex = 35
		}
		Elseif ($softsum.Approved -eq "Not Approved") 
		{
			#Warning threshold 
			$rangesoft.Interior.ColorIndex = 6
		}

		$wssoft.rows("1").RowHeight = 25
		$wssoftrange = $wssoft.Range("A1:C1")
		#$wssoftrange.AutoFilter() | Out-Null
		$wssoft.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null
		$datarangesoft = $wssoft.Range(("A{0}" -f $initialrowso),("C{0}" -f $rowso))
		7..12 | foreach{
			$datarangesoft.Borders.Item($_).LineStyle = 1
			$datarangesoft.Borders.Item($_).Weight = 2
		}#7..12 | foreach 
	}#foreach ($softsum in $softwaresummary)
}#get-softinfo


Function get-nessinfo
{
	$nessusinfo = foreach ($ness in $nessus)
	{
		$scaninfo = New-Object psobject
		$scaninfo | Add-Member -Type NoteProperty -name "results" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem)
		$scaninfo | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "hostname"})
		$scaninfo | Add-Member -Type NoteProperty -name "IP" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "host-ip"})
		$scaninfo | Add-Member -Type NoteProperty -Name "nessus" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "19506"} | Select-Object plugin_output) -ErrorAction SilentlyContinue
		$scaninfo | Add-Member -Type NoteProperty -name "plugins" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem.pluginid)
		$scaninfo | Add-Member -Type NoteProperty -name "AuthSuccess" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "117887"})
		$scaninfo | Add-Member -Type NoteProperty -Name "plugin19506" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "19506"}) -ErrorAction SilentlyContinue
		$scaninfo | Add-Member -Type NoteProperty -name "plugin17887" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "117887"}) -ErrorAction SilentlyContinue
		$scaninfo | Add-Member -Type NoteProperty -name "plugin17886" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "117886"}) -ErrorAction SilentlyContinue
		$scaninfo | Add-Member -Type NoteProperty -name "model" -Value ($ness.NessusClientData_v2.report.reporthost.ReportItem | where-object {$_.pluginid -match "24270"}) -ErrorAction SilentlyContinue
		$scaninfo | Add-Member -Type NoteProperty -name "name" -Value ($ness.NessusClientData_v2.report.name)
		$scaninfo | Add-Member -Type NoteProperty -name "policy" -Value ($ness.NessusClientData_v2.Policy.policyName)
		$scaninfo | Add-Member -Type NoteProperty -name "OS" -Value ($ness.NessusClientData_v2.report.reporthost.hostproperties.tag | where-object {$_.name -eq "operating-system"})

		$pluginlist = $scaninfo.plugins

		#IF($Array -contains "Number" -AND $Array -contains "Number" -AND $Array -notcontains "Number" - and $Array -notcontains "Number" - and $Array -notcontains "Number" )

		#$19506 = $scaninfo.nessus
		$scaninfohost = $scaninfo.Hostname.'#text'
		$scaninfoip = $scaninfo.ip.'#text' -replace "10.10","x.x"
		#$scaninfoip = $scaninfo.ip -replace "10.10","x.x"
		$scaninfohostos = $scaninfo.os.'#text'
		#$scaninfomodel = $scaninfo.model.plugin_output.split("`r,`n") | select-string Manufacturer,Model -ErrorAction SilentlyContinue | Out-String 
		$credentialscan = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "credentialed_scan"
		$cred = $credentialscan.ToString()
		$pluginfeedversion = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "plugin feed version"
		$pluginfeed = $pluginfeedversion.ToString()
		$scanstartdate = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "scan start date"
		$scandate = $scanstartdate.ToString()
		$vulinfostartdate = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "scan start date"
		$vulinfodate = $vulinfostartdate.ToString()
		$vulninfodate = $vulinfodate.Split(":")[1].trim().substring(0,10).split(" ")[0]
		$vulnerabilityinfoscanstartdate = [datetime]$vulninfodate
		$feedstartdate = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "plugin feed version"
		$feeddate = $feedstartdate.ToString()
		$feedate = $feeddate.Split(":")[1].trim().Substring(0,8)
		$feedate = [datetime]::ParseExact($feedate,'yyyyMMdd',$null)
		$feedate = $feedate.tostring("yyyy-MM-dd")
		$pluginfeedversiondate = [datetime]$feedate

		[PSCustomObject]@{
			Hostname = $scaninfohost
			IP = $scaninfoip
			ScanPolicy = $scaninfo.policy
			Credentialed = $cred
			Pluginfeed = $pluginfeedversiondate
			ScanStartDate = $vulnerabilityinfoscanstartdate
			AuthSuccess = check-authsuccess
			ValidScan = check-nessusdates
			OperatingSystem = $scaninfohostos
			Model = get-model
			Plugins = check-plugins
		}#[PSCustomObject]

	}#$nessusinfo = foreach ($ness in $nessus)

	# Set variables for the worksheet cells, and for navigation
	$WorksheetName = 'nessusinfo'
	$TableName = 'nessusinfoTable'
	
	ExcelWorkSheet =  = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $Headers 

	$ExcelCells = ExcelWorkSheet.Cells
	$row = 1
	$col = 1

	 = $row
	foreach ($nessusin in $nessusinfo)
	{
		If($nessusin.Hostname.length -gt 0)
		{
			$row++
			$col = 1

			$ExcelCells.Item($row,$col) = $nessusin.Hostname
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.IP
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Credentialed
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.pluginfeed
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.scanstartdate
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.AuthSuccess
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.ValidScan
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.OperatingSystem   
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Model
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Plugins

			$rangeness = ExcelWorkSheet.Range(("A{0}"  -f $row),("K{0}"  -f $row))
			If ($nessusin.AuthSuccess -ne $false -and $nessusin.ValidScan -eq $true) 
			{
				$rangeness.Interior.ColorIndex = 35 
			}
			else 
			{
				$rangeness.Interior.ColorIndex = 3
			}

			#Add Borders to sheet
			$datarangenessus = ExcelWorkSheet.Range(("A{0}" -f $InitialRow),("K{0}" -f $row))
			7..12 | foreach 
			{
				$datarangenessus.Borders.Item($_).LineStyle = 1
				$datarangenessus.Borders.Item($_).Weight = 2 
			}#7..12 | foreach      
		}#If($nessusin.Hostname -ne "")
	}#foreach ($nessusin in $nessusinfo)

	#formatting excel
	#ExcelWorkSheet.Rows.RowHeight = 120
	ExcelWorkSheet.rows("1").RowHeight = 25
	$wsnessusrange = ExcelWorkSheet.range("A1:K1")
	ExcelWorkSheet.columns.Item(7).columnWidth = 60
	ExcelWorkSheet.columns.Item(7).wrapText = $true
	#$wsnessusrange.AutoFilter() | Out-Null
	ExcelWorkSheet.Columns.Item("A:J").EntireColumn.AutoFit() | Out-Null
}#get-nessinfo


Function get-vulninfobulk
{
	#Gathering Critical/High/Medium/Low Open finding information#
	$uniquenessus = $nessusscan | sort-object name -Unique
	$reports = foreach ($ness in $uniquenessus)
	{
		$scan = New-Object psobject
		$scan | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "hostname"})
		$scan | Add-Member -Type NoteProperty -name "IP" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "host-ip"})
		$scan | Add-Member -Type NoteProperty -name "results" -Value ($ness.ReportItem)
		$scan | Add-Member -Type NoteProperty -name "severity" -value ($ness.ReportItem.severity)
		$scan | Add-Member -Type NoteProperty -name "name" -Value ($nessus.NessusClientData_v2.report.name)
		$scan | Add-Member -Type NoteProperty -Name "nessus" -Value ($ness.ReportItem | where-object {$_.pluginid -match "19506"} | Select-Object plugin_output)
		#$scan | Add-Member -Type NoteProperty -name "PluginID" -value ($ness.nessusclientdata_V2.report.reporthost.reportitem.pluginid)
		#$scan | Add-Member -Type NoteProperty -name "riskfactor" -value ($ness.nessusclientdata_V2.report.reporthost.reportitem.risk_factor)
		#$scan | Add-Member -Type NoteProperty -name "pluginname" -value ($ness.NessusClientData_v2.Report.ReportHost.ReportItem.pluginname)
		$vulstartdate = $scan.nessus.plugin_output.split("`r,`n") | Select-String "scan start date"
		$vuldate = $vulstartdate.ToString()
		$vulndate = $vuldate.Split(":")[1].trim().substring(0,10).split(" ")[0]
		$vulnerabilityscanstartdate = [datetime]$vulndate

		$openfindings = $scan.results
		foreach ($openfinding in $openfindings)
		{
			if($openfinding.severity -notmatch "0")
			{
				[PSCustomObject]@{
					ScanName = $scan.name
					PluginID = $openfinding.pluginID
					PluginName = $openfinding.pluginname
					Risk = $openfinding.risk_factor
					Hostname = $scan.hostname.'#text' -replace ".dsdev.oconusdev.navy.mil",""
					IP = $scan.ip.'#text' -replace "10.10","x.x"
					#IP = $scan.ip -replace "10.10","x.x"
					Synopsis = $openfinding.synopsis
					Description = $openfinding.description
					Port = $openfinding.port
					PluginOutput = null-pluginoutput
					Solution = $openfinding.solution
					STIGSeverity = $openfinding.stig_severity
					PluginPublicationDate = $openfinding.plugin_publication_date
					MitigationStatement = get-mitigation
				}#PSCustomObject		
			}#if($openfinding.severity -notmatch "0")
		}#foreach ($openfinding in $openfindings)
	}#

	#Create RAR tab in Excel spreadsheet if it does not already exist
	$WorksheetName = 'RAR'
	$TableName = 'RARTable'
	
	$ws = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $RARTableHeaders 
	$cells = $ws.Cells
	$row = 1
	$col = 1
		
	#Add the results from the nessus files to RAR tab
	$initalrow = $row
	foreach ($report in $reports)
	{
		$row++
		$col = 1
		$cells.Item($row,$col) = $report.ScanName
		$col++
		$cells.Item($row,$col) = $report.pluginid
		$col++
		$cells.Item($row,$col) = $report.pluginname
		$col++
		$cells.Item($row,$col) = $report.risk
		$col++
		$cells.Item($row,$col) = $report.hostname
		$col++
		$cells.Item($row,$col) = $report.ip
		$col++
		$cells.Item($row,$col) = $report.synopsis
		$col++
		$cells.Item($row,$col) = $report.Description
		$col++
		$cells.Item($row,$col) = $report.port
		$col++
		$cells.Item($row,$col) = $report.pluginoutput
		$col++
		$cells.Item($row,$col) = $report.solution
		$col++
		$cells.Item($row,$col) = $report.STIGSeverity
		$col++
		$cells.Item($row,$col) = $report.pluginPublicationDate
		$col++
		$cells.Item($row,$col) = $report.mitigationstatement
   

		#Check to see if space is near empty and use appropriate background colors
		$range = $ws.Range(("A{0}"  -f $row),("N{0}"  -f $row))
		#$range.Select() | Out-Null

		#Determine if disk needs to be flagged for warning or critical alert
		If ($report.risk -match "Critical") 
		{
			#Critical threshold - Magenta
			$range.Interior.ColorIndex = 7
		}
		ElseIf ($report.risk -match "High") 
		{
			#Warning threshold = Olive
			$range.Interior.ColorIndex = 45
		}
		ElseIf ($report.risk -match "Medium")
		{
			#Medium threshold = Olive-1
			$range.Interior.ColorIndex = 44
		}
		ElseIf ($report.risk -match "Low")
		{
			#Low threshold = Cyan
			$range.Interior.ColorIndex = 34
		}
  
		If ($report.mitigationstatement -notmatch "Can this be remediated/mitigated?")
		{
			#Light Gray
			$range.Interior.ColorIndex = 15
		}
	}#foreach ($report in $reports)

	#Formatting Excel
	#$ws.Rows.RowHeight = 30
	$ws.Rows("1").RowHeight = 25
	$wsheaderrange = $ws.range("A1:N1")
	#$wsheaderrange.AutoFilter() | Out-Null
	$ws.columns.Item("A:N").EntireColumn.AutoFit() | out-null
	$ws.columns.Item(3).columnWidth = 50
	$ws.columns.Item(3).wrapText = $true
	$ws.columns.Item(4).columnWidth = 15
	$ws.columns.Item(4).Font.Bold = $true
	#$ws.columns.Item(5).columnWidth = 60
	#$ws.columns.Item(5).wrapText = $true
	$ws.columns.Item(7).columnWidth = 60
	$ws.columns.Item(7).wrapText = $true
	$ws.columns.Item(8).columnWidth = 60
	$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(11).columnWidth = 60
	$ws.columns.Item(11).wrapText = $true
	$ws.columns.Item(14).columnWidth = 60
	$ws.columns.Item(14).wrapText = $true
	#$ws.columns.Item(8).columnWidth = 50
	#$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(10).columnWidth = 50
	$ws.columns.Item(10).wrapText = $true
	#$ws.columns.Item(11).columnWidth = 40
	#$ws.columns.Item(11).Font.Bold = $true
	#Add Border to RAR tab
	$dataRange = $ws.Range(("A{0}" -f $initalRow),("N{0}" -f $row))
	7..12 | ForEach{
		$dataRange.Borders.Item($_).LineStyle = 1
		$dataRange.Borders.Item($_).Weight = 2
	}#7..12 ForEach 
}#get-vulninfobulk


Function get-portinfobulk
{
	$uniquenessus = $nessusscan | sort-object name -Unique
	$portsummary = foreach ($ness in $uniquenessus)
	{
		$scanport = New-Object psobject
		$scanport | Add-Member -Type NoteProperty -name "results" -Value ($ness.ReportItem)
		$scanport | Add-Member -Type NoteProperty -Name "Ports" -Value ($ness.ReportItem | where-object {$_.pluginid -match "34220"} | Select-Object Port) -Force
		$scanport | Add-Member -Type NoteProperty -Name "Syn" -Value ($ness.ReportItem | where-object {$_.pluginid -match "11219"} | Select-Object Port) -Force
		$scanport | Add-Member -Type NoteProperty -Name "netstat" -Value ($ness.ReportItem | where-object {$_.pluginid -match "14272"} | Select-Object Port) -Force
		$scanport | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "host-fqdn"})
		$scanport | Add-Member -Type NoteProperty -name "name" -Value ($nessus.NessusClientData_v2.report.name)
		$scanport | Add-Member -Type NoteProperty -name "OS" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "operating-system"})
		$porthost = $scanport.Hostname.'#text' -replace ".baseline.smit-th.com",""
		$windowsports = $scanport.ports
		$synports = $scanport.syn
		$netports = $scanport.netstat

		$scanportos = $scanport.os.'#text'
		if ($windowsports) 
		{
			$openports = $windowsports
		}

		if ($synports) 
		{
			$openports = $synports
		}

		if ($netports) 
		{
			$openports = $netports
		}



		foreach ($openport in $openports)
		{
			if($openport -ne "0")
			{
				[PSCustomObject]@{
					ScanName = $porthost
					OpenPorts = $openport
					Approved = check-port
					Service = get-service
				}
			}#if($openport -ne "0")
		}#foreach ($openport in $openports)
	}#$portsummary = foreach ($ness in $uniquenessus)
	
	#Check to see if Ports tab exist, if it does not, create a Ports tab
	$WorksheetName = 'Ports'
	$TableName = 'PortsTable'
	#Create Headers for Ports tab
	
	$wsports = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $PortsTableHeaders 

	$cellsp = $wsports.Cells
	$row = $rowp = 1
	$col = $colp = 1
		 
	$initialrowp = $rowp
	foreach ($portsum in $portsummary)
	{
		$rowp++
		$colp = 1
		$cellsp.Item($rowp,$colp) = $portsum.ScanName
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.openports
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.approved
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.service

		$rangep = $wsports.Range(("A{0}"  -f $rowp),("D{0}"  -f $rowp))
		#  $rangep.Select() | Out-Null

		#Detrmine if disk needs to be flagged for warning or critical alert
		If ($portsum.Approved -eq "Approved") 
		{
			#Approved gray
			$rangep.Interior.ColorIndex = 35
		}
		Elseif ($portsum.Approved -eq "Not Approved") 
		{
			#Warning threshold = Yellow
			$rangep.Interior.ColorIndex = 6
		}
	}#foreach ($portsum in $portsummary)

	#Formatting Excel
	$wsports.columns.Item(1).wrapText = $false
	$wsports.Columns.Item(2).wrapText = $false
	$wsports.Columns.Item(4).wrapText = $true
	$wsports.Rows.RowHeight = 15
	$wsports.rows("1").RowHeight = 25
	$wsportsrange = $wsports.Range("A1:D1")
	#$wsportsrange.autofilter() | Out-Null
	$wsports.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null
	#Add Borders to spreadsheet
	$datarangeport = $wsports.Range(("A{0}" -f $initialrowp),("D{0}" -f $rowp))
	7..12 | foreach{
		$datarangeport.Borders.Item($_).LineStyle = 1
		$datarangeport.Borders.Item($_).Weight = 2 
	}#7..12 foreach 
}#get-portinfobulk


Function get-softinfobulk
{
	$uniquenessus = $nessusscan | sort-object name -Unique
	$softwaresummary = foreach ($ness in $uniquenessus)
	{
		$shostname = $ness.hostproperties.tag | where-object {$_.name -eq "host-ip"} | Select-Object "#text" -ErrorAction SilentlyContinue
		$shost = $shostname.'#text'
		$nsoft = $ness.ReportItem | where-object {$_.pluginid -match "20811"} -ErrorAction SilentlyContinue

		$scansoft = New-Object psobject
		$scansoft | Add-Member -Type NoteProperty -name "software" -Value ($ness.ReportItem | where-object {$_.pluginid -match "20811"} | Select-Object -ExpandProperty plugin_output) -Force
		$scansoft | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "host-fqdn"})
		$scansoft | Add-Member -Type NoteProperty -name "OS" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "operating-system"})
		$scansoft | Add-Member -Type NoteProperty -name "name" -Value ($nessus.NessusClientData_v2.report.name)
		$scansoft
		$hostsoftos = $scansoft.os.'#text'
		$hostnamesofts = $scansoft.hostname.'#text' -replace ".baseline.smit-th.com",""
		$softwarelist = $scansoft.software -replace "\[installed.*\]","" -replace "the following updates are installed :","" -replace "The following software are installed on the remote host :","" -replace ":",""
		#$softwarelist2 = $softwarelist.Split(":")[1]
		$softwarelist3 = $softwarelist.Trim()
		$softwarelist4 = $softwarelist3.split("`r,`n") | ForEach-Object {$_.trim()}

		$softwarelist5 = $softwarelist4 | where-object {$_ -ne ""}

		foreach($software in $softwarelist5)
		{
				
			[PSCustomObject]@{
				ScanName = $hostnamesofts
				Software = $software
				Approved = check-software
			}
		}#foreach($software in $softwarelist5)
	}#$softwaresummary = foreach ($ness in $uniquenessus)

	#Create softwarelist tab in excel if it does not exist
	$WorksheetName = 'SoftwareList'
	$TableName = 'SoftwareListTable'
	#Create Headers for SoftwareList tab
	
	$wssoft = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $SoftwareListTable 

	$cellss = $wssoft.Cells
	$row = $rowso = 1
	$col = $colso = 1
	
	#Populate softwarelist tab
	$initialrowso = $rowso
	foreach ($softsum in $softwaresummary)
	{
		$rowso++
		$colso = 1
		$cellss.Item($rowso,$colso) = $softsum.ScanName
		$colso++
		$cellss.Item($rowso,$colso) = $softsum.software
		$colso++
		$cellss.Item($rowso,$colso) = $softsum.approved
		#$colso++
		#$cellss.Item($rowp,$colp) = $softsum.missing
		$rangesoft = $wssoft.Range(("A{0}"  -f $rowso),("C{0}"  -f $rowso))
		If ($softsum.Approved -eq "Approved") 
		{
			#Approved =gray
			$rangesoft.Interior.ColorIndex = 35
		}
		Elseif ($softsum.Approved -eq "Not Approved") 
		{
			#Warning threshold =Yellow
			$rangesoft.Interior.ColorIndex = 6
		}

		$wssoft.rows("1").RowHeight = 25
		$wssoftrange = $wssoft.Range("A1:C1")
		#$wssoftrange.AutoFilter() | Out-Null
		$wssoft.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null
		$datarangesoft = $wssoft.Range(("A{0}" -f $initialrowso),("C{0}" -f $rowso))
		7..12 | foreach{
			$datarangesoft.Borders.Item($_).LineStyle = 1
			$datarangesoft.Borders.Item($_).Weight = 2
		}#7..12 | foreach 
	}#foreach ($softsum in $softwaresummary)
}#get-softinfobulk


Function get-nessinfobulk
{
	$uniquenessus = $nessusscan | sort-object name -Unique
	$nessusinfo = foreach ($ness in $uniquenessus)
	{
		$nesos = $ness.hostproperties.tag | where-object {$_.name -eq "operating-system"}

		$nesoper = $nesos.'#text'
		$scaninfo = New-Object psobject


		$scaninfo | Add-Member -Type NoteProperty -name "results" -Value ($ness.ReportItem)
		$scaninfo | Add-Member -Type NoteProperty -name "Hostname" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "hostname"})
		$scaninfo | Add-Member -Type NoteProperty -name "IP" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "host-ip"})
		$scaninfo | Add-Member -Type NoteProperty -Name "nessus" -Value ($ness.ReportItem | where-object {$_.pluginid -match "19506"} | Select-Object plugin_output)
		$scaninfo | Add-Member -Type NoteProperty -name "plugins" -Value ($ness.ReportItem.pluginid)
		$scaninfo | Add-Member -Type NoteProperty -name "AuthSuccess" -Value ($ness.ReportItem | where-object {$_.pluginid -match "117887"})
		$scaninfo | Add-Member -Type NoteProperty -Name "plugin19506" -Value ($ness.ReportItem | where-object {$_.pluginid -match "19506"})
		$scaninfo | Add-Member -Type NoteProperty -name "plugin17887" -Value ($ness.ReportItem | where-object {$_.pluginid -match "117887"})
		$scaninfo | Add-Member -Type NoteProperty -name "plugin17886" -Value ($ness.ReportItem | where-object {$_.pluginid -match "117886"})
		$scaninfo | Add-Member -Type NoteProperty -name "model" -Value ($ness.ReportItem | where-object {$_.pluginid -match "24270"})
		$scaninfo | Add-Member -Type NoteProperty -name "name" -Value ($ness.name)
		$scaninfo | Add-Member -Type NoteProperty -name "policy" -Value ($nessus.NessusClientData_v2.Policy.policyName)
		$scaninfo | Add-Member -Type NoteProperty -name "OS" -Value ($ness.hostproperties.tag | where-object {$_.name -eq "operating-system"})

		$modelplugin = $scaninfo.model
		$pluginlist = $scaninfo.plugins

		#IF($Array -contains "Number" -AND $Array -contains "Number" -AND $Array -notcontains "Number" - and $Array -notcontains "Number" - and $Array -notcontains "Number" )

		#$19506 = $scaninfo.nessus
		$scaninfohost = $scaninfo.Hostname.'#text' -replace ".baseline.smit-th.com",""
		#$scaninfoip = $scaninfo.ip.'#text' -replace "10.189","x.x" (replaced with line below)
		$scaninfoip = $scaninfo.ip.'#text' -replace "10.10","x.x" 
		$scaninfohostos = $scaninfo.os.'#text'
		#$scaninfomodel = $scaninfo.model.plugin_output.split("`r,`n") | select-string Manufacturer,Model | Out-String
		$credentialscan = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "credentialed_scan"
		$cred = $credentialscan.ToString()
		$pluginfeedversion = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "plugin feed version"
		$pluginfeed = $pluginfeedversion.ToString()
		$scanstartdate = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "scan start date"
		$scandate = $scanstartdate.ToString()
		$vulinfostartdate = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "scan start date"
		$vulinfodate = $vulinfostartdate.ToString()
		$vulninfodate = $vulinfodate.Split(":")[1].trim().substring(0,10).split(" ")[0]
		$vulnerabilityinfoscanstartdate = [datetime]$vulninfodate
		$feedstartdate = $scaninfo.nessus.plugin_output.split("`r,`n") | Select-String "plugin feed version"
		$feeddate = $feedstartdate.ToString()
		$feedate = $feeddate.Split(":")[1].trim().Substring(0,8)
		$feedate=[datetime]::ParseExact($feedate,'yyyyMMdd',$null)
		$feedate = $feedate.tostring("yyyy-MM-dd")
		$pluginfeedversiondate = [datetime]$feedate

		[PSCustomObject]
		@{
			Hostname = $scaninfohost
			IP = $scaninfoip
			ScanPolicy = $scaninfo.policy
			Credentialed = $cred
			Pluginfeed = $pluginfeedversiondate
			ScanStartDate = $vulnerabilityinfoscanstartdate
			AuthSuccess = check-authsuccess
			ValidScan = check-nessusdates
			OperatingSystem = $scaninfohostos
			Model = get-model
			Plugins = check-plugins
		}

	}#foreach ($ness in $uniquenessus)
		
	# Set variables for the worksheet cells, and for navigation
	$WorksheetName = 'nessusinfo'
	$TableName = 'nessusinfoTable'
	
	ExcelWorkSheet =  = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $Headers 
	$ExcelCells = ExcelWorkSheet.Cells
	$row = 1
	$col = 1
	   
	$InitialRow = $row
	foreach ($nessusin in $nessusinfo)
	{		
		If($nessusin.Hostname.length -gt 0)
		{
			$row++
			$col = 1
		
			$ExcelCells.Item($row,$col) = $nessusin.Hostname
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.IP
			$col++
			$ExcelCells.Item($row,$col) = "No Data"
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Credentialed
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.pluginfeed
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.scanstartdate
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.AuthSuccess
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.ValidScan
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.OperatingSystem   
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Model
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Plugins

			$rangeness = ExcelWorkSheet.Range(("A{0}"  -f $row),("K{0}"  -f $row))
			If ($nessusin.AuthSuccess -ne $false -and $nessusin.ValidScan -eq $true -and $nessusin.Plugins -ne "Invalid Scan.  Review Plugins") 
			{
				$rangeness.Interior.ColorIndex = 35 
			}
			else 
			{
				$rangeness.Interior.ColorIndex = 3
			}

			#Add Borders to sheet
			$datarangenessus = ExcelWorkSheet.Range(("A{0}" -f $InitialRow),("K{0}" -f $row))
			7..12 | foreach{
				$datarangenessus.Borders.Item($_).LineStyle = 1
				$datarangenessus.Borders.Item($_).Weight = 2 
			}     
		}#If($nessusin.Hostname -ne "")		
	}#foreach ($nessusin in $nessusinfo)

	#formatting excel
	#ExcelWorkSheet.Rows.RowHeight = 120
	ExcelWorkSheet.rows("1").RowHeight = 25
	$wsnessusrange = ExcelWorkSheet.range("A1:K1")
	ExcelWorkSheet.columns.Item(7).columnWidth = 60
	ExcelWorkSheet.columns.Item(7).wrapText = $true
	#$wsnessusrange.AutoFilter() | Out-Null
	ExcelWorkSheet.Columns.Item("A:K").EntireColumn.AutoFit() | Out-Null
}#get-nessinfobulk


Function create-rarbulk
{
	### This selects the Excel worksheet that you will import data from ###
	Write-Host "Select nessus file(s)"
	$nessusfiles = Get-FileNamenessus
	Write-Host "Importing Nessus Data"
	$nessus = foreach ($nessusfile in $nessusfiles)
	{ 
		[xml] (Get-Content $nessusfile)
	}#foreach ($nessusfile in $nessusfiles)


	#Check if single scans are included
	foreach ($nes in $nessus)
	{
		$nesscanname = $nes.NessusClientData_v2.Report.name
		$nessucount = $nes.NessusClientData_v2.Report.ReportHost.name
		if ($nessucount.Count -lt 2) 
		{
			throw "Single scan $nesscanname detected, please re-run script on that nessus without the -bulk switch"
		}
		else 
		{
			Write-Host 'No single scans detected, continuing..'
		}
	}#foreach ($nes in $nessus)


	$nessusscan = $nessus.NessusClientData_v2.Report.ReportHost
	#Open the Excel document and pull in the 'RAR' worksheet
	
	$Excel = New-Object -ComObject Excel.Application    
	ExcelWorkSheet = $Excel.Workbooks.Add()

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0
	get-vulninfobulk
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50
	get-nessinfobulk
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100
	cls
	Write-Host "Save Excel File"

	#Close the workbook and exit excel
	ExcelWorkSheet.Close($true)
	$Excel.quit()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-rarbulk


Function create-fullbulk
{
	### This selects the Excel worksheet that you will import data from ###
	Write-Host "Select nessus file(s)"
	$nessusfiles = Get-FileNamenessus
	$nessus = foreach ($nessusfile in $nessusfiles)
	{ 
		[xml] (Get-Content $nessusfile)
	}#foreach ($nessusfile in $nessusfiles)


	#Check if single scans are included
	foreach ($nes in $nessus)
	{
		$nesscanname = $nes.NessusClientData_v2.Report.name
		$nessucount = $nes.NessusClientData_v2.Report.ReportHost.name
		if ($nessucount.Count -lt 2) 
		{
			throw "Single scan $nesscanname detected, please re-run script on that nessus without the -bulk switch"
		}
		else 
		{
			Write-Host 'No single scans detected, continuing..'
		}
	}#foreach ($nes in $nessus)

	$nessusscan = $nessus.NessusClientData_v2.Report.ReportHost
	#Open the Excel document and pull in the 'RAR' worksheet
	#$path = Get-FileNameExcel
	$Excel = New-Object -ComObject Excel.Application
	#ExcelWorkSheet = $Excel.Workbooks.Open($path)
	ExcelWorkSheet = $Excel.Workbooks.Add()

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0    
	
	get-vulninfobulk

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 25
	
	get-portinfobulk    
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50
	
	get-nessinfobulk
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 75
	
	get-softinfobulk
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100
	cls
	Write-Host "Save Excel File"

	#Close the workbook and exit excel
	ExcelWorkSheet.Close($true)
	$Excel.quit()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-fullbulk


Function create-rar
{
	### This selects the Excel worksheet that you will import data from ###
	Write-Host "Select nessus file(s)"
	$nessusfiles = Get-FileNamenessus
	Write-Host "Importing Nessus Data"
	$nessus = foreach ($nessusfile in $nessusfiles)
	{ 
		[xml] (Get-Content $nessusfile)
	}#$nessus = foreach ($nessusfile in $nessusfiles)


	#Check if bulk scans are included
	foreach ($nes in $nessus)
	{
		$nesscanname = $nes.NessusClientData_v2.Report.name
		$nessucount = $nes.NessusClientData_v2.Report.ReportHost.name
		if ($nessucount.Count -gt 1) 
		{
			throw "Bulk Scan $nesscanname detected, please re-run script on that nessus with the -bulk switch"
		}
		else 
		{
			Write-Host 'No bulk scans detected, continuing..'
		}
	}#foreach ($nes in $nessus)

	$nessusscan = $nessus.NessusClientData_v2.Report.ReportHost
	#Open the Excel document and pull in the 'RAR' worksheet
	#$path = Get-FileNameExcel
	$Excel = New-Object -ComObject Excel.Application
	#ExcelWorkSheet = $Excel.Workbooks.Open($path)
	ExcelWorkSheet = $Excel.Workbooks.Add()

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0
	
	get-vulninfo
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50
	
	get-nessinfo
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100
	
	cls
	Write-Host "Save Excel File"


	#Close the workbook and exit excel
	ExcelWorkSheet.Close($true)
	$Excel.quit()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-rar


Function create-full
{
	### This selects the Excel worksheet that you will import data from ###
	Write-Host "Select nessus file(s)"
	$nessusfiles = Get-FileNamenessus
	$nessus = foreach ($nessusfile in $nessusfiles)
	{ 
		[xml] (Get-Content $nessusfile)
	}

	#Check if bulk scans are included
	foreach ($nes in $nessus)
	{
		$nesscanname = $nes.NessusClientData_v2.Report.name
		$nessucount = $nes.NessusClientData_v2.Report.ReportHost.name
		if ($nessucount.Count -gt 1) 
		{
			throw "Bulk Scan $nesscanname detected, please re-run script on that nessus with the -bulk switch"
		}
		else 
		{
			Write-Host 'No bulk scans detected, continuing..'
		}
	}#foreach ($nes in $nessus)

	#Open the Excel document and pull in the 'RAR' worksheet
	#$path = Get-FileNameExcel
	$Excel = New-Object -ComObject Excel.Application
	#ExcelWorkSheet = $Excel.Workbooks.Open($path)
	ExcelWorkSheet = $Excel.Workbooks.Add()
   
	cls
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0
	
	get-vulninfo
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 25
	
	get-portinfo
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50
	
	get-softinfo
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 75
	
	get-nessinfo
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100
	
	cls
	Write-Host "Save Excel File"

	#Close the workbook and exit excel
	ExcelWorkSheet.Close($true)
	$Excel.quit()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-full


Function CreateExcelTable
{
	Param(
		  [Parameter(Mandatory = $false)] [String] $WorksheetName
		, [Parameter(Mandatory = $false)] [String] $TableName
		, [Parameter(Mandatory = $false)] [String[]] $Headers		
	)
	
	If(ExcelWorkSheet -eq $null)
	{
		$Excel = New-Object -ComObject Excel.Application    
		ExcelWorkSheet = $Excel.Workbooks.Add()
	}
	ExcelWorkSheet = ExcelWorkSheet.Worksheets  | Where-Object {$_.Name -eq $WorksheetName}
	$excelWorkSheetCheck = 
	if ((ExcelWorkSheet)) {} 
	else {
		ExcelWorkSheet = ExcelWorkSheet.Worksheets.Add()
		ExcelWorkSheet.Name = $WorksheetName
	}#create new worksheet	

	If($debugFlag){
		$Excel.Visible = $true
		Write-Host -ForegroundColor Cyan "`$excelWorkSheetCheck= `"$excelWorkSheetCheck`""
	}#If($debugFlag) #>
	
	$excelWorkSheetCheck
	ExcelWorkSheet.Cells.Clear() | Out-Null
		
	# Calculate the index of the letter in the alphabet.
	$index = $Headers.Count - 1
	#Write-Host -ForegroundColor White "`$index= "  -NoNewline
	#Write-Host -ForegroundColor Cyan "`"$index`""
	# Get the letter in the alphabet at the specified index.
	$RangeLimit = [char]($index + 65)

	# Display the letter in the alphabet at the specified position. 
	#Write-Host "The letter in the alphabet at position $position is $RangeLimit."	
	
	$UpperRange = "A1:" + $RangeLimit + "1"

	#Write-Host -ForegroundColor White "`$UpperRange= "  -NoNewline
	#Write-Host -ForegroundColor Cyan "`"$UpperRange`""
	$range = ExcelWorkSheet.Range($UpperRange)

	$listObject = ExcelWorkSheet.ListObjects.Add(
						[Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange, 
						$range, 
						$null,
						[Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes,
						$null)

	$listObject.Name = $TableName

	$i = 0
	ForEach($column in $listObject.ListColumns)
	{
		$column.Name = $Headers[$i]			
		$i++
	}

	#style header row
	$cells = ExcelWorkSheet.Cells
	$row = 1
	$col = 1
	
	#Style the headers to the RAR worksheet
	#
	ForEach($headerCell in $Headers)
	{
		$cells.Item($row,$col).Font.Size = "14"
		$cells.Item($row,$col).Font.Bold = $true
		$cells.Item($row,$col).Font.ColorIndex = "1"
		$cells.Item($row,$col).Interior.ColorIndex = "24"
		$cells.HorizontalAlignment = -4108
		$cells.VerticalAlignment = -4160
		$col++
	}
	#>
	return ExcelWorkSheet
}#CreateExcelTable


<#############################
####   DEV FUNCIONS  ###
#############################>

Function get-vulninfoDev
{
	#	
	$FunctionName = "get-vulninfoDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[1786]" 		
	}#If($debugFlag) #> 
	#Create RAR tab in Excel spreadsheet if it does not already exist
	$WorksheetName = 'RAR'
	$TableName = 'RARTable'
	
	$ws = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $RARTableHeaders
	  
	$cells = $ws.Cells
	$row = 1
	$col = 1

	#Add the results from the nessus files to RAR tab
	$initalrow = $row
	#foreach ($report in $reports)
	For($i = 0;  $i -lt $RARTableHeaders.length; $i++)
	{   
		$row++
		$col = 1
		$cells.Item($row,$col) = "report.ScanName"
		$col++
		$cells.Item($row,$col) = "report.pluginid"
		$col++
		$cells.Item($row,$col) = "report.pluginname"
		$col++
		#$cells.Item($row,$col) = "report.risk"
		If($i%2 -eq 0)
		{
			$cells.Item($row,$col) = "Critical"
		}
		Else
		{
			$cells.Item($row,$col) = "High"
		}
		
		If($i%3 -eq 0)
		{
			$cells.Item($row,$col) = "Medium"
		}
		Else
		{
			$cells.Item($row,$col) = "Low"
		}
		$col++
		$cells.Item($row,$col) = "report.hostname"
		$col++
		$cells.Item($row,$col) = "report.ip"
		$col++
		$cells.Item($row,$col) = "report.synopsis"
		$col++
		$cells.Item($row,$col) = "report.Description"
		$col++
		$cells.Item($row,$col) = "report.port"
		$col++
		$cells.Item($row,$col) = "report.pluginoutput"
		$col++
		$cells.Item($row,$col) = "report.solution"
		$col++
		$cells.Item($row,$col) = "report.STIGSeverity"
		$col++
		$cells.Item($row,$col) = "report.pluginPublicationDate"
		$col++
		$cells.Item($row,$col) = "report.mitigationstatement"
   

		#Check to see if space is near empty and use appropriate background colors
		$range = $ws.Range(("A{0}"  -f $row),("N{0}"  -f $row))
		#$range.Select() | Out-Null

		#Determine if disk needs to be flagged for warning or critical alert
		If ($cells.Item($row,$col-10).text -match "Critical") 
		{
			#Critical threshold 
			$range.Interior.ColorIndex = 7
		}
		If ($cells.Item($row,$col-10).text -match "High") 
		{
			#Warning threshold 
			$range.Interior.ColorIndex = 45
		}
		If ($cells.Item($row,$col-10).text -match "Medium")
		{
			#Medium threshold
			$range.Interior.ColorIndex = 44
		}
		If ($cells.Item($row,$col-10).text -match "Low")
		{
			#Low threshold
			$range.Interior.ColorIndex = 34
		}
  
		If ($cells.Item($row,$col).text -notmatch "Can this be remediated/mitigated?")
		{
			$range.Interior.ColorIndex = 15
		}
	}#foreach ($report in $reports)
	

	#Formatting Excel
	$ws.Rows.RowHeight = 30
	$ws.Rows("1").RowHeight = 35
	$wsheaderrange = $ws.range("A1:N1")
	#$wsheaderrange.AutoFilter() | Out-Null
	$ws.columns.Item("A:N").EntireColumn.AutoFit() | out-null
	$ws.columns.Item(3).columnWidth = 50
	$ws.columns.Item(3).wrapText = $true
	$ws.columns.Item(4).columnWidth = 15
	$ws.columns.Item(4).Font.Bold = $true
	#$ws.columns.Item(5).columnWidth = 60
	#$ws.columns.Item(5).wrapText = $true
	$ws.columns.Item(7).columnWidth = 60
	$ws.columns.Item(7).wrapText = $true
	$ws.columns.Item(8).columnWidth = 60
	$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(11).columnWidth = 60
	$ws.columns.Item(11).wrapText = $true
	$ws.columns.Item(14).columnWidth = 60
	$ws.columns.Item(14).wrapText = $true
	#$ws.columns.Item(8).columnWidth = 50
	#$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(10).columnWidth = 50
	$ws.columns.Item(10).wrapText = $true
	#$ws.columns.Item(11).columnWidth = 40
	#$ws.columns.Item(11).Font.Bold= $true
	#Add Border to RAR tab
	$dataRange = $ws.Range(("A{0}" -f $initalRow),("N{0}" -f $row))
	7..12 | ForEach{
		$dataRange.Borders.Item($_).LineStyle = 1
		$dataRange.Borders.Item($_).Weight = 2
	}#7..12 | ForEach
}#get-vulninfoDev

	
Function get-portinfoDev
{   
	#	
	$FunctionName = "get-portinfoDev"
	If($debugFlag){  
	
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[1928]" 		
	}#If($debugFlag) #>
	#Check to see if Ports tab exist, if it does not, create a Ports tab
	$WorksheetName = 'Ports'
	$TableName = 'PortsTable'
	
	$wsports = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $PortsTableHeaders
	
	$cells = $cellsp = $wsports.Cells
	$row = $rowp = 1
	$col = $colp = 1
		
	$initialrowp = $rowp
	#foreach ($portsum in $portsummary)
	For($i = 0;  $i -lt $PortsTableHeaders.length; $i++)
	{
		$rowp++
		$colp = 1
		$cellsp.Item($rowp,$colp) = "portsum.ScanName"
		$colp++
		$cellsp.Item($rowp,$colp) = "portsum.openports"
		$colp++
		If($i%2 -eq 0)
		{
			$cellsp.Item($rowp,$colp) = "Approved"
		}
		Else
		{
			$cellsp.Item($rowp,$colp) = "Not Approved"
		}
		$colp++
		$cellsp.Item($rowp,$colp) = "portsum.service"

		$rangep = $wsports.Range(("A{0}"  -f $rowp),("D{0}"  -f $rowp))
		#  $rangep.Select() | Out-Null

		#Determine if disk needs to be flagged for warning or critical alert
		If ($cellsp.Item($rowp,$colp-1).text -eq "Approved") 
		{
			#Approved #Gray
			$rangep.Interior.ColorIndex = 35
		}
		Elseif ($cellsp.Item($rowp,$colp-1).text -eq "Not Approved") 
		{
			#Warning threshold = Yellow
			$rangep.Interior.ColorIndex = 6
		}
	}#foreach ($portsum in $portsummary)
	#>
	#Formatting Excel
	$wsports.columns.Item(1).wrapText = $false
	$wsports.Columns.Item(2).wrapText = $false
	$wsports.Columns.Item(4).wrapText = $true
	$wsports.Rows.RowHeight = 15
	$wsports.rows("1").RowHeight = 25
	$wsportsrange = $wsports.Range("A1:D1")
	#$wsportsrange.autofilter() | Out-Null
	$wsports.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null
	#Add Borders to spreadsheet
	$datarangeport = $wsports.Range(("A{0}" -f $initialrowp),("D{0}" -f $rowp))
	7..12 | foreach{
		$datarangeport.Borders.Item($_).LineStyle = 1
		$datarangeport.Borders.Item($_).Weight = 2 
	}#7..12 | foreach
}#get-portinfoDev


Function get-softinfoDev
{  
	#	
	$FunctionName = "get-softinfoDev"
	If($debugFlag){  	
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2003]" 		
	}#If($debugFlag) #>
	$WorksheetName = 'SoftwareList'
	$TableName = 'SoftwareListTable'
	#Create Headers for SoftwareList tab

	$wssoft = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $SoftwareListTable 

	$cellss = $cells = $wssoft.Cells
	$row = $rowso = 1
	$col = $colso = 1
   
	#Populate softwarelist tab
	$initialrowso = $rowso
	#foreach ($softsum in $softwaresummary)
	For($i = 0;  $i -lt $SoftwareListTable.length; $i++)
	{
		$rowso++
		$colso = 1
		$cellss.Item($rowso,$colso) = "softsum.ScanName"
		$colso++
		$cellss.Item($rowso,$colso) = "softsum.software"
		$colso++
		#$cellss.Item($rowso,$colso) = "softsum.approved"
		If($i%2 -eq 0)
		{
			$cellss.Item($rowso,$colso) = "Approved"
		}
		Else
		{
			$cellss.Item($rowso,$colso) = "Not Approved"
		}
		#$colso++
		#$cellss.Item($rowp,$colp) = "softsum.missing"
		$rangesoft = $wssoft.Range(("A{0}"  -f $rowso),("C{0}"  -f $rowso))
		If ($cellss.Item($rowso,$colso).text -eq "Approved") 
		{
			#Approved 
			$rangesoft.Interior.ColorIndex = 35
		}
		Elseif ($cellss.Item($rowso,$colso).text -eq "Not Approved") 
		{
			#Warning threshold 
			$rangesoft.Interior.ColorIndex = 6
		}

		$wssoft.rows("1").RowHeight = 25
		$wssoftrange = $wssoft.Range("A1:C1")
		#$wssoftrange.AutoFilter() | Out-Null
		$wssoft.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null
		$datarangesoft = $wssoft.Range(("A{0}" -f $initialrowso),("C{0}" -f $rowso))
		7..12 | foreach{
			$datarangesoft.Borders.Item($_).LineStyle = 1
			$datarangesoft.Borders.Item($_).Weight = 2
		}#7..12 | foreach 
	}#foreach ($softsum in $softwaresummary)	
}#get-softinfoDev


Function get-nessinfoDev
{
	#	
	$FunctionName = "get-nessinfoDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2070]" 		
	}#If($debugFlag) #>
	# Set variables for the worksheet cells, and for navigation
	$WorksheetName = 'nessusinfo'
	$TableName = 'nessusinfoTable'
	ExcelWorkSheet =  = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $Headers 

	$ExcelCells = ExcelWorkSheet.Cells
	$row = 1
	$col = 1
  
	$InitialRow = $row
	#foreach ($nessusin in $nessusinfo)
	For($i = 0;  $i -lt $Headers.length; $i++)
	{
		If($debugFlag){
			$hostNameBlank = $nessusin.Hostname.length
			Write-Host -ForegroundColor Yellow "`$hostNameBlank= " -NoNewline			
			Write-Host -ForegroundColor Cyan $hostNameBlank
		}#If($debugFlag) #> 

		#If($nessusin.Hostname.length -gt 0){
			$row++
			$col = 1
			$ExcelCells.Item($row,$col) = $nessusin.Hostname
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.IP
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Credentialed
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.pluginfeed
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.scanstartdate
			$col++
			#$ExcelCells.Item($row,$col) = $nessusin.AuthSuccess
			If($i%2 -eq 0)
			{
				$ExcelCells.Item($row,$col) = $true
			}
			Else
			{
				$ExcelCells.Item($row,$col) = $false
			}
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.ValidScan
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.OperatingSystem   
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Model
			$col++
			$ExcelCells.Item($row,$col) = $nessusin.Plugins

			$rangeness = ExcelWorkSheet.Range(("A{0}"  -f $row),("K{0}"  -f $row))
			#If ($nessusin.AuthSuccess -ne $false -and $nessusin.ValidScan -eq $true) 
			If($ExcelCells.Item($row,$col-4).text -ne $false) 
			{
				#Gray
				$rangeness.Interior.ColorIndex = 35 
			}
			else 
			{
				#Red
				$rangeness.Interior.ColorIndex = 3
			}

			#Add Borders to sheet
			$datarangenessus = ExcelWorkSheet.Range(("A{0}" -f $InitialRow),("K{0}" -f $row))
			7..12 | foreach{
				$datarangenessus.Borders.Item($_).LineStyle = 1
				$datarangenessus.Borders.Item($_).Weight = 2 
			}#7..12 | foreach     
		#}#If($nessusin.Hostname -ne "")
	}#foreach ($nessusin in $nessusinfo)
	
	#formatting excel
	#ExcelWorkSheet.Rows.RowHeight = 120
	ExcelWorkSheet.rows("1").RowHeight = 25
	$wsnessusrange = ExcelWorkSheet.range("A1:K1")
	ExcelWorkSheet.columns.Item(7).columnWidth = 60
	ExcelWorkSheet.columns.Item(7).wrapText = $true
	#$wsnessusrange.AutoFilter() | Out-Null
	ExcelWorkSheet.Columns.Item("A:J").EntireColumn.AutoFit() | Out-Null
}#get-nessinfoDev


Function get-vulninfobulkDev
{    
	#	
	$FunctionName = "get-vulninfobulkDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2158]"
	}#If($debugFlag) #>
	#Create RAR tab in Excel spreadsheet if it does not already exist
	$WorksheetName = 'RAR'
	$TableName = 'RARTable'
	
	$ws = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $RARTableHeaders 
	$cells = $ws.Cells
	$row = 1
	$col = 1
	   
	#Add the results from the nessus files to RAR tab
	$initalrow = $row
	#
	#foreach ($report in $reports)
	For($i = 0;  $i -lt $RARTableHeaders.length; $i++)
	{
		$row++
		$col = 1
		$cells.Item($row,$col) = "report.ScanName"
		$col++
		$cells.Item($row,$col) = "report.pluginid"
		$col++
		$cells.Item($row,$col) = "report.pluginname"
		$col++
		#$cells.Item($row,$col) = "report.risk"
		If($i%2 -eq 0)
		{
			$cells.Item($row,$col) = "Critical"
		}
		ElseIf($i%3 -eq 0)
		{
			$cells.Item($row,$col) = "High"
		}
		ElseIf($i%4 -eq 0)
		{
			$cells.Item($row,$col) = "Medium"
		}
		Else 
		{
			$cells.Item($row,$col) = "Low"
		}
		$col++
		$cells.Item($row,$col) = "report.hostname"
		$col++
		$cells.Item($row,$col) = "report.ip"
		$col++
		$cells.Item($row,$col) = "report.synopsis"
		$col++
		$cells.Item($row,$col) = "report.Description"
		$col++
		$cells.Item($row,$col) = "report.port"
		$col++
		$cells.Item($row,$col) = "report.pluginoutput"
		$col++
		$cells.Item($row,$col) = "report.solution"
		$col++
		$cells.Item($row,$col) = "report.STIGSeverity"
		$col++
		$cells.Item($row,$col) = "report.pluginPublicationDate"
		$col++
		#$cells.Item($row,$col) = "report.mitigationstatement"
		If($i%2 -eq 0)
		{
			$cells.Item($row,$col) = "Can this be remediated/mitigated?"
		}
		Else
		{
			$cells.Item($row,$col) = "Plugin Published within 30 days of Scan Start Date"
		}
   

		#Check to see if space is near empty and use appropriate background colors
		$range = $ws.Range(("A{0}"  -f $row),("N{0}"  -f $row))
		#$range.Select() | Out-Null

		
		#Determine if disk needs to be flagged for warning or critical alert
		If ($cells.Item($row,$col-10).text -eq "Critical") 
		{
			#Write-Host -ForegroundColor Red "cell text=" $cells.Item($row,$col-10).text
			#Critical threshold 
			#7 = magenta
			$range.Interior.ColorIndex = 7
		}
		ElseIf ($cells.Item($row,$col-10).text -eq "High") 
		{
			#Write-Host -ForegroundColor Green "cell text=" $cells.Item($row,$col-10).text
			#Warning threshold 
			$range.Interior.ColorIndex = 45
		}
		ElseIf ($cells.Item($row,$col-10).text -eq "Medium")
		{
			#Medium threshold
			#olive
			#Write-Host -ForegroundColor Cyan "cell text=" $cells.Item($row,$col-10).text
			$range.Interior.ColorIndex = 44
		}
		ElseIf ($cells.Item($row,$col-10).text -eq "Low")
		{
			#Low threshold
			#cyan
			$range.Interior.ColorIndex = 34
		}
  
		If ($cells.Item($row,$col).text -ne "Can this be remediated/mitigated?")
		{
			#gray
			$range.Interior.ColorIndex = 15
		}        
	}#foreach ($report in $reports)

	#Formatting Excel
	#
	$ws.Rows.RowHeight = 30
	$ws.Rows("1").RowHeight = 35
	$wsheaderrange = $ws.range("A1:N1")
	#$wsheaderrange.AutoFilter() | Out-Null
	$ws.columns.Item("A:N").EntireColumn.AutoFit() | out-null
	$ws.columns.Item(3).columnWidth = 50
	$ws.columns.Item(3).wrapText = $true
	$ws.columns.Item(4).columnWidth = 15
	$ws.columns.Item(4).Font.Bold = $true
	#$ws.columns.Item(5).columnWidth = 60
	#$ws.columns.Item(5).wrapText = $true
	$ws.columns.Item(7).columnWidth = 60
	$ws.columns.Item(7).wrapText = $true
	$ws.columns.Item(8).columnWidth = 60
	$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(11).columnWidth = 60
	$ws.columns.Item(11).wrapText = $true
	$ws.columns.Item(14).columnWidth = 60
	$ws.columns.Item(14).wrapText = $true
	#$ws.columns.Item(8).columnWidth = 50
	#$ws.columns.Item(8).wrapText = $true
	$ws.columns.Item(10).columnWidth = 50
	$ws.columns.Item(10).wrapText = $true
	#$ws.columns.Item(11).columnWidth = 40
	#$ws.columns.Item(11).Font.Bold= $true

	#Add Border to RAR tab    
	$dataRange = $ws.Range(("A{0}" -f $initalRow),("N{0}" -f $row))
	7..12 | ForEach{
		$dataRange.Borders.Item($_).LineStyle = 1
		$dataRange.Borders.Item($_).Weight = 2
	}#7..12 | ForEach 	
}#get-vulninfobulkDev


Function get-portinfobulkDev
{
	#	
	$FunctionName = "get-portinfobulkDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2315]"
	}#If($debugFlag) #>
	#Check to see if Ports tab exist, if it does not, create a Ports tab
	$WorksheetName = 'Ports'
	$TableName = 'PortsTable'
	#Create Headers for Ports tab
	
	$wsports = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $PortsTableHeaders 

	$cellsp = $wsports.Cells
	$row = $rowp = 1
	$col = $colp = 1
			
	$initialrowp = $rowp
	#foreach ($portsum in $portsummary)
	For($i = 0;  $i -lt $PortsTableHeaders.length; $i++)
	{
		$rowp++
		$colp = 1
		$cellsp.Item($rowp,$colp) = $portsum.ScanName
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.openports
		$colp++
		#$cellsp.Item($rowp,$colp) = $portsum.approved        
		If($i%2 -eq 0)
		{
			$cellsp.Item($rowp,$colp) = "Approved"
		}
		Else
		{
			$cellsp.Item($rowp,$colp) = "Not Approved"
		}
		$colp++
		$cellsp.Item($rowp,$colp) = $portsum.service

		$rangep = $wsports.Range(("A{0}"  -f $rowp),("D{0}"  -f $rowp))
		#  $rangep.Select() | Out-Null

		#Detrmine if disk needs to be flagged for warning or critical alert
		If ($cellsp.Item($rowp,$colp-1).text -eq "Approved") 
		{    
			#Gray
			$rangep.Interior.ColorIndex = 35
		}
		Elseif($cellsp.Item($rowp,$colp-1).text -eq "Not Approved") 
		{ 
			#Yellow
			$rangep.Interior.ColorIndex = 6
		}
	}#foreach ($portsum in $portsummary)
	
	#Formatting Excel
	$wsports.columns.Item(1).wrapText = $false
	$wsports.Columns.Item(2).wrapText = $false
	$wsports.Columns.Item(4).wrapText = $true
	$wsports.Rows.RowHeight = 15
	$wsports.rows("1").RowHeight = 25
	$wsportsrange = $wsports.Range("A1:D1")
	#$wsportsrange.autofilter() | Out-Null
	$wsports.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null

	#Add Borders to spreadsheet
	$datarangeport = $wsports.Range(("A{0}" -f $initialrowp),("D{0}" -f $rowp))
	7..12 | foreach{
		$datarangeport.Borders.Item($_).LineStyle = 1
		$datarangeport.Borders.Item($_).Weight = 2 
	}#7..12 | foreach 
}#get-portinfobulkDev


Function get-softinfobulkDev
{   
	#	
	$FunctionName = "get-softinfobulkDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2393]" 		
	}#If($debugFlag) #>
	#Create softwarelist tab in excel if it does not exist
	$WorksheetName = 'SoftwareList'
	$TableName = 'SoftwareListTable'
	#Create Headers for SoftwareList tab

	$wssoft = ExcelWorkSheet = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $SoftwareListTable 

	$cellss = $wssoft.Cells
	$row = $rowso = 1
	$col = $colso = 1
	
	#Populate softwarelist tab
	$initialrowso = $rowso
	#foreach ($softsum in $softwaresummary)
	For($i = 0;  $i -lt $SoftwareListTable.length; $i++)
	{
		$rowso++
		$colso = 1
		$cellss.Item($rowso,$colso) = $softsum.ScanName
		$colso++
		$cellss.Item($rowso,$colso) = $softsum.software
		$colso++
		#$cellss.Item($rowso,$colso) = $softsum.approved
		If($i%2 -eq 0)
		{
			$cellss.Item($rowso,$colso) = "Approved"
		}
		Else
		{
			$cellss.Item($rowso,$colso) = "Not Approved"
		}

		#$colso++
		#$cellss.Item($rowp,$colp) = $softsum.missing
		$rangesoft = $wssoft.Range(("A{0}"  -f $rowso),("C{0}"  -f $rowso))
		If ($cellss.Item($rowso,$colso).text -eq "Approved") 
		{    
			$rangep.Interior.ColorIndex = 35
		}
		Elseif($cellss.Item($rowso,$colso).text -eq "Not Approved") 
		{ 
			$rangep.Interior.ColorIndex = 6
		}

		$wssoft.rows("1").RowHeight = 25
		$wssoftrange = $wssoft.Range("A1:C1")
		#$wssoftrange.AutoFilter() | Out-Null
		$wssoft.Columns.Item("A:D").EntireColumn.AutoFit() | Out-Null
		$datarangesoft = $wssoft.Range(("A{0}" -f $initialrowso),("C{0}" -f $rowso))
		7..12 | foreach{
			$datarangesoft.Borders.Item($_).LineStyle = 1
			$datarangesoft.Borders.Item($_).Weight = 2
		}#7..12 | foreach 
	}#foreach ($softsum in $softwaresummary)	
}#get-softinfobulkDev


Function get-nessinfobulkDev
{
	#
	$FunctionName = "get-nessinfobulkDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2460]" 		
	}#If($debugFlag) #>
	#Set variables for the worksheet cells, and for navigation
	$WorksheetName = 'nessusinfo'
	$TableName = 'nessusinfoTable'
	
	ExcelWorkSheet =  = CreateExcelTable `
										-WorksheetName $WorksheetName `
										-TableName $TableName `
										-Headers $Headers 
	$ExcelCells = ExcelWorkSheet.Cells
	$row = 1
	$col = 1
		
	$InitialRow = $row
	#foreach ($nessusin in $nessusinfo)
	For($i = 0;  $i -lt $Headers.length; $i++)
	{
		If($nessusin.Hostname -ne "")
		{
			$row++
			$col = 1
			$ExcelCells.Item($row,$col) = "nessusin.Hostname"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.IP"
			$col++
			$ExcelCells.Item($row,$col) = "No Data"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.Credentialed"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.pluginfeed"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.scanstartdate"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.AuthSuccess"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.ValidScan"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.OperatingSystem"
			$col++
			$ExcelCells.Item($row,$col) = "nessusin.Model"
			$col++
			#$ExcelCells.Item($row,$col) = "nessusin.Plugins"
			If($i%2 -eq 0)
			{
				$ExcelCells.Item($row,$col) = "Invalid Scan.  Review Plugins"
			}
			Else
			{
				$ExcelCells.Item($row,$col) = "Valid Scan"
			}

			$rangeness = ExcelWorkSheet.Range(("A{0}"  -f $row),("K{0}"  -f $row))
			#Write-Host "cellsness text = " $ExcelCells.Item($row,$col).text
			If($ExcelCells.Item($row, $col).text -ne "Invalid Scan.  Review Plugins") 
			{
				#gray
				$rangeness.Interior.ColorIndex = 35 
			}
			else 
			{
				#Red
				$rangeness.Interior.ColorIndex = 3
			}

			#Add Borders to sheet
			$datarangenessus = ExcelWorkSheet.Range(("A{0}" -f $InitialRow),("K{0}" -f $row))
			7..12 | foreach{
				$datarangenessus.Borders.Item($_).LineStyle = 1
				$datarangenessus.Borders.Item($_).Weight = 2 
			}#7..12 | foreach   
		}#If($nessusin.Hostname -ne "")
	}#foreach ($nessusin in $nessusinfo)
	
	#formatting excel
	#ExcelWorkSheet.Rows.RowHeight = 120
	ExcelWorkSheet.rows("1").RowHeight = 25
	$wsnessusrange = ExcelWorkSheet.range("A1:K1")
	ExcelWorkSheet.columns.Item(7).columnWidth = 60
	ExcelWorkSheet.columns.Item(7).wrapText = $true
	#$wsnessusrange.AutoFilter() | Out-Null
	ExcelWorkSheet.Columns.Item("A:K").EntireColumn.AutoFit() | Out-Null
}#get-nessinfobulkDev


Function create-rarbulkDev
{    
	#	
	$FunctionName = "create-rarbulkDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2549]"
	}#If($debugFlag) #>
	$FunctionName = "create-rarbulkDev"
	#Open the Excel document and pull in the 'RAR' worksheet
	#$path = Get-FileNameExcel
	$Excel = New-Object -ComObject Excel.Application
	#ExcelWorkSheet = $Excel.Workbooks.Open($path)
	ExcelWorkSheet = $Excel.Workbooks.Add()

	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2561]" 
		Write-Host -ForegroundColor Cyan "STARTING get-vulninfobulkDev"
	}#If($debugFlag) #> 
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0
	get-vulninfobulkDev


	#	
	If($debugFlag){  
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2570]" 
		Write-Host -ForegroundColor Cyan "STARTING get-nessinfobulkDev"
	}#If($debugFlag) #> 

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50
	get-nessinfobulkDev


	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100
			
	<#  
		cls
		Write-Host "Save Excel File"
		
		#Close the workbook and exit excel
		ExcelWorkSheet.Close($true)
		$Excel.quit()
	#>
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-rarbulkDev


Function create-fullbulkDev
{   
	#	
	$FunctionName = "create-fullbulkDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2595]" 		
	}#If($debugFlag) #>

	#Open the Excel document and pull in the 'RAR' worksheet
	#$path = Get-FileNameExcel
	$Excel = New-Object -ComObject Excel.Application
	#ExcelWorkSheet = $Excel.Workbooks.Open($path)
	ExcelWorkSheet = $Excel.Workbooks.Add()


	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2610]" 
		Write-Host -ForegroundColor Cyan "STARTING get-vulninfobulkDev"
	}#If($debugFlag) #> 

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0		
	get-vulninfobulkDev
	

	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2620]" 
		Write-Host -ForegroundColor Cyan "STARTING get-portinfobulkDev"
	}#If($debugFlag) #> 
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 25	
	get-portinfobulkDev
	
	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2628]" 
		Write-Host -ForegroundColor Cyan "STARTING get-nessinfobulkDev"
	}#If($debugFlag) #> 
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50	
	get-nessinfobulkDev
	

	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2637]" 
		Write-Host -ForegroundColor Cyan "STARTING get-softinfobulkDev"
	}#If($debugFlag) #> 
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 75
	get-softinfobulkDev
	
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100
	
	<#
	cls
	Write-Host "Save Excel File"
	  

	#Close the workbook and exit excel
	ExcelWorkSheet.Close($true)
	$Excel.quit()
	#>

	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-fullbulkDev


Function create-rarDev
{  
	#	
	$FunctionName = "create-rarDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2665]" 		
	}#If($debugFlag) #>
	#Open the Excel document and pull in the 'RAR' worksheet
	#$path = Get-FileNameExcel
	$Excel = New-Object -ComObject Excel.Application
	#ExcelWorkSheet = $Excel.Workbooks.Open($path)
	ExcelWorkSheet = $Excel.Workbooks.Add()

	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2675]" 
		Write-Host -ForegroundColor Cyan "STARTING get-vulninfoDev"
	}#If($debugFlag) #> 

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0	
	get-vulninfoDev
	
	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2684]" 
		Write-Host -ForegroundColor Cyan "STARTING get-nessinfoDev"
	}#If($debugFlag) #> 
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50	
	get-nessinfoDev
		
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100

	<#
	cls
	Write-Host "Save Excel File"


	#Close the workbook and exit excel
	ExcelWorkSheet.Close($true)
	$Excel.quit()
	#>

	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-rarDev


Function create-fullDev
{   
	#	
	$FunctionName = "create-fullDev"
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2712]" 		
	}#If($debugFlag) #>

	#Open the Excel document and pull in the 'RAR' worksheet
	#$path = Get-FileNameExcel
	$Excel = New-Object -ComObject Excel.Application
	#ExcelWorkSheet = $Excel.Workbooks.Open($path)
	ExcelWorkSheet = $Excel.Workbooks.Add()
   
	#cls
	
	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2730]" 
		Write-Host -ForegroundColor Cyan "STARTING get-vulninfoDev"
	}#If($debugFlag) #> 

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 0
	get-vulninfoDev
	
	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2745]" 
		Write-Host -ForegroundColor Cyan "STARTING get-portinfoDev"
	}#If($debugFlag) #> 

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 25
	get-portinfoDev
	
	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2754]" 
		Write-Host -ForegroundColor Cyan "STARTING get-softinfoDev"
	}#If($debugFlag) #> 

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 50
	get-softinfoDev
	
	#	
	If($debugFlag){  		
		Write-Host -ForegroundColor Magenta -BackgroundColor Black "$FunctionName[2763]" 
		Write-Host -ForegroundColor Cyan "STARTING get-nessinfoDev"
	}#If($debugFlag) #> 

	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 75
	get-nessinfoDev
		
	write-progress -Activity "Getting information from NESSUS and populating EXCEL. Once completed, you will be prompted to save Excel spreadsheet." -PercentComplete 100
	
	#
	#cls
	Write-Host "Save Excel File"
	<#
	#Close the workbook and exit excel
	ExcelWorkSheet.Close($true)
	$Excel.quit()
	#>

	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
	#endregion EXCEL
}#create-fullDev

<################################
END OF DEV FUNCTIONS
################################>


#region Values/Variables
#values
$portexists = "Approved"
$portnotexists = "Not Approved"
$noauthsuccess = "False"
$nopluginoutput = "No Plugin Output available"
$filter = "All Nessus Files (*.nessus*) | *.nessus"
$filterexcel = "All Excel Files (*.xl*) | *.xl*; *.csv"
$ScanGoodLocalChecksEnabled = "ScanData Good, Local Checks Enabled.  Logic: Plugins 19506 AND 117887 AND NOT (10919 AND 21745 AND 110385 AND 117885) per ACAS BPG"
$ScanInvalid = "Invalid Scan.  Review Plugins"
<#
	#Original Table Headers
	#RAR
	$RARTableHeaders = "ScanName", "PluginID", "PluginName", "Risk", "Hostname", "IP", "Synopsis", "Description", "Port", "Plugin_Results", "Solution", "STIG_Severity", "PluginPublicationDate", "Mitigation"
	#Ports
	$PortsTableHeaders = "ScanName", "Port", "Approved", "Service"
	#SoftwareList
	$SoftwareListTable = "ScanName", "Software", "Approved"
	#nessusinfo	
	$Headers = "Hostname", "IP", "ScanPolicy", "Credentialed?", "Pluginfeedversion", "ScanStartDate", "AuthenticationSuccess?", "Valid Scan Date?", "Operating System", "Model", "Plugin Verification"
#>


#Table Headers
#RAR
$RARTableHeaders = "ScanName", 
					"PluginID", 
					"PluginName", 
					"Risk", 
					"Hostname", 
					"IP", 
					"Synopsis", 
					"Description", 
					"Port", 
					"PluginResults", 
					"Solution", 
					"STIGSeverity", 
					"PluginPublicationDate", 
					"Mitigation"
#Ports
$PortsTableHeaders = "ScanName",
					"Port", 
					"Approved", 
					"Service"
#SoftwareList
$SoftwareListTable = "ScanName", 
					"Software",		
					"Approved"	
#nessusinfo
$Headers =	"Hostname", 
							"IP", 
							"ScanPolicy", 
							"Credentialed?", 
							"PluginFeedVersion", 
							"ScanStartDate", 
							"AuthenticationSuccess?", 
							"ValidScanDate?", 
							"OperatingSystem", 
							"Model", 
							"PluginVerification"

#Mitigations
$mitigationstatements = 
@{
	"126824" = "NO ACTION REQUIRED. Currently exists in McAfee CND eISD 11628 POAM."
	"12107" = 'MITIGATED.  NO ACTION REQUIRED.  Attack Vector: Malicious Logic | Exploitation Vector: AV Software | Justification: New Virus Signatures pending deployment and installation | CAT I to CAT II Mitigation: Assets are isolated in a VLAN where access to/ from is being enforced via ACLs.  Additional boundary protection devices are deployed to provide more robust defense mechanisms.  Assets have HBSS Point Products installed to identify, alert, and quarantine malicious activity.  Access to the assets is regulated to administrators and a subset of privileged users.'
	"35291" = 'NO ACTION REQUIRED. ON POAM.'
	"42873" = 'NO ACTION REQUIRED. ON POAM.'
	"45411" = 'NO ACTION REQUIRED. ON POAM.'
	"51192" = 'NO ACTION REQUIRED. ON POAM.'
	"104743" = 'NO ACTION REQUIRED. ON POAM. '
	"125780" = "NO ACTION REQUIRED. Currently exists in McAfee CND eISD 11628 POAM."
	"128416" = 'MITIGATED.  NO ACTION REQUIRED.  Attack Vector: Missing Patch | Exploitation Vector: AV Software | Justification: New version pending deployment and installation | CAT II to CAT III Mitigation: Assets are isolated in a VLAN where access to/ from is being enforced via ACLs.  Additional boundary protection devices are deployed to provide more robust defense mechanisms.  Assets have HBSS Point Products installed to identify, alert, and quarantine malicious activity.  Access to the assets is regulated to administrators and a subset of privileged users.'
	"130271" = 'MITIGATED.  NO ACTION REQUIRED.  Attack Vector: Missing Patch | Exploitation Vector: AV Software | Justification: New version pending deployment and installation | CAT II to CAT III Mitigation: Assets are isolated in a VLAN where access to/ from is being enforced via ACLs.  Additional boundary protection devices are deployed to provide more robust defense mechanisms.  Assets have HBSS Point Products installed to identify, alert, and quarantine malicious activity.  Access to the assets is regulated to administrators and a subset of privileged users.'
	"127116" = 'MITIGATED.  NO ACTION REQUIRED.  Attack Vector: Missing Patch | Exploitation Vector: AV Software | Justification: New version pending deployment and installation | CAT II to CAT III Mitigation: Assets are isolated in a VLAN where access to/ from is being enforced via ACLs.  Additional boundary protection devices are deployed to provide more robust defense mechanisms.  Assets have HBSS Point Products installed to identify, alert, and quarantine malicious activity.  Access to the assets is regulated to administrators and a subset of privileged users.'
	"125781" = "NO ACTION REQUIRED. Currently exists in McAfee CND eISD 11628 POAM."
	"126988" = 'MITIGATED.  NO ACTION REQUIRED.  Attack Vector: Missing Patch | Exploitation Vector: AV Software | Justification: New version pending deployment and installation | CAT I to CAT III Mitigation: The patch for this vulnerability will be applied as part of the ONE-Net IAVM and Patch process.  There is no external attack vector for this vulnerability as the non-compliant device(s) is located internally within the protected enclave. The IA suite external protections include multiple firewalls and IDS/IPS (host-based and network based).  Internal attacks are limited through STIG hardening and authentication, authorization, and accountability (AAA) services provided by Microsoft Active Directory which will prevent internal unauthorized access by enforcing password complexity, forcing lockout after invalid attempts, and enforcing two-factor authentication via Common Access Card (CAC)/ALT-Token.  Assets are isolated in a VLAN where access to/ from is being enforced via ACLs.  Additional boundary protection devices are deployed to provide more robust defense mechanisms.  Assets have HBSS Point Products installed to identify, alert, and quarantine malicious activity.  Access to the assets is regulated to a single administrator.'
	"127117" = 'MITIGATED.  NO ACTION REQUIRED.  Attack Vector: Missing Patch | Exploitation Vector: AV Software | Justification: New version pending deployment and installation | CAT I to CAT II Mitigation: Assets are isolated in a VLAN where access to/ from is being enforced via ACLs.  Additional boundary protection devices are deployed to provide more robust defense mechanisms.  Assets have HBSS Point Products installed to identify, alert, and quarantine malicious activity.  Access to the assets is regulated to administrators and a subset of privileged users.'
	"122615" = "NO ACTION REQUIRED.  KNOWN ENTERPRISE FINDING"
	"157126" = "NO ACTION REQUIRED. Currently exists in McAfee CND eSID 11628 POAM."
	"139239" = "NO ACTION REQUIRED. ON POAM."
	"156024" = "NO ACTION REQUIRED. Currently exists in McAfee CND eISD 11628 POAM."
	"125779" = "NO ACTION REQUIRED. Currently exists in McAfee CND eISD 11628 POAM."
	"141833" = "NO ACTION REQUIRED. Currently exists in McAfee CND eISD 11628 POAM."
	"157872" = "NO ACTION REQUIRED. Currently exists in McAfee CND eISD 11628 POAM."
	"57582" = "NO ACTION REQUIRED. Currently exists in POAM"
	"108797" = "Misleading result because ONE-Net has purchased extended support"
}#$mitigationstatements


<################################
##### END OF VALUES/VARIABLES ###>
# Region testarrays:

$approvedwin10portarray = @(
	'25'
	'50'
	'51'
	'53'
	'53'
	'67'
	'80'
	'80'
	'88'
	'123'
	'135'
	'137'
	'138'
	'139'
	'389'
	'443'
	'443'
	'445'
	'464'
	'500'
	'515'
	'591'
	'636'
	'1900'
	'2701'
	'3268'
	'3269'
	'3389'
	'3702'
	'4500'
	'5040'
	'5050'
	'5222'
	'5353'
	'5355'
	'5985'
	'8081'
	'8082'
	'8089'
	'8443'
	'8444'
	'8888'
	'9997'
	49152..65535
)

$approvedportarray = @(
	'7'
	'20' #solarwinds
	'21' #solarwinds
	'22'
	'25'
	'53'
	'67' #wins
	'68' #wins
	'69' #Solarwinds
	'80'
	'88'
	'111'
	'123'
	'135'
	'137'
	'138'
	'139'
	'161'
	'162' #Solarwinds
	'389'
	'443'
	'445'
	'464'
	'465'
	'500'
	'514' #Solarwinds
	'515'
	'587'
	'591'
	'593'
	'636'
	'808'
	'902'
	'1433' #sql
	'1434' #sqlbrowser
	'1688' #KMS
	#'1801' #Solarwinds
	#'2012'
	'2055' #solarwinds
	#'2103'
	#'2105'
	'2107'
	#'2535' #wins
	'3003'
	'3260' #sib iscsi
	'3268'
	'3269'
	'3343'
	'3389'
	'3702'
	'4500' #sib
	#'5353'
	'5355'
	#'5671'
	#'5672'
	'5722'
	'5723'
	'5724'
	'5725' #scom
	'5985'
	'5986'
	'7569' #sib eql-asm-agent
	'8000' #FSS
	'8081' #Mcafee
	'8082'
	'8089' #mcafee
	'8099' #sib
	'8400'
	'8401' #commvault
	'8402' #COMMVAULT
	'8403'
	'8443' #commvault
	'8444'
	'8530' #Mcafee
	#'9084'
	#'9354'
	#'9355'
	#'9356'
	#'9359'
	'9389'
	'9876'
	'9997'
	'10003'
	#'10080'
	'10123'
	#'10443'
	'16500'
	#'17777' #solarwinds
	#'17778' #solarwinds
	#'17779' #solarwinds
	#'17780' #solarwinds
	'20002'
	'20003'
	'22233'
	'25555'
	#'32843'
	#'32844'
	#'25' #Gemini
	#'389' #Gemini
	#'465' #Gemini
	#'636' #Gemini
	#'1352' #Gemini
	#'1352' #Gemini
	'47001' #winrm
	1435..1483
	49152..65535
)

$approvedbbsoft = @(
	'ACCM  [version 3.2.4.5]'
	'ACCM  [version 3.2.5.1]'
	'ActivID ActivClient x64  [version 7.1.0]'
	'AdoptOpenJDK JRE with Hotspot 8u282-b08 (x64)  [version 8.0.282.8]'
	'Axway Desktop Validator  [version 4.12.2.2.0]'
	'BlackBerry Enterprise Mobility Server  [version 2.10.6.10]'
	'BlackBerry Enterprise Mobility Server  [version 3.1.15.17]'
	'BlackBerry Enterprise Mobility Server - Mail  [version 0.15.10.0]'
	'BlackBerry Enterprise Mobility Server - Mail  [version 3.1.17.0]'
	'BlackBerry UEM  [version 12.11.1 [Catalog 7.44.0]]'
	'Configuration Manager Client  [version 5.00.8853.1000]'
	'Configuration Manager Client  [version 5.00.9012.1000]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2565063)  [version 1]'
	'Java 8 Update 251 (64-bit)  [version 8.0.2510.8]'
	'McAfee Agent  [version 5.6.4.151]'
	'McAfee Agent  [version 5.7.1.116]'
	'McAfee Data Exchange Layer for MA  [version 6.0.0.204]'
	'McAfee Data Exchange Layer for MA  [version 6.0.204.0]'
	'McAfee Data Exchange Layer for MA  [version 6.0.3.278]'
	'McAfee Data Exchange Layer for MA  [version 6.0.30278.0]'
	'McAfee DLP Endpoint  [version 11.4.0.452]'
	'McAfee Endpoint Security Firewall  [version 10.7.0]'
	'McAfee Endpoint Security Platform  [version 10.7.0]'
	'McAfee Endpoint Security Threat Prevention  [version 10.7.0]'
	'McAfee Host Intrusion Prevention  [version 8.00.1400]'
	'McAfee Host Intrusion Prevention  [version 8.00.1500]'
	'McAfee Policy Auditor Agent  [version 6.4.3.297]'
	'McAfee Policy Auditor Agent  [version 6.5.0.241]'
	'Microsoft CRT 10.0 package  [version 10.0.30319.1]'
	'Microsoft CRT 9.0 package  [version 9.0.30729.4148]'
	'Microsoft Monitoring Agent  [version 7.1.10184.0]'
	'Microsoft Policy Platform  [version 68.1.1010.0]'
	'Microsoft Silverlight  [version 5.1.50907.0]'
	'Microsoft SQL Server 2012 Native Client   [version 11.0.2100.60]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.61000]'
	'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2010  x86 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.20.27508  [version 14.20.27508.1]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x86) - 14.20.27508  [version 14.20.27508.1]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.11.25325  [version 14.11.25325.0]'
	'Microsoft Visual C++ 2017 x64 Additional Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.20.27508  [version 14.20.27508]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.20.27508  [version 14.20.27508]'
	'Microsoft Visual C++ 2019 X86 Additional Runtime - 14.20.27508  [version 14.20.27508]'
	'Microsoft Visual C++ 2019 X86 Minimum Runtime - 14.20.27508  [version 14.20.27508]'
	'SCAP Compliance Checker 5.3  [version 5.3]'
	'VMware Tools  [version 11.0.5.15389592]'
)

$approvedbbport = @(
	'25'
	'53'
	'80'
	'80'
	'88'
	'123'
	'135'
	'137'
	'138'
	'139'
	'389'
	'443'
	'443'
	'445'
	'464'
	'500'
	'591'
	'636'
	'1470'
	'1471'
	'1688'
	'1701'
	'1723'
	'3101'
	'3202'
	'3203'
	'3268'
	'3269'
	'3389'
	'4500'
	'5355'
	'5723'
	'5985'
	'8000'
	'8081'
	'8082'
	'8085'
	'8087'
	'8089'
	'8095'
	'8103'
	'8104'
	'8443'
	'8444'
	'8448'
	8881..8885
	'8886'
	'8887'
	'8889'
	'8890'
	'8891'
	'8892'
	8893..8897
	'8898'
	'8899'
	'8900'
	'8902'
	'9389'
	'9444'
	'9887'
	'9997'
	'10080'
	'11001'
	'11002'
	12000..12999
	'17080'
	'17317'
	'17433'
	'18084'
	18111..65535
	'47001'
)

$approvedmibsoft = @(
	'{86C2A745-08F4-4616-BD57-F622D8BA8504}  [version 5.14.1405]'
	'90meter Smartcard Manager 1.4.39-S  [version 1.4.39]'
	'ACCM  [version 3.2.5.1]'
	'ACCM  [version 3.2.6.2]'
	'Active Directory Authentication Library for SQL Server  [version 13.0.1300.275]'
	'Active Directory Authentication Library for SQL Server  [version 14.0.1000.169]'
	'Active Directory Management Pack Helper Object  [version 1.1.0]'
	'ActivID ActivClient x64  [version 7.1.0]'
	'ActivID ActivClient x64  [version 7.2.1]'
	'Apache Tomcat 8.5 Tomcat8 (remove only)  [version 8.5.57]'
	'Application Web Service  [version 5.00.9012.1000]'
	'Asset Intelligence Update Service Point  [version 5.00.9012.1000]'
	'Asset Intelligence Update Service Point  [version 5.00.9058.1000]'
	'Axway Desktop Validator  [version 4.12.2.2.0]'
	'Axway Desktop Validator  [version 5.1]'
	'BCD and Boot  [version 10.1.22000.1]'
	'BGB http proxy  [version 5.00.9012.1000]'
	'BGB http proxy  [version 5.00.9058.1000]'
	'BMC Atrium Core  [version 9.1.10]'
	'BMC Atrium Integrator 20.02.00  [version 9.1.10]'
	'BMC Remedy Action Request System  [version 9.1.10]'
	'BMC Remedy Action Request System 20.02.00 Install 1  [version 9.1.10]'
	'BMC Remedy ITSM Suite 18.05.00 Install 1  [version 9.1.05]'
	'BMC Remedy Migrator 20.02.00  [version 9.1.10]'
	'BMC Remedy Single Sign-On  [version 20.02.00]'
	'BMC Service Level Management  [version 9.1.05]'
	'Broadcom Drivers and Management Applications  [version 15.2.5.6]'
	'Browser for SQL Server 2016  [version 13.2.5026.0]'
	'Browser for SQL Server 2017  [version 14.0.1000.169]'
	'CommCellConsole Instance001  [version 11.160.645.0]'
	'CommCellConsole Instance001  [version 11.200.798.0]'
	'CommServe Instance001  [version 11.160.645.0]'
	'CommServe Instance001  [version 11.200.798.0]'
	'Commvault ContentStore  [version 11.80.140.0]'
	'Commvault ContentStore  [version 11.80.160.0]'
	'Commvault ContentStore  [version 11.80.200.0]'
	'ConfigMgr 2012 Toolkit R2  [version 5.00.7958.1151]'
	'ConfigMgr Distribution Point  [version 5.00.8239.1000]'
	'ConfigMgr Fallback Status Point  [version 5.00.9012.1000]'
	'ConfigMgr Fallback Status Point  [version 5.00.9058.1000]'
	'ConfigMgr Management Point  [version 5.00.9012.1000]'
	'ConfigMgr Management Point  [version 5.00.9058.1000]'
	'ConfigMgr Reporting Services Point  [version 5.00.9012.1000]'
	'ConfigMgr Reporting Services Point  [version 5.00.9058.1000]'
	'Configuration Manager Client  [version 5.00.8740.1000]'
	'Configuration Manager Client  [version 5.00.9012.1000]'
	'Configuration Manager Client  [version 5.00.9058.1000]'
	'Dell EqualLogic Host Integration Tools  [version 4.0.0]'
	'Dell EqualLogic Storage Management Pack Suite v6.0  [version 6.0]'
	'Dell MD Storage Software'
	'Dell MD Storage Software  [version 6.1.0.0]'
	'Dell OpenManage Systems Management Software (64-Bit)  [version 7.4.0]'
	'Dell OpenManage Systems Management Software (64-Bit)  [version 8.5.0]'
	'Dell Touchpad  [version 8.1200.101.127]'
	'DiagnosticsAndUsageServer Instance001  [version 11.160.645.0]'
	'DiagnosticsAndUsageServer Instance001  [version 11.200.798.0]'
	'DoD Secure Host Baseline Server  [version 2016.Build2]'
	'ExchangeDatabaseiDataAgent Instance001  [version 11.200.798.0]'
	'GDR 4232 for SQL Server 2014 (KB3194720) (64-bit)  [version 12.1.4232.0]'
	'GDR 5207 for SQL Server 2014 (KB4019093) (64-bit)  [version 12.2.5207.0]'
	'GDR 6108 for SQL Server 2014 (KB4505218) (64-bit)  [version 12.3.6108.1]'
	'GDR 6118 for SQL Server 2014 (KB4532095) (64-bit)  [version 12.3.6118.4]'
	'GDR 6164 for SQL Server 2014 (KB4583463) (64-bit)  [version 12.3.6164.21]'
	'Herramientas de correcciÃ³n de Microsoft Office 2016'
	'Hotfix 4522 for SQL Server 2014 (KB4019099) (64-bit)  [version 12.1.4522.0]'
	'Hotfix 5264 for SQL Server 2016 (KB4475776) (64-bit)  [version 13.2.5264.1]'
	'Hotfix 5366 for SQL Server 2016 (KB4505222) (64-bit)  [version 13.2.5366.0]'
	'Hotfix 5622 for SQL Server 2016 (KB4535706) (64-bit)  [version 13.2.5622.0]'
	'Hotfix 5698 for SQL Server 2016 (KB4536648) (64-bit)  [version 13.2.5698.0]'
	'Hotfix 5865 for SQL Server 2016 (KB4583461) (64-bit)  [version 13.2.5865.1]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2151757)  [version 1]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2467173)  [version 1]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2565063)  [version 1]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB982573)  [version 1]'
	'Hotfix for Microsoft Visual C++ 2010  x86 Redistributable (KB2151757)  [version 1]'
	'Hotfix for Microsoft Visual C++ 2010  x86 Redistributable (KB2467173)  [version 1]'
	'Hotfix for Microsoft Visual C++ 2010  x86 Redistributable (KB982573)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946040)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946308)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946344)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB947540)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB947789)  [version 1]'
	'IIS URL Rewrite Module 2  [version 7.2.1993]'
	'InstallRoot  [version 5.2]'
	'Java 8 Update 311 (64-bit)  [version 8.0.3110.11]'
	'Java Auto Updater  [version 2.8.311.11]'
	'Java SE Development Kit 8 Update 311 (64-bit)  [version 8.0.3110.11]'
	'KB3058865  [version 12.1.4100.1]'
	'KB3171021  [version 12.2.5000.0]'
	'KB3194720  [version 12.1.4232.0]'
	'KB4019099  [version 12.1.4522.0]'
	'KB4469137  [version 12.2.5605.1]'
	'KB4505419  [version 12.2.5659.1]'
	'Kelverion Integration Pack for BMC Remedy AR System  [version 2.41]'
	'Kelverion Integration Pack for SQL Server  [version 2.3]'
	'Kits Configuration Installer  [version 10.1.19041.1]'
	'Kits Configuration Installer  [version 10.1.22000.1]'
	'Local Administrator Password Solution  [version 6.2.0.0]'
	'Matrox Graphics Software (remove only)'
	'Matrox Graphics Software (remove only)  [version 4.3.1.4]'
	'Matrox Graphics Software (remove only)  [version 4.3.4.2]'
	'McAfee Agent  [version 5.7.4.399]'
	'McAfee Asset Baseline Monitor Agent  [version 3.5.0.250]'
	'McAfee Data Exchange Layer for MA  [version 6.0.3.441]'
	'McAfee Data Exchange Layer for MA  [version 6.0.30441.0]'
	'McAfee DLP Endpoint  [version 11.6.100.432]'
	'McAfee DLP Endpoint  [version 11.6.200.162]'
	'McAfee DLP Endpoint  [version 11.6.300.52]'
	'McAfee DLP Endpoint  [version 11.6.400.342]'
	'McAfee Endpoint Security Firewall  [version 10.7.0]'
	'McAfee Endpoint Security Platform  [version 10.7.0]'
	'McAfee Endpoint Security Threat Prevention  [version 10.7.0]'
	'McAfee Host Intrusion Prevention  [version 8.00.1600]'
	'McAfee Policy Auditor Agent  [version 6.5.0.241]'
	'McAfee Policy Auditor Agent  [version 6.5.1.229]'
	'McAfee Policy Auditor Agent  [version 6.5.2.307]'
	'McAfee RSD Sensor  [version 5.0.5.120]'
	'MediaAgent Instance001  [version 11.160.645.0]'
	'MediaAgent Instance001  [version 11.200.798.0]'
	'MediaAgentCore Instance001  [version 11.160.645.0]'
	'MediaAgentCore Instance001  [version 11.200.798.0]'
	'Microsoft .NET Framework 4 Multi-Targeting Pack  [version 4.0.30319]'
	'Microsoft .NET Framework 4.5 Multi-Targeting Pack  [version 4.5.50710]'
	'Microsoft .NET Framework 4.5.1 Multi-Targeting Pack  [version 4.5.50932]'
	'Microsoft .NET Framework 4.5.1 Multi-Targeting Pack (ENU)  [version 4.5.50932]'
	'Microsoft .NET Framework 4.5.1 SDK  [version 4.5.51641]'
	'Microsoft .NET Framework 4.5.2  [version 4.5.51209]'
	'Microsoft .NET Framework 4.5.2 Multi-Targeting Pack  [version 4.5.51209]'
	'Microsoft .NET Framework 4.5.2 Multi-Targeting Pack (ENU)  [version 4.5.51209]'
	'Microsoft Access MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Analysis Services ADOMD.NET  [version 14.0.1000.397]'
	'Microsoft Analysis Services OLE DB Provider  [version 15.0.800.90]'
	'Microsoft Application Error Reporting  [version 12.0.6012.5000]'
	'Microsoft Application Error Reporting  [version 12.0.6015.5000]'
	'Microsoft ASP.NET MVC 4  [version 4.0.20714.0]'
	'Microsoft ASP.NET MVC 4 Runtime  [version 4.0.40804.0]'
	'Microsoft ASP.NET Web Pages 2 Runtime  [version 2.0.20713.0]'
	'Microsoft BitLocker Administration and Monitoring  [version 2.5.1100.0]'
	'Microsoft BitLocker Administration and Monitoring  [version 2.5.1125.0]'
	'Microsoft BitLocker Administration and Monitoring 2.5 Update 1(KB3122998)  [version 2.5.1125.0]'
	'Microsoft Build Tools 14.0 (amd64)  [version 14.0.23107]'
	'Microsoft Build Tools 14.0 (x86)  [version 14.0.23107]'
	'Microsoft Build Tools Language Resources 14.0 (amd64)  [version 14.0.23107]'
	'Microsoft Build Tools Language Resources 14.0 (x86)  [version 14.0.23107]'
	'Microsoft Deployment Toolkit (6.3.8456.1000)  [version 6.3.8456.1000]'
	'Microsoft Endpoint Configuration Manager Central Administration Site Setup  [version 5.00.9058.1000]'
	'Microsoft Endpoint Configuration Manager Console  [version 5.2006.1026.1000]'
	'Microsoft Endpoint Configuration Manager Console  [version 5.2107.1059.1000]'
	'Microsoft Endpoint Configuration Manager Primary Site Setup  [version 5.00.9058.1000]'
	'Microsoft Excel MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Help Viewer 1.1  [version 1.1.40219]'
	'Microsoft Help Viewer 2.2  [version 2.2.23107]'
	'Microsoft Monitoring Agent  [version 10.19.10014.0]'
	'Microsoft Monitoring Agent  [version 7.1.10184.0]'
	'Microsoft NetBanner  [version 2.1.161]'
	'Microsoft ODBC Driver 11 for SQL Server  [version 12.1.4100.1]'
	'Microsoft ODBC Driver 11 for SQL Server  [version 12.3.6164.21]'
	'Microsoft ODBC Driver 11 for SQL Server  [version 12.3.6433.1]'
	'Microsoft ODBC Driver 13 for SQL Server  [version 13.0.811.168]'
	'Microsoft ODBC Driver 13 for SQL Server  [version 14.0.1000.169]'
	'Microsoft Office 2003 Web Components  [version 12.0.6213.1000]'
	'Microsoft Office Professional Plus 2016  [version 16.0.4266.1001]'
	'Microsoft Office Proofing Tools 2016 - English  [version 16.0.4266.1001]'
	'Microsoft OLE DB Driver for SQL Server  [version 18.3.0.0]'
	'Microsoft Outlook MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Policy Platform  [version 68.1.1010.0]'
	'Microsoft PowerPoint MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Publisher MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Report Viewer 2012 Runtime  [version 11.1.3452.0]'
	'Microsoft Report Viewer 2014 Runtime  [version 12.0.2000.8]'
	'Microsoft Report Viewer 2015 Runtime  [version 12.0.2402.15]'
	'Microsoft Report Viewer Redistributable 2008 (KB971119)  [version 9.0.30731]'
	'Microsoft Report Viewer Redistributable 2008 SP1'
	'Microsoft ReportViewer 2010 SP1 Redistributable (KB2549864)  [version 10.0.40220]'
	'Microsoft Silverlight  [version 5.1.50907.0]'
	'Microsoft Silverlight  [version 5.1.50918.0]'
	'Microsoft SQL Server 2008 R2 (64-bit)'
	'Microsoft SQL Server 2008 R2 Management Objects  [version 10.51.2500.0]'
	'Microsoft SQL Server 2008 R2 Native Client  [version 10.53.6560.0]'
	'Microsoft SQL Server 2008 R2 Policies  [version 10.50.1600.1]'
	'Microsoft SQL Server 2008 R2 Report Builder 3.0  [version 10.50.1600.1]'
	'Microsoft SQL Server 2008 R2 RsFx Driver  [version 10.53.6000.34]'
	'Microsoft SQL Server 2008 R2 Setup (English)  [version 10.53.6000.34]'
	'Microsoft SQL Server 2008 R2 Setup (English)  [version 10.53.6560.0]'
	'Microsoft SQL Server 2008 Setup Support Files   [version 10.3.5500.0]'
	'Microsoft SQL Server 2012 Management Objects   [version 11.0.2100.60]'
	'Microsoft SQL Server 2012 Management Objects   [version 11.1.3000.0]'
	'Microsoft SQL Server 2012 Management Objects  (x64)  [version 11.0.2100.60]'
	'Microsoft SQL Server 2012 Native Client   [version 11.0.2100.60]'
	'Microsoft SQL Server 2012 Native Client   [version 11.3.6538.0]'
	'Microsoft SQL Server 2012 Native Client   [version 11.3.6540.0]'
	'Microsoft SQL Server 2012 Native Client   [version 11.4.7001.0]'
	'Microsoft SQL Server 2012 Native Client   [version 11.4.7462.6]'
	'Microsoft SQL Server 2014 (64-bit)'
	'Microsoft SQL Server 2014 Management Objects   [version 12.0.2000.8]'
	'Microsoft SQL Server 2014 Management Objects  (x64)  [version 12.0.2000.8]'
	'Microsoft SQL Server 2014 Policies   [version 12.0.2000.8]'
	'Microsoft SQL Server 2014 Policies   [version 12.3.6024.0]'
	'Microsoft SQL Server 2014 RsFx Driver  [version 12.3.6164.21]'
	'Microsoft SQL Server 2014 RsFx Driver  [version 12.3.6433.1]'
	'Microsoft SQL Server 2014 Setup (English)  [version 12.1.4100.1]'
	'Microsoft SQL Server 2014 Setup (English)  [version 12.3.6164.21]'
	'Microsoft SQL Server 2014 Setup (English)  [version 12.3.6433.1]'
	'Microsoft SQL Server 2014 Transact-SQL Compiler Service   [version 12.1.4100.1]'
	'Microsoft SQL Server 2014 Transact-SQL Compiler Service   [version 12.3.6164.21]'
	'Microsoft SQL Server 2014 Transact-SQL Compiler Service   [version 12.3.6433.1]'
	'Microsoft SQL Server 2014 Transact-SQL ScriptDom   [version 12.1.4100.1]'
	'Microsoft SQL Server 2014 Transact-SQL ScriptDom   [version 12.3.6164.21]'
	'Microsoft SQL Server 2014 Transact-SQL ScriptDom   [version 12.3.6433.1]'
	'Microsoft SQL Server 2014 Upgrade Advisor   [version 12.0.2000.8]'
	'Microsoft SQL Server 2016 (64-bit)'
	'Microsoft SQL Server 2016 Report Builder  [version 15.0.900.71]'
	'Microsoft SQL Server 2016 RsFx Driver  [version 13.2.5865.1]'
	'Microsoft SQL Server 2016 Setup (English)  [version 13.2.5026.0]'
	'Microsoft SQL Server 2016 Setup (English)  [version 13.2.5865.1]'
	'Microsoft SQL Server 2016 T-SQL Language Service   [version 13.0.14500.10]'
	'Microsoft SQL Server 2016 T-SQL ScriptDom   [version 13.2.5026.0]'
	'Microsoft SQL Server 2017'
	'Microsoft SQL Server 2017 Policies   [version 14.0.1000.169]'
	'Microsoft SQL Server 2017 Setup (English)  [version 14.0.1000.169]'
	'Microsoft SQL Server 2017 T-SQL Language Service   [version 14.0.17285.0]'
	'Microsoft SQL Server Compact 3.5 SP2 ENU  [version 3.5.8080.0]'
	'Microsoft SQL Server Compact 3.5 SP2 Query Tools ENU  [version 3.5.8080.0]'
	'Microsoft SQL Server Compact 3.5 SP2 x64 ENU  [version 3.5.8080.0]'
	'Microsoft SQL Server Data-Tier Application Framework (x86)  [version 14.0.4127.1]'
	'Microsoft SQL Server Management Studio - 17.9  [version 14.0.17285.0]'
	'Microsoft SQL Server System CLR Types  [version 10.51.2500.0]'
	'Microsoft SQL Server System CLR Types (x64)  [version 10.53.6000.34]'
	'Microsoft System Center Operations Manager  [version 10.19.10050.0]'
	'Microsoft System CLR Types for SQL Server 2012  [version 11.0.2100.60]'
	'Microsoft System CLR Types for SQL Server 2012  [version 11.1.3000.0]'
	'Microsoft System CLR Types for SQL Server 2012 (x64)  [version 11.0.2100.60]'
	'Microsoft System CLR Types for SQL Server 2014  [version 12.0.2402.11]'
	'Microsoft System CLR Types for SQL Server 2014  [version 12.1.4100.1]'
	'Microsoft System CLR Types for SQL Server 2014 (x64)  [version 12.3.6164.21]'
	'Microsoft System CLR Types for SQL Server 2014 (x64)  [version 12.3.6433.1]'
	'Microsoft System CLR Types for SQL Server 2016  [version 13.2.5026.0]'
	'Microsoft System CLR Types for SQL Server 2017  [version 14.0.1000.169]'
	'Microsoft Visual C++ 2005 Redistributable  [version 8.0.61001]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.56336]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.61000]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.17  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.21022  [version 9.0.21022]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.17  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4974  [version 9.0.30729.4974]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2010  x86 Redistributable - 10.0.30319  [version 10.0.30319]'
	'Microsoft Visual C++ 2010  x86 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2010  x86 Runtime - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.61030  [version 11.0.61030.0]'
	'Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.61030  [version 11.0.61030.0]'
	'Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.30501  [version 12.0.30501.0]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.30501  [version 12.0.30501.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x64 Debug Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Debug Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24212  [version 14.0.24212.0]'
	'Microsoft Visual C++ 2015 x64 Debug Runtime - 14.0.23026  [version 14.0.23026]'
	'Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x86 Debug Runtime - 14.0.23026  [version 14.0.23026]'
	'Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.25.28508  [version 14.25.28508.3]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.28.29913  [version 14.28.29913.0]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.28.29914  [version 14.28.29914.0]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x86) - 14.25.28508  [version 14.25.28508.3]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x86) - 14.28.29913  [version 14.28.29913.0]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x86) - 14.28.29914  [version 14.28.29914.0]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.11.25325  [version 14.11.25325.0]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.15.26706  [version 14.15.26706.0]'
	'Microsoft Visual C++ 2017 Redistributable (x86) - 14.15.26706  [version 14.15.26706.0]'
	'Microsoft Visual C++ 2017 x64 Additional Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2017 x64 Additional Runtime - 14.15.26706  [version 14.15.26706]'
	'Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.15.26706  [version 14.15.26706]'
	'Microsoft Visual C++ 2017 x86 Additional Runtime - 14.15.26706  [version 14.15.26706]'
	'Microsoft Visual C++ 2017 x86 Minimum Runtime - 14.15.26706  [version 14.15.26706]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.25.28508  [version 14.25.28508]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.28.29913  [version 14.28.29913]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.28.29914  [version 14.28.29914]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.25.28508  [version 14.25.28508]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.28.29913  [version 14.28.29913]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.28.29914  [version 14.28.29914]'
	'Microsoft Visual C++ 2019 X86 Additional Runtime - 14.25.28508  [version 14.25.28508]'
	'Microsoft Visual C++ 2019 X86 Additional Runtime - 14.28.29913  [version 14.28.29913]'
	'Microsoft Visual C++ 2019 X86 Additional Runtime - 14.28.29914  [version 14.28.29914]'
	'Microsoft Visual C++ 2019 X86 Minimum Runtime - 14.25.28508  [version 14.25.28508]'
	'Microsoft Visual C++ 2019 X86 Minimum Runtime - 14.28.29913  [version 14.28.29913]'
	'Microsoft Visual C++ 2019 X86 Minimum Runtime - 14.28.29914  [version 14.28.29914]'
	'Microsoft Visual J# 2.0 Redistributable Package - SE (x64)'
	'Microsoft Visual J# 2.0 Redistributable Package - SE (x64)  [version 2.0.50728]'
	'Microsoft Visual Studio 2010 Shell (Isolated) - ENU  [version 10.0.40219]'
	'Microsoft Visual Studio 2015 Shell (Isolated)  [version 14.0.23107.10]'
	'Microsoft Visual Studio 2015 Shell (Isolated)  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Isolated) Resources  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Minimum)  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Minimum) Interop Assemblies  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Minimum) Resources  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 XAML Designer  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 XAML Designer - ENU  [version 14.0.23107]'
	'Microsoft Visual Studio Services Hub  [version 1.0.23107.00]'
	'Microsoft Visual Studio Tools for Applications 2.0 - ENU  [version 9.0.35191]'
	'Microsoft Visual Studio Tools for Applications 2015  [version 14.0.23829]'
	'Microsoft Visual Studio Tools for Applications 2015 Finalizer  [version 14.0.23829]'
	'Microsoft Visual Studio Tools for Applications 2015 Language Support  [version 14.0.23107.20]'
	'Microsoft Visual Studio Tools for Applications 2015 Language Support - ENU Language Pack  [version 14.0.23107.20]'
	'Microsoft Visual Studio Tools for Applications 2015 Language Support Finalizer  [version 14.0.23107.20]'
	'Microsoft Visual Studio Tools for Applications 2015 x64 Hosting Support  [version 14.0.23829]'
	'Microsoft Visual Studio Tools for Applications 2015 x86 Hosting Support  [version 14.0.23829]'
	'Microsoft VSS Writer for SQL Server 2014  [version 12.3.6024.0]'
	'Microsoft VSS Writer for SQL Server 2016  [version 13.2.5026.0]'
	'Microsoft VSS Writer for SQL Server 2017  [version 14.0.1000.169]'
	'Microsoft Word MUI (English) 2016  [version 16.0.4266.1001]'
	'Mobile Reach  [version 4.2.1652]'
	'None'
	'Npcap OEM  [version 1.10]'
	'OA3Tool  [version 10.1.22000.1]'
	'OACheck  [version 10.1.22000.1]'
	'OATool  [version 10.1.22000.1]'
	'OMNIKEY 3x21 PC/SC Driver  [version 3.0.0.0]'
	'Orchestrator Integration Pack for PowerShell Script Execution 1.2  [version 1.2]'
	'Oscdimg (DesktopEditions)  [version 10.1.22000.1]'
	'Oscdimg (OnecoreUAP)  [version 10.1.22000.1]'
	'Outils de vÃ©rification linguistique 2016 de Microsoft OfficeÂ - FranÃ§ais  [version 16.0.4266.1001]'
	'Portal Web Site  [version 5.00.8786.1000]'
	'PowerVault Modular Disk Storage Manager  [version 11.25.xx06.0026]'
	'Python 3.10.1 Core Interpreter (64-bit)  [version 3.10.1150.0]'
	'Python 3.10.1 Development Libraries (64-bit)  [version 3.10.1150.0]'
	'Python 3.10.1 Executables (64-bit)  [version 3.10.1150.0]'
	'Python 3.10.1 pip Bootstrap (64-bit)  [version 3.10.1150.0]'
	'Python 3.10.1 Standard Library (64-bit)  [version 3.10.1150.0]'
	'Python 3.10.1 Utility Scripts (64-bit)  [version 3.10.1150.0]'
	'Python 3.6.6 Core Interpreter (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 Development Libraries (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 Documentation (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 Executables (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 pip Bootstrap (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 Standard Library (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 Tcl/Tk Support (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 Test Suite (64-bit)  [version 3.6.6150.0]'
	'Python 3.6.6 Utility Scripts (64-bit)  [version 3.6.6150.0]'
	'Python 3.8.1 Core Interpreter (64-bit)  [version 3.8.1150.0]'
	'Python 3.8.1 Executables (64-bit)  [version 3.8.1150.0]'
	'Python 3.8.1 pip Bootstrap (64-bit)  [version 3.8.1150.0]'
	'Python 3.8.1 Standard Library (64-bit)  [version 3.8.1150.0]'
	'RabbitMQ Server (SolarWinds Distribution)  [version 1.7.50057.0]'
	'Right Click Tools  [version 2.1]'
	'Right Click Tools  [version 4.6.2103.5701]'
	'Roslyn Language Services - x86  [version 14.0.23107]'
	'SCAP Compliance Checker 5.0  [version 5.0]'
	'SCAP Compliance Checker 5.2  [version 5.2]'
	'SCAP Compliance Checker 5.3  [version 5.3]'
	'SCAP Compliance Checker 5.4.2  [version 5.4.2]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB2972107)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB2972216)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB2978128)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3023224)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3037581)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3074230)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3074550)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3097996)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3098781)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3122656)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3127229)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3163251)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB4552952)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB4565583v3)  [version 3]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB4569743)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB4578983)  [version 1]'
	'Security Update for Microsoft Outlook 2016 (KB5001942) 64-Bit Edition'
	'Service Pack 1 for SQL Server 2014 (KB3058865) (64-bit)  [version 12.1.4100.1]'
	'Service Pack 2 for SQL Server 2014 (KB3171021) (64-bit)  [version 12.2.5000.0]'
	'Service Pack 2 for SQL Server 2016 (KB4052908) (64-bit)  [version 13.2.5026.0]'
	'Service Pack 3 for SQL Server 2008 R2 (KB2979597) (64-bit)  [version 10.53.6000.34]'
	'Service Pack 3 for SQL Server 2014 (KB4022619) (64-bit)  [version 12.3.6024.0]'
	'Snare for Vista version 1.1.2  [version 1.1.2]'
	'Snare version 4.0.0.2  [version 4.0.0.2]'
	'Snare version 4.0.2 (Open Source)  [version 4.0.2]'
	'SolarWinds Active Diagnostics 2020.2.6.50031  [version 20.2.6.50031]'
	'SolarWinds Administration Service - 2020.2.6.50059  [version 20.2.6.50059]'
	'SolarWinds Agent 2020.2.50025.6  [version 120.2.50025.6]'
	'SolarWinds Collector v2.22.50111  [version 2.22.50111.0]'
	'SolarWinds Cortex Orion Integration v8.0.50059.0  [version 8.0.50059.0]'
	'SolarWinds Cortex v8.0.50149.0  [version 8.0.50149.0]'
	'SolarWinds Enterprise Operations Console v2020.2.6.50040  [version 120.2.50040.6]'
	'SolarWinds HighAvailability  [version 120.2.6.50106]'
	'SolarWinds HighAvailability Orion Plugin  [version 120.2.0.50193]'
	'SolarWinds Information Service v2020.2.6.50109  [version 120.2.50109.6]'
	'SolarWinds IP Address Manager v2020.2.6  [version 120.2.50056.6]'
	'SolarWinds Job Engine v2.19.50102  [version 2.19.50102.0]'
	'SolarWinds License Manager  [version 4.0.0.178]'
	'SolarWinds MIBs v1.2.0.50010  [version 1.2.0.50010]'
	'SolarWinds Network Topology Mapper  [version 2.2.816.2]'
	'SolarWinds Network Topology Mapper 2.2.816.2  [version 2.2.816.2]'
	'SolarWinds Orion Core Services 2020.2.6  [version 120.2.50103.65120]'
	'SolarWinds Orion Improvement Program v3.4.50017.0  [version 3.4.50017.0]'
	'SolarWinds Orion NetFlow Traffic Analyzer 2020.2  [version 120.2.50057.6]'
	'SolarWinds Orion NetPath 2020.2.6  [version 1.7.50106.0]'
	'SolarWinds Orion Network Atlas v1.23.50014  [version 1.23.50014.0]'
	'SolarWinds Orion Network Configuration Manager v2020.2.6  [version 120.2.50085.6]'
	'SolarWinds Orion Network Performance Monitor 2020.2.6  [version 120.2.50104.6]'
	'SolarWinds Orion QoE 2.11.50068.0  [version 2.11.50068.0]'
	'SolarWinds Orion SyslogTraps v1.6.0  [version 1.6.50197.0]'
	'SolarWinds Orion User Device Tracker v2020.2.6  [version 120.2.50115.6]'
	'SolarWinds Recommendations v3.0.0  [version 3.0.50074.0]'
	'SolarWinds SCP Server  [version 2.2.0.110]'
	'SolarWinds SCP Server  [version 2.2.0.120]'
	'SolarWinds SCP Server  [version 2.2.0.50025]'
	'SolarWinds TFTP Server  [version 11.2.0.50020]'
	'Solarwinds ToolsetOnTheWeb v2020.2.6  [version 120.2.50037.6]'
	'SolarWinds Virtual Infrastructure Monitor v2020.2.6  [version 120.2.50158.6]'
	'SolarWinds Web Performance Monitor Recorder (deprecated) v2020.2.50099.6  [version 120.2.50259.6]'
	'SolarWinds Web Performance Monitor Recorder v2020.2.50099.6  [version 120.2.50099.6]'
	'SolarWinds Web Performance Monitor Transaction Player v2020.2.50099.6  [version 120.2.50099.6]'
	'SolarWinds Web Performance Monitor Transaction Player v2020.2.6  [version 120.2.50259.6]'
	'SolarWinds Web Performance Monitor v2020.2.50099.6  [version 120.2.50259.6]'
	'SQL Server 2008 R2 SP2 Client Tools  [version 10.53.6000.34]'
	'SQL Server 2008 R2 SP2 Common Files  [version 10.53.6000.34]'
	'SQL Server 2008 R2 SP2 Management Studio  [version 10.53.6000.34]'
	'SQL Server 2014 Client Tools  [version 12.1.4100.1]'
	'SQL Server 2014 Client Tools  [version 12.3.6024.0]'
	'SQL Server 2014 Common Files  [version 12.1.4100.1]'
	'SQL Server 2014 Common Files  [version 12.3.6024.0]'
	'SQL Server 2014 Database Engine Services  [version 12.3.6024.0]'
	'SQL Server 2014 Database Engine Shared  [version 12.3.6024.0]'
	'SQL Server 2014 Full text search  [version 12.3.6024.0]'
	'SQL Server 2014 Management Studio  [version 12.1.4100.1]'
	'SQL Server 2014 Management Studio  [version 12.3.6024.0]'
	'SQL Server 2014 Reporting Services  [version 12.1.4100.1]'
	'SQL Server 2014 Reporting Services  [version 12.3.6024.0]'
	'SQL Server 2016 Batch Parser  [version 13.0.1601.5]'
	'SQL Server 2016 Client Tools  [version 13.0.14500.10]'
	'SQL Server 2016 Client Tools Extensions  [version 13.2.5026.0]'
	'SQL Server 2016 Common Files  [version 13.2.5026.0]'
	'SQL Server 2016 Connection Info  [version 13.0.16108.4]'
	'SQL Server 2016 Database Engine Services  [version 13.2.5026.0]'
	'SQL Server 2016 Database Engine Shared  [version 13.2.5026.0]'
	'SQL Server 2016 DMF  [version 13.0.1601.5]'
	'SQL Server 2016 Full text search  [version 13.2.5026.0]'
	'SQL Server 2016 Reporting Services  [version 13.2.5026.0]'
	'SQL Server 2016 Shared Management Objects  [version 13.0.16107.4]'
	'SQL Server 2016 Shared Management Objects  [version 13.0.16116.4]'
	'SQL Server 2016 Shared Management Objects Extensions  [version 13.2.5026.0]'
	'SQL Server 2016 SQL Diagnostics  [version 13.0.1601.5]'
	'SQL Server 2016 XEvent  [version 13.0.1601.5]'
	'SQL Server 2017 Batch Parser  [version 14.0.1000.169]'
	'SQL Server 2017 Client Tools  [version 14.0.1000.169]'
	'SQL Server 2017 Client Tools Extensions  [version 14.0.1000.169]'
	'SQL Server 2017 Common Files  [version 14.0.1000.169]'
	'SQL Server 2017 Connection Info  [version 14.0.1000.169]'
	'SQL Server 2017 DMF  [version 14.0.1000.169]'
	'SQL Server 2017 Integration Services Scale Out Management Portal  [version 14.0.1000.169]'
	'SQL Server 2017 Management Studio Extensions  [version 14.0.3026.27]'
	'SQL Server 2017 Shared Management Objects  [version 14.0.1000.169]'
	'SQL Server 2017 Shared Management Objects Extensions  [version 14.0.1000.169]'
	'SQL Server 2017 SQL Diagnostics  [version 14.0.1000.169]'
	'SQL Server 2017 XEvent  [version 14.0.1000.169]'
	'SQL Server Browser for SQL Server 2014  [version 12.3.6024.0]'
	'Sql Server Customer Experience Improvement Program  [version 10.53.6000.34]'
	'Sql Server Customer Experience Improvement Program  [version 12.1.4100.1]'
	'Sql Server Customer Experience Improvement Program  [version 12.3.6024.0]'
	'Sql Server Customer Experience Improvement Program  [version 13.2.5026.0]'
	'SQL Server Management Studio  [version 14.0.17285.0]'
	'SQL Server Management Studio for Analysis Services  [version 14.0.17285.0]'
	'SQL Server Management Studio for Reporting Services  [version 14.0.17285.0]'
	'SQLServeriDataAgent Instance001  [version 11.140.580.0]'
	'SQLServeriDataAgent Instance001  [version 11.160.645.0]'
	'SQLServeriDataAgent Instance001  [version 11.200.798.0]'
	'SSMS Post Install Tasks  [version 14.0.17285.0]'
	'System Center 2012 - Operations Manager Gateway  [version 7.1.10226.0]'
	'System Center 2012 R2 Operations Manager  [version 7.1.10226.0]'
	'System Center 2016 Orchestrator Integration Pack for Active Directory  [version 7.3.51.0]'
	'System Center Configuration Manager Central Administration Site Setup  [version 5.00.8412.1000]'
	'System Center Configuration Manager Console  [version 5.1810.1075.1000]'
	'System Center Configuration Manager Primary Site Setup  [version 5.00.8498.1000]'
	'System Center Integration Pack for Azure  [version 7.3.95.0]'
	'System Center Integration Pack for Exchange Admin  [version 7.3.27.0]'
	'System Center Integration Pack for Exchange User  [version 7.3.24.0]'
	'System Center Integration Pack for Rest  [version 7.3.95.0]'
	'System Center Integration Pack for SharePoint  [version 7.3.34.0]'
	'System Center Integration Pack for System Center 2016 Data Protection Manager  [version 7.3.95.0]'
	'System Center Integration Pack for System Center 2016 Virtual Machine Manager  [version 7.3.95.0]'
	'System Center Integration Pack for System Center Configuration Manager  [version 7.4.18.0]'
	'System Center Integration Pack for System Center Operations Manager  [version 7.4.18.0]'
	'System Center Integration Pack for VMware vSphere  [version 7.3.26.0]'
	'System Center Operations Manager 2007 R2 Authoring Console  [version 6.1.7221.49]'
	'System Center Operations Manager 2007 R2 Authoring Resource Kit  [version 6.0.6726.0]'
	'System Center Operations Manager 2012 Console  [version 7.1.10226.0]'
	'System Center Operations Manager 2012 Server  [version 7.1.10226.0]'
	'System Center Operations Manager 2012 Web Console  [version 7.1.10226.0]'
	'System Center Operations Manager Console  [version 10.19.10050.0]'
	'System Center Operations Manager Gateway  [version 10.19.10050.0]'
	'System Center Operations Manager Reporting Server  [version 10.19.10050.0]'
	'System Center Operations Manager Server  [version 10.19.10050.0]'
	'System Center Operations Manager Web Console  [version 10.19.10050.0]'
	'System Center Orchestrator Management Server  [version 7.3.149.0]'
	'System Center Orchestrator Runbook Designer  [version 7.3.149.0]'
	'System Center Orchestrator Runbook Server  [version 7.3.149.0]'
	'System Center Orchestrator Web Features  [version 7.3.149.0]'
	'System Center Updates Publisher 2011  [version 5.00.1727.0000]'
	'Toolkit Documentation  [version 10.1.19041.1]'
	'Toolkit Documentation  [version 10.1.22000.1]'
	'Tools for .Net 3.5  [version 3.11.50727]'
	'Tumbleweed ONE-NET Configuration  [version TL-Enabled]'
	'UniversalForwarder  [version 7.2.2.0]'
	'UniversalForwarder  [version 7.3.3.0]'
	'Update for  (KB2504637)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB3210139)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4014514)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4040977)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4054992)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4054995)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4096495)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4338417)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4344149)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4457019)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4459945)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4470637)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4480059)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4483455)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4488669)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4507001)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4532929)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4552920)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4569780)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4578955)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4578955v2)  [version 2]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4578955v4)  [version 4]'
	'Update for Microsoft .NET Framework 4.5.2 (KB5007167)  [version 1]'
	'Update for Microsoft Visual Studio 2015 (KB3095681)  [version 14.0.23317]'
	'User State Migration Tool  [version 10.1.19041.1]'
	'User State Migration Tool (ClientCore)  [version 10.1.22000.1]'
	'User State Migration Tool (DesktopEditions)  [version 10.1.22000.1]'
	'User State Migration Tool (OnecoreUAP)  [version 10.1.22000.1]'
	'VirtualServerAgent Instance001  [version 11.160.645.0]'
	'VirtualServerAgent Instance001  [version 11.200.798.0]'
	'Visual Studio 2010 Prerequisites - English  [version 10.0.40219]'
	'Visual Studio 2015 Prerequisites  [version 14.0.23107]'
	'Visual Studio 2015 Prerequisites - ENU Language Pack  [version 14.0.23107]'
	'VMware Remote Console Plug-in 5.1  [version 0.0.1]'
	'VMware Tools  [version 11.3.0.18090558]'
	'VMware vSphere CLI  [version 6.0.0.7357]'
	'VMware vSphere Client 6.0  [version 6.0.0.7597]'
	'VMware vSphere PowerCLI  [version 6.0.0.7857]'
	'VSSHardwareProvider Instance001  [version 11.160.645.0]'
	'VSSProvider Instance001  [version 11.160.645.0]'
	'VSSProvider Instance001  [version 11.200.798.0]'
	'Windows Assessment and Deployment Kit  [version 10.1.22000.1]'
	'Windows Assessment and Deployment Kit - Windows 10  [version 10.1.19041.1]'
	'Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons  [version 10.1.22000.1]'
	'Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10  [version 10.1.19041.1]'
	'Windows Deployment Customizations  [version 10.1.19041.1]'
	'Windows Deployment Customizations  [version 10.1.22000.1]'
	'Windows Deployment Image Servicing and Management - Headers and Libraries  [version 10.1.22000.1]'
	'Windows Deployment Image Servicing and Management Tools (DesktopEditions)  [version 10.1.22000.1]'
	'Windows Deployment Image Servicing and Management Tools (OnecoreUAP)  [version 10.1.22000.1]'
	'Windows Deployment Tools  [version 10.1.19041.1]'
	'Windows Deployment Tools  [version 10.1.22000.1]'
	'Windows Deployment Tools Environment  [version 10.1.22000.1]'
	'Windows PE ARM ARM64  [version 10.1.19041.1]'
	'Windows PE ARM ARM64 wims  [version 10.1.19041.1]'
	'Windows PE Boot Files (DesktopEditions)  [version 10.1.22000.1]'
	'Windows PE Boot Files (OnecoreUAP)  [version 10.1.22000.1]'
	'Windows PE Optional Packages (DesktopEditions)  [version 10.1.22000.1]'
	'Windows PE Scripts  [version 10.1.22000.1]'
	'Windows PE wims (DesktopEditions)  [version 10.1.22000.1]'
	'Windows PE x86 x64  [version 10.1.19041.1]'
	'Windows PE x86 x64 wims  [version 10.1.19041.1]'
	'Windows Setup Files (ClientCore)  [version 10.1.22000.1]'
	'Windows Setup Files (DesktopEditions)  [version 10.1.22000.1]'
	'Windows Setup Files (Holographic)  [version 10.1.22000.1]'
	'Windows Setup Files (OnecoreUAP)  [version 10.1.22000.1]'
	'Windows Setup Files (ShellCommon)  [version 10.1.22000.1]'
	'Windows System Image Manager on amd64  [version 10.1.19041.1]'
	'Windows System Image Manager on amd64  [version 10.1.22000.1]'
	'WindowsFileSystemiDataAgentAdvanced Instance001  [version 11.140.580.0]'
	'WindowsFileSystemiDataAgentAdvanced Instance001  [version 11.160.645.0]'
	'WindowsFileSystemiDataAgentAdvanced Instance001  [version 11.200.798.0]'
	'WindowsFileSystemiDataAgentCore Instance001  [version 11.140.580.0]'
	'WindowsFileSystemiDataAgentCore Instance001  [version 11.160.645.0]'
	'WindowsFileSystemiDataAgentCore Instance001  [version 11.200.798.0]'
	'WinPcap 4.1.3  [version 4.1.3036.3]'
	'WinPcapInst  [version 4.1.3036.3]'
	'WinZip 23.0  [version 23.0.13300]'
	'WorkFlowEngine Instance001  [version 11.160.645.0]'
	'WorkFlowEngine Instance001  [version 11.200.798.0]'
)

$approvedmibport = @(
	'22'
	'25'
	'53'
	'53'
	'67'
	'69'
	'80'
	'80'
	'81'
	'88'
	'88'
	'111'
	'123'
	'135'
	'135'
	'137'
	'139'
	'161'
	'162'
	'383'
	'389'
	'389'
	'442'
	'443'
	'443'
	'444'
	'445'
	'464'
	'464'
	'465'
	'500'
	'514'
	'515'
	'587'
	'591'
	'636'
	'636'
	'901'
	'1024'
	'1024'
	'1024'
	'1024'
	'1100'
	'1150'
	'1211'
	'1433'
	'1434'
	'1468'
	'1688'
	'1801'
	'2049'
	'2050'
	'2055'
	'2103'
	'2105'
	'2107'
	'2222'
	'2463'
	'2701'
	'2702'
	'3260'
	'3268'
	'3268'
	'3269'
	'3343'
	'3389'
	'3389'
	'3702'
	'4011'
	'4022'
	'4023'
	'4369'
	'5022'
	'5040'
	'5041'
	'5050'
	'5227'
	'5353'
	'5355'
	'5671'
	'5723'
	'5723'
	'5985'
	'7311'
	'7319'
	'7320'
	'7350'
	'7569'
	'8003'
	'8004'
	'8008'
	'8080'
	'8081'
	'8082'
	'8089'
	'8400'
	'8401'
	'8402'
	'8403'
	'8443'
	'8443'
	'8444'
	'8530'
	'8886'
	'9010'
	'9389'
	'9555'
	'9556'
	'9977'
	'9997'
	'9999'
	'10001'
	'10123'
	'17472'
	'17777'
	'17778'
	'17779'
	'17781'
	'17782'
	'17784'
	'20000'
	'25672'
	'35672'
	'40001'
	'40002'
	'47001'
	'49152'
	'49152'
	'49152'
	'49252'
	'63000'
	'65535'
	'50'
	'51'
	'500'
	'4500'
	49152..65535
)

$approvednceaport = @(
	'22'
	'25'
	'50'
	'51'
	'53'
	'53'
	'67'
	'80'
	'88'
	'123'
	'135'
	'137'
	'138'
	'139'
	'389'
	'443'
	'445'
	'464'
	'500'
	'515'
	'563'
	'591'
	'636'
	'923'
	'1433'
	'1900'
	'2177'
	'2696'
	'2701'
	'3268'
	'3269'
	'3389'
	'3702'
	'4500'
	'5040'
	'5050'
	'5222'
	'5353'
	'5355'
	'5985'
	'6200'
	'8081'
	'8082'
	'8089'
	'8443'
	'8444'
	'8888'
	'9191'
	'9191'
	'9997'
	'15003'
	'27000'
	49152..65535
)

$approvednceasoft = @(
	'{AEE4E052-F11C-11D4-BBD1-00600839BCB6}  [version 10.0]'
	'ACA & MEP 2016 Object Enabler  [version 7.8.41.0]'
	'ACA & MEP 2016 Object Enabler  [version 7.8.44.0]'
	'ACA & MEP 2018 Object Enabler  [version 8.0.73.0]'
	'ACAD Private  [version 20.1.49.0]'
	'ACAD Private  [version 22.0.49.0]'
	'ACCM  [version 3.2.4.5]'
	'ActivID ActivClient x64  [version 7.1.0.257]'
	'ActivID ActivClient x64  [version 7.1.0]'
	'ADIOS 2  [version 2.0.1]'
	'Adobe Acrobat 2017  [version 17.011.30175]'
	'Adobe Acrobat Reader 2017 MUI  [version 17.011.30175]'
	'Adobe Acrobat Reader 2017 MUI  [version 17.011.30180]'
	'Adobe Acrobat Reader 2017 MUI  [version 17.011.30188]'
	'Adobe Connect application  [version 18.7.10]'
	'Adobe Flash Player 32 NPAPI  [version 32.0.0.387]'
	'Adobe Flash Player 32 NPAPI  [version 32.0.0.445]'
	'Adobe Flash Player 32 PPAPI  [version 32.0.0.387]'
	'Adobe Flash Player 32 PPAPI  [version 32.0.0.445]'
	'Adobe Refresh Manager  [version 1.8.0]'
	'AdobeCC2019_EA  [version 1.0.0000]'
	'ALOHA Version 5.4.7  [version 5.4.7]'
	'APEX  [version 4]'
	'Arbortext IsoView 7.1  [version 7.1.00.31]'
	'ArcGIS Desktop 10.7.1  [version 10.7.11595]'
	'ArcGIS Earth  [version 1.9.2351]'
	'AutoCAD 2016  [version 20.1.107.0]'
	'AutoCAD 2016  [version 20.1.49.0]'
	'AutoCAD 2016 - English  [version 20.1.49.0]'
	'AutoCAD 2016 Language Pack - English  [version 20.1.49.0]'
	'AutoCAD 2018  [version 22.0.161.0]'
	'AutoCAD 2018 - English  [version 22.0.49.0]'
	'AutoCAD 2018 Language Pack - English  [version 22.0.154.0]'
	'AutoCAD 2018 VBA Enabler  [version 22.0.49.0]'
	'AutoCAD Architecture 2016 Core  [version 7.8.44.0]'
	'AutoCAD Architecture 2016 Language Core - English  [version 7.8.44.0]'
	'AutoCAD Architecture 2016 Language Shared - English  [version 7.8.44.0]'
	'AutoCAD Architecture 2016 Shared  [version 7.8.44.0]'
	'AutoCAD Architecture 2018 Core  [version 8.0.73.0]'
	'AutoCAD Architecture 2018 Language Core - English  [version 8.0.44.0]'
	'AutoCAD Architecture 2018 Language Shared - English  [version 8.0.44.26]'
	'AutoCAD Architecture 2018 Shared  [version 8.0.100.0]'
	'AutoCAD LT 2012 - English  [version 18.2.205.0]'
	'AutoCAD LT 2012 - English SP2  [version 1]'
	'AutoCAD LT 2012 Language Pack - English  [version 18.2.51.0]'
	'AutoCAD LT 2016 - English  [version 20.1.49.0]'
	'AutoCAD LT 2016 Language Pack - English  [version 20.1.49.0]'
	'AutoCAD MEP 2016  [version 7.8.44.0]'
	'AutoCAD MEP 2016 - English  [version 7.8.44.0]'
	'AutoCAD MEP 2016 Core  [version 7.8.106.0]'
	'AutoCAD MEP 2016 Language Core - English  [version 7.8.44.0]'
	'AutoCAD MEP 2018  [version 8.0.73.0]'
	'AutoCAD MEP 2018 - English  [version 8.0.44.0]'
	'AutoCAD MEP 2018 Core  [version 8.0.73.0]'
	'AutoCAD MEP 2018 Language Core - English  [version 8.0.44.0]'
	'AutoCAD Raster Design 2016  [version 20.1.49.0]'
	'AutoCAD Raster Design 2018  [version 22.0.49.0]'
	'Autodesk {28B89EEF-1004-0000-4102-CF3F3A09B77D}  Update  [version 8.0.44.26]'
	'Autodesk Advanced Material Library Image Library 2016  [version 6.3.0.15]'
	'Autodesk Advanced Material Library Image Library 2018  [version 16.11.1.0]'
	'Autodesk AutoCAD 2016 - English  [version 20.1.49.0]'
	'Autodesk AutoCAD 2016 Hotfix 4  [version 20.1.107.19]'
	'Autodesk AutoCAD 2016 SP 1  [version 20.1.107.0]'
	'Autodesk AutoCAD 2016.0.10  [version 20.1.107.26]'
	'Autodesk AutoCAD 2018 - English  [version 22.0.49.0]'
	'Autodesk AutoCAD 2018 VBA Enabler  [version 22.0.49.0]'
	'Autodesk AutoCAD Architecture 2018 Update  [version 8.0.100.0]'
	'Autodesk AutoCAD Civil 3D 2016 64 Bit Object Enabler on AutoCAD MEP 2016 - English - English (United States)  [version 965.0]'
	'Autodesk AutoCAD Civil 3D 2016 64 Bit Object Enabler on Autodesk AutoCAD Map 3D 2016 - English - English (United States)  [version 1132.0]'
	'Autodesk AutoCAD Civil 3D 2018  [version 12.0.1467.0]'
	'Autodesk AutoCAD Civil 3D 2018 - English  [version 12.0.1467.0]'
	'Autodesk AutoCAD Civil 3D 2018 - English  [version 12.0.842.0]'
	'Autodesk AutoCAD Civil 3D 2018 Language Pack - English  [version 12.0.1467.0]'
	'Autodesk AutoCAD Civil 3D 2018 Object Enabler 32 Bit  [version 12.0.842.0]'
	'Autodesk AutoCAD Civil 3D 2018 Private Pack  [version 12.0.842.0]'
	'Autodesk AutoCAD Civil 3D 2018.2 Object Enabler 64 Bit  [version 12.0.1385.0]'
	'Autodesk AutoCAD Civil 3D Extension  [version 18.1.1467.0]'
	'Autodesk AutoCAD LT 2016 - English  [version 20.1.49.0]'
	'Autodesk AutoCAD Map 3D 2016  [version 19.0.200.83]'
	'Autodesk AutoCAD Map 3D 2016 - English  [version 19.0.020.16]'
	'Autodesk AutoCAD Map 3D 2016 - English  [version 19.0.200.83]'
	'Autodesk AutoCAD Map 3D 2016 Language Pack - English  [version 19.0.020.16]'
	'Autodesk AutoCAD Map 3D 2016 Private  [version 19.0.020.16]'
	'Autodesk AutoCAD Map 3D 2016 SP1  [version 1]'
	'Autodesk AutoCAD Map 3D 2016 SP2  [version 1]'
	'Autodesk AutoCAD Map 3D 2018 - English  [version 21.0.015.11]'
	'Autodesk AutoCAD Map 3D 2018 Core  [version 21.0.100.6]'
	'Autodesk AutoCAD Map 3D 2018 Language Pack - English  [version 21.0.015.11]'
	'Autodesk AutoCAD Map 3D 2018 Private  [version 21.0.015.11]'
	'Autodesk AutoCAD MEP 2016 - English  [version 7.8.44.0]'
	'Autodesk AutoCAD MEP 2016 SP1  [version 7.8.106.0]'
	'Autodesk AutoCAD MEP 2018 - English  [version 8.0.44.0]'
	'Autodesk AutoCAD Raster Design 2016  [version 20.1.49.0]'
	'Autodesk AutoCAD Raster Design 2018  [version 22.0.49.0]'
	'Autodesk Certificate Package  (x64) - 5.1.4  [version 5.1.4.100]'
	'Autodesk Collaboration for Revit 2018  [version 18.3.3.18]'
	'Autodesk Content Service  [version 3.2.0.0]'
	'Autodesk Content Service Language Pack  [version 3.2.0.0]'
	'Autodesk Geotechnical Module 2018  [version 12.0.7.0]'
	'Autodesk Inventor Infrastructure Modeler Plugin  [version 18.1.31.0]'
	'Autodesk License Service (x64) - 5.1.6  [version 5.1.6.0]'
	'Autodesk Material Library 2016  [version 6.3.0.15]'
	'Autodesk Material Library 2018  [version 16.11.1.0]'
	'Autodesk Material Library Base Resolution Image Library 2016  [version 6.3.0.15]'
	'Autodesk Material Library Base Resolution Image Library 2018  [version 16.11.1.0]'
	'Autodesk Material Library Low Resolution Image Library 2018  [version 16.11.1.0]'
	'Autodesk Material Library Medium Resolution Image Library 2018  [version 16.11.1.0]'
	'Autodesk Network License Manager  [version 11.16.2.0]'
	'Autodesk Rail Layout Module 2018  [version 12.0.15.0]'
	'Autodesk Revit 2018'
	'Autodesk Revit 2018  [version 18.3.3.18]'
	'Autodesk Revit 2018.3.3  [version 18.3.3.18]'
	'Autodesk Revit DB Link 2018  [version 18.1.0.92]'
	'Autodesk Revit MEP Imperial Content  [version 2.1]'
	'Autodesk Revit MEP Metric Content  [version 2.1]'
	'Autodesk Revit Model Review 2018  [version 18.0.0.420]'
	'Autodesk Revit Site Designer Extension 2018  [version 18.1.0.31]'
	'Autodesk Shared Reference Point for Autodesk Civil 3D 2018  [version 12.0.6.0]'
	'Autodesk Shared Reference Point for Autodesk Revit 2018  [version 8.0.6.0]'
	'Autodesk Steel Connections for Revit 2018  [version 18.1.0.31]'
	'Autodesk Storm and Sanitary Analysis 2018  [version 12.0.42.0]'
	'Autodesk Storm and Sanitary Analysis 2018 x64 Plug-in  [version 12.0.42.0]'
	'Autodesk Subassembly Composer on Autodesk AutoCAD Civil 3D 2018 - English - English (United States)  [version 842.0]'
	'Autodesk Vehicle Tracking 2018 (64 bit)  [version 18.0.533.0]'
	'Autodesk Vehicle Tracking 2018 (64 bit)  [version 18.2.800.0]'
	'Autodesk Vehicle Tracking 2018 (64 bit) Core  [version 18.2.800.0]'
	'Autodesk Workflows 2018  [version 16.11.1.0]'
	'AutodeskÂ® Structural Precast Extension for RevitÂ®2018  [version 18.017.221.01 ]'
	'AWBS (Automated Weight and Balance System)  [version 10.2.006]'
	'Axway Desktop Validator  [version 4.12.1.0.0]'
	'Batch Print for Autodesk Revit 2018  [version 18.0.0.420]'
	'Bentley WaterGEMS V8i (SELECTseries 4) 08.11.04.57  [version 08.11.04.57]'
	'BLCC5  [version 1.0.0.0]'
	'Bonjour  [version 3.0.0.10]'
	'CAMEO Chemicals 2.7.1  [version 2.7.1]'
	'CAMEO Version 3.5.1  [version 3.5.1]'
	'Cisco AnyConnect Secure Mobility Client   [version 4.9.00086]'
	'Cisco AnyConnect Secure Mobility Client   [version 4.9.03049]'
	'Cisco AnyConnect Secure Mobility Client  [version 4.9.00086]'
	'Cisco AnyConnect Secure Mobility Client  [version 4.9.03049]'
	'Citrix Authentication Manager  [version 11.0.5000.18329]'
	'Citrix Receiver (HDX Flash Redirection)  [version 14.9.5000.7]'
	'Citrix Receiver 4.9 LTSR  [version 14.9.5000.7]'
	'Citrix Receiver Inside  [version 4.9.5000.4]'
	'Citrix Receiver(Aero)  [version 14.9.5000.7]'
	'Citrix Receiver(DV)  [version 14.9.5000.7]'
	'Citrix Receiver(USB)  [version 14.9.5000.7]'
	'Citrix Web Helper  [version 4.9.5000.5]'
	'Configuration Manager Client  [version 5.00.8740.1000]'
	'connectivity.boe.ccis.cpp-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.boe.connectsrv.client.http.cpp-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.boe.connectsrv.client.httpxir3.cpp-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.core.helpers.cpp-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.informix.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.informix.odbc.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.informix.odbc-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.jdbc.core.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.jdbc.core.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.jdbc.core-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.mysql.jdbc-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.mysql.jdbc-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.mysql.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.mysql.odbc.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.mysql.odbc-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.neoview.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.neoview.odbc.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.neoview.odbc-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.netezza.jdbc-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.netezza.jdbc-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.netezza.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.netezza.odbc.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.netezza.odbc-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.odbc.core.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.odbc.core.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.odbc.core-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.sybase.ctlib.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.sybase.ctlib.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.sybase.ctlib-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.teradata.jdbc-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.teradata.jdbc-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.teradata.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.teradata.odbc.config-4.0-en-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.drivers.teradata.odbc-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.helpers.cpp-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.tools.cscheck.config-4.0-core-nu  [version 14.1.4.1327]'
	'connectivity.connectionserver.tools.cscheck-4.0-core-32  [version 14.1.4.1327]'
	'connectivity.connectionserver.tools.cscheck-4.0-en-32  [version 14.1.4.1327]'
	'connectivity.foundation.cpp-4.0-core-32  [version 14.1.4.1327]'
	'CostWorks 2020  [version 16.04]'
	'Cross Match Live Scan Management System  [version 8.5.7.0030]'
	'Cross Match LSMS Federal MCIO-DFME Configuration  [version 3.1.0.0059]'
	'Cross Match LSMS Federal-ArmyCID Configuration  [version 3.0.0.0017]'
	'Cross Match LSMS OPM Configuration  [version 2.0.5.0033]'
	'crystalreports.boe.sdkplugins.java.crlov-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.boe.sdkplugins.java.managedreports-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.boe.sdkplugins.java-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.boe.sdkplugins.java-4.0-en-nu  [version 14.1.4.1327]'
	'crystalreports.cpp.businessview.clients.crw-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.businessview.clients.crw-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.businessview.sdk-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.businessview.sdk-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.charthelp-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.cractivexviewer-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.cractivexviewer-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.cslib-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.designer-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.designer-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.erom-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.erom-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.expmod-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dapp-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dapp-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2ddisk-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2ddisk-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dmapi-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dmapi-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dnotes-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dnotes-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dpost-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dpost-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dvim-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2dvim-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fcr-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fcr-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fhtml-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fhtml-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fodbc-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fodbc-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fpdf-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fpdf-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2frdef-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2frdef-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2frec-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2frec-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2frtf-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2frtf-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fsepv-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fsepv-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2ftext-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2ftext-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fwordw-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fwordw-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fxls-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fxls-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fxml2-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fxml2-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fxml-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.exporting.u2fxml-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.filedialog-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.filedialog-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.help-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.help-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.keycode.defn-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.cpp.parameterprompt-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.parameterprompt-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.printcontrol-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.printcontrol-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.ras.bv-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.ras.bv-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.registrywrapper-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.runtimeshare-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.runtimeshare-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.saptoolbar-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.saptoolbar-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.cpp.share.registry-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.share-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.cpp.share-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.crystalcommon.cpp.crlang-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.crystalcommon.cpp.crlogger-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.crystalcommon.dotnet-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.access-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.access-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.act-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.act-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.ado-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.ado-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.adodotnetinterop-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.adoplus-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.adoplus-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.btrieve-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.btrieve-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.com-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.com-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.db2-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.db2-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.ebs-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.fielddef-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.fielddef-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.filesystem-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.filesystem-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.informix-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.informix-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.java-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.javabeans-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.javabeans-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.jdbc-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.jdbc-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.jde-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.odbc-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.odbc-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.olap-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.olap-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.oracle-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.oracle-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2bbde-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2bbde-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2dbase-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2dbase-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2sevt-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2sevt-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2sexchange-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2sexchange-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2slog-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2slog-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2soutlk-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.p2soutlk-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.psenterprise-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.sap-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.sap-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.sforce-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.sforce-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.siebel-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.sybase-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.sybase-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.universe-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.universe-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.wic-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.wic-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.xml-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.driver.xml-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.querybuilder-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.querybuilder-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.share.registry-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.dataaccess.share-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.dataaccess.share-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.designers.java.launcher-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.partner.shared.cpp.pvlmapping-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.partner.shared.cpp-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.partner.shared.cpp-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.partner.shared.java.jde-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.partner.shared.java.siebel-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.rptpubwiz.cpp.help-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.rptpubwiz.cpp-4.0-core-32  [version 14.1.4.1327]'
	'crystalreports.rptpubwiz.cpp-4.0-en-32  [version 14.1.4.1327]'
	'crystalreports.sdk.java.repository-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.sdk.java.sdkcommon-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.webreporting.common-4.0-core-nu  [version 14.1.4.1327]'
	'crystalreports.webreporting.common-4.0-en-nu  [version 14.1.4.1327]'
	'cvom.java.ui_helpers-4.0-core-nu  [version 14.1.4.1327]'
	'cvom.java-4.0-core-nu  [version 14.1.4.1327]'
	'cvom.java-4.0-en-nu  [version 14.1.4.1327]'
	'Datawatch Monarch 14  [version 14.3.2.7917]'
	'Defense Working Capital Accounting System Client 6.01  [version 6.01]'
	'Definition Update for Microsoft Office 2013 (KB3115404) 32-Bit Edition'
	'DLwin  [version 10.2019.03.27]'
	'DLwin  [version 8.0]'
	'DoD Secure Host Baseline  [version 10.5.0]'
	'DWG TrueView 2013  [version 19.0.55.0]'
	'DYMO Label  [version 8.7.3.46663]'
	'Dynamo Core 1.3.2  [version 1.3.2.2480]'
	'Dynamo Revit 1.3.2  [version 1.3.2.2480]'
	'E-CAT / E20-II Configuration Services 2.21'
	'ECON4.0.23  [version 4.0.23]'
	'Education Software 2013 September Update  [version 11.3.161.0]'
	'Electronic Benchbook 2014  [version 2014]'
	'ePadLink ePad 12.4.12285  [version 12.4.12285]'
	'eTransmit for Autodesk Revit 2018  [version 18.0.0.420]'
	'FARO LS 1.1.600.6 (64bit)  [version 6.0.6.5]'
	'FEDLOG 9  [version 9]'
	'FFT 2.4 Client  [version 2.4.2]'
	'FitPro+  [version 3.0.0]'
	'Fixmo Sentinel  [version 1.6.0]'
	'FormIt Converter For Revit 2018  [version 1.9.3.0]'
	'foundation.bcm.cpp-4.0-core-32  [version 14.1.4.1327]'
	'foundation.bcm.java.boe-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.bcm.java.bundle-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.bcm.java.classes-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.bcm.java-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.javalibs.boe-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.javalibs.bundle-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.javalibs.classes-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.javalibs-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.locale_fallback.cpp-4.0-core-32  [version 14.1.4.1327]'
	'foundation.tracelog.cpp-4.0-core-32  [version 14.1.4.1327]'
	'foundation.tracelog.java.boe-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.tracelog.java.classes-4.0-core-nu  [version 14.1.4.1327]'
	'foundation.tracelog.java-4.0-core-nu  [version 14.1.4.1327]'
	'Freedom Scientific Authorization  [version 6.22.6.0]'
	'Freedom Scientific Elevation  [version 21.3.1.0]'
	'Freedom Scientific HookManager 1.0  [version 2.0.13.0]'
	'Freedom Scientific Synth  [version 21.3.1.0]'
	'Freedom Scientific WOW64 Proxy  [version 20.0.7.0]'
	'Freedom Scientific ZoomText 2020  [version 14.3.7.0]'
	'Freedom Scientific ZtVoiceEnable ZrWaveWriter'
	'Freedom Scientific ZtVoiceEnable Zt'
	'GDR 4232 for SQL Server 2014 (KB3194720) (64-bit)  [version 12.1.4232.0]'
	'Google Chrome  [version 85.0.4183.121]'
	'Google Chrome  [version 85.0.4183.83]'
	'Google Chrome  [version 86.0.4240.111]'
	'Google Chrome  [version 87.0.4280.66]'
	'Google Earth Pro  [version 7.3.3.7699]'
	'Google Update Helper  [version 1.3.36.31]'
	'Google Update Helper  [version 1.3.36.51]'
	'GPS Pathfinder Office  [version 5.85.0000]'
	'HASSM Navy  [version 1.00.0000]'
	'Herramientas de correcciÃ³n de Microsoft Office 2016'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2565063)  [version 1]'
	'Hourly Analysis Program 5.10'
	'HP LoadRunner - Load Generator  [version 12.53.845.0]'
	'HPE BPM Core Package  [version 9.30.71]'
	'HPE Business Process Monitor  [version 9.30]'
	'HPEBpmDocs  [version 9.30.101]'
	'HPEBpmJRE  [version 1.8.66]'
	'informationengine.qt.drivers.informix.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.mysql.jdbc-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.mysql.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.neoview.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.netezza.jdbc-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.netezza.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.sybase.ctlib.config-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.teradata.jdbc-4.0-core-nu  [version 14.1.4.1327]'
	'informationengine.qt.drivers.teradata.odbc.config-4.0-core-nu  [version 14.1.4.1327]'
	'Intel(R) Processor Graphics  [version 20.19.15.4549]'
	'Intel(R) Processor Graphics  [version 25.20.100.6472]'
	'Ipswitch WS_FTP 12  [version 12.4]'
	'IronPython 2.7.3  [version 2.7.31000.0]'
	'IVI Shared Component 64-bit  [version 2.30.49156]'
	'IVI Shared Components 2.3  [version 2.30.49156]'
	'Java 8 Update 261  [version 8.0.2610.12]'
	'Java 8 Update 261 (64-bit)  [version 8.0.2610.12]'
	'Java 8 Update 271  [version 8.0.2710.9]'
	'Java 8 Update 271 (64-bit)  [version 8.0.2710.9]'
	'Java Auto Updater  [version 2.8.261.12]'
	'Java Auto Updater  [version 2.8.271.9]'
	'Keyboard Manager  [version 2.2.4.400]'
	'Local Administrator Password Solution  [version 6.2.0.0]'
	'LSMS Submissions 2.0.0.0017  [version 2.0.0.0017]'
	'LSMS Submissions MultiWEBSSnF Configuration 2.0.0.0003  [version 2.0.0.0003]'
	'LT Viewer 32 v1.7.0.0  [version 1.7.00]'
	'MailCrypt  [version 3.1]'
	'MARPLOT Version 5.1.1  [version 5.1.1]'
	'McAfee Agent  [version 5.6.5.236]'
	'McAfee Data Exchange Layer for MA  [version 6.0.0.218]'
	'McAfee Data Exchange Layer for MA  [version 6.0.218.0]'
	'McAfee DLP Endpoint  [version 11.4.0.452]'
	'McAfee Endpoint Security Firewall  [version 10.7.0]'
	'McAfee Endpoint Security Platform  [version 10.7.0]'
	'McAfee Endpoint Security Threat Prevention  [version 10.7.0]'
	'McAfee Host Intrusion Prevention  [version 8.00.1400]'
	'McAfee Policy Auditor Agent  [version 6.4.3.290]'
	'McAfee Policy Auditor Agent  [version 6.4.3.297]'
	'MDOP MBAM  [version 2.5.1147.0]'
	'Microsoft Access database engine 2010 (English)  [version 14.0.7015.1000]'
	'Microsoft Access MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Access Setup Metadata MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft DCF MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Edge  [version 85.0.564.67]'
	'Microsoft Edge  [version 87.0.664.60]'
	'Microsoft Edge Update  [version 1.3.135.29]'
	'Microsoft Edge Update  [version 1.3.137.99]'
	'Microsoft Edge Update  [version 1.3.139.59]'
	'Microsoft Excel MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Groove MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft InfoPath MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Lync MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Monitoring Agent  [version 7.1.10184.0]'
	'Microsoft NetBanner  [version 2.1.161]'
	'Microsoft Office 64-bit Components 2013  [version 15.0.4569.1506]'
	'Microsoft Office Office 64-bit Components 2010  [version 14.0.7015.1000]'
	'Microsoft Office OSM MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Office OSM UX MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Office Professional Plus 2013  [version 15.0.4569.1506]'
	'Microsoft Office Project MUI (English) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Project Professional 2010  [version 14.0.7015.1000]'
	'Microsoft Office Project Standard 2010  [version 14.0.7015.1000]'
	'Microsoft Office Proof (English) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Proof (French) 2010  [version 14.0.4763.1000]'
	'Microsoft Office Proof (French) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Proof (Spanish) 2010  [version 14.0.4763.1000]'
	'Microsoft Office Proof (Spanish) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Proofing (English) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Proofing (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Office Proofing Tools 2013 - English  [version 15.0.4569.1506]'
	'Microsoft Office Proofing Tools 2013 - EspaÃ±ol  [version 15.0.4569.1506]'
	'Microsoft Office Proofing Tools 2016 - English  [version 16.0.4266.1001]'
	'Microsoft Office Shared 64-bit MUI (English) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Shared 64-bit MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Office Shared 64-bit Setup Metadata MUI (English) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Shared 64-bit Setup Metadata MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Office Shared MUI (English) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Shared MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Office Shared Setup Metadata MUI (English) 2010  [version 14.0.7015.1000]'
	'Microsoft Office Shared Setup Metadata MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Office Visio 2010  [version 14.0.7015.1000]'
	'Microsoft Office Visio MUI (English) 2010  [version 14.0.7015.1000]'
	'Microsoft OneNote MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Outlook MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Policy Platform  [version 68.1.1010.0]'
	'Microsoft PowerPoint MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Primary Interoperability Assemblies 2005  [version 8.0.50727.42]'
	'Microsoft Project Professional 2010  [version 14.0.7015.1000]'
	'Microsoft Project Professional 2016  [version 16.0.4266.1001]'
	'Microsoft Project Standard 2010  [version 14.0.7015.1000]'
	'Microsoft Project Standard 2016  [version 16.0.4266.1001]'
	'Microsoft Publisher MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft ReportViewer 2010 Redistributable  [version 10.0.30319]'
	'Microsoft ReportViewer 2010 SP1 Redistributable (KB2549864)  [version 10.0.40220]'
	'Microsoft SharePoint Designer 2013  [version 15.0.4420.1017]'
	'Microsoft SharePoint Designer MUI (English) 2013  [version 15.0.4420.1017]'
	'Microsoft SQL Server 2012 Native Client   [version 11.0.2100.60]'
	'Microsoft SQL Server 2014 Express LocalDB   [version 12.1.4100.1]'
	'Microsoft SQL Server 2014 Express LocalDB   [version 12.1.4232.0]'
	'Microsoft SQL Server 2014 Setup (English)  [version 12.1.4232.0]'
	'Microsoft SQL Server Compact 4.0 SP1 x64 ENU  [version 4.0.8876.1]'
	'Microsoft Visio MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft Visio Premium 2010  [version 14.0.7015.1000]'
	'Microsoft Visio Professional 2010  [version 14.0.7015.1000]'
	'Microsoft Visio Professional 2013  [version 15.0.4569.1506]'
	'Microsoft Visio Professional 2016  [version 16.0.4266.1001]'
	'Microsoft Visio Standard 2010  [version 14.0.7015.1000]'
	'Microsoft Visio Standard 2016  [version 16.0.4266.1001]'
	'Microsoft Visio Viewer 2016  [version 16.0.4339.1001]'
	'Microsoft Visual Basic for Applications 7.1 (x64)  [version 7.1.00.00]'
	'Microsoft Visual Basic for Applications 7.1 (x64) English  [version 7.1.0.0]'
	'Microsoft Visual Basic PowerPacks 10.0  [version 10.0.20911]'
	'Microsoft Visual C++ 2005 Redistributable  [version 8.0.56336]'
	'Microsoft Visual C++ 2005 Redistributable  [version 8.0.59193]'
	'Microsoft Visual C++ 2005 Redistributable  [version 8.0.61001]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.56336]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.59192]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.21022  [version 9.0.21022]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.21022  [version 9.0.21022]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.17  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2008 x64 ATL Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 x64 CRT Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 x64 MFC Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 x64 OpenMP Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 x86 ATL Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 x86 CRT Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 x86 MFC Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 x86 OpenMP Runtime 9.0.30729  [version 9.0.30729]'
	'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2010  x86 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.60610  [version 11.0.60610.1]'
	'Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.61030  [version 11.0.61030.0]'
	'Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.60610  [version 11.0.60610.1]'
	'Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.61030  [version 11.0.61030.0]'
	'Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.60610  [version 11.0.60610]'
	'Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.60610  [version 11.0.60610]'
	'Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.60610  [version 11.0.60610]'
	'Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.60610  [version 11.0.60610]'
	'Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.30501  [version 12.0.30501.0]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.30501  [version 12.0.30501.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.23026  [version 14.0.23026.0]'
	'Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24212  [version 14.0.24212.0]'
	'Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.23026  [version 14.0.23026.0]'
	'Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24212  [version 14.0.24212.0]'
	'Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24215  [version 14.0.24215.1]'
	'Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.23026  [version 14.0.23026]'
	'Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026  [version 14.0.23026]'
	'Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.23026  [version 14.0.23026]'
	'Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.24215  [version 14.0.24215]'
	'Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.23026  [version 14.0.23026]'
	'Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.24215  [version 14.0.24215]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.27.29016  [version 14.27.29016.0]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.27.29112  [version 14.27.29112.0]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.13.26020  [version 14.13.26020.0]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.16.27033  [version 14.16.27033.0]'
	'Microsoft Visual C++ 2017 Redistributable (x86) - 14.12.25810  [version 14.12.25810.0]'
	'Microsoft Visual C++ 2017 Redistributable (x86) - 14.13.26020  [version 14.13.26020.0]'
	'Microsoft Visual C++ 2017 x64 Additional Runtime - 14.13.26020  [version 14.13.26020]'
	'Microsoft Visual C++ 2017 X64 Additional Runtime - 14.16.27033  [version 14.16.27033]'
	'Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.13.26020  [version 14.13.26020]'
	'Microsoft Visual C++ 2017 X64 Minimum Runtime - 14.16.27033  [version 14.16.27033]'
	'Microsoft Visual C++ 2017 x86 Additional Runtime - 14.12.25810  [version 14.12.25810]'
	'Microsoft Visual C++ 2017 x86 Additional Runtime - 14.13.26020  [version 14.13.26020]'
	'Microsoft Visual C++ 2017 x86 Minimum Runtime - 14.12.25810  [version 14.12.25810]'
	'Microsoft Visual C++ 2017 x86 Minimum Runtime - 14.13.26020  [version 14.13.26020]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.27.29016  [version 14.27.29016]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.27.29112  [version 14.27.29112]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.27.29016  [version 14.27.29016]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.27.29112  [version 14.27.29112]'
	'Microsoft Visual Studio 2010 Tools for Office Runtime (x64)  [version 10.0.50903]'
	'Microsoft Visual Studio 2010 Tools for Office Runtime (x64)  [version 10.0.50908]'
	'Microsoft Word MUI (English) 2013  [version 15.0.4569.1506]'
	'Microsoft WSE 2.0 SP3 Runtime  [version 2.0.5050.0]'
	'Minitab 18  [version 18.1.0.0]'
	'MMF OPOS 1.13  [version 1.13]'
	'Mozilla Firefox 78.3.0 ESR (x86 en-US)  [version 78.3.0]'
	'Mozilla Firefox 78.4.0 ESR (x86 en-US)  [version 78.4.0]'
	'Mozilla Firefox 78.5.0 ESR (x86 en-US)  [version 78.5.0]'
	'Mozilla Firefox 84.0 (x64 en-US)  [version 84.0]'
	'Mozilla Maintenance Service  [version 78.3.0]'
	'Mozilla Maintenance Service  [version 78.4.0]'
	'Mozilla Maintenance Service  [version 78.5.0]'
	'Mozilla Maintenance Service  [version 78.5.1]'
	'Mozilla Maintenance Service  [version 84.0]'
	'Mozilla Thunderbird 78.5.1 (x86 en-US)  [version 78.5.1]'
	'MSXML 4.0 SP2 Parser and SDK  [version 4.20.9818.0]'
	'NAVFIT98A  [version 1.0.0]'
	'Navy 2016  [version 1.00.0000]'
	'Notepad++ (64-bit x64)  [version 7.7.1]'
	'olap.analysis.implementation.cpp.activex-4.0-core-32  [version 14.1.4.1327]'
	'olap.analysis.implementation.cpp.sofa-4.0-core-32  [version 14.1.4.1327]'
	'OMNIKEY 3x21 PC/SC Driver  [version 3.0.0.0]'
	'Online Plug-in  [version 14.9.5000.7]'
	'Outils de vÃ©rification linguistique 2013 de Microsoft OfficeÂ - FranÃ§ais  [version 15.0.4569.1506]'
	'Outils de vÃ©rification linguistique 2016 de Microsoft OfficeÂ - FranÃ§ais  [version 16.0.4266.1001]'
	'PACES 1.4  [version 1.4.20]'
	'PCASE 2.09  [version 2.09]'
	'PDF Report Writer (novaPDF 6.4  printer)'
	'PDFCreator  [version 1.4.1]'
	'Personal Accelerator for Revit  [version 16.0.1205.0]'
	'Photo Mechanic 5  [version 5.0]'
	'platform.client.java.helper.supportability-4.0-core-nu  [version 14.1.4.1327]'
	'platform.library.common.authentication.jdedwards.java-4.0-core-nu  [version 14.1.4.1327]'
	'platform.library.common.authentication.jdedwards-4.0-core-32  [version 14.1.4.1327]'
	'platform.library.common.authentication.jdedwards-4.0-en-32  [version 14.1.4.1327]'
	'platform.library.common.authentication.oracle-4.0-core-32  [version 14.1.4.1327]'
	'platform.library.common.authentication.peoplesoft-4.0-core-32  [version 14.1.4.1327]'
	'platform.library.common.authentication.sap-4.0-core-32  [version 14.1.4.1327]'
	'platform.library.common.authentication.siebel.java-4.0-core-nu  [version 14.1.4.1327]'
	'platform.library.common.authentication.siebel-4.0-core-32  [version 14.1.4.1327]'
	'platform.library.common.authentication.siebel-4.0-en-32  [version 14.1.4.1327]'
	'platform.library.common.instrumentation-4.0-core-nu  [version 14.1.4.1327]'
	'platform.library.common-4.0-core-32  [version 14.1.4.1327]'
	'platform.sdk.boe.com.core-4.0-core-32  [version 14.1.4.1327]'
	'platform.sdk.boe.com.instrumentation-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.com.slplugins.binfiles-4.0-core-32  [version 14.1.4.1327]'
	'platform.sdk.boe.com.slplugins.pinfiles-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.com-4.0-core-32  [version 14.1.4.1327]'
	'platform.sdk.boe.com-4.0-en-32  [version 14.1.4.1327]'
	'platform.sdk.boe.java.boe-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.bundles-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.classes-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.jdedwards-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.oracle-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.pbds_full-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.pbds-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.peoplesoft-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.sap-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java.siebel-4.0-core-nu  [version 14.1.4.1327]'
	'platform.sdk.boe.java-4.0-core-nu  [version 14.1.4.1327]'
	'platform.services.ras21.clientsdk.java.pbd-4.0-core-nu  [version 14.1.4.1327]'
	'platform.services.ras21.clientsdk.java-4.0-core-nu  [version 14.1.4.1327]'
	'platform.services.ras21.clientsdk_shared_bundle-4.0-core-nu  [version 14.1.4.1327]'
	'PMSViewer 2.0  [version 2.0.0.0]'
	'PMT  [version 2.0.9]'
	'PmtClient  [version 1.0.3]'
	'POSSE5  [version 5.1.0416.2]'
	'Power*Tools For Windows  [version 8.0.3.7 build 1]'
	'Primavera P6 Professional (x64)  [version 15.2.0.15383]'
	'Primavera P6 Professional (x64)  [version 17.12.9.29975]'
	'product.crystalreports.actions-4.0-core-32  [version 14.1.4.1327]'
	'product.crystalreports.arp.icon-4.0-core-32  [version 14.1.4.1327]'
	'product.crystalreports.eula-4.0-core-32  [version 14.1.4.1327]'
	'product.crystalreports.langpackproperty-4.0-en-nu  [version 14.1.4.1327]'
	'product.shared.installiverse.reg-4.0-core-nu  [version 14.1.4.1327]'
	'product.shared.langpackreg-4.0-core-nu  [version 14.1.4.1327]'
	'RDP Support  [version 22.0.10.0]'
	'Realtek High Definition Audio Driver  [version 6.0.1.8328]'
	'Realtek High Definition Audio Driver  [version 6.0.1.8335]'
	'Remark Office OMR 10  [version 10.0.39.0]'
	'repoaccess.async_scheduling-4.0-core-32  [version 14.1.4.1327]'
	'repoaccess.async_scheduling-4.0-en-32  [version 14.1.4.1327]'
	'repoaccess.bo_storage-4.0-core-32  [version 14.1.4.1327]'
	'repoaccess.cdztools.java-4.0-core-nu  [version 14.1.4.1327]'
	'repoaccess.cdztools.jshell-4.0-core-nu  [version 14.1.4.1327]'
	'repoaccess.cdztools.oldregistry-4.0-core-32  [version 14.1.4.1327]'
	'repoaccess.cdztools.oldregistry-4.0-en-32  [version 14.1.4.1327]'
	'repoaccess.cdztools-4.0-core-32  [version 14.1.4.1327]'
	'repoaccess.container.admintool.java-4.0-core-nu  [version 14.1.4.1327]'
	'repoaccess.container.java-4.0-core-nu  [version 14.1.4.1327]'
	'repoaccess.container-4.0-core-32  [version 14.1.4.1327]'
	'repoaccess.repo_proxy.cpp-4.0-core-32  [version 14.1.4.1327]'
	'repoaccess.repoaccess_plugins_webi.binfiles-4.0-core-32  [version 14.1.4.1327]'
	'Required Runtimes  [version 13.0.0.0]'
	'Revit 2018  [version 18.3.3.18]'
	'Revit Extensions for Autodesk Revit 2018  [version 1.0.0.0]'
	'Roombook Areabook Buildingbook for Revit 2018  [version 8.00.2811]'
	'SAP Crystal Reports 2013 SP4  [version 14.1.4.1327]'
	'SCAP Compliance Checker 5.3.1  [version 5.3.1]'
	'SDL MultiTerm 2019 Convert  [version 15.0.43891]'
	'SDL MultiTerm 2019 Core  [version 15.0.43891]'
	'SDL MultiTerm 2019 Desktop  [version 15.0.43891]'
	'SDL Trados Legacy Compatibility Module  [version 2.1.128]'
	'SDL Trados Studio 2019 SR2  [version 15.2.1041]'
	'SDL WorldServer Components 15.2  [version 15.2.1041]'
	'Security Update for Microsoft Access 2013 (KB4484366) 32-Bit Edition'
	'Security Update for Microsoft Excel 2013 (KB4484526) 32-Bit Edition'
	'Security Update for Microsoft Excel 2013 (KB4486734) 32-Bit Edition'
	'Security Update for Microsoft InfoPath 2013 (KB3162075) 32-Bit Edition'
	'Security Update for Microsoft Office 2010 (KB2553204) 32-Bit Edition'
	'Security Update for Microsoft Office 2010 (KB2881029) 32-Bit Edition'
	'Security Update for Microsoft Office 2010 (KB4011611) 32-Bit Edition'
	'Security Update for Microsoft Office 2010 (KB4011618) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB2768005) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB2810009) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB2878316) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3039746) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3039794) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3039798) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3054816) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3162051) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3172522) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3172524) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3172531) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB3213564) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4011580) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4018375) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4022188) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4022189) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4484359) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4484435) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4484469) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4484520) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4486688) 32-Bit Edition'
	'Security Update for Microsoft Office 2013 (KB4486725) 32-Bit Edition'
	'Security Update for Microsoft Outlook 2013 (KB4484524) 32-Bit Edition'
	'Security Update for Microsoft Project 2010 (KB4484463) 32-Bit Edition'
	'Security Update for Microsoft Project 2013 (KB4484450) 32-Bit Edition'
	'Security Update for Microsoft Publisher 2013 (KB3162033) 32-Bit Edition'
	'Security Update for Microsoft SharePoint Designer 2013 (KB2752096) 32-Bit Edition'
	'Security Update for Microsoft SharePoint Designer 2013 (KB2863836) 32-Bit Edition'
	'Security Update for Microsoft Visio 2010 (KB4462225) 32-Bit Edition'
	'Security Update for Microsoft Visio 2013 (KB4464544) 32-Bit Edition'
	'Security Update for Microsoft Word 2013 (KB4484522) 32-Bit Edition'
	'Security Update for Microsoft Word 2013 (KB4486692) 32-Bit Edition'
	'Security Update for Microsoft Word 2013 (KB4486730) 32-Bit Edition'
	'Security Update for Skype for Business 2015 (KB3191937) 32-Bit Edition'
	'Security Update for Skype for Business 2015 (KB3213568) 32-Bit Edition'
	'Self-service Plug-in  [version 4.9.5000.5]'
	'Sentinel System Driver Installer 7.5.0  [version 7.5.0]'
	'Service Pack 2 for Microsoft Office 2010 Language Pack (KB2687449) 32-Bit Edition'
	'Service Pack 2 for Microsoft Project 2010 (KB2687457) 32-Bit Edition'
	'Service Pack 2 for Microsoft Visio 2010 (KB2687468) 32-Bit Edition'
	'setup.engine.sharedregistry-4.0-core-32  [version 14.1.4.1327]'
	'shared.library.content-4.0-core-32  [version 14.1.4.1327]'
	'shared.library.content-4.0-en-32  [version 14.1.4.1327]'
	'shared.library.cxlib.cxlib-4.0-core-32  [version 14.1.4.1327]'
	'shared.library.keycode.decoder.cpp-4.0-core-32  [version 14.1.4.1327]'
	'shared.library.keycode.defn-4.0-core-32  [version 14.1.4.1327]'
	'shared.library.keycode.licmgr-4.0-core-32  [version 14.1.4.1327]'
	'shared.library.keycode.licmgr-4.0-en-32  [version 14.1.4.1327]'
	'shared.tp.aurora.apache.axis2.bundle-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.apache.axis2-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.apache.rampart-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.curl.cpp-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.datadirect.cpp-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.ooc.cpp-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.ooc.java.boe-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.ooc.java.bundle-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.ooc.java.classes-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.ooc.java-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.poco-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.sap.ncs-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.sap.nwrfc-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.simba.sfdc.odbc-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.sun.jre-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.threedgraphics.pgsdk.cpp.chartsupport-4.0-core-nu  [version 14.1.4.1327]'
	'shared.tp.aurora.threedgraphics.pgsdk.cpp.runtime-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.threedgraphics.pgsdk.cpp.runtime-4.0-en-32  [version 14.1.4.1327]'
	'shared.tp.aurora.threedgraphics.pgsdk.cpp-4.0-core-32  [version 14.1.4.1327]'
	'shared.tp.aurora.threedgraphics.pgsdk.cpp-4.0-en-32  [version 14.1.4.1327]'
	'SketchUp 2017  [version 17.2.2555]'
	'SketchUp Import 2016  [version 2.0.0]'
	'SMART Common Files  [version 11.4.194.0]'
	'SMART Ink  [version 2.0.720.0]'
	'SMART Notebook  [version 11.3.857.0]'
	'SMART Product Drivers  [version 11.3.550.0]'
	'SMART Response Software  [version 4.7.806.0]'
	'Snare version 4.0.2 (Open Source)  [version 4.0.2]'
	'SpecsIntact  [version 4.6.2.996]'
	'Success Estimator for the Navy-USMC  [version 9.1.0.2]'
	'System Analyzer  [version 6.1.0.0]'
	'System Analyzer  [version 6.1.1.0]'
	'System Center Configuration Manager Console  [version 5.1906.1096.1000]'
	'Tableau 2018.2 (20182.18.0627.2230)  [version 18.2.156]'
	'Tableau Reader 2018.2 (20182.18.1009.2120)  [version 18.2.672]'
	'Teams Machine-Wide Installer  [version 1.3.0.4461]'
	'tools.astools.cpp-4.0-core-32  [version 14.1.4.1327]'
	'tools.boe.wstk.java-4.0-core-nu  [version 14.1.4.1327]'
	'tools.boe.wstk-4.0-core-32  [version 14.1.4.1327]'
	'tools.i18n4j-4.0-core-nu  [version 14.1.4.1327]'
	'tools.srvtools-4.0-core-32  [version 14.1.4.1327]'
	'tp.apache.abdera.bundle.biprs-1.1.2-core-nu  [version 14.1.4.1327]'
	'tp.apache.abdera.license-1.1.2-core-nu  [version 14.1.4.1327]'
	'tp.apache.commons.java.boe-3.1-core-nu  [version 14.1.4.1327]'
	'tp.apache.commons.java.classes-3.1-core-nu  [version 14.1.4.1327]'
	'tp.apache.commons.java-3.1-core-nu  [version 14.1.4.1327]'
	'tp.apache.cxf.bundle.biprs-2.3.8-core-nu  [version 14.1.4.1327]'
	'tp.apache.cxf.license-2.3.8-core-nu  [version 14.1.4.1327]'
	'tp.apache.derby.boe-10.2.2.0-core-nu  [version 14.1.4.1327]'
	'tp.apache.derby.classes-10.2.2.0-core-nu  [version 14.1.4.1327]'
	'tp.apache.derby-10.2.2.0-core-nu  [version 14.1.4.1327]'
	'tp.apache.log4j.boe-1.2.6_sap.1-core-nu  [version 14.1.4.1327]'
	'tp.apache.log4j.bundle-1.2.6_sap.1-core-nu  [version 14.1.4.1327]'
	'tp.apache.log4j.classes-1.2.6_sap.1-core-nu  [version 14.1.4.1327]'
	'tp.apache.log4j.nteventlogappender-1.2.6_sap.1-core-32  [version 14.1.4.1327]'
	'tp.apache.log4j-1.2.6_sap.1-core-nu  [version 14.1.4.1327]'
	'tp.apache.xalan.cpp-1.10.0-core-32  [version 14.1.4.1327]'
	'tp.apache.xalan.java.boe-2.5.2-core-nu  [version 14.1.4.1327]'
	'tp.apache.xalan.java.classes-2.5.2-core-nu  [version 14.1.4.1327]'
	'tp.apache.xalan.java-2.5.2-core-nu  [version 14.1.4.1327]'
	'tp.apache.xbean-2.1.0-core-nu  [version 14.1.4.1327]'
	'tp.apache.xerces.cpp-2.1.0-core-32  [version 14.1.4.1327]'
	'tp.apache.xerces.cpp-2.7.0-core-32  [version 14.1.4.1327]'
	'tp.apache.xerces.java.boe-2.6.2-core-nu  [version 14.1.4.1327]'
	'tp.apache.xerces.java.classes-2.6.2-core-nu  [version 14.1.4.1327]'
	'tp.apache.xerces.java-2.6.2-core-nu  [version 14.1.4.1327]'
	'tp.azalea.fonts-5.5-core-nu  [version 14.1.4.1327]'
	'tp.azalea-5.5-core-32  [version 14.1.4.1327]'
	'tp.cup-0.11-core-nu  [version 14.1.4.1327]'
	'tp.eclipse.aspectj.boe-1.6.5-core-nu  [version 14.1.4.1327]'
	'tp.eclipse.aspectj.classes-1.6.5-core-nu  [version 14.1.4.1327]'
	'tp.eclipse.aspectj-1.6.5-core-nu  [version 14.1.4.1327]'
	'tp.gzip-1.2.3-core-32  [version 14.1.4.1327]'
	'tp.ibm.icu.cpp-3.0.1-core-32  [version 14.1.4.1327]'
	'tp.ibm.icu.cpp-4.2.1-core-32  [version 14.1.4.1327]'
	'tp.ibm.icu.java-3.8.1-core-nu  [version 14.1.4.1327]'
	'tp.libxml2-2.0-core-32  [version 14.1.4.1327]'
	'tp.mapinfo.mapx.cpp-3.5-core-32  [version 14.1.4.1327]'
	'tp.microsoft.mssdk-10.0-core-32  [version 14.1.4.1327]'
	'tp.microsoft.office.stdole-11.0-core-32  [version 14.1.4.1327]'
	'tp.netegrity.siteminder.cpp.smagent-6.0-core-32  [version 14.1.4.1327]'
	'tp.netscape.ldap.cpp-6.0.5-core-32  [version 14.1.4.1327]'
	'tp.openssl-0.9.8l-core-32  [version 14.1.4.1327]'
	'tp.pervasive.db.btrieve-3.0-core-32  [version 14.1.4.1327]'
	'tp.pkware.cpp-1.0-core-32  [version 14.1.4.1327]'
	'tp.rosette-4.2.1-core-32  [version 14.1.4.1327]'
	'tp.rsa.crypto.cpp-3.2.1.2-core-32  [version 14.1.4.1327]'
	'tp.rsa.crypto.java.boe-4.1-core-nu  [version 14.1.4.1327]'
	'tp.rsa.crypto.java.classes-4.1-core-nu  [version 14.1.4.1327]'
	'tp.rsa.crypto.java-4.1-core-nu  [version 14.1.4.1327]'
	'tp.rsa.crypto-6.3-core-32  [version 14.1.4.1327]'
	'tp.sap.ljs.passport.boe-0.8.0-core-nu  [version 14.1.4.1327]'
	'tp.sap.ljs.passport.classes-0.8.0-core-nu  [version 14.1.4.1327]'
	'tp.sap.ljs.passport-0.8.0-core-nu  [version 14.1.4.1327]'
	'tp.sap.rfcsdku-70-core-32  [version 14.1.4.1327]'
	'tp.shared.pvlocale.pvlocale-4.0-core-32  [version 14.1.4.1327]'
	'tp.sourceforge.libpng.cpp-1.0.30-core-32  [version 14.1.4.1327]'
	'tp.sun.boe-1.1-core-nu  [version 14.1.4.1327]'
	'tp.sun.classes-1.1-core-nu  [version 14.1.4.1327]'
	'tp.sun-1.1-core-nu  [version 14.1.4.1327]'
	'tp.utexasaustin.hoard-3.7.1-core-32  [version 14.1.4.1327]'
	'tp.xpp3.boe-1.1.3.8-core-nu  [version 14.1.4.1327]'
	'tp.xpp3.bundle-1.1.3.8-core-nu  [version 14.1.4.1327]'
	'tp.xpp3.classes-1.1.3.8-core-nu  [version 14.1.4.1327]'
	'tp.xpp3-1.1.3.8-core-nu  [version 14.1.4.1327]'
	'TRACE 700  [version 6.3.0.1]'
	'Trane Report Framework  [version 2.0.0]'
	'TransVerse v1.8.1.3 Build829'
	'Tumbleweed ONE-NET Configuration  [version TL-Enabled]'
	'Update for Microsoft InfoPath 2013 (KB3114818) 32-Bit Edition'
	'Update for Microsoft InfoPath 2013 (KB3114946) 32-Bit Edition'
	'Update for Microsoft InfoPath 2013 (KB4022181) 32-Bit Edition'
	'Update for Microsoft Office 2010 (KB2837602) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB2760344) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB2760371) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB2883095) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB2889863) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB2899522) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3023049) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3023052) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3039701) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3039720) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3039756) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3039766) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3039778) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3039795) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3054785) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3054819) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3054856) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3085565) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3085587) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3101503) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3114488) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3114499) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3114825) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3127916) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3172471) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3172473) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3172523) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3172533) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3172545) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3178640) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3191872) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB3213536) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4011087) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4011155) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4011677) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4018378) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4022212) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4092455) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4462200) 32-Bit Edition'
	'Update for Microsoft Office 2013 (KB4475562) 32-Bit Edition'
	'Update for Microsoft OneDrive for Business (KB3178645) 32-Bit Edition'
	'Update for Microsoft OneDrive for Business (KB3178712) 32-Bit Edition'
	'Update for Microsoft OneDrive for Business (KB4022226) 32-Bit Edition'
	'Update for Microsoft OneNote 2013 (KB3172477) 32-Bit Edition'
	'Update for Microsoft OneNote 2013 (KB4011281) 32-Bit Edition'
	'Update for Microsoft Outlook Social Connector 2013 (KB3054854) 32-Bit Edition'
	'Update for Microsoft PowerPoint 2013 (KB4484349) 32-Bit Edition'
	'Update for Microsoft Visio 2013 (KB4011149) 32-Bit Edition'
	'Update for Microsoft Visio 2013 (KB4464505) 32-Bit Edition'
	'Update for Microsoft Visio Viewer 2013 (KB2817301) 32-Bit Edition'
	'Update for Microsoft Word 2013 (KB3039719) 32-Bit Edition'
	'Update for Microsoft Word 2013 (KB3162081) 32-Bit Edition'
	'Update for Skype for Business 2015 (KB4484289) 32-Bit Edition'
	'VanDyke Software SecureCRT 8.7  [version 8.7.3]'
	'Vidyo Desktop 3.0  [version 3.0]'
	'Visual Basic for Applications (R) Core  [version 6.5.10.54]'
	'Visual Basic for Applications (R) Core - English  [version 6.5.10.32]'
	'Visual C++ 2008 - x64 (KB958357) - v9.0.30729.177  [version 9.0.30729.177]'
	'Visual C++ 2008 - x86 (KB958357) - v9.0.30729.177  [version 9.0.30729.177]'
	'VLC media player  [version 3.0.10]'
	'Vocalizer Expressive 2.2 Tom Compact  [version 2.2.206]'
	'Vocalizer Expressive 2.2 Zoe Compact  [version 2.2.206]'
	'Weather Display 10.37S Build 120'
	'Windows Driver Package - TSI (TSIUSB) USB  (07/23/2013 1.4.6)  [version 07/23/2013 1.4.6]'
	'Windows Driver Package - TSI Incorporated (USB_RNDIS) Net  (07/18/2013 6.1.7600.16387)  [version 07/18/2013 6.1.7600.16387]'
	'WinZip 23.0  [version 23.0.13300]'
	'Wireshark 3.2.8 64-bit  [version 3.2.8]'
	'Worksharing Monitor for Autodesk Revit 2018  [version 18.0.0.420]'
	'X Builder Framework 1.06f'
	'XBuilder Tag Grid 1.0  [version 1.0.18]'
	'YAMAHA DIAGNOSTIC SYSTEM2  [version 2.31.7]'
	'ZoomText 2020  [version 14.3.7.0]'
	'ZoomText 2020 Components  [version 14.3.7.0]'
)

$approvedvisoft = @(
	'{86C2A745-08F4-4616-BD57-F622D8BA8504}  [version 5.14.1405]'
	'ACCM  [version 3.2.4.5]'
	'ACCM  [version 3.2.6.2]'
	'ActivID ActivClient x64  [version 7.1.0]'
	'ActivID ActivClient x64  [version 7.2.1]'
	'Axway Desktop Validator  [version 4.12.2.2.0]'
	'cis-upgrade-runner  [version 6.0.0.25231]'
	'Commvault ContentStore  [version 11.80.160.0]'
	'ConfigMgr 2012 Toolkit R2  [version 5.00.7958.1151]'
	'Configuration Manager Client  [version 5.00.8853.1000]'
	'Dell EqualLogic Host Integration Tools  [version 4.7.1]'
	'Dell EqualLogic SAN Headquarters  [version 3.4.0.9366]'
	'Dell OpenManage Systems Management Software (64-Bit)  [version 8.5.0]'
	'DoD Secure Host Baseline Server  [version 2016.Build2]'
	'GDR 4232 for SQL Server 2014 (KB3194720) (64-bit)  [version 12.1.4232.0]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2565063)  [version 1]'
	'Java 8 Update 261  [version 8.0.2610.12]'
	'Local Administrator Password Solution  [version 6.2.0.0]'
	'McAfee Agent  [version 5.6.5.236]'
	'McAfee Agent  [version 5.7.3.245]'
	'McAfee Data Exchange Layer for MA  [version 6.0.0.218]'
	'McAfee Data Exchange Layer for MA  [version 6.0.218.0]'
	'McAfee Data Exchange Layer for MA  [version 6.0.3.356]'
	'McAfee Data Exchange Layer for MA  [version 6.0.30356.0]'
	'McAfee DLP Endpoint  [version 11.4.0.452]'
	'McAfee DLP Endpoint  [version 11.6.200.162]'
	'McAfee Endpoint Security Firewall  [version 10.7.0]'
	'McAfee Endpoint Security Platform  [version 10.7.0]'
	'McAfee Endpoint Security Threat Prevention  [version 10.7.0]'
	'McAfee Host Intrusion Prevention  [version 8.00.1600]'
	'McAfee Policy Auditor Agent  [version 6.4.3.297]'
	'McAfee Policy Auditor Agent  [version 6.5.0.241]'
	'Microsoft Application Error Reporting  [version 12.0.6012.5000]'
	'Microsoft Help Viewer 1.1  [version 1.1.40219]'
	'Microsoft Monitoring Agent  [version 7.1.10184.0]'
	'Microsoft NetBanner  [version 2.1.161]'
	'Microsoft ODBC Driver 11 for SQL Server  [version 12.2.5659.1]'
	'Microsoft Policy Platform  [version 68.1.1010.0]'
	'Microsoft Report Viewer 2014 Runtime  [version 12.0.2000.8]'
	'Microsoft Silverlight  [version 5.1.50907.0]'
	'Microsoft SQL Server 2008 R2 Management Objects  [version 10.51.2500.0]'
	'Microsoft SQL Server 2008 Setup Support Files   [version 10.3.5500.0]'
	'Microsoft SQL Server 2012 Native Client   [version 11.2.5643.3]'
	'Microsoft SQL Server 2014 (64-bit)'
	'Microsoft SQL Server 2014 Policies   [version 12.0.2000.8]'
	'Microsoft SQL Server 2014 RsFx Driver  [version 12.2.5659.1]'
	'Microsoft SQL Server 2014 Setup (English)  [version 12.2.5659.1]'
	'Microsoft SQL Server 2014 Transact-SQL Compiler Service   [version 12.2.5659.1]'
	'Microsoft SQL Server System CLR Types  [version 10.51.2500.0]'
	'Microsoft Visual C++ 2005 Redistributable  [version 8.0.61001]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.56336]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.17  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4974  [version 9.0.30729.4974]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2010  x86 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2010  x86 Runtime - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.61030  [version 11.0.61030.0]'
	'Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24212  [version 14.0.24212.0]'
	'Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.20.27508  [version 14.20.27508.1]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x86) - 14.20.27508  [version 14.20.27508.1]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.11.25325  [version 14.11.25325.0]'
	'Microsoft Visual C++ 2017 x64 Additional Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.20.27508  [version 14.20.27508]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.20.27508  [version 14.20.27508]'
	'Microsoft Visual C++ 2019 X86 Additional Runtime - 14.20.27508  [version 14.20.27508]'
	'Microsoft Visual C++ 2019 X86 Minimum Runtime - 14.20.27508  [version 14.20.27508]'
	'Microsoft Visual J# 2.0 Redistributable Package - SE (x64)'
	'Microsoft Visual J# 2.0 Redistributable Package - SE (x64)  [version 2.0.50728]'
	'Microsoft VSS Writer for SQL Server 2014  [version 12.2.5000.0]'
	'MIT Kerberos for Windows (64-bit) 4.0.0 Mon 09/22/2014 16'
	'None'
	'SCAP Compliance Checker 5.3  [version 5.3]'
	'Service Pack 1 for SQL Server 2014 (KB3058865) (64-bit)  [version 12.1.4100.1]'
	'Snare version 4.0.2 (Open Source)  [version 4.0.2]'
	'SQL Server 2014 Client Tools  [version 12.2.5000.0]'
	'SQL Server 2014 Common Files  [version 12.2.5000.0]'
	'SQL Server 2014 Database Engine Services  [version 12.2.5000.0]'
	'SQL Server 2014 Database Engine Shared  [version 12.2.5000.0]'
	'SQL Server 2014 Management Studio  [version 12.2.5000.0]'
	'SQL Server Browser for SQL Server 2014  [version 12.2.5000.0]'
	'Sql Server Customer Experience Improvement Program  [version 12.2.5000.0]'
	'SQLServeriDataAgent Instance001  [version 11.160.645.0]'
	'Tumbleweed ONE-NET Configuration  [version TL-Enforced]'
	'UniversalForwarder  [version 7.3.3.0]'
	'vCenter Server with an embedded Platform Services Controller  [version 6.0.0.25231]'
	'VCSServiceManager  [version 6.0.0.25231]'
	'VirtualServerAgent Instance001  [version 11.160.645.0]'
	'Visual Studio 2010 Prerequisites - English  [version 10.0.40219]'
	'VMware afd Service  [version 6.0.7.3391]'
	'VMware Certificate Service  [version 6.0.7.2859]'
	'VMware Client Integration Plug-in 6.0.0  [version 6.0.0.9116444]'
	'VMware Client Integration Plug-in 6.2.0  [version 6.2.0.4948]'
	'VMware Directory Service  [version 6.0.7.6826]'
	'VMware Identity Platform SDK  [version 6.0.7.1489]'
	'VMware Identity Services  [version 6.0.7.10110]'
	'VMware Platform Services Controller Client  [version 6.3.1.4422]'
	'VMware Plug-in Service  [version 6.7.0.161]'
	'VMware Remote Console  [version 9.0.0]'
	'VMware Remote Console Plug-in 5.1  [version 0.0.1]'
	'VMware Service Control Agent  [version 6.0.0.14510542]'
	'VMware Tools  [version 11.0.5.15389592]'
	'VMware vCenter Server  [version 6.0.0.25231]'
	'VMware Virtual SAN Health Check Plug-in  [version 6.2.0.14297465]'
	'VMware vSphere Client 6.0  [version 6.0.0.7597]'
	'VMware vSphere Update Manager  [version 6.0.0.41926]'
	'VMware vSphere Update Manager Client 6.0 Update 1b  [version 6.0.0.28847]'
	'VMware vSphere Update Manager Client 6.0 Update 2  [version 6.0.0.29963]'
	'VMware vSphere Update Manager Client 6.0 Update 2a  [version 6.0.0.34068]'
	'VMware vSphere Update Manager Client 6.0 Update 3  [version 6.0.0.35637]'
	'VMware vSphere Update Manager Client 6.0 Update 3c  [version 6.0.0.39331]'
	'VMware vSphere Update Manager Client 6.0 Update 3g  [version 6.0.0.41926]'
	'VMware-Apache-Tomcat  [version 6.0.0.11]'
	'VMware-autodeploy  [version 6.0.0.25231]'
	'VMware-cis-license  [version 6.0.0.33077]'
	'vmware-cm  [version 6.0.0.33077]'
	'VMware-commonjars  [version 6.0.0.675]'
	'vmware-cyrus-sasl  [version 1.0.0.0]'
	'vmware-cyrus-sasl  [version 1.3.0.0]'
	'vmware-eam  [version 6.0.0.11617]'
	'VMware-invsvc  [version 6.0.0.33077]'
	'VMware-jmemtool  [version 6.0.0.33077]'
	'VMware-mbcs  [version 6.0.0.33077]'
	'VMware-netdump  [version 6.0.0.25231]'
	'VMware-OpenSSL  [version 6.0.0.11617]'
	'VMware-perfcharts  [version 6.0.0.11617]'
	'VMware-python  [version 6.0.0.20945]'
	'VMware-rhttpproxy  [version 6.0.0.11617]'
	'VMware-ruby  [version 6.0.0.592]'
	'VMware-rvc  [version 1.8.0.592]'
	'VMware-vapi  [version 6.0.0.2721]'
	'VMware-vc-support  [version 6.0.0.11617]'
	'VMware-vpxd-agents-eesx  [version 6.0.0.11617]'
	'VMware-vpxd-client  [version 6.0.0.11617]'
	'VMware-vsanmgmt  [version 6.2.0.17630]'
	'vmware-vsm  [version 6.0.0.11617]'
	'VSSProvider Instance001  [version 11.160.645.0]'
	'WindowsFileSystemiDataAgentAdvanced Instance001  [version 11.160.645.0]'
	'WindowsFileSystemiDataAgentCore Instance001  [version 11.160.645.0]'
)

$approvedviport = @(
	'3260'
	'53'
	'123'
	'514'
	'80'
	'427'
	'5989'
	'8000'
	'8100'
	'8182'
	'8182'
	'8300'
	'8400'
	'123'
	'161'
	'514'
	'53'
	'88'
	'389'
	'427'
	'135'
	'137'
	'138'
	'139'
	'445'
	'500'
	'514'
	'1433'
	'1434'
	'1443'
	'1514'
	'2014'
	'2020'
	'3389'
	'4500'
	'5355'
	'5985'
	'7080'
	'7444'
	'7569'
	'8088'
	'8109'
	'8403'
	'9443'
	'10109'
	'11711'
	'11712'
	'12080'
	'12721'
	'13080'
	'15005'
	'15007'
	'47001'
	'49152'
	'5989'
	'8000'
	'443'
	'636'
	'902'
	'8400'
	'9000'
	'22'
	'80'
	'443'
	'623'
	'902'
	'8084'
	'9443'
	'6061'
	'53'
	'389'
	'636'
	'1099'
	'1100'
	'5433'
	'5488'
	'6061'
	'7001'
	'8001'
	'8443'
	'8445'
	'8447'
	'9008'
	'9042'
	'20000'
	32768..65535
	'3268'
	'3269'
	'10080'
	'10443'
	'10000'
	'80'
	'443'
	'591'
	'8081'
	'8082'
	'8089'
	'8444'
	'9997'
	'50'
	'51'
	'500'
)

$approvednibport = @(
	'22'
	'25'
	'49'
	'69'
	'80'
	'123'
	'161'
	'162'
	'179'
	'443'
	'500'
	'514'
	'636'
	'2000'
	'2001'
	'2002'
	'4500'
	'7800'
	'7801'
	'7850'
	'9443'
	'80'
	'53'
	'68'
	'88'
	'464'
	'3268'
	'1026'
	'1344'
	'5246'
	'5248'
	'8082'
)

$approvedsoftware = @(
	'ACCM  [version 3.2.0.18]'
	'ACCM  [version 3.2.4.5]'
	'ActivClient x64  [version 7.0.2]'
	'ActivID ActivClient x64  [version 7.1.0]'
	'Active Directory Management Pack Helper Object  [version 1.1.0]'
	'Active Directory Rights Management Services Client 2.1  [version 1.0.3356.1108]'
	'AppFabric 1.1 for Windows Server  [version 1.1.2106.32]'
	'Commvault ContentStore  [version 11.80.30.0]'
	'Configuration Manager Client  [version 5.00.8740.1000]'
	'Configuration Manager Client  [version 5.00.8853.1000]'
	'Cumulative Update for Workflow Manager 1.0 (KB4055730)LDR  [version 2.0.40131.0]'
	'Dell OpenManage Systems Management Software (64-Bit)  [version 8.5.0]'
	'Dell EqualLogic Host Integration Tools  [version 5.1.0]'
	'Dell EqualLogic SAN Headquarters  [version 3.4.0.9366]'
	'Device Installer x64  [version 2.2]'
	'DoD Secure Host Baseline Server  [version 2016.Build2]'
	'Hotfix 5264 for SQL Server 2016 (KB4475776) (64-bit)  [version 13.2.5264.1]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2565063)  [version 1]'
	'Matrox Graphics Software (remove only)  [version 4.3.4.2]'
	'McAfee Agent  [version 5.5.1.462]'
	'McAfee Agent  [version 5.5.1.388]'
	'McAfee Agent  [version 5.6.1.308]'
	'McAfee Data Exchange Layer for MA  [version 5.0.1.249]'
	'McAfee Data Exchange Layer for MA  [version 5.0.10249.0]'
	'McAfee DLP Endpoint  [version 11.1.100.232]'
	'McAfee DLP Endpoint  [version 10.0.350.12]'
	'McAfee Endpoint Security Firewall  [version 10.6.11910]'
	'McAfee Endpoint Security Platform  [version 10.6.1]'
	'McAfee Endpoint Security Platform  [version 10.6.11910]'
	'McAfee Endpoint Security Threat Prevention  [version 10.6.1]'
	'McAfee Endpoint Security Threat Prevention  [version 10.6.11910]'
	'McAfee Host Intrusion Prevention  [version 8.00.1100]'
	'McAfee Host Intrusion Prevention  [version 8.00.1200]'
	'McAfee Policy Auditor Agent  [version 6.3.0.194]'
	'McAfee RSD Sensor  [version 5.0.5.120]'
	'Microsoft NetBanner  [version 2.1.161]'
	'McAfee Policy Auditor Agent  [version 6.4.1.105]'
	'McAfee VirusScan Enterprise  [version 8.8.012000]'
	'Microsoft CCR and DSS Runtime 2008 R3  [version 2.2.760]'
	'Microsoft Identity Extensions  [version 2.0.1459.0]'
	'Microsoft Monitoring Agent  [version 7.1.10184.0]'
	'Microsoft ODBC Driver 11 for SQL Server  [version 12.2.5543.11]'
	'Microsoft Policy Platform  [version 68.1.1010.0]'
	'Microsoft Server Proof (Arabic) 2016  [version 16.0.4351.1000]'
	'Microsoft Server Proof (English) 2016  [version 16.0.4351.1000]'
	'Microsoft Server Proof (French) 2016  [version 16.0.4351.1000]'
	'Microsoft Server Proof (German) 2016  [version 16.0.4351.1000]'
	'Microsoft Server Proof (Russian) 2016  [version 16.0.4351.1000]'
	'Microsoft Server Proof (Spanish) 2016  [version 16.0.4351.1000]'
	'Microsoft SharePoint Foundation 2016 1033 Lang Pack  [version 16.0.4351.1000]'
	'Microsoft SharePoint Foundation 2016 Core  [version 16.0.4351.1000]'
	'Microsoft SharePoint Server 2016  [version 16.0.4351.1000]'
	'Microsoft Silverlight  [version 5.1.50907.0]'
	'Microsoft SQL Server 2005 Analysis Services ADOMD.NET  [version 9.00.1399.06]'
	'Microsoft SQL Server 2008 Setup Support Files   [version 10.3.5500.0]'
	'Microsoft SQL Server 2012 Native Client   [version 11.1.3000.0]'
	'Microsoft SQL Server 2016 Setup (English)  [version 13.2.5264.1]'
	'Microsoft SQL Server 2016 PowerPivot - SharePoint   [version 13.0.1601.5]'
	'Microsoft SQL Server 2016 RS Addin for SharePoint   [version 13.2.5264.1]'
	'Microsoft Sync Framework Runtime v1.0 SP1 (x64)  [version 1.0.3010.0]'
	'PowerShell 6-x64  [version 6.1.0.0]'
	'Microsoft Web Deploy 3.0  [version 3.1236.1631]'
	'Security Update for Microsoft SharePoint Enterprise Server 2016 (KB4022228) 64-Bit Edition'
	'Service Bus 1.1  [version 2.0.30904.0]'
	'Service Pack 2 for SQL Server 2016 (KB4052908) (64-bit)  [version 13.2.5026.0]'
	'SharePointiDataAgent Instance001  [version 11.80.30.0]'
	'Snare version 4.0.2 (Open Source)  [version 4.0.2]'
	'Tumbleweed Desktop Validator  [version 4.11]'
	'Update for Microsoft SharePoint Enterprise Server 2016 (KB4022178) 64-Bit Edition'
	'Update for Service Bus 1.1 (KB3086798)GDR  [version 2.0.30904.0]'
	'Update for Microsoft .NET Framework 4.6.*'
	'VMware Tools  [version 10.0.6.3560309]'
	'WCF Data Services 5.6 Tools  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 CHS Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 CHT Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 DEU Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 ESN Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 FRA Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 ITA Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 JPN Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 KOR Language Pack  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 Runtime  [version 5.6.61587.0]'
	'WCF Data Services 5.6.0 RUS Language Pack  [version 5.6.61587.0]'
	'Windows Fabric  [version 1.0.976.0]'
	'Windows Server AppFabric v1.1 CU7 [KB3092423]LDR  [version 1.1.2106.32]'
	'WindowsFileSystemiDataAgentAdvanced Instance001  [version 11.80.30.0]'
	'WindowsFileSystemiDataAgentCore Instance001  [version 11.80.30.0]'
	'Workflow Manager 1.0  [version 2.0.40131.0]'
	'Workflow Manager Client 1.0  [version 2.1.10607.2]'

	#C++ Software List Entries
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.56336]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.61000]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4148  [version 9.0.30729.4148]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2010  x86 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.51106  [version 11.0.51106.1]'
	'Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.61030  [version 11.0.61030.0]'
	'Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005  [version 12.0.21005.1]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24212  [version 14.0.24212.0]'
	'Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.11.25325  [version 14.11.25325.0]'
	'Microsoft Visual C++ 2017 x64 Additional Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.11.25325  [version 14.11.25325]'
	'Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24212  [version 14.0.24212.0]'
	'Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.24212  [version 14.0.24212]'
	'Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.61030  [version 11.0.61030.0]'
	'Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.61030  [version 11.0.61030]'
	'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.30501  [version 12.0.30501.0]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.30501  [version 12.0.30501.0]'
	'Microsoft Visual C++ 2017 Redistributable (x64) - 14.15.26706  [version 14.15.26706.0]'
	'Microsoft Visual C++ 2017 Redistributable (x86) - 14.16.27027  [version 14.16.27027.1]'
	'Microsoft Visual C++ 2017 x64 Additional Runtime - 14.15.26706  [version 14.15.26706]'
	'Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.15.26706  [version 14.15.26706]'
	'Microsoft Visual C++ 2017 X86 Additional Runtime - 14.16.27024  [version 14.16.27024]'
	'Microsoft Visual C++ 2017 X86 Minimum Runtime - 14.16.27024  [version 14.16.27024]'

	#Solarwinds
	'Microsoft SQL Server 2008 Management Objects  [version 10.0.1600.22]'
	'Microsoft SQL Server 2008 Native Client  [version 10.0.1600.22]'
	'Microsoft SQL Server 2012 Management Objects   [version 11.0.2100.60]'
	'Microsoft SQL Server 2012 Management Objects  (x64)  [version 11.0.2100.60]'
	'Microsoft SQL Server Compact 3.5 SP2 ENU  [version 3.5.8080.0]'
	'Microsoft SQL Server Compact 3.5 SP2 x64 ENU  [version 3.5.8080.0]'
	'Microsoft System CLR Types for SQL Server 2012  [version 11.0.2100.60]'
	'Microsoft System CLR Types for SQL Server 2012 (x64)  [version 11.0.2100.60]'
	'SolarWinds Active Diagnostics 1.3.0.1019  [version 1.3.0.1019]'
	'SolarWinds Agent 1.4.9.0  [version 1.4.9.0]'
	'SolarWinds Collector v2.12.47  [version 2.12.47.0]'
	'SolarWinds Information Service v2015.1.7028  [version 115.1.7028.3]'
	'SolarWinds Integrated Virtual Infrastructure Monitor v2.1.1  [version 2.1.680.0]'
	'SolarWinds IP Address Manager v4.3.1  [version 4.3.1]'
	'SolarWinds Job Engine v1.6.0  [version 1.6.0.0]'
	'SolarWinds Job Engine v2.10.0  [version 2.10.34.0]'
	'SolarWinds MIBs v1.0.15  [version 1.0.15.0]'
	'SolarWinds Network Topology Mapper  [version 2.2.701.2]'
	'SolarWinds Network Topology Mapper 2.2.701.2  [version 2.2.701.2]'
	'SolarWinds Orion Core Services 2015.1.3  [version 115.1.9216.35100]'
	'SolarWinds Orion Improvement Program v2.0  [version 2.5.43.0]'
	'SolarWinds Orion NCM-NPM Integration v7.4.1  [version 7.4.3]'
	'SolarWinds Orion NetFlow Traffic Analyzer 4.1  [version 4.1.9813.0]'
	'SolarWinds Orion Network Atlas v1.14.42  [version 1.14.42.0]'
	'SolarWinds Orion Network Configuration Manager v7.4.1  [version 7.4.3]'
	'SolarWinds Orion Network Performance Monitor v11.5.3  [version 11.5.35100.0]'
	'SolarWinds Orion QoE 2.0.593.0  [version 2.0.593.0]'
	'SolarWinds SCP Server  [version 1.0.4.9]'
	'SolarWinds TFTP Server  [version 10.9.0.25]'
	'Solarwinds ToolsetOnTheWeb v11  [version 11.0.1232.2]'
	'SolarWinds User Device Tracker v3.2.3  [version 3.2.4012.3]'
	'SQL Server System CLR Types  [version 10.0.1600.22]'
	'Tumbleweed ONE-NET Configuration  [version TL-Enabled]'
	'WinPcap 4.1.3  [version 4.1.2980]'
	'WinPcapInst  [version 4.1.0.2980]'
	'DHTML Editing Component  [version 6.02.0001]'

	#SHPT SQL2016
	'Active Directory Authentication Library for SQL Server  [version 14.0.1000.169]'
	'Browser for SQL Server 2016  [version 13.2.5026.0]'
	'Configuration Manager Client  [version 5.00.8740.1000]'
	'Dell EqualLogic Host Integration Tools  [version 4.7.1]'
	'Hotfix 5264 for SQL Server 2016 (KB4475776) (64-bit)  [version 13.2.5264.1]'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2565063)  [version 1]'
	'McAfee Agent  [version 5.5.1.388]'
	'McAfee DLP Endpoint  [version 11.1.100.232]'
	'McAfee Host Intrusion Prevention  [version 8.00.1200]'
	'McAfee Policy Auditor Agent  [version 6.4.1.105]'
	'McAfee VirusScan Enterprise  [version 8.8.012000]'
	'Microsoft .NET Framework 4 Multi-Targeting Pack  [version 4.0.30319]'
	'Microsoft .NET Framework 4.5 Multi-Targeting Pack  [version 4.5.50710]'
	'Microsoft .NET Framework 4.5.1 Multi-Targeting Pack  [version 4.5.50932]'
	'Microsoft .NET Framework 4.5.1 Multi-Targeting Pack (ENU)  [version 4.5.50932]'
	'Microsoft .NET Framework 4.5.1 SDK  [version 4.5.51641]'
	'Microsoft .NET Framework 4.5.2 Multi-Targeting Pack  [version 4.5.51209]'
	'Microsoft .NET Framework 4.5.2 Multi-Targeting Pack (ENU)  [version 4.5.51209]'
	'Microsoft Analysis Services OLE DB Provider  [version 15.0.600.141]'
	'Microsoft Build Tools 14.0 (amd64)  [version 14.0.23107]'
	'Microsoft Build Tools 14.0 (x86)  [version 14.0.23107]'
	'Microsoft Build Tools Language Resources 14.0 (amd64)  [version 14.0.23107]'
	'Microsoft Build Tools Language Resources 14.0 (x86)  [version 14.0.23107]'
	'Microsoft Help Viewer 2.2  [version 2.2.23107]'
	'Microsoft Monitoring Agent  [version 7.1.10184.0]'
	'Microsoft ODBC Driver 13 for SQL Server  [version 14.0.1000.169]'
	'Microsoft Policy Platform  [version 68.1.1010.0]'
	'Microsoft Silverlight  [version 5.1.50907.0]'
	'Microsoft SQL Server 2008 Setup Support Files   [version 10.3.5500.0]'
	'Microsoft SQL Server 2012 Native Client   [version 11.3.6540.0]'
	'Microsoft SQL Server 2014 Management Objects   [version 12.0.2000.8]'
	'Microsoft SQL Server 2016 (64-bit)'
	'Microsoft SQL Server 2016 RsFx Driver  [version 13.2.5264.1]'
	'Microsoft SQL Server 2016 Setup (English)  [version 13.2.5264.1]'
	'Microsoft SQL Server 2016 T-SQL Language Service   [version 13.0.14500.10]'
	'Microsoft SQL Server 2016 T-SQL ScriptDom   [version 13.2.5026.0]'
	'Microsoft SQL Server 2017'
	'Microsoft SQL Server 2017 Policies   [version 14.0.1000.169]'
	'Microsoft SQL Server 2017 T-SQL Language Service   [version 14.0.17277.0]'
	'Microsoft SQL Server Data-Tier Application Framework (x86)  [version 14.0.4079.2]'
	'Microsoft SQL Server Management Studio - 17.8.1  [version 14.0.17277.0]'
	'Microsoft System CLR Types for SQL Server 2014  [version 12.0.2402.11]'
	'Microsoft System CLR Types for SQL Server 2017  [version 14.0.1000.169]'
	'Microsoft Visual Studio 2015 Shell (Isolated)  [version 14.0.23107.10]'
	'Microsoft Visual Studio 2015 Shell (Isolated)  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Isolated) Resources  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Minimum)  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Minimum) Interop Assemblies  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 Shell (Minimum) Resources  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 XAML Designer  [version 14.0.23107]'
	'Microsoft Visual Studio 2015 XAML Designer - ENU  [version 14.0.23107]'
	'Microsoft Visual Studio Services Hub  [version 1.0.23107.00]'
	'Microsoft Visual Studio Tools for Applications 2015  [version 14.0.23829]'
	'Microsoft Visual Studio Tools for Applications 2015 Finalizer  [version 14.0.23829]'
	'Microsoft Visual Studio Tools for Applications 2015 Language Support  [version 14.0.23107.20]'
	'Microsoft Visual Studio Tools for Applications 2015 Language Support - ENU Language Pack  [version 14.0.23107.20]'
	'Microsoft Visual Studio Tools for Applications 2015 Language Support Finalizer  [version 14.0.23107.20]'
	'Microsoft Visual Studio Tools for Applications 2015 x64 Hosting Support  [version 14.0.23829]'
	'Microsoft Visual Studio Tools for Applications 2015 x86 Hosting Support  [version 14.0.23829]'
	'Microsoft VSS Writer for SQL Server 2016  [version 13.2.5026.0]'
	'Roslyn Language Services - x86  [version 14.0.23107]'
	'SCAP Compliance Checker 5.2  [version 5.2]'
	'Service Pack 2 for SQL Server 2016 (KB4052908) (64-bit)  [version 13.2.5026.0]'
	'SQL Server 2016 Batch Parser  [version 13.0.1601.5]'
	'SQL Server 2016 Client Tools  [version 13.0.14500.10]'
	'SQL Server 2016 Client Tools Extensions  [version 13.2.5026.0]'
	'SQL Server 2016 Common Files  [version 13.2.5026.0]'
	'SQL Server 2016 Connection Info  [version 13.0.16108.4]'
	'SQL Server 2016 Database Engine Services  [version 13.2.5026.0]'
	'SQL Server 2016 Database Engine Shared  [version 13.2.5026.0]'
	'SQL Server 2016 DMF  [version 13.0.1601.5]'
	'SQL Server 2016 Shared Management Objects  [version 13.0.16107.4]'
	'SQL Server 2016 Shared Management Objects  [version 13.0.16114.4]'
	'SQL Server 2016 Shared Management Objects Extensions  [version 13.2.5026.0]'
	'SQL Server 2016 SQL Diagnostics  [version 13.0.1601.5]'
	'SQL Server 2016 XEvent  [version 13.0.1601.5]'
	'SQL Server 2017 Batch Parser  [version 14.0.1000.169]'
	'SQL Server 2017 Client Tools Extensions  [version 14.0.1000.169]'
	'SQL Server 2017 Common Files  [version 14.0.1000.169]'
	'SQL Server 2017 Connection Info  [version 14.0.1000.169]'
	'SQL Server 2017 DMF  [version 14.0.1000.169]'
	'SQL Server 2017 Integration Services Scale Out Management Portal  [version 14.0.1000.169]'
	'SQL Server 2017 Management Studio Extensions  [version 14.0.3026.27]'
	'SQL Server 2017 Shared Management Objects  [version 14.0.1000.169]'
	'SQL Server 2017 Shared Management Objects Extensions  [version 14.0.1000.169]'
	'SQL Server 2017 SQL Diagnostics  [version 14.0.1000.169]'
	'Sql Server Customer Experience Improvement Program  [version 13.2.5026.0]'
	'SQL Server Management Studio  [version 14.0.17277.0]'
	'SQL Server Management Studio for Analysis Services  [version 14.0.17277.0]'
	'SQL Server Management Studio for Reporting Services  [version 14.0.17277.0]'
	'SSMS Post Install Tasks  [version 14.0.17277.0]'
	'Tools for .Net 3.5  [version 3.11.50727]'
	'Update for  (KB2504637)  [version 1]'
	'Update for Microsoft Visual Studio 2015 (KB3095681)  [version 14.0.23317]'
	'Visual Studio 2015 Prerequisites  [version 14.0.23107]'
	'Visual Studio 2015 Prerequisites - ENU Language Pack  [version 14.0.23107]'

	#GEMINI
	'Binary Tree SMART Coexistence  [version 04.00.0007]'
	'Binary Tree SMART Directory Sync  [version 5.00.0100]'
	'Binary Tree SMART FreeBusy  [version 3.05.0001]'
	'Commvault ContentStore  [version 11.80.50.0]'
	'Configuration Manager Client  [version 5.00.7804.1000]'
	'Configuration Manager Client  [version 5.00.8239.1000]'
	'EMET 5.1  [version 5.1]'
	'Git version 2.7.0  [version 2.7.0]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946040)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946308)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946344)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB947540)  [version 1]'
	'Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB947789)  [version 1]'
	'IBM Domino Social Edition'
	'IBM mail server add-on'
	'IBM Traveler 9.0.1.15  [version 9.0.1.15]'
	'KB2528583  [version 10.51.2500.0]'
	'KB2630458  [version 10.52.4000.0]'
	'Label Security Toolkit  [version 1.5.2]'
	'Microsoft .NET Framework 4.5.2  [version 4.5.51209]'
	'Microsoft Application Error Reporting  [version 12.0.6015.5000]'
	'Microsoft Policy Platform  [version 1.2.3602.0]'
	'Microsoft Report Viewer Redistributable 2008 (KB971119)  [version 9.0.30731]'
	'Microsoft Report Viewer Redistributable 2008 SP1'
	'Microsoft Silverlight  [version 5.1.50906.0]'
	'Microsoft SQL Server 2008 R2 (64-bit)'
	'Microsoft SQL Server 2008 R2 Native Client  [version 10.53.6000.34]'
	'Microsoft SQL Server 2008 R2 Policies  [version 10.50.1600.1]'
	'Microsoft SQL Server 2008 R2 RsFx Driver  [version 10.53.6000.34]'
	'Microsoft SQL Server 2008 R2 Setup (English)  [version 10.53.6220.0]'
	'Microsoft SQL Server 2008 Setup Support Files   [version 10.1.2731.0]'
	'Microsoft SQL Server 2014 Transact-SQL ScriptDom   [version 12.0.2000.8]'
	'Microsoft SQL Server 2014 Upgrade Advisor   [version 12.0.2000.10]'
	'Microsoft SQL Server Browser  [version 10.53.6000.34]'
	'Microsoft SQL Server Compact 3.5 SP2 Query Tools ENU  [version 3.5.8080.0]'
	'Microsoft SQL Server System CLR Types (x64)  [version 10.53.6000.34]'
	'Microsoft SQL Server VSS Writer  [version 10.53.6000.34]'
	'Microsoft Sync Framework Runtime v1.0 (x64)  [version 1.0.1215.0]'
	'Microsoft Sync Services for ADO.NET v2.0 (x64)  [version 2.0.1215.0]'
	'Microsoft Visual C++ 2005 Redistributable  [version 8.0.59193]'
	'Microsoft Visual C++ 2005 Redistributable  [version 8.0.61001]'
	'Microsoft Visual C++ 2005 Redistributable (x64)  [version 8.0.59192]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.21022  [version 9.0.21022]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.17  [version 9.0.30729]'
	'Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.17  [version 9.0.30729]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.21005  [version 12.0.21005]'
	'Microsoft Visual Studio Tools for Applications 2.0 - ENU  [version 9.0.35191]'
	'NETWARCOM CTO 09-05  [version 1.00]'
	'ONE-NET Cleanup Post Script Executed  [version v14.40]'
	'ONE-NET Security Cleanup Script Executed  [version v14.40]'
	'ONE-NET Security Template Executed  [version v14.4]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB2972107)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB2972216)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB2978128)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3023224)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3035490)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3037581)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3074230)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3074550)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3097996)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3098781)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3122656)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3127229)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3135996)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3135996v2)  [version 2]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3142033)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB3163251)  [version 1]'
	'Security Update for Microsoft .NET Framework 4.5.2 (KB4014566)  [version 1]'
	'Service Pack 3 for SQL Server 2008 R2 (KB2979597) (64-bit)  [version 10.53.6000.34]'
	'Snare for Vista version 1.1.2  [version 1.1.2]'
	'SQL Server 2008 R2 SP2 Client Tools  [version 10.53.6000.34]'
	'SQL Server 2008 R2 SP2 Common Files  [version 10.53.6000.34]'
	'SQL Server 2008 R2 SP2 Database Engine Services  [version 10.53.6000.34]'
	'SQL Server 2008 R2 SP2 Database Engine Shared  [version 10.53.6000.34]'
	'SQL Server 2008 R2 SP2 Management Studio  [version 10.53.6000.34]'
	'Sql Server Customer Experience Improvement Program  [version 10.53.6000.34]'
	'SQLServeriDataAgent Instance001  [version 11.80.50.0]'
	'Update for Microsoft .NET Framework 4.5.2 (KB3210139)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4014514)  [version 1]'
	'Update for Microsoft .NET Framework 4.5.2 (KB4014559)  [version 1]'
	'USAF ACCM  [version 2.2.0.59]'
	'VMware Tools  [version 9.10.5.2981885]'
	'VMware Tools  [version 9.4.15.2827462]'
	'Windows PowerShell Extensions for SQL Server 2012   [version 11.0.2100.60]'
	'WindowsFileSystemiDataAgentAdvanced Instance001  [version 11.80.50.0]'
	'WindowsFileSystemiDataAgentCore Instance001  [version 11.80.50.0]'
	'WinSCP 5.7.6  [version 5.7.6]'
)

$approvedwin10software = @(
	'90meter Smartcard Manager 1.4.35 S  [version 1.4.35]'
	'ACCM  [version 3.2.6.2]'
	'ActivID ActivClient x64  [version 7.2.1]'
	'Axway Desktop Validator  [version 5.0]'
	'Cisco AnyConnect Secure Mobility Client   [version 4.10.01075]'
	'Citrix Authentication Manager  [version 21.4.0.3]'
	'Citrix Screen Casting for Windows  [version 19.11.100.48]'
	'Citrix Web Helper  [version 21.5.0.22]'
	'Citrix Workspace 2105  [version 21.5.0.48]'
	'Citrix Workspace Inside  [version 21.5.0.65534]'
	'Citrix Workspace(USB)  [version 21.4.0.10]'
	'Configuration Manager Client  [version 5.00.9058.1000]'
	'Definition Update for Microsoft Office 2016 (KB3115407) 32-Bit Edition'
	'DoD Secure Host Baseline  [version 10.7.0]'
	'Google Chrome  [version 96.0.4664.110]'
	'Herramientas de correcciÃ³n de Microsoft Office 2016'
	'Hotfix for Microsoft Visual C++ 2010  x64 Redistributable (KB2565063)  [version 1]'
	'MailCrypt  [version 3.1]'
	'McAfee Agent  [version 5.7.4.399]'
	'McAfee Endpoint Security Firewall  [version 10.7.0]'
	'McAfee Endpoint Security Threat Prevention  [version 10.7.0]'
	'McAfee Policy Auditor Agent  [version 6.5.2.307]'
	'Microsoft Access MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Edge Update  [version 1.3.153.53]'
	'Microsoft Excel MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft NetBanner  [version 2.1.161]'
	'Microsoft Office Professional Plus 2016  [version 16.0.4266.1001]'
	'Microsoft Office Proofing Tools 2016 - English  [version 16.0.4266.1001]'
	'Microsoft Outlook MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Policy Platform  [version 68.1.1010.0]'
	'Microsoft PowerPoint MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Publisher MUI (English) 2016  [version 16.0.4266.1001]'
	'Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161  [version 9.0.30729.6161]'
	'Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219  [version 10.0.40219]'
	'Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660  [version 12.0.40660.0]'
	'Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660  [version 12.0.40660]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.28.29914  [version 14.28.29914.0]'
	'Microsoft Visual C++ 2015-2019 Redistributable (x86) - 14.28.29914  [version 14.28.29914.0]'
	'Microsoft Visual C++ 2019 X64 Additional Runtime - 14.28.29914  [version 14.28.29914]'
	'Microsoft Visual C++ 2019 X64 Minimum Runtime - 14.28.29914  [version 14.28.29914]'
	'Microsoft Visual C++ 2019 X86 Minimum Runtime - 14.28.29914  [version 14.28.29914]'
	'Microsoft Visual Studio 2010 Tools for Office Runtime (x64)  [version 10.0.50903]'
	'Microsoft Word MUI (English) 2016  [version 16.0.4266.1001]'
	'Mozilla Firefox ESR (x86 en-US)  [version 91.4.1]'
	'Mozilla Maintenance Service  [version 91.4.1]'
	'OMNIKEY 3x21 PC/SC Driver  [version 3.0.0.0]'
	'Online Plug-in  [version 21.4.0.10]'
	'Outils de vÃ©rification linguistique 2016 de Microsoft OfficeÂ - FranÃ§ais  [version 16.0.4266.1001]'
	'Security Update for Microsoft Access 2016 (KB4504711) 32-Bit Edition'
	'Security Update for Microsoft Excel 2016 (KB5002098) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB2920727) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB3085538) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB3114690) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB3213551) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4011574) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4022162) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4022176) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4461476) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4484103) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4486670) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4504710) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB4504745) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB5001982) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB5002033) 32-Bit Edition'
	'Security Update for Microsoft Office 2016 (KB5002099) 32-Bit Edition'
	'Security Update for Microsoft OneNote 2016 (KB3115419) 32-Bit Edition'
	'Security Update for Microsoft PowerPoint 2016 (KB4493224) 32-Bit Edition'
	'Security Update for Microsoft Visio 2016 (KB4493151) 32-Bit Edition'
	'Security Update for Microsoft Word 2016 (KB5002004) 32-Bit Edition'
	'Self-service Plug-in  [version 21.5.0.22]'
	'Snare version 4.0.1.2a  [version 4.0.1.2a]'
	'Swift  [version 4.74.0]'
	'Tumbleweed ONE-NET Configuration  [version UFEYO-ENABLED-2012.A]'
	'UniversalForwarder  [version 7.3.3.0]'
	'Update for Microsoft Office 2016 (KB2920678) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB2920717) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB2920720) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB2920724) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3114524) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3114852) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3114903) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3115081) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3115276) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3118262) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3118263) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3118264) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3141456) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3178666) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3191929) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB3213650) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4011225) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4011259) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4011629) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4011634) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4022193) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4032254) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4462117) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4462119) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4462197) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4464535) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4464538) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4484145) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4484171) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4484467) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4486668) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4486711) 32-Bit Edition'
	'Update for Microsoft Office 2016 (KB4486747) 32-Bit Edition'
	'Update for Microsoft Outlook 2016 (KB5001998) 32-Bit Edition'
	'Update for Microsoft Project 2016 (KB4493191) 32-Bit Edition'
	'Update for Microsoft Publisher 2016 (KB4484334) 32-Bit Edition'
	'Update for Skype for Business 2016 (KB5001940) 32-Bit Edition'
)

$mitigatedpluginids = @(
	'126824'
	'12107'
	'35291'
	'45411'
	'42873'
	'51192'
	'104743'
	'125780'
	'125781'
	'126988'
	'127117'
	'122615'
	'128416'
	'127116'
	'130271'
	'157126'
	'139239'
	'156024'
	'125780'
	'57582'
	'108797'
)
#endregion testarrays


#endregion Values



	#replace xyz with your username if you want to run the dev versions
	#kahopkin
	If($env:username -eq "kahopkin")
	#If($env:username -eq "xyz")
	{
		$debugFlag = $true
	
		if($rar -and $bulk)
		{
			write-host "passed"
			create-rarbulkDev
		}#if($rar -and $bulk)
		elseif ($bulk) 
		{
			Write-Host "passedbulk"
			create-fullbulkDev
		}#elseif ($bulk)
		elseif ($rar) 
		{
			create-rarDev
		}#elseif ($rar)
		else 
		{
			create-fullDev
		}#else
	}#If($env:username -eq
	Else
	{
	#>
		$debugFlag	= $false
		if($rar -and $bulk)
		{
			write-host "passed"
			create-rarbulk
		}#if($rar -and $bulk)
		elseif ($bulk) 
		{
			Write-Host "passedbulk"
			create-fullbulk
		}#elseif ($bulk) 
		elseif ($rar) 
		{
			create-rar
		}#elseif ($rar) 
		else 
		{
			create-full
		}#else
	}#Else if not Debug


<#
	if($rar -and $bulk)
	{
		write-host "passed"
		create-rarbulkDev
	}#
	elseif ($bulk) 
	{
		Write-Host "passedbulk"
		create-fullbulkDev
	}#
	elseif ($rar) 
	{
		create-rarDev
	}#
	else 
	{
		create-fullDev
	}
#>

<#
#Close the workbook and exit excel
ExcelWorkSheet.Close($true)
$Excel.quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
#endregion EXCEL
#>