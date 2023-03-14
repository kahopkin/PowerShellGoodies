<#
If($debugFlag){  
    Write-Host -ForegroundColor Magenta ".[]" 
    Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""
}#If($debugFlag) #> 
#If($debugFlag){exit(1)}

$Caller='n .[]::'
$ObjectName=""
$ObjectName = $DeployObject.Solution + "AppObj"
PrintDeployObject -ObjectName $ObjectName -Object $DeployInfo -Caller $Caller


$Message = ""
Write-Host -ForegroundColor Cyan "================================================================================"    	
Write-Host -ForegroundColor Cyan $Message
Write-Host -ForegroundColor Cyan "================================================================================"


"================================================================================"								>> $DeployInfo.LogFile
$Message																										>> $DeployInfo.LogFile
"================================================================================"								>> $DeployInfo.LogFile
