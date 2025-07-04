# Cloud-to-Edge Kubernetes Development Environment

A **GitOps-managed Kubernetes application** demonstrating modern deployment practices and edge computing foundations.

## 🚀 Quick Start

```bash
# 1. Enter development environment
nix develop

# 2. Create local cluster  
kind create cluster --name dev-cluster

# 3. Bootstrap GitOps (replace with your GitHub details)
flux bootstrap github \
  --owner=YOUR_USERNAME \
  --repository=cluster \
  --branch=main \
  --path=./clusters/dev \
  --personal

# 4. Build and load application images
cd apps/demo-hello/backend && docker build -t demo-backend:latest .
cd ../frontend && docker build -t demo-frontend:latest .  
cd ../nginx && docker build -t demo-nginx:latest .

kind load docker-image demo-backend:latest --name dev-cluster
kind load docker-image demo-frontend:latest --name dev-cluster
kind load docker-image demo-nginx:latest --name dev-cluster

# 5. Access application
kubectl port-forward -n demo-hello service/demo-nginx 8080:80
# Visit http://localhost:8080
```

## 🎯 What This Demonstrates

- **GitOps Automation**: Push to Git → Automatic deployment
- **Modern Stack**: FastAPI (Python 3.13) + Astro (Node.js) + nginx
- **Production Patterns**: Health checks, resource limits, service mesh
- **Edge Computing Foundation**: Kubernetes dev → Docker Compose production

## 📁 Repository Structure

```
├── apps/demo-hello/        # Application code (FastAPI, Astro, nginx)
├── apps/base/             # Kubernetes manifests  
├── clusters/dev/          # GitOps configuration
├── docs/                  # Architecture documentation
├── flake.nix             # Reproducible development environment
└── CONTRIBUTING.md       # Detailed development guide
```

## 🔄 Development Workflow

1. **Make changes** to application code in `apps/demo-hello/`
2. **Build container images** with Docker
3. **Load into Kind cluster** for testing
4. **Commit and push** - GitOps handles deployment automatically

## 🎓 Learning Resources

- **New to Kubernetes?** Check out `CONTRIBUTING.md` for guided learning prompts
- **Architecture details**: See `docs/ARCHITECTURE.md`
- **Edge computing vision**: See `docs/EDGE_COMPUTING.md`

## 🛠️ Prerequisites

- **Nix** package manager (provides all other tools)
- **Docker** or Podman
- **Git** and GitHub account

## 🚀 Next Steps

- **Contribute**: See `CONTRIBUTING.md` for detailed development guide
- **Extend**: Add new services or improve existing ones
- **Deploy**: Evolve toward edge computing with Docker Compose variants

**This foundation scales** from local development to distributed edge AI systems. Start simple, grow complex! 🌱→🌳