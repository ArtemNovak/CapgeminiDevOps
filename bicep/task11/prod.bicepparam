using './main.bicep'

param environment = 'prod'
param vmSize = 'Standard_D2s_v3'
param location = 'eastus'
param adminUsername = 'azureadmin'
@secure()
param sshPublicKey = ''

param allowedIpRanges = [
  '10.0.0.0/24'
]
