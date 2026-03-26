#!/bin/bash
# ============================================================================
# teardown.sh — Delete the AML test environment and purge soft-deleted resources
#
# Use this instead of manually deleting the RG. It captures resource names
# first, waits for the RG deletion, then purges soft-deleted KVs and AML
# workspaces so the next deployment can reuse the same names.
#
# Usage: ./aml/scripts/teardown.sh
# ============================================================================

set -euo pipefail

RG="rg-aml-ai300-dev"
LOCATION="eastus2"

echo "=================================================="
echo " Tearing down AML test environment"
echo " Resource Group: $RG"
echo "=================================================="
echo ""

# ─── 1. Capture KV names before the RG is gone ───────────────────────────────
echo "── Fetching Key Vault names in $RG..."
KV_NAMES=$(az keyvault list --resource-group "$RG" --query "[].name" -o tsv 2>/dev/null || echo "")

# ─── 2. Permanently delete AML workspaces before the RG ──────────────────────
# Must happen first — if the RG is deleted first, the workspace enters
# soft-delete and can't be purged via CLI.
echo "── Permanently deleting AML Workspaces in $RG..."
WS_NAMES=$(az ml workspace list --resource-group "$RG" --query "[].name" -o tsv 2>/dev/null || echo "")
if [[ -n "$WS_NAMES" ]]; then
  while IFS= read -r WS_NAME; do
    echo "   Deleting $WS_NAME..."
    az ml workspace delete --name "$WS_NAME" --resource-group "$RG" --permanently-delete --yes
    echo "   Deleted $WS_NAME"
  done <<< "$WS_NAMES"
fi

# ─── 3. Delete the resource group ────────────────────────────────────────────
echo "── Deleting resource group $RG..."
az group delete --name "$RG" --yes
echo "   Resource group deleted"

# ─── 4. Purge soft-deleted Key Vaults ────────────────────────────────────────
if [[ -n "$KV_NAMES" ]]; then
  echo ""
  echo "── Purging soft-deleted Key Vaults..."
  while IFS= read -r KV_NAME; do
    echo "   Purging $KV_NAME..."
    az keyvault purge --name "$KV_NAME" --location "$LOCATION"
    echo "   Purged $KV_NAME"
  done <<< "$KV_NAMES"
fi

echo ""
echo "=================================================="
echo " Done. Safe to redeploy."
echo "=================================================="
