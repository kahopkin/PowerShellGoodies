#UtilityFunctions
<#
#
#>

Function global:WriteJsonFile{
    Param(
        [Parameter(Mandatory = $true)] [String]$FilePath    
      , [Parameter(Mandatory = $true)] $CustomObject    
    )
    
    Write-Debug "UtilityFunctions.WriteJsonFile[11]"

    <#If($debugFlag)
    {
        $Caller='UtilityFunctions.WriteJsonFile[15]'
        #PrintObject -object $CustomObject -Caller $Caller
        #PrintHash -object $CustomObject -Caller $Caller
    }#>
    
    $json = ConvertTo-Json $CustomObject
    $json > $FilePath

}#WriteJsonFile

Function global:PrintLogInfo 
{
    Param(       
          [Parameter(Mandatory = $true)] [Object] $DeployObject        
         #,[Parameter(Mandatory = $false)] [string] $Solution
    )
    
    Write-Debug ("UtilityFunctions.PrintLogInfo[31] DeployObject.Solution:" + $DeployObject.Solution )
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Red "UtilityFunctions.PrintLogInfo[34] DeployObject.Solution:" $DeployObject.Solution 
    }#>

    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "`t`t`t FILES CREATED AND USED (PARAMETER FILES, ETC):"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor White "JSON output file:"
    Write-Host -ForegroundColor Yellow $DeployInfo.OutFileJSON
    Write-Host -ForegroundColor White "Output Log file:"
    Write-Host -ForegroundColor Yellow $DeployInfo.LogFile
    
    if( ($DeployObject.Solution -eq "Transfer") -or ($DeployObject.Solution -eq "All"))
    {    
        Write-Host -ForegroundColor White "DTP Custom Role Definition file:"
        Write-Host -ForegroundColor Yellow $TransferAppObj.RoleDefinitionFile
    }
    if(($DeployObject.Solution -eq "Pickup") -or ($DeployObject.Solution -eq "All"))
    {
        Write-Host -ForegroundColor White "DPP Custom Role Definition file:"
        Write-Host -ForegroundColor Yellow $PickupAppObj.RoleDefinitionFile
    }    
    
    Write-Host -ForegroundColor White "BICEP Parameter file:"
    Write-Host -ForegroundColor Yellow $DeployObject.TemplateParameterFile
    Write-Host -ForegroundColor Yellow "================================================================================"
   <# 
    "================================================================================"						>> $DeployInfo.LogFile
    "`t`t`t FILES CREATED AND USED (PARAMETER FILES, ETC):"													>> $DeployInfo.LogFile
    "`nJSON output file:"																					>> $DeployInfo.LogFile
    $DeployInfo.OutFileJSON																					>> $DeployInfo.LogFile
    "`nLog file:"																							>> $DeployInfo.LogFile
    $DeployInfo.LogFile																						>> $DeployInfo.LogFile
    "`nCustom Role Definition files:"																		>> $DeployInfo.LogFile
    $TransferAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    $PickupAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    "`nBICEP Parameter file:"																				>> $DeployInfo.LogFile
    $DeployInfo.TemplateParameterFile																		>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
    #>
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Green "`n================================================================================"
	Write-Host -ForegroundColor Green "[$today] STARTING DEPLOYMENT ..."
	Write-Host -ForegroundColor Green "================================================================================`n"    
    <#
	"================================================================================" 	>> $DeployInfo.LogFile
    "[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!" 							>> $DeployInfo.LogFile
    "================================================================================" 	>> $DeployInfo.LogFile
	#>
}#PrintLogInfo


Function global:PrintDeployDuration 
{
    Param(  
        [Parameter(Mandatory = $true)] [Object] $DeployObject
    )
   
    Write-Debug "UtilityFunctions.PrintDeployDuration[91]"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #$global:EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $DeployObject.EndTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $DeployObject.Duration = New-TimeSpan -Start $DeployObject.StartTime -End $DeployObject.EndTime 
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "UtilityFunctions.PrintDeployDuration[95] `$DeployObject.StartTime=" $DeployObject.StartTime
        Write-Host -ForegroundColor Magenta "UtilityFunctions.PrintDeployDuration[96] `$DeployObject.EndTime=" $DeployObject.EndTime
        Write-Host -ForegroundColor Magenta "UtilityFunctions.PrintDeployDuration[97] `$DeployObject.Duration=" $DeployObject.Duration
      
    }#>   

    $DeployObject.Duration = New-TimeSpan -Start $DeployObject.StartTime -End $DeployObject.EndTime
    <#If($debugFlag)
    {
        Write-Host -ForegroundColor Magenta "UtilityFunctions.PrintDeployDuration[102] `$DeployObject.StartTime=" $DeployObject.StartTime
        Write-Host -ForegroundColor Magenta "UtilityFunctions.PrintDeployDuration[103] `$DeployObject.EndTime=" $DeployObject.EndTime
        Write-Host -ForegroundColor Magenta "UtilityFunctions.PrintDeployDuration[104] `$DeployObject.Duration=" $DeployObject.Duration
    }#>
   
    Write-Host -ForegroundColor Cyan "================================================================================" 
	Write-Host -ForegroundColor Cyan "[$today] COMPLETED DEPLOYMENT:" $DeployObject.Solution
    Write-Host -ForegroundColor Cyan "DEPLOYMENT DURATION [HH:MM:SS]:" $DeployObject.Duration
	Write-Host -ForegroundColor Cyan "================================================================================"  
    
    "================================================================================"	>> $DeployInfo.LogFile
    "[$today] COMPLETED DEPLOYMENT " + $DeployObject.Solution							>> $DeployInfo.LogFile
    "DEPLOYMENT DURATION [HH:MM:SS]:" + $DeployObject.Duration							>> $DeployInfo.LogFile
    "================================================================================" 	>> $DeployInfo.LogFile 
	#>
}#PrintDeployDuration


Function global:PickAZCloud
{    
    #Write-Debug -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickAZCloud"	
    Write-Debug "START UtilityFunctions.PickAZCloud[143]"	
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"            
	<#"================================================================================"	>> $DeployInfo.LogFile
	"[$today] CONNECT TO AZURE CLOUD..." 												>> $DeployInfo.LogFile
	"================================================================================"  >> $DeployInfo.LogFile
	#>
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "[$today] CONNECT TO AZURE CLOUD..."
    Write-Host -ForegroundColor Cyan "================================================================================"    
    Write-Host -ForegroundColor White "Choose the Azure Cloud to log in, then press Enter:"

    $CloudArr= [System.Collections.ArrayList]::new()
    $CloudArr = Get-AzEnvironment 

    $CloudStringArr = [System.Collections.ArrayList]::new()    
    $i=1           
    foreach($item in $CloudArr)
    {           
        #Write-Host -ForegroundColor Cyan "item.Name=" $item.Name
        $item = $item.Name -csplit '(?<!^)(?=[A-Z])' -join ' '
        #Write-Host "`$item=`"$item`""
        $item = $item.Replace("U S","US")
        Write-Host -ForegroundColor Yellow "[ $i ] : $item"        
        #$item['ProperName', $item]
        [void]$CloudStringArr.Add($i)
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ C ] : Provide Custom Environment String"
    [void]$CloudStringArr.Add("C")
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
    [void]$CloudStringArr.Add("X")

    $AzCloud = Get_AZCloud -CloudArr $CloudArr -CloudStringArr $CloudStringArr
    Write-Host -ForegroundColor Green "`nYour Selection:`"$AzCloud`" Cloud`n"
    #"`nSelected Cloud:" + $AzCloud  + " Cloud" >> $DeployInfo.LogFile

     return $AzCloud
}


Function global:Get_AZCloud
{
    Param(
        [Parameter(Mandatory = $true)] [object[]] $CloudArr
        ,[Parameter(Mandatory = $true)] [string[]] $CloudStringArr
    )
    
    Write-Debug "UtilityFunctions.Get_AZCloud[190]"

    $cloudIndex = Read-Host "Enter Az Cloud Selection"
    $cloudIndex = $cloudIndex.ToUpper()

    If( ($cloudIndex -lt $CloudStringArr.Count) -or ($cloudIndex -eq "X") -or ($cloudIndex -eq "C") )
    {
        Switch ($cloudIndex)
	    {       
            X 
            {
                Write-Host -ForegroundColor Red "You chose to Quit... Try again later ...." 
                exit(1)
            }
            C
            {
                $cloud = Read-Host "Enter Custom Azure Cloud Environment String"
            }        
		    Default 
            {            
                $cloud = $CloudArr[$cloudIndex-1]    
                #Write-Host -ForegroundColor Cyan "Get_AZCloud[91] Cloud=" $cloud
    
            }
	    }
    }
    Else
    {
        Write-Host -ForegroundColor Red "INPUT NOT VALID, TRY AGAIN..." 
        $cloud = Get_AZCloud
    }

     #Write-Host -ForegroundColor Cyan "Get_AZCloud[100] Cloud=" $cloud
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"    
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_AZCloud `$cloud=`"$cloud`" `n"
	return $cloud
}


Function global:PickSubscription  
{    
    Write-Debug "UtilityFunctions.PickSubscription[232]"
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickSubscription"
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tCHOOSE SUBSCRIPTION TO LOG IN..."
    Write-Host -ForegroundColor Cyan "================================================================================" 	
    Write-Host -ForegroundColor White "Press the letter in the bracket to choose Subscription, then press Enter"
    Write-Host -ForegroundColor Yellow "[ Y ] : Proceed with current subscription:" $AzureContext.Subscription.Name
    Write-Host -ForegroundColor Yellow "[ C ] : Change subscription"
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
    
    $choice = Read-Host "Enter Selection"
    #Write-Host -ForegroundColor Cyan 'UtilityFunctions.PickSubscription[610] Subscription choice:' $choice
    Switch($choice){
        Y{
            
            #get current logged in context
            $global:AzureContext = Get-AzContext
            $currContextTenantId = $AzureContext.Subscription.TenantId
            $DeployInfo.Environment = $AzureContext.Environment.Name
            $DeployInfo.REACT_APP_GRAPH_ENDPOINT = $AzureContext.Environment.ExtendedProperties.MicrosoftGraphEndpointResourceId + "v1.0/me"
                       
            #$currContextHomeTenantId = $AzureContext.Subscription.HomeTenantId
            #$currContextSubscriptionId = $Azureontext.Subscription.Id        
            #$currContextSubscriptionName = $AzureContext.Subscription.Name
            
            $DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
            $DeployInfo.SubscriptionName = $AzureContext.Subscription.Name

            $SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId
            $DeployInfo.TenantName = $SubscriptionTenant.Name
            $DeployInfo.TenantId = $SubscriptionTenant.Id

            #Write-Host -ForegroundColor Yellow 'UtilityFunctions.PickSubscription[631] AzureContext:' $AzureContext.Subscription.Name
            #Write-Host -ForegroundColor Yellow 'UtilityFunctions.PickSubscription[632] AzureContext:' $AzureContext.Subscription.Name

            Write-Host -ForegroundColor Green "================================================================================"
            Write-Host -ForegroundColor Green "`t`t`t`t`t`t`tCURRENT CONTEXT:"
            Write-Host -ForegroundColor Green "================================================================================"
            Write-Host -ForegroundColor Cyan  "Tenant:" $DeployInfo.TenantName
            Write-Host -ForegroundColor Cyan  "TenantId:" $DeployInfo.TenantId
            Write-Host -ForegroundColor Cyan  "Subscription:" $DeployInfo.SubscriptionName
            Write-Host -ForegroundColor Cyan  "SubscriptionId:" $DeployInfo.SubscriptionId
            Write-Host -ForegroundColor Green "================================================================================"
           <#
		   "================================================================================"	>> $DeployInfo.LogFile
            "`t`t`t`t`t`t`tCURRENT CONTEXT:"													>> $DeployInfo.LogFile
            "================================================================================"	>> $DeployInfo.LogFile
            "Tenant:" + $DeployInfo.TenantName													>> $DeployInfo.LogFile
            "TenantId:" + $DeployInfo.TenantId													>> $DeployInfo.LogFile
			"Subscription:" + $DeployInfo.SubscriptionName										>> $DeployInfo.LogFile
			"SubscriptionId:" + $DeployInfo.SubscriptionId										>> $DeployInfo.LogFile
			"================================================================================"	>> $DeployInfo.LogFile
			#>
            Set-AzContext -Subscription $DeployInfo.SubscriptionId
            #Write-Host -ForegroundColor Green "Context is: " 
            Get-AzContext
        }
        C{
            #Write-Host -ForegroundColor Yellow 'choice:' $choice
            ConnectToSpecSubsc -Environment $AzCloud #-MgEnvironment $MgEnvironment    
            #ConnectToSpecSubsc -Environment $AzCloud -TenantId $SubscriptionTenant.Id -SubscriptionId $currContextSubscriptionId
        }
        X{
            "Quitting..." 
            exit(1)
            }
    }
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.PickSubscription`n"
    #return 
}#PickSubscription

Function global:ConnectToSpecSubsc{
    Param(
        [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$TenantId  
        , [Parameter(Mandatory = $true)] [String]$SubscriptionId      
        #, [Parameter(Mandatory = $false)] [String]$MgEnvironment        
    )

    Write-Debug "UtilityFunctions.ConnectToSpecSubsc[313]"
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "[$today] Start ConnectToMSGraph.ConnectToSpecSubsc"
    #Write-Host -ForegroundColor Cyan "Environment: " $DeployInfo.Environment
    #Write-Host -ForegroundColor Cyan "TenantId: " $DeployInfo.TenantId
    #Write-Host -ForegroundColor Cyan "SubscriptionId: " $SubscriptionId
    #Write-Host -ForegroundColor Cyan "MgEnvironment: " $MgEnvironment

    $AzConnection = Connect-AzAccount -Tenant $DeployInfo.TenantId -Environment $DeployInfo.Environment -SubscriptionId $DeployInfo.SubscriptionId 
    $AzureContext = Get-AzContext
    #Write-Host -ForegroundColor Green "Context=" $AzureContext.Environment
    $DeployInfo.Environment = $AzureContext.Environment.Name
    $DeployInfo.ActiveDirectoryAuthority = $AzureContext.Environment.ActiveDirectoryAuthority
    $DeployInfo.SubscriptionId = $AzureContext.Subscription.Id
    $DeployInfo.SubscriptionName = $AzureContext.Subscription.Name
    $SubscriptionTenant = Get-AzTenant -TenantId $AzureContext.Subscription.HomeTenantId        
    $DeployInfo.TenantName = $SubscriptionTenant.Name
    $DeployInfo.TenantId = $SubscriptionTenant.Id

    #Connect-MgGraph -Environment $DeployInfo.MgEnvironment -ErrorAction Stop

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green "[$today] CONNECTED to $AzureContext.Environment.Name `n"    
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: ConnectToMSGraph.ConnectToSpecSubsc`n"
}

Function global:PickAzRegion
{
    Write-Debug "UtilityFunctions.PickAzRegion[340]"

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickAzRegion"       
    #Get all az regions for the cloud chosen
    $GeographyGroupArr = Get-AzLocation `
                        | Select Location, DisplayName, GeographyGroup `
                        | Sort-Object -Property  Location 
    Switch($AzCloud)
    {
        #Commercial Cloud:
        AzureCloud
        {
            #$GeoGroup = Pick_GeoGroup -GeographyGroupArr $GeographyGroupArr
           #Select all the unique georgaphy groups:
            $UniqueGeoGroups = $( 
            foreach ($geoGroup in $GeographyGroupArr) 
            {
                $geoGroup.GeographyGroup
            }) | Sort-Object | Get-Unique

            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE GEOGRAPHY GROUP:"
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor White "Press the number in the bracket to choose GEOGRAPHY GROUP, then press Enter:"   
            
            $i=0            
            foreach($group in $UniqueGeoGroups)
            {                
                Write-Host -ForegroundColor Yellow "[ $i ] : $group "
                $i++
            }
            Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  

            $GeoGroup = Read-Host "Enter Selection"
            If($GeoGroup -match "x") {
                    "Quitting..." 
                    exit(1)
            }

            Write-Host -ForegroundColor Green "`nYour Selection: " $UniqueGeoGroups[$GeoGroup] "`n"
            #"`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] >> $DeployInfo.LogFile

            $LocationArr = $GeographyGroupArr `
                        | select Location, DisplayName, GeographyGroup `
                        | Where-Object -Property GeographyGroup -eq $UniqueGeoGroups[$GeoGroup] `
                        | Sort-Object -Property  GeographyGroup 

            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE REGION:"
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host "Press the number in the bracket to choose REGION:"

            $i=0 
            foreach ($location in $LocationArr)
            {
                Write-Host -ForegroundColor Yellow "[ $i ] :" $location.DisplayName 
                $i++
            }
            Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
            
            $LocationIndex =  Read-Host "Enter Selection"
            #Write-Host "UtilityFunctions.PickAzRegion[764] LocationArr.Length:" $LocationArr.Length
            #Write-Host "UtilityFunctions.PickAzRegion[765] LocationIndex:" $LocationIndex
            if($LocationIndex -le $LocationArr.Length)
                    {
                        $Location = $LocationArr[$LocationIndex].toLower()
                    }
            #Write-Host "UtilityFunctions.PickAzRegion[770] LocationIndex:"$LocationIndex
            #Write-Host "UtilityFunctions.PickAzRegion[771] Location:"$LocationArr[$LocationIndex].Location
            Switch($locationIndex)
            {
                X {
                    "Quitting..." 
                    exit(1)
                }
			    Default 
                {
                    $Location = $LocationArr[$LocationIndex].toLower()
                }
            }          
            <#
            $i=0
            foreach ($location in $GeographyGroupArr)
            {
                Write-Host -ForegroundColor Yellow "GeographyGroupArr[$i] :" $location.Location 
                $i++
            }
            #>
             Write-Host -ForegroundColor Green "`nYour Selection:" $LocationArr[$LocationIndex].DisplayName "Region`n"
            #"`nYour Selection:" + $LocationArr[$LocationIndex].DisplayName + "Region" >> $DeployInfo.LogFile
        }
        AzureUSGovernment
        {
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE REGION:"
            Write-Host -ForegroundColor Cyan "================================================================================"
            Write-Host "Press the number in the bracket to choose REGION:"
            $i=0
            foreach ($location in $GeographyGroupArr)
            {
                Write-Host -ForegroundColor Yellow "[ $i ] :" $location.DisplayName 
                $i++
            }
            Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
            
            $Location = Get_Region
            Write-Host -ForegroundColor Green "`nYour Selection:" ($Location.DisplayName).ToUpper() "Region`n"
            #"`nSelected Region:" + $Location.DisplayName + "Region" >> $DeployInfo.LogFile
        }
    }#switch 
    
    <#
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "UtilityFunctions.PickAzRegion[815] [$today] FINISHED: UtilityFunctions.PickAzRegion`n"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "UtilityFunctions.PickAzRegion[816] Location.DisplayName="$Location.DisplayName
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "UtilityFunctions.PickAzRegion[817] DeployInfo.Location="$DeployInfo.Location
	#>
   return $Location.Location
}#PickAzRegion

Function global:Pick_GeoGroup 
{
    Param(
          [Parameter(Mandatory = $true)] [object]$GeographyGroupArr
    )

    Write-Debug "UtilityFunctions.Pick_GeoGroup[468]"
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Pick_GeoGroup"
              
    #Select all the unique georgaphy groups:
    $UniqueGeoGroups = $( 
            foreach ($geoGroup in $GeographyGroupArr) 
            {
                $geoGroup.GeographyGroup
            }) | Sort-Object | Get-Unique

    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT AZURE GEOGRAPHY GROUP:"
    Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the number in the bracket to choose GEOGRAPHY GROUP, then press Enter:"   
    
    $i=0  
    #list options in UniqueGeoGroups:          
    foreach($group in $UniqueGeoGroups)
    {                
        Write-Host -ForegroundColor Yellow "[ $i ] : $group "
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"

    $LocationArr = Get_GeoGroup -GeographyGroupArr $GeographyGroupArr -UniqueGeoGroups $UniqueGeoGroups
    <#
    $i=0
    foreach ($location in $GeographyGroupArr)
    {
        Write-Host -ForegroundColor Yellow "GeographyGroupArr[$i] :" $location.Location 
        $i++
    }
    #>
    #Pick_Location -LocationArr $LocationArr
    $Location = Get_Region -LocationArr $LocationArr
    #Write-Host "UtilityFunctions.Pick_GeoGroup[863] Location:" $Location

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Pick_GeoGroup`n"
    return $LocationIndex
}#Pick_GeoGroup

Function global:Get_GeoGroup
{
    Param(
          [Parameter(Mandatory = $true)] [object]$GeographyGroupArr,
          [Parameter(Mandatory = $true)] [object]$UniqueGeoGroups 
    )

    Write-Debug "UtilityFunctions.Get_GeoGroup[518]"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_GeoGroup"
    
    $GeoGroup = Read-Host "Enter Selection for GEOGRAPHY GROUP"
    #Write-Host "UtilityFunctions.Get_GeoGroup[881] you selected: " $GeographyGroupArr[$GeoGroup].DisplayName
    Switch ($GeoGroup)
	{       
        X { "Quitting..." 
            exit(1)
        }
        
		Default {
          $LocationArr = $GeographyGroupArr `
                        | select Location, DisplayName, GeographyGroup `
                        | Where-Object -Property GeographyGroup -eq $UniqueGeoGroups[$GeoGroup] `
                        | Sort-Object -Property  GeographyGroup 
                  
        }
	}    
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_GeoGroup`n"
    return $LocationArr
}#Get_GeoGroup

Function global:Pick_Location
{
    Param(
        [Parameter(Mandatory = $false)] [object]$LocationArr 
    )

    Write-Debug "UtilityFunctions.Pick_Location[549]"

    $i = 0 
    foreach ($location in $LocationArr)
    {
        Write-Host -ForegroundColor Yellow "[ $i ] :" $location.DisplayName 
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
    
    $LocationIndex =  Read-Host "Enter Selection"
    Switch($locationIndex){
        X {
            "Quitting..." 
            exit(1)
        }
		Default 
        {
            $Location = $LocationArr[$LocationIndex].Location          
        }
    }
            
    #Write-Host -ForegroundColor White "UtilityFunctions.PickAzRegion[926] Location:" $Location
}#Pick_Location

Function global:Get_Region 
{ 
    Param(
        [Parameter(Mandatory = $false)] [object]$LocationArr 
    )
    
    Write-Debug "UtilityFunctions.Get_Region[580]"
    #>
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_Region"
	$LocationIndex = Read-Host "Enter Selection"
   
    If($LocationIndex -lt $GeographyGroupArr.Count -or $LocationIndex -eq "X")
    {
        Switch ($LocationIndex)
	    {       
            X 
            {
                "Quitting..." 
                exit(1)
            }        
		    Default 
            {            
                $region = $GeographyGroupArr[$LocationIndex]    
            }
	    }
    }
    Else
    {
        Write-Host -ForegroundColor Red "INPUT NOT VALID, TRY AGAIN..." 
        $region = Get_Region
    }

    
    <#    
    Write-Host "UtilityFunctions.Get_Region[962] LocationIndex:" $LocationIndex
    Write-Host "UtilityFunctions.Get_Region[963] region:" $region.DisplayName
    #Write-Host "UtilityFunctions.Get_Region[964] LocationIndex.Type:" $LocationIndex.GetType()
    #Write-Host "UtilityFunctions.Get_Region[320] GeographyGroupArr.Count:" $GeographyGroupArr.Count
    Write-Host "UtilityFunctions.Get_Region[966] GeographyGroupArr.Length:" $GeographyGroupArr.Length
    Write-Host "UtilityFunctions.Get_Region[967] GeographyGroupArr.Count:" $GeographyGroupArr.Count
    Write-Host "UtilityFunctions.Get_Region[968] LocationIndex:" $LocationIndex
 
    #Write-Host -ForegroundColor White -BackgroundColor Black  " UtilityFunctions.Get_Region[970] region: " $region
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_Region`n"
    #>
	return $region
}

Function global:PickCodeEnvironment
{    
    Write-Debug "UtilityFunctions.PickCodeEnvironment[626]"
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickCodeEnvironment"
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT ENVIRONMENT:"
	Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the number in the bracket to choose ENVIRONMENT, then press Enter:"   
    Write-Host -ForegroundColor Yellow "[ 0 ] : TEST" 
	Write-Host -ForegroundColor Yellow "[ 1 ] : DEV"
	Write-Host -ForegroundColor Yellow "[ 2 ] : PROD"
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
        
    #$Environment = Get_CodeEnvironment  
	$DeployInfo.Environment = Get_CodeEnvironment     
    Write-Host -ForegroundColor Green "`nYour Selection:" $DeployInfo.Environment "Environment`n"
    #"`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.PickCodeEnvironment`n"
    return $DeployInfo.Environment
}#PickCodeEnvironment

Function global:Get_CodeEnvironment
{
    Write-Debug "UtilityFunctions.Get_CodeEnvironment[649]"
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_CodeEnvironment"

    $environment = Read-Host "Enter Selection for CODE ENVIRONMENT"    
	Switch ($environment)
	{
       
        0{$environment="Test"}
        1{$environment="Dev"}
        2{$environment="Prod"}
        X { "Quitting..." 
                exit(1)
        }
        Default {
            $environment = Get_CodeEnvironment
        }
    }
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "You Selected: " $environment
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_CodeEnvironment`n"
    return $environment
}#Get_CodeEnvironment

Function global:Pick_Solution
{
    Write-Debug "UtilityFunctions.Pick_Solution[675]"

    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT SOLUTION TYPE:"
	Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the letter in the bracket to choose ENVIRONMENT, then press Enter:"   
    Write-Host -ForegroundColor Yellow "[ 1 ] : Transfer" 
	Write-Host -ForegroundColor Yellow "[ 2 ] : Pickup"	
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
    $DeployInfo.Solution = Get_Solution

}#Pick_Solution

Function global:Get_Solution
{
    Write-Debug "UtilityFunctions.Get_Solution[690]"

    $Solution = Read-Host "Enter Transfer OR PickUp"
    Switch ($Solution)
	{
       
        1{$Solution="Transfer"}
        2{$Solution="Pickup"}                    
        X { "Quitting..." 
                exit(1)
        }
        Default {
            $Solution = Get_Solution
        }
    }#Switch
    return $Solution
}

Function global:PickDeployMode
{
    Write-Debug "UtilityFunctions.PickDeployMode[710]"
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.PickCodeEnvironment"
    Write-Host -ForegroundColor Cyan "================================================================================"
	Write-Host -ForegroundColor Cyan "`t`t`t`t`t`t`tSELECT DEPLOY MODE:"
	Write-Host -ForegroundColor Cyan "================================================================================"
    Write-Host -ForegroundColor White "Press the letter in the bracket to choose DEPLOY MODE, then press Enter:"   
    Write-Host -ForegroundColor Yellow "[ 0 ] : ALL - Deploy both the Transfer and Pickup Solution in your tenant" 
	Write-Host -ForegroundColor Yellow "[ 1 ] : TRANSFER - Will deploy 2 App registrations and the Azure resources "
    Write-Host -ForegroundColor Yellow "`t`tfor the Data Transfer Solution"
	Write-Host -ForegroundColor Yellow "[ 2 ] : PICKUP -  Will deploy 2 App registrations and the Azure resources " 
    Write-Host -ForegroundColor Yellow "`t`tfor the Data Pickup Solution"
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"
        
    #$Environment = Get_CodeEnvironment  
	$DeployInfo.DeployMode = Get_DeployMode     
    Write-Host -ForegroundColor Green "`nYour Selection:" $DeployInfo.DeployMode "DeployMode`n"
    #"`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.PickCodeEnvironment`n"
    return $DeployInfo.DeployMode
}#PickDeployMode

Function global:Get_DeployMode
{
    Write-Debug "UtilityFunctions.Get_DeployMode[735]"
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n[$today] START UtilityFunctions.Get_CodeEnvironment"

    $deployMode = Read-Host "Enter Selection for DEPLOY MODE"    
	Switch ($deployMode)
	{
       
        0{$deployMode="All"}
        1{$deployMode="Transfer"}
        2{$deployMode="Pickup"}
        X { "Quitting..." 
                exit(1)
        }
        Default {
            $deployMode = Get_DeployMode
        }
    }
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "You Selected: " $environment
    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "[$today] FINISHED: UtilityFunctions.Get_DeployMode`n"
    return $deployMode
}#Get_DeployMode

Function global:PrintObject{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller
      , [Parameter(Mandatory = $false)] [string] $FilePath

    )

    Write-Debug "UtilityFunctions.PrintObject[767]"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan "================================================================================`n"
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] START $Caller.PrintObject"
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    #foreach ($item in $object) 
    {         
        Write-Host -ForegroundColor White -BackgroundColor Black "[$i]" $item.name "=" $item.value #"`n"
        #$item.name +"=" + $item.value >> $FilePath
        $i++       
    }

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
    Write-Host -ForegroundColor Cyan "================================================================================`n"
}#PrintObject

Function global:PrintDeployObject{
    Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller      

    )

    Write-Debug "UtilityFunctions.PrintDeployObject[792]"

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan "================================================================================`n"
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] START $Caller.PrintDeployObject"

    $i=0
    foreach ($item in $object.GetEnumerator()) 
    #foreach ($item in $object) 
    {         
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] `$item.name="$item.name
        $currItem = $item.value
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$i] item.value.GetType=" ($item.value).GetType()        
        #Write-Host -ForegroundColor Green -BackgroundColor Black "[$i] currItem.GetType=" $currItem.GetType()
        #Write-Host -ForegroundColor Green -BackgroundColor Black "[$i] currItem.GetType.Name=" $currItem.GetType().Name
        #Write-Host -ForegroundColor Green -BackgroundColor Black "[$i] currItem.GetType.BaseType=" $currItem.GetType().BaseType
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$i] currItem.GetType.BaseType.FullName=" $currItem.GetType().BaseType.FullName
        #Write-Host "[1136] itemType -eq OrderedDictionary:" ($currItem.GetType() -eq "System.Collections.Specialized.OrderedDictionary")
        
        If( $currItem.GetType() -match "System.Collections.Specialized.OrderedDictionary")
        {
            Write-Host -ForegroundColor Magenta "item.name="$item.name            
            foreach($key in $currItem.keys)
            {
                $message = '{0} = {1} ' -f $key, $currItem[$key]
                Write-Host -ForegroundColor Yellow $message
            }          
        }        
        ElseIf($currItem.GetType() -match "System.Management.Automation.PSCustomObject")
        {
            Write-Host -ForegroundColor Red "item.name="$item.name
            #Write-Host -ForegroundColor Red "[1246][$i] `$item.GetType=" $item.GetType()
            #Write-Host -ForegroundColor Red "[1246][$i] `$item.value.GetType()=" $item.value.GetType()
            #Write-Host -ForegroundColor Red "[1246][$i] `$item.value=" $item.value
            $currItem.PSObject.Properties | ForEach-Object {
                #$_.Name
                #$_.Value
                Write-Host -ForegroundColor Cyan $_.Name "=" $_.Value
            }
        }
        Else
        {
            Write-Host -ForegroundColor Green  $item.name "=" $item.value
        }
        #>
        #$item.name +"=" + $item.value >> $FilePath
        $i++       
    }

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
    Write-Host -ForegroundColor Cyan "================================================================================`n"
}#PrintDeployObject


Function global:PrintHash
{
    Param(
        [Parameter(Mandatory = $true)]  [Object] $Object
      , [Parameter(Mandatory = $false)] [string] $Caller

    )

    Write-Debug "UtilityFunctions.PrintHash[855]"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    foreach ($item in $Object)    
    {         
        Write-Host -ForegroundColor Cyan $item.name "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHash

Function global:PrintHashKeyValue
{
    Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller

    )

    Write-Debug "UtilityFunctions.PrintHashKeyValue[878]"

    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    foreach ($item in $object.GetEnumerator())    
    {   
        write-host -ForegroundColor Cyan $item.key "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHashKeyValue


Function global:PrintSubscription
{
    Param(
        [Parameter(Mandatory = $true)] [object] $object
    )

    Write-Debug "UtilityFunctions.PrintSubscription[901]"

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n[$today] START "
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    {         
        Write-Host -ForegroundColor White $item.name "=" $item.value        
        $i++       
    }
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
}#PrintSubscription

Function global:PrintCloudOptionsStrArr
{
    Param(
        [Parameter(Mandatory = $true)] [string[]] $ValueArr      
    )

    Write-Debug "UtilityFunctions.PrintCloudOptionsStrArr[921]"

    $i=0            
    foreach($item in $ValueArr)
    {   
        #$camelString = $item
        $item = $item -csplit '(?<!^)(?=[A-Z])' -join ' '
        Write-Host -ForegroundColor Yellow "[ $i ] : $item"
        $item['ProperName', $item]
        $i++
    }
    Write-Host -ForegroundColor Yellow "[ X ] : Cancel and Quit"  
    #return $ValueArr
}#PrintCloudOptionsStrArr


Function global:ConvertFrom-SecureString-AsPlainText
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.Security.SecureString]
        $SecureString
    )

    Write-Debug "UtilityFunctions.ConvertFrom-SecureString-AsPlainText[949]"

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
    $PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
    $PlainTextString;
}

Function global:WriteLogFile
{
    Write-Debug "UtilityFunctions.WriteLogFile[958]"

    "================================================================================" 	>  $DeployInfo.LogFile
    "[$today] WELCOME TO THE DATA TRANSFER APP DEPLOYMENT!!" 							>> $DeployInfo.LogFile
    "================================================================================"	>> $DeployInfo.LogFile
    
    "================================================================================"						>> $DeployInfo.LogFile
    "`t`t`t FILES CREATED AND USED (PARAMETER FILES, ETC):"													>> $DeployInfo.LogFile
    "`nJSON output file:"																					>> $DeployInfo.LogFile
    $DeployInfo.OutFileJSON																					>> $DeployInfo.LogFile
    "`nLog file:"																							>> $DeployInfo.LogFile
    $DeployInfo.LogFile																						>> $DeployInfo.LogFile
    "`nCustom Role Definition files:"																		>> $DeployInfo.LogFile
    $TransferAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    $PickupAppObj.RoleDefinitionFile																		>> $DeployInfo.LogFile
    "`nBICEP Parameter file:"																				>> $DeployInfo.LogFile
    $DeployInfo.TemplateParameterFile																		>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile

    "================================================================================"	>> $DeployInfo.LogFile
	"[$today] CONNECTED TO AZURE CLOUD..." 												>> $DeployInfo.LogFile
	"================================================================================"  >> $DeployInfo.LogFile
    "Selected Cloud:" + $AzCloud  + " Cloud" >> $DeployInfo.LogFile

#"`nSelected Cloud:" + $AzCloud  + " Cloud" >> $DeployInfo.LogFile
    "`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] >> $DeployInfo.LogFile
    "`nYour Selection:" + $LocationArr[$LocationIndex].DisplayName + "Region" >> $DeployInfo.LogFile
    "`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
"`nSelected Region: " + $UniqueGeoGroups[$GeoGroup] >> $DeployInfo.LogFile
#"`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
    "You are currently logged in context:"																	>> $DeployInfo.LogFile
    "Tenant Name:" + $DeployInfo.TenantName																	>> $DeployInfo.LogFile
    "Tenant Id:" + $DeployInfo.TenantId																		>> $DeployInfo.LogFile
    "Subscription:" + $DeployInfo.SubscriptionName															>> $DeployInfo.LogFile
    "Subscription Id:" + $DeployInfo.SubscriptionId															>> $DeployInfo.LogFile
    "================================================================================"						>> $DeployInfo.LogFile
	
	"================================================================================"	>> $DeployInfo.LogFile
	"`t`t`t`t`t`t`tCURRENT CONTEXT:"													>> $DeployInfo.LogFile
	"================================================================================"	>> $DeployInfo.LogFile
	"Tenant:" + $DeployInfo.TenantName													>> $DeployInfo.LogFile
	"TenantId:" + $DeployInfo.TenantId													>> $DeployInfo.LogFile
	"Subscription:" + $DeployInfo.SubscriptionName										>> $DeployInfo.LogFile
	"SubscriptionId:" + $DeployInfo.SubscriptionId										>> $DeployInfo.LogFile
	"================================================================================"	>> $DeployInfo.LogFile

	"`nSelected Region:" + $Location.DisplayName + "Region" >> $DeployInfo.LogFile    
    "`nSelected Application Environment:" + $DeployInfo.Environment >> $DeployInfo.LogFile
    "`nApp Name:" + $DeployInfo.AppName >> $DeployInfo.LogFile
    "`Sql Admin Name:" + $DeployInfo.SqlAdmin >> $DeployInfo.LogFile
    "`Sql Admin PwdP lainText:" + $DeployInfo.SqlAdminPwdPlainText >> $DeployInfo.LogFile    
	
	"================================================================================"	>> $DeployInfo.LogFile
    "[$today] COMPLETED DEPLOYMENT "													>> $DeployInfo.LogFile
    "DEPLOYMENT DURATION [HH:MM:SS]:" + $Duration										>> $DeployInfo.LogFile
    "================================================================================" 	>> $DeployInfo.LogFile 
    
    "================================================================================"	>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": ADD API PERMISSION: " + $PermissionParentName	>> $DeployInfo.LogFile
    "================================================================================"	>> $DeployInfo.LogFile
    
    "================================================================================"								>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": ADDING SUBSCRIPTION SCOPE CUSTOM ROLE DEFINITION:" + $RoleAssignmentName	>> $DeployInfo.LogFile
    "================================================================================"								>> $DeployInfo.LogFile
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    "================================================================================" 			>> $DeployInfo.LogFile
    "Step" + $DeployInfo.StepCount + ": CREATE RESOURCE GROUP: $DeployObject.ResourceGroupName" >> $DeployInfo.LogFile
    "================================================================================`n"		>> $DeployInfo.LogFile
}#WriteLogFile


function ConvertPSObjectToHashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

	Write-Debug "UtilityFunctions.ConvertPSObjectToHashtable[1037]"

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject])
        {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties)
            {
                $hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
            }

            $hash
        }
        else
        {
            $InputObject
        }
    }
}



Function global:HashFromJson
{
    Write-Debug "UtilityFunctions.HashFromJson[1073]"

    $global:TransferAppObj = [ordered]@{
            AppName = $json.TransferAppObj.AppName;
            Environment = $json.TransferAppObj.Environment;            
            Location = $json.TransferAppObj.Location;
            Solution = $json.TransferAppObj.Solution;
            ResourceGroupName = $json.TransferAppObj.ResourceGroupName;
            RoleDefinitionId = $json.TransferAppObj.RoleDefinitionId;
            RoleDefinitionFile = $json.TransferAppObj.RoleDefinitionFile;            
            BicepFile = $json.TransferAppObj.BicepFile;           
            
            APIAppRegName = $json.TransferAppObj.APIAppRegName;
            APIAppRegAppId = $json.TransferAppObj.APIAppRegAppId;
            APIAppRegObjectId = $json.TransferAppObj.APIAppRegObjectId;
            APIAppRegClientSecret = $json.TransferAppObj.APIAppRegClientSecret;
            APIAppRegServicePrincipalId = $json.TransferAppObj.APIAppRegServicePrincipalId;            
            APIAppRegExists = $json.TransferAppObj.APIAppRegExists;

            ClientAppRegName = $json.TransferAppObj.ClientAppRegName;
            ClientAppRegAppId = $json.TransferAppObj.ClientAppRegAppId;
            ClientAppRegObjectId = $json.TransferAppObj.ClientAppRegObjectId;
            ClientAppRegServicePrincipalId = $json.TransferAppObj.ClientAppRegServicePrincipalId;            
            ClientAppRegExists = $json.TransferAppObj.ClientAppRegExists;
        }#TransferAppObj

        $global:PickupAppObj = [ordered]@{
            AppName = $json.PickupAppObj.AppName;
            Environment = $json.PickupAppObj.Environment;            
            Location = $json.PickupAppObj.Location;
            Solution = $json.PickupAppObj.Solution;
            ResourceGroupName = $json.PickupAppObj.ResourceGroupName;
            RoleDefinitionId = $json.PickupAppObj.RoleDefinitionId;
            RoleDefinitionFile = $json.PickupAppObj.RoleDefinitionFile;
            BicepFile = $json.PickupAppObj.BicepFile;            
            
            APIAppRegName = $json.PickupAppObj.APIAppRegName;
            APIAppRegAppId = $json.PickupAppObj.APIAppRegAppId;
            APIAppRegObjectId = $json.PickupAppObj.APIAppRegObjectId;
            APIAppRegClientSecret = $json.PickupAppObj.APIAppRegClientSecret;
            APIAppRegServicePrincipalId = $json.PickupAppObj.APIAppRegServicePrincipalId;            
            APIAppRegExists = $json.PickupAppObj.APIAppRegExists;
                       
            ClientAppRegName = $json.PickupAppObj.ClientAppRegName;
            ClientAppRegAppId = $json.PickupAppObj.ClientAppRegAppId;
            ClientAppRegObjectId = $json.PickupAppObj.ClientAppRegObjectId;
            ClientAppRegServicePrincipalId = $json.PickupAppObj.ClientAppRegServicePrincipalId;            
            ClientAppRegExists = $json.PickupAppObj.ClientAppRegExists;
            
        }#PickupAppObj

        $global:DeployInfo = [ordered]@{
			CloudEnvironment = $json.CloudEnvironment;
            Location = $json.Location;
			Environment = $json.Environment;
            AppName = $json.AppName;
            SqlAdmin = $json.SqlAdmin;
            SqlAdminPwd = $json.SqlAdminPwd;
            SqlAdminPwdPlainText = $json.SqlAdminPwdPlainText;
            BicepFile = $json.BicepFile;
            OutFileJSON =  $json.OutFileJSON;
            LogFile = $json.LogFile;
            DeploymentName = $json.DeploymentName;
            FileExists = $true;
            
			SubscriptionName = $json.SubscriptionName;
            SubscriptionId = $json.SubscriptionId;
            TenantName = $json.TenantName;
            TenantId = $json.TenantId;
						
            CurrUserName = $json.CurrUserName;
            CurrUserId = $json.CurrUserId;
            CurrUserPrincipalName = $json.CurrUserPrincipalName;            
            MyIP = $json.MyIP;

            StepCount = 1;            
            TemplateParameterFile = $json.TemplateParameterFile;
			ContributorRoleId = $json.ContributorRoleId;
			TransferAppObj = $TransferAppObj;
            PickupAppObj = $PickupAppObj;
            Cloud = $json.Cloud;
        }#DeployInfo
}#HashFromJson
