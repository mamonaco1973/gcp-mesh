#!/bin/bash
set -euo pipefail

# ================================================================================
# apply.sh — Two-stage deploy for gcp-mesh (VPC peering + VMs)
# Stage 1: networking (VPCs, subnets, Cloud NAT, full-mesh peering)
# Stage 2: mesh (firewall rules, VMs) — vars injected from stage 1 outputs
# ================================================================================

# ------------------------------------------------------------------------------
# Environment validation
# ------------------------------------------------------------------------------
./check_env.sh

# ------------------------------------------------------------------------------
# Stage 1: Networking
# ------------------------------------------------------------------------------
cd 01-networking
terraform init -upgrade
terraform apply -auto-approve
cd ..

# ------------------------------------------------------------------------------
# Capture stage 1 outputs
# ------------------------------------------------------------------------------
NET1=$(cd 01-networking && terraform output -raw network1_name)
NET2=$(cd 01-networking && terraform output -raw network2_name)
NET3=$(cd 01-networking && terraform output -raw network3_name)

SUB1=$(cd 01-networking && terraform output -raw subnet1_name)
SUB2=$(cd 01-networking && terraform output -raw subnet2_name)
SUB3=$(cd 01-networking && terraform output -raw subnet3_name)

# ------------------------------------------------------------------------------
# Stage 2: VMs and firewall rules
# ------------------------------------------------------------------------------
cd 02-mesh
terraform init -upgrade
terraform apply -auto-approve \
  -var="network1_name=${NET1}" \
  -var="network2_name=${NET2}" \
  -var="network3_name=${NET3}" \
  -var="subnet1_name=${SUB1}" \
  -var="subnet2_name=${SUB2}" \
  -var="subnet3_name=${SUB3}"
cd ..

# ------------------------------------------------------------------------------
# Capture VM details from stage 2
# ------------------------------------------------------------------------------
VM1=$(cd 02-mesh && terraform output -raw vm1_name)
VM2=$(cd 02-mesh && terraform output -raw vm2_name)
VM3=$(cd 02-mesh && terraform output -raw vm3_name)

ZONE1=$(cd 02-mesh && terraform output -raw vm1_zone)
ZONE2=$(cd 02-mesh && terraform output -raw vm2_zone)
ZONE3=$(cd 02-mesh && terraform output -raw vm3_zone)

PROJECT_ID=$(jq -r '.project_id' ./credentials.json)

# ------------------------------------------------------------------------------
# Wait for nginx to be active on each VM before validating
# Uses IAP tunnel — no public IPs needed
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

wait_for_nginx "${VM1}" "${ZONE1}"
wait_for_nginx "${VM2}" "${ZONE2}"
wait_for_nginx "${VM3}" "${ZONE3}"

# ------------------------------------------------------------------------------
# Run cross-VPC validation
# ------------------------------------------------------------------------------
./validate.sh
