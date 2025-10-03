#!/bin/bash

set -u

# Colors
GREEN='\033[;32m'
DARK_GREEN='\033[2;32m'
NC='\033[0m' # No Color

create_cluster() {
    sudo k3d cluster create p3 \
        -p "80:80@loadbalancer" \
        -p "443:443@loadbalancer" \
        -p "30443:30443@loadbalancer" \
        -p "30080:30080@loadbalancer"
}

create_namespaces() {
    sudo kubectl create namespace argocd
    sudo kubectl create namespace dev
}

wait_argocd_server() {
    # Wait for argocd-server to be created
    sleep 2
    until sudo kubectl get pod -l app.kubernetes.io/name=argocd-server -n argocd >/dev/null 2>&1; do
        echo -e "${DARK_GREEN}Waiting for argocd-server pod to be created${NC}"
        sleep 2
    done
    echo -e "${DARK_GREEN}argocd-server created${NC}"
    # Wait for argocd-server to be ready
    echo -e "${DARK_GREEN}Waiting for argocd-server pod to be Ready${NC}"
    sudo kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=240s
    echo -e "${DARK_GREEN}argocd-server pod Ready${NC}"
}

install_argocd() {
    sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    wait_argocd_server

    echo -e "${DARK_GREEN}Forwarding argocd-server port to 30443${NC}"

    # Forward ArgoCD port -> The API server can then be accessed using https://localhost:30443
    sudo kubectl apply -f confs/argocd.yaml

    # Waiting for argocdd-server to be reachable
    while ! curl -s http://127.0.0.1:30443 >/dev/null; do
    echo "Waiting for argocd-server Nodeport..."
    sleep 2
    done
    echo "argocd-server Nodeport is ready!"
}

setup_kubernetes() {
    echo -e "${GREEN}Creating cluster${NC}"
    create_cluster
    echo -e "${GREEN}Creating namespaces${NC}"
    create_namespaces
    echo -e "${GREEN}Installing ArgoCD in cluster${NC}"
    install_argocd
}
