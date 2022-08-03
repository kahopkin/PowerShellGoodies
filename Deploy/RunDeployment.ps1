#RunDeployment
<#
This script creates and configures two app registrations and
then it start a Bicep script that deploys the Data Transfer Portal application.
It writes an Output.txt file and saves it in the same directory where the deploy script is located.
The file contains the app registration data: ids, secret, tenantid, subscriptionid, etc.
This is a plain text file for the person who runs the deployment.
The resources the script creates are:
Resource Group
Function App
App Service
App Service Plan
Storage Account
Log Analytics Workspace
Application Insigths for the API
Application Insigths for the Web Client
#>


<#
Checks to see if the resourceGroup by that name exists, if not, creates it
#>
Function CreateResourceGroup
{
    Param(
        [Parameter(Mandatory = $true)] [String]$ResGroupName
        , [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location
    )

    Write-Host -ForegroundColor Magenta -BackgroundColor DarkBlue  "CreateResourceGroup************* Enter CreateResourceGroup Function *****************"
    $ResGroupName = $ResGroupName + "ResGoup" + (Get-Culture).TextInfo.ToTitleCase($Environment)
    #Write-Host -ForegroundColor Cyan  -BackgroundColor DarkBlue "[15] ResGroupName: " $ResGroupName

    $myResourceGroup = Get-AzResourceGroup -Name $ResGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent)
    {
        # ResourceGroup doesn't exist
        $myResourceGroup = New-AzResourceGroup -Name $ResGroupName -Location $Location
        Write-Host  -BackgroundColor DarkBlue "CreateResourceGroup[20] New ResourceGroup: " + $myResourceGroup
        $ResourceId = $myResourceGroup.ResourceId
    }
    else
    {
        $myResourceGroup = Get-AzResourceGroup -Name $ResGroupName
        # ResourceGroup exist: get its resourceID
        $ResourceId = $myResourceGroup.ResourceId
    }
    Write-Host -ForegroundColor Green  -BackgroundColor DarkBlue "CreateResourceGroup[28] ResourceId: $ResourceId"
    Write-Host -ForegroundColor Magenta  -BackgroundColor DarkBlue "CreateResourceGroup************* EXITING CreateResourceGroup Function *****************"

    "Resource Group Name: " + $ResGroupName >> $OutFile
    "Resource Group's ResourceId: " + $ResourceId >> $OutFile

    return $ResourceId
}#CreateResourceGroup


Function CreateAppRegistration
{
    Param([Parameter(Mandatory = $true)] [String]$AppRegName)

    $object= @{}
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "CreateAppRegistration************* Enter CreateAppRegistration Function FOR $AppRegName *****************"
    $ServicePrincipal = Get-AzADServicePrincipal -DisplayName $AppRegName
    Write-Host  -ForegroundColor Green  -BackgroundColor Black "CreateAppRegistration[40] ServicePrincipal.AppDisplayName.Length" $ServicePrincipal.AppDisplayName.Length

    #create a new Azure Active Directory
    if (($ServicePrincipal.AppDisplayName.Length).Equals(0))
    {
        #depending on the name, the app registrations need different configurations.
        #API app registration
        if ($AppRegName -match 'api')
        {
            #create a new Azure Active Directory
            $aadApplication = New-AzADApplication `
                -DisplayName $AppRegName `
                -SigninAudience 'AzureADMyOrg'

            #create a client secret key which will expire in two years.
            $appId = $aadApplication.AppId
            $appObjectId = $aadApplication.Id
            Write-Host "CreateAppRegistration[58] API.AppId:" $appId
            Write-Host "CreateAppRegistration[59] API.appObjectId:" $appObjectId

            $appPassword = New-AzADAppCredential -ObjectId $appObjectId -EndDate (Get-Date).AddYears(2)
            #$appPassword.Value
            $plaintextSecretTest = $appPassword.SecretText
            write-host -ForegroundColor Cyan -BackgroundColor Black  "CreateAppRegistration[63] secret: $plaintextSecretTest"
            $object = @{
                Tenant = $Tenant
                TenantId = $TenantId
                SubscriptionId = $SubscriptionId
                ClientId = $appId
                ClientSecret = $plaintextSecretTest
            }
            $appIDUri = "api://" + $appId

            $identifierUris = @()
            $identifierUris += "api://$appId"
            $webAppUrl = "https://$AppRegName.azurewebsites.net"
            # when you add a redirect URI Azure creates a "web" policy.
            $redirectUris = @()
            $redirectUris += "$webAppUrl"

            #Update-AzADApplication -ApplicationId $newapp.AppId -ReplyUrl $redirectUris | Out-Null
            Update-AzADApplication -ApplicationId $appId -IdentifierUris $appIDUri
            Write-Host "CreateAppRegistration[86] Updated API URI:"  $appIDUri

            $currentUser = Get-AzADUser -SignedIn
            Write-Host "CreateAppRegistration[89] Current User:" $currentUser.DisplayName

            "API App Registration Name:	" +	$AppRegName  >> $OutFile
            "API App Registration ID:	" + $appId  >> $OutFile
            "API App Registration Secret:	" + $plaintextSecretTest  >> $OutFile
        }
        else
        {
            #WebClient registration
			$redirectUri = "https://" + $AppRegName + ".azurewebsites.us"
			Write-Host -f Green "CreateAppRegistration[100] redirecturi:"  $redirectUri

            $aadApplication = New-AzADApplication `
                -DisplayName $AppRegName `
                -SigninAudience 'AzureADMyOrg' `
                -ReplyUrls $redirectUri

            $appId = $aadApplication.AppId
            $appObjectId = $aadApplication.Id
			Write-Host "CreateAppRegistration[104] WebClient.AppId:" $appId
            Write-Host "CreateAppRegistration[105] WebClient.appObjectId:" $appObjectId
            $object = @{
                Tenant = $Tenant
                TenantId = $TenantId
                SubscriptionId = $SubscriptionId
                ClientId = $appId
            }
            Write-Host -ForegroundColor Green  -BackgroundColor Black "[113] WebClient: " $aadApplication.DisplayName
            Write-Host -ForegroundColor Green  -BackgroundColor Black "[114] WebClient.redirectUri: " $redirectUri
        }
    }
    else
	{
        Write-Host -ForegroundColor Red  -BackgroundColor Black "[123] existing app registration: $ServicePrincipal.DisplayName"
        Write-Host -ForegroundColor Red  -BackgroundColor Black "[123] existing app registration: $ServicePrincipal.AppId"

        $object = @{
            Tenant = $Tenant
            TenantId = $TenantId
            SubscriptionId = $SubscriptionId
            ClientId = $ServicePrincipal.AppId
        }
    }

    #$ServicePrincipal = New-AzADServicePrincipal -ApplicationId $appId
    #Write-Host "[120] ServicePrincipal:" $ServicePrincipal.DisplayName

    $json = ConvertTo-Json $object
    #DEBUG
    $clientObj = ConvertFrom-Json $json
    "WebSite App Registration Name:	" +	$AppRegName  >> $OutFile
    "WebSite App Registration ID:	" + $clientObj[0].clientId  >> $OutFile

	Write-Host -ForegroundColor Green "CreateAppRegistration[143] WebSite App Registration Name:" $AppRegName
    Write-Host -ForegroundColor Green "CreateAppRegistration[144] WebSite App Registration ID:" $clientObj[0].clientId

    #"WebSite App Registration Secret:	" + $clientObj[0].clientSecret  >> $OutFile
    if ($clientObj[0].clientSecret.Length -gt 0)
    {
        #$AppRegName + " Secret	" + $clientObj[0].clientSecret  >> $OutFile
        Write-Host -ForegroundColor Green "CreateAppRegistration[150] API App Registration clientSecret:" $clientObj[0].clientSecret
    }
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "CreateAppRegistration************* EXITING CreateAppRegistration Function for $AppRegName *****************"
    return $json
} #end of func CreateAppRegistration

<#
#>
Function StartBicepDeploy {
    Param(
        [Parameter(Mandatory = $true)] [String]$AppRegName
        , [Parameter(Mandatory = $true)] [String]$ResGroupName
        , [Parameter(Mandatory = $true)] [String]$ResourceId
        , [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location
        , [Parameter(Mandatory = $true)] [String]$SiteName
        , [Parameter(Mandatory = $true)] [object]$ApiAppRegJson
        , [Parameter(Mandatory = $true)] [object]$ClientAppRegJson
    )
    Write-Host -ForegroundColor Magenta -BackgroundColor Black "StartBicepDeploy************* Enter StartBicepDeploy Function *****************"
    $templateFile = 'main.bicep'
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    $DeploymentName = "Deployment_" + $today
    $ResGroupName = $ResGroupName + "ResGoup" + (Get-Culture).TextInfo.ToTitleCase($Environment)

    "DeploymentName: " + $DeploymentName >> $OutFile

    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[126] Subscription:  $subscriptionName"
    <#
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[171] Location:  $location"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[172] ResGroupName: $ResGroupName"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[173] ResourceId: $ResourceId"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[174] EnvType:  $Environment"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[175] SiteName:  $SiteName"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[176] DeploymentName:  $DeploymentName"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[177] ResourceId:  $ResourceId"
	#>
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[186] ApiAppRegJson:"  $ApiAppRegJson
    Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[187] ClientAppRegJson:"  $ClientAppRegJson

    $apiClientObj = ConvertFrom-Json $ApiAppRegJson
    $ApiClientId = $apiClientObj[0].ClientId

    $webClientObj = ConvertFrom-Json $ClientAppRegJson
    $WebClientId = $webClientObj[0].ClientId

    if ($apiClientObj[0].clientSecret.Length -gt 0)
    {
        $ApiClientSecret = $apiClientObj[0].ClientSecret
        $SecureApiClientSecret = ConvertTo-SecureString $ApiClientSecret -AsPlainText -Force
        Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[202] ApiClientSecret:" $ApiClientSecret
        Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[203] SecureApiClientSecret:" $SecureApiClientSecret
    }

    Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[206] ApiClientId:" $ApiClientId
    Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[207] WebClientId:" $WebClientId
    $SecureApiClientId = ConvertTo-SecureString $ApiClientId -AsPlainText -Force
    $SecureWebClientId = ConvertTo-SecureString $WebClientId -AsPlainText -Force
    Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[210] ApiClientSecret:" $ApiClientSecret
    Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[211] **** STARTING AzSubscriptionDeployment *****"

    New-AzSubscriptionDeployment `
        -Name $DeploymentName `
        -Location $Location `
        -TemplateFile $templateFile `
        -ResGroupName $ResGroupName `
        -EnvironmentType $Environment `
        -SiteName $SiteName `
        -ApiClientId $SecureApiClientId `
        -ApiClientSecret $SecureApiClientSecret `
        -WebClientId $SecureWebClientId

    Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[216] **** FINISHED AzSubscriptionDeployment *****"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "StartBicepDeploy************* EXITING StartBicepDeploy Function *****************"
    #"FINISH	StartBicepDeploy" >> $OutFile

}#end of StartBicepDeploy


Function RunDeployment {
    Param(
          [Parameter(Mandatory = $true)] [String]$ApiAppRegName
        , [Parameter(Mandatory = $true)] [String]$ClientAppRegName
        , [Parameter(Mandatory = $true)] [String]$ResGroupName
        , [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location
        , [Parameter(Mandatory = $true)] [String]$SiteName
    )

    $subscription = Get-AzSubscription
    $global:SubscriptionName = $subscription.Name
    $global:SubscriptionId = $subscription.Id

    $azureContext = Get-AzContext
    $global:Tenant = (Get-AzTenant).Name
    $global:TenantId = (Get-AzTenant).Id

    #"START	RunDeployment" >> $OutFile
    #"ApiAppRegName	$ApiAppRegName" >> $OutFile
    #"ClientAppRegName	$ClientAppRegName"  >> $OutFile
    #"ResGroupName	$ResGroupName"  >> $OutFile
    "Tenant:	" + $Tenant  >> $OutFile
    "TenantId:	" + $TenantId  >> $OutFile
    "SubscriptionName:	" + $SubscriptionName  >> $OutFile
    "SubscriptionId:	" + $SubscriptionId  >> $OutFile
    "Environment:	$Environment"  >> $OutFile
    "SiteName:	$SiteName"  >> $OutFile
    "Location:	$Location"  >> $OutFile

    $ResourceId = CreateResourceGroup $ResGroupName $Environment $Location
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[257] CreateResourceGroup.ResourceId: " $ResourceId

    if ($ApiAppRegName -notcontains 'api') {
        $ApiAppRegName = $ApiAppRegName + 'api'
        Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[262] ApiAppRegName: $ApiAppRegName"
    }
    #Write-Host -ForegroundColor Green  -BackgroundColor DarkGray "[47] azureContext.Account: " $azureContext.Account
    Write-Host -ForegroundColor Magenta -BackgroundColor DarkBlue  "************* Enter RunDeployment Function *****************"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "RunDeployment[266] ApiAppRegName: $ApiAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[267] ClientAppRegName: $ClientAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[268] ResGroupName: $ResGroupName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[269] Environment: $Environment"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[270] SiteName: $SiteName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[271] Location: $Location"

    #Create API App Registration
    $ApiAppRegJson = CreateAppRegistration $ApiAppRegName
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[275] ApiAppRegName: $ApiAppRegName Created"
    Write-Host -ForegroundColor Cyan $ApiAppRegJson
    #"ApiAppRegName:	" +	$ApiAppRegName  >> $OutFile

    #Create webAPI app Registration
    $clientAppRegJson = CreateAppRegistration $ClientAppRegName
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[281] ClientAppRegName:  $ClientAppRegName Created"
    #"ClientAppRegName:	" +	$ClientAppRegName  >> $OutFile
    Write-Host -ForegroundColor Cyan $clientAppRegJson

    #Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "[209] *********** STARTING StartBicepDeploy **********"
    StartBicepDeploy $ApiAppRegName $ResGroupName $ResourceId $Environment $Location $SiteName $ApiAppRegJson $clientAppRegJson

    Write-Host -ForegroundColor Magenta -BackgroundColor DarkBlue  "RunDeployment************* EXITING RunDeployment Function *****************"
    Write-Host -ForegroundColor Magenta -BackgroundColor DarkBlue  "RunDeployment************* DEPLOYMENT COMPLETED, PLEASE SEE APP REGISTRATION INFO IN OUTPUT FILE: $OutFile*****************"
    #"FINISH RunDeployment" >> $OutFile

}#RunDeployment

#ScriptVariables
<#
$ApiAppRegName = "APIAPPREGNAME"
$ClientAppRegName= "CLIENTAPPNAME"
$ResGroupName= "RESOURCEGROUPBASENAME"
$Environment = "ENVIRONMENT"
$SiteName = "WEBSITENAME"
$Location = "'LOCATION"
#>
# Refer to Possible LOCATION values in the instructions.
$Location = "usgovvirginia"

$today = Get-Date -Format 'MM-dd-yyyy-HH-mm'
$OutFile = "OutputFile_" + $today + ".txt"

RunDeployment `
    -ApiAppRegName $ApiAppRegName `
    -ClientAppRegName $ClientAppRegName `
    -ResGroupName $ResGroupName `
    -Environment $Environment `
    -Location $Location `
    -SiteName $SiteName

