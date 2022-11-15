param name string
param location string
param applicationName string

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = { 'azd-env-name': name }
var abbrs = loadJsonContent('../abbreviations.json')

resource ai 'Microsoft.Insights/components@2020-02-02' existing = {
  name: '${abbrs.insightsComponents}${resourceToken}'
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: '${abbrs.storageAccount}${resourceToken}'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-10-01' existing = {
  name:  '${abbrs.hostingPlan}${resourceToken}'
}

resource redis 'Microsoft.Cache/Redis@2022-05-01' existing = {
  name: '${abbrs.redisName}${resourceToken}'
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: applicationName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: 'Node|18'
      
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        //  {
        //   name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        //   value: 'true'
        // }
        //  {
        //   name: 'ENABLE_ORYX_BUILD'
        //   value: 'true'
        // }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: ai.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_PROCESS_COUNT'
          value: '4'
        }
        {
          name: 'REDIS_HOST'
          value: redis.properties.hostName
        }
        {
          name: 'REDIS_KEY'
          value: redis.listKeys().primaryKey
        }
      ]
    }
  }
}

output application_url string = functionApp.properties.hostNames[0]
