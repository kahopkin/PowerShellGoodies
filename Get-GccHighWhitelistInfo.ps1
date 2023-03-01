
<#PSScriptInfo
 
.VERSION 1.2
 
.GUID 97f3989f-b934-46a2-ae4c-a7c6b234ffbf
 
.AUTHOR daduck
 
.COMPANYNAME
 
.COPYRIGHT
 
.TAGS
 
.LICENSEURI
 
.PROJECTURI
 
.ICONURI
 
.EXTERNALMODULEDEPENDENCIES
 
.REQUIREDSCRIPTS
 
.EXTERNALSCRIPTDEPENDENCIES
 
.RELEASENOTES
 
 
.PRIVATEDATA
 
#> 





<#
 
.DESCRIPTION
Queries the Office 365 tenant parameters to determine if this tenant is a commercial tenant, or a US Government High (GCC High) tenant.
 
#> 

Param()

$tenant = Read-Host -Prompt "Enter the domain name or tenant ID here"
$tenantInfo = Invoke-RestMethod -Uri https://login.microsoftonline.com/$tenant/.well-known/openid-configuration -Method Get

# Display the URL's to the user. GCC-H URL's must end with .us
Write-Host "The current configured endpoint URL's are below. GCC-H URLs must have .us instead of .com`n`n" -ForegroundColor Yellow -BackgroundColor Black

Write-Host "The token endpoint URL is: `t`t`t" $tenantInfo.token_endpoint
Write-Host "The authorization endpoint is: `t`t`t" $tenantInfo.authorization_endpoint
Write-Host "The end session endpoint is: `t`t`t" $tenantInfo.end_session_endpoint
Write-Host "The check session iframe endpoint is: `t`t" $tenantInfo.check_session_iframe
Write-Host "The userinfo endpoint is: `t`t`t" $tenantInfo.userinfo_endpoint
Write-Host "The cloud instance name is: `t`t`t" $tenantInfo.cloud_instance_name `n

Write-Host "The current configured endpoint URL's are above." `n -ForegroundColor Red -BackgroundColor Black

# Display if the region_scope is USG - it MUST be "USG" for the tenant to be in GCC-H
Write-Host "GCC-H tenants must have the region scope set to USG (Fairfax) or USGov (Arlington) " -ForegroundColor Yellow -BackgroundColor Black
Write-Host "The sub scope should always be DODCON. " -ForegroundColor White -BackgroundColor Black
Write-Host "If it is not USG, this tenant cannot be whitelisted. This includes USGov." -ForegroundColor Yellow -BackgroundColor Black

if ($tenantInfo.tenant_region_sub_scope -eq "DODCON") {
    Write-Host `n"The tenant region scope is: `t`t`t" $tenantInfo.tenant_region_scope 
    Write-Host "The tenant region sub scope is: `t`t" $tenantInfo.tenant_region_sub_scope
    Write-Host `n"It appears that this tenant is a USG tenant. Please confirm the URLs above end with .us for the FQDN, and not .com" -ForegroundColor Green -BackgroundColor Black `n
}

elseif ($tenantinfo.tenant_region_scope -ne "USG") {
    Write-Host "`nThe tenant region scope is: `t`t`t" $tenantInfo.tenant_region_scope 
    Write-Host `n"It appears that this tenant is NOT a USG tenant." -ForegroundColor Red -BackgroundColor Black `n
}