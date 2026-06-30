#!/bin/bash

set -eu

# Install NFS-utils pour le sync-file
sudo apt-get update
sudo apt-get install -y curl nfs-kernel-server

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

# On attend que k3s ait ecrit le node-token dans le dossier
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
	echo "Waiting node-token appear"
	sleep 5
done

# Save token in shared folder to be read by worker
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token
