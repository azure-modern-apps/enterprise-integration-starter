param storageAccountName string
param storageAccountType string
param logicAppName string
param logicAppAspName string
param logicAppAspSku object
param vnetName string
param logicAppSubnetName string
param networking object
param dnsZoneNameSites string
param dnsZoneNameStorage string
param logicAppPrivateLinkName string
param logicAppPrivateEndpointName string
param storageAccountPrivateLinkName string
param storageAccountPrivateEndpointName string

module storageAccountModule './storageAccount.bicep' = {
  name: 'rg-deploy-${storageAccountName}'
  params: {
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
  }
}

module logicAppModule './logicApp.bicep' = {
  name: 'rg-deploy-${logicAppName}'
  params: {
    logicAppAspName: logicAppAspName
    logicAppAspSku: logicAppAspSku
    logicAppName: logicAppName
    storageAccountDetails: storageAccountModule.outputs.storageAccountDetails
  }
  dependsOn: [
    storageAccountModule
  ]
}

module networkingModule './networking.bicep' = {
  name: 'rg-deploy-vnet'
  params: {
    vnetName: vnetName
    logicAppSubnetName: logicAppSubnetName
    logicAppName: logicAppName
    networking: networking
    dnsZoneNameSites: dnsZoneNameSites
    dnsZoneNameStorage: dnsZoneNameStorage
    logicAppPrivateLinkName: logicAppPrivateLinkName
    logicAppPrivateEndpointName: logicAppPrivateEndpointName
    storageAccountName: storageAccountName
    storageAccountPrivateLinkName: storageAccountPrivateLinkName
    storageAccountPrivateEndpointName: storageAccountPrivateEndpointName
  }
  dependsOn: [
    logicAppModule
  ]
}
