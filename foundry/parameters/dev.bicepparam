// ============================================================================
// Dev environment parameters for Azure AI Foundry
// ============================================================================
using '../main.bicep'

param rgName = 'rg-foundry-aif-dev'
param location = 'eastus2'
param baseName = 'aifdev'
param environment = 'dev'

param projectName = 'aifdev-project'
param deploymentName = 'deepseek-r1'
param modelName = 'DeepSeek-R1'
param modelFormat = 'DeepSeek'
param modelVersion = ''
param deploymentSkuName = 'GlobalStandard'
param deploymentCapacity = 1
