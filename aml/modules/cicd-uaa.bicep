// ============================================================================
// CI/CD SP — User Access Administrator on Resource Group
//
// Grants the CI/CD service principal the ability to write role assignments
// within the resource group (e.g. AcrPull on ACR during workspace deployment).
// ============================================================================

param cicdSpPrincipalId string
param rgId              string

var userAccessAdminRoleId = '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'

resource cicdUaa 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(rgId, cicdSpPrincipalId, userAccessAdminRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', userAccessAdminRoleId)
    principalId: cicdSpPrincipalId
    principalType: 'ServicePrincipal'
  }
}
