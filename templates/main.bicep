param storageAccountName string
param storageAccountType string
param logicAppName string
param logicAppAspName string
param logicAppAspSku object
param vnetName string
param logicAppSubnetName string
param networking object

module storageAccountModule './storageAccount.bicep' = {
  name: 'rg-deploy-${storageAccountName}'
  params: {
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
  }
}

module logicAppModule './logicApp.bicep' = {
  name: 'rg-deploy-${logicAppName}'
  params: {
    logicAppAspName: logicAppAspName
    logicAppAspSku: logicAppAspSku
    logicAppName: logicAppName
    storageAccountDetails: storageAccountModule.outputs.storageAccountDetails
  }
  dependsOn: [
    storageAccountModule
  ]
}

module networkingModule './networking.bicep' = {
  name: 'rg-deploy-vnet'
  params: {
    vnetName: vnetName
    logicAppSubnetName: logicAppSubnetName
    logicAppName: logicAppName
    networking: networking
  }
  dependsOn: [
    logicAppModule
  ]
}
