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


foreach ($item in $CustomRoles) 
{
    Write-host $item.Name
    #Write-host $item
    #Write-host $item.AssignableScopes             
}


$MyJsonObject.PSObject.Properties | ForEach-Object {
    Write-Host $_.Name "=" $_.Value
}

$content = Get-Content -Path $RoleDefinitionFile -Raw -ErrorAction Stop
$scriptBlock = [scriptblock]::Create( $content )
$scriptBlock.CheckRestrictedLanguage( $allowedCommands, $allowedVariables, $true )
$hashtable = ( & $scriptBlock )


$content.GetEnumerator() | ForEach-Object {"$($_.Key) - $($_.Value)"}


