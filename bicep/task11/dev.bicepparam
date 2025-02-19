using './main.bicep'

param environment = 'dev'
param vmSize = 'Standard_B2s'
param location = 'eastus'
param adminUsername = 'azureadmin'
@secure()
param sshPublicKey = ''

param allowedIpRanges = [
  '0.0.0.0/0'
]
