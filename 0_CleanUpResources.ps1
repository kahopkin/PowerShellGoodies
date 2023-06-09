
#RemoveAppRegistration.ps1
#C:\GitHub\PowerShellGoodies\CleanUpResources.ps1
<#
This script removes app registrations, 
either Owned ones or specified by name
#>

$currDir = Get-Item (Get-Location)
$currDirPath = $currDir.FullName
#
if($currDirPath -notmatch "powershellgoodies")
{
    cd C:\GitHub\PowerShellGoodies
}
#>

Function global:CleanUpResources{
 Param(     
     [Parameter(Mandatory = $true)]  [String]  $OwnedApplication
    ,[Parameter(Mandatory = $false)] [Boolean] $LogFilesOnly
    ,[Parameter(Mandatory = $true)]  [String]  $ParentFolder
    ,[Parameter(Mandatory = $false)] [Boolean] $RemoveRG
    ,[Parameter(Mandatory = $false)] [String]  $ResourceGroup
 )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START CleanUpResources "    
    Write-Host -ForegroundColor Cyan "`n================================================================================"
	Write-Host -ForegroundColor Cyan "[$today] STARTING CleanUpResources ... Remove Owned App Registrations and Log files..."
	Write-Host -ForegroundColor Cyan "================================================================================"    
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`PARAMETERS: "                    
    Write-Host -ForegroundColor Green "`$OwnedApplication=`""$OwnedApplication "`""
    Write-Host -ForegroundColor Yellow "`$LogFilesOnly=`""$LogFilesOnly "`""
    Write-Host -ForegroundColor Green "`$ParentFolder=`""$ParentFolder "`""
    Write-Host -ForegroundColor Yellow "`$RemoveRG=`""$RemoveRG "`""
    Write-Host -ForegroundColor Yellow "`$ResourceGroup=`""$ResourceGroup "`""
    
    If($LogFilesOnly.Length -eq 0){$LogFilesOnly=$false}
    
    $AzureContext = Get-AzContext
    Write-Host -ForegroundColor Cyan "AzureContext -eq null=" ($AzureContext -eq $null)
    If( ($AzureContext -eq $null ) -or ($AzureContext.Subscription.Name -notmatch "^BMA-05") )
    {
        Connect-AzAccount -Environment AzureUSGovernment
    }
    Else
    {
        $Subscription = $AzureContext.Subscription.Name
        $SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId   
        $TenantName = $SubscriptionTenant.Name
        $TenantId = $SubscriptionTenant.Id
    }
    
    Write-Host -ForegroundColor Magenta "[51]" 
    Write-Host -ForegroundColor Yellow "`$Subscription=`"$Subscription`""
    Write-Host -ForegroundColor Yellow "`$SubscriptionTenant=`"$SubscriptionTenant`""
    Write-Host -ForegroundColor Yellow "`$SubscriptionTenant=`"$TenantName`""
    Write-Host -ForegroundColor Yellow "`$SubscriptionTenant.Id=`"$TenantId`""

    $i = 0
    if($OwnedApplication -eq $true -and $LogFilesOnly -eq $false)
    {
        $AdApplications = Get-AzADApplication -OwnedApplication
        Write-Host -ForegroundColor Magenta "[63] Owned App Registration count="$AdApplications.Count        
        ForEach($appreg in $AdApplications) 
        {      
            $i++      
            if ($Subscription -match "^BMA-05") 
            { 
              
                #Write-Host 'RemoveAppRegistration[$i] $appreg.DisplayName does not start with Data"'
                $DisplayName = $appreg.DisplayName
                $AppId = $appreg.AppId
                #Write-Host "`$DisplayName=`"$DisplayName`""
                #{$_ -in "2","partial"}{$DeployMode = "Partial"}
               if( -not (
                    $DisplayName -match '^dtp' -or `                     
                    $DisplayName -match '^dpp' -or `
                    #$DisplayName -match '^dts' -or `                      
                    $DisplayName -eq "Graph"  
                    ) #-eq $false 
                )
                {
                    Remove-AzADApplication -ObjectId $appreg.Id
                    Write-Host -ForegroundColor Red "Deleted:"$DisplayName
                    #Write-Host -ForegroundColor Red "`$ObjectId=`"$AppId`""
                }
                else
                {
                    Write-Host -ForegroundColor Green "KEEPING:"$DisplayName
                    #Write-Host -ForegroundColor Green "`$ObjectId=`"$AppId`""
                }#else               
            }
            else
            {
                Write-Host -ForegroundColor Yellow -BackgroundColor Black "[109][$i]" $appreg.DisplayName"; AppId=" $appreg.AppId 
                #Write-Host 'RemoveAppRegistration[$i] $appreg.DisplayName does not start with Data"'
                #Remove-AzADApplication -ObjectId $appreg.Id
                #Write-Host -ForegroundColor Red "[$i] Deleted AzADApplication: " $appreg.DisplayName"; ObjectId=" $appreg.AppId 
                #Remove-AzADServicePrincipal -DisplayName $appreg.DisplayName
                #Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id                  
                #Write-Host -ForegroundColor Red  -BackgroundColor White "[$i] Deleted AzADServicePrincipal:" $appreg.DisplayName"; ObjectId=" $appreg.AppId 
            }	       
            #>
        }#ForEach appreg in owned registrations
    }#if OwnedApplication -eq $true 

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED RemoveAppRegistration "        
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "[$today] FINISHED RemoveAppRegistration ..."
	Write-Host -ForegroundColor Cyan "================================================================================"    
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "[$today] STARTING DeleteLogFiles ..."
	Write-Host -ForegroundColor Cyan "================================================================================"    
    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START DeleteLogFiles FOR $ParentDirPath "
    
    if (Test-Path $ParentFolder) 
    {
        Write-Host -ForegroundColor Cyan "[153] EXISTING $ParentFolder ParentFolder" 
        $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName

        Write-Host -ForegroundColor Cyan "`$ParentFolder=`"$ParentFolder`""
        Write-Host -ForegroundColor Cyan "`$FullPath`"$ParentFolderPath`""

        $dirs = Get-ChildItem -Path $ParentFolderPath -Recurse | Sort-Object #| Where-Object { $_.PSIsContainer -eq $true } # | Sort-Object 
        $FolderCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -Directory | Measure-Object).Count
        $FileCount = (Get-ChildItem -Path $ParentFolderPath -Recurse -File | Measure-Object).Count
        Write-Host -ForegroundColor Cyan "FolderCount: $FolderCount "      
        Write-Host -ForegroundColor Cyan "FileCount: $FileCount "
        $i = 0  
        $j = 0  
    
        Foreach ($file In $dirs) 
        { 
        
            $FullPath =  $file.FullName
            $FileName = $file.BaseName        
            $ParentFolder = Split-Path (Split-Path $file.FullName -Parent) -Leaf
            $DirectoryPath = $file.DirectoryName
            $Extension = $file.Extension            
            $LastWriteTime = $file.LastWriteTime
            $LastWriteTime = $LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            $FullFileName = Split-Path $file.FullName -Leaf -Resolve
            
            $isDir = (Get-Item $FullPath) -is [System.IO.DirectoryInfo]
            $subFolder = Get-ChildItem -Path $file.FullName -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false }  | Measure-Object -property Length -sum | Select-Object Sum    
            # Set default value for addition to file name            
         
            Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "`$FullFileName=`"$FullFileName`""
            Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "`$FullPath=`"$FullPath`""
                
            Remove-Item -Path $FullPath
            $i++
         
        }#ForEach
        Write-Host -ForegroundColor Cyan "================================================================================"
	    Write-Host -ForegroundColor Cyan "[$today] FINISHED DeleteLogFiles ..."
	    Write-Host -ForegroundColor Cyan "================================================================================"    
    }#if

    #>

    <#if($removeRG)
    {
        $today = Get-Date -Format "MM/dd/yyyy"
        #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED DeleteLogFiles FOR $ParentDirPath "

        Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] START Removing ResourceGroups "
        #Remove-AzResourceGroup -Name $ResourceGroup -Force
    
        #$myResourceGroups = Get-AzResourceGroup | Where-Object {$_.Tags.DeployDate -eq $today -and $_.Tags.DeployedBy -eq 'Kat Hopkins'}
        $myResourceGroups = Get-AzResourceGroup | Where-Object {$_.Tags.DeployedBy -eq 'Kat Hopkins'}
        
        Write-Host -ForegroundColor Cyan "myResourceGroups.Count=" $myResourceGroups.Count
        Foreach ($item In $myResourceGroups) 
        {
            $StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"            
            $ResourceGroupName = $item.ResourceGroupName
            $resources = Get-AzResource -ResourceGroupName $ResourceGroupName | Where-Object {$_.Tags.DeployedBy -eq 'Kat Hopkins'}
            Write-Host -ForegroundColor Cyan $resources.Count
            Write-Host -ForegroundColor Yellow "$StartTime Removing Resources from RG=" $ResourceGroupName
            Foreach($resource in $resources)
            {
                If( -not ($resource.Name).StartsWith('kv') )
                {
                    Write-Host "[199] resource" $resource.Name
                    Remove-AzResource -ResourceName $resource.Name -Force
                }
                else
                {
                    Write-Host -ForegroundColor Red "[204] KEYVAULT :" $resource.Name
                }
                
            }            
            #Remove-AzResourceGroup -Name $ResourceGroupName -Force
            $EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
            $Duration = New-TimeSpan -Start $StartTime -End $EndTime
            #Write-Host -ForegroundColor Red "$EndTime DELETED ResourceGroup="$ResourceGroupName "Duration:" $Duration
        }
    }#if removeRG
    #>
    #Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n [$today] FINISHED Removing ResourceGroup $ResourceGroup "
    
    #Write-Host -ForegroundColor Green -BackgroundColor Black "`n [$today] FINISHED CleanUpResources "        
    #$DisconnectState = $Disconnect = Disconnect-AzAccount 
    
} #CleanUpResources

$today = Get-Date -Format 'ddd'   
$Environment = "test"
$Location = "usgovvirginia"
#$AppName = $today + "Site"
#$ResourceGroup += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment)
$LogFilesOnly = $true
$LogFilesOnly = $false

$RemoveRG = $true
$RemoveRG = $false
$ResourceGroupName = "rg-dts-transfer-prod"
$ParentFolder = 'C:\GitHub\dtp\Deploy\logs'
#$ParentFolder = 'C:\Users\kahopkin\source\repos\MainBranch\Deploy\logs'
#CleanUpResources -OwnedApplication $true -ParentFolder $ParentFolder -ResourceGroup $ResourceGroup
CleanUpResources `
    -OwnedApplication 'true' `
    -ParentFolder $ParentFolder `
    -LogFilesOnly $LogFilesOnly `
    -ResourceGroup $ResourceGroup 
    #-RemoveRG $RemoveRG `
    
& "$PSScriptRoot\RemoveOrphanRoleAssignments.ps1"
RemoveOrphanRoleAssignments -ResourceGroupName rg-dts-transfer-prod


    <#$i=0
    Write-Host -ForegroundColor Green "`n[53] AppName.length=" $AppName.Length    

    if($AppName.Length -ne 0 )
    {
        Write-Host -ForegroundColor Green "[56] AppName= $AppName"
        
        $AdApplications = Get-AzADApplication -DisplayName $AppName   
        Write-Host -ForegroundColor Yellow "[60] CleanUpResources[50] AppReg count:" $AdApplications.Count
        
        ForEach($appreg in $AdApplications) 
        {
            $i++
	        #Remove-AzADApplication -ObjectId $appreg.id
            Write-Host -ForegroundColor Cyan "CleanUpResources[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id 
        }
    }
    else
    {
        Write-Host 'CleanUpResources[71] AppName is null' 
    }
    #>
    