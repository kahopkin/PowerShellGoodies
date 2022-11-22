$json = @'
[{
	"squadName": "Super hero squad Alpha",
	"homeTown": "Metro City",
	"formed": 2016,
	"secretBase": "Large tent in the forest",
	"active": "True",
	"members": [{
		"name": "Molecule Man",
		"age": 29,
		"secretIdentity": "Dan Jukes",
		"powers": ["Radiation resistance",
		"Turning tiny",
		"Radiation blast"]
	},
	{
		"name": "Madame Uppercut",
		"age": 39,
		"secretIdentity": "Jane Wilson",
		"powers": ["Million tonne punch",
		"Damage resistance",
		"Superhuman reflexes"]
	},
	{
		"name": "Eternal Flame",
		"age": 1000000,
		"secretIdentity": "Unknown",
		"powers": ["Immortality",
		"Heat Immunity",
		"Inferno",
		"Teleportation",
		"Interdimensional travel"]
	}]
},
{
	"squadName": "Second squad Baker",
	"homeTown": "Metro Toronto",
	"formed": 2017,
	"secretBase": "CN tower",
	"active": "True",
	"members": [{
		"name": "Kathleen Wynne",
		"age": 49,
		"secretIdentity": "Cyan Arrah",
		"powers": ["XRay vision",
		"Invisibility",
		"Radiation blast"]
	},
	{
		"name": "Madame Butterfly",
		"age": 27,
		"secretIdentity": "Iman Angel",
		"powers": ["Magical hearing",
		"Fantastic ideas"]
	},
	{
		"name": "Gassy Misty Cloud",
		"age": 1000,
		"secretIdentity": "Puff of Smoke",
		"powers": ["Immortality",
		"Heat and Flame Immunity",
		"Impeccable hearing",
		"Xray Vision",
		"Able to jump tall buildings",
		"Teleportation",
		"Intergalactic travel"]
	}]
}]
'@

$objectOut =  $json | ConvertFrom-Json
$objectOut[0].squadName
$objectOut[0].members[0].name

$newJson = ConvertTo-Json $objectOut
$objectOut =  $json | ConvertFrom-Json
$squads = $objectOut | ConvertFrom-Json


$APIResponse = Invoke-RestMethod -Uri $Uri -Headers $Headers

$EnvironmentObj = [ordered]@{}
$AzureContext = Get-AzContext
$EnvironmentObj = $AzureContext.Environment
$EnvironmentJSON = ConvertTo-Json $EnvironmentObj

ForEach ($d in $EnvironmentObj) 
{

<#    "Project Code = " + $d.code + ", Project Description = " + $d.description
    ForEach ($e in $d.customFieldValues) {
        "CustomField Key " + $e.key + ", Name " + $e.name  + ", Value " + $e.value
    }
    #>
}

ForEach ($d in $json.Values) 
{
Write-Host $d
}


