#UtilityFunctions
Function global:IngestJsonFile{
Param(
      [Parameter(Mandatory = $true)] [String]$OutFileJSON    
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n`t`t[$today] START IngestJsonFile "
    
    $Hashtable = [ordered]@{}
    if (Test-Path $OutFileJSON) 
    {
        $FullPath = Get-ChildItem -Path $OutFileJSON | select FullName
        Write-Host "RunDeployment.IngestJsonFile[319] jsonFileName.FullPath: " $FullPath.FullName        
        #Write-Host "RunDeployment.IngestJsonFile[342] File: $OutFileJSON Exists"
                
        $json = Get-Content $OutFileJSON | Out-String | ConvertFrom-Json
        #Write-Host "RunDeployment.IngestJsonFile[349] json.Tenant:" $json.Tenant

        $Hashtable = [ordered]@{
            Tenant = $json.Tenant;
            TenantId = $json.TenantId;
            SubscriptionId = $json.SubscriptionId ;
            FileExists = $true;       
	        ApiAppRegName = $json.ApiAppRegName;
	        ApiClientId = $json.ApiClientId;
	        ApiClientSecret = $json.ApiClientSecret;
	        ApiAppObjectId = $json.ApiAppObjectId;
            ApiServicePrincipalId="ApiServicePrincipalId"
            ApiExisting=$true;
	        WebAppRegName = $json.WebAppRegName;
	        WebClientId = $json.WebClientId;
	        WebAppObjectId = $json.WebAppObjectId
            WebClientServicePrincipalId = "WebClientServicePrincipalId"
            WebExisting=$true
        }      
    }
    else
    {
        Write-Host -ForegroundColor Yellow "!!RunDeployment.IngestJsonFile[345] $jsonFileName Doesn't Exists, Creating object"
        $Hashtable = [ordered]@{
            Tenant = $Tenant;
            TenantId = $TenantId;
            SubscriptionId = $SubscriptionId;
            FileExists = $false;       	       
            ApiAppRegName = "ApiAppRegName";
	        ApiClientId ="ApiClientId";
	        ApiClientSecret = "ApiClientSecret";
	        ApiAppObjectId = "ApiAppObjectId";
            ApiServicePrincipalId="ApiServicePrincipalId";
            ApiExisting=$false;
	        WebAppRegName = "WebAppRegName";
	        WebClientId = "WebClientId";
	        WebAppObjectId = "WebAppObjectId";
            WebClientServicePrincipalId = "WebClientServicePrincipalId"
            WebExisting=$false
        }  
    }#else    

    #$Caller='IngestJsonFile[365]'
    #PrintObject -object $Hashtable -Caller $Caller
    #PrintHashTable -object $AppRegObj -Caller $Caller

    $json = ConvertTo-Json $Hashtable
    $json > $OutFileJSON	
    																					
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`t`t[$today] FINISHED IngestJsonFile `n"

    return $Hashtable
}#IngestJsonFile


#$Caller=''
Function global:PrintObject{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $true)] [string] $Caller

    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n`t`t[$today] START $Caller.PrintObject Caller "
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    {         
        write-host  -ForegroundColor Yellow -BackgroundColor Black "[$i]" $item.name "=" $item.value
        $i++       
    }

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`t`t[$today] FINISHED $Caller.PrintObject`n "
}#PrintObject


#$Caller=''
Function global:PrintHashTable{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $true)] [string] $Caller

    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHashTable: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    foreach ($item in $object.GetEnumerator()) 
    {         
        write-host -ForegroundColor Cyan $item.name "="""$item.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHashTable $Caller"
}#PrintHashTable