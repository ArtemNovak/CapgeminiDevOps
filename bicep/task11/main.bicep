targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vmSize string = 'Standard_B2s'
param adminUsername string = 'azureadmin'
@secure()
param sshPublicKey string

var networkingModule = 'networking'
var vmModule = 'vm'
var storageAccountName = 'diag${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

module networking './modules/networking.bicep' = {
  name: networkingModule
  params: {
    location: location
  }
}

module virtualMachine './modules/vm.bicep' = {
  name: vmModule
  params: {
    location: location
    vmSize: vmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    subnetId: networking.outputs.subnetId
    diagnosticsStorageAccountName: storageAccount.name
  }
}

output vmName string = virtualMachine.outputs.vmName
output vmPublicIP string = virtualMachine.outputs.publicIPAddress
