param location string = resourceGroup().location
param kvName string

@description('Resource ID of the Azure Storage Account')
param saId string

@description('Name of the Azure storage account that contains the input/output data.')
param saName string

var pipelineId = '1b9d3e57-a455-4e73-ad7a-8dd331f2819b'
var brayanId = 'ccb234c6-838f-4d75-8332-e025d9806031'
var tenantId = '9c07eaa2-cdd5-41ba-a19e-9d59e54a7593'
var saKey = listKeys(saId, '2021-09-01').keys[0].value

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    tenantId: tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    accessPolicies: [
      {
        objectId: pipelineId
        tenantId: tenantId
        permissions: {
          keys: ['list', 'get', 'delete']
          secrets: ['list', 'get', 'set', 'delete']
        }
      }
      {
        objectId: brayanId
        tenantId: tenantId
        permissions: {
          keys: ['list', 'get', 'delete']
          secrets: ['list', 'get', 'set', 'delete']
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource saConnStr 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'saconnstr'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${saName};AccountKey=${saKey}'
  }
}

output uri string = kv.properties.vaultUri
