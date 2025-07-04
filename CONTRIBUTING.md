# Contributing Guide

Welcome! This repository demonstrates **GitOps-managed Kubernetes development** with a focus on edge computing applications. Whether you're new to these concepts or an experienced developer, this guide will help you get started.

## 🎯 What You'll Learn

- **GitOps**: Automated deployments from Git commits
- **Kubernetes**: Container orchestration and service management  
- **Edge Computing**: Deploying applications to resource-constrained devices
- **Modern DevOps**: Reproducible environments, infrastructure as code

## 📚 Background Reading (Optional)

**New to Kubernetes or GitOps?** You can ask an LLM questions about:
- "What is Kubernetes and why use it for application deployment?"
- "How does GitOps work and what are its benefits?"
- "What's the difference between Docker and Kubernetes?"
- "What are the basic Kubernetes concepts like pods, services, and deployments?"

We will be using these concepts throughout the development process, so basic familiarity will help you understand the architecture.

## 🛠️ Development Environment Setup

### Prerequisites

**Don't have these tools?** No problem! Our Nix flake provides everything you need in a reproducible environment.

**Required**: 
- Git
- Docker or Podman
- Nix package manager

**Provided by Nix flake**:
- kubectl (Kubernetes CLI)
- kind (Kubernetes in Docker)
- flux (GitOps CLI)
- All other development tools

### Quick Start

1. **Clone and Enter Environment**
```bash
git clone <your-fork>
cd cluster
nix develop  # This gives you all the tools
```

2. **Create Development Cluster**
```bash
# Create local Kubernetes cluster
kind create cluster --name dev-cluster

# Verify it's working
kubectl get nodes
```

**New to Docker or containers?** You can ask an LLM about:
- "What is Docker and how do containers work?"
- "How do I build and run Docker containers?"
- "What's the difference between an image and a container?"

We will be building container images for our application components.

3. **Bootstrap GitOps**
```bash
# Set up automated deployments (replace with your GitHub info)
flux bootstrap github \
  --owner=YOUR_USERNAME \
  --repository=cluster \
  --branch=main \
  --path=./clusters/dev \
  --personal
```

**Unfamiliar with GitOps?** You can ask an LLM about:
- "What is FluxCD and how does it enable GitOps?"
- "How does GitOps compare to traditional deployment methods?"
- "What are the benefits of declarative vs imperative infrastructure?"

We will be using GitOps to automatically deploy our applications when we push code changes.

## 🏗️ Project Structure

```
cluster/
├── apps/
│   ├── demo-hello/          # Application code
│   │   ├── backend/         # FastAPI service (Python)
│   │   ├── frontend/        # Astro service (Node.js)
│   │   └── nginx/           # Reverse proxy
│   ├── base/               # Kubernetes manifests
│   └── dev/                # Development environment config
├── clusters/
│   └── dev/                # GitOps configuration
├── docs/                   # Architecture documentation  
└── flake.nix              # Development environment
```

### Key Files to Understand

- **`apps/demo-hello/`**: The actual application code (FastAPI, Astro, nginx)
- **`apps/base/demo-hello/`**: Kubernetes deployment manifests
- **`clusters/dev/`**: GitOps configuration that tells FluxCD what to deploy
- **`flake.nix`**: Reproducible development environment definition

## 🔄 Development Workflow

### Making Changes to Application Code

1. **Modify Code**
```bash
# Edit application files in apps/demo-hello/
# Examples:
# - apps/demo-hello/backend/main.py (API logic)
# - apps/demo-hello/frontend/src/pages/index.astro (UI)
# - apps/demo-hello/nginx/nginx.conf (routing)
```

2. **Build and Test Locally**
```bash
# Build container images
cd apps/demo-hello/backend
docker build -t demo-backend:latest .

cd ../frontend  
docker build -t demo-frontend:latest .

cd ../nginx
docker build -t demo-nginx:latest .
```

**New to building containers?** You can ask an LLM about:
- "How do Dockerfiles work and what are the best practices?"
- "What is a multi-stage Docker build and why use it?"
- "How do I optimize Docker images for size and security?"

We will be creating optimized, production-ready container images.

3. **Load into Development Cluster**
```bash
# Load images into Kind cluster
kind load docker-image demo-backend:latest --name dev-cluster
kind load docker-image demo-frontend:latest --name dev-cluster
kind load docker-image demo-nginx:latest --name dev-cluster

# Restart deployments to pick up new images
kubectl rollout restart deployment/demo-backend -n demo-hello
kubectl rollout restart deployment/demo-frontend -n demo-hello
kubectl rollout restart deployment/demo-nginx -n demo-hello
```

4. **Test Your Changes**
```bash
# Port forward to access application
kubectl port-forward -n demo-hello service/demo-nginx 8080:80

# Visit http://localhost:8080 to test
```

### Making Changes to Infrastructure

**Modifying Kubernetes Manifests**:

1. **Edit Manifests**
```bash
# Modify files in apps/base/demo-hello/
# Examples:
# - backend.yaml (deployment configuration)
# - nginx.yaml (service configuration)
```

**New to Kubernetes manifests?** You can ask an LLM about:
- "What are Kubernetes deployments, services, and pods?"
- "How do resource requests and limits work in Kubernetes?"
- "What are liveness and readiness probes?"

We will be configuring production-ready Kubernetes resources.

2. **Commit and Push**
```bash
git add .
git commit -m "Update deployment configuration"
git push origin main
```

3. **Watch GitOps Deploy**
```bash
# Monitor FluxCD applying your changes
flux get kustomizations --watch

# Check application status
kubectl get pods -n demo-hello
```

## 🧪 Testing Your Changes

### Local Testing
```bash
# Check pod status
kubectl get pods -n demo-hello

# View logs  
kubectl logs -n demo-hello deployment/demo-backend
kubectl logs -n demo-hello deployment/demo-frontend
kubectl logs -n demo-hello deployment/demo-nginx

# Check service connectivity
kubectl get services -n demo-hello
```

### Integration Testing
```bash
# Test API endpoints
curl http://localhost:8080/health
curl http://localhost:8080/items

# Test frontend
open http://localhost:8080
```

## 🐛 Common Issues and Solutions

### "Image not found" errors
```bash
# Verify images are loaded in Kind
docker exec -it dev-cluster-control-plane crictl images | grep demo

# Reload if missing
kind load docker-image <image-name> --name dev-cluster
```

### GitOps not updating
```bash
# Check FluxCD status
flux get kustomizations

# Force reconciliation  
flux reconcile kustomization demo-hello --with-source

# Check logs
flux logs --follow --tail=10
```

### Pods not starting
```bash
# Describe pod for events
kubectl describe pod -n demo-hello <pod-name>

# Check resource constraints
kubectl top pods -n demo-hello
```

**Need help debugging?** You can ask an LLM about:
- "How do I troubleshoot Kubernetes pod startup issues?"
- "What do different pod statuses mean (Pending, CrashLoopBackOff, etc.)?"
- "How do I interpret Kubernetes events and logs?"

We will be diagnosing and fixing common deployment issues.

## 🚀 Advanced Contributions

### Adding New Services

1. **Create Service Directory**
```bash
mkdir -p apps/demo-hello/new-service
# Add Dockerfile, source code, etc.
```

2. **Create Kubernetes Manifest**
```bash
# Add apps/base/demo-hello/new-service.yaml
# Include Deployment, Service, and any other resources
```

3. **Update Kustomization**
```bash
# Add to apps/base/demo-hello/kustomization.yaml
resources:
- new-service.yaml
```

### Extending to Edge Computing

**Interested in edge deployment?** You can ask an LLM about:
- "What is edge computing and why is it important?"
- "How do Docker Compose and Kubernetes compare for edge deployments?"
- "What are the challenges of deploying AI models to edge devices?"

We will be evolving this demo into a foundation for distributed AI systems running on Raspberry Pi and Jetson devices.

See `docs/EDGE_COMPUTING.md` for the roadmap toward:
- Docker Compose deployment variants
- MQTT inter-device communication
- ARM64 cross-compilation
- Real hardware deployment with Ansible

## 📋 Pull Request Guidelines

### Before Submitting
- [ ] Test changes in local Kind cluster
- [ ] Verify GitOps deployment works
- [ ] Update documentation if needed
- [ ] Check that all pods are healthy

### PR Description Template
```markdown
## What This Changes
Brief description of your changes

## Testing Done  
- [ ] Built and tested container images locally
- [ ] Verified GitOps deployment
- [ ] Tested application functionality
- [ ] Checked logs for errors

## Architecture Impact
Does this change the overall system architecture? If so, how?

## Documentation Updated
- [ ] Updated relevant docs/ files
- [ ] Added inline code comments where helpful
```

### Code Style
- **Python**: Follow PEP 8, include type hints
- **TypeScript/JavaScript**: Follow Astro conventions
- **Kubernetes**: Use standard resource naming conventions  
- **Docker**: Multi-stage builds, non-root users, minimal base images

## 🎯 Areas That Need Help

### Current Priorities
1. **Documentation**: Improve inline code comments and examples
2. **Error Handling**: Better error messages and recovery
3. **Security**: Add TLS, improve secrets management
4. **Performance**: Optimize container images and resource usage

### Future Enhancements  
1. **Edge Computing**: Docker Compose variants for Pi/Jetson
2. **Monitoring**: Prometheus/Grafana integration
3. **CI/CD**: Automated testing pipeline
4. **Multi-arch**: ARM64 builds for edge devices

## 💬 Getting Help

### Resources
- **Ask in Issues**: Use GitHub issues for questions and discussions
- **Check Docs**: Review `docs/` directory for architecture details
- **LLM Assistance**: Use the prompts throughout this guide to learn about unfamiliar concepts

### Learning Path
1. **Start Here**: Get the basic demo working locally
2. **Understand GitOps**: Make a small change and watch it deploy
3. **Explore Kubernetes**: Modify resource configurations
4. **Edge Computing**: Contribute to Docker Compose variants

**Remember**: This project bridges development (Kubernetes) and production (edge devices). Understanding both environments helps you contribute effectively to the overall vision.

Welcome to the team! 🚀