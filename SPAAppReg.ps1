Connect-MgGraph -Environment USGov # -Scopes "Directory.AccessAsUser.All, Application.ReadWrite.All, User.Read" -ErrorAction Stop

$AppName ='mySpaApp'


$WebAppUrl = "https://$AppName.azurewebsites.us"

if ($redirectUris -notcontains "$WebAppUrl") {
    $redirectUris += "$WebAppUrl"   
    Write-Host "SetRedirectURI[21] Adding $WebAppUrl to redirect URIs";
}
$mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
$mySpaApplication.RedirectUris=$redirectUris

<#
$AdApplication = New-AzADApplication `
                -DisplayName $AppName `
                -SigninAudience "AzureADMyOrg" `
                -SPARedirectUri $mySpaApplication.RedirectUris
#>

$AdApplication = New-MgApplication `
                    -DisplayName 'MGapp' `
                    -SignInAudience AzureADMyOrg `
                    -SPA $mySpaApplication


                    
$mySpaApplication.RedirectUris
$AdApplication.Spa

