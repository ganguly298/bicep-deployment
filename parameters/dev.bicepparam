using '../main.bicep'  // ← Links to which template this is for

// Environment-specific parameters
param environment = 'dev'
param location = 'eastus'
param projectName = 'secureapi'

// Dev-specific configurations (small, cheap)
param appServiceSku = 'B1'           // Basic tier
param databaseSku = 'B_Standard_B1ms' // Burstable tier
param enableBackup = false            // No backup in dev
param enableHighAvailability = false  // Single instance
