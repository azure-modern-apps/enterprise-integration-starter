param vnetName string
param logicAppSubnetName string
param logicAppName string
param networking object


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
