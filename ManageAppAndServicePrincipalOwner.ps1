#ManageAppAndServicePrincipalOwner
# Adds, lists or removes owners of Azure AD Application and ServicePrincipal objects

<#
Examples:

    # Add bob@contoso.com as owner to both app and service principal
    .\ManageAppAndServicePrincipalOwner.ps1 -Add "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56"

    # List owners for the app in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 -List -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -TenantId "contoso.com" | ft userPrincipalName

    # List owners for the app's service principal in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 -List -ServicePrincipal -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -TenantId "contoso.com" | ft userPrincipalName

    # Remove bob@contoso.com as an owner for the app, and output the acces token to $at for subsequent reuse
    .\ManageAppAndServicePrincipalOwner.ps1 -Remove "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -AccessTokenOut ([ref] $at)

   

    # Add bob@contoso.com as owner to both app and service principal
    .\ManageAppAndServicePrincipalOwner.ps1 `
        -Add "bob@contoso.com" `
        -Application `
        -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56"

    # List owners for the app in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 `
        -List -Application `
        -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" `
        -TenantId "contoso.com" | ft userPrincipalName

    # List owners for the app's service principal in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 `
        -List -ServicePrincipal `
        -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" `
        -TenantId "contoso.com" | ft userPrincipalName

    # Remove bob@contoso.com as an owner for the app, and output the acces token to $at for subsequent reuse
    .\ManageAppAndServicePrincipalOwner.ps1 -Remove "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -AccessTokenOut ([ref] $at)
#>



[CmdletBinding()]
param(
    
    # Apply action to Application
    [switch] $Application,

    # Apply action to ServicePrincipal
    [switch] $ServicePrincipal,

    # ObjectId or UPN of owner to add
    $Add = $null,
    
    $UserObjectId = $null,

    # ObjectId or UPN of owner to remove
    $Remove = $null,

    # List current owners, will happen after add/remove
    [switch] $List,

    # Tenant ID or domain name identifying the directory
    $TenantId = $null,

    # AppId identifying the application
    [Parameter(Mandatory = $true)]
    $AppId,

    # A valid access token
    $AccessToken = $null,

    # A reference to where a retrieved access token will be placed
    [ref] $AccessTokenOut,

    # Path to 'Microsoft.IdentityModel.Clients.ActiveDirectory.dll.
    $PathToAdal = $null,

    # If set, will always prompt during auth
    [switch] $Prompt
)

& "$PSScriptRoot\GetAzureADToken.ps1"

# Default is to apply to both Application and ServicePrincipal
if (-not $Application -and -not $ServicePrincipal) {
    $Application = $true
    $ServicePrincipal = $true
}

# If no TenantId given, use one from the Add or Remove UPNs, if a UPN is used
Write-Host -ForegroundColor Magenta "[92]`n `$Application=`"$Application`""
Write-Host -ForegroundColor Magenta "[93]`n `$ServicePrincipal=`"$ServicePrincipal`""

Write-Host -ForegroundColor Cyan "[95]`n `$TenantId=`"$TenantId`""
if ($TenantId -eq $null) 
{
    if ($Add -ne $null -and $Add.Contains("@")) 
    {
        $TenantId = $Add.Split("@")[1]
    } 
    elseif ($Remove -ne $null -and $Remove.Contains("@")) 
    {
        $TenantId = $Remove.Split("@")[1]
    } 
    else 
    {
        throw "TenantId required, or use a UPN in Add or Remove"
    }
    Write-Warning "Using '$TenantId' as TenantId"
}#if ($TenantId -eq $null) 

$AccessToken = GetAzureADToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret
Write-Host -ForegroundColor Yellow "[114]`n `$AccessToken=`"$AccessToken`""

if ($AccessToken -eq $null) 
{

    # Load ADAL. If the path to ADAL is not defined, use script's directory
    if ($PathToAdal -eq $null) 
    {
        $PathToAdal = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    $PathToAdal = (Join-Path $PathToAdal "Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
    Write-Host -ForegroundColor Cyan "[125]`n `$PathToAdal=`"$PathToAdal`""
    
    if (-not (Test-Path -Path $PathToAdal -PathType Leaf)) 
    {
        throw "ADAL library not found at '$PathToAdal'"
    }
    Add-Type -Path $PathToAdal

    # Get an access token to Graph API using the 'Azure AD PowerShell' client ID
    $AzureContext = Get-AzContext    
    #$oauth2tokenendpointv1 = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id +"/oauth2/token"    
    #Write-Host -ForegroundColor Yellow "`$oauth2tokenendpointv1 =`"$oauth2tokenendpointv1`""

    $AuthenticationContext = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id
    Write-Host -ForegroundColor Yellow "[139]`n `$AuthenticationContext =`"$AuthenticationContext`""
    $AuthContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext $AuthenticationContext
    
    $PromptBehavior = if ($Prompt) { "Always" } else { "Auto" }
    try {
        $AuthResult = $AuthContext.AcquireToken(
                        $GraphUrl,              
                        $APIAppRegAppId,   <# Client ID #>
                        [Uri]::new('urn:ietf:wg:oauth:2.0:oob'),  <# Redirect URI #>
                        $PromptBehavior                           <# Prompt, 'Auto' or 'Always' #>
                      )
        $AccessToken = $AuthResult.AccessToken
        if ($AccessTokenOut -ne $null) {
            $AccessTokenOut.Value = $AccessToken
        }
    } catch {
        throw $_
    }
}# ($AccessToken -eq $null) 

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type" = "application/json"
}
Write-Host -ForegroundColor Green "[163]`n `$Headers=`"$Headers`""

# Resolves a user ID (UPN or ObjectId) to an ObjectId
function ResolveUserObjectId ($UserId, $TenantId, $Headers) 
{
    $AzureContext = Get-AzContext    
    $ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id 
    Write-Host -ForegroundColor Yellow "[170]`n `$ActiveDirectoryAuthority =`"$ActiveDirectoryAuthority`""
    
    Write-Host -ForegroundColor Yellow "[172]`n `$UserId=`"$UserId`""
    Write-Host -ForegroundColor Yellow "[173]`n `$TenantId=`"$TenantId`""
    Write-Host -ForegroundColor Yellow "[174]`n `$Headers=`"$Headers`""
    # Get the User object of the additional owner
    $User = $null
    $Uri = $ActiveDirectoryAuthority + "/users/$UserId`?api-version=1.6"  
    Write-Host -ForegroundColor Cyan "[178]`n `$Uri=`"$Uri`""
    try {
        $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri
        $User = ($Result.Content | ConvertFrom-Json)
        $UserId = $User.objectId
        Write-Host -ForegroundColor Yellow "[184]`n `$UserId=`"$UserId`""
        return $UserId
    } catch {
        throw "Could not find user '$UserId'"
    }
}#ResolveUserObjectId

# Get the Application object by AppId
$App = $null
Write-Host -ForegroundColor Magenta "[193]`n `$Application=`"$Application`""
if ($Application) 
{
    $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri "https://graph.windows.net/$TenantId/applications?`$filter=appId eq '$AppId'&api-version=1.6"
    $App = ($Result.Content | ConvertFrom-Json).value[0]
    if ($App -eq $null) {
        Write-Warning "Application object not found for AppId '$AppId'"
    }
}#if ($Application) 

# Get the ServicePrincipal object by AppId
$SP = $null
Write-Host -ForegroundColor Magenta "[206]`n `$CurrUserPrincipalName=`"$CurrUserPrincipalName`""
if ($ServicePrincipal) 
{
    $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri "https://graph.windows.net/$TenantId/servicePrincipals?`$filter=appId eq '$AppId'&api-version=1.6"
    $SP = ($Result.Content | ConvertFrom-Json).value[0]
    if ($SP -eq $null) {
        Write-Warning "ServicePrincipal object not found for AppId '$AppId'"
    }
}#if ($ServicePrincipal) 

Write-Host -ForegroundColor Magenta "[217]`n `$Add=`"$Add`""
if ($Add -ne $null) 
{
    #function ResolveUserObjectId ($UserId, $TenantId, $Headers) 
    $UserObjectId = ResolveUserObjectId $Add $TenantId $Headers
    Write-Host -ForegroundColor Cyan "[222]`n `$UserObjectId=`"$UserObjectId`""

    # The link to the additional owner, in JSON
    $AdditionalOwnerLink = @{
        "url" = "https://graph.windows.net/$TenantId/users/$UserObjectId"
    } | ConvertTo-Json

    # Add new owner to Application
    if ($App -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Post `
                    -Uri "https://graph.windows.net/$TenantId/applications/$($App.objectId)/`$links/owners?api-version=1.6" `
                    -Body $AdditionalOwnerLink
        if ($Result.StatusCode -eq 204) {    
            Write-Host "New owner '$Add' added to Application"
        }
    }

    # Add new owner to ServicePrincipal
    if ($SP -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Post `
                    -Uri "https://graph.windows.net/$TenantId/servicePrincipals/$($SP.objectId)/`$links/owners?api-version=1.6" `
                    -Body $AdditionalOwnerLink
        if ($Result.StatusCode -eq 204) {    
            Write-Host "New owner '$Add' added to ServicePrincipal"
        }
    }
}#if ($Add -ne $null) 

Write-Host -ForegroundColor Magenta "[250]`n `$CurrUserPrincipalName=`"$CurrUserPrincipalName`""
if ($Remove -ne $null) 
{
    
    if ($Add -ne $Remove) {
        $UserObjectId = ResolveUserObjectId $Remove $TenantId $Headers
    }

    # Remove owner from Application
    if ($App -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Delete `
                    -Uri "https://graph.windows.net/$TenantId/applications/$($App.objectId)/`$links/owners/$UserObjectId`?api-version=1.6"
        if ($Result.StatusCode -eq 204) {    
            Write-Host "Owner '$Remove' removed from Application"
        }
    }

    # Remove owner from ServicePrincipal
    if ($SP -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Delete `
                    -Uri "https://graph.windows.net/$TenantId/servicePrincipals/$($SP.objectId)/`$links/owners/$UserObjectId`?api-version=1.6"
        if ($Result.StatusCode -eq 204) {    
            Write-Host "Owner '$Remove' removed from ServicePrincipal"
        }
    }
}#if ($Remove -ne $null) 

Write-Host -ForegroundColor Magenta "[277]`n `$CurrUserPrincipalName=`"$CurrUserPrincipalName`""
if ($List) 
{
    if ($Application -and $App -ne $null -and $ServicePrincipal -and $SP -ne $null) {
        Write-Warning "Listing owners of both Application and ServicePrincipal objects may result in duplicates"
    }
    if ($Application -and $App -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri "https://graph.windows.net/$TenantId/applications/$($App.objectId)/owners?api-version=1.6"
        ($Result.Content | ConvertFrom-Json).value
    }
    if ($ServicePrincipal -and $SP -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri "https://graph.windows.net/$TenantId/servicePrincipals/$($SP.objectId)/owners?api-version=1.6"
        ($Result.Content | ConvertFrom-Json).value
    }
}#if ($List) 

