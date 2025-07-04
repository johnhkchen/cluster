# Edge Computing Strategy

## Development → Production Path

**Current State**: Kubernetes development environment with GitOps  
**Production Goal**: Docker Compose on edge devices with MQTT communication

### Why This Approach?

- **Development**: Full Kubernetes for testing, integration, and learning
- **Production**: Simple Docker Compose for reliability and low latency on edge devices
- **Bridge**: Same containers work in both environments

## Deployment Targets

| Device | Purpose | Platform | Resources |
|--------|---------|----------|-----------|
| **Development** | Testing, integration | Kind/K3s | Full cluster |
| **Pi 4/5** | Lightweight services | Docker Compose | 8GB RAM |
| **Jetson Orin** | GPU workloads, AI/ML | Docker Compose | 64GB RAM, GPU |
| **Cloud** | Orchestration, admin | K3s cluster | Scalable |

## Migration Strategy

1. **Phase 1**: Current demo stack as orchestration layer
2. **Phase 2**: Add Docker Compose variants for edge devices  
3. **Phase 3**: MQTT backbone for inter-device communication
4. **Phase 4**: Deploy to real hardware with Ansible

## Technology Evolution

**Start Simple**: Docker Compose + MQTT (reliable, debuggable)  
**Add Complexity**: Migrate to K3s when benefits outweigh complexity  
**GitOps Throughout**: Same deployment pipeline for all environments