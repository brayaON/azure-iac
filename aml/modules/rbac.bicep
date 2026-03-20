// ============================================================================
// RBAC Module — Team role assignments on the Azure ML Workspace
//
// KEY EXAM CONCEPT: Role assignments in Bicep use the roleAssignment resource.
// Each assignment needs:
//   - name:                 a deterministic GUID (use guid() function)
//   - roleDefinitionId:     the built-in role's resource ID
//   - principalId:          the object ID of the user/SP/group
//   - principalType:        User | ServicePrincipal | Group
//
// Scope: all assignments here are scoped to the workspace resource only.
// ============================================================================

param workspaceName string

// ─── Principal object IDs (passed in as parameters) ───────────────────────────
// In a real setup these come from your bicepparam file or Key Vault references.

@description('Object ID of Maria — Data Scientist')
param mariaPrincipalId string

@description('Object ID of Carlos — ML Engineer')
param carlosPrincipalId string

@description('Object ID of Sarah — Stakeholder')
param sarahPrincipalId string

@description('Object ID of the CI/CD Service Principal')
param cicdSpPrincipalId string

@description('Object ID of the DevOps Entra Security Group')
param devopsGroupObjectId string

// ─── Built-in role definition IDs ─────────────────────────────────────────────
// These IDs are fixed across all Azure tenants — safe to hardcode.
// KEY EXAM CONCEPT: Know these role names and what they allow/deny.

var roleIds = {
  Owner:                    subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Contributor:              subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Reader:                   subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  AzureMLDataScientist:     subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f6c7c914-8db3-469d-8ca1-694a8f32e121')
  AzureMLComputeOperator:   subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e503ece1-11d0-4e8e-8e2c-7a6c3bf38815')
}

// ─── Reference the existing workspace ─────────────────────────────────────────

resource workspace 'Microsoft.MachineLearningServices/workspaces@2024-04-01' existing = {
  name: workspaceName
}

// ─── Maria — AzureML Data Scientist ───────────────────────────────────────────
// Can: run experiments, submit jobs, register models
// Cannot: create compute, manage networking, assign roles

resource mariaRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, mariaPrincipalId, roleIds.AzureMLDataScientist)
  scope: workspace
  properties: {
    roleDefinitionId: roleIds.AzureMLDataScientist
    principalId: mariaPrincipalId
    principalType: 'User'
  }
}

// ─── Carlos — Contributor ─────────────────────────────────────────────────────
// Can: manage compute, deploy endpoints, create resources
// Cannot: manage role assignments

resource carlosRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, carlosPrincipalId, roleIds.Contributor)
  scope: workspace
  properties: {
    roleDefinitionId: roleIds.Contributor
    principalId: carlosPrincipalId
    principalType: 'User'
  }
}

// ─── Sarah — Reader ────────────────────────────────────────────────────────────
// Can: view experiments, metrics, model details
// Cannot: modify anything

resource sarahRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, sarahPrincipalId, roleIds.Reader)
  scope: workspace
  properties: {
    roleDefinitionId: roleIds.Reader
    principalId: sarahPrincipalId
    principalType: 'User'
  }
}

// ─── CI/CD Service Principal — AzureML Data Scientist ────────────────────────
// KEY EXAM CONCEPT: CI/CD pipelines authenticate as a Service Principal.
// principalType: 'ServicePrincipal' — different from 'User'.
// AzureML Data Scientist is enough to submit training jobs from GitHub Actions.

resource cicdRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, cicdSpPrincipalId, roleIds.AzureMLDataScientist)
  scope: workspace
  properties: {
    roleDefinitionId: roleIds.AzureMLDataScientist
    principalId: cicdSpPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ─── DevOps Team — Entra Security Group — Contributor ────────────────────────
// KEY EXAM CONCEPT: Assign roles to a GROUP, not individual users.
// principalType: 'Group' — avoids hitting subscription role assignment limits.
// Team leads manage group membership; no need to touch workspace IAM per person.

resource devopsGroupRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(workspace.id, devopsGroupObjectId, roleIds.Contributor)
  scope: workspace
  properties: {
    roleDefinitionId: roleIds.Contributor
    principalId: devopsGroupObjectId
    principalType: 'Group'
  }
}
