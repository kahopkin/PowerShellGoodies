$red = New-Object System.Management.Automation.Host.ChoiceDescription '&Red', 'Favorite color: Red'
$blue = New-Object System.Management.Automation.Host.ChoiceDescription '&Blue', 'Favorite color: Blue'
$yellow = New-Object System.Management.Automation.Host.ChoiceDescription '&Yellow', 'Favorite color: Yellow'

#Once we've defined all the options, we'll group them all into an array.

$options = [System.Management.Automation.Host.ChoiceDescription[]]($red, $blue, $yellow)

$title = 'Favorite color'
$message = 'What is your favorite color?'
$result = $host.ui.PromptForChoice($title, $message, $options, 0)


switch ($result)
{
    0 { 'Your favorite color is Red' }
    1 { 'Your favorite color is Blue' }
    2 { 'Your favorite color is Yellow' }
}


Get-MgEnvironment

Name     AzureADEndpoint                   GraphEndpoint                       
----     ---------------                   -------------                       
USGovDoD https://login.microsoftonline.us  https://dod-graph.microsoft.us      
Germany  https://login.microsoftonline.de  https://graph.microsoft.de          
USGov    https://login.microsoftonline.us  https://graph.microsoft.us          
China    https://login.chinacloudapi.cn    https://microsoftgraph.chinacloud...
Global   https://login.microsoftonline.com https://graph.microsoft.com 