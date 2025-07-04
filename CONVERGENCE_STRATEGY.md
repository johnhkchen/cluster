# PERCI System Convergence Strategy

## 🎯 Executive Summary

This document outlines how our current Kubernetes-based GitOps development environment converges with the practical Docker Compose + MQTT approach for deploying PERCI (Personal Cognitive Intelligence) across edge devices.

**Key Insight**: Our current foundation becomes PERCI's **orchestration and admin layer**, while edge devices run optimized Docker Compose stacks.

## 🏗️ System Architecture Overview

### PERCI Component Distribution

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Pi 1: STT     │  │   Pi 2: NLP     │  │   Pi 3: TTS     │  │Pi 4: Orchestrator│
│                 │  │                 │  │                 │  │                 │
│ • 3x Vosk       │  │ • Mini RWKV     │  │ • TTS Engine    │  │ • Admin UI      │
│ • SER Model     │  │ • NLP Recon     │  │ • Audio Out     │  │ • Watchdog      │
│ • Resemblyzer   │  │ • Preprocessing │  │ • Audio Proc    │  │ • Deployment    │
└─────────────────┘  └─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │                     │
         └─────────────────────┼─────────────────────┼─────────────────────┘
                               │                     │
                    ┌─────────────────────────────────────────┐
                    │        Jetson Orin NX: Core AI         │
                    │                                         │
                    │ • RWKV "Consciousness" Core            │
                    │ • Main LLM (Inference)                 │
                    │ • Reflective LLM (Planning/Summary)    │
                    │ • Governor System (Safety/Monitoring)  │
                    │ • GPU-Accelerated Processing           │
                    └─────────────────────────────────────────┘
```

**Communication Backbone**: MQTT pub/sub for low-latency inter-component messaging

## 🔄 Convergence Strategy

### Current State → PERCI Orchestration

**What We Have Now:**
```yaml
Current Demo Stack:
  - FastAPI Backend: Health monitoring, device data simulation
  - Astro Frontend: Status dashboard, device management UI
  - Nginx Proxy: Service routing, rate limiting
  - GitOps/FluxCD: Automated deployment pipeline
  - Kubernetes: Local development environment
```

**How It Evolves:**
```yaml
PERCI Orchestration Layer:
  - FastAPI Backend → PERCI Orchestrator API
    * Device health monitoring
    * Inter-service communication routing
    * Model loading/unloading management
    * Performance metrics collection
    
  - Astro Frontend → PERCI Admin Interface
    * Real-time system monitoring
    * Log aggregation and viewing
    * Deployment management
    * Performance dashboards
    
  - Nginx Proxy → Service Mesh Gateway
    * Load balancing across devices
    * Request routing to appropriate services
    * Rate limiting and protection
    
  - GitOps → Configuration Management
    * Deploy Docker Compose files to devices
    * Manage model updates
    * Configuration synchronization
```

### Development vs Production Deployment

| Environment | Platform | Purpose | Deployment |
|-------------|----------|---------|------------|
| **Development** | Kind/K3s | Testing, development, integration | GitOps + Kubernetes |
| **Production Edge** | Docker Compose | Low-latency, reliable operation | GitOps → Compose files |
| **Orchestration** | Pi 4 + Docker Compose | Admin, monitoring, watchdog | GitOps → Compose files |

## 📋 Implementation Phases

### Phase 1: Foundation Extension (Current → PERCI Base)

**Goal**: Transform demo-hello into PERCI orchestrator

**Changes to Current Stack:**

1. **FastAPI Backend Extensions**
```python
# Current: Simple health check + mock devices
# Future: PERCI orchestration API

@app.get("/devices")  # Device discovery and health
@app.post("/deploy/{device_id}")  # Deploy services to devices
@app.get("/metrics/{service}")  # Service performance metrics
@app.post("/models/load")  # Model management
@app.get("/logs/{device_id}")  # Log aggregation

# MQTT Integration
@app.post("/mqtt/publish")  # Send commands via MQTT
@app.get("/mqtt/status")  # MQTT broker health
```

2. **Astro Frontend Extensions**
```typescript
// Current: Simple device status display
// Future: PERCI admin dashboard

- Real-time device health monitoring
- Service logs viewing (STT, NLP, LLM, TTS)
- Performance metrics dashboards
- Deployment management interface
- MQTT message monitoring
- Model loading status
```

3. **MQTT Backbone Integration**
```yaml
# Add to current stack:
MQTT Broker: 
  - Eclipse Mosquitto container
  - Topic structure for PERCI communication
  - Security configuration

Topic Structure:
  - perci/stt/audio → Raw audio to STT
  - perci/stt/text → Transcribed text
  - perci/nlp/processed → Processed/reconstructed text  
  - perci/core/input → Input to consciousness core
  - perci/llm/response → LLM response
  - perci/tts/audio → Audio output
  - perci/admin/* → Administrative commands
```

### Phase 2: Device-Specific Docker Compose

**Goal**: Create production deployment configurations

**Directory Structure:**
```
apps/
├── perci-orchestrator/     # Current demo-hello evolved
│   ├── backend/           # FastAPI orchestrator
│   ├── frontend/          # Astro admin interface  
│   └── k8s/              # Development deployment
├── device-configs/        # Production edge configs
│   ├── pi-stt/
│   │   ├── docker-compose.yml
│   │   ├── vosk-config/
│   │   └── models/
│   ├── pi-nlp/
│   │   ├── docker-compose.yml
│   │   ├── rwkv-config/
│   │   └── models/
│   ├── pi-tts/
│   │   ├── docker-compose.yml
│   │   └── tts-config/
│   ├── pi-orchestrator/
│   │   ├── docker-compose.yml  # Admin stack
│   │   └── nginx.conf
│   └── jetson-core/
│       ├── docker-compose.yml
│       ├── gpu-config/
│       └── models/
└── mqtt-backbone/
    ├── mosquitto.conf
    └── security/
```

**Example Pi STT Docker Compose:**
```yaml
# device-configs/pi-stt/docker-compose.yml
version: '3.8'
services:
  vosk-en:
    image: alphacep/kaldi-en:latest
    ports:
      - "2700:2700"
    volumes:
      - ./models:/opt/vosk-model

  vosk-multilang:
    image: alphacep/kaldi-multilang:latest
    ports:
      - "2701:2700"
    volumes:
      - ./models:/opt/vosk-model

  ser-model:
    build: ./ser-container
    depends_on:
      - vosk-en
    environment:
      - VOSK_SERVER=vosk-en:2700

  resemblyzer:
    build: ./resemblyzer-container
    volumes:
      - ./speaker-profiles:/app/profiles

  stt-coordinator:
    build: ./coordinator
    depends_on:
      - vosk-en
      - vosk-multilang
      - ser-model
      - resemblyzer
    environment:
      - MQTT_BROKER=pi-orchestrator.local:1883
    ports:
      - "8080:8080"

  watchdog:
    build: ./watchdog
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```

### Phase 3: GitOps Integration

**Goal**: Unified deployment pipeline for both K8s dev and Compose prod

**GitOps Structure:**
```
clusters/
├── dev/                   # Current K8s development
│   └── perci-orchestrator.yaml
├── production/            # Edge device management
│   ├── pi-stt.yaml       # FluxCD config for Pi STT
│   ├── pi-nlp.yaml
│   ├── pi-tts.yaml
│   ├── pi-orchestrator.yaml
│   └── jetson-core.yaml
└── shared/
    ├── mqtt-config/
    └── security/
```

**FluxCD Kustomizations for Edge Devices:**
```yaml
# clusters/production/pi-stt.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: pi-stt
  namespace: flux-system
spec:
  interval: 5m0s
  path: ./device-configs/pi-stt
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  postBuild:
    substitute:
      DEVICE_ID: "pi-stt-001"
      MQTT_BROKER: "pi-orchestrator.local"
  healthChecks:
    - apiVersion: v1
      kind: Service
      name: stt-coordinator
      namespace: default
```

## 🔧 Technical Implementation Details

### MQTT Message Flow

```
Audio Input → [Pi 1: STT] → perci/stt/text
                    ↓
perci/nlp/input ← [Pi 2: NLP] ← perci/stt/text
                    ↓
perci/core/input ← [Jetson: Core] ← perci/nlp/processed
                    ↓
perci/llm/response → [Jetson: LLM] → perci/tts/input
                    ↓
perci/tts/audio ← [Pi 3: TTS] ← perci/tts/input
                    ↓
Audio Output
```

**Administrative Flow:**
```
[Pi 4: Admin] → perci/admin/deploy → All devices
[Pi 4: Admin] ← perci/admin/status ← All devices
[Pi 4: Admin] → perci/admin/logs → Centralized logging
```

### Service Discovery & Health Monitoring

**Each device publishes:**
```json
{
  "device_id": "pi-stt-001",
  "services": ["vosk-en", "vosk-multilang", "ser-model"],
  "health": {
    "cpu_usage": 45.2,
    "memory_usage": 62.1,
    "disk_usage": 23.4,
    "gpu_usage": null
  },
  "last_seen": "2025-01-04T12:34:56Z"
}
```

**Orchestrator tracks:**
- Service availability across all devices
- Performance metrics and bottlenecks
- Message flow latency
- Error rates and failure patterns

### Configuration Management

**Shared Configuration:**
```yaml
# Managed via GitOps, deployed to all devices
mqtt:
  broker: "pi-orchestrator.local:1883"
  topics:
    stt_output: "perci/stt/text"
    nlp_input: "perci/nlp/input"
    # ... etc

models:
  stt:
    vosk_model_path: "/opt/models/vosk-model-en-us"
    ser_model_path: "/opt/models/ser-model"
  nlp:
    rwkv_model_path: "/opt/models/rwkv-mini"
  # ... etc

security:
  mqtt_username: "${MQTT_USER}"
  mqtt_password: "${MQTT_PASS}"
  device_certificates: "/opt/certs/"
```

### Deployment Pipeline

1. **Development**: Code changes → Git → FluxCD → K8s development cluster
2. **Testing**: Integration tests in K8s environment
3. **Production**: Git → FluxCD → Docker Compose files deployed to edge devices
4. **Monitoring**: All devices report back to orchestrator

## 🚀 Migration Path

### Week 1-2: Foundation Extension
- [ ] Extend FastAPI backend with PERCI orchestration endpoints
- [ ] Add MQTT broker to current stack
- [ ] Update Astro frontend for device monitoring
- [ ] Test MQTT communication in K8s environment

### Week 3-4: Docker Compose Creation
- [ ] Create Docker Compose files for each device type
- [ ] Build container images for PERCI components
- [ ] Test Docker Compose stacks locally
- [ ] Implement watchdog services

### Week 5-6: GitOps Integration
- [ ] Extend GitOps to manage Docker Compose deployments
- [ ] Create device-specific FluxCD configurations
- [ ] Implement automated deployment pipeline
- [ ] Test full GitOps → Docker Compose workflow

### Week 7-8: Production Deployment
- [ ] Deploy to actual Pi hardware
- [ ] Deploy to Jetson Orin NX
- [ ] Performance optimization and tuning
- [ ] Production monitoring and alerting

## 🎯 Success Metrics

**Development Environment:**
- [ ] PERCI components run successfully in K8s
- [ ] MQTT communication works end-to-end
- [ ] Admin interface provides full visibility
- [ ] GitOps pipeline deploys changes automatically

**Production Environment:**
- [ ] All Pi devices run their services reliably
- [ ] Jetson core processes LLM requests efficiently
- [ ] MQTT latency < 50ms for critical paths
- [ ] System recovers automatically from component failures
- [ ] Admin interface provides real-time monitoring

## 🔗 Integration with Colleague's Approach

This convergence strategy directly implements your colleague's recommended approach:

**Phase 1 Alignment:**
- ✅ Docker Compose on each device (production deployment)
- ✅ MQTT backbone for pub/sub communication
- ✅ Admin UI for monitoring (your Astro frontend)
- ✅ Watchdog outside Kubernetes (per-device Docker Compose)

**Phase 2+ Readiness:**
- 🎯 Easy transition from Docker Compose → K3s (same containers)
- 🎯 Service mesh patterns already established (nginx proxy)
- 🎯 Monitoring infrastructure ready for Prometheus/Grafana
- 🎯 Security patterns established for secrets management

**Key Insight**: Your Kubernetes development environment becomes the **testing and integration platform**, while production uses the simpler, more reliable Docker Compose approach your colleague recommends. Best of both worlds!