param rgName string
param location string = 'eastus2'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

module service 'br/public:avm/res/api-management/service:0.1.0' = {
  name: 'serviceDeployment'
  scope: rg
  params: {
    // Required parameters
    name: 'apim-01-${uniqueString(rg.id)}'
    publisherEmail: 'bof_devops@mail.com'
    publisherName: 'bof_devops'
    // Non-required parameters
    location: location
    sku: 'Developer'
  }
}
