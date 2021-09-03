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
  }
}

//subnets
resource subnetDefault 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: vnet
  name: 'default'
  properties: {
    addressPrefix: networking.defaultSnetAddressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource subnetLogicApp 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: vnet
  name: logicAppSubnetName
  properties: {
    addressPrefix: networking.logicAppsSnetAddressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

// Existing Logic App
resource logicApp 'Microsoft.Web/sites@2020-12-01' existing = {
  name: logicAppName
}

//Attach logic app subnet
resource logicAppAttachSubnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: logicApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetLogicApp.id
  }
}




