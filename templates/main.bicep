param storageAccountName string
param storageAccountType string
param logicAppName string
param logicAppAspName string
param logicAppAspSku object

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
