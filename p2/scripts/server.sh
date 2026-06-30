#!/bin/bash

set -eu

sudo apt-get update
sudo apt-get install -y curl

# Configure le serveur
# K3S_KUBECONFIG_MODE: permet de configurer les droit du fichier de config de k3s
# INSTALL_K3S_EXEC: variable d'env pour script d'installation de k3s (Indique comment installer)
# server: Permet d'installer le node en mode serveur et pas en mode agent
# node-ip: Met l'adresse ip du noeud a 192.168.56.110
# advertise-address: Adresse ip par laquelle le serveur va s'annoncer au autres noeuds
# tls-san:
# flannel-iface: On dit a flannel qui gere le reseau des pods par defaut de k3s d'utiliser l'eth1 (192.168.56.110)
curl -sfL https://get.k3s.io | \
    K3S_KUBECONFIG_MODE="644" \
    INSTALL_K3S_EXEC="server \
        --node-ip 192.168.56.110 \
        --advertise-address 192.168.56.110 \
        --tls-san 192.168.56.110 \
        --flannel-iface eth1" \
    sh -

# Install docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Creer un registre docker local
docker pull registry:2
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Build chaque image
docker build /vagrant/confs/app1/ -t localhost:5000/app1
docker build /vagrant/confs/app2/ -t localhost:5000/app2
docker build /vagrant/confs/app3/ -t localhost:5000/app3

# Push chaque image dans le registre local
docker push localhost:5000/app1
docker push localhost:5000/app2
docker push localhost:5000/app3

# Deployer les pods
kubectl apply -f /vagrant/confs/app1/app1.yaml
kubectl apply -f /vagrant/confs/app2/app2.yaml
kubectl apply -f /vagrant/confs/app3/app3.yaml
kubectl apply -f /vagrant/confs/ingress.yaml

sudo cat /vagrant/confs/registries.yaml > /etc/rancher/k3s/registries.yaml

sudo systemctl restart k3s
