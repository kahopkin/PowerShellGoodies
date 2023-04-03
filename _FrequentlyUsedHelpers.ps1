If($debugFlag){
}#If($debugFlag) #> 

If($debugFlag){  
    Write-Host -ForegroundColor Magenta ".[]" 
    Write-Host -ForegroundColor White -NoNewline "`$XYZ=`""
    Write-Host -ForegroundColor Cyan "`"$XYZ`""
}#If($debugFlag) #> 

If($debugFlag){exit(1)}

Write-Host -ForegroundColor White -NoNewline 
Write-Host -ForegroundColor White -NoNewline ": "

$ObjectName=""

$Caller='`n .[]::'
$ObjectName = $DeployObject.Solution + "AppObj"
PrintDeployObject -ObjectName $ObjectName -Object $DeployInfo -Caller $Caller

$FilePath = $LogsFolderPath + $ObjectName + ".ps1"
PrintObjectAsVars -Object $DeployObject -Caller $Caller -ObjectName $ObjectName -FilePath $FilePath
PrintObjectAsVars -Object $DeployObject -ObjectName $ObjectName -Caller $Caller 


$Message = "Step " + $DeployInfo.StepCount + ": " + ""
Write-Host -ForegroundColor Cyan "================================================================================"    	
Write-Host -ForegroundColor Cyan $Message
Write-Host -ForegroundColor Cyan "================================================================================"
$DeployInfo.StepCount++

$Message = ""
Write-Host -ForegroundColor Magenta -BackgroundColor Black "================================================================================"    	
Write-Host -ForegroundColor Magenta -BackgroundColor Black     $Message
Write-Host -ForegroundColor Magenta -BackgroundColor Black "================================================================================"
$DeployInfo.StepCount++
-NoNewline
"================================================================================"								>> $DeployInfo.LogFile
$Message																										>> $DeployInfo.LogFile
"================================================================================"								>> $DeployInfo.LogFile


"================================================================================"	>> $DeployInfo.LogFile
"Step" + $DeployInfo.StepCount + ": ADD API PERMISSION: " + $PermissionParentName	>> $DeployInfo.LogFile
"================================================================================"	>> $DeployInfo.LogFile
#>
Write-Host -ForegroundColor Cyan "================================================================================"
Write-Host -ForegroundColor Cyan "Step" $DeployInfo.StepCount": ADD API PERMISSION:"$PermissionParentName
Write-Host -ForegroundColor Cyan "================================================================================"
$DeployInfo.StepCount++

Switch($DeployInfo.Solution)
{
    Transfer
    {
    }
    Pickup
    {
    }
    All
    {
    }
    Default
    {
        exit(1)
    }
}#switch(Solution)


#Write DeployInfo to stdout
Write-Host -ForegroundColor Cyan "`$DeployInfo=@'`n["        
$json = ConvertTo-Json $DeployInfo
Write-Host -ForegroundColor Cyan $json
Write-Host -ForegroundColor Cyan "]`n'@"




<#
If($debugFlag){  
    Write-Host -ForegroundColor Magenta "[]"
}#If($debugFlag) #> 

<#If(-not $debugFlag){  
#}#If(-not $debugFlag) #>  

#If($debugFlag){exit(1)}







#PRINT INDIV PROPERTIES:
Write-Host -ForegroundColor Cyan "`$DeployObject.CloudEnvironment="$DeployObject.CloudEnvironment
Write-Host -ForegroundColor Cyan "CurrUserName= " $DeployInfo.CurrUserName
Write-Host -ForegroundColor Yellow "Space index= " $firstSpace
Write-Host -ForegroundColor Cyan "CurrUserFirst= " $DeployInfo.CurrUserFirst
Write-Host -ForegroundColor Cyan "CurrUserPrincipalName= " $DeployInfo.CurrUserPrincipalName      
        





<#
If($debugFlag){  
    Write-Host -ForegroundColor Magenta ".[]" 
    Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""
}#If($debugFlag) #> 
<#
If(-not $debugFlag){  
}#If(-not $debugFlag) #>

#If($debugFlag){exit(1)}
