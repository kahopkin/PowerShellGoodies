$PSScriptRoot =  "C:\GitHub\dtp\Deploy\powershell"

& "$PSScriptRoot\InitiateScripts.ps1"
& "$PSScriptRoot\UtilityFunctions.ps1"
& "$PSScriptRoot\PrintUtilityFunctions.ps1"




$ResourceGroupName="rg-dts-transfer-prod"
$ResourceName="kv-dts-transfer-prod"
$ResourceType="Microsoft.KeyVault/vaults"

$DeployInfo = InitializeDeployInfoObject
SetDeployInfoObj -DeployObject $DeployInfo

ConfigureDeployInfo -DeployObject $DeployInfo 

$DeployInfo.KeyVaultExists = CheckForExistingResource  `
                                              -ResourceGroupName $DeployInfo.ResourceGroupName  `
                                              -ResourceType "Microsoft.KeyVault/vaults" `
                                              -ResourceName $DeployInfo.KeyVaultName 

Function global:CheckForExistingResource
{
   Param(       
        [Parameter(Mandatory = $true)] [String] $ResourceGroupName 
      , [Parameter(Mandatory = $false)] [String] $ResourceName
      , [Parameter(Mandatory = $true)] [String] $ResourceType
    )  

    If($debugFlag){
      $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
      Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING UtilityFunctions.CheckForExistingResource[2024]"  
    }#If($debugFlag) #> 
    
    If($debugFlag){  
      Write-Host -ForegroundColor Yellow "UtilityFunctions.CheckForExistingResource[2028]"      
      
      Write-Host -ForegroundColor White "`$ResourceGroupName=" -NoNewline
      Write-Host -ForegroundColor Cyan "`"$ResourceGroupName`""
      
      #Write-Host -ForegroundColor Cyan "ResourceName.length="$ResourceName.length      
      Write-Host -ForegroundColor White "`$ResourceName=" -NoNewline
      Write-Host -ForegroundColor Cyan "`"$ResourceName`""

      Write-Host -ForegroundColor White "`$ResourceType=" -NoNewline
      Write-Host -ForegroundColor Cyan "`"$ResourceType`""
    }#If($debugFlag) #> 

    If($ResourceName.length -eq 0)
    {
      $resourceExists = $false
      Write-Host -ForegroundColor Yellow "UtilityFunctions.CheckForExistingResource[2044] $ResourceName.length=0"
    }
    Else
    {      
      $azResource = Get-AzResource  -ResourceGroupName $ResourceGroupName `
                                    -ResourceType $ResourceType `
                                    -Name $ResourceName `
                                    -ErrorAction SilentlyContinue

      $azRequestString =  "`n`$azResource = `nGet-AzResource  ```n`t" + 
      #$azRequestString =  "`nGet-AzResource  ```n`t" + 
                          "-ResourceGroupName `"" + $ResourceGroupName + "`" ```n`t" +
                          "-ResourceType `"" +  $ResourceType + "`" ```n`t" +
                          "-Name `"" +  $ResourceName + "`" ```n`t" +
                          "-ErrorAction SilentlyContinue `n"
      If($debugFlag){
        Write-Host -ForegroundColor Magenta "UtilityFunctions.CheckForExistingResource[2059] - azRequestString:"         
        Write-Host -ForegroundColor Cyan $azRequestString
      }#If($debugFlag) #> 

      If($azResource -eq $null)
      {
        $resourceExists = $false
      }
      Else{
        Write-Host -ForegroundColor Yellow "UtilityFunctions.CheckForExistingResource[2068] $ResourceName ->resourceExists TRUE"
        $resourceExists = $true
      }
    }   
  return $resourceExists
}#CheckForExistingResource
