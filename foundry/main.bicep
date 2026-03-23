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

@description('List of model deployments to create in the Foundry account.')
param modelDeployments array = [
  {
    deploymentName: 'deepseek-r1'
    modelName: 'DeepSeek-R1'
    modelFormat: 'DeepSeek'
    modelVersion: '1'
    deploymentSkuName: 'GlobalStandard'
    deploymentCapacity: 1
  }
  {
    deploymentName: 'grok-3-mini'
    modelName: 'grok-3-mini'
    modelFormat: 'xAI'
    modelVersion: '1'
    deploymentSkuName: 'GlobalStandard'
    deploymentCapacity: 1
  }
  {
    deploymentName: 'phi-4'
    modelName: 'Phi-4'
    modelFormat: 'Microsoft'
    modelVersion: '7'
    deploymentSkuName: 'GlobalStandard'
    deploymentCapacity: 1
  }
  {
    deploymentName: 'kimi-k2-thinking'
    modelName: 'Kimi-K2-Thinking'
    modelFormat: 'MoonshotAI'
    modelVersion: '1'
    deploymentSkuName: 'GlobalStandard'
    deploymentCapacity: 1
  }
  {
    deploymentName: 'mistral-large-3'
    modelName: 'Mistral-Large-3'
    modelFormat: 'Mistral AI'
    modelVersion: '1'
    deploymentSkuName: 'GlobalStandard'
    deploymentCapacity: 1
  }
]

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
    modelDeployments: modelDeployments
  }
}

output accountName string = foundry.outputs.accountName
output projectResourceName string = foundry.outputs.projectResourceName
output deploymentResourceNames array = foundry.outputs.deploymentResourceNames
output accountId string = foundry.outputs.accountId
