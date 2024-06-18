param (
    [Parameter(Mandatory=$true)]
    [string]$SolutionName,

    [Parameter(Mandatory=$true)]
    [string]$SubscriptionName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [ValidateSet('dev', 'test', 'prod', 'GOV', 'EX', 'RX')]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 255)]
    [int]
    $HubIpOctet = 1,

    [Parameter(Mandatory = $true)]
    [switch]
    $OverwriteExistingFile
)

# Import DTS Utility Module
Import-Module $(Join-Path $PSScriptRoot "\utilities\dts.psm1") -Force

# Set the subscription
Set-AzContext -SubscriptionName $subscriptionName

New-DeploymentConfig -SolutionName $SolutionName `
    -SubscriptionName $SubscriptionName `
    -Location $Location `
    -Environment $Environment `
    -HubIpOctet $HubIpOctet `
    -OverwriteExistingFile

$config = Get-DeploymentConfig
 
# Retreive / Generate Secure Random Passwords
$secretNames = @('sqlAdminPassword', 'vmAdminPassword')
$secretValues = @{} 

foreach ($secretName in $secretNames) {
    $keyVaultName = $config.keyVaults[0].name
    
    if ($secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -ErrorAction SilentlyContinue) {
        $secretValue = $secret.SecretValue
    } else {
        $secretValue = New-SecurePassword -Length 16
    }
    
    # Store the secret value in the hashtable
    $secretValues[$secretName] = $secretValue
}

$vmAdminPassword = $secretValues['vmAdminPassword']
$sqlAdminPassword = $secretValues['sqlAdminPassword']

#Tags
$tags = New-Tags -Environment $Environment

# Function to validate and deploy Bicep
Start-Deployment -sqlAdminPassword $sqlAdminPassword -vmAdminPassword $vmAdminPassword -Tags $tags
