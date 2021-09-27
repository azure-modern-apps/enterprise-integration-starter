param vnetName string
param logicAppSubnetName string
param apimSubnetName string
param applicationGatewaySubnetName string
param defaultSubnetName string
param vnetAddressPrefix string
param defaultSnetAddressPrefix string
param logicAppsSnetAddressPrefix string
param apimSnetAddressPrefix string
param applicationGatewaySnetAddressPrefix string
param bastionSubnetAddressPrefix string
param bastionSubnetName string

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
        name: defaultSubnetName
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
          addressPrefix: apimSnetAddressPrefix
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
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
        }
      }
    ]
  }
}
