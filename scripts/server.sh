#!/bin/sh

set -eu

sudo dnf -y install nfs-utils

curl -sfL https://get.k3s.io | \
    K3S_KUBECONFIG_MODE="644" \
    INSTALL_K3S_EXEC="server --node-ip 192.168.56.110 --advertise-address 192.168.56.110 --tls-san 192.168.56.110 --flannel-iface eth1" \
    sh -

while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
	echo "Waiting node-token appear"
	sleep 5
done

sudo tee /vagrant/node-token < /var/lib/rancher/k3s/server/node-token > /dev/null
