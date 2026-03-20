#!/bin/bash
# ============================================================================
# create-test-users.sh — Create test identities in Entra ID
#
# Creates:
#   - Maria    → test user (Data Scientist)
#   - Carlos   → test user (ML Engineer)
#   - Sarah    → test user (Stakeholder)
#   - ci-cd-sp → service principal (GitHub Actions)
#   - DevOps Team → Entra Security Group (contains Carlos)
#
# Usage:
#   ./aml/scripts/create-test-users.sh <your-domain>
#   Example: ./aml/scripts/create-test-users.sh contoso.onmicrosoft.com
#
# After running, copy the printed object IDs into aml/parameters/dev.bicepparam
# ============================================================================

set -euo pipefail

DOMAIN="${1:?Usage: create-test-users.sh <your-entra-domain> e.g. contoso.onmicrosoft.com}"
TEMP_PASSWORD="TempPass@2026!"   # Users will be prompted to change on first login

echo "=================================================="
echo " Creating test identities in Entra ID"
echo " Domain: $DOMAIN"
echo "=================================================="
echo ""

# ─── Users ────────────────────────────────────────────────────────────────────

create_user() {
  local DISPLAY_NAME="$1"
  local UPN="$2"
  local MAIL_NICKNAME="$3"

  echo "── Creating user: $DISPLAY_NAME ($UPN)..."

  # Check if user already exists
  EXISTING=$(az ad user list --upn "$UPN" --query "[0].id" -o tsv 2>/dev/null || echo "")
  if [[ -n "$EXISTING" ]]; then
    echo "   Already exists — skipping creation"
    echo "$EXISTING"
    return
  fi

  az ad user create \
    --display-name "$DISPLAY_NAME" \
    --user-principal-name "$UPN" \
    --mail-nickname "$MAIL_NICKNAME" \
    --password "$TEMP_PASSWORD" \
    --force-change-password-next-sign-in true \
    --query id \
    --output tsv
}

MARIA_ID=$(create_user \
  "Maria Gonzalez (Data Scientist)" \
  "maria.gonzalez@$DOMAIN" \
  "maria.gonzalez")
echo "✓ Maria object ID: $MARIA_ID"
echo ""

CARLOS_ID=$(create_user \
  "Carlos Mendez (ML Engineer)" \
  "carlos.mendez@$DOMAIN" \
  "carlos.mendez")
echo "✓ Carlos object ID: $CARLOS_ID"
echo ""

SARAH_ID=$(create_user \
  "Sarah Chen (Stakeholder)" \
  "sarah.chen@$DOMAIN" \
  "sarah.chen")
echo "✓ Sarah object ID: $SARAH_ID"
echo ""

# ─── Security Group (DevOps Team) ─────────────────────────────────────────────
# KEY EXAM CONCEPT: Assign roles to groups, not individuals.
# Carlos (ML Engineer) is added to the DevOps group for infra access.

echo "── Creating DevOps Team security group..."

EXISTING_GROUP=$(az ad group list --display-name "DevOps Team" --query "[0].id" -o tsv 2>/dev/null || echo "")
if [[ -n "$EXISTING_GROUP" ]]; then
  echo "   Group already exists — skipping creation"
  GROUP_ID="$EXISTING_GROUP"
else
  GROUP_ID=$(az ad group create \
    --display-name "DevOps Team" \
    --mail-nickname "devops-team" \
    --query id \
    --output tsv)
fi

echo "✓ DevOps Team group object ID: $GROUP_ID"

# Add Carlos to the DevOps group
echo "── Adding Carlos to DevOps Team group..."
az ad group member add \
  --group "$GROUP_ID" \
  --member-id "$CARLOS_ID" 2>/dev/null || echo "   Already a member"
echo "✓ Carlos added to DevOps Team"
echo ""

# ─── Output — copy these into dev.bicepparam ──────────────────────────────────

echo "=================================================="
echo " Done! Copy these into aml/parameters/dev.bicepparam"
echo "=================================================="
echo ""
echo "param mariaPrincipalId    = '$MARIA_ID'"
echo "param carlosPrincipalId   = '$CARLOS_ID'"
echo "param sarahPrincipalId    = '$SARAH_ID'"
echo "param devopsGroupObjectId = '$GROUP_ID'"
echo ""
echo "=================================================="
