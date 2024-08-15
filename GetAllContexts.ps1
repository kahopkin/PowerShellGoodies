$RootFolder= "c:\github\dts\"
$DeployFolder= "c:\github\dts\Deploy\"
$BicepFolder= "c:\github\dts\Deploy\Bicep\"
$TemplateDir= "c:\github\dts\Deploy\LocalSetUp\"
$LogsFolderPath= "C:\GitHub\dts\Deploy\logs\"

$PSScriptRoot = $DeployFolder + "powershell"
& "$PSScriptRoot\PreReqCheck.ps1"
& "$PSScriptRoot\InitiateScripts.ps1"
& "$PSScriptRoot\UtilityFunctions.ps1"
& "$PSScriptRoot\PrintUtilityFunctions.ps1"
& "$PSScriptRoot\ConnectToMSGraph.ps1"
& "$PSScriptRoot\BuildLocalSettingsFile"
& "$PSScriptRoot\CreateEnvironmentFiles.ps1"
& "$PSScriptRoot\CreateAppRoles.ps1"
& "$PSScriptRoot\SetApplicationIdURI.ps1"
& "$PSScriptRoot\CreateAppRegistration.ps1"
& "$PSScriptRoot\CreateScopes.ps1"
& "$PSScriptRoot\CreateServicePrincipal.ps1"    
& "$PSScriptRoot\AddAPIPermissions.ps1"
& "$PSScriptRoot\AddRoleAssignment.ps1"
& "$PSScriptRoot\StartBicepDeploy.ps1"

$global:CurrUser =  $env:username 

#
If($CurrUser -eq "kahopkin")
{ 
    $PrintPSCommands = $true; 
    #$PrintPSCommands = $false; 
    $debugFlag = $true 
    #$PickSubscriptionFlag = "1"
} 

#$global:DeployInfo = InitializeDeployInfoObject -StepCount $StepCount



$AllContexts = Get-AzContext -ListAvailable
$i = 0
        ForEach($context in $AllContexts) 
	    {     
            Write-Host -ForegroundColor Cyan "`$AllContexts[$i] = " 
            $AllContexts[$i] 
            
            $subscriptionName = $context.Subscription.Name
            $subscriptionId = $context.Subscription.Id
            $TenantId = $context.Tenant.Id
            
            Set-AzContext -Subscription $subscriptionId
            #
            If($debugFlag){  
                Write-Host -ForegroundColor Cyan "`n`$subscriptionName= " -NoNewline
                Write-Host -ForegroundColor Green "`"$subscriptionName`""

                Write-Host -ForegroundColor Cyan "`$subscriptionId= " -NoNewline
                Write-Host -ForegroundColor Green "`"$subscriptionId`""

                Write-Host -ForegroundColor Cyan "`$TenantId= " -NoNewline
                Write-Host -ForegroundColor Yellow "`"$TenantId`""
            }#If($debugFlag) #> 

            $tenant = Get-AzTenant -TenantId $TenantId
            $TenantName = $tenant.Name
            $TenantId = $tenant.Id        
            
            #
            If($debugFlag){  
                Write-Host -ForegroundColor Green "After Get-AzTenant...."
                Write-Host -ForegroundColor Cyan "`$TenantName= " -NoNewline
                Write-Host -ForegroundColor Cyan "`"$TenantName`""

                Write-Host -ForegroundColor Cyan "`$TenantId= " -NoNewline
                Write-Host -ForegroundColor Cyan "`"$TenantId`""
            }#If($debugFlag) #>                        

            $Hashtable = [ordered]@{
                Tenant = $TenantName;
                TenantId = $TenantId;                
                Subscription = """$subscriptionName""";                
                SubscriptionId = $subscriptionId;
            }                     
            PrintSubscription -Object $Hashtable            
            $i++
        }#ForEach($context in $AllContexts) 





<#If($debugFlag)
{  
    Write-Host -ForegroundColor Magenta -BackgroundColor White "InitiateDeploymentProcess[142]" 
    Write-Host -ForegroundColor Cyan "`$PSScriptRoot= `"$PSScriptRoot`""
    Write-Host -ForegroundColor Cyan "AllContexts.Count=" $AllContexts.Count
}#If($debugFlag)  


If($AllContexts -eq $null) 
{   
    ConnectToAzure -DeployObject $DeployInfo
}     
ElseIf($AllContexts.Count -eq 1)
{           
    SetDeployInfoObj -DeployObject $DeployInfo
    PrintCurrentContext -DeployObject $DeployInfo
    PickSubscription -CurrContext $AzureContext -DeployObject $DeployInfo -PickSubscriptionFlag $PickSubscriptionFlag
}#Else(AzContext -eq 1) 
ElseIf($AllContexts.Count -gt 1)
{

    ForEach($context in $AllContexts) 
	{            
        $subscriptionName = $context.Subscription.Name
        $subscriptionId = $context.Subscription.Id
        $TenantId = $context.Tenant.Id
        #
        If($debugFlag){  
            Write-Host -ForegroundColor White "`$subscriptionName= " -NoNewline
            Write-Host -ForegroundColor Green "`"$subscriptionName`""

            Write-Host -ForegroundColor White "`$subscriptionId= " -NoNewline
            Write-Host -ForegroundColor Green "`"$subscriptionId`""

            Write-Host -ForegroundColor White "`$TenantId= " -NoNewline
            Write-Host -ForegroundColor Yellow "`"$TenantId`""
        }#If($debugFlag)  

        $tenant = Get-AzTenant -TenantId $TenantId
        $TenantName = $tenant.Name
        $TenantId = $tenant.Id        
            
        #
        If($debugFlag){  
            Write-Host -ForegroundColor White "`$TenantName= " -NoNewline
            Write-Host -ForegroundColor Cyan "`"$TenantName`""

            Write-Host -ForegroundColor White "`$TenantId= " -NoNewline
            Write-Host -ForegroundColor Cyan "`"$TenantId`""
        }#If($debugFlag)                        

        $Hashtable = [ordered]@{
            Tenant = $TenantName;
            TenantId = $TenantId;                
            Subscription = """$subscriptionName""";                
            SubscriptionId = $subscriptionId;
        }                     
        PrintSubscription -Object $Hashtable            
    }#ForEach($context in $AllContexts) 
    #
}#Else(AzContext -gt 1) 
#>

#Get-AzTenant -TenantId $AllContexts[0].Tenant.Id

#
$AllContexts = Get-AzContext -ListAvailable
$AllContexts

$contextName = $AllContexts[0].Name
$subscriptionName = $AllContexts[0].Subscription.Name
$subscriptionId = $AllContexts[0].Subscription.Id
$TenantId = $AllContexts[0].Tenant.Id
Write-Host -ForegroundColor Cyan "`nAllContexts[0] = "

If($debugFlag){      

    Write-Host -ForegroundColor White "`$contextName= " -NoNewline
    Write-Host -ForegroundColor Magenta "`"$contextName`""

    Write-Host -ForegroundColor White "`$subscriptionName= " -NoNewline
    Write-Host -ForegroundColor Green "`"$subscriptionName`""

    Write-Host -ForegroundColor White "`$subscriptionId= " -NoNewline
    Write-Host -ForegroundColor Green "`"$subscriptionId`""

    Write-Host -ForegroundColor White "`$TenantId= " -NoNewline
    Write-Host -ForegroundColor Yellow "`"$TenantId`""
}#If($debugFlag) #> 

$contextName = $AllContexts[1].Name$Al
$subscriptionName = $AllContexts[1].Subscription.Name
$subscriptionId = $AllContexts[1].Subscription.Id
$TenantId = $AllContexts[1].Tenant.Id
Write-Host -ForegroundColor Cyan "`nAllContexts[1] = "
#

If($debugFlag){      

    Write-Host -ForegroundColor White "`$contextName= " -NoNewline
    Write-Host -ForegroundColor Magenta "`"$contextName`""

    Write-Host -ForegroundColor White "`$subscriptionName= " -NoNewline
    Write-Host -ForegroundColor Green "`"$subscriptionName`""

    Write-Host -ForegroundColor White "`$subscriptionId= " -NoNewline
    Write-Host -ForegroundColor Green "`"$subscriptionId`""

    Write-Host -ForegroundColor White "`$TenantId= " -NoNewline
    Write-Host -ForegroundColor Yellow "`"$TenantId`""
}#If($debugFlag) #> 


$contextName = $AllContexts[2].Name
$subscriptionName = $AllContexts[2].Subscription.Name
$subscriptionId = $AllContexts[2].Subscription.Id
$TenantId = $AllContexts[2].Tenant.Id
Write-Host -ForegroundColor Cyan "`nAllContexts[2] = "

#
If($debugFlag){      

    Write-Host -ForegroundColor White "`$contextName= " -NoNewline
    Write-Host -ForegroundColor Magenta "`"$contextName`""

    Write-Host -ForegroundColor White "`$subscriptionName= " -NoNewline
    Write-Host -ForegroundColor Green "`"$subscriptionName`""

    Write-Host -ForegroundColor White "`$subscriptionId= " -NoNewline
    Write-Host -ForegroundColor Green "`"$subscriptionId`""

    Write-Host -ForegroundColor White "`$TenantId= " -NoNewline
    Write-Host -ForegroundColor Yellow "`"$TenantId`""
}#If($debugFlag) #> 

