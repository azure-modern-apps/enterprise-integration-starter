param vnetName string
param subnets object
param bastionProperties object
param selfHostedRunnerProperties object

// These come from secrets in the Repo

@secure()
param selfHostedRunnerVmAdminUserName string

@secure()
param selfHostedRunnerVmAdminPassword string

var defaultSubnetName = 'default'

// Bastion must have its own subnet with this name
var bastionSubnetName = 'AzureBastionSubnet'

module networkingModule './networking.bicep' = {
  name: 'rg-deploy-vnet'
  params: {
    vnetName: vnetName
    logicAppSubnetName: subnets.logicAppSubnetName
    apimSubnetName: subnets.apimSubnetName
    applicationGatewaySubnetName: subnets.applicationGatewaySubnetName
    vnetAddressPrefix: subnets.vnetAddressPrefix
    defaultSnetAddressPrefix: subnets.defaultSnetAddressPrefix
    logicAppsSnetAddressPrefix: subnets.logicAppsSnetAddressPrefix
    apimSnetAddressPrefix: subnets.apimSnetAddressPrefix
    applicationGatewaySnetAddressPrefix: subnets.applicationGatewaySnetAddressPrefix
    bastionSubnetAddressPrefix: subnets.bastionSubnetAddressPrefix
    bastionSubnetName: bastionSubnetName
    defaultSubnetName: defaultSubnetName
  }
}

module bastionModule './bastion.bicep' = {
  name: 'rg-deploy-bastion'
  params: {
    vnetName: vnetName
    bastionSubnetName: bastionSubnetName
    bastionName: bastionProperties.bastionName
    bastionPublicIpAddressName: bastionProperties.publicIpAddressName
  }
}

module selfHostedRunnerVm './runnerVm.bicep' = {
  name: 'rg-deploy-runnerVm'
  params: {
    vnetName: vnetName
    defaultSubnetName: defaultSubnetName
    vmName: selfHostedRunnerProperties.vmName
    networkInterfaceName: selfHostedRunnerProperties.networkInterfaceName
    osDiskType : selfHostedRunnerProperties.osDiskType
    vmSize : selfHostedRunnerProperties.vmSize
    vmImagePublisher : selfHostedRunnerProperties.imageReference.publisher
    vmImageOffer : selfHostedRunnerProperties.imageReference.offer
    vmImageSku : selfHostedRunnerProperties.imageReference.sku
    vmImageVersion : selfHostedRunnerProperties.imageReference.version
    selfHostedRunnerVmAdminUserName: selfHostedRunnerVmAdminUserName
    selfHostedRunnerVmAdminPassword: selfHostedRunnerVmAdminPassword
  }
}
