// ============================================================================
// Azure AI Foundry Module
// Deploys: Foundry account resource · project · OpenAI model deployment
// ============================================================================

param baseName string
param location string
param environment string
param projectName string
param deploymentName string
param modelName string
param modelVersion string

@allowed([
  'GlobalStandard'
  'Standard'
])
param deploymentSkuName string

@minValue(1)
param deploymentCapacity int

var suffix = take(uniqueString(resourceGroup().id), 6)
var accountName = toLower(take(replace('${baseName}fd${suffix}', '-', ''), 24))
var customSubDomainName = accountName

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: accountName
  location: location
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: customSubDomainName
    disableLocalAuth: false
    dynamicThrottlingEnabled: false
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: false
  }
  tags: {
    environment: environment
  }
}

resource foundryProject 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  parent: foundryAccount
  name: projectName
  location: location
  properties: {
    displayName: projectName
    description: 'Azure AI Foundry project for ${environment}'
  }
}

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: foundryAccount
  name: deploymentName
  sku: {
    name: deploymentSkuName
    capacity: deploymentCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      publisher: 'OpenAI'
      version: modelVersion
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
  }
}

output accountName string = foundryAccount.name
output accountId string = foundryAccount.id
output projectResourceName string = foundryProject.name
output deploymentResourceName string = modelDeployment.name
