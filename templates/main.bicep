param storageAccountName string
param storageAccountType string
param logicAppName string
param logicAppAspName string
param logicAppAspSku object
param vnetName string
param subnets object
param dnsZoneNameSites string
param dnsZoneNameStorage string
param logicAppPrivateLinkName string
param logicAppPrivateEndpointName string
param storageAccountPrivateLinkName string
param storageAccountPrivateEndpointName string
param applicationGatewayProperties object
param apimProperties object

var defaultSubnetName = 'default'

// Bastion must have its own subnet with this name
var bastionSubnetName = 'AzureBastionSubnet'

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
    logicAppSubnetName: subnets.logicAppSubnetName
    apimSubnetName: subnets.apimSubnetName
    applicationGatewaySubnetName: subnets.applicationGatewaySubnetName
    vnetAddressPrefix: subnets.vnetAddressPrefix
    defaultSnetAddressPrefix: subnets.defaultSnetAddressPrefix
    logicAppsSnetAddressPrefix: subnets.logicAppsSnetAddressPrefix
    apimSnetAddressPrefix: subnets.apimSnetAddressPrefix
    applicationGatewaySnetAddressPrefix: subnets.applicationGatewaySnetAddressPrefix
    bastionSubnetAddressPrefix: subnets.bastionSubnetAddressPrefix
    bastionSubnetName: bastionSubnetName
    defaultSubnetName: defaultSubnetName
  }
}

module logicAppVnetIntegration 'logicAppVnetIntegration.bicep' = {
  name: 'rg-deploy-logicApp-vnetIntegration'
  params: {
    vnetName: vnetName
    logicAppSubnetName: subnets.logicAppSubnetName
    logicAppName: logicAppName
  }
  dependsOn: [
    logicAppModule
    networkingModule
  ]  
}

// Configure Private Endpoints for Logic App and Storage

module privateEndpoints 'privateEndpoints.bicep' = {
  name: 'rg-deploy-privateEndpoints'
  params: {
    vnetName: vnetName
    dnsZoneNameSites: dnsZoneNameSites
    dnsZoneNameStorage: dnsZoneNameStorage
    logicAppPrivateLinkName: logicAppPrivateLinkName
    logicAppPrivateEndpointName: logicAppPrivateEndpointName
    storageAccountName: storageAccountName
    storageAccountPrivateLinkName: storageAccountPrivateLinkName
    storageAccountPrivateEndpointName: storageAccountPrivateEndpointName
    logicAppName: logicAppName
    defaultSubnetName: defaultSubnetName
  }
  dependsOn: [
    logicAppModule
    networkingModule
  ]  
}

module apimModule './apim.bicep' = {
  name: 'rg-deploy-apim'
  params: {
    vnetName: vnetName
    apimName: apimProperties.apimName
    logicAppName: logicAppName
    apimSkuName: apimProperties.sku.name
    apimSkuCapacity: apimProperties.sku.capacity
    apimSubnetName: subnets.apimSubnetName
    publisherUserEmail: apimProperties.publisherEmail
    publisherName: apimProperties.publisherName
    notificationSenderEmail: apimProperties.notificationSenderEmail
    apimResourcePrefix: apimProperties.apimResourcePrefix
  }
  dependsOn: [
    networkingModule
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

