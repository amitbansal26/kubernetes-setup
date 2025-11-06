# Nginx Ingress Controller

This directory contains Kubernetes manifests for deploying the Nginx Ingress Controller and MetalLB load balancer.

## Contents

- `ingress-service-account.yaml` - Service account and RBAC for ingress controller
- `admission-service-account.yaml` - Service account for admission webhook
- `configmap.yaml` - Configuration for ingress controller
- `services.yaml` - Services for ingress controller
- `deployment.yaml` - Ingress controller deployment
- `ingressclass.yaml` - IngressClass definition
- `validating-webhook.yaml` - Validating webhook configuration
- `jobs.yaml` - Jobs for webhook certificate management
- `metallb.yaml` - MetalLB installation manifest
- `metal-config.yaml` - MetalLB configuration

## Installation

### Quick Install (All Components)

```bash
kubectl apply -f nginx-ingress/
```

### Step-by-Step Installation

1. **Install RBAC and Service Accounts:**
   ```bash
   kubectl apply -f ingress-service-account.yaml
   kubectl apply -f admission-service-account.yaml
   ```

2. **Install ConfigMap:**
   ```bash
   kubectl apply -f configmap.yaml
   ```

3. **Install Services:**
   ```bash
   kubectl apply -f services.yaml
   ```

4. **Deploy Ingress Controller:**
   ```bash
   kubectl apply -f deployment.yaml
   ```

5. **Configure IngressClass:**
   ```bash
   kubectl apply -f ingressclass.yaml
   ```

6. **Set up Admission Webhook:**
   ```bash
   kubectl apply -f jobs.yaml
   kubectl apply -f validating-webhook.yaml
   ```

7. **Install MetalLB (optional, for LoadBalancer service type):**
   ```bash
   kubectl apply -f metallb.yaml
   
   # Wait for MetalLB to be ready
   kubectl wait --namespace metallb-system \
     --for=condition=ready pod \
     --selector=app=metallb \
     --timeout=90s
   
   # Apply MetalLB configuration
   kubectl apply -f metal-config.yaml
   ```

## Verification

### Check Ingress Controller Status

```bash
# Check pods
kubectl get pods -n ingress-nginx

# Check services
kubectl get svc -n ingress-nginx

# Check logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### Check MetalLB Status

```bash
# Check MetalLB pods
kubectl get pods -n metallb-system

# Check MetalLB configuration
kubectl get ipaddresspool -n metallb-system
kubectl get l2advertisement -n metallb-system
```

## Usage

### Create an Ingress Resource

Example ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
```

Apply the ingress:

```bash
kubectl apply -f ingress.yaml
```

### Test the Ingress

```bash
# Get the ingress IP
kubectl get ingress example-ingress

# Test with curl
curl -H "Host: example.local" http://<INGRESS_IP>
```

## MetalLB Configuration

The `metal-config.yaml` defines IP address pools for LoadBalancer services.

Default configuration:
- IP Pool: Defined in the metal-config.yaml
- Mode: Layer 2 (L2Advertisement)

To modify the IP pool:

```bash
kubectl edit ipaddresspool -n metallb-system
```

## Customization

### Ingress Controller ConfigMap

Edit `configmap.yaml` to customize ingress behavior:

```yaml
data:
  use-forwarded-headers: "true"
  compute-full-forwarded-for: "true"
  proxy-body-size: "50m"
  # Add more configurations as needed
```

Apply changes:

```bash
kubectl apply -f configmap.yaml
kubectl rollout restart deployment -n ingress-nginx ingress-nginx-controller
```

### SSL/TLS Configuration

To enable HTTPS:

1. Create a TLS secret:
   ```bash
   kubectl create secret tls example-tls \
     --cert=path/to/tls.crt \
     --key=path/to/tls.key
   ```

2. Reference in ingress:
   ```yaml
   spec:
     tls:
     - hosts:
       - example.local
       secretName: example-tls
   ```

## Troubleshooting

### Ingress Controller Not Starting

Check events:
```bash
kubectl describe pod -n ingress-nginx <pod-name>
```

Check logs:
```bash
kubectl logs -n ingress-nginx <pod-name>
```

### MetalLB Not Assigning IPs

Check MetalLB speaker logs:
```bash
kubectl logs -n metallb-system -l component=speaker
```

Check MetalLB controller logs:
```bash
kubectl logs -n metallb-system -l component=controller
```

Verify IP pool configuration:
```bash
kubectl get ipaddresspool -n metallb-system -o yaml
```

### Ingress Not Routing Traffic

1. Verify ingress resource:
   ```bash
   kubectl describe ingress <ingress-name>
   ```

2. Check backend service:
   ```bash
   kubectl get svc <service-name>
   kubectl get endpoints <service-name>
   ```

3. Test from within the cluster:
   ```bash
   kubectl run test --rm -it --image=curlimages/curl -- sh
   # Inside the pod:
   curl http://<service-name>
   ```

## Uninstallation

To remove all components:

```bash
kubectl delete -f nginx-ingress/
```

Or remove individually:

```bash
kubectl delete -f metal-config.yaml
kubectl delete -f metallb.yaml
kubectl delete -f validating-webhook.yaml
kubectl delete -f jobs.yaml
kubectl delete -f ingressclass.yaml
kubectl delete -f deployment.yaml
kubectl delete -f services.yaml
kubectl delete -f configmap.yaml
kubectl delete -f admission-service-account.yaml
kubectl delete -f ingress-service-account.yaml
```

## References

- [Nginx Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)
- [MetalLB Documentation](https://metallb.universe.tf/)
- [Kubernetes Ingress Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)
