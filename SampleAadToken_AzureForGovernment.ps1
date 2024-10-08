﻿<#
# Created by Steve Winward
# https://github.com/SteveWinward/Azure-Samples/blob/master/AAD/SampleAadToken_AzureForGovernment.ps1
# 
# This script is a sample to show how you can work with the Azure for Governemnt
# Graph API endpoint
#
# This requries you to create an AAD Application ahead of time.  You will also need
# to create a client secret for the AAD applciation and then also setup the API Permissions.
# 
# More details can be found below on this,
# https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/add-application-portal
#>

$TenantName     = "<INSERT_ACTUAL_TENANT_GUID>"
$ClientID       = "<INSERT_ACTUAL_CLIENT_ID>" #This is the Applicaiton ID of the AAD App
$ClientSecret   = "<INSERT_ACTUAL_CLIENT_SECRET>" #This is the client secret you create for the AAD App 

# This is the Azure for Government login URL
$LoginUrl       = "https://login.microsoftonline.us"

# This is the Graph API endpoint for Azure for Government
$Resource       = "https://graph.microsoft.us" 

# Constructs an HTTP POST request to get an OAuth token from AAD
$body = 
@{
    grant_type="client_credentials";
    resource=$Resource;
    client_id=$ClientID;
    client_secret=$ClientSecret
}

$oauth = Invoke-RestMethod -Method POST -Uri $LoginUrl/$TenantName/oauth2/token?api-version=1.0 -Body $body 

# Outputs the JWT token for debugging
Write-Output "JWT Token =>"
$oauth.access_token
Write-Output ""

# Get the middle part of the JWT token
$middleToken = $oauth.access_token.Split(".")[1]

# padd the base64 with "=" if the length is not divisible by 4
$remainder = 4 - ($middleToken.Length % 4)

for($i=0; $i -lt $remainder; $i++){
    $middleToken = "" + $middleToken + "="
}

# Parses the JWT token for the role assignments to the AAD Application
$payload = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($middleToken))
Write-Output "Token Roles =>"
($payload | ConvertFrom-Json).roles
Write-Output ""

# Sample call to list all users in the tenant
# This requires application permissions to the User.ReadBasic.All (Graph API)
$graphOperationUrl = "https://graph.microsoft.us/v1.0/users"
$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
$response = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $graphOperationUrl -Method GET) 

# Outputs the Graph API response for debugging
Write-Output "HTTP Response =>"
$response