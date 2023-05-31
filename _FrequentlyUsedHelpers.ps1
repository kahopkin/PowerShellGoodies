If($debugFlag){exit(1)}

If($debugFlag){
}#If($debugFlag) #>

#
If($debugFlag){  
    Write-Host -ForegroundColor Magenta -BackgroundColor White ".[]" 
    Write-Host -ForegroundColor Cyan "`$XYZ= `"$XYZ`""
}#If($debugFlag) #> 

If($debugFlag){  
    Write-Host -ForegroundColor White "`$XYZ = " -NoNewline
    Write-Host -ForegroundColor Cyan "`"$XYZ`""
}#If($debugFlag) #> 

For($i=1;$i -le 80;$i++){If($i -eq 80){Write-Host -ForegroundColor Green "=" }Else{Write-Host -ForegroundColor Green "=" -NoNewline}} 

For($i=1;$i -le 80;$i++){ "=" >> $DeployObject.LogFile} "`n" >> $DeployObject.LogFile

$Message = "Step " + $StepCount + ": " + ""
$Message = "Step " + $DeployInfo.StepCount + ": " + ""

$Message =  ""
$StepCount = PrintMessage -Message $Message -StepCount $StepCount
$DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
$DeployInfo.StepCount = PrintMessage -Message $Message -StepCount $DeployInfo.StepCount

PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile

If($debugFlag){
  Write-Host -ForegroundColor Magenta -BackgroundColor Black "STARTING FileName.FunctionName[Line]"
}#If($debugFlag) #>


  If($debugFlag){
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n[$today] STARTING FileName.FunctionName"        
  }
  Else{
    $Message = ":"
    $DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount       
    PrintMessageToFile -Message $Message -StepCount $DeployObject.StepCount -LogFile $DeployObject.LogFile
  } 

  If($debugFlag){
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n[$today] STARTING FileName.FunctionName"        
  }
  Else{
    $Message = ":"
    $DeployInfo.StepCount = PrintMessage -Message $Message -StepCount $DeployInfo.StepCount
    $DeployObject.StepCount = PrintMessage -Message $Message -StepCount $DeployObject.StepCount
  }

If($debugFlag){
  $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
  Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n[$today] STARTING FileName.FunctionName"  
}#If($debugFlag) #> 

Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n[$today] STARTING FileName.FunctionName[Line]"  


For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline} Write-Host "`n"


For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "*" -NoNewline} Write-Host "`n"

For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Cyan "=" -NoNewline} Write-Host "`n"

For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta -BackgroundColor Black "=" -NoNewline} Write-Host "`n"

For($i=0;$i -lt 80;$i++){ "=" >> $LogFile} "`n" >> $LogFile
For($i=0;$i -lt 80;$i++){ "=" >> $DeployObject.LogFile} "`n" >> $DeployObject.LogFile


Write-Host -ForegroundColor Magenta ".[]" 
Write-Host -ForegroundColor Magenta "[]" 


 Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""


If($debugFlag){
  Write-Host -ForegroundColor Magenta ".[]" 
  Write-Host -ForegroundColor White "`$XYZ=" -NoNewline
  Write-Host -ForegroundColor Cyan "`"$XYZ`""
}#If($debugFlag) #> 

#ise:
If($debugFlag){  
    Write-Host -ForegroundColor Magenta ".[]"     
    Write-Host -ForegroundColor Cyan "`$ = `"$`""
}#If($debugFlag) #> 

#vs
If($debugFlag){  
    Write-Host -ForegroundColor Magenta ".[]"     
    Write-Host -ForegroundColor Cyan "` = `"`" "
}#If($debugFlag) #> 

Write-Host -ForegroundColor Cyan "`=`"`""
#Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""

If($debugFlag){exit(1)}

Write-Host -ForegroundColor White -NoNewline 
Write-Host -ForegroundColor White -NoNewline ": "

{$_ -in "1","y", "yes"} 
{$_ -in "0","n", "no"} 

 For($i=0;$i -lt 80;$i++){ Write-Host -ForegroundColor Magenta "-" -NoNewline}
Write-Host "`n"

$ObjectName = ""
$Caller = '`n .[]::'
$ObjectName = $DeployObject.Solution + "AppObj"
PrintDeployObject -ObjectName $ObjectName -Object $DeployInfo -Caller $Caller

If($debugFlag){    
$Caller = '`n .[]::'
$ObjectName = ""
PrintDeployObject -ObjectName $ObjectName -Object $DeployInfo -Caller $Caller
}#If($debugFlag) #> 

$FilePath = $LogsFolderPath + $ObjectName + ".ps1"
PrintObjectAsVars -Object $DeployObject -Caller $Caller -ObjectName $ObjectName -FilePath $FilePath
PrintObjectAsVars -Object $DeployObject -ObjectName $ObjectName -Caller $Caller 


If($DeployObject.DebugFlag)
{
    $Caller='`n .[]::'
    $ObjectName = ""
    PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller
}#If($debugFlag) #>


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

Switch($DeployObject.Solution)
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

If($debugFlag){
	    $Caller='`nInitiateScripts.ConfigureTransferAppObj[851] ::' 
        $ObjectName = $DeployObject.Solution + "AppObj"
	    PrintDeployObject -ObjectName $ObjectName -Object $DeployObject -Caller $Caller        
    }#>
    



#PRINT INDIV PROPERTIES:
Write-Host -ForegroundColor Cyan "`$DeployObject.CloudEnvironment="$DeployObject.CloudEnvironment
Write-Host -ForegroundColor Cyan "CurrUserName= " $DeployInfo.CurrUserName
Write-Host -ForegroundColor Yellow "Space index= " $firstSpace
Write-Host -ForegroundColor Cyan "CurrUserFirst= " $DeployInfo.CurrUserFirst
Write-Host -ForegroundColor Cyan "CurrUserPrincipalName= " $DeployInfo.CurrUserPrincipalName      
        

#
If($debugFlag)
{
    Write-Host -ForegroundColor Magenta "`n================================================================================"
    Write-Host -ForegroundColor Magenta "InitiateScripts.ConfigureTransferAppObj[879]:"
    #Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.ResourceGroupName="$DeployObject.TransferAppObj.ResourceGroupName        
        
    Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.Solution="$DeployObject.TransferAppObj.Solution
    Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.AppName="$DeployObject.TransferAppObj.AppName 

    Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegName="$DeployObject.TransferAppObj.APIAppRegName
    Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegAppId="$DeployObject.TransferAppObj.APIAppRegAppId
    Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegObjectId="$DeployObject.TransferAppObj.APIAppRegObjectId
    Write-Host -ForegroundColor Yellow "`$DeployObject.TransferAppObj.APIAppRegExists="$DeployObject.TransferAppObj.APIAppRegExists
        
    Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegName="$DeployObject.TransferAppObj.ClientAppRegName
    Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegAppId="$DeployObject.TransferAppObj.ClientAppRegAppId
    Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegObjectId="$DeployObject.TransferAppObj.ClientAppRegObjectId
    Write-Host -ForegroundColor Cyan "`$DeployObject.TransferAppObj.ClientAppRegExists="$DeployObject.TransferAppObj.ClientAppRegExists        
    Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.BuildFlag="$DeployObject.TransferAppObj.BuildFlag
    Write-Host -ForegroundColor Green "`$DeployObject.TransferAppObj.PublishFlag="$DeployObject.TransferAppObj.PublishFlag
        
    Write-Host -ForegroundColor Magenta "================================================================================"        
}#If($debugFlag) #> 

#
If($debugFlag){
	$Caller='`nInitiateScripts.ConfigureTransferAppObj[861] ::' 
    $ObjectName = "TransferAppObj"
	PrintDeployObject -ObjectName $ObjectName -Object $DeployInfo -Caller $Caller
    #PrintDeployObject -ObjectName "DeployInfo" -Object $DeployInfo -Caller $Caller
}#>

#
If($debugFlag){  
    Write-Host -ForegroundColor Magenta ".[]" 
    Write-Host -ForegroundColor Cyan "`$XYZ=`"$XYZ`""
}#If($debugFlag) #> 

#
If(-not $debugFlag){  
}#If(-not $debugFlag) #>

If($debugFlag){exit(1)}
