targetScope = 'resourceGroup'

param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}

resource keyvaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.keyVaultPrivateDnsZoneName
	location: 'global'
	tags: tags
	resource keyvaultDnsZoneLink 'virtualNetworkLinks' = {
	name: '${keyvaultDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}
//*/

resource auditStorage_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.blobPrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_Blob_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${auditStorage_Blob_PrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}

resource mainStorage_File_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.filePrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_File_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${mainStorage_File_PrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}//mainStorage_File_PrivateDnsZone


resource mainStorage_Queue_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.queuePrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_Queue_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${mainStorage_Queue_PrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}

resource mainStorage_Table_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.tablePrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_Table_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${mainStorage_Table_PrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}




resource webapp_privateDNSZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
	name: SolutionObj.webappPrivateDNSZoneName
	location: 'global'
	tags: tags
}



resource webapp_privateDNSZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
	parent: webapp_privateDNSZone
	name: '${SolutionObj.webappPrivateDNSZoneName}-link'
	tags: tags
	location: 'global'
	properties: {
	registrationEnabled: false
	virtualNetwork: {
		id: virtualNetwork.id
	}
	}
}

/*
resource functionApp_privateDNSZoneVirutalNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =  if(SolutionObj.Environment == 'Prod'){
	parent: webapp_privateDNSZone
	name: '${SolutionObj.webappPrivateDNSZoneName}-link'
	tags: tags
	location: 'global'
	properties: {
	registrationEnabled: false
	virtualNetwork: {
		id: virtualNetwork.id
	}
	}
}
//*/

