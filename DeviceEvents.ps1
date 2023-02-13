Write-Host -ForegroundColor Yellow "" 
Write-Host -ForegroundColor Yellow ""

Write-Host -ForegroundColor DarkYellow "[Cancel and Quit] = Terminate Deployment`n" 


Write-Host -ForegroundColor Yellow "[Cancel and Quit] = Terminate Deployment`n" 

Make a selection by entering the character 

















DeviceEvents `
| where Timestamp > datetime(2023-01-13) `
| where ActionType contains "AsrOfficeMacroWin32ApiCallsBlocked" `
| where FileName contains ".lnk" `
| extend JSON = parse_json(AdditionalFields) `
| extend isAudit = tostring(JSON.IsAudit) `
| where isAudit == "false" `
| summarize by Timestamp, DeviceId, FileName, FolderPath, ActionType, AdditionalFields, isAudit `
| sort by Timestamp asc