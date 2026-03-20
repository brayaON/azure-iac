// ============================================================================
// Azure ML Workspace Module
// Deploys: Storage · Key Vault · Container Registry · App Insights ·
//          AML Workspace · Compute Cluster
//
// Default datastore (workspaceblobstore) is auto-registered by Azure ML
// when the workspace is created — no manual registration needed.
// ============================================================================

param baseName    string
param location    string
param environment string

var suffix = take(uniqueString(resourceGroup().id), 6)

var storageAccountName = toLower(take('${baseName}st${suffix}', 24))
var keyVaultName       = toLower(take('${baseName}kv${suffix}', 24))
var acrName            = toLower(take('${baseName}acr${suffix}', 50))
var logAnalyticsName   = '${baseName}-logs'
var appInsightsName    = '${baseName}-insights'
var workspaceName      = '${baseName}-aml-ws'

// ─── 1. Storage Account ───────────────────────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
  tags: { environment: environment }
}

// ─── 2. Key Vault ─────────────────────────────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
  }
  tags: { environment: environment }
}

// ─── 3. Container Registry ────────────────────────────────────────────────────

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrName
  location: location
  sku: { name: 'Basic' }
  properties: { adminUserEnabled: false }
  tags: { environment: environment }
}

// ─── 4. Log Analytics ─────────────────────────────────────────────────────────

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    retentionInDays: 30
    sku: { name: 'PerGB2018' }
  }
  tags: { environment: environment }
}

// ─── 5. Application Insights ─────────────────────────────────────────────────

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
  tags: { environment: environment }
}

// ─── 6. Azure ML Workspace ────────────────────────────────────────────────────
// Azure ML automatically registers workspaceblobstore (pointing to the storage
// account above) and workspacefilestore as default datastores on creation.

resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: workspaceName
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {
    friendlyName: '${baseName} ML Workspace'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: appInsights.id
    containerRegistry: containerRegistry.id
  }
  tags: { environment: environment }
}

// ─── 7. Compute Cluster ───────────────────────────────────────────────────────

resource computeCluster 'Microsoft.MachineLearningServices/workspaces/computes@2024-04-01' = {
  parent: amlWorkspace
  name: 'cpu-cluster-01'
  location: location
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: 'Standard_DS3_v2'
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 4
        nodeIdleTimeBeforeScaleDown: 'PT120S'
      }
      osType: 'Linux'
      remoteLoginPortPublicAccess: 'Disabled'
    }
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────

output workspaceName      string = amlWorkspace.name
output workspaceId        string = amlWorkspace.id
output computeClusterName string = computeCluster.name
