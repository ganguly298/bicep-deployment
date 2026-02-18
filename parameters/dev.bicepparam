using '../main.bicep'

param environment = 'dev'
param projectName = 'myapp'
param appServicePlanSku = 'B1' // Cost-conscious for dev
param pgAdminLogin = 'devadmin'
param pgAdminPassword = 'SuperSecretPassword123!' // Recommend passing this via Azure DevOps/GitHub Actions variables
