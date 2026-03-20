// ============================================================================
// Dev environment parameters
// Replace the object IDs below with real values from your Azure AD tenant.
//
// To find an object ID:
//   User:             az ad user show --id user@domain.com --query id -o tsv
//   Service Principal: az ad sp show --id <appId> --query id -o tsv
//   Group:            az ad group show --group "DevOps Team" --query id -o tsv
// ============================================================================
using '../main.bicep'

param rgName      = 'rg-aml-ai300-dev'
param location    = 'eastus2'
param baseName    = 'ai300dev'
param environment = 'dev'

// ─── Team principal object IDs ────────────────────────────────────────────────
param mariaPrincipalId   = 'ca966afd-a996-4ea3-a4d9-302d14b63762'
param carlosPrincipalId  = 'e4375a8c-4ab4-4be2-8d75-c3f3de2fb7b7'
param sarahPrincipalId   = 'ff506b31-2199-494e-a9b3-b11295dce557'
param cicdSpPrincipalId  = '1447cca8-e1c1-4390-989a-64f547d13078'
param devopsGroupObjectId = 'a60008df-e9e1-4a1c-9031-a287fb93c2cc'
