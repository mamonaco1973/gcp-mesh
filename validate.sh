#!/bin/bash
set -euo pipefail

# ================================================================================
# validate.sh — Cross-VPC connectivity checks for gcp-mesh
# Uses gcloud compute ssh --tunnel-through-iap (no public IPs needed)
# Each VM curls the other two; expects "{ip} - Welcome to VPC {region}"
# ================================================================================

# ------------------------------------------------------------------------------
# Load VM details from Terraform outputs
# ------------------------------------------------------------------------------
PROJECT_ID=$(jq -r '.project_id' ./credentials.json)

VM1=$(cd 02-mesh && terraform output -raw vm1_name)
VM2=$(cd 02-mesh && terraform output -raw vm2_name)
VM3=$(cd 02-mesh && terraform output -raw vm3_name)

ZONE1=$(cd 02-mesh && terraform output -raw vm1_zone)
ZONE2=$(cd 02-mesh && terraform output -raw vm2_zone)
ZONE3=$(cd 02-mesh && terraform output -raw vm3_zone)

VM1_IP=$(cd 02-mesh && terraform output -raw vm1_private_ip)
VM2_IP=$(cd 02-mesh && terraform output -raw vm2_private_ip)
VM3_IP=$(cd 02-mesh && terraform output -raw vm3_private_ip)

# ------------------------------------------------------------------------------
# Wait for nginx — safe to call standalone (no-op if already active)
# ------------------------------------------------------------------------------
wait_for_nginx() {
  local vm_name=$1
  local zone=$2
  local max=36
  local delay=10

  echo "Waiting for nginx on ${vm_name} (${zone})..."
  for ((i=1; i<=max; i++)); do
    STATUS=$(gcloud compute ssh "${vm_name}" \
      --zone="${zone}" \
      --project="${PROJECT_ID}" \
      --tunnel-through-iap \
      --ssh-flag="-o StrictHostKeyChecking=no" \
      --command="systemctl is-active nginx" \
      --quiet 2>/dev/null || true)

    if echo "${STATUS}" | grep -q "^active"; then
      echo "  nginx is active on ${vm_name}"
      return 0
    fi

    echo "  [${i}/${max}] not ready yet — retrying in ${delay}s"
    sleep "${delay}"
  done

  echo "ERROR: nginx never became active on ${vm_name}" >&2
  return 1
}

# ------------------------------------------------------------------------------
# run_check: SSH into source VM, curl target IP, print result
# ------------------------------------------------------------------------------
run_check() {
  local src_vm=$1
  local src_zone=$2
  local target_ip=$3
  local label=$4

  echo "  ${src_vm} → ${label} (${target_ip})"
  RESULT=$(gcloud compute ssh "${src_vm}" \
    --zone="${src_zone}" \
    --project="${PROJECT_ID}" \
    --tunnel-through-iap \
    --ssh-flag="-o StrictHostKeyChecking=no" \
    --command="curl -s --connect-timeout 5 http://${target_ip}" \
    --quiet 2>/dev/null || true)

  if [ -n "${RESULT}" ]; then
    echo "    OK: ${RESULT}"
  else
    echo "    FAIL: no response from ${target_ip}" >&2
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Readiness check (safe to call standalone)
# ------------------------------------------------------------------------------
wait_for_nginx "${VM1}" "${ZONE1}"
wait_for_nginx "${VM2}" "${ZONE2}"
wait_for_nginx "${VM3}" "${ZONE3}"

# ------------------------------------------------------------------------------
# Cross-VPC curl checks — 6 total (full mesh)
# ------------------------------------------------------------------------------
echo ""
echo "=== Validating cross-VPC connectivity ==="
echo ""

echo "[${VM1}]"
run_check "${VM1}" "${ZONE1}" "${VM2_IP}" "${VM2}"
run_check "${VM1}" "${ZONE1}" "${VM3_IP}" "${VM3}"

echo "[${VM2}]"
run_check "${VM2}" "${ZONE2}" "${VM1_IP}" "${VM1}"
run_check "${VM2}" "${ZONE2}" "${VM3_IP}" "${VM3}"

echo "[${VM3}]"
run_check "${VM3}" "${ZONE3}" "${VM1_IP}" "${VM1}"
run_check "${VM3}" "${ZONE3}" "${VM2_IP}" "${VM2}"

echo ""
echo "=== All checks passed ==="
