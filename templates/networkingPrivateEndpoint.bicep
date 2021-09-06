param dnsZoneName string
param privateEndpointName string
param privateLinkName string
param groupId string
param serviceId string
param snetId string
param vnetId string

var location = resourceGroup().location

// Logic App Dns Zone and Private Endpoint
resource dnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnsZoneName
  location: 'global'
}

resource privateLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: dnsZone
  name: privateLinkName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: snetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: serviceId
          groupIds: [
            '${groupId}'
          ]
        }
      }
    ]
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: dnsZone.id
        }
      }
    ]
  }
}

