param logicAppAspName string
param logicAppAspSku object = {
  name: 'WS1'
  tier: 'WorkflowStandard'
  size: 'WS1'
  family: 'WS'
  capacity: 1
}
param logicAppName string
@description('Contains storage account API version, name and id to retrieve the connection string.')
param storageAccountDetails object

resource appServicePlanLogicApp 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: logicAppAspName
  location: resourceGroup().location
  sku: {
    name: logicAppAspSku.name
    tier: logicAppAspSku.tier
    size: logicAppAspSku.size
    family: logicAppAspSku.family
    capacity: logicAppAspSku.capacity
  }
  kind: 'elastic'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 20
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource appServiceLogicApp 'Microsoft.Web/sites@2018-11-01' = {
  name: logicAppName
  location: resourceGroup().location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${logicAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${logicAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanLogicApp.id
    reserved: false
    isXenon: false
    hyperV: false
    siteConfig: {
      numberOfWorkers: 1
      alwaysOn: false
      http20Enabled: false
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
  }
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountDetails.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountDetails.id, storageAccountDetails.apiVersion).keys[0].value}'

resource lgapp_appSettings 'Microsoft.Web/sites/config@2018-11-01' = {
  name: '${appServiceLogicApp.name}/appsettings'
  properties: {
    APP_KIND: 'workflowApp'
    AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
    AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
    AzureWebJobsStorage: storageAccountConnectionString
    FUNCTIONS_EXTENSION_VERSION: '~3'
    FUNCTIONS_WORKER_RUNTIME: 'node'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
    WEBSITE_CONTENTSHARE: '${logicAppName}fileshare'
    WEBSITE_NODE_DEFAULT_VERSION: '~12'
  }
}
