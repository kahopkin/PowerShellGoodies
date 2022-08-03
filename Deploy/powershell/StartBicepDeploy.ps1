
<#
StartBicepDeploy
 # , [Parameter(Mandatory = $true)] [String]$ResourceId
#>
Function global:StartBicepDeploy {
    Param(
          [Parameter(Mandatory = $true)] [String]$ResGroupName
        , [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location        
        , [Parameter(Mandatory = $true)] [String]$AppName
        , [Parameter(Mandatory = $true)] $AppRegObj
    )
   
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] START StartBicepDeploy *****************"
    $Caller = 'StartBicepDeploy'
    PrintObject -object $AppRegObj -Caller $Caller

    $templateFile = '..\main.bicep'
    <#
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    $DeploymentName = "Deployment_" + $today

    "DeploymentName: " + $DeploymentName >> $OutFile
    #>
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[27] debugFlag:  $debugFlag"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] Subscription:  $subscriptionName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] ResGroupName: $ResGroupName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] ResourceId: $ResourceId"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] EnvType:  $Environment"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] Location:  $location"    
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] AppName:  $AppName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] DeploymentName:  $DeploymentName"
    
    #$apiClientObj = ConvertFrom-Json $ApiAppRegJson
    $ApiClientId = $AppRegObj.ApiClientId
    Write-Host -ForegroundColor Cyan "StartBicepDeploy[39] ApiClientId:"  $ApiClientId

   # $webClientObj = ConvertFrom-Json $ClientAppRegJson
    $WebClientId = $AppRegObj.WebClientId
    Write-Host -ForegroundColor Cyan "StartBicepDeploy[43] WebClientId:"  $WebClientId

    
    $SecureApiClientId = ConvertTo-SecureString $ApiClientId -AsPlainText -Force

    if ($AppRegObj.ApiClientSecret.Length -gt 0)
    {
        $ApiClientSecret = $AppRegObj.ApiClientSecret
        $SecureApiClientSecret = ConvertTo-SecureString $ApiClientSecret -AsPlainText -Force
        #   Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[202] ApiClientSecret:" $ApiClientSecret
        #  Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[203] SecureApiClientSecret:" $SecureApiClientSecret            
    }

    $CurrUser = Get-AzADUser -SignedIn
    $CurrUserName = $CurrUser.DisplayName

    if($debugFlag)
    {
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black  "StartBicepDeploy[66] debugFlag:  $debugFlag"
        Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[76] BICEP Command: "
        #Write-Host -ForegroundColor Cyan 
        #"New-AzSubscriptionDeployment -Name $DeploymentName -Location $Location -TemplateFile $templateFile -ResourceGroupName $ResGroupName -EnvironmentType $Environment -SiteName $SiteName -AppName $AppName -TemplateParameterFile $TemplateParameterFile"

        "`nNew-AzSubscriptionDeployment ```
        -Name $DeploymentName ```
        -Location $Location ```
        -TemplateFile $templateFile ```
        -EnvironmentType $Environment ```
        -ResourceGroupName $ResGroupName ```
        -CurrUser $CurrUserName ```
        -SiteName $SiteName ```
        -AppName $AppName ```
        -ApiClientId $ApiClientId ```
        -ApiClientSecret $ApiClientSecret ```
        -TemplateParameterFile $TemplateParameterFile" >> $OutFile

        Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
        -Name $DeploymentName ```
        -Location $Location ```
        -TemplateFile $templateFile ```
        -EnvironmentType $Environment ```
        -ResourceGroupName $ResGroupName ```
        -CurrUser $CurrUserName ```
        -SiteName $SiteName ```
        -AppName $AppName ```
        -ApiClientId $ApiClientId ```
        -ApiClientSecret $ApiClientSecret ```
        -TemplateParameterFile $TemplateParameterFile"

        try{
        New-AzSubscriptionDeployment `
            -Name $DeploymentName `
            -Location $Location.toLower() `
            -TemplateFile $templateFile `
            -EnvironmentType $Environment.toLower() `
            -ResourceGroupName $ResGroupName `
            -CurrUser $CurrUserName `
            -AppName $AppName.toLower() `
            -ApiClientId $SecureApiClientId `
            -ApiClientSecret $SecureApiClientSecret `
            -TemplateParameterFile $TemplateParameterFile

            $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
            Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[168] **** FINISHED AzSubscriptionDeployment *****"
            Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today]: EXITING StartBicepDeploy Function *****************"    
            return $ApiClientId
        }
        catch{
            #Write-Error -Verbose 
            Write-Host "Failed deployment"
        }
    }
    else
    {

        #Write-Host -ForegroundColor Red -BackgroundColor Black  "StartBicepDeploy[35] debugFlag:  $debugFlag"
        #Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[128] ApiAppRegJson:"  $ApiAppRegJson
        #Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[193] ClientAppRegJson:"  $ClientAppRegJson
        
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[206] ApiClientId:" $ApiClientId
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[207] WebClientId:" $WebClientId
       
        #$SecureWebClientId = ConvertTo-SecureString $WebClientId -AsPlainText -Force
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[210] ApiClientSecret:" $ApiClientSecret
        #Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[211] **** STARTING AzSubscriptionDeployment *****"
        
        Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[138] BICEP Command: "

        Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment `
            -Name $DeploymentName ```
            -Location $Location ```
            -TemplateFile $templateFile ```            
            -EnvironmentType $Environment ```
            -ResourceGroupName $ResGroupName ```
            -CurrUser $CurrUserName ```
            -AppName $AppName ```
            -ApiClientId $SecureApiClientId ```
            -ApiClientSecret $SecureApiClientSecret ```
            -TemplateParameterFile $TemplateParameterFile"
          
        try{
        New-AzSubscriptionDeployment `
            -Name $DeploymentName.toLower() `
            -Location $Location.toLower() `
            -TemplateFile $templateFile `
            -EnvironmentType $Environment.toLower() `
            -ResourceGroupName $ResGroupName `
            -CurrUser $CurrUserName `
            -AppName $AppName.toLower() `
            -ApiClientId $SecureApiClientId `
            -ApiClientSecret $SecureApiClientSecret `
            -TemplateParameterFile $TemplateParameterFile

            $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
            Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[168] **** FINISHED AzSubscriptionDeployment *****"
            Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today]: EXITING StartBicepDeploy Function *****************"    
            return $ApiClientId
            }
        catch{
            #Write-Error -Verbose 
            Write-Host "Failed deployment"
        }
           
    }
    
    
}#end of StartBicepDeploy