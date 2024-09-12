param rgName string
param location string = 'eastus2'
param kvName string
param containerName string
param saName string
param dfName string

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

module sa './modules/sa.bicep' = {
  name: 'saModule'
  scope: rg
  params: {
    containerName: containerName
    saName: saName
  }
}

module kv './modules/kv.bicep' = {
  name: 'kvModule'
  scope: rg
  params: {
    kvName: kvName
    saId: sa.outputs.id
    saName: sa.outputs.name
  }

  dependsOn: [
    sa
  ]
}

module adf './modules/adf.bicep' = {
  name: 'adfModule'
  scope: rg
  params: {
    dfName: dfName
    saName: sa.outputs.name
    kvName: kvName
    kvUri: kv.outputs.uri
  }

  dependsOn: [
    kv
  ]
}
