// PARAMETERS
param location string
param resourcePrefix string
param tags object
param vnetAddressPrefix string = '10.0.0.0/16'  // Default CIDR

// VARIABLES
var vnetName = '${resourcePrefix}-vnet'
var subnets = [
  {
    name: 'subnet-frontend'
    addressPrefix: '10.0.1.0/24'
    serviceEndpoints: ['Microsoft.Web']
  }
  {
    name: 'subnet-backend'
    addressPrefix: '10.0.2.0/24'
    serviceEndpoints: ['Microsoft.Web', 'Microsoft.KeyVault']
  }
  {
    name: 'subnet-database'
    addressPrefix: '10.0.3.0/24'
    serviceEndpoints: ['Microsoft.Sql']
    delegations: [{
      name: 'delegation'
      properties: {
        serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
      }
    }]
  }
]

// RESOURCES
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressPrefix]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: [for endpoint in subnet.serviceEndpoints: {
          service: endpoint
        }]
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
      }
    }]
  }
}

// OUTPUTS
output vnetId string = vnet.id
output vnetName string = vnet.name
output frontendSubnetId string = vnet.properties.subnets[0].id
output backendSubnetId string = vnet.properties.subnets[1].id
output dbSubnetId string = vnet.properties.subnets[2].id
