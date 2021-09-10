param apimName string 
param logicAppName string 
param vnetName string
param apimSkuName string
param apimSkuCapacity int
param apimSubnetName string
param publisherUserEmail string
param publisherName string
param notificationSenderEmail string
param apimResourcePrefix string

var logicAppBackendName = '${logicAppName}-backend'
var logicAppNameValueName = '${logicAppName}-name-value'
var logicAppNameValueTemplatePath = '${logicAppNameValueName}-template-path'
var logicAppHostName = 'https://${logicAppName}.azurewebsites.net'
var logicAppSchemaId = '${logicAppName}-schema'


resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource logicApp 'Microsoft.Web/sites@2020-12-01' existing = {
  name: logicAppName
}
resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apimName
  location: resourceGroup().location
  sku: {
    name: apimSkuName
    capacity: apimSkuCapacity
  }
  properties: {
    publisherEmail: publisherUserEmail
    publisherName: publisherName
    notificationSenderEmail: notificationSenderEmail
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${apimName}.azure-api.net'
      }
    ]
    virtualNetworkConfiguration: {
      subnetResourceId: '${vnet.id}/subnets/${apimSubnetName}'
    }
    virtualNetworkType: 'Internal'
  }
}

resource logicAppApi 'Microsoft.ApiManagement/service/apis@2021-01-01-preview' = {
  parent: apim
  name: logicAppName
  properties: {
    displayName: logicAppName
    apiRevision: '1'
    description: logicAppName
    subscriptionRequired: true
    serviceUrl: logicAppHostName
    path: 'logicapp'
    protocols: [
      'https'
    ]
    isCurrent: true
  }
}

resource logicAppBackend 'Microsoft.ApiManagement/service/backends@2021-01-01-preview' = {
  parent: apim
  name: logicAppBackendName
  properties: {
    description: logicAppName
    url: logicAppHostName
    protocol: 'http'
    resourceId: '${apimResourcePrefix}/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${logicAppName}'
  }
}

resource logicAppServiceProperty 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apim
  name: logicAppNameValueName
  properties: {
    displayName: logicAppNameValueTemplatePath
    value: 'Workflow signature placeholder.'
    tags: []
    secret: true
  }
}

resource logicAppApiSchema 'Microsoft.ApiManagement/service/apis/schemas@2021-01-01-preview' = {
  parent: logicAppApi
  name: logicAppSchemaId
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }
  dependsOn: [
    apim
  ]
}

resource logicAppApiOperation 'Microsoft.ApiManagement/service/apis/operations@2021-01-01-preview' = {
  parent: logicAppApi
  name: 'request-invoke'
  properties: {
    displayName: 'request-invoke'
    method: 'POST'
    urlTemplate: '/request/paths/invoke'
    templateParameters: []
    description: 'Trigger a run of the logic app.'
    request: {
      description: 'The request body.'
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          schemaId: logicAppSchemaId
          typeName: 'request-request'
          sample: '{}'
        }
      ]
    }
    responses: [
      {
        statusCode: 200
        description: 'The Logic App Response.'
        representations: [
          {
            contentType: 'application/json'
            schemaId: logicAppSchemaId
            typeName: 'RequestPathsInvokePost200ApplicationJsonResponse'
            sample: '{}'
          }
        ]
        headers: []
      }
      {
        statusCode: 500
        description: 'The Logic App Response.'
        representations: [
          {
            contentType: 'application/json'
            schemaId: logicAppSchemaId
            typeName: 'RequestPathsInvokePost500ApplicationJsonResponse'
            sample: '{}'
          }
        ]
        headers: []
      }
    ]
  }
  dependsOn: [
    apim
    logicAppApiSchema
  ]
}

resource logicAppApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-01-01-preview' = {
  parent: logicAppApi
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service id="apim-generated-policy" backend-id="${logicAppBackendName}" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    apim
    logicAppBackend
  ]
}

resource logicAppApiOperationPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-01-01-preview' = {
  parent: logicAppApiOperation
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-method id="apim-generated-policy">POST</set-method>\r\n    <rewrite-uri id="apim-generated-policy" template="{{${logicAppNameValueTemplatePath}}}" />\r\n    <set-header id="apim-generated-policy" name="Ocp-Apim-Subscription-Key" exists-action="delete" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    logicAppApi
    apim
    logicAppServiceProperty
  ]
}
