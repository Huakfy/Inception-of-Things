# Inception-of-Things

## Virtual Machine Setup
### Install Vagrant
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```
### Tutorial on deploying ArgoCD
https://argo-cd.readthedocs.io/en/stable/getting_started/

### Delete kube cluster for ex03
sudo k3d cluster delete p3


# IoT Evaluation Cheat Sheet

## P1 — Vagrant + K3s

### Launch VMs
```bash
vagrant up
```

### SSH into machines
```bash
vagrant ssh mjournoS
vagrant ssh mjournoSW
```

### VM status
```bash
vagrant status
```

### Destroy + recreate
```bash
vagrant destroy -f
vagrant up
```

---

## Check networking

### Show interfaces
```bash
ip a
```

### Expected
Server:
```text
192.168.56.110
```

Worker:
```text
192.168.56.111
```

---

## K3s

### Check nodes
```bash
kubectl get nodes -o wide
```

Expected:
```text
mjournos    Ready    control-plane
mjournosw   Ready
```

---

# P2 — Ingress

## Pods
```bash
kubectl get pods -o wide
```

Expected:
```text
app2 -> 3 replicas
```

---

## Test routing

### app1
```bash
curl -H "Host: app1.com" 192.168.56.110
```

### app2
```bash
curl -H "Host: app2.com" 192.168.56.110
```

### default app
```bash
curl 192.168.56.110
```

---

## Useful debug

### Describe pod
```bash
kubectl describe pod <pod-name>
```

### Pod logs
```bash
kubectl logs <pod-name>
```

### Exec into container
```bash
kubectl exec -it <pod-name> -- sh
```

---

# P3 — K3d + Argo CD

## Launch setup
```bash
./setup.sh abcdefgh
```

---

## k3d

### Delete cluster
```bash
k3d cluster delete p3
```

### List clusters
```bash
k3d cluster list
```

---

# Argo CD

## Access UI
```text
http://localhost:30443
```

### Login
```text
admin
abcdefgh
```

---

## Namespaces
```bash
kubectl get ns
```

Expected:
```text
argocd
dev
```

---

## Argo CD pods
```bash
kubectl get pods -n argocd
```

---

## Dev app pods
```bash
kubectl get pods -n dev
```

---

## Dev services
```bash
kubectl get svc -n dev
```

Expected:
```text
30080/TCP
```

---

## Test deployed app
```bash
curl http://localhost:30080
```

Expected:
```json
{"status":"ok","message":"v1"}
```
---

## Verify sync
```bash
kubectl get pods -n dev
curl http://localhost:30080
```

Expected:
```json
{"status":"ok","message":"v2"}
```

---

# Concepts evaluators may ask

## K3s
Lightweight Kubernetes distribution by Rancher.

---

## K3d
Runs K3s clusters inside Docker containers.

---

## Flannel
Default K3s CNI plugin.  
Handles pod-to-pod networking.

---

## Ingress
HTTP router inside Kubernetes.

Routes requests depending on:
- hostname
- path

---

## NodePort
Exposes a Kubernetes service on a host port.

Example:
```text
localhost:30080 -> service -> pod
```

---

## tls-san
Adds additional valid IPs/domains to Kubernetes API server certificate.

Without it:
```text
x509 certificate errors
```

can happen.

---

## GitOps
Infrastructure/application state stored in Git.  
Argo CD watches Git and reconciles cluster automatically.

---

## Difference between K3s and K3d

### K3s
Actual lightweight Kubernetes distribution.

### K3d
Tool that runs K3s inside Docker.
