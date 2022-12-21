#Azure Commercial: 
Add-AzEnvironment -AutoDiscover -Uri "https://management.azure.com/metadata/endpoints?api-version=2020-06-01"
#Azure Government: 
Add-AzEnvironment -AutoDiscover -Uri "https://management.usgovcloudapi.net/metadata/endpoints?api-version=2020-06-01"
#Azure X: 
Add-AzEnvironment -AutoDiscover -Uri "https://<Resource_Management_Url>/metadata/endpoints?api-version=2020-06-01"