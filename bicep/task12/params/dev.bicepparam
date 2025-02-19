using '../main.bicep'

param environment = 'dev'
param vmSize = 'Standard_B2s'
param location = 'westeurope'
param adminUsername = 'azureadmin'

param allowedIpRanges = [
  '0.0.0.0/0'
]
