// ============================================================================
// Dev environment parameters for Azure AI Foundry
// ============================================================================
using '../main.bicep'

param rgName = 'rg-foundry-aif-dev'
param location = 'eastus2'
param baseName = 'aifdev'
param environment = 'dev'

param projectName = 'aifdev-project'
param deploymentName = 'gpt-41-mini'
param modelName = 'gpt-4.1-mini'
param modelVersion = '2025-04-14'
param deploymentSkuName = 'GlobalStandard'
param deploymentCapacity = 1
