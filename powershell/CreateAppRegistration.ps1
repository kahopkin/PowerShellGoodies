#CreateAppRegistration

Function global:CreateAppRegistration
{
    Param(
        [Parameter(Mandatory = $true)] [String] $AppName    
      , [Parameter(Mandatory = $true)] $AppRegObj          		
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor DarkCyan -BackgroundColor White "`n  [$today] START CreateAppRegistration FOR $AppName  "
   
    #$Caller='CreateAppRegistration[13] BEFORE Param:AppRegObj'    
    #PrintObject -object $AppRegObj -Caller $Caller
    
    $AdApplication = Get-AzADApplication -DisplayName $AppName    
    $nameLength = ($AdApplication.DisplayName.Length)    
    #Write-Host -ForegroundColor White "CreateAppRegistration[22] AdApplication.Name.Length=" $nameLength

    #create a new Azure Active Directory App Reg
    if (($AdApplication.DisplayName.Length).Equals(0))
    {
        #depending on the name, the app registrations need different configurations.
        #API app registration        
        $WebAppUrl = "https://$AppName.azurewebsites.us"
        $redirectUris = @()
        
        if ($redirectUris -notcontains "$WebAppUrl") {
            $redirectUris += "$WebAppUrl"               
        }
        
        $mySpaApplication = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphSpaApplication
        $mySpaApplication.RedirectUris = $redirectUris

        if ($AppName -match 'api')
        {
            #Create the App Roles at the time of creation
            $AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]             
            $newAppRole = CreateAppRole `
                -AllowedMemberTypes "User" `
                -Description "Admin users of the DTP API" `
                -DisplayName  "DTP API Admins" `
                -Value "DTPAPI.Admins"                 
    
            $AppRoles += $newAppRole
            #Write-Host -ForegroundColor White "CreateAppRegistration[48] newAppRole.DisplayName= " $newAppRole.DisplayName

            $newAppRole = CreateAppRole `
                -AllowedMemberTypes "User" `
                -Description "Standard users of the DTP API" `
                -DisplayName  "DTP Users" `
                -Value "DTPAPI.Users"                
            
            $AppRoles += $newAppRole
            #Write-Host -ForegroundColor White "CreateAppRegistration[57] newAppRole.DisplayName= " $newAppRole.DisplayName
            #create a new Azure Active Directory
            $AdApplication = New-AzADApplication `
                -DisplayName $AppName `
                -SigninAudience "AzureADMyOrg" `
                -AppRole $AppRoles `
                -SPARedirectUri $mySpaApplication.RedirectUris

            
            $AppId = $AdApplication.AppId
            $AppObjectId = $AdApplication.Id
            #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[26] API.AppId:" $AppId
            #Write-Host  -ForegroundColor Cyan  "CreateAppRegistration[27] API.appObjectId:" $AppObjectId
            
            #create a client secret key which will expire in two years.
            $appPassword = New-AzADAppCredential -ObjectId $AppObjectId -EndDate (Get-Date).AddYears(2)
            $PlaintextSecretTest = $appPassword.SecretText            
           
            #Configure ApplicationId URI
            SetApplicationIdURI -AppId $AppId 

            "API App Registration Name:	" +	$AppName  >> $OutFile
            "API App Registration ID:	" + $AppId  >> $OutFile
            "API App Registration ObjectID:	" + $AppObjectId  >> $OutFile
            "API App Registration Secret:	" + $PlaintextSecretTest  >> $OutFile            

            $AppRegObj.ApiAppRegName = $AppName
            $AppRegObj.ApiClientId = $AppId
            $AppRegObj.ApiClientSecret = $PlaintextSecretTest
            $AppRegObj.ApiAppObjectId = $AppObjectId
            $AppRegObj.ApiExisting = $false
            
        }
        #CLIENT APP REGISTRATION
        else
        {             
            #Create the App Roles at the time of creation
            $AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]             
            $newAppRole = CreateAppRole `
                -DisplayName  "DTP Admins" `
                -Description "Admin enabled users of the DTP web application" `
                -Value "DTP.Admins" `
                -AllowedMemberTypes "User"
    
            $AppRoles += $newAppRole
            #Write-Host -ForegroundColor Green "CreateAppRegistration[101] newAppRole.DisplayName= " $newAppRole.DisplayName

            $newAppRole = CreateAppRole `
                -DisplayName  "DTP Users" `
                -Description "Normal users of the DTP web application" `
                -Value "DTP.Users" `
                -AllowedMemberTypes "User"
            
            $AppRoles += $newAppRole
			
            $redirectUris += "http://localhost:3000"
		    $mySpaApplication.RedirectUris = $redirectUris

            #Create the App Registration
            $AdApplication = New-AzADApplication `
                -DisplayName $AppName `
                -SigninAudience "AzureADMyOrg" `
                -AppRole $AppRoles `
                -SPARedirectUri $mySpaApplication.RedirectUris

            $AppId = $AdApplication.AppId
            $AppObjectId = $AdApplication.Id
          
            $AppRegObj.WebAppRegName = $AppName
            $AppRegObj.WebClientId = $AppId            
            $AppRegObj.WebAppObjectId = $AppObjectId
            $AppRegObj.WebExisting = $false

            #Write-Host -ForegroundColor Cyan  -BackgroundColor Black "[120] WebClient: " $AdApplication.DisplayName
            "WebSite App Registration Name:	" +	$AppName  >> $OutFile
            "WebSite App Registration ID:	" + $AppId  >> $OutFile
            "WebSite App Registration ObjectID:	" + $AppObjectId  >> $OutFile            		            
            			
        }#else      
    } #app reg does not exist
    #EXISTING APP REGISTRATION
    else
	{
        Write-Host -ForegroundColor Red  -BackgroundColor Black "CreateAppRegistration[138] EXISTING app registration:" $AdApplication.DisplayName
        
        if($AdApplication.DisplayName.Contains("api"))
        {           
            $appPassword = New-AzADAppCredential -ObjectId $AdApplication.Id -EndDate (Get-Date).AddYears(2)
            $PlaintextSecretTest = $appPassword.SecretText            
            $AppRegObj.ApiAppRegName= $AdApplication.DisplayName
            $AppRegObj.ApiClientId = $AdApplication.AppId
            $AppRegObj.ApiClientSecret= $PlaintextSecretTest
            $AppRegObj.ApiAppObjectId = $AdApplication.Id
            $AppRegObj.ApiExisting= $true
        }
        else
        {            
            $AppRegObj.WebAppRegName = $AdApplication.DisplayName
            $AppRegObj.WebClientId = $AdApplication.AppId            
            $AppRegObj.WebAppObjectId = $AdApplication.Id
            $AppRegObj.WebExisting = $true  
        }
        
        $AppRegObj["FileExists", $true]
        
        #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[170] Updated AppRegObj:"
        #PrintObject -object $AppRegObj -Caller $Caller       
    }#existing app registration
    
    $json = ConvertTo-Json $AppRegObj

    $json > $OutFileJSON 
    
    #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[171] Returning:AppRegObj: "
    #PrintObject -object $AppRegObj -Caller $Caller
    #PrintHashTable -object $AppRegObj -Caller $Caller

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor DarkGreen -BackgroundColor White  "`n  [$today] EXITING CreateAppRegistration for $AppName  "
    
    return $AppRegObj
} #end of func CreateAppRegistration
