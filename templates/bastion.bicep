param vnetName string
param bastionSubnetName string
param bastionName string
param bastionPublicIpAddressName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: bastionSubnetName
}

resource bastionPublicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: bastionPublicIpAddressName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionName
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfiguration'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]  
  }
  dependsOn: [
    vnet
  ]
}
