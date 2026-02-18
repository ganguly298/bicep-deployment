using '../main.bicep'

param environment = 'prod'
param projectName = 'myapp'
param appServicePlanSku = 'P1v3' // Production-grade SKU
param pgAdminLogin = 'prodadmin'
param pgAdminPassword = 'ProductionSecurePassword456!'
