// ============================================================================
// Azure AI Foundry — Main Bicep
// ============================================================================
targetScope = 'subscription'

param rgName string
param location string = 'eastus2'
param baseName string = 'aifdev'
param environment string = 'dev'

// Accepted for compatibility with the shared GitHub Actions deployment template.
// This stack does not currently need it.
param randomSuffix string = ''

@description('Azure AI Foundry project display name suffix.')
param projectName string = '${baseName}-project'

@description('Model deployment name used by applications.')
param deploymentName string = 'deepseek-r1'

@description('Base model to deploy to the Foundry resource.')
param modelName string = 'DeepSeek-R1'

@description('Model provider/format as exposed by Azure AI Foundry model listings.')
@allowed([
  'DeepSeek'
  'OpenAI'
  'Microsoft'
  'Meta'
  'Mistral AI'
  'Cohere'
  'AI21 Labs'
  'Core42'
  'xAI'
])
param modelFormat string = 'DeepSeek'

@description('Optional pinned model version. Leave empty to let Azure choose the default available version.')
param modelVersion string = ''

@description('Deployment SKU. GlobalStandard is the safest default for gpt-4.1-mini availability.')
@allowed([
  'GlobalStandard'
  'Standard'
])
param deploymentSkuName string = 'GlobalStandard'

@description('Deployment capacity units. Keep at 1 unless quota planning requires more.')
@minValue(1)
param deploymentCapacity int = 1

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: {
    environment: environment
    managedBy: 'bicep'
  }
}

module foundry './modules/foundry.bicep' = {
  name: 'foundryModule'
  scope: rg
  params: {
    baseName: baseName
    location: location
    environment: environment
    projectName: projectName
    deploymentName: deploymentName
    modelName: modelName
    modelFormat: modelFormat
    modelVersion: modelVersion
    deploymentSkuName: deploymentSkuName
    deploymentCapacity: deploymentCapacity
  }
}

output accountName string = foundry.outputs.accountName
output projectResourceName string = foundry.outputs.projectResourceName
output deploymentResourceName string = foundry.outputs.deploymentResourceName
output accountId string = foundry.outputs.accountId
