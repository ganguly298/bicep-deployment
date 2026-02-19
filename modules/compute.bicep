param location string
param appServicePlanName string
param sku string
param frontendAppName string
param backendAppName string
param frontendSubnetId string
param backendSubnetId string
param appInsightsInstrumentationKey string
param dbPasswordSecretUri string
param dbServerName string
param dbAdminLogin string

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
  }
  properties: {
    reserved: true // Required for Linux
  }
}

resource frontendApp 'Microsoft.Web/sites@2022-09-01' = {
  name: frontendAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: asp.id
    virtualNetworkSubnetId: frontendSubnetId
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
      ]
    }
  }
}

resource backendApp 'Microsoft.Web/sites@2022-09-01' = {
  name: backendAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: asp.id
    virtualNetworkSubnetId: backendSubnetId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'DB_HOST'
          value: '${dbServerName}.postgres.database.azure.com'
        }
        {
          name: 'DB_USER'
          value: dbAdminLogin
        }
        {
          name: 'DB_PASSWORD'
          value: '@Microsoft.KeyVault(SecretUri=${dbPasswordSecretUri})'
        }
      ]
    }
  }
}

output backendPrincipalId string = backendApp.identity.principalId
