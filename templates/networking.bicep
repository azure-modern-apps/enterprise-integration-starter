param vnetName string
param logicAppSubnetName string
param apimSubnetName string
param applicationGatewaySubnetName string
param logicAppName string
param vnetAddressPrefix string
param defaultSnetAddressPrefix string
param logicAppsSnetAddressPrefix string
param applicationGatewaySnetAddressPrefix string
param dnsZoneNameSites string
param dnsZoneNameStorage string
param logicAppPrivateLinkName string
param logicAppPrivateEndpointName string
param storageAccountName string
param storageAccountPrivateLinkName string
param storageAccountPrivateEndpointName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    //Defining subnets in the same resource instead of seperate child properties so the subnet 
    //redeployment will not fail. 
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: defaultSnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: logicAppSubnetName
        properties: {
          addressPrefix: logicAppsSnetAddressPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: apimSubnetName
        properties: {
          addressPrefix: applicationGatewaySnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource logicApp 'Microsoft.Web/sites@2020-12-01' existing = {
  name: logicAppName
}

resource logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: logicAppSubnetName
}

resource logicAppAttachSubnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: logicApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: logicAppSubnet.id
  }
}

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: 'default'
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
  }
  dependsOn: [
    vnet
    defaultSubnet
  ]
}

