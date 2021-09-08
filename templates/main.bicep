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
param applicationGatewayProperties object

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
    apimSubnetName: applicationGatewayProperties.apimSnetAddressPrefix
    applicationGatewaySubnetName: applicationGatewayProperties.applicationGatewaySubnetName
    logicAppName: logicAppName
    vnetAddressPrefix: networking.vnetAddressPrefix
    defaultSnetAddressPrefix: networking.defaultSnetAddressPrefix
    logicAppsSnetAddressPrefix: networking.logicAppsSnetAddressPrefix
    applicationGatewaySnetAddressPrefix: networking.applicationGatewaySnetAddressPrefix
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

module applicationGatewayModule './applicationGateway.bicep' = {
  name: 'rg-deploy-application-gateway'
  params: {
    applicationGatewayName: applicationGatewayProperties.applicationGatewayName
    tier: applicationGatewayProperties.tier
    sku: applicationGatewayProperties.sku
    skuSize: applicationGatewayProperties.skuSize
    capacity: applicationGatewayProperties.capacity
    subnetName: applicationGatewayProperties.subnetName
    publicIpAddressName: applicationGatewayProperties.publicIpAddressName
    allocationMethod: applicationGatewayProperties.allocationMethod
    vnetName: vnetName
    logicAppName: logicAppName
  }
  dependsOn: [
    networkingModule
  ]
}

