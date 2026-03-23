// ============================================================================
// Dev environment parameters for Azure AI Foundry
// ============================================================================
using '../main.bicep'

param rgName = 'rg-foundry-aif-dev'
param location = 'eastus2'
param baseName = 'aifdev'
param environment = 'dev'

param projectName = 'aifdev-project'
param modelDeployments = [
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
    modelFormat: 'Moonshot AI'
    modelVersion: '1'
    deploymentSkuName: 'GlobalStandard'
    deploymentCapacity: 1
  }
  {
    deploymentName: 'mistral-small-2503'
    modelName: 'Mistral-small-2503'
    modelFormat: 'Mistral AI'
    modelVersion: '1'
    deploymentSkuName: 'GlobalStandard'
    deploymentCapacity: 1
  }
]
