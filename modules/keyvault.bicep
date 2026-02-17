// PARAMETERS
param location string
param resourcePrefix string
param tags object
param enablePurgeProtection bool = true  // Production best practice

// VARIABLES
var keyVaultName = '${resourcePrefix}-kv-${uniqueString(resourceGroup().id)}'

// RESOURCES
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: true  // Use RBAC instead of access policies
    networkAcls: {
      defaultAction: 'Deny'  // Deny by default, allow specific networks
      bypass: 'AzureServices'
    }
  }
}

// OUTPUTS
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
