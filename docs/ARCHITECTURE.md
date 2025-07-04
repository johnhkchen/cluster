# System Architecture

## Overview

This is a **GitOps-managed Kubernetes application** that demonstrates cloud-to-edge deployment patterns. The demo application (FastAPI + Astro + nginx) serves as the foundation for more complex edge computing scenarios.

## Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   FastAPI       │    │   Astro         │    │   Nginx         │
│   Backend       │    │   Frontend      │    │   Proxy         │
│                 │    │                 │    │                 │
│ • Python 3.13   │    │ • Node.js LTS   │    │ • Rate limiting │
│ • Health checks │    │ • SSR           │    │ • Load balancing│
│ • Mock devices  │    │ • Admin UI      │    │ • TLS ready     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────────────┐
                    │   Kubernetes Cluster    │
                    │   • Kind (development)  │
                    │   • FluxCD (GitOps)     │
                    │   • Automated deployment│
                    └─────────────────────────┘
```

## Request Flow

1. **Client Request** → nginx (port 80)
2. **API Calls** `/health`, `/items` → FastAPI backend  
3. **Web Pages** `/` → Astro frontend
4. **Static Assets** → nginx (cached)

## Future Extensions

- **Edge Devices**: Same containers → Docker Compose on Pi/Jetson
- **MQTT Integration**: Inter-device communication backbone
- **Multi-arch**: ARM64 builds for edge hardware
- **Monitoring**: Prometheus/Grafana integration