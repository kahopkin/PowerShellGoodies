<#
3-GetUser.ps1
https://learn.microsoft.com/en-us/graph/tutorials/powershell?tabs=powershell&tutorial-step=3
#>

$context = Get-MgContext
# Get the authenticated user by UPN
#You can add the -Debug switch to the previous command to see the API request and response.
$user = Get-MgUser -UserId $context.Account -Select 'displayName, id, mail, userPrincipalName'

Write-Host "Hello," $user.DisplayName
# For Work/school accounts, email is in Mail property
# Personal accounts, email is in UserPrincipalName
Write-Host "Email:", ($user.Mail ?? $user.UserPrincipalName)