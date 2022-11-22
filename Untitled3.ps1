
try 
{ 
    $var = Get-AzureADTenantDetail 
} 
catch
{ 
    
    Write-Host "You're not connected.";
    Connect-AzAccount -Environment AzureUSGovernment
}




<#
try{
Get-AzADUser -SignedIn
}
catch
{

}
$Error.Exception.GetType().FullName
#>

Get-AzADApplication -First 1 | convertto-json -Depth 30
$AdApplication = Get-AzADApplication -DisplayName depguide | convertto-json -Depth 30 > depguideOut.txt