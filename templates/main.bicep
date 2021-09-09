param storageAccountName string
param storageAccountType string
param logicAppName string
param logicAppAspName string
param logicAppAspSku object
param vnetName string
param subnets object
// param dnsZoneNameSites string
// param dnsZoneNameStorage string
// param logicAppPrivateLinkName string
// param logicAppPrivateEndpointName string
// param storageAccountPrivateLinkName string
// param storageAccountPrivateEndpointName string
param applicationGatewayProperties object
param apimProperties object

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
    logicAppName: logicAppName
    vnetAddressPrefix: subnets.vnetAddressPrefix
    defaultSnetAddressPrefix: subnets.defaultSnetAddressPrefix
    logicAppsSnetAddressPrefix: subnets.logicAppsSnetAddressPrefix
    apimSnetAddressPrefix: subnets.apimSnetAddressPrefix
    applicationGatewaySnetAddressPrefix: subnets.applicationGatewaySnetAddressPrefix
    // dnsZoneNameSites: dnsZoneNameSites
    // dnsZoneNameStorage: dnsZoneNameStorage
    // logicAppPrivateLinkName: logicAppPrivateLinkName
    // logicAppPrivateEndpointName: logicAppPrivateEndpointName
    // storageAccountName: storageAccountName
    // storageAccountPrivateLinkName: storageAccountPrivateLinkName
    // storageAccountPrivateEndpointName: storageAccountPrivateEndpointName
  }
  dependsOn: [
    logicAppModule
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

