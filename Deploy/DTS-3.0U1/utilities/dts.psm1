Function New-DeploymentConfig {
    <#>
    .SYNOPSIS
        Builds a json deployment config that will be used for the infrastructure deployment and aks configuration build.
    .DESCRIPTION
        Builds a json deployment config that will be used for the infrastructure deployment and aks configuration build.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 13)]
        [string]
        $SolutionName,
        
        [Parameter(Mandatory = $true)]
        [string]
        $Location,
        
        [Parameter(Mandatory = $true)]
        [string]
        $SubscriptionName,

        [Parameter(Mandatory = $true)]
        [string]
        $Environment,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 255)]
        [int]
        $HubIpOctet,

        [switch] $OverwriteExistingFile
    )

    $outputConfigFile = Join-Path $PSScriptRoot "\..\deployment-config.json"
    if ((Test-Path -Path $outputConfigFile) -and (-not $OverwriteExistingFile)) {
        Write-Host "The network deployment configuration file already exists.  Use the -OverwriteExistingFile switch." -ForegroundColor Red
        return
    }
    $sourceTemplate = $(Join-Path $PSScriptRoot "deployment-template.json")
    if (Test-Path $sourceTemplate) {
        Write-Host "Using the source configuration template file: " -ForegroundColor DarkCyan -NoNewline
        Write-Host $sourceTemplate
        Write-Host
        $templateRows = Get-Content -Path $sourceTemplate
    }
    else {
        $PSCmdlet.WriteError(
            [System.Management.Automation.ErrorRecord]::new(
                [Exception]::new("Source configuration template not found!"), 'ERROR_FILE_NOT_FOUND',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound, $null)
        )
        return
    }

    if ($Environment -eq 'GOV') {
        $Suffix = 'usgovcloudapi.net'
    }

    $templateRows = $templateRows | ForEach-Object {
        $t = $_
        $t = $t.replace("[-LOCATION-]", $Location)
        $t = $t.replace("[-SUBSCRIPTIONNAME-]", $SubscriptionName)
        $t = $t.replace("[-SOLUTIONNAME-]", $SolutionName)
        $t = $t.replace("[-HUB-IP-OCTET-]", $HubIpOctet)
        $t = $t.replace("[-SUFFIX-]", $Suffix)

        Write-Output $t
        $line++
    }

    $templateRows | Out-File $outputConfigFile -Encoding ascii -Force

    return ($(Resolve-Path ($outputConfigFile)).Path)
}

Function Get-DeploymentConfig {
    <#>
    .SYNOPSIS
        Reads json configuraton file and returns it is an object.
    .DESCRIPTION
        Reads json configuraton file and returns it is an object.
    #>
    [CmdletBinding()]
    param (
        [string] $ConfigFilePath = (Join-Path $PSScriptRoot "\..\deployment-config.json")
    )

    if (Test-Path $ConfigFilePath) {
        $ConfigFilePath = Resolve-Path $ConfigFilePath
        if (-not $SuppressMessageOutput) {
            Write-Host "Using the deployment configuration file: " -ForegroundColor Cyan -NoNewline
            Write-Host $ConfigFilePath
        }

        $configContent = Get-Content -Path $ConfigFilePath
        $isEmpty = ($null -eq $configContent)
        if (-not $isEmpty) {
            $configObject = $configContent | ConvertFrom-Json
            return $configObject
        }
        else {
            if (-not $SuppressMessageOutput) {
                Write-Host "This $ConfigFilePath is empty. Please create a new deployment configuration and try again" -ForegroundColor Yellow
            }
            return
        }
    }
    else {
        if (-not $SuppressMessageOutput) {
            $PSCmdlet.WriteError(
                [System.Management.Automation.ErrorRecord]::new(
                    [Exception]::new("Deployment configuration file not found!"), 'ERROR_FILE_NOT_FOUND',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound, $null)
            )
        }
        return
    }
}

Function New-SecurePassword {
    <#
    .SYNOPSIS
        Generate a random SecureString password.
    .DESCRIPTION
        Generate a random SecureString password.
    #>
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param (
        # The length of the password which should be created.
        [Parameter(ValueFromPipeline)]        
        [ValidateRange(8, 255)]
        [Int32]$Length,

        # The character sets the password may contain. A password will contain at least one of each of the characters.
        [String[]]$CharacterSet = ('abcdefghijklmnopqrstuvwxyz',
                                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                   '0123456789',
                                   '!$%&^.#;'),

        # The number of characters to select from each character set.
        [Int32[]]$CharacterSetCount = (@(1) * $CharacterSet.Count)
    )

    begin {
        $bytes = [Byte[]]::new(4)
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($bytes)

        $seed = [System.BitConverter]::ToInt32($bytes, 0)
        $rnd = [Random]::new($seed)

        if ($CharacterSet.Count -ne $CharacterSetCount.Count) {
            throw "The number of items in -CharacterSet needs to match the number of items in -CharacterSetCount"
        }

        $allCharacterSets = [String]::Concat($CharacterSet)
    }

    process {
        try {
            $requiredCharLength = 0
            foreach ($i in $CharacterSetCount) {
                $requiredCharLength += $i
            }

            if ($requiredCharLength -gt $Length) {
                throw "The sum of characters specified by CharacterSetCount is higher than the desired password length"
            }

            $password = [Char[]]::new($Length)
            $index = 0
        
            for ($i = 0; $i -lt $CharacterSet.Count; $i++) {
                for ($j = 0; $j -lt $CharacterSetCount[$i]; $j++) {
                    $password[$index++] = $CharacterSet[$i][$rnd.Next($CharacterSet[$i].Length)]
                }
            }

            for ($i = $index; $i -lt $Length; $i++) {
                $password[$index++] = $allCharacterSets[$rnd.Next($allCharacterSets.Length)]
            }

            # Fisher-Yates shuffle
            for ($i = $Length; $i -gt 0; $i--) {
                $n = $i - 1
                $m = $rnd.Next($i)
                $j = $password[$m]
                $password[$m] = $password[$n]
                $password[$n] = $j
            }

            # Convert the char array to a string
            $plainPassword = [String]::new($password)

            # Convert the string to a SecureString
            $securePassword = ConvertTo-SecureString -String $plainPassword -AsPlainText -Force

            return $securePassword

        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}

Function New-Tags {
        <#
    .SYNOPSIS
        Generate tags for Az resource deployment.
    .DESCRIPTION
        Generate tags for Az resource deployment.
    #>
    param (
        $Environment
    )
    $config = Get-DeploymentConfig

    $tags = @{
        Environment = $Environment
        DeployDate = (Get-Date).tostring("MM/dd/yyyy HH:mm")
        DeployedBy = (Get-AzContext).Account.Id
        SolutionVersion = $config.solutionVersion
        Owner = $config.solutionOwner
    }
    return $tags
}

function Start-Deployment {
    [CmdletBinding()]
    param (
        $bicepFilePath = (Join-Path $PSScriptRoot "\..\bicep\main.bicep"),

        [Parameter(Mandatory = $true)]
        [securestring]
        $sqlAdminPassword,

        [Parameter(Mandatory = $true)]
        [securestring]
        $vmAdminPassword,

        [Parameter(Mandatory = $true)]
        [object]
        $Tags
    )

    $config = Get-DeploymentConfig

    # Check if the resource group exists
    $resourceGroup = Get-AzResourceGroup -Name $config.resourceGroupName -ErrorAction SilentlyContinue
    
    if ($null -eq $resourceGroup) {
        # Create Resource Group
        New-AzResourceGroup -Name $config.resourceGroupName -Location $config.location

        $preFlightFilePath = (Join-Path $PSScriptRoot "\..\bicep\preFlight.bicep")

        New-AzResourceGroupDeployment -Name $config.SolutionName `
            -ResourceGroupName $config.resourceGroupName `
            -TemplateFile $preFlightFilePath `
            -Tags $Tags
    }
    
    # Deploy Main Bicep file
    $bicepFilePath = (Join-Path $PSScriptRoot "\..\bicep\main.bicep")
    New-AzResourceGroupDeployment -Name $config.SolutionName `
        -ResourceGroupName $config.resourceGroupName `
        -TemplateFile $bicepFilePath `
        -sqlAdminPassword $sqlAdminPassword `
        -vmAdminPassword $vmAdminPassword `
        -Tags $Tags `
        -WarningAction SilentlyContinue
}
