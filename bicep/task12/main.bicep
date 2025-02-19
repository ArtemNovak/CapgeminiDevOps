targetScope = 'resourceGroup'

param location string
param environment string
param vmSize string
param adminUsername string
param allowedIpRanges array

var networkingModule = 'networking'
var vmModule = 'vm'
var storageAccountName = 'diag${uniqueString(resourceGroup().id)}'

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: 'kv-wtjlxjhrlg5ga'
  scope: resourceGroup('an-bicep')
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
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
    environment: environment
    allowedIpRanges: allowedIpRanges
  }
}

module virtualMachine './modules/vm.bicep' = {
  name: vmModule
  params: {
    location: location
    environment: environment
    vmSize: vmSize
    adminUsername: adminUsername
    sshPublicKey: kv.getSecret('sshPublicKey') 
    subnetId: networking.outputs.subnetId
    diagnosticsStorageAccountName: storageAccount.name
  }
}

output vmName string = virtualMachine.outputs.vmName
output vmPublicIP string = virtualMachine.outputs.publicIPAddress
output storageAccountName string = storageAccount.name
