#https://dotnet-helpers.com/powershell/how-to-check-response-code-from-a-website/

#[string] #$_URL = 'https://dotnet-helpers.com'
function CheckSiteURLStatus($_URL) 
{
    try 
    {
    $request= [System.Net.WebRequest]::Create($_URL)
    $response = $request.getResponse()
        if ($response.StatusCode -eq "200") {
            write-host "`nSite - $_URL is up (Return code: $($response.StatusCode) - 
        $([int] $response.StatusCode)) `n" -ForegroundColor green 
        }
        else 
        {
            write-host "`n Site - $_URL is down `n" ` -ForegroundColor red
        }
    } 
    catch 
    {
        write-host "`n Site is not accessable, May DNS issue. Try again.`n" ` -ForegroundColor red
    }
}
 
 Get-AzResource -ResourceType Microsoft.Web/sites | Select Name
$_URL = 'https://datatransfer.azurewebsites.us'
$_URL = 'https://kat.azurewebsites.us'
CheckSiteURLStatus $_URL




# First we create the request.
$HTTP_Request = [System.Net.WebRequest]::Create($_URL)

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.GetResponse()

# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {
    Write-Host "Site is OK!"
}
Else {
    Write-Host "The Site may be down, please check!"
}

# Finally, we clean up the http request by closing it.
If ($HTTP_Response -eq $null) { } 
Else { $HTTP_Response.Close() }