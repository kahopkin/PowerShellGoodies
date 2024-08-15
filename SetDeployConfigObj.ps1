$debugFlag = $true

$DeployConfigObj = [ordered]@{
        DeployMode = "Full";
        AppRegistration = $false;
        ResourceGroup = $false;        
        CreateVM  = $false;
        EnvFile = $false;
        BuildArchives = $false;
        PublishApps = $false;                
        CustomRole = $false;        
        RoleAssignments = $false;  
}

Write-Host -ForegroundColor Cyan "[15]DeployConfigObj="      
$DeployConfigObj	
<#
Write-Host -ForegroundColor Cyan "[15]DeployConfigObj.Keys="      
$DeployConfigObj.Keys
Write-Host -ForegroundColor Cyan "[15]DeployConfigObj.Values="      
$DeployConfigObj.Values
#>
$ComponentsChosen="AppRegistration,ResourceGroup"

Function global:SetDeployConfigObj
{
  Param(     
    [Parameter(Mandatory = $false)] [string] $ComponentsChosen          
    )         
      
    If($debugFlag){
      $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
      #Write-Host -ForegroundColor Magenta -BackgroundColor Black "`n[$today] STARTING UtilityFunctions.SetDeployConfigObj[912]" 
      Write-Host -ForegroundColor White "`n`$ComponentsChosen=" -NoNewline 
      Write-Host -ForegroundColor Cyan "`"$ComponentsChosen`"`n"      
    }#If($debugFlag) #> 

    $ComponentHash = [ordered]@{        
        0 = "DeployMode";
        1 = "AppRegistration";
        2 = "ResourceGroup"; 
        3 = "CreateVM";
        4 = "EnvFile";
        5 = "BuildArchives";
        6 = "PublishApps";
        7 = "CustomRole";    
        8 = "RoleAssignments";
    }
   
   
    $i = 1

    If($ComponentsChosen -ne $null)
    {  
        $DeployComponents = @()
        $afterReplaceNormalized = $ComponentsChosen -replace '\s+', ''    
        #if incoming is an array
        If($afterReplaceNormalized -match ',')
        {
            $DeployComponents = $afterReplaceNormalized.Split(',')
            #Write-Host -ForegroundColor White "`$DeployComponents=" -NoNewline
            #Write-Host -ForegroundColor Green "`"$DeployComponents`""      

            #Write-Host -ForegroundColor White "`$DeployComponents.GetType()=" $DeployComponents.GetType().BaseType
            #Write-Host -ForegroundColor White "`$DeployComponents.Count()=" $DeployComponents.Count

            
            Foreach($item in $DeployComponents)
            {
                #Write-Host -ForegroundColor Magenta "[$i][69]" 
                Write-Host -ForegroundColor Yellow "`$item=`"$item`""
                #Write-Host -ForegroundColor Cyan "item.length=" $item.length
                
                If($item.length -eq 1) {$item = [int]$item}
                $itemType = ($item.GetType()).Name 
                #Write-Host -ForegroundColor White "`$itemType=`"$itemType`""
                
                Switch($itemType)
                {
                    String
                    {           
                        #Foreach($key in $DeployConfigObj.Keys.GetEnumerator())
                        Foreach($value in $ComponentHash.Values.GetEnumerator())
                        {                           
                            
                            If($item -eq $value)
                            {
                                #Write-Host -ForegroundColor Green "`$key=`"$key`""
                                #$value = $DeployConfigObj.$key
                                $DeployConfigObj.$value = $true
                                #$DeployConfigObj.$i = $true
                                Write-Host -ForegroundColor Cyan "`$value=`"$value`""
                            }
                        }#Foreach($key in $ComponentHash.Keys)
                    }
                    Int32
                    {
                        Foreach($key in $ComponentHash.Keys)
                        {
                            #Write-Host -ForegroundColor Green "key=" $key -NoNewline
                            #Write-Host -ForegroundColor Cyan "; value=" $ComponentHash.$key
                            If($item -eq $key)
                            {
                                $value = $ComponentHash.$key
                                Write-Host -ForegroundColor Cyan "`$key=`"$key`"" -NoNewline
                                Write-Host -ForegroundColor Yellow "`$value=`"$value`""
                                $DeployConfigObj.$value = $true
                            }
                            #>
                        }#Foreach($key in $ComponentHash.Keys)
                    }
                    Default{
                        $DeployConfigObj.DeployMode = "Full"
                    }#Default
                }#Switch($itemType)                    
                $i++
            }#foreach(DeployComponents) 
        }
        #if single component is chosen:
        Else
        {        
            #Write-Host -ForegroundColor Yellow "`UtilityFunctions.SetDeployConfigObj[933]"
            $item = $afterReplaceNormalized
            #Write-Host -ForegroundColor Cyan "`$item=`"$item`""
            $itemType = ($item.GetType()).Name 
            #Write-Host -ForegroundColor Cyan "item.length=" $item.length
            If($item.length -eq 1) {$item = [int]$item}
            $i=1
            Switch($itemType)
            {
                String
                {  
                   $DeployConfigObj.$item = $true
                }
                Int32
                {  
                    $item = $ComponentHash.$item
                    #Write-Host -ForegroundColor Cyan "`$key=`"$key`"" -NoNewline
                    #Write-Host -ForegroundColor Yellow "`$value=`"$value`""
                    $DeployConfigObj.$item = $true                 
                }
                Default{
                    $DeployConfigObj.DeployMode = "Full"
                }#Default
            }#Switch($itemType)    
        }#Else
    } #if ComponentsChosen ne null
    
    <#
    If($debugFlag){
        Write-Host -ForegroundColor Magenta "`UtilityFunctions.SetDeployConfigObj[973]"                        
        #Write-Host -ForegroundColor Cyan "`$afterReplaceNormalized=`"$afterReplaceNormalized`""                
        #Write-Host -ForegroundColor Cyan "`$DeployComponents=`"$DeployComponents`""
        #Write-Host -ForegroundColor Green "DeployComponents.Count ="$DeployComponents.Count
        
        $Caller = "UtilityFunctions.SetDeployConfigObj[979] AFTER DeployConfigObj="
        PrintObject -Object $DeployConfigObj -Caller $Caller   
    }#debugFlag #>
         
    return $DeployConfigObj
}#SetDeployConfigObj


SetDeployConfigObj -ComponentsChosen $ComponentsChosen