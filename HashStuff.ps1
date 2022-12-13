<#
HashStuff.ps1
https://pipe.how/new-hashtable/
https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-hashtable?view=powershell-7.2
#>

<#
https://ilovepowershell.com/2015/09/11/using-add-method-hashtable-object/
https://riptutorial.com/powershell/example/26069/add-a-key-value-pair-to-an-existing-hash-table

#>


#Creating Hashtables
$Hashtable = @{}
$Hashtable = New-Object hashtable
$Hashtable = [hashtable]::new()

# Setting values during creation
$Hashtable = @{
    Name = 'Emanuel Palm'
    Blog = 'PipeHow'
}

# Creating a hashtable inline is also possible
$Hashtable = @{ Name = 'Emanuel'; Blog = '| How' }

# Property-style
$Hashtable.Blog = '| How'

# As a dictionary
$Hashtable['Blog'] = '| How'

# Using the Add method
$Hashtable.Add('Blog', '| How')

# The hidden setter method
$Hashtable.set_Item('Blog', '| How')


# Adding 10000 items property-style
Measure-Command {
    $HashProp = @{}
    1..10000 | ForEach-Object { $HashProp.$_ = $_ }
}

# Adding 10000 items using the Add method
Measure-Command {
    $HashMethod = @{}
    1..10000 | ForEach-Object { $HashMethod.Add($_, $_) }
}

# Adding 10000 items dictionary-style
Measure-Command {
    $HashDict = @{}
    1..10000 | ForEach-Object { $HashDict[$_] = $_ }
}


#Accessing Values:
# Property-style
$Hashtable.Name

# As a dictionary
$Hashtable['Name']

# Using the Item property
$Hashtable.Item('Name')

$Hashtable['Name','Blog']

#Removing Values:
# Using the Remove method by providing the key
$Hashtable.Remove('Name')


#Finding Keys or Values:
$Hashtable.Contains('Name')
$Hashtable.ContainsKey('Name')
$Hashtable.ContainsValue('Emanuel')

#Combining Hashtables
$A = @{ Name = 'Emanuel' }
$B = @{ Blog = '| How' }
$C = $A + $B

#Copying Hashtables
$A = @{ 'Name' = 'Emanuel' } # Create hashtable
$B = $A # "Copy" hashtable
$B['Blog'] = '| How' # Add to copy
$A # Print original

#OR
$A = @{ 'Name' = 'Emanuel' }
$B = $A.Clone()
$B['Blog'] = '| How'
$A

#Or combine w/empty hash
$A = @{ 'Name' = 'Emanuel' }
$B = $A + @{}
$B['Blog'] = '| How'
$A


#splatting (?)
New-Item -Path 'C:\Temp' -Name 'MyFile.txt' -ItemType File -Value 'Hello world' -Force

<#
By creating a hashtable and providing it to the command using the @ symbol in front of 
the name of the hashtable instead of our normal variable $ sign,
all the items in the hashtable will be added to the command as parameters. 
Keys will become parameter names and the values will be the values provided.
#>
$Params = @{
    Path = 'C:\Temp'
    Name = 'MyFile.txt'
    ItemType = File
    Value = 'Hello world'
    Force = $true
}
New-Item @Params

#Common Parameters
$CommonParams = @{
    Path = 'C:\Temp'
    ItemType = 'File'
}
New-Item @CommonParams -Name 'File1.txt' -Value 'First file'
New-Item @CommonParams -Name 'File2.txt' -Value 'Second file'


$Params = @{
    Path = 'C:\Temp'
    ItemType = 'File'
    Name = 'MyFile.txt'
    Value = 'Hello world!'
}

if (Test-Path 'C:\Temp\MyFile.txt') {
    $Params['Path'] = 'C:\Temp\MyNewFolder'
    $Params['Force'] = $true
}

New-Item @Params

$Hashtable = Get-AzContext
#Loops
foreach ($Item in $Hashtable) 
{ 
    #"The item is $Item" 
    "The value of key $($_.Key) is $($_.Value)"
}

foreach ($Item in $Hashtable.GetEnumerator()) 
{
   "The value of key $($_.Key) is $($_.Value)"
}

foreach ($Key in @($Hashtable.Keys)) 
{
    $Hashtable[$Key] = Get-Random
}
$Hashtable

#Ordered Items
$Hashtable = @{} # not ordered
$Hashtable['FirstName'] = 'Emanuel'
$Hashtable['LastName'] = 'Palm'
$Hashtable['Blog'] = '| How'
$Hashtable['Post'] = 'Hashtables'
$Hashtable['Year'] = 2020
$Hashtable


###
$json = @{Path="C:\temp"; Filter="*.js"} | ConvertTo-Json

$hashtable = @{}

(ConvertFrom-Json $json).psobject.properties | Foreach { $hashtable[$_.Name] = $_.Value }


(ConvertFrom-Json $AzureContextJSON).psobject.properties | Foreach { $hashtable[$_.Name] = $_.Value }
##

<#
#If we need them to stay in order, we can use the [ordered] type accelerator when creating 
the hashtable, which internally changes the type of the hashtable to an OrderedDictionary 
and keeps our items in order.
#>
$Hashtable = [ordered]@{}
$Hashtable['FirstName'] = 'Emanuel'
$Hashtable['LastName'] = 'Palm'
$Hashtable['Blog'] = 'How'
$Hashtable['Post'] = 'Hashtables'
$Hashtable['Year'] = 2020
$Hashtable

#Complex Keys
$BlogHash = @{
     @{ 'Blog' = 'PipeHow' } = 'Emanuel Palm'
 }
$BlogHash


#Commands with Hashtables
#Group-Object
$Hash = Get-Service | Group-Object Status -AsHashTable
$Hash

#Select-Object
@{
    # There are different options for naming
    Name/n/Label/l = 'PropertyName'
    Expression/e = { <# logic here #> }
}

<#
The property name is defined with either Name or Label, or their first letter versions.

The expression for calculating the value is defined as a scriptblock with the
 key Expression (or e), where we can use $_ to reference the object.

We can either do it in-line, or define the hashtable as a variable to provide as below.
This code will result in a list of custom objects showing the files we created previously.
#>

$Params = @{
    'Path' = 'C:\Temp'
    'Filter' = 'File*'
}
$CreatedWeekDay = @{
    'n' = 'CreatedWeekday'
    'e' = { $_.CreationTime.DayOfWeek.ToString() }
}
Get-ChildItem @Params | Select-Object Name, Directory, $CreatedWeekDay


#ConvertTo-Json

$JsonHashtable = @{
    'Name' = 'Emanuel'
    'Blog' = '| How'
} | ConvertTo-Json


#ConvertFrom-Json
$Hashtable = '{"Name":"Emanuel","Blog":"| How"}'
$Hashtable | ConvertFrom-Json -AsHashtable

#PSCustomObject
$Hashtable = @{ Name = 'Emanuel'; Blog = '| How' }
$Hashtable


$CustomObject = [PSCustomObject]$Hashtable
$CustomObject

Get-Member $CustomObject


#Other Types
<#
We can actually cast to other object types as well, as long as we have the correct data and property structure. 
An example where I used this is with the AzureAD module, 
where I wanted to grant access to Graph and the Windows Virtual Desktop API for an Azure Function App, using PowerShell.
For this I needed to provide the command to create my application with a specific definition of required accesses. 
With hashtables I could define them in a structure that made sense and allowed me to flexibly declare which accesses 
the app should have in a verbose way.

#>


$RequiredAccess = [Microsoft.Open.AzureAD.Model.RequiredResourceAccess[]](
    @{
        # Graph App Id
        ResourceAppId  = '00000003-0000-0000-c000-000000000000'

        ResourceAccess = [Microsoft.Open.AzureAD.Model.ResourceAccess[]]@(
            # Directory.Read.All - Application Permission
            @{
                Id   = '7ab1d382-f21e-4acd-a863-ba3e13f7da61'
                Type = 'Role'
            },
            # Group.Read.All - Application Permission
            @{
                Id   = '5b567255-7703-4780-807c-7be8301ae99b'
                Type = 'Role'
            }
        )
    },
    @{
        # Windows Virtual Desktop App Id
        ResourceAppId  = '5a0aa725-4958-4b0c-80a9-34562e23f3b7'

        ResourceAccess = [Microsoft.Open.AzureAD.Model.ResourceAccess[]]@(
            # Windows Virtual Desktop - user_impersonation - Delegated Permission
            @{
                Id   = '0edede9d-bec8-4bf1-802b-aee83e72608a'
                Type = 'Scope'
            }
        )
    }
)










$hash = [ordered]@{ 
    Number = 1; 
    Shape = "Square"; 
    Color = "Blue"
   }
$hash

$hash = [ordered]@{ 
    Tenant= "jaifairfax";
    TenantId=  "c024032e-1c04-49c9-a557-87a4f548c42a";
    SubscriptionId=  "093847b0-f0dd-428f-a0b0-bd4245b99339";
    FileExists=  $false
}


#$hash.count


{
    "Tenant":  "jaifairfax",
    "TenantId":  "c024032e-1c04-49c9-a557-87a4f548c42a",
    "SubscriptionId":  "093847b0-f0dd-428f-a0b0-bd4245b99339",
    "FileExists":  false,
    "ApiAppRegName":  "katdevapi",
    "ApiClientId":  "50174b15-1c18-470e-9fd1-26d5e568176b",
    "ApiClientSecret":  "1DxVWm0h4~L9GwvW~3pz9v5q-Y~kkq6KiR",
    "ApiAppObjectId":  "230a4ddd-254a-4a23-87e9-911b461bdaf0",
    "ApiExisting":  false,
    "WebAppRegName":  "katdev",
    "WebClientId":  "15d5c5b0-2106-4584-a061-08dd0e88a16f",
    "WebAppObjectId":  "1adc675a-1ecb-44e8-8868-c4ee204eca38",
    "WebExisting":  false
}




















$ParentFolder ="../logs"
$todayShort = Get-Date -Format 'MM-dd-yyyy'
$jsonFileName = "DeploymentOutput-" + $todayShort + ".json"

$OutFileJSON = "..\logs\$jsonFileName"
Get-Item (Get-Location)
$dir= Get-Item (Get-Location)
 
    $Parent =$dir.Parent    
Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[70] OutFileJSON: " $OutFileJSON

Split-Path -Path $ParentFolder -Parent

if (Test-Path $ParentFolder) 
{
    Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[36] EXISTING Logs Folder" $ParentFolder
    $ParentFolderPath = (Get-ItemProperty  $ParentFolder | select FullName).FullName
    Write-Host -ForegroundColor Yellow "InitiateDeploymentProcess[38] EXISTING Logs Folder. FullPath:"  $ParentFolderPath
}

$curDir = Get-Location
Split-Path -Path $curDir -Parent

#https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-hashtable?view=powershell-7.2#using-the-brackets-for-access
#Using the brackets for access:
$ageList = @{}
$key = 'Kevin'
$value = 36
$ageList.add( $key, $value )
$ageList.add( 'Alex', 9 )

#Using the brackets for access:
#We can use this approach to add or update values into the hashtable too.
$ageList['Kevin']
$ageList['Alex']

$ageList = @{}

$key = 'Kevin'
$value = 36
$ageList[$key] = $value

$ageList['Alex'] = 9

$EnvironmentObj = [ordered]@{}
$AzureContext = Get-AzContext
$EnvironmentObj = $AzureContext.Environment
$EnvironmentJSON = ConvertTo-Json $EnvironmentObj

#expand the contents of the nested hashtables
$EnvironmentObj | Format-Table Name, @{n='Value';e={
  if ($_.Value -is [Hashtable]) {
    $ht = $_.Value
    $a  = $ht.keys | sort | % { '{0}={1}' -f $_, $ht[$_] }
    '{{{0}}}' -f ($a -join ', ')
  } else {
    $_.Value
  }
}}


#expand the contents of the nested hashtables
$items | Format-Table Name, @{n='Value';e={
  if ($_.Value -is [Hashtable]) {
    $ht = $_.Value
    $a  = $ht.keys | sort | % { '{0}={1}' -f $_, $ht[$_] }
    '{{{0}}}' -f ($a -join ', ')
  } else {
    $_.Value
  }
}}



function Convert-HashToString
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Collections.Hashtable]
            $Hash
        )
        $hashstr = "@{"
        $keys = $Hash.keys
        foreach ($key in $keys)
        {
            $v = $Hash[$key]
            if ($key -match "\s")
            {
                $hashstr += "`"$key`"" + "=" + "`"$v`"" + ";"
            }
            else
            {
                $hashstr += $key + "=" + "`"$v`"" + ";"
            }
        }
        $hashstr += "}"
        return $hashstr
    }


<#
https://stackoverflow.com/questions/40495248/create-hashtable-from-json
parse nested json arrays and json objects.
#>


[CmdletBinding]
function Get-FromJson
{
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Path
    )

    function Get-Value {
        param( $value )

        $result = $null
        if ( $value -is [System.Management.Automation.PSCustomObject] )
        {
            Write-Verbose "Get-Value: value is PSCustomObject"
            $result = @{}
            $value.psobject.properties | ForEach-Object { 
                $result[$_.Name] = Get-Value -value $_.Value 
            }
        }
        elseif ($value -is [System.Object[]])
        {
            $list = New-Object System.Collections.ArrayList
            Write-Verbose "Get-Value: value is Array"
            $value | ForEach-Object {
                $list.Add((Get-Value -value $_)) | Out-Null
            }
            $result = $list
        }
        else
        {
            Write-Verbose "Get-Value: value is type: $($value.GetType())"
            $result = $value
        }
        return $result
    }


    if (Test-Path $Path)
    {
        $json = Get-Content $Path -Raw
    }
    else
    {
        $json = '{}'
    }

    $hashtable = Get-Value -value (ConvertFrom-Json $json)

    return $hashtable
}

$path = "C:\GitHub\dtp\Deploy\powershell\AzContext"
Get-FromJson -Path $path



###############
$ageList = @{
    Kevin = 36
    Alex  = 9
}


$ageList.count


foreach($item in $MyJsonObject.GetEnumerator()) {
Write-Host -ForegroundColor Yellow -BackgroundColor Black  $item.name "=" $item.value
}

$ageList.keys | ForEach-Object{
    $message = '{0} is {1} years old!' -f $_, $ageList[$_]
    Write-Output $message
}


foreach($key in $ageList.keys)
{
    $message = '{0} is {1} years old' -f $key, $ageList[$key]
    Write-Output $message
}


$MyJsonObject.GetEnumerator() | ForEach-Object{
    $message = '{0} is {1} ' -f $_.key, $_.value
    Write-Output $message
}




Function global:PrintHash{
Param(
        [Parameter(Mandatory = $false)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow  "`n[$today] PrintHash: $Caller"
    $i=0
    Write-Host -ForegroundColor Cyan  "@{"
    $object.GetEnumerator() | Foreach-Object   
    {         
        Write-Host -ForegroundColor Cyan $_.key "="""$_.value""";"
        $i++       
    }
    Write-Host -ForegroundColor Cyan "}"
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Yellow "[$today] FINISHED PrintHash $Caller"
}#PrintHash


foreach ($item in $item.value) {
            $message = '{0} is {1} ' -f $_.key, $_.value
            Write-Output $message
        }

foreach ($item in $CustomRoles) 
{
    Write-host $item.Name
    #Write-host $item
    #Write-host $item.AssignableScopes             
}


$MyJsonObject.PSObject.Properties | ForEach-Object {
    Write-Host -ForegroundColor DarkYellow $_.Name "=" $_.Value
}

$content = Get-Content -Path $RoleDefinitionFile -Raw -ErrorAction Stop
$scriptBlock = [scriptblock]::Create( $content )
$scriptBlock.CheckRestrictedLanguage( $allowedCommands, $allowedVariables, $true )
$hashtable = ( & $scriptBlock )


$content.GetEnumerator() | ForEach-Object {"$($_.Key) - $($_.Value)"}



$people = @{
    Kevin = @{
        age  = 36
        city = 'Austin'
    }
    Alex = @{
        age  = 9
        city = 'Austin'
    }
}


foreach($name in $people.keys)
{
    $person = $people[$name]
    '{0}, age {1}, is in {2}' -f $name, $person.age, $person.city
}



$Properties = @{}
($json | ConvertFrom-Json).PSObject.Properties |
    ForEach-Object {$Properties.($_.Name) = $_.Value |
        ConvertTo-Expression -Expand -1}
[PSCustomObject]$Properties




Function global:PrintDeployObject{
Param(
        [Parameter(Mandatory = $true)] [object] $object
      , [Parameter(Mandatory = $false)] [string] $Caller      

    )
    $today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Write-Host -ForegroundColor Cyan "================================================================================`n"
    Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] START $Caller.PrintDeployObject"
    
    $Caller='[1214]: object :: object'       
    PrintObject -object $object -Caller $Caller
    
    $i=0
    foreach ($item in $object.GetEnumerator()) 
    #foreach ($item in $object) 
    {         
        #Write-Host "[1221] item.name.Length=" $item.name.Length
        if($item.name.Length -gt 0)
        {
            Write-Host -ForegroundColor Yellow  "[1224][$i] `$item.name="$item.name
            Write-Host -ForegroundColor Cyan  "[1225][$i] item.value.GetType=" ($item.value).GetType() 
            $currItem = $item.value       
        }
        else
        {
            $currItem = $item
            Write-Host -ForegroundColor Green -BackgroundColor Black "[1231][$i] currItem.GetType=" $currItem.GetType()
        }
        
        Write-Host -ForegroundColor Green -BackgroundColor Black "[1234][$i] currItem.GetType=" $currItem.GetType()
        Write-Host -ForegroundColor Green -BackgroundColor Black "[1235][$i] currItem.GetType.Name=" $currItem.GetType().Name
        Write-Host -ForegroundColor Green -BackgroundColor Black "[1236][$i] currItem.GetType.BaseType=" $currItem.GetType().BaseType
        Write-Host -ForegroundColor Cyan -BackgroundColor Black "[1237][$i] currItem.GetType.BaseType.FullName=" $currItem.GetType().BaseType.FullName    
               

        #Write-Host "[1136] itemType -eq OrderedDictionary:" ($currItem.GetType() -eq "System.Collections.Specialized.OrderedDictionary")
        
        If( $currItem.GetType() -match "System.Collections.Specialized.OrderedDictionary")
        {
            Write-Host -ForegroundColor Magenta "[$i] `$item.name="$item.name
            Write-Host -ForegroundColor Green -BackgroundColor Black "[1245][$i] currItem.GetType=" $currItem.GetType()
            Write-Host -ForegroundColor Green -BackgroundColor Black "[1246][$i] currItem.GetType.Name=" $currItem.GetType().Name
            Write-Host -ForegroundColor Green -BackgroundColor Black "[1247][$i] currItem.GetType.BaseType=" $currItem.GetType().BaseType
            Write-Host -ForegroundColor Cyan -BackgroundColor Black "[1248][$i] currItem.GetType.BaseType.FullName=" $currItem.GetType().BaseType.FullName    
        
            #Write-Host -ForegroundColor Magenta "[$i] `$currItem.name="$currItem.name
            #$Caller = $item.name
            #PrintDeployObject -$item.value -Caller $Caller
        }
        
        Else
        {
            Write-Host -ForegroundColor Green "[1257][$i]" $item.name "=" $item.value
        }
        #>
        #$item.name +"=" + $item.value >> $FilePath
        $i++       
    }

    #$today = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    #Write-Host -ForegroundColor Cyan -BackgroundColor Black "[$today] FINISHED $Caller.PrintObject`n "
    Write-Host -ForegroundColor Cyan "================================================================================`n"

}#PrintDeployObject



function ConvertPSObjectToHashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

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

$json = @"
{
    "outer": "value1",
    "outerArray": [
        "value2",
        "value3"
    ],
    "outerHash": {
        "inner": "value4",
        "innerArray": [
            "value5",
            "value6"
        ],
        "innerHash": {
            "innermost1": "value7",
            "innermost2": "value8",
            "innermost3": "value9"
        }
    }
}
"@

$json = @'
[{
    "CloudEnvironment":  "AzureUSGovernment",
    "Location":  "usgovvirginia",
    "Environment":  "prod",
    "AppName":  "Wed",
    "SqlAdmin":  "dtpadmin",
    "SqlAdminPwd":  {
                        "Length":  12
                    },
    "SqlAdminPwdPlainText":  "1qaz2wsx#EDC",
    "BicepFile":  "C:\\GitHub\\dtp\\Deploy\\main.bicep",
    "OutFileJSON":  "C:\\GitHub\\dtp\\Deploy\\logs\\jaifairfax_Wed_prod.json",
    "LogFile":  "C:\\GitHub\\dtp\\Deploy\\logs\\jaifairfax_Wed_prod_Log.txt",
    "DeploymentName":  "Deployment_12-07-2022",
    "FileExists":  true,
    "SubscriptionName":  "jaiFairfax",
    "SubscriptionId":  "093847b0-f0dd-428f-a0b0-bd4245b99339",
    "TenantName":  "jaifairfax",
    "TenantId":  "c024032e-1c04-49c9-a557-87a4f548c42a",
    "CurrUserName":  "Kat Hopkins",
    "CurrUserId":  "d648ba5b-2897-4420-84af-197512f27c24",
    "CurrUserPrincipalName":  "katalin.hopkins@jaifairfax.onmicrosoft.com",
    "MyIP":  "MyIP",
    "StepCount":  5,
    "TemplateParameterFile":  "\\main.parameters.prod.json",
    "ContributorRoleId":  "b24988ac-6180-42a0-ab88-20f7382dd24c",
    "TransferAppObj":  {
                           "AppName":  "wedtransfer",
                           "Environment":  "prod",
                           "Location":  "usgovvirginia",
                           "Solution":  "Transfer",
                           "ResourceGroupName":  "rg-wed-transfer-prod",
                           "RoleDefinitionId":  "a04aad57-4986-4269-ad2a-325c867557f0",
                           "RoleDefinitionFile":  "C:\\GitHub\\dtp\\Deploy\\DTPStorageBlobDataReadWrite.json",
                           "BicepFile":  "C:\\GitHub\\dtp\\Deploy\\transfer-main.bicep",
                           "APIAppRegName":  "wedtransferAPI",
                           "APIAppRegAppId":  "86378e01-997c-44ce-b9c5-b86a369bb915",
                           "APIAppRegObjectId":  "da99ad47-c8c0-482b-b5f9-f9c13719352c",
                           "APIAppRegClientSecret":  ".1FU-AW-1j_CZjcH0-iA7N6Lc.f7_x7y5N",
                           "APIAppRegServicePrincipalId":  "0c8bccf4-142c-42ba-a3c0-5571ef136ee3",
                           "APIAppRegExists":  true,
                           "ClientAppRegName":  "wedtransferTransfer",
                           "ClientAppRegAppId":  "7ebadd30-8ecb-47a2-814a-dfdf855c52c1",
                           "ClientAppRegObjectId":  "e91db1b6-3894-421e-93f0-23f85cbe7fe0",
                           "ClientAppRegServicePrincipalId":  "ed15a4fa-85d2-4c30-a82e-69b9746976d1",
                           "ClientAppRegExists":  true
                       },
    "PickupAppObj":  {
                         "AppName":  "wedpickup",
                         "Environment":  "prod",
                         "Location":  "usgovvirginia",
                         "Solution":  "Pickup",
                         "ResourceGroupName":  "rg-wed-pickup-prod",
                         "RoleDefinitionId":  "a566f2af-c7d8-4fa5-ad8d-bc582d8e391e",
                         "RoleDefinitionFile":  "C:\\GitHub\\dtp\\Deploy\\DPPStorageBlobDataRead.json",
                         "BicepFile":  "C:\\GitHub\\dtp\\Deploy\\pickup-main.bicep",
                         "APIAppRegName":  "wedpickupAPI",
                         "APIAppRegAppId":  "774ba7be-387e-478b-87fd-6191a4d561f1",
                         "APIAppRegObjectId":  "e3ea2e23-8ff4-4abb-873e-7e4e1c0e4389",
                         "APIAppRegClientSecret":  "-a69-X4OupoIBlXp.FQeJiw~bN19B6a-1H",
                         "APIAppRegServicePrincipalId":  "40c94e02-1ac1-40a5-81c2-1f52d95ccdfc",
                         "APIAppRegExists":  true,
                         "ClientAppRegName":  "wedpickup",
                         "ClientAppRegAppId":  "1dd46432-30bb-40d6-aa82-08a06c32e956",
                         "ClientAppRegObjectId":  "0a0c46b6-f276-46cf-8ec3-0427bbd85629",
                         "ClientAppRegServicePrincipalId":  "e315362f-261d-4cb8-8bf1-09e10e641e0a",
                         "ClientAppRegExists":  true
                     },
    "Cloud":  {
                  "Name":  "AzureUSGovernment",
                  "Type":  "Built-in",
                  "EnableAdfsAuthentication":  false,
                  "OnPremise":  false,
                  "ActiveDirectoryServiceEndpointResourceId":  "https://management.core.usgovcloudapi.net/",
                  "AdTenant":  "Common",
                  "GalleryUrl":  "https://gallery.azure.com/",
                  "ManagementPortalUrl":  "https://portal.azure.us/",
                  "ServiceManagementUrl":  "https://management.core.usgovcloudapi.net/",
                  "PublishSettingsFileUrl":  "https://manage.windowsazure.us/publishsettings/index",
                  "ResourceManagerUrl":  "https://management.usgovcloudapi.net/",
                  "SqlDatabaseDnsSuffix":  ".database.usgovcloudapi.net",
                  "StorageEndpointSuffix":  "core.usgovcloudapi.net",
                  "ActiveDirectoryAuthority":  "https://login.microsoftonline.us/",
                  "GraphUrl":  "https://graph.windows.net/",
                  "GraphEndpointResourceId":  "https://graph.windows.net/",
                  "TrafficManagerDnsSuffix":  "usgovtrafficmanager.net",
                  "AzureKeyVaultDnsSuffix":  "vault.usgovcloudapi.net",
                  "DataLakeEndpointResourceId":  null,
                  "AzureDataLakeStoreFileSystemEndpointSuffix":  null,
                  "AzureDataLakeAnalyticsCatalogAndJobEndpointSuffix":  null,
                  "AzureKeyVaultServiceEndpointResourceId":  "https://vault.usgovcloudapi.net",
                  "ContainerRegistryEndpointSuffix":  "azurecr.us",
                  "AzureOperationalInsightsEndpointResourceId":  "https://api.loganalytics.us",
                  "AzureOperationalInsightsEndpoint":  "https://api.loganalytics.us/v1",
                  "AzureAnalysisServicesEndpointSuffix":  "asazure.usgovcloudapi.net",
                  "AnalysisServicesEndpointResourceId":  "https://region.asazure.usgovcloudapi.net",
                  "AzureAttestationServiceEndpointSuffix":  null,
                  "AzureAttestationServiceEndpointResourceId":  null,
                  "AzureSynapseAnalyticsEndpointSuffix":  "dev.azuresynapse.usgovcloudapi.net",
                  "AzureSynapseAnalyticsEndpointResourceId":  "https://dev.azuresynapse.usgovcloudapi.net",
                  "VersionProfiles":  [

                                      ],
                  "ExtendedProperties":  {
                                             "OperationalInsightsEndpoint":  "https://api.loganalytics.us/v1",
                                             "OperationalInsightsEndpointResourceId":  "https://api.loganalytics.us",
                                             "AzureAnalysisServicesEndpointSuffix":  "asazure.usgovcloudapi.net",
                                             "AnalysisServicesEndpointResourceId":  "https://region.asazure.usgovcloudapi.net",
                                             "AzureSynapseAnalyticsEndpointSuffix":  "dev.azuresynapse.usgovcloudapi.net",
                                             "AzureSynapseAnalyticsEndpointResourceId":  "https://dev.azuresynapse.usgovcloudapi.net",
                                             "ManagedHsmServiceEndpointResourceId":  "https://managedhsm.usgovcloudapi.net",
                                             "ManagedHsmServiceEndpointSuffix":  "managedhsm.usgovcloudapi.net",
                                             "MicrosoftGraphEndpointResourceId":  "https://graph.microsoft.us/",
                                             "MicrosoftGraphUrl":  "https://graph.microsoft.us"
                                         },
                  "BatchEndpointResourceId":  "https://batch.core.usgovcloudapi.net/"
              }
}]
'@

$j = $json | ConvertFrom-Json
$x = $j | ConvertPSObjectToHashtable


$json | Select-Object -ExpandProperty outerhash


 $Properties = @{}
            ($json | ConvertFrom-Json).PSObject.Properties |
                ForEach-Object {$Properties.($_.Name) = $_.Value |
                 #   ConvertTo-Expression -Expand -1}
            #[PSCustomObject]$Properties


$Properties = @{}
($json | ConvertFrom-Json).PSObject.Properties |
    ForEach-Object {$Properties.($_.Name) = $_.Value |
        ConvertTo-Expression -Expand -1}
[PSCustomObject]$Properties




$Properties = @{}
($json | ConvertFrom-Json).PSObject.Properties |
    ForEach-Object {$Properties.($_.Name) = $_.Value 
            } 
[PSCustomObject]$Properties