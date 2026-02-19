targetScope = 'resourceGroup'

@description('Environment name (e.g., dev, prod)')
param environment string

@description('Primary location for all resources')
param location string = resourceGroup().location

@description('Project or application short name')
param projectName string

@description('SKU for the App Service Plan')
param appServicePlanSku string

@description('PostgreSQL Administrator Login')
param pgAdminLogin string

@secure()
@description('PostgreSQL Administrator Password')
param pgAdminPassword string

// Naming variables
var baseName = '${projectName}-${environment}'
var vnetName = 'vnet-${baseName}'
var lawName = 'law-${baseName}'
var appInsightsName = 'appi-${baseName}'
var kvName = 'kv-${baseName}-${uniqueString(resourceGroup().id)}'
var aspName = 'plan-${baseName}'
var frontendAppName = 'app-${baseName}-web'
var backendAppName = 'app-${baseName}-api'
var dbServerName = 'psql-${baseName}'

module network 'modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
    vnetName: vnetName
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deployment'
  params: {
    location: location
    lawName: lawName
    appInsightsName: appInsightsName
  }
}

module compute 'modules/compute.bicep' = {
  name: 'compute-deployment'
  params: {
    location: location
    appServicePlanName: aspName
    sku: appServicePlanSku
    frontendAppName: frontendAppName
    backendAppName: backendAppName
    frontendSubnetId: network.outputs.frontendSubnetId
    backendSubnetId: network.outputs.backendSubnetId
    appInsightsInstrumentationKey: monitoring.outputs.instrumentationKey
    dbPasswordSecretUri: ''  // Will be updated after security module
    dbServerName: dbServerName
    dbAdminLogin: pgAdminLogin
  }
}

module security 'modules/security.bicep' = {
  name: 'security-deployment'
  params: {
    location: location
    keyVaultName: kvName
    vnetId: network.outputs.vnetId
    privateEndpointSubnetId: network.outputs.privateEndpointSubnetId
    dbAdminPassword: pgAdminPassword
    backendAppPrincipalId: compute.outputs.backendPrincipalId
  }
}

module database 'modules/database.bicep' = {
  name: 'database-deployment'
  params: {
    location: location
    serverName: dbServerName
    adminLogin: pgAdminLogin
    adminPassword: pgAdminPassword
    vnetId: network.outputs.vnetId
    dbSubnetId: network.outputs.dbSubnetId
  }
}

// Update backend app settings with Key Vault secret URI
module computeUpdate 'modules/compute.bicep' = {
  name: 'compute-update-deployment'
  params: {
    location: location
    appServicePlanName: aspName
    sku: appServicePlanSku
    frontendAppName: frontendAppName
    backendAppName: backendAppName
    frontendSubnetId: network.outputs.frontendSubnetId
    backendSubnetId: network.outputs.backendSubnetId
    appInsightsInstrumentationKey: monitoring.outputs.instrumentationKey
    dbPasswordSecretUri: security.outputs.dbPasswordSecretUri
    dbServerName: dbServerName
    dbAdminLogin: pgAdminLogin
  }
}
