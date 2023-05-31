
Function global:WriteJsonFile {
    Param(
        [Parameter(Mandatory = $true)] [String]$FilePath    
      , [Parameter(Mandatory = $true)] $CustomObject    
    )  
    #
    If($debugFlag){
      $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
      Write-Host -ForegroundColor Magenta -BackgroundColor White "`n[$today] STARTING UtilityFunctions.WriteJsonFile[2057]"  
      Write-host -ForegroundColor Yellow  "`$FilePath=`"$FilePath`""
      Write-Host -ForegroundColor Yellow "CustomObject.Count=" $CustomObject.Count "`n"      
      $Caller='UtilityFunctions.WriteJsonFile[2060]'      
      #PrintObject -Object $CustomObject -Caller $Caller
      #PrintHash -Object $CustomObject -Caller $Caller
    }#If($debugFlag) #> 
        
    If($debugFlag){Write-Host -ForegroundColor Magenta "{"}
    "{" > $FilePath
    $i = 1
    ForEach ($item in $CustomObject.GetEnumerator())     
    {         
        If($item.value -ne $null)
        {
            $currItemKey = $item.name   
            $currItem = $item.value            
            $itemType = ($currItem).GetType().Name
            $debugMsg = "[" + $i + "] - " + $currItemKey + ".GetType = " + $itemType               
            #Write-Host -ForegroundColor Yellow $debugMsg              
            $value = "`$" + $item.value 
            #Write-Host -ForegroundColor Green "  `$value=`"$value`""
            #>

            Switch($itemType)
            {
                Boolean
                {
                    $key = "`t`"" + $item.name + "`" : "
                    $value =  $item.value 
                    If($i -eq $CustomObject.Count){$property = $key + $value.ToString().ToLower() }
                    Else{ $property = $key + $value.ToString().ToLower() + ","  }
                                     
                    If($debugFlag){Write-Host -ForegroundColor Cyan $property }
                    
                }#Boolean

                Object[]{
                  $itemType = ($currItem).GetType().Name
                  $debugMsg = "[" + $i + "] - " + $currItemKey + ".GetType = " + $itemType               
                  #Write-Host -ForegroundColor DarkYellow $debugMsg              

                  $key = "`t`"" + $currItemKey + "`" : "  
                  $property = $key
                  #Write-Host -ForegroundColor Cyan $property -NoNewline
                  
                  #Write-Host "Array.Count=" $currItem.Count
                  $j = 1
                  ForEach ($arrItem in $currItem.GetEnumerator())     
                  {
                    
                    $itemType = ($arrItem).GetType().Name
                    <#$debugMsg = "`t[" + $j + "] - " + $currItemKey + ".GetType() = " + $itemType 
                    #If($debugFlag){Write-Host -ForegroundColor Green $debugMsg  }                    
                    #>
                    If($itemType -eq 'Boolean')
                    {
                      $value = $arrItem.ToString().ToLower() 
                    }
                    Else{
                      $value = "`"" + $arrItem + "`""
                    }                    
                                        
                    If($j -eq $currItem.Count)
                    {
                      $property = $property + $value 
                      If($debugFlag){                        
                        Write-Host -ForegroundColor Magenta $property 
                      }
                    }
                    Else{                                           
                      $property = $property + $value + " | "
                    }
                    $j++
                  }#ForEach
                  
                  If($i -eq $CustomObject.Count){
                    $property = $property
                  }
                  Else{
                    $property =$property + "," 
                  }
                  $property >> $FilePath
                }#Object[]
                
                OrderedDictionary
                {                  
                  $debugMsg = "[" + $i + "] - " + $currItemKey + ".GetType = " + $itemType 
                  If($debugFlag){Write-Host -ForegroundColor Yellow $debugMsg -NoNewline }
                  $value = "`$" + $item.value 
                  If($debugFlag){Write-Host -ForegroundColor Green "  `$value:`"$value`""}

                    #$objName = "`t" + $item.name + "`n`t{"
                    $dictionaryObjName = "`t" + $currItemKey + "`n`t{"
                    If($debugFlag){Write-Host -ForegroundColor Magenta $dictionaryObjName }
                    $dictionaryObjName >> $FilePath
                    ForEach ($dictionaryItem in $currItem.GetEnumerator())     
                    {
                        If($dictionaryItem.value -ne $null)
                        {
                            $dictionaryKey = $dictionaryItem.name                               
                            $itemType = ($currItem).GetType().Name
                            $debugMsg = "[" + $dictionaryKey + "].Type() = " + $itemType
                            
                            $dictionaryKey = "`t`t" + $dictionaryItem.name + " = "                    
                            $value = "`"" + $dictionaryItem.value + "`", "
                            If($debugFlag){Write-Host -ForegroundColor Green $dictionaryKey -NoNewline
                            Write-Host -ForegroundColor Cyan $value }
                            $dictionaryKey + $value >> $FilePath               
                            $property >> $FilePath
                        }
                        Else
                        {
                            $dictionaryKey = $dictionaryItem.name   
                            #$debugMsg = "`t`t[" + $dictionaryKey + "]"            
                            $debugMsg = "`t`t`"" + $dictionaryKey + "`" : `$null, "
                            If($debugFlag){Write-Host -ForegroundColor Red -BackgroundColor Black $debugMsg }
                            $debugMsg >> $FilePath
                            
                        }
                    }#ForEach
                    $dictionaryObjName = "`t}#" + $currItemKey #+ "`n"
                    If($debugFlag){Write-Host -ForegroundColor Magenta $dictionaryObjName }
                    $dictionaryObjName >> $FilePath
                    $property >> $FilePath
                }#OrderedDictionary
                PSCustomObject
                {
                  $debugMsg = "[" + $i + "] - " + $currItemKey + ".GetType = " + $itemType 
                  If($debugFlag){Write-Host -ForegroundColor Yellow $debugMsg -NoNewline }
                  $value = "`$" + $item.value 
                  If($debugFlag){Write-Host -ForegroundColor Green "  `$value=`"$value`"" }

                    If($debugFlag){Write-Host -ForegroundColor Red "item.name="$item.name }
                    "item.name=" + $item.name >> $FilePath
                    
                    $currItem.PSObject.Properties | ForEach-Object 
                    {
                        If($debugFlag){Write-Host -ForegroundColor Cyan "`t`t"$_.Name "=" $_.Value }
                        "`t`t" + $_.Name + "=" + $_.Value >> $FilePath
                    }
                }#PSCustomObject                
                Default
                {
                  $debugMsg = "Case:Default[" + $i + "] - " + $currItemKey + ".GetType = " + $itemType 
                  #Write-Host -ForegroundColor Yellow $debugMsg -NoNewline
                  #$value = "`$" + $item.value 
                  #Write-Host -ForegroundColor Green "  `$value=`"$value`""

                  #$message = "`t" + $item.name + "=`"" + $item.value + "`""
                  $key = "`t`"" + $item.name + "`" : "
                  $value = "`"" + $item.value + "`""
                    
                  If($i -eq $CustomObject.Count){
                    $property = $key + $value 
                  }
                  Else{ 
                    $property = $key + $value + "," 
                    $value = "`"" + $item.value + "`", "
                  }
                  If($debugFlag){
                  Write-Host -ForegroundColor Green $key -NoNewline
                  Write-Host -ForegroundColor Cyan $value }
                  $property >> $FilePath                    
                }#Default
            }#Switch
        }#if item.value -ne null
        Else
        {
            $key = $item.name               
            #$debugMsg = "`t`"" + $key + "`" : `$null,"            
            #If($i -eq $CustomObject.Count){$property ="`t`"" + $key + "`" : `$null"  }
            #Else{ $property = "`t`"" + $key + "`" : `$null," }
            If($i -eq $CustomObject.Count){$property ="`t`"" + $key + "`" : null"  }
            Else{ $property = "`t`"" + $key + "`" : null," }

            If($debugFlag){Write-Host -ForegroundColor Red -BackgroundColor Black $property }
            $property >> $FilePath            
        }       
        $i++       
    } #ForEach ($item in $CustomObject) 

    If($debugFlag){Write-Host -ForegroundColor Magenta "}" }
    "}" >> $FilePath    

}#WriteJsonFile

$ParamFilePath =  "c:\github\dtp\Deploy\DEBUGGINGOUT.json"


$CurrUser = Get-AzADUser -SignedIn
$CustomObject = [ordered]@{
        DebugFlag = $false;
        DeploymentName = $null;
        DeployMode = $null;        
        CurrUserName = $CurrUser.DisplayName;          
        CurrUserId =  $CurrUser.Id;
        CurrUserPrincipalName = $CurrUser.UserPrincipalName;        
        MyIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();       
        StepCount = 1;        
        StartTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss";        		
        DeveloperGroupId = $null;
	}#$CustomObject


WriteJsonFile -FilePath $ParamFilePath -CustomObject $CustomObject


<#
$CustomObject = [ordered]@{
                "DebugFlag" = "true | false";
                "DeployMode" = "Partial|Full";
	            "CloudEnvironment" = "AzureUSGovernment";
	            "Location" = "Location";
	            "Environment" = "Prod|Dev|Test";
	            "AppName" = "AppName";
	            "Solution" = "Transfer|Pickup|All";
	            "SqlAdmin" = "SqlAdmin";
	            "SqlAdminPwd" = "SqlAdminPwd";
	            "BuildFlag" = "Yes|No";
	            "PublishFlag" = "Yes|No";	            
	            "DeployComponents" = "AppRegistration, ResourceGroup, CreateVM , EnvFile, BuildArchives, PublishApps, CustomRole, RoleAssignments";
	            "OpenIdIssuer" = "sts.windows.net";
	            "WebDomain" = "azurewebsites.us";
	            "DnsSuffix" = "usgovcloudapi.net";
                "GraphEndPoint" = "graph.microsoft.us";
	            "GraphVersion" = "1.0";
	            "AddressPrefix" = "10.10.0";
	            "AddressSpace" = "23"
            } 

#>




     <#$i = 0
    ForEach ($item in $CustomObject.GetEnumerator())     
    {       
        $key = $item.name
        $value = $item.value
        $isNull = $value -eq $null
        
        If($isNull -eq $false){
            $itemType = $value.GetType()
        }
        Else
        {
            $itemType = $null
        }
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$key=" $key -NoNewline
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black " `$value="$value
        Write-Host -ForegroundColor Blue -BackgroundColor White "[$i]"

        Write-Host -ForegroundColor White "`$key = " -NoNewline
        Write-Host -ForegroundColor Cyan "`"$key`""

        Write-Host -ForegroundColor White "`$value = " -NoNewline
        Write-Host -ForegroundColor Yellow "`"$value`""

        Write-Host -ForegroundColor White "`$isNull = " -NoNewline
        Write-Host -ForegroundColor Green "`"$isNull`""
        
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`$item.name="$item.name -NoNewline
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black "; `$item.value="$item.value
        $i++
    }#ForEach
    #>
    #$json > $FilePath
