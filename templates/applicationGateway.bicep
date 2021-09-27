param applicationGatewayName string
param tier string
param skuSize string
param capacity int
param subnetName string
param publicIpAddressName string
param sku string
param allocationMethod string
param vnetName string
param apimName string

var frontEndPort80 = 'port_80'
var publicIpName = 'appGwPublicFrontendIp'
var backendPoolApim = 'backend-apim'
var backendHttp = 'http-backend'
var httpListenerApim = 'listener-backend-apim'
var routingApim = 'routing-backend-apim'
var healthProbeApim = 'health-probe-apim'
var apimHostName = '${apimName}.azure-api.net'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: subnetName
}

resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimName
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: resourceGroup().location
  sku: {
    name: sku
  }
  properties: {
    publicIPAllocationMethod: allocationMethod
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: applicationGatewayName
  location: resourceGroup().location
  properties: {
    sku: {
      name: skuSize
      tier: tier
      capacity: capacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: publicIpName
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontEndPort80
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolApim
        properties: {
          backendAddresses: [
            {
              fqdn: apim.properties.privateIPAddresses[0]
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: backendHttp
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
          hostName: apimHostName
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, healthProbeApim)
          }
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerApim
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, publicIpName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, frontEndPort80)
          }
          protocol: 'Http'
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: routingApim
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, httpListenerApim)
          }
          priority: null
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, backendPoolApim)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, backendHttp)
          }
        }
      }
    ]
    probes: [
      {
        name: healthProbeApim
        properties: {
          protocol: 'Http'
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {}
        }
      }
    ]
  }
}
