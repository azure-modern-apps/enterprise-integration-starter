param applicationGatewayName string
param tier string
param skuSize string
param capacity int
param subnetName string
param publicIpAddressName string
param sku string
param allocationMethod string
param vnetName string
param logicAppName string

var frontEndPort80 = 'port_80'
var publicIpName = 'appGwPublicFrontendIp'
var backendPoolLogicApp = 'backend-logic-app'
var backendHttp = 'http-backend'
var httpListenerLogicApp = 'listener-backend-logic-app'
var routingLogicApp = 'routing-backend-logic-app'
var healthProbeLogicApp = 'health-probe-logicapp'
var logicAppHostName = '${logicAppName}.azurewebsites.net'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: subnetName
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
        name: backendPoolLogicApp
        properties: {
          backendAddresses: [
            {
              fqdn: logicAppHostName
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
          hostName: logicAppHostName
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, healthProbeLogicApp)
          }
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerLogicApp
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
        name: routingLogicApp
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, httpListenerLogicApp)
          }
          priority: null
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, backendPoolLogicApp)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, backendHttp)
          }
        }
      }
    ]
    probes: [
      {
        name: healthProbeLogicApp
        properties: {
          protocol: 'Http'
          host: logicAppHostName
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {}
        }
      }
    ]
  }
}
