param vnetName string
param defaultSubnetName string
param vmName string
param networkInterfaceName string
param osDiskType string
param vmSize string
param vmImagePublisher string
param vmImageOffer string
param vmImageSku string
param vmImageVersion string

@secure()
param selfHostedRunnerVmAdminUserName string

@secure()
param selfHostedRunnerVmAdminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: defaultSubnetName
}

// Create the NIC in the default subnet for the self-hosted runner VM

resource selfHostedRunnerNic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: networkInterfaceName
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'vmAgentIpConfiguration'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: defaultSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
  dependsOn: [
    defaultSubnet
  ]
}


resource selfHostedRunnerVm 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmName
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: vmImageVersion
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: selfHostedRunnerVmAdminUserName
      adminPassword: selfHostedRunnerVmAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: selfHostedRunnerNic.id
        }
      ]
    }
  }
  dependsOn: [
    selfHostedRunnerNic
  ]
}
