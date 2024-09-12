@description('Data Factory Name')
param dfName string

@description('Location of the data factory.')
param location string = resourceGroup().location

@description('Name of the Azure storage account that contains the input/output data.')
param saName string

@description('Name of the Azure Key Vault that contains the secret data.')
param kvName string

@description('URI of the Azure Key Vault that contains the secret data.')
param kvUri string

var dataFactoryLinkedServiceName = 'LS_SA_${saName}'
var dataFactoryName = '${dfName}${uniqueString(resourceGroup().id)}'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${kvName}/add'
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
  name: 'LS_KV_${kvName}'
  location: location
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
          referenceName: 'LS_KV_${kvName}'
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
