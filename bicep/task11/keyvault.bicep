param location string
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
  }
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
