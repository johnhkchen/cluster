# Kubernetes Development Environment with Nix Flakes

A reproducible development environment for Kubernetes using Kind, K3s, FluxCD, and Ansible, managed with Nix flakes.

## 🚀 Quick Start

```bash
# Clone this repository
git clone <your-repo-url>
cd kubernetes-dev-env

# Enter the development shell
nix develop

# Or if you don't have flakes enabled globally:
nix --experimental-features "nix-command flakes" develop
```

## 📦 Included Tools

- **kubectl** - Kubernetes command-line tool
- **kind** - Kubernetes in Docker for local development
- **k3s** - Lightweight Kubernetes distribution  
- **flux** - GitOps continuous delivery
- **ansible** - Infrastructure automation
- **helm** - Kubernetes package manager
- **docker** - Container runtime
- **podman** - Alternative container runtime
- **git, jq, yq** - Essential utilities

## 🛠️ Available Development Shells

### Default Shell (Full Environment)
```bash
nix develop
```
Includes all tools with helpful aliases and environment setup.

### Minimal Shell
```bash
nix develop .#minimal
```
Just the essentials: kubectl, kind, flux, git, jq

### Ansible-focused Shell
```bash
nix develop .#ansible
```
Ansible + Kubernetes tools for infrastructure automation.

## 🎯 Helpful Aliases

The environment automatically loads these aliases:

### Kubernetes
- `k` = `kubectl`
- `kg` = `kubectl get`
- `kd` = `kubectl describe`
- `ka` = `kubectl apply`
- `kdel` = `kubectl delete`
- `kl` = `kubectl logs`
- `kx` = `kubectl exec -it`
- `kns` = `kubectl config set-context --current --namespace`

### Kind
- `kind-create` = `kind create cluster --config`
- `kind-load` = `kind load docker-image`
- `kind-delete` = `kind delete cluster`

### Flux
- `fl` = `flux`
- `flr` = `flux reconcile`
- `fls` = `flux get sources all`
- `flk` = `flux get kustomizations`
- `flh` = `flux get helmreleases`

Run `kubectl-help` to see all available aliases.

## 📁 Project Structure

The environment automatically creates this structure:

```
./
├── clusters/          # Cluster configurations
├── manifests/         # Kubernetes manifests
├── kind-configs/      # Kind cluster configs
│   └── basic.yaml    # Basic multi-node config
├── ansible.cfg       # Ansible configuration
└── flake.nix         # Nix environment definition
```

## 🚀 Getting Started Guide

### 1. Create a Kind Cluster

```bash
# Create a basic cluster
kind-create kind-configs/basic.yaml

# Verify the cluster
kubectl cluster-info
kubectl get nodes
```

### 2. Install FluxCD

```bash
# Check prerequisites
flux check --pre

# Bootstrap Flux (replace with your repo)
flux bootstrap github \
  --owner=YOUR_GITHUB_USER \
  --repository=YOUR_REPO \
  --branch=main \
  --path=./clusters/dev

# Verify installation
flux get sources all
```

### 3. Deploy Sample Application

```bash
# Create a simple deployment
kubectl create deployment hello-world --image=nginx
kubectl expose deployment hello-world --port=80 --type=NodePort

# Check status
kubectl get pods,services
```

### 4. Use Ansible for Infrastructure

```bash
# Create inventory file
cat > inventory << EOF
[local]
localhost ansible_connection=local
EOF

# Test connectivity
ansible all -m ping

# Run ad-hoc commands
ansible local -m command -a "kubectl get nodes"
```

## 🔧 Advanced Usage

### Working with K3s

```bash
# Install K3s (requires sudo on real systems)
curl -sfL https://get.k3s.io | sh -

# Or use in container/VM environments
k3s server --write-kubeconfig-mode 644
```

### GitOps with FluxCD

```bash
# Create a source
flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=1m

# Create a kustomization
flux create kustomization podinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m
```

### Ansible Playbooks

```bash
# Create a simple playbook
cat > site.yml << EOF
---
- hosts: local
  tasks:
    - name: Check kubectl version
      command: kubectl version --client
      register: kubectl_version
    
    - name: Display kubectl version
      debug:
        var: kubectl_version.stdout
EOF

# Run the playbook
ansible-playbook site.yml
```

## 🔄 Reproducibility

### Sharing the Environment

1. **Share this repository** - Anyone with Nix can run `nix develop`
2. **Pin versions** - The flake.lock ensures exact reproducibility
3. **Cross-platform** - Works on Linux, macOS, and WSL2

### Updating Dependencies

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Check what changed
git diff flake.lock
```

### Building Packages

```bash
# Build the setup script
nix build .#setup-env

# Build kubectl aliases
nix build .#kubectl-aliases
```

## 🐛 Troubleshooting

### Docker Socket Issues
```bash
# If docker commands fail
export DOCKER_HOST="unix:///var/run/docker.sock"
# Or use podman instead
alias docker=podman
```

### Kind Cluster Issues
```bash
# Clean up clusters
kind get clusters
kind delete cluster --name <cluster-name>

# Check Docker is running
docker ps
```

### Flux Bootstrap Issues
```bash
# Verify GitHub token
echo $GITHUB_TOKEN

# Check cluster access
kubectl auth can-i create namespaces --all-namespaces
```

## 📚 Resources

- [Kind Documentation](https://kind.sigs.k8s.io/)
- [K3s Documentation](https://k3s.io/)
- [FluxCD Documentation](https://fluxcd.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

## 🤝 Contributing

1. Fork the repository
2. Make your changes
3. Test with `nix flake check`
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.