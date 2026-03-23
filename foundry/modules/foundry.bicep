// ============================================================================
// Azure AI Foundry Module
// Deploys: Foundry account resource · project · OpenAI model deployment
// ============================================================================

param baseName string
param location string
param environment string
param projectName string
param modelDeployments array

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
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: projectName
    description: 'Azure AI Foundry project for ${environment}'
  }
  tags: {
    environment: environment
  }
}

@batchSize(1)
resource modelDeploymentsResource 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [for deployment in modelDeployments: {
  parent: foundryAccount
  name: deployment.deploymentName
  sku: {
    name: deployment.deploymentSkuName
    capacity: deployment.deploymentCapacity
  }
  properties: {
    model: {
      format: deployment.modelFormat
      name: deployment.modelName
      version: deployment.modelVersion
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
  }
}]

output accountName string = foundryAccount.name
output accountId string = foundryAccount.id
output projectResourceName string = foundryProject.name
output deploymentResourceNames array = [for deployment in modelDeployments: deployment.deploymentName]
