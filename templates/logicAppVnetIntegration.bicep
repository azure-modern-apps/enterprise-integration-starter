param vnetName string
param logicAppSubnetName string
param logicAppName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: logicAppSubnetName
}

resource logicApp 'Microsoft.Web/sites@2020-12-01' existing = {
  name: logicAppName
}

resource logicAppAttachSubnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: logicApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: logicAppSubnet.id
  }
}
