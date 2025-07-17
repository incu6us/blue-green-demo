# Kubernetes Deployment with Argo Rollouts and Istio

This directory contains Kubernetes manifests for deploying the demo application using Argo Rollouts with blue-green deployment strategy, Istio service mesh, and Istio Gateway.

## Prerequisites

1. **Kubernetes Cluster** with the following components installed:
   - Argo Rollouts Controller
   - Istio Service Mesh
   - Prometheus (for metrics collection)

2. **Docker Images** pushed to a public registry:
   - `incu6us/demo-app:latest`
   - `incu6us/demo-app-mock-backend:latest`

## Architecture

```
Internet
    ↓
Istio Gateway (Port 80/443)
    ↓
Istio VirtualService
    ↓
Demo App Active Service (Blue)
    ↓
Demo App Pods (v1)
    ↓
Mock Backend Service
    ↓
Mock Backend Pods
```

## Components

### 1. Namespace
- `demo-app` namespace for all resources

### 2. Configuration
- **ConfigMap**: Application configuration (BACKEND_URL, PORT)

### 3. Mock Backend
- **Deployment**: Mock backend service
- **Service**: Internal service for mock backend

### 4. Demo Application (Argo Rollouts)
- **Rollout**: Blue-green deployment strategy
- **Active Service**: Serves production traffic
- **Preview Service**: Serves new version during testing

### 5. Istio Components
- **Gateway**: External ingress point
- **VirtualService**: Traffic routing rules
- **DestinationRule**: Load balancing and circuit breaking

### 6. Analysis
- **AnalysisTemplate**: Success rate monitoring for rollouts

## Deployment Steps

### 1. Update Docker Images

Update the image references in the manifests:

```bash
# Update demo app image
sed -i 's|your-registry/demo-app:latest|your-actual-registry/demo-app:latest|g' deployment/argo-rollout.yaml

# Update mock backend image
sed -i 's|your-registry/demo-app-mock-backend:latest|your-actual-registry/demo-app-mock-backend:latest|g' deployment/mock-backend-deployment.yaml
```

### 2. Update Domain Names

Update the domain names in Istio resources:

```bash
# Replace demo-app.example.com with your actual domain
sed -i 's|demo-app.example.com|your-domain.com|g' deployment/istio-gateway.yaml
sed -i 's|demo-app.example.com|your-domain.com|g' deployment/istio-virtualservice.yaml
```

### 3. Deploy the Application

```bash
# Apply all resources
kubectl apply -k deployment/

# Or apply individually
kubectl apply -f deployment/namespace.yaml
kubectl apply -f deployment/configmap.yaml
kubectl apply -f deployment/mock-backend-deployment.yaml
kubectl apply -f deployment/argo-rollout.yaml
kubectl apply -f deployment/services.yaml
kubectl apply -f deployment/istio-gateway.yaml
kubectl apply -f deployment/istio-virtualservice.yaml
kubectl apply -f deployment/istio-destinationrule.yaml
kubectl apply -f deployment/analysis-template.yaml
```

## Blue-Green Deployment Process

### 1. Initial Deployment
```bash
# Deploy the first version
kubectl apply -f deployment/argo-rollout.yaml
```

### 2. Update to New Version
```bash
# Update the image in the rollout
kubectl set image rollout/demo-app-rollout demo-app=your-registry/demo-app:v2.0.0 -n demo-app
```

### 3. Monitor the Rollout
```bash
# Watch the rollout status
kubectl argo rollouts get rollout demo-app-rollout -n demo-app --watch

# Check rollout history
kubectl argo rollouts history rollout demo-app-rollout -n demo-app
```

### 4. Promote the Rollout
```bash
# Promote the preview to active (after testing)
kubectl argo rollouts promote demo-app-rollout -n demo-app
```

### 5. Rollback (if needed)
```bash
# Rollback to previous version
kubectl argo rollouts rollback demo-app-rollout -n demo-app
```

## Accessing the Application

### External Access
```bash
# Get the Istio Ingress Gateway IP
kubectl get svc -n istio-system istio-ingressgateway

# Access via domain (if configured)
curl http://your-domain.com

# Access via IP (for testing)
curl http://<INGRESS_IP>
```

### Internal Access
```bash
# Port forward to active service
kubectl port-forward svc/demo-app-active 9876:9876 -n demo-app

# Access locally
curl http://localhost:9876
```

## Monitoring and Observability

### Argo Rollouts Dashboard
```bash
# Install Argo Rollouts UI
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Port forward to Argo Rollouts UI
kubectl port-forward svc/argo-rollouts-dashboard 3100:3100 -n argo-rollouts
```

### Istio Kiali Dashboard
```bash
# Access Kiali (if installed)
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

### Prometheus Metrics
```bash
# Port forward to Prometheus
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
```

## Configuration

### Environment Variables
- `BACKEND_URL`: Backend service URL
- `PORT`: Application port

### Resource Limits
- **Demo App**: 256Mi memory, 200m CPU
- **Mock Backend**: 128Mi memory, 100m CPU

### Health Checks
- **Liveness Probe**: `/health` endpoint
- **Readiness Probe**: `/health` endpoint

## Troubleshooting

### Common Issues

1. **Rollout Stuck in Progress**
   ```bash
   # Check rollout status
   kubectl argo rollouts get rollout demo-app-rollout -n demo-app
   
   # Check pod status
   kubectl get pods -n demo-app -l app=demo-app
   ```

2. **Istio Gateway Not Working**
Install Istio and ensure the gateway is configured correctly(https://istio.io/latest/docs/setup/additional-setup/gateway/).
   ```bash
   curl -L https://istio.io/downloadIstio | sh -
   istioctl install --set profile=minimal
   ```

   ```bash
   # Check gateway status
   kubectl get gateway -n demo-app
   
   # Check virtual service
   kubectl get virtualservice -n demo-app
   ```

3. **Analysis Failing**
   ```bash
   # Check analysis runs
   kubectl get analysisruns -n demo-app
   
   # Check Prometheus connectivity
   kubectl port-forward svc/prometheus 9090:9090 -n monitoring
   ```

### Logs
```bash
# Demo app logs
kubectl logs -l app=demo-app -n demo-app

# Mock backend logs
kubectl logs -l app=mock-backend -n demo-app

# Istio proxy logs
kubectl logs -l app=demo-app -c istio-proxy -n demo-app
```

## Security Considerations

1. **Network Policies**: Consider implementing network policies
2. **RBAC**: Ensure proper RBAC for Argo Rollouts
3. **TLS**: Configure TLS certificates for production
4. **Secrets**: Use Kubernetes secrets for sensitive data

## Scaling

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo-app-hpa
  namespace: demo-app
spec:
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: demo-app-rollout
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Cleanup

```bash
# Delete all resources
kubectl delete -k deployment/

# Or delete individually
kubectl delete namespace demo-app
``` 
