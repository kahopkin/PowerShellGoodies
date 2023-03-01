<#
https://www.leogether.com/2022/01/create-azure-ad-app-registration-using.html
https://github.com/Pujago/ApplicationRegistrationUsingMSGraphAPIs-Public
CreateSimpleApplicationRegistration.ps1

#>

#Generate Access Token
$url = "https://login.microsoftonline.com/<your tenant Id>/oauth2/token"
     
$body = "grant_type=client_credentials&client_id=$clientId&client_secret=<your app registration secret>&resource=https://graph.microsoft.com"
$header = @{
        "Content-Type" = 'application/x-www-form-urlencoded'
}
$request = Invoke-WebRequest -Method 'Post' -Uri $url -Body $body -Header $header

#Create Application using Graph API
$url = "https://graph.microsoft.com/v1.0/applications"
$header = @{
    Authorization = "Bearer $token"
}
$postBody = @"

    "displayName": "$DisplayName"
}
"@
 try 
{                
    $appRegistration = Invoke-RestMethod -Method 'POST' -Uri $url -Body $postBody -ContentType 'application/json' -Headers $header

}


#connect using master app credentials:
$ServicePrincipalUser="<Master app registration Client Id>"
$ServicePrincipalPW="<Master app registration client secret>"
$passwd = ConvertTo-SecureString $ServicePrincipalPW -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($ServicePrincipalUser, $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant "<Your tenant Id>" 

#Or if you have application administrator role, you can use command below to login in.
Connect-AzAccount -TenantId <Your tenant ID>

#Run the script:
\CreateSimpleApplicationRegistration.ps1 -appName "<Enter a display name you want to create>" 


<#
CREATE APP ROLES USING MS GRAPH API AND POWERSHELL - PART 2
https://www.leogether.com/2022/01/azure-ad-app-registration-create-app.html
CreateAppRoles.ps1
#>
