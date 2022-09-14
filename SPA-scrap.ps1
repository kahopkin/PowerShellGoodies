
$Subject = @(‘History’,’Geo’,’Maths’)
#$redirectUris = @('https://$AppName.azurewebsites.us')

$redirectUris = @()
$WebAppUrl = "https://$AppName.azurewebsites.us"
if ($redirectUris -notcontains "$WebAppUrl") {
    $redirectUris += "$WebAppUrl"   
    Write-Host "SetRedirectURI[21] Adding $WebAppUrl to redirect URIs";
}

$body = @{
    'spa' = @{
        'redirectUris' = $redirectUris
    }
} 
 Write-Host $body.spa.redirectUris     
        
#$bodyJson = ConvertTo-Json $body

#$redirectUris = @('https://$AppName.azurewebsites.us')

'spa' = @{
        'redirectUris' = $redirectUris
    }


$mySpaApplication = {"spa":{"redirectUris":["'$redirectUri'"]}}

$AdApplication = New-AzADApplication `
                -DisplayName 'SPAtest' `
                -SigninAudience "AzureADMyOrg" `
                -SPARedirectUri $mySpaApplication 


$AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]             
            $newAppRole = CreateAppRole `
                -AllowedMemberTypes "User" `
                -Description "Admin users of the DTP API" `
                -DisplayName  "DTP API Admins" `
                -Value "DTPAPI.Admins"                 
    
            $AppRoles += $newAppRole               


$spa = New-Object Microsoft.
 IMicrosoftGraphSpaApplication

$redirectUris = @("https://$AppName.azurewebsites.us")
$WebAppUrl = "https://$AppName.azurewebsites.us"

$redirectUris = @("https://$AppName.azurewebsites.us")
$mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
$redirectUris = New-Object System.Collections.Generic.List[string]
$redirectUris.Add($redirectUris)
$mySpaApplication.RedirectUris = 

$AppRole = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole
        $AppRole.AllowedMemberTypes = New-Object System.Collections.Generic.List[string]

 New-Object -TypeName System.Diagnostics.EventLog -ArgumentList Application

 Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10
 Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication

 $AppRole.AllowedMemberTypes = @($AllowedMemberTypes)

$redirectUriList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication]         