param dfName string
param location string = resourceGroup().location
param saName string
param kvName string
param kvUri string

var dataFactoryLinkedServiceName = 'LS_SA_${saName}'
var dataFactoryName = '${dfName}-${uniqueString(resourceGroup().id)}'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${kvName}-${uniqueString(resourceGroup().id)}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: dataFactory.identity.principalId
        permissions: {
          secrets: [
            'get' // Allow ADF to read secrets
            'list'
          ]
        }
      }
    ]
  }
}

resource kvLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'LS_KV_${kvName}-${uniqueString(resourceGroup().id)}'
  properties: {
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: kvUri
    }
  }
}

resource dataFactoryLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: dataFactoryLinkedServiceName
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        secretName: 'saconnstr'
        store: {
          type: 'LinkedServiceReference'
          referenceName: 'LS_KV_${kvName}-${uniqueString(resourceGroup().id)}'
        }
      }
    }
  }

  dependsOn: [
    keyVaultAccessPolicy
  ]
}

output name string = dataFactory.name
output resourceId string = dataFactory.id
