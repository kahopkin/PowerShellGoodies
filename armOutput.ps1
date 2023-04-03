<#If($debugFlag){  
#}#If($debugFlag) #> 

$armOutput = @'
{
"openIdIssuer":  {
                        "Type":  "String",
                        "Value":  "https://sts.windows.net/f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0/v2.0"
                    },
"webAppDNSSuffix":  {
                        "Type":  "String",
                        "Value":  ".azurewebsites.us"
                    },
"environmentOutput":  {
                            "Type":  "Object",
                            "Value":  [
                                "AzureUSGovernment",
                                "https://gallery.usgovcloudapi.net",
                                "https://graph.windows.net",
                                "https://portal.azure.us",
                                "https://graph.windows.net",
                                "",
                                "https://batch.core.usgovcloudapi.net",
                                "https://rest.media.usgovcloudapi.net",
                                "https://management.core.usgovcloudapi.net:8443",
                                "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json",
                                "https://management.usgovcloudapi.net"                          
                            ]
                        },
"vnetId":  {
                "Type":  "String",
                "Value":  "/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod"
            },
"subnetIds":  {
                    "Type":  "Array",
                    "Value":  [
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-default-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-keyvault-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-webapp-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-function-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-storage-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-functionintegration-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/AzureBastionSubnet\""
                    ]
                },
"subnetNames":  {
                    "Type":  "Array",
                    "Value":  [
                        "\"name\": \"snet-default-dts-pickup-prod\"",
                        "\"name\": \"snet-keyvault-dts-pickup-prod\"",
                        "\"name\": \"snet-webapp-dts-pickup-prod\"",
                        "\"name\": \"snet-function-dts-pickup-prod\"",
                        "\"name\": \"snet-storage-dts-pickup-prod\"",
                        "\"name\": \"snet-functionintegration-dts-pickup-prod\"",
                        "\"name\": \"AzureBastionSubnet\""
                    ]
                }
}

'@

foreach ($key in $armOutput.Outputs.keys) {
    <#if ($key -eq "NewVnetResourceId") {
        $NewVnetResourceId = $outputs.Outputs[$key].value
    }#>
    Write-Host $outputs.Outputs[$key].value
}

$armOutputObj = $armOutput | convertfrom-json

$armOutputObj.subnetNames[0].Value.Count

$i=0
$armOutputObj.PSObject.Properties | ForEach-Object {
    $keyname = $_.Name
    $value = $_.Value.value
    $type = ($_.value.type).ToLower()
    
    #$vsoAttribs = @("task.setvariable variable=$keyName")
    #Write-Host "The value of [$keyName] is [$value]"
    #Write-Host "$keyName=$value"
    if ($type -eq "array") 
    {
        Write-Host -ForegroundColor Red "Array"
        Write-Host -ForegroundColor Cyan  "`$keyName=`"$keyName`""
        Write-Host -ForegroundColor Yellow "[$i]"

        Write-Host -ForegroundColor Green  "`$value=`"$value`""
        #Write-Host $_.Value.value.name
        Write-Host -ForegroundColor Gray ($_.Value.value).GetType()
        $value = $_.Value.value.name -join ',' 
        ## All array variables will come out as comma-separated strings
    }

    If($keyName -eq "subnetNames")
    {
        Write-Host -ForegroundColor Green  "$keyName"
        Write-Host -ForegroundColor Cyan $value
        #Write-Host $value.GetType().Name
    }
    Else
    {
        Write-Host -ForegroundColor Cyan  "$keyName"
        Write-Host -ForegroundColor Yellow "$value"
    }
}#foreach


$armOutputObj.subnetNames[0].Value
$armOutputObj.subnetNames[0].Value
foreach ($item in $armOutputObj.subnetNames[0].Value) {
    $item.value
}

foreach ($item in ($armOutputObj.subnetNames.Value).GetEnumerator())
{
    $item.GetType()
    <#$currItem = $item.value
    $currItem.PSObject.Properties | ForEach-Object {
                #$_.Name
                #$_.Value
                Write-Host -ForegroundColor Cyan $_.Name "=" $_.Value
            }
            #>
} 


#parse_arm_deployment_output.ps1
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ArmOutputString,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [switch]$MakeOutput
)

Write-Output "Retrieved input: $ArmOutputString"
$armOutputObj = $ArmOutputString | ConvertFrom-Json

$armOutputObj.PSObject.Properties | ForEach-Object {
    $type = ($_.value.type).ToLower()
    $keyname = $_.Name
    $vsoAttribs = @("task.setvariable variable=$keyName")

    if ($type -eq "array") {
        $value = $_.Value.value.name -join ',' ## All array variables will come out as comma-separated strings
    } elseif ($type -eq "securestring") {
        $vsoAttribs += 'isSecret=true'
    } elseif ($type -ne "string") {
        throw "Type '$type' is not supported for '$keyname'"
    } else {
        $value = $_.Value.value
    }
        
    if ($MakeOutput.IsPresent) {
        $vsoAttribs += 'isOutput=true'
    }

    $attribString = $vsoAttribs -join ';'
    $var = "##vso[$attribString]$value"
    Write-Output -InputObject $var
}








$armOutput = @'
{
"openIdIssuer":  {
                        "Type":  "String",
                        "Value":  "https://sts.windows.net/f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0/v2.0"
                    },
"webAppDNSSuffix":  {
                        "Type":  "String",
                        "Value":  ".azurewebsites.us"
                    },
"environmentOutput":  {
                            "Type":  "Object",
                            "Value":  [
                                "AzureUSGovernment",
                                "https://gallery.usgovcloudapi.net",
                                "https://graph.windows.net",
                                "https://portal.azure.us",
                                "https://graph.windows.net",
                                "",
                                "https://batch.core.usgovcloudapi.net",
                                "https://rest.media.usgovcloudapi.net",
                                "https://management.core.usgovcloudapi.net:8443",
                                "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json",
                                "https://management.usgovcloudapi.net"                          
                            ]
                        },
"vnetId":  {
                "Type":  "String",
                "Value":  "/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod"
            },
"subnetIds":  {
                    "Type":  "Array",
                    "Value":  [
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-default-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-keyvault-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-webapp-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-function-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-storage-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-functionintegration-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/AzureBastionSubnet\""
                    ]
                },
"subnetNames":  {
                    "Type":  "Array",
                    "Value":  [
                        "\"name\": \"snet-default-dts-pickup-prod\"",
                        "\"name\": \"snet-keyvault-dts-pickup-prod\"",
                        "\"name\": \"snet-webapp-dts-pickup-prod\"",
                        "\"name\": \"snet-function-dts-pickup-prod\"",
                        "\"name\": \"snet-storage-dts-pickup-prod\"",
                        "\"name\": \"snet-functionintegration-dts-pickup-prod\"",
                        "\"name\": \"AzureBastionSubnet\""
                    ]
                }
}

'@

$armOutput = @'
{
    "sqlServerName": {
	    "value" : "[some sql server name].database.windows.net",
        "type": "string"
    },
    "databaseName": {
		"value" : "[some sql db name]",
        "type": "string"
    }
}
'@





$armOutput = @'
{
"openIdIssuer":  {
                        "Type":  "String",
                        "Value":  "https://sts.windows.net/f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0/v2.0"
                    },
"webAppDNSSuffix":  {
                        "Type":  "String",
                        "Value":  ".azurewebsites.us"
                    },
"vnetId":  {
                "Type":  "String",
                "Value":  "/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod"
            },
"subnetIds":  {
                    "Type":  "Array",
                    "Value":  [
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-default-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-keyvault-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-webapp-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-function-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-storage-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/snet-functionintegration-dts-pickup-prod\"",
                        "\"id\": \"/subscriptions/2b2df691-421a-476f-bfb6-7b7e008d6041/resourceGroups/rg-dts-pickup-prod/providers/Microsoft.Network/virtualNetworks/vnet-dts-pickup-prod/subnets/AzureBastionSubnet\""
                    ]
                },
"subnetNames":  {
                    "Type":  "Array",
                    "Value":  [
                        "\"name\": \"snet-default-dts-pickup-prod\"",
                        "\"name\": \"snet-keyvault-dts-pickup-prod\"",
                        "\"name\": \"snet-webapp-dts-pickup-prod\"",
                        "\"name\": \"snet-function-dts-pickup-prod\"",
                        "\"name\": \"snet-storage-dts-pickup-prod\"",
                        "\"name\": \"snet-functionintegration-dts-pickup-prod\"",
                        "\"name\": \"AzureBastionSubnet\""
                    ]
                }
}

'@


$armOutputObj = $armOutput | convertfrom-json


$ArmOutputString = $armOutput


Write-Host -ForegroundColor Cyan "`$armOutput=@'`n["        
$json = ConvertTo-Json $DeployInfo
Write-Host -ForegroundColor Cyan $json
Write-Host -ForegroundColor Cyan "]`n'@"
#>