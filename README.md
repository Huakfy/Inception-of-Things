# Inception-of-Things

## Virtual Machine Setup
### Install Vagrant
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

### Enable nested virtualisation in VM
```bash
modprobe kvm-intel nested=1
```


## Debug
Please disable the KVM kernel extension
```bash
modprobe -r kvm_intel
```

https://argo-cd.readthedocs.io/en/stable/getting_started/

sudo k3d cluster delete p3