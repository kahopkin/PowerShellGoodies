<#
2-AuthenticatePSAsUserForGraph.ps1

https://learn.microsoft.com/en-us/graph/tutorials/powershell?tabs=powershell&tutorial-step=2
#Add user authentication

#>

$clientId = <your-client-id>
$tenantId = <tenant-id>

$graphScopes = "user.read mail.read mail.send"

# Authenticate the user
#If you would prefer to use interactive browser authentication, omit the -UseDeviceAuthentication parameter.
Connect-MgGraph -ClientId $clientId -TenantId $tenantId -Scopes $graphScopes # -UseDeviceAuthentication

# Get the Graph context
Get-MgContext