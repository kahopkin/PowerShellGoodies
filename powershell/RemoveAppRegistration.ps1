#RemoveAppRegistration.ps1

#

<#
This script removes app registrations, either Owned ones or specified by name
#>
Function global:RemoveAppRegistration{
 Param(            
     [Parameter(Mandatory = $false)] [String] $AppName    
    ,[Parameter(Mandatory = $false)] [String] $OwnedApplication    
 )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START RemoveAppRegistration *****************"        
    Write-Host -ForegroundColor Yellow "OwnedApplication: " $OwnedApplication
    
    $i = 0
    if($OwnedApplication -eq $true)
    {
        $AdApplications = Get-AzADApplication -OwnedApplication
        Write-Host -ForegroundColor Yellow "AppReg count: " $AdApplications.Count
        foreach($appreg in $AdApplications) 
        {      
            $i++      
            if($appreg.DisplayName -like 'Data*') 
            {
                  #Write-Host -ForegroundColor Red "[$i]" $appreg.DisplayName " starts with 'Data'"
                  Write-Host -ForegroundColor Red "[$i]" $appreg.DisplayName"; AppId=" $appreg.id 
            } 
            else 
            {
                #Write-Host 'RemoveAppRegistration[$i] $appreg.DisplayName does not start with Data"'
                 Remove-AzADApplication -ObjectId $appreg.id
                 #Write-Host -ForegroundColor Cyan "RemoveAppRegistration[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id 
                 Write-Host -ForegroundColor Cyan "[$i] Deleted " $appreg.DisplayName"; AppId=" $appreg.id 
            }
	       
        }
    }



    $i=0
    Write-Host -ForegroundColor Green "`nAppName.length=" $AppName.Length
    

    if($AppName.Length -ne 0 )
    {
        Write-Host -ForegroundColor Green "AppName= $AppName"
        
        $AdApplications = Get-AzADApplication -DisplayName $AppName   
        Write-Host -ForegroundColor Yellow "RemoveAppRegistration[50] AppReg count:" $AdApplications.Count
        
        foreach($appreg in $AdApplications) 
        {
            $i++
	        #Remove-AzADApplication -ObjectId $appreg.id
            Write-Host -ForegroundColor Cyan "RemoveAppRegistration[$i] Deleted AppReg:" $appreg.DisplayName"; AppId=" $appreg.id 
        }
    }
     else
    {
        Write-Host 'RemoveAppRegistration[61] AppName is null' 
    }
    
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED RemoveAppRegistration *****************"        

} #RemoveAppRegistration

RemoveAppRegistration -OwnedApplication $true 


