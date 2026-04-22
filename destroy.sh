#!/bin/bash
set -euo pipefail

# ================================================================================
# destroy.sh — Reverse two-stage teardown for gcp-mesh
# Stage 2 destroyed first; stage 1 (VPCs, peering, NAT) destroyed second
# ================================================================================

# ------------------------------------------------------------------------------
# Capture stage 1 outputs — needed as vars for stage 2 destroy
# ------------------------------------------------------------------------------
NET1=$(cd 01-networking && terraform output -raw network1_name)
NET2=$(cd 01-networking && terraform output -raw network2_name)
NET3=$(cd 01-networking && terraform output -raw network3_name)

SUB1=$(cd 01-networking && terraform output -raw subnet1_name)
SUB2=$(cd 01-networking && terraform output -raw subnet2_name)
SUB3=$(cd 01-networking && terraform output -raw subnet3_name)

# ------------------------------------------------------------------------------
# Stage 2 destroy: VMs and firewall rules
# ------------------------------------------------------------------------------
cd 02-mesh
terraform destroy -auto-approve \
  -var="network1_name=${NET1}" \
  -var="network2_name=${NET2}" \
  -var="network3_name=${NET3}" \
  -var="subnet1_name=${SUB1}" \
  -var="subnet2_name=${SUB2}" \
  -var="subnet3_name=${SUB3}"
cd ..

# ------------------------------------------------------------------------------
# Stage 1 destroy: VPCs, subnets, Cloud NAT, peering
# ------------------------------------------------------------------------------
cd 01-networking
terraform destroy -auto-approve
cd ..
