param vnetName string
param logicAppSubnetName string
param logicAppName string
param networking object
param dnsZoneName string
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
resource dnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnsZoneName
  location: 'global'
  dependsOn: [
    vnet
    logicAppAttachSubnet
  ]
}

resource privateLinkLogicApp 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: dnsZone
  name: logicAppPrivateLinkName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// Existing Logic App Subnet
resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: 'default'
}


resource privateEndpointLogicApp 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: logicAppPrivateEndpointName
  location: resourceGroup().location
  properties: {
    subnet: {
      id: defaultSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: logicAppPrivateEndpointName
        properties: {
          privateLinkServiceId: logicApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

