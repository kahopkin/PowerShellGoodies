@description('Name of the Virtual Machine')
@maxLength(15)
param vmName string

@description('Name of the vnet in which VM is connected')
param vnetName string

@description('Name of the subnet in which VM is connected')
param subnetName string

@description('Static IP Address of the VM')
param ipAddress string

@description('Size of the Virtual Machine')
param vmSize string

@description('Admin Username for the VM')
param adminUsername string

@description('The admin password for the SQL Server')
@secure()
param adminPassword string

@description('Data disks configuration')
param dataDisks array

@description('Location for the VM and related resources')
param location string = resourceGroup().location

@description('The Log Analytics workspace ID for monitoring and diagnostics.')
param workspaceName string

@description('The name of the disk encryption set.')
param diskEncryptionSetName string

param keyVaultName string

param desKeyName string

param tags object

var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

// Disk Encryption Set
resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyVaultName
}

resource desKey 'Microsoft.KeyVault/vaults/keys@2021-10-01' = {
  name: desKeyName
  parent: keyVault
  properties: {
    keySize: 2048
    kty: 'RSA'
  }
}

resource diskEncryptionSet 'Microsoft.Compute/diskEncryptionSets@2021-08-01' = {
  name: diskEncryptionSetName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      keyUrl: desKey.properties.keyUriWithVersion
      sourceVault: {
        id: keyVault.id
      }
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
    rotationToLatestKeyVersionEnabled: true
  }
}

resource desAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        permissions: {
          keys: ['get', 'wrapKey', 'unwrapKey']
        }
        tenantId: tenant().tenantId
        objectId: diskEncryptionSet.identity.principalId
      }
    ]
  }
}

// NIC for the VM
resource nic 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: ipAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: '${vmName}-osDisk'
        managedDisk: {
          diskEncryptionSet: {
            id: diskEncryptionSet.id
          }
        }
      }
      dataDisks: [for disk in dataDisks: {
        createOption: 'Empty'
        lun: disk.lun
        diskSizeGB: disk.sizeGB
        managedDisk: {
          diskEncryptionSet: {
            id: diskEncryptionSet.id
          }
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Get a reference to the existing log analytics workspace
resource logAnalyticWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspaceName
}

resource vmMMAExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: vm
  name: '${vmName}-MMAExtension'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: logAnalyticWorkspace.listKeys().primarySharedKey
    }
  }
}

resource antimalwareExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: vm
  name: '${vmName}-IaaSAntimalware'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.5'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
    }
  }
}

resource vmDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${vm.name} VM to Log Analytics'
  scope: vm
  properties: {
    workspaceId: logAnalyticWorkspace.id
    logs: [
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
