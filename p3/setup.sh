#!/bin/bash

set -u

source ./scripts/01_requirements.sh
source ./scripts/02_kubectl.sh
source ./scripts/03_argocd.sh

# Colors
TITLE_GREEN='\033[1;4;32m'
NC='\033[0m' # No Color

# Get new ArgoCD password
NEW_PASS=$1

echo -e "${TITLE_GREEN}Installing requirements${NC}"
install_requirements

echo -e "${TITLE_GREEN}Setting up Kubernetes${NC}"
setup_kubernetes

echo -e "${TITLE_GREEN}Setting up ArgoCD${NC}"
setup_argocd $NEW_PASS
