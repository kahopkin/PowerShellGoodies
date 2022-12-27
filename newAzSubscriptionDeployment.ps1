New-AzSubscriptionDeployment `
-Name Deployment-Vixen-Transfer-Prod-12-21-2022 `
-AppName Vixen `
-Solution Transfer `
-Environment prod `
-Location usgovvirginia `
-TimeStamp "12/22/2022 15:32" `
-TemplateFile C:\GitHub\dtp\Deploy\main.bicep `
-TemplateParameterFile C:\GitHub\dtp\Deploy\main.parameters.prod.json `
-DeployObject $DeployInfo




New-AzSubscriptionDeployment `
-Name Deployment-Vixen-Transfer-Prod-12-21-2022 `
-AppName Vixen `
-Solution Transfer `
-Environment prod `
-Location usgovvirginia `
-TimeStamp '12/22/2022 15:39' `
-TemplateFile C:\GitHub\dtp\Deploy\main.bicep `
-TemplateParameterFile C:\GitHub\dtp\Deploy\main.parameters.prod.json `
-ApiClientId 094cc3b3-b546-419f-98fc-bffb5a038cbb `
-ApiClientSecret ip7LljF6gL0r0fP_Wa.x4S2-3Bcqq~dss1 `
-SqlServerAdministratorLogin dtpadmin `
-SqlServerAdministratorPassword '1qaz2wsx#EDC$RFV' `
-DeployObject $DeployInfo



New-AzSubscriptionDeployment `
-Name Deployment-Vixen-Transfer-Prod-12-21-2022 `
-AppName Vixen `
-Solution Transfer `
-Environment prod `
-Location usgovvirginia `
-TimeStamp '12/22/2022 15:39' `
-TemplateFile .\main.bicep `
-TemplateParameterFile .\main.parameters.prod.json `
-DeployObject $DeployInfo

C:\GitHub\dtp\Deploy\main.parameters.prod.json