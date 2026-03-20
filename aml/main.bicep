// ============================================================================
// Azure ML Workspace — Main Bicep
// ============================================================================
targetScope = 'subscription'

param rgName      string
param location    string = 'eastus'
param baseName    string = 'ai300dev'
param environment string = 'dev'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: {
    environment: environment
    managedBy: 'bicep'
  }
}

module workspace './modules/workspace.bicep' = {
  name: 'workspaceModule'
  scope: rg
  params: {
    baseName:    baseName
    location:    location
    environment: environment
  }
}

output workspaceName      string = workspace.outputs.workspaceName
output computeClusterName string = workspace.outputs.computeClusterName
