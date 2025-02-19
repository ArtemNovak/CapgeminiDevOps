targetScope = 'subscription'

@description('Name of the Resource Group')
param rgName string = 'ArtemNovakARM'

@description('Location of the Resource Group')
param rgLocation string = 'westeurope'

@description('Storage Account Name')
param storageAccountName string = 'artemnovakarmbicep'

param tags object = {
  environment: 'test'
  deployedBy: 'Bicep'
}

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgName
  location: rgLocation
  tags: tags
}

module storageAccount './storage.bicep' = {
  scope: rg
  name: 'storageAccountDeployment'
  params: {
    storageAccountName: storageAccountName
    location: rgLocation
    tags: tags
  }
}

output resourceGroupName string = rgName
