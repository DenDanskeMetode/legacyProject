#!/usr/bin/env bash

# ==========================================
# AZURE TOTAL RESET / NUKE SCRIPT
# ==========================================
# Deletes:
#   - ALL resource groups
#   - ALL deployments
#   - ALL locks
#
# Optional:
#   - Purge soft-deleted Key Vaults
#
# DOES NOT:
#   - Cancel subscription
#   - Remove billing methods
#   - Delete Entra ID tenant
#
# USE WITH EXTREME CAUTION.
# ==========================================

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}"
echo "=========================================="
echo "         AZURE TOTAL DESTRUCTION"
echo "=========================================="
echo -e "${NC}"

SUB_NAME=$(az account show --query name -o tsv)
SUB_ID=$(az account show --query id -o tsv)

echo "Subscription:"
echo "  Name : $SUB_NAME"
echo "  ID   : $SUB_ID"
echo ""

echo -e "${YELLOW}THIS WILL DELETE EVERYTHING IN THIS SUBSCRIPTION.${NC}"
echo ""
echo "Including:"
echo "  - VMs"
echo "  - VNets"
echo "  - Public IPs"
echo "  - Databases"
echo "  - Storage Accounts"
echo "  - Kubernetes clusters"
echo "  - Monitoring"
echo "  - Managed identities"
echo "  - Resource groups"
echo ""

read -p "Type EXACTLY: DELETE EVERYTHING : " CONFIRM

if [[ "$CONFIRM" != "DELETE EVERYTHING" ]]; then
    echo "Confirmation failed."
    exit 1
fi

echo ""
echo -e "${RED}Removing resource locks...${NC}"

LOCK_IDS=$(az lock list --query "[].id" -o tsv || true)

if [[ -n "${LOCK_IDS:-}" ]]; then
    while read -r LOCK_ID; do
        [ -z "$LOCK_ID" ] && continue
        echo "Deleting lock: $LOCK_ID"
        az lock delete --ids "$LOCK_ID"
    done <<< "$LOCK_IDS"
else
    echo "No locks found."
fi

echo ""
echo -e "${RED}Deleting ALL resource groups...${NC}"

RESOURCE_GROUPS=$(az group list --query "[].name" -o tsv)

if [[ -z "${RESOURCE_GROUPS:-}" ]]; then
    echo "No resource groups found."
else
    while read -r RG; do
        [ -z "$RG" ] && continue
        echo ""
        echo "=========================================="
        echo "Deleting Resource Group: $RG"
        echo "=========================================="

        az group delete \
            --name "$RG" \
            --yes \
            --no-wait
    done <<< "$RESOURCE_GROUPS"
fi

echo ""
echo -e "${YELLOW}Optional: Purging soft-deleted Key Vaults...${NC}"

DELETED_VAULTS=$(az keyvault list-deleted --query "[].name" -o tsv 2>/dev/null || true)

if [[ -n "${DELETED_VAULTS:-}" ]]; then
    while read -r VAULT; do
        [ -z "$VAULT" ] && continue
        echo "Purging Key Vault: $VAULT"
        az keyvault purge --name "$VAULT" || true
    done <<< "$DELETED_VAULTS"
else
    echo "No deleted key vaults found."
fi

echo ""
echo -e "${GREEN}=========================================="
echo "NUKE COMMANDS SUBMITTED"
echo "==========================================${NC}"
echo ""
echo "Azure is now asynchronously deleting everything."
echo ""
echo "Monitor progress:"
echo ""
echo "  az group list -o table"
echo ""
echo "When that returns empty, the subscription is effectively clean."
echo ""