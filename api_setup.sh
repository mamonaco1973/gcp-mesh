#!/bin/bash
set -euo pipefail

# ================================================================================
# api_setup.sh — Enable GCP APIs required for gcp-mesh
# ================================================================================

PROJECT_ID=$(jq -r '.project_id' "./credentials.json")

echo "NOTE: Enabling required GCP APIs for project: ${PROJECT_ID}"

gcloud services enable compute.googleapis.com --project="${PROJECT_ID}"
gcloud services enable iap.googleapis.com --project="${PROJECT_ID}"

echo "NOTE: All required APIs enabled."
