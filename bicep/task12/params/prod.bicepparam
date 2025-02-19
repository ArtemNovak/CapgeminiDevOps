using '../main.bicep'

param environment = 'prod'
param vmSize = 'Standard_D2s_v3'
param location = 'westeurope'
param adminUsername = 'azureadmin'

param allowedIpRanges = [
  '37.57.129.74'
]
