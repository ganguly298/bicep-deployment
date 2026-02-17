using '../main.bicep'

param environment = 'prod'
param location = 'eastus'
param projectName = 'secureapi'

// Production configurations (robust, scalable)
param appServiceSku = 'P1v3'              // Premium tier
param databaseSku = 'GP_Standard_D2ds_v4' // General Purpose
param enableBackup = true                  // Daily backups
param enableHighAvailability = true        // Zone redundancy
param minReplicas = 2                      // At least 2 instances