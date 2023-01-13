#CreateResourceGroup
<#
Checks to see if the resourceGroup by that name exists, if not, creates it
#>
Function global:CreateResourceGroup 
{
    Param(
          [Parameter(Mandatory = $true)] [Object] $DeployObject         
    )
	
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    "================================================================================" 			>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": CREATE RESOURCE GROUP: $DeployObject.ResourceGroupName" >> $DeployInfo.LogFile
    "================================================================================`n"		>> $DeployInfo.LogFile
	
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "Step"$DeployInfo.StepCount": CREATE RESOURCE GROUP:" $DeployObject.ResourceGroupName
    Write-Host -ForegroundColor Cyan "================================================================================"
    $DeployInfo.StepCount++
	
    <#
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue  "CreateResourceGroup[26] DeployObject.ResourceGroupName:" $DeployObject.ResourceGroupName    
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue  "CreateResourceGroup[27] DeployObject.Environment:" $DeployObject.Environment
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue  "CreateResourceGroup[28] DeployObject.Location:" $DeployObject.Location
    #>
    
    $DeployDate = (Get-Date).tostring("MM/dd/yyyy HH:mm")
    $DeployTime = (Get-Date).tostring("HH:MM")
    $TimeStamp = (Get-Date).tostring("MM/dd/yyyy HH:mm")
    $Tags = @{
        DeployDate = $DeployDate;
        DeployTime = $DeployTime;
        Environment = $DeployObject.Environment;
        DeployedBy = $DeployInfo.CurrUserName;
        Owner = $DeployInfo.CurrUserName;
    }
    
    $myResourceGroup = Get-AzResourceGroup -Name $DeployObject.ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent) 
    {
        # ResourceGroup doesn't exist
        $myResourceGroup = New-AzResourceGroup -Name $DeployObject.ResourceGroupName `
            -Location $DeployObject.Location `
            -Tag $Tags
        #Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "CreateResourceGroup[20] Creating New ResourceGroup: "  $DeployInfo.ResourceGroupName
        $ResourceId = $myResourceGroup.ResourceId
        #Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "CreateResourceGroup[25] Creating New ResourceGroup: "  $ResourceId
    }
    else 
    {
        $myResourceGroup = Get-AzResourceGroup -Name $DeployObject.ResourceGroupName
        # ResourceGroup exists: get its resourceID
        $ResourceId = $myResourceGroup.ResourceId
        #Write-Host -ForegroundColor Red -BackgroundColor DarkBlue "CreateResourceGroup[57] EXISTING ResourceGroup: "$DeployInfo.ResourceGroupName
        #Write-Host -ForegroundColor Red -BackgroundColor DarkBlue "Returning ResourceID[1]: " $ResourceId
    }
   
    
    "Resource Group Name: " + $DeployObject.ResourceGroupName >> $DeployInfo.LogFile
    "Resource Group's ResourceId: " + $ResourceId >> $DeployInfo.LogFile

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    #Write-Host -ForegroundColor Green  -BackgroundColor DarkBlue "CreateResourceGroup[66] FINISHED CreateResourceGroup="$DeployObject.ResourceGroupName
    return $ResourceId
}#CreateResourceGroup