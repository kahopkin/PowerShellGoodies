Function global:PrintSubscription{
Param(
        [Parameter(Mandatory = $true)] [object] $object      

    )
    #$today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`n`t`t[$today] START "
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    {         
        Write-Host -ForegroundColor Yellow $item.name "=" $item.value        
        $i++       
    }
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    #Write-Host -ForegroundColor Yellow -BackgroundColor Black "`t`t[$today] FINISHED $Caller.PrintObject`n "
}#PrintSubscription

Function global:ConnectToSpecSubsc{
    Param(
        [Parameter(Mandatory = $true)] [String]$Environment,
        [Parameter(Mandatory = $true)] [String]$TenantId,  
        [Parameter(Mandatory = $true)] [String]$SubscriptionId        
    )
    
   
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "[$today] Start ConnectToSpecSubsc"
    Write-Host -ForegroundColor Cyan "Environment: " $Environment
    Write-Host -ForegroundColor Cyan "TenantId: " $TenantId
    Write-Host -ForegroundColor Cyan "SubscriptionId: " $SubscriptionId
    Connect-AzAccount -Tenant $TenantId -Environment $Environment -SubscriptionId $SubscriptionId 
    $azureContext = Get-AzContext
    Write-Host -ForegroundColor Green "Context=" $azureContext.Environment
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green "[$today] CONNECTED to $azureContext.Environment `n"
}

function Get-Choice
{
	$count=$count+1
	$choice = Read-Host "Enter Selection"
	Switch ($choice)
	{
			A {
                #"Connecting to Azure Cloud."
                $environment = "AzureCloud"
            } 
            G {
                $environment = "AzureUSGovernment"
            }
			X {
                "Quitting..."
                exit(1)
            }
			Default {Get-Choice}
	}
	return $environment
}

    Write-Host ""
    Write-Host "========================================"
    Write-Host "       CONNECT TO AZURE SUBSCRIPTION..."
    Write-Host "========================================"
    Write-Host "Press"    
    Write-Host "A : Azure Cloud"
    Write-Host "G : Azure US Government"
    Write-Host "X : to cancel and quit"    
    
    $Environment = Get-Choice    
    
    Write-Host -ForegroundColor Cyan "Connecting to environment:" $Environment
    Connect-AzAccount -Environment $Environment
    

    $global:subscriptions = Get-AzSubscription
    
    If($subscriptions.Count -gt 1)
    {        
        #$global:TenantId
        Write-Host -ForegroundColor Cyan "You have " $subscriptions.Count " subscriptions...."
        Write-Host -ForegroundColor Cyan "Please pick the right subscription from below list and copy/paste when asked for..."
        $azureContext = Get-AzContext
        foreach($subscription in $subscriptions) 
	    {
            #Write-Host $subscription.Name ", Subscription Id:" $subscription.Id "; Tenant Id: " $subscription.TenantId
            $subscriptionName=$subscription.Name
            $Hashtable = [ordered]@{
                Subscription = """$subscriptionName""";
                TenantId = $subscription.TenantId;                
                SubscriptionId = $subscription.Id;
            }
                     
            PrintSubscription -object $Hashtable
            Write-Host "-------------------------------------------------------"
        }
        Write-Host -ForegroundColor Green "Your current subscription is :" $azureContext.Subscription.Name
        Write-Host -ForegroundColor Green "You are logged in to tenant: " $azureContext.Tenant.Id
        Write-Host -ForegroundColor Yellow "Y : Proceed"
        Write-Host -ForegroundColor Yellow "C : Change subscription"
        $choice = Read-Host "Enter Selection"
        Switch($choice){
            Y{
                #Write-Host -ForegroundColor Cyan 'choice:' $choice
                $Tenant = (Get-AzTenant).Name
                $TenantId = (Get-AzTenant).Id
                $SubscriptionName = $azureContext.Subscription.Name
                Write-Host -ForegroundColor Green "Logged into Subscription: " $subscriptionName

            }
            C{
                Write-Host -ForegroundColor Yellow 'choice:' $choice
                ConnectToSpecSubsc -Environment $Environment       
            }
        }        
    }#if subscriptions.Count -gt 1
    Else
    {
        $global:SubscriptionName = $subscriptions.Name
        $global:SubscriptionId = $subscriptions.Id

        $global:azureContext = Get-AzContext
        $global:Tenant = (Get-AzTenant).Name
        $global:TenantId = (Get-AzTenant).Id
        Write-Host -ForegroundColor Green "Logged into Subscription: " $SubscriptionName
    }

