#!/bin/bash

set -u

# Colors
GREEN='\033[;32m'
DARK_GREEN='\033[2;32m'
NC='\033[0m' # No Color

install_argocd_cli() {
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
}

change_argocd_password() {
    # Logging to ArgoCD
    echo -e "${DARK_GREEN}Logging as admin with default password${NC}"
    PASSWORD=$(sudo argocd admin initial-password -n argocd | head -n 1)
    sudo argocd login localhost:30443 --username admin --password ${PASSWORD} --insecure
    # Changing password on ArgoCD
    echo -e "${DARK_GREEN}Updating password to argument${NC}"
    sudo argocd account update-password --current-password ${PASSWORD} --new-password $1 --insecure
}

deploy_app_to_argocd() {
    sudo kubectl config set-context --current --namespace=argocd

    sleep 3

    # Linking ArgoCD to github
    sudo argocd app create p3 \
    --repo https://github.com/Huakfy/Inception-of-Things-mjourno.git \
    --revision mjourno \
    --path p3/confs/wil \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev

    sleep 3

    # Adding auto sync to project
    echo -e "${DARK_GREEN}Adding auto sync${NC}"
    sudo argocd app sync p3
    sudo argocd app set p3 --sync-policy automated
}

setup_argocd() {
    echo -e "${GREEN}Installing ArgoCD cli locally${NC}"
    install_argocd_cli
    echo -e "${GREEN}Changing ArgoCD admin password${NC}"
    change_argocd_password $1
    echo -e "${GREEN}Creating p3 app from github${NC}"
    deploy_app_to_argocd
}
