param storageAccountName string
param vnetName string
param dnsZoneNameSites string
param dnsZoneNameStorage string
param logicAppPrivateLinkName string
param logicAppPrivateEndpointName string
param storageAccountPrivateLinkName string
param storageAccountPrivateEndpointName string
param logicAppName string
param defaultSubnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: defaultSubnetName
}

resource logicApp 'Microsoft.Web/sites@2020-12-01' existing = {
  name: logicAppName
}

module privateEndpointLogicAppModule './networkingPrivateEndpoint.bicep' = {
  name: 'private-endpoint-logic-app-deploy'
  params: {
    dnsZoneName: dnsZoneNameSites
    privateLinkName: logicAppPrivateLinkName
    privateEndpointName:logicAppPrivateEndpointName
    serviceId: logicApp.id
    groupId: 'sites'
    snetId: defaultSubnet.id
    vnetId: vnet.id 
    defaultSubnetName: defaultSubnetName
  }
  dependsOn: [
    vnet
    defaultSubnet
  ]
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

module privateEndpointStorageBlobModule './networkingPrivateEndpoint.bicep' = {
  name: 'private-endpoint-blob-deploy'
  params: {
    dnsZoneName: dnsZoneNameStorage
    privateLinkName: storageAccountPrivateLinkName
    privateEndpointName:storageAccountPrivateEndpointName
    serviceId: storageAccount.id
    groupId: 'blob'
    snetId: defaultSubnet.id
    vnetId: vnet.id 
    defaultSubnetName: defaultSubnetName
  }
  dependsOn: [
    vnet
    defaultSubnet
  ]
}
