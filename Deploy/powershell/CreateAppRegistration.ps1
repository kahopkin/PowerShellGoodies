#CreateAppRegistration

Function global:CreateAppRegistration
{
    Param(
        [Parameter(Mandatory = $true)] [String] $AppName    
      , [Parameter(Mandatory = $true)] $AppRegObj          		
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *** [$today] START CreateAppRegistration FOR $AppName *** "
    $Caller='CreateAppRegistration'

    $object = @{}   
    $object = $AppRegObj
    #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[13] BEFORE Param:AppRegObj"
    #PrintObject -object $object -Caller $Caller
    
    $AdApplication = Get-AzADApplication -DisplayName $AppName    
    

    #create a new Azure Active Directory App Reg
    if (($AdApplication.DisplayName.Length).Equals(0))
    {
        #depending on the name, the app registrations need different configurations.
        #API app registration        
        $WebAppUrl = "https://$AppName.azurewebsites.us"

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
            Write-Host -ForegroundColor Green "CreateAppRegistration[37] newAppRole.DisplayName= " $newAppRole.DisplayName

            $newAppRole = CreateAppRole `
                -AllowedMemberTypes "User" `
                -Description "Standard users of the DTP API" `
                -DisplayName  "DTP Users" `
                -Value "DTP.Users"                
            
            $AppRoles += $newAppRole
            Write-Host -ForegroundColor Green "CreateAppRegistration[46] newAppRole.DisplayName= " $newAppRole.DisplayName
            #create a new Azure Active Directory
            $AdApplication = New-AzADApplication `
                -DisplayName $AppName `
                -SigninAudience "AzureADMyOrg" `
                -AppRole $AppRoles `
                -SPARedirectUri $mySpaApplication.RedirectUris

            #create a client secret key which will expire in two years.
            $AppId = $AdApplication.AppId
            $AppObjectId = $AdApplication.Id
            #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[26] API.AppId:" $AppId
            #Write-Host  -ForegroundColor Cyan  "CreateAppRegistration[27] API.appObjectId:" $AppObjectId

            $appPassword = New-AzADAppCredential -ObjectId $AppObjectId -EndDate (Get-Date).AddYears(2)
            $PlaintextSecretTest = $appPassword.SecretText            
                        
            $object.Add("ApiAppRegName", $AppName) 
            $object.Add("ApiClientId", $AppId)
            $object.Add("ApiClientSecret",$PlaintextSecretTest)
            $object.Add("ApiAppObjectId", $AppObjectId)
            $object.Add("ApiExisting", $false)

            #Configure ApplicationId URI
            SetApplicationIdURI -AppId $AppId 

            "API App Registration Name:	" +	$AppName  >> $OutFile
            "API App Registration ID:	" + $AppId  >> $OutFile
            "API App Registration ObjectID:	" + $AppObjectId  >> $OutFile
            "API App Registration Secret:	" + $PlaintextSecretTest  >> $OutFile            
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
            #Write-Host -ForegroundColor Green "CreateAppRegistration[93] newAppRole.DisplayName= " $newAppRole.DisplayName

            $newAppRole = CreateAppRole `
                -DisplayName  "DTP Users" `
                -Description "Normal users of the DTP web application" `
                -Value "DTP.Users" `
                -AllowedMemberTypes "User"
            
            $AppRoles += $newAppRole
						
            #Create the App Registration
            $AdApplication = New-AzADApplication `
                -DisplayName $AppName `
                -SigninAudience "AzureADMyOrg" `
                -AppRole $AppRoles `
                -SPARedirectUri $mySpaApplication.RedirectUris

            $AppId = $AdApplication.AppId
            $AppObjectId = $AdApplication.Id
                        
            $object.Add("WebAppRegName", $AppName) 
            $object.Add("WebClientId", $AppId)
            $object.Add("WebAppObjectId", $AppObjectId)
            $object.Add("WebExisting", $false)

            #Write-Host -ForegroundColor Cyan  -BackgroundColor Black "[120] WebClient: " $AdApplication.DisplayName
            "WebSite App Registration Name:	" +	$AppName  >> $OutFile
            "WebSite App Registration ID:	" + $AppId  >> $OutFile
            "WebSite App Registration ObjectID:	" + $AppObjectId  >> $OutFile            		            
            			
        }#else      
    }
    #EXISTING APP REGISTRATION
    else
	{
        Write-Host -ForegroundColor Red  -BackgroundColor Black "CreateAppRegistration[130] EXISTING app registration:" $AdApplication.DisplayName       
    }
    
    $json = ConvertTo-Json $object

    $json > $OutFileJSON 
    
    #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[171] AFTER:object: **************************"
    #PrintObject -object $object -Caller $Caller

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n *** [$today] EXITING CreateAppRegistration for $AppName *** "
    
    return $object
} #end of func CreateAppRegistration
