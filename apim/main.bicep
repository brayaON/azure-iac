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
    name: 'apimboftest'
    publisherEmail: 'bof.23402@mail.windowsazure.com'
    publisherName: 'bof-23402'
    // Non-required parameters
    location: location
    sku: 'Developer'
  }
}
