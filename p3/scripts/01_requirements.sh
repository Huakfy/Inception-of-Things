#!/bin/bash

set -u

# Colors
GREEN='\033[;32m'
NC='\033[0m' # No Color

update_apt_get() {
  sudo apt-get update
  sudo apt-get upgrade -y
}

install_docker() {
  sudo apt-get install ca-certificates curl -y
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

install_k3d() {
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

install_requirements() {
  echo -e "${GREEN}Upgrading apt-get${NC}"
  update_apt_get
  echo -e "${GREEN}Installing Docker${NC}"
  install_docker
  echo -e "${GREEN}Installing kubectl${NC}"
  install_kubectl
  echo -e "${GREEN}Installing K3d${NC}"
  install_k3d
}
