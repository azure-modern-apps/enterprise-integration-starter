param vnetName string
param logicAppSubnetName string
param logicAppName string
param networking object
param dnsZoneNameSites string
param dnsZoneNameStorage string
param logicAppPrivateLinkName string
param logicAppPrivateEndpointName string


//vnet
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networking.vnetAddressPrefix
      ]
    }
    //Defining subnets in the same resource instead of seperate child properties so the subnet 
    //redeployment will not fail. 
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: networking.defaultSnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: logicAppSubnetName
        properties: {
          addressPrefix: networking.logicAppsSnetAddressPrefix
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
    ]
  }
}

// Existing Logic App
resource logicApp 'Microsoft.Web/sites@2020-12-01' existing = {
  name: logicAppName
}

// Existing Logic App Subnet
resource logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: logicAppSubnetName
}


//Attach logic app subnet
resource logicAppAttachSubnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: logicApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: logicAppSubnet.id
  }
}

// Logic App Dns Zone and Private Endpoint
resource dnsZoneSites 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnsZoneNameSites
  location: 'global'
  dependsOn: [
    vnet
    logicAppAttachSubnet
  ]
}

resource dnsZoneBlob 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnsZoneNameStorage
  location: 'global'
  dependsOn: [
    vnet
    logicAppAttachSubnet
  ]
}

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: 'default'
}

module privateEndpointLogicApp './networkingPrivateEndpoint.bicep' = {
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
