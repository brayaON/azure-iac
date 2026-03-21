// ============================================================================
// Azure ML Workspace — Main Bicep
// ============================================================================
targetScope = 'subscription'

param rgName      string
param location    string = 'eastus'
param baseName    string = 'ai300dev'
param environment string = 'dev'

// Generates a new random 3-char suffix on each deployment to avoid Key Vault
// and AML workspace 90-day soft-delete purge conflicts on recreate.
param randomSuffix string = substring(newGuid(), 0, 3)

// ─── RBAC principal IDs ───────────────────────────────────────────────────────
// Pass these via dev.bicepparam — never hardcode object IDs in templates.

@description('Object ID of Maria — Data Scientist')
param mariaPrincipalId string = ''

@description('Object ID of Carlos — ML Engineer')
param carlosPrincipalId string = ''

@description('Object ID of Sarah — Stakeholder')
param sarahPrincipalId string = ''

@description('Object ID of the CI/CD Service Principal')
param cicdSpPrincipalId string = ''

@description('Object ID of the DevOps Entra Security Group')
param devopsGroupObjectId string = ''

// ─── Resource Group ───────────────────────────────────────────────────────────

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: {
    environment: environment
    managedBy: 'bicep'
  }
}

// ─── Workspace Module ─────────────────────────────────────────────────────────

module workspace './modules/workspace.bicep' = {
  name: 'workspaceModule'
  scope: rg
  params: {
    baseName:    baseName
    location:    location
    environment: environment
    randomSuffix: randomSuffix
  }
}

// ─── CI/CD SP — User Access Administrator on RG ───────────────────────────────
// Required so the CI/CD SP can write role assignments (e.g. AcrPull on ACR)
// during deployments. Scoped to the resource group, not the subscription.

module cicdUaaRg './modules/cicd-uaa.bicep' = if (!empty(cicdSpPrincipalId)) {
  name: 'cicdUaaModule'
  scope: rg
  params: {
    cicdSpPrincipalId: cicdSpPrincipalId
    rgId: rg.id
  }
}

// ─── RBAC Module ──────────────────────────────────────────────────────────────
// Only deployed when principal IDs are provided.
// Condition check prevents empty-string assignments from erroring.

module rbac './modules/rbac.bicep' = if (!empty(mariaPrincipalId)) {
  name: 'rbacModule'
  scope: rg
  params: {
    workspaceName:      workspace.outputs.workspaceName
    mariaPrincipalId:   mariaPrincipalId
    carlosPrincipalId:  carlosPrincipalId
    sarahPrincipalId:   sarahPrincipalId
    cicdSpPrincipalId:  cicdSpPrincipalId
    devopsGroupObjectId: devopsGroupObjectId
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────

output workspaceName      string = workspace.outputs.workspaceName
output computeClusterName string = workspace.outputs.computeClusterName
