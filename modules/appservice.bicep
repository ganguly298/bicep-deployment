@description('Azure location')
param location string

@description('Resource prefix')
param resourcePrefix string

@description('Tags')
param tags object

@description('Environment')
@allowed(['dev','staging','prod'])
param environment string

@description('Subnet ID for App Service VNet Integration (delegated to Microsoft.Web/serverFarms)')
param appSubnetId string

@description('App Service Plan SKU (B1/S1/P1v3 etc.)')
param appServiceSkuName string

@description('Linux runtime stack (linuxFxVersion), e.g. NODE|20-lts')
param linuxFxVersion string

@description('Key Vault URI (for reference usage and clarity)')
param keyVaultUri string

@description('Secret URI for DB connection string (Key Vault secretUri). If empty, DB setting is not added.')
param dbConnectionSecretUri string

@description('Application Insights connection string')
param appInsightsConnectionString string

var planName = '${resourcePrefix}-asp'
var webAppName = '${resourcePrefix}-web'

resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  tags: tags
  sku: {
    name: appServiceSkuName
    tier: contains(['B1','B2','B3'], appServiceSkuName) ? 'Basic' : contains(['S1','S2','S3'], appServiceSkuName) ? 'Standard' : 'PremiumV3'
    capacity: environment == 'prod' ? 2 : 1
  }
  properties: {
    reserved: true // Linux
  }
}

resource web 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true

    // Allows Key Vault references to use system-assigned identity
    keyVaultReferenceIdentity: 'SystemAssigned'

    siteConfig: {
      linuxFxVersion: linuxFxVersion
      ftpsState: 'Disabled'
      alwaysOn: environment == 'prod'
      http20Enabled: true

      appSettings: union([
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: appInsightsConnectionString
          }
          {
            name: 'KeyVaultUri'
            value: keyVaultUri
          }
        ], dbConnectionSecretUri != '' ? [{ name: 'DB_CONNECTION_STRING', value: '@Microsoft.KeyVault(SecretUri=${dbConnectionSecretUri})' }] : [])
    }
  }
}

// Regional VNet Integration via networkConfig child
resource vnetConfig 'Microsoft.Web/sites/networkConfig@2022-09-01' = {
  parent: web
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: appSubnetId
    swiftSupported: true
  }
}

// Outputs
output webAppId string = web.id
output webAppName string = web.name
output webAppUrl string = 'https://${web.properties.defaultHostName}'
output webAppPrincipalId string = web.identity.principalId
