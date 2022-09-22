
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
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START StartBicepDeploy "
    #$Caller = 'StartBicepDeploy'
    #PrintObject -object $AppRegObj -Caller $Caller
    #PrintHashTable -object $AppRegObj -Caller $Caller

    if ($Environment.ToLower() -eq "test" -or $Environment.ToLower() -eq "dev") 
    {
        $global:TemplateParameterFile = "..\main.parameters.dev.json"
    }
    else 
    {
        $global:TemplateParameterFile = "..\main.parameters.prod.json"
    }
    $templateFile = '..\main.bicep'
    <#    
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[27] debugFlag:  $debugFlag"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] Subscription:  $subscriptionName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] ResGroupName: $ResGroupName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] ResourceId: $ResourceId"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] EnvType:  $Environment"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] Location:  $location"    
	#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] AppName:  $AppName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[] DeploymentName:  $DeploymentName"
    #>
    
    $ApiClientId = $AppRegObj.ApiClientId
    #Write-Host -ForegroundColor Cyan "StartBicepDeploy[33] ApiClientId:"  $ApiClientId
       
    $WebClientId = $AppRegObj.WebClientId
    #Write-Host -ForegroundColor Cyan "StartBicepDeploy[36] WebClientId:"  $WebClientId
        
    $SecureApiClientId = ConvertTo-SecureString $ApiClientId -AsPlainText -Force

    if ($AppRegObj.ApiClientSecret.Length -gt 0)
    {
        $ApiClientSecret = $AppRegObj.ApiClientSecret
        $SecureApiClientSecret = ConvertTo-SecureString $ApiClientSecret -AsPlainText -Force            
    }

    $CurrUser = Get-AzADUser -SignedIn
    $CurrUserName = $CurrUser.DisplayName
    $TimeStamp = (Get-Date).tostring(“MM-dd-yyyy HH:MM”)
    #$TimeStamp = (Get-Date).tostring(“HH:MM”)

    if($debugFlag)
    {        
        #Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[62] BICEP Command: "
     
        "`nNew-AzSubscriptionDeployment ```
        -Name $DeploymentName ```
        -Location $Location ```
        -TemplateFile $templateFile ```
        -EnvironmentType $Environment ```
        -ResourceGroupName $ResGroupName ```
        -CurrUser $CurrUserName ```
        -TimeStamp $TimeStamp ```
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
        -TimeStamp $TimeStamp ```
        -AppName $AppName ```
        -ApiClientId $ApiClientId ```
        -ApiClientSecret $ApiClientSecret ```
        -TemplateParameterFile $TemplateParameterFile"

        #try{
        New-AzSubscriptionDeployment `
            -Name $DeploymentName `
            -Location $Location.toLower() `
            -TemplateFile $templateFile `
            -EnvironmentType $Environment.toLower() `
            -ResourceGroupName $ResGroupName `
            -CurrUser $CurrUserName `
            -TimeStamp $TimeStamp `
            -AppName $AppName.toLower() `
            -ApiClientId $SecureApiClientId `
            -ApiClientSecret $SecureApiClientSecret `
            -TemplateParameterFile $TemplateParameterFile

            $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
            Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[105]  FINISHED AzSubscriptionDeployment "
            Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today]: EXITING StartBicepDeploy Function "    
            #return $ApiClientId
        #}
        #catch{
            #Write-Error -Verbose 
         #   Write-Host "Failed deployment"
        #}
    }
    else
    {
        Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[116] BICEP Command: "
        Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment `
            -Name $DeploymentName ```
            -Location $Location ```
            -TemplateFile $templateFile ```
            -EnvironmentType $Environment ```
            -ResourceGroupName $ResGroupName ```
            -CurrUser $CurrUserName ```
            -TimeStamp $TimeStamp ```
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
            -TimeStamp $TimeStamp `
            -AppName $AppName.toLower() `
            -ApiClientId $SecureApiClientId `
            -ApiClientSecret $SecureApiClientSecret `
            -TemplateParameterFile $TemplateParameterFile

            $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
            Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[146]  FINISHED AzSubscriptionDeployment "
            Write-Host -ForegroundColor Green -BackgroundColor Black  "`[$today]: EXITING StartBicepDeploy Function `n" 
            #return $ApiClientId
            }
        catch{            
            #Write-Host -ForegroundColor Red "Failed deployment"
            Write-Output  "Ran into an issue: $($PSItem.ToString())"
        }           
    }    
    
}#end of StartBicepDeploy