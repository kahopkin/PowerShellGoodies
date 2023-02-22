$WebhookData=@'
[{	
	"WebhookName": "Alert1676503247681",
	"RequestBody": "{\"schemaId\":\"azureMonitorCommonAlertSchema\",\"data\":{\"essentials\":{\"alertId\":\"/subscriptions/aa77a0e0-cbf2-48ea-b948-a79d72e8215e/providers/Microsoft.AlertsManagement/alerts/1d4efd4e-7220-1de6-ae9b-ff25102bda85\",\"alertRule\":\"FsLogix - Service is Stopped\",\"severity\":\"Sev1\",\"signalType\":\"Log\",\"monitorCondition\":\"Fired\",\"monitoringService\":\"Log Alerts V2\",\"alertTargetIDs\":[\"/subscriptions/aa77a0e0-cbf2-48ea-b948-a79d72e8215e\"],\"configurationItems\":[\"BMTN-DEVAVD-0.bmtntech.us\"],\"originAlertId\":\"0b72b0d0-dd65-41f2-a385-43f5fa938e6e\",\"firedDateTime\":\"2023-02-16T18:17:35.2025626Z\",\"description\":\"\",\"essentialsVersion\":\"1.0\",\"alertContextVersion\":\"1.0\"},\"alertContext\":{\"properties\":{},\"conditionType\":\"LogQueryCriteria\",\"condition\":{\"windowSize\":\"PT5M\",\"allOf\":[{\"searchQuery\":\" ConfigurationChange\\n| where ConfigChangeType == \\\"WindowsServices\\\"\\n| where SvcName == \\\"frxsvc\\\"\\n| where SvcStartupType == \\\"Auto\\\"\\n| where SvcChangeType == \\\"State\\\"\\n| summarize arg_max(TimeGenerated, *) by Computer, SvcName, SvcDisplayName\",\"metricMeasureColumn\":null,\"targetResourceTypes\":null,\"operator\":\"GreaterThan\",\"threshold\":\"0\",\"timeAggregation\":\"Count\",\"dimensions\":[{\"name\":\"Computer\",\"value\":\"BMTN-DEVAVD-0.bmtntech.us\"},{\"name\":\"SvcDisplayName\",\"value\":\"FSLogix Apps Services\"},{\"name\":\"SvcName\",\"value\":\"frxsvc\"}],\"metricValue\":1.0,\"failingPeriods\":{\"numberOfEvaluationPeriods\":1,\"minFailingPeriodsToAlert\":1},\"linkToSearchResultsUI\":\"https://portal.azure.us#@fece80a6-6aa5-42ac-8ca3-76a0180de310/blade/Microsoft_Azure_Monitoring_Logs/LogsBlade/source/Alerts.EmailLinks/scope/%7B%22resources%22%3A%5B%7B%22resourceId%22%3A%22%2Fsubscriptions%2Faa77a0e0-cbf2-48ea-b948-a79d72e8215e%22%7D%5D%7D/q/eJxdjssOgkAMRfd%2BRcNKDb%2FAwmDizg0kLk2FAk2cRzozPIwf7yCRBHe9vSftgdzohtsg6NnovEPd0u4NQ0dCsHTLspwsQZZBcmNdm8EVJD1X5JKVLvrqimqBGhldX226wqP4YNc7p%2BDNBvj7E3lPM%2BCCUij8IkBp7wrHfcmKLqQpSlOdwvEAjynKKhs8SfoT%2BQ5ndvaJ05w%2F/prettify/1/timespan/2023-02-16T18%3a09%3a25.0000000Z%2f2023-02-16T18%3a14%3a25.0000000Z\",\"linkToFilteredSearchResultsUI\":\"https://portal.azure.us#@fece80a6-6aa5-42ac-8ca3-76a0180de310/blade/Microsoft_Azure_Monitoring_Logs/LogsBlade/source/Alerts.EmailLinks/scope/%7B%22resources%22%3A%5B%7B%22resourceId%22%3A%22%2Fsubscriptions%2Faa77a0e0-cbf2-48ea-b948-a79d72e8215e%22%7D%5D%7D/q/eJxlkMtuwkAMRff9CotNoALED7BISdtNyyYRLCuTmMlInYdmPCFB%2FfgmjAJKu%2FPjHt8rw87osxTBIUujdzVqQU8%2FcKnJEcRdHBadJdhuYXaUujIXn5NrZEl%2BdlfnTblHFUVn1%2FqmnOxyRsfB3u%2Bkgc1E8Men1zMNAh%2BUQievBOjEl8J2XkhF76SpD03VEp4XcOr6sMoGJrccg9yKTHr7jd3Qj1ZsPDupxXwkFoNf8vJZ7FfZ6yE9ZKvN%2BqRYM5X1OvgEUFcPano0sm%2F5hxGyhdRaD%2BNn%2FnMPIP4n%2BQU%3D/prettify/1/timespan/2023-02-16T18%3a09%3a25.0000000Z%2f2023-02-16T18%3a14%3a25.0000000Z\",\"linkToSearchResultsAPI\":\"https://api.loganalytics.us/v1/subscriptions/aa77a0e0-cbf2-48ea-b948-a79d72e8215e/query?query=%20ConfigurationChange%0A%7C%20where%20ConfigChangeType%20%3D%3D%20%22WindowsServices%22%0A%7C%20where%20SvcName%20%3D%3D%20%22frxsvc%22%0A%7C%20where%20SvcStartupType%20%3D%3D%20%22Auto%22%0A%7C%20where%20SvcChangeType%20%3D%3D%20%22State%22%0A%7C%20summarize%20arg_max%28TimeGenerated%2C%20%2A%29%20by%20Computer%2C%20SvcName%2C%20SvcDisplayName&timespan=2023-02-16T18%3a09%3a25.0000000Z%2f2023-02-16T18%3a14%3a25.0000000Z\",\"linkToFilteredSearchResultsAPI\":\"https://api.loganalytics.us/v1/subscriptions/aa77a0e0-cbf2-48ea-b948-a79d72e8215e/query?query=%20ConfigurationChange%0A%7C%20where%20ConfigChangeType%20%3D%3D%20%22WindowsServices%22%0A%7C%20where%20SvcName%20%3D%3D%20%22frxsvc%22%0A%7C%20where%20SvcStartupType%20%3D%3D%20%22Auto%22%0A%7C%20where%20SvcChangeType%20%3D%3D%20%22State%22%0A%7C%20summarize%20arg_max%28TimeGenerated%2C%20%2A%29%20by%20Computer%2C%20SvcName%2C%20SvcDisplayName%7C%20where%20tostring%28Computer%29%20%3D%3D%20%27BMTN-DEVAVD-0.bmtntech.us%27%20and%20tostring%28SvcDisplayName%29%20%3D%3D%20%27FSLogix%20Apps%20Services%27%20and%20tostring%28SvcName%29%20%3D%3D%20%27frxsvc%27&timespan=2023-02-16T18%3a09%3a25.0000000Z%2f2023-02-16T18%3a14%3a25.0000000Z\"}],\"windowStartTime\":\"2023-02-16T18:09:25Z\",\"windowEndTime\":\"2023-02-16T18:14:25Z\"}}}}",
	"RequestHeader": {
		"X-CorrelationContext": "RkkKACgAAAACAAAAEACuel3mslDXRbLBfH6ofhkFAQAQANKOc8Ivjn9BpA44WNOT4HY=",
		"Connection": "Keep-Alive",
		"Expect": "100-continue",
		"Host": "f0038672-c79b-4634-9dcf-71fad890ef56.webhook.usge.azure-automation.us",
		"User-Agent": "IcMBroadcaster/1.0",
		"x-ms-request-id": "f5970319-5204-4b87-af7e-f309bd2d51d4"	
}
}]
'@



$webhookObj =  $WebhookData | ConvertFrom-Json
$myRequestBody = ConvertFrom-Json $webhookObj.RequestBody
$requestBodyData = $myRequestBody.data
$essentials = $requestBodyData.essentials
$hashtable = @{}
$essentials.psobject.properties | Foreach { $hashtable[$_.Name] = $_.Value }
foreach ($item in $essentials) 
{
    Write-host $item
}
#requires -module Az.Resources
#requires -module Az.OperationalInsights
#requires -module Az.Compute
#you will need to give the managed identity rights to the VM, can you just give contributor rights against the resource group of the VM for the purposes of the lab.
param  
(  
    [Parameter (Mandatory = $false)]  
    [object] $WebhookData  
)
Connect-AzAccount -Identity -ErrorAction stop
#Extract data from webhook
$AlertContext = (ConvertFrom-Json $WebhookData.RequestBody).data.alertContext

$AlertContext = $myRequestBody.data.alertContext
$allOf = $AlertContext.condition.allOf
$alertCondition = $myRequestBody.data.alertContext.condition
$dimensions = $allOf.dimensions
$computerName = $dimensions.value[0]
$computerResourceId = 
#$computerName = $AlertContext.AffectedConfigurationItems
$essentialsArr =  $essentials.alertTargetIDs.split("/")

$computerName= $essentialsArr[$essentialsArr.Count-1]

if(!$computerName)
{
    #$allwebhookData = ConvertFrom-Json $WebhookData.RequestBody
    $allwebhookData = $myRequestBody
    $workspaceobjref= Get-AzResource -resourceid $allwebhookData.data.essentials.alertTargetIDs[0]
    $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $workspaceobjref.ResourceGroupName -Name $workspaceobjref.Name
    $r = Invoke-AzOperationalInsightsQuery -Query $allwebhookData.data.alertContext.condition.allOf.searchQuery -Workspace $workspace -Timespan ((get-date $allwebhookData.data.alertContext.condition.windowEndTime) -(get-date $allwebhookData.data.alertContext.condition.windowEndTime).AddMinutes(-30))
    if($r)
    {
        $computername = $r.Results | Select-Object -First 1 -ExpandProperty computer
    }
    else
    {
        throw "no search results found"
    }
}
Write-Output "Computername: $computerName"
$scriptcontents = @'
"Running script on $env:computername"
Restart-Service -Name frxsvc -Verbose -Force
Get-service frxsvc
'@
$scriptcontents > .\tempscript.ps1
$vm = Get-AzVM | Where-Object Name -eq $computerName
"Invoking command on $computername"
$output = Invoke-AzVMRunCommand -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -CommandId 'RunPowerShellScript' -ScriptPath '.\tempscript.ps1' 
$output.Value[0].Message
Remove-item .\tempscript.ps1




#kats
$WebhookData=@'
[{
	"WebhookName": "Alert1676470490681",
	"RequestBody": "{\"schemaId\":\"azureMonitorCommonAlertSchema\",\"data\":{\"essentials\":{\"alertId\":\"/subscriptions/355e427a-6396-4164-bd2e-d0f24719ea04/providers/Microsoft.AlertsManagement/alerts/5736f3b1-3d82-41cc-9e17-75f1aae2dfb7\",\"alertRule\":\"Error\",\"severity\":\"Sev1\",\"signalType\":\"Metric\",\"monitorCondition\":\"Resolved\",\"monitoringService\":\"Platform\",\"alertTargetIDs\":[\"/subscriptions/355e427a-6396-4164-bd2e-d0f24719ea04/resourcegroups/rg-datacenter2019/providers/microsoft.compute/virtualmachines/datacenter2019\"],\"configurationItems\":[\"datacenter2019\"],\"originAlertId\":\"355e427a-6396-4164-bd2e-d0f24719ea04_rg-Automation_microsoft.insights_metricAlerts_Error_-2081934275\",\"firedDateTime\":\"2023-02-15T16:05:29.9510784Z\",\"resolvedDateTime\":\"2023-02-15T16:12:26.8047668Z\",\"description\":\"Severity=Error\",\"essentialsVersion\":\"1.0\",\"alertContextVersion\":\"1.0\"},\"alertContext\":{\"properties\":null,\"conditionType\":\"MultipleResourceMultipleMetricCriteria\",\"condition\":{\"windowSize\":\"PT5M\",\"allOf\":[{\"metricName\":\"Percentage CPU\",\"metricNamespace\":\"Microsoft.Compute/virtualMachines\",\"operator\":\"GreaterThan\",\"threshold\":\"5\",\"timeAggregation\":\"Average\",\"dimensions\":[],\"metricValue\":2.481,\"webTestName\":null}],\"windowStartTime\":\"2023-02-15T16:04:15.537Z\",\"windowEndTime\":\"2023-02-15T16:09:15.537Z\"}}}}",
	"RequestHeader": {
		"X-CorrelationContext": "RkkKACgAAAACAAAAEABx20ozhnm9RIBri2FswdpoAQAQALJD532H/DNLshkIii5uoJw=",
		"Connection": "Keep-Alive",
		"Expect": "100-continue",
		"Host": "af9509ec-287f-4032-8005-c52c8d99617e.webhook.usge.azure-automation.us",
		"User-Agent": "IcMBroadcaster/1.0",
		"x-ms-request-id": "61586449-729b-4c2d-856f-aa6b0bf2913c"
	}
}]
'@


$environmentJson = @'
[{
  "name": "AzureCloud",
  "gallery": "https://gallery.azure.com/",
  "graph": "https://graph.windows.net/",
  "portal": "https://portal.azure.com",
  "graphAudience": "https://graph.windows.net/",
  "activeDirectoryDataLake": "https://datalake.azure.net/",
  "batch": "https://batch.core.windows.net/",
  "media": "https://rest.media.azure.net",
  "sqlManagement": "https://management.core.windows.net:8443/",
  "vmImageAliasDoc": "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json",
  "resourceManager": "https://management.azure.com/",
  "authentication": {
    "loginEndpoint": "https://login.microsoftonline.com/",
    "audiences": [
      "https://management.core.windows.net/",
      "https://management.azure.com/"
    ],
    "tenant": "common",
    "identityProvider": "AAD"
  },
  "suffixes": {
    "acrLoginServer": ".azurecr.io",
    "azureDatalakeAnalyticsCatalogAndJob": "azuredatalakeanalytics.net",
    "azureDatalakeStoreFileSystem": "azuredatalakestore.net",
    "azureFrontDoorEndpointSuffix": "azurefd.net",
    "keyvaultDns": ".vault.azure.net",
    "sqlServerHostname": ".database.windows.net",
    "storage": "core.windows.net"
  }
}]
'@

$environment = $environmentJson | ConvertFrom-Json 