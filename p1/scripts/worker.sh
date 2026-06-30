#!/bin/bash

set -eu

# Install NFS-utils pour le sync-file
sudo apt-get update
sudo apt-get install -y curl nfs-kernel-server

# On attend que le token soit dispo dans le dossier partage
while [ ! -f /vagrant/node-token ]; do
    echo "Waiting for node-token"
    sleep 5
done

# On recupere le token dans la variable TOKEN
TOKEN=$(cat /vagrant/node-token)

# On configure k3s en mode agent pour le worker
# K3S_URL: Adresse du noeud maitre a laquelle doit se connecter le worker
# K3S_TOKEN: Jeton d'authentification emis par le serveur et obligatoire pour se connecter a lui
# agent: k3s mode agent
# node-ip: Met l'adresse de ce noeud a 192.168.56.111
# flannel-iface: On dit a flannel qui gere le reseau des pods par defaut de k3s d'utiliser l'eth1 (192.168.56.111)
curl -sfL https://get.k3s.io | \
    K3S_URL="https://192.168.56.110:6443" \
    K3S_TOKEN="$TOKEN" \
    INSTALL_K3S_EXEC="agent \
        --node-ip 192.168.56.111 \
        --flannel-iface eth1" \
    sh -
