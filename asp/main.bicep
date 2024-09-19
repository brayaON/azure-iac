param rgName string
param location string = 'eastus2'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

var sitesCount = 2

module sites 'br/public:avm/res/web/site:0.8.0' = [
  for i in range(0, sitesCount): {
    name: 'site${i}Deployment'
    scope: rg
    params: {
      // Required parameters
      kind: 'app,linux,container'
      name: 'apisite${i}${uniqueString(rg.id)}'
      serverFarmResourceId: serverfarm.outputs.resourceId
      // Non-required parameters
      location: location
      siteConfig: {
        appSettings: [
          {
            name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
            value: 'false'
          }
        ]
        linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
      }
    }
  }
]

module serverfarm 'br/public:avm/res/web/serverfarm:0.2.2' = {
  name: 'serverfarmDeployment'
  scope: rg
  params: {
    // Required parameters
    name: 'asplinux001'
    skuCapacity: 1
    skuName: 'B1'
    // Non-required parameters
    kind: 'Linux'
    location: location
    tags: {
      Environment: 'Non-Prod'
    }
    zoneRedundant: false
  }
}
